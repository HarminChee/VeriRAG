module trng_apbif (
output  reg  sfr_CTRL_ENABLE,	
output  reg  sfr_CTRL_READY,	
output  reg  sfr_CTRL_PP,	
output  reg  sfr_CTRL_FIFO,	
output  reg  [32-1:0] sfr_RNDDAT,
output  reg  [32-1:0] sfr_PPCONF,
output  reg  [32-1:0] sfr_SRCCONF,
output  reg  [128-1:0] sfr_SRCINIT,
output  reg  [32-1:0] sfr_SPYSEL,
input   wire sfr_CTRL_READY_wr,
input   wire sfr_CTRL_READY_wren,
input   wire [32-1:0] sfr_RNDDAT_wr,
input   wire sfr_RNDDAT_wren,
output  reg  sfr_RNDDAT_read,
input   wire        i_clk,
input   wire        i_apb_clk_en,
input   wire        PRESETn,
input   wire        PSEL,
input   wire [11:0] PADDR,
input   wire        PENABLE,
input   wire        PWRITE,
input   wire [3:0]  PSTRB,
input   wire [31:0] PWDATA,
output  reg  [31:0] PRDATA,
output  reg         PREADY,
output  reg         PSLVERR
);
wire [32-1:0]  sfr_CTRL = {{28{1'b0}}
			,sfr_CTRL_FIFO
			,sfr_CTRL_PP
			,sfr_CTRL_READY
			,sfr_CTRL_ENABLE
};
wire sfr_valid_access = PSEL & (PADDR < 36);
assign PSLVERR = 1'b0;
assign PREADY  = 1'b1;
wire sfr_write_access = sfr_valid_access & PENABLE & PWRITE & i_apb_clk_en;
wire sfr_read_access  = sfr_valid_access & ~PWRITE;
wire sfr_read_access_1st_cycle = sfr_read_access & ~PENABLE;
wire sfr_read_access_2nd_cycle = sfr_read_access & PENABLE;
reg [9:0] word_address;
always @(posedge i_clk) if(i_apb_clk_en) word_address <= PADDR[11:2];
reg read_gate;
always @(posedge i_clk) begin
	read_gate <= i_apb_clk_en & sfr_read_access_1st_cycle;
end
reg [31:0] sfr_read_value;
always @* begin
	if(read_gate) PRDATA = sfr_read_value;
end
reg sfr_RNDDAT_read_apb;
always @* sfr_RNDDAT_read = read_gate & sfr_RNDDAT_read_apb; 
always @* begin
	sfr_read_value = 32'hDEADBEEF;
	{sfr_RNDDAT_read_apb} = {1{1'b0}};
	if (sfr_read_access) begin
		case(word_address)		
		0: sfr_read_value = sfr_CTRL;
		1: begin
			sfr_read_value = sfr_RNDDAT;
			sfr_RNDDAT_read_apb = 1'b1;
		end
		2: sfr_read_value = sfr_PPCONF;
		3: sfr_read_value = sfr_SRCCONF;
		4: sfr_read_value = sfr_SRCINIT[0*32+:32];
		5: sfr_read_value = sfr_SRCINIT[1*32+:32];
		6: sfr_read_value = sfr_SRCINIT[2*32+:32];
		7: sfr_read_value = sfr_SRCINIT[3*32+:32];
		8: sfr_read_value = sfr_SPYSEL;
		endcase
	end 
end
always @(posedge i_clk or negedge PRESETn) begin
	if(~PRESETn) begin
		sfr_CTRL_ENABLE <= 0;
		sfr_CTRL_READY <= 0;
		sfr_CTRL_PP <= 0;
		sfr_CTRL_FIFO <= 0;
		sfr_RNDDAT <= 0;
		sfr_PPCONF <= 0;
		sfr_SRCCONF <= 0;
		sfr_SRCINIT <= 0;
		sfr_SPYSEL <= 0;
    end else begin
		if(sfr_write_access) begin
			case(word_address)
			0: begin
				if (PSTRB[0]) sfr_CTRL_ENABLE <= PWDATA[0*8+0+:1];
				if (PSTRB[0]) sfr_CTRL_PP <= PWDATA[0*8+2+:1];
				if (PSTRB[0]) sfr_CTRL_FIFO <= PWDATA[0*8+3+:1];
			end
			1: begin
			end
			2: begin
				if (PSTRB[0]) sfr_PPCONF[0*8+:8] <= PWDATA[0*8+:8];
				if (PSTRB[1]) sfr_PPCONF[1*8+:8] <= PWDATA[1*8+:8];
				if (PSTRB[2]) sfr_PPCONF[2*8+:8] <= PWDATA[2*8+:8];
				if (PSTRB[3]) sfr_PPCONF[3*8+:8] <= PWDATA[3*8+:8];
			end
			3: begin
				if (PSTRB[0]) sfr_SRCCONF[0*8+:8] <= PWDATA[0*8+:8];
				if (PSTRB[1]) sfr_SRCCONF[1*8+:8] <= PWDATA[1*8+:8];
				if (PSTRB[2]) sfr_SRCCONF[2*8+:8] <= PWDATA[2*8+:8];
				if (PSTRB[3]) sfr_SRCCONF[3*8+:8] <= PWDATA[3*8+:8];
			end
			4: begin
				if (PSTRB[0]) sfr_SRCINIT[0*32+0*8+:8] <= PWDATA[0*8+:8];
				if (PSTRB[1]) sfr_SRCINIT[0*32+1*8+:8] <= PWDATA[1*8+:8];
				if (PSTRB[2]) sfr_SRCINIT[0*32+2*8+:8] <= PWDATA[2*8+:8];
				if (PSTRB[3]) sfr_SRCINIT[0*32+3*8+:8] <= PWDATA[3*8+:8];
			end
			5: begin
				if (PSTRB[0]) sfr_SRCINIT[1*32+0*8+:8] <= PWDATA[0*8+:8];
				if (PSTRB[1]) sfr_SRCINIT[1*32+1*8+:8] <= PWDATA[1*8+:8];
				if (PSTRB[2]) sfr_SRCINIT[1*32+2*8+:8] <= PWDATA[2*8+:8];
				if (PSTRB[3]) sfr_SRCINIT[1*32+3*8+:8] <= PWDATA[3*8+:8];
			end
			6: begin
				if (PSTRB[0]) sfr_SRCINIT[2*32+0*8+:8] <= PWDATA[0*8+:8];
				if (PSTRB[1]) sfr_SRCINIT[2*32+1*8+:8] <= PWDATA[1*8+:8];
				if (PSTRB[2]) sfr_SRCINIT[2*32+2*8+:8] <= PWDATA[2*8+:8];
				if (PSTRB[3]) sfr_SRCINIT[2*32+3*8+:8] <= PWDATA[3*8+:8];
			end
			7: begin
				if (PSTRB[0]) sfr_SRCINIT[3*32+0*8+:8] <= PWDATA[0*8+:8];
				if (PSTRB[1]) sfr_SRCINIT[3*32+1*8+:8] <= PWDATA[1*8+:8];
				if (PSTRB[2]) sfr_SRCINIT[3*32+2*8+:8] <= PWDATA[2*8+:8];
				if (PSTRB[3]) sfr_SRCINIT[3*32+3*8+:8] <= PWDATA[3*8+:8];
			end
			8: begin
				if (PSTRB[0]) sfr_SPYSEL[0*8+:8] <= PWDATA[0*8+:8];
				if (PSTRB[1]) sfr_SPYSEL[1*8+:8] <= PWDATA[1*8+:8];
				if (PSTRB[2]) sfr_SPYSEL[2*8+:8] <= PWDATA[2*8+:8];
				if (PSTRB[3]) sfr_SPYSEL[3*8+:8] <= PWDATA[3*8+:8];
			end
			endcase
		end else begin 
		end
		if (sfr_CTRL_READY_wren) sfr_CTRL_READY <= sfr_CTRL_READY_wr;
		if (sfr_RNDDAT_wren) sfr_RNDDAT <= sfr_RNDDAT_wr;
	end
end
endmodule
