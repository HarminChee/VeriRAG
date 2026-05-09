module yuv422_to_yuv444
(
	input 	wire			iCLK,
	input 	wire			iRST_N,	
	input 	wire [15:0] 	iYCbCr,
	input	wire 			iYCbCr_valid,
	output	reg [7:0]		oY,
	output	reg [7:0]		oCb,
	output	reg [7:0]		oCr,
	output	reg			oYCbCr_valid
);
reg 			every_other;
reg		[7:0]	mY;
reg		[7:0]	mCb;
reg		[7:0]	mCr;
reg 			mValid;
// assign	oY			 =	mY;
// assign	oCb			 =	mCb;
// assign	oCr			 =	mCr;
// assign  oYCbCr_valid = mValid;
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
		begin
			every_other  <= 0;
			mY			 <=	0;
			mCb			 <=	0;
			mCr			 <=	0;
			mValid 		 <= 0;
			oY <= 0;
			oCb <= 0;
			oCr <= 0;
			oYCbCr_valid <= 0;
		end
	else
		begin
			every_other  <= ~every_other;
			mValid <= iYCbCr_valid;
			if(iYCbCr_valid) begin
				if(every_other)
					begin
						mY	<=	iYCbCr[15:8];
						mCr	<=	iYCbCr[7:0];
					end
				else
					begin
						mY	<=	iYCbCr[15:8];
						mCb	<=	iYCbCr[7:0];
					end
			end
			oY <= mY;
			oCb <= mCb;
			oCr <= mCr;
			oYCbCr_valid <= mValid;
		end
end
endmodule