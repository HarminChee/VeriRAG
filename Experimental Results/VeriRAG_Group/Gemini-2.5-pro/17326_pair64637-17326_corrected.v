module yuv422_to_yuv444
(
	input 	wire			iCLK,
	input 	wire			iRST_N,
    input   wire            scan_phi, // Added for test clock
    input   wire            test_i,   // Added for test mode
	input 	wire [15:0] 	iYCbCr,
	input	wire 			iYCbCr_valid,
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
wire            dft_clk; // Multiplexed clock
assign	oY			 =	mY;
assign	oCb			 =	mCb;
assign	oCr			 =	mCr;
assign  oYCbCr_valid = mValid;
// Clock MUX for DFT
assign dft_clk = test_i ? scan_phi : iCLK;
always@(posedge dft_clk or negedge iRST_N) // Use multiplexed clock
begin
	if(!iRST_N)
		begin
			every_other  <= 1'b0; // Use explicit width and base
			mY			 <=	8'b0; // Use explicit width and base
			mCb			 <=	8'b0; // Use explicit width and base
			mCr			 <=	8'b0; // Use explicit width and base
			mValid 		 <= 1'b0; // Use explicit width and base
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