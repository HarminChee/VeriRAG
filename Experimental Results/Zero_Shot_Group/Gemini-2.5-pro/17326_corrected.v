module yuv422_to_yuv444
(
	input 	wire			iCLK,
	input 	wire			iRST_N,
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

assign	oY			 =	mY;
assign	oCb			 =	mCb;
assign	oCr			 =	mCr;
assign  oYCbCr_valid = mValid;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
		begin
			every_other  <= 1'b0; // Initialize to a known state (e.g., expect Cb first)
			mY			 <=	8'b0;
			mCb			 <=	8'b0;
			mCr			 <=	8'b0;
			mValid 		 <= 1'b0;
		end
	else
		begin
			mValid <= iYCbCr_valid; // Output valid follows input valid

			if (iYCbCr_valid) // Only update registers and toggle when input is valid
			  begin
			  	every_other <= ~every_other; // Toggle state for next valid input
			  	mY <= iYCbCr[15:8];      // Always update Y from upper byte

			  	// Assuming input sequence is {Y0, Cb0}, {Y1, Cr0}, {Y2, Cb1}, {Y3, Cr1} ...
			  	// When every_other is 0 (initial state after reset, or after Cr cycle), expect Cb input
			  	// When every_other is 1 (after Cb cycle), expect Cr input
			  	if(~every_other) // Check the state *before* toggling for the current input type
			  	  begin
			  	    // Current input is {Y_even, Cb_n}
			  	    mCb <= iYCbCr[7:0]; // Update Cb from lower byte
			  	    // mCr holds Cr_(n-1) from the previous cycle
			  	  end
			  	else // every_other was 1 before toggling
			  	  begin
			  	    // Current input is {Y_odd, Cr_n}
			  	    mCr <= iYCbCr[7:0]; // Update Cr from lower byte
			  	    // mCb holds Cb_n from the previous cycle
			  	  end
			  end
			// If iYCbCr_valid is low, registers hold their values, mValid goes low.
		end
end

endmodule