module yuv422_to_yuv444
(
	input 	wire			iCLK,
	input 	wire			iRST_N,	
	input 	wire [15:0] 	iYCbCr,
	input	wire 			iYCbCr_valid,
	input	wire			test_i,
	input	wire			scan_every_other,
	input	wire [7:0]		scan_mY,
	input	wire [7:0]		scan_mCb,
	input	wire [7:0]		scan_mCr,
	input	wire			scan_mValid,
	output	wire [7:0]		oY,
	output	wire [7:0]		oCb,
	output	wire [7:0]		oCr,
	output	wire			oYCbCr_valid
);
reg 			every_other;
wire			dft_every_other;
assign			dft_every_other = test_i ? scan_every_other : every_other;
reg		[7:0]	mY;
reg		[7:0]	mCb;
reg		[7:0]	mCr;
reg 			mValid;
wire	[7:0]	dft_mY;
assign			dft_mY = test_i ? scan_mY : mY;
wire	[7:0]	dft_mCb;
assign			dft_mCb = test_i ? scan_mCb : mCb;
wire	[7:0]	dft_mCr;
assign			dft_mCr = test_i ? scan_mCr : mCr;
wire			dft_mValid;
assign			dft_mValid = test_i ? scan_mValid : mValid;
assign	oY			 =	dft_mY;
assign	oCb			 =	dft_mCb;
assign	oCr			 =	dft_mCr;
assign  oYCbCr_valid = dft_mValid;
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
			every_other  <= ~every_other;
			mValid <= iYCbCr_valid;
			if(every_other)
				{mY,mCr}	<=	iYCbCr;
			else
				{mY,mCb}	<=	iYCbCr;
		end
end
endmodule