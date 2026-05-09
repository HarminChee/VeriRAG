module AUDIO_DAC_FIFO (	
						input wire test_i,
						input wire [DATA_WIDTH-1:0] iDATA,
						input wire iWR,
						input wire iWR_CLK,
						output wire [DATA_WIDTH-1:0] oDATA,
						output wire oAUD_BCK,
						output wire oAUD_DATA,
						output wire oAUD_LRCK,
						output wire oAUD_XCK,
						input wire iCLK_18_4,
						input wire iRST_N
					);
parameter REF_CLK = 18432000;
parameter SAMPLE_RATE = 48000;
parameter DATA_WIDTH = 16;
parameter CHANNEL_NUM = 2;

wire [DATA_WIDTH-1:0] mDATA;
reg mDATA_RD;
reg oAUD_BCK;
reg [3:0] BCK_DIV;
reg [8:0] LRCK_1X_DIV;
reg [7:0] LRCK_2X_DIV;
reg [3:0] SEL_Cont;
reg [DATA_WIDTH-1:0] DATA_Out;
reg [DATA_WIDTH-1:0] DATA_Out_Tmp;
reg LRCK_1X;
reg LRCK_2X;
wire dft_rst;

assign dft_rst = test_i ? ~iRST_N : ~iRST_N;

FIFO_16_256 u0 (
	.data(iDATA),
	.wrreq(iWR),
	.rdreq(mDATA_RD),
	.rdclk(iCLK_18_4),
	.wrclk(iWR_CLK),
	.aclr(dft_rst),
	.q(mDATA),
	.wrfull(oDATA[0])
);

assign oAUD_XCK = ~iCLK_18_4;

always @(posedge iCLK_18_4 or posedge dft_rst) begin
	if (dft_rst) begin
		BCK_DIV <= 0;
		oAUD_BCK <= 0;
	end else begin
		if (BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1) begin
			BCK_DIV <= 0;
			oAUD_BCK <= ~oAUD_BCK;
		end else begin
			BCK_DIV <= BCK_DIV + 1;
		end
	end
end

always @(posedge iCLK_18_4 or posedge dft_rst) begin
	if (dft_rst) begin
		LRCK_1X_DIV <= 0;
		LRCK_2X_DIV <= 0;
		LRCK_1X <= 0;
		LRCK_2X <= 0;
	end else begin
		if (LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1) begin
			LRCK_1X_DIV <= 0;
			LRCK_1X <= ~LRCK_1X;
		end else begin
			LRCK_1X_DIV <= LRCK_1X_DIV + 1;
		end
		if (LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1) begin
			LRCK_2X_DIV <= 0;
			LRCK_2X <= ~LRCK_2X;
		end else begin
			LRCK_2X_DIV <= LRCK_2X_DIV + 1;
		end
	end
end

assign oAUD_LRCK = LRCK_1X;

always @(posedge iCLK_18_4 or posedge dft_rst) begin
	if (dft_rst) begin
		mDATA_RD <= 0;
	end else begin
		if (LRCK_1X_DIV == REF_CLK/(SAMPLE_RATE*2)-1)
			mDATA_RD <= 1;
		else
			mDATA_RD <= 0;
	end
end

always @(posedge iCLK_18_4 or posedge dft_rst) begin
	if (dft_rst) begin
		DATA_Out_Tmp <= 0;
	end else begin
		if (LRCK_2X_DIV == REF_CLK/(SAMPLE_RATE*4)-1)
			DATA_Out_Tmp <= mDATA;
	end
end

always @(posedge iCLK_18_4 or posedge dft_rst) begin
	if (dft_rst) begin
		DATA_Out <= 0;
	end else begin
		if (LRCK_2X_DIV == REF_CLK/(SAMPLE_RATE*4)-3)
			DATA_Out <= DATA_Out_Tmp;
	end
end

always @(negedge oAUD_BCK or posedge dft_rst) begin
	if (dft_rst) begin
		SEL_Cont <= 0;
	end else begin
		SEL_Cont <= SEL_Cont + 1;
	end
end

assign oAUD_DATA = DATA_Out[~SEL_Cont];

endmodule