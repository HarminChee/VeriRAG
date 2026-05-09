module yuv422_to_yuv444_corrected_cdf
(
	input 	wire			iCLK,
	input 	wire			iRST_N,
	input 	wire			test_mode,    // Added test mode signal for DFT
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

// DFT Modification: Synchronous handling of reset during test_mode
// Reset is active low asynchronously in functional mode (test_mode=0)
// Reset is effectively disabled in test mode (test_mode=1) to allow scan testing
wire rst_n_sync = iRST_N | test_mode;

assign	oY			 =	mY;
assign	oCb			 =	mCb;
assign	oCr			 =	mCr;
assign  oYCbCr_valid = mValid;

// DFT Modification: Changed sensitivity list to only posedge iCLK
// Asynchronous reset logic is handled inside based on rst_n_sync
always@(posedge iCLK)
begin
	// Reset logic: Active only when rst_n_sync is low (i.e., functional mode and iRST_N is low)
	if(!rst_n_sync)
		begin
			every_other  <= 1'b0;
			mY			 <=	8'b0;
			mCb			 <=	8'b0;
			mCr			 <=	8'b0;
			mValid 		 <= 1'b0;
		end
	// Normal synchronous operation
	else
		begin
			every_other  <= ~every_other; // Toggle on each clock cycle
			mValid <= iYCbCr_valid;
			if(every_other) // On odd cycles (assuming starts at 0)
				{mY,mCr}	<=	iYCbCr; // Capture Y and Cr
			else // On even cycles
				{mY,mCb}	<=	iYCbCr; // Capture Y and Cb
		end
end
endmodule