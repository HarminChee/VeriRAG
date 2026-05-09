module yuv422_to_yuv444_corrected_cdf
(
	input 	wire			iCLK,
	input 	wire			iRST_N,	
	input 	wire [15:0] 	iYCbCr,
	input	wire 			iYCbCr_valid,
	input   wire            test_mode,
	output	wire [7:0]		oY,
	output	wire [7:0]		oCb,
	output	wire [7:0]		oCr,
	output	wire			oYCbCr_valid
);
reg 			every_other;
reg		[7:0]	mY;
reg		[7:0]	mCb;
reg		[7:0]	mCr;
reg 			mValid;
wire            data_sel;

assign	data_sel = test_mode ? 1'b0 : every_other;
assign	oY			 =	mY;
assign	oCb			 =	mCb;
assign	oCr			 =	mCr;
assign  oYCbCr_valid = mValid;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
		begin
			every_other  <= 0;
			mY			 <=	0;
			mCb			 <=	0;
			mCr			 <=	0;
			mValid 		 <= 0;
		end
	else
		begin
			every_other  <= ~every_other & ~test_mode;
			mValid <= iYCbCr_valid;
			if(data_sel)
				{mY,mCr}	<=	iYCbCr;
			else
				{mY,mCb}	<=	iYCbCr;
		end
end
endmodule