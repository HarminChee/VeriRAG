module	LCD_TEST (	
					iCLK,iRST_N,
					d0,d1,d2,d3,d4,d5,
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS	);
input			iCLK,iRST_N;
input  [15:0] d0,d1,d2,d3,d4,d5;
output	[7:0]	LCD_DATA;
output			LCD_RW,LCD_EN,LCD_RS;
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg			mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
wire		mLCD_Done;
parameter	LCD_INTIAL	=	0;
parameter	LCD_RESTART	=	4;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE2+16-1;
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;					
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY+1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
			3:	begin
					if(LUT_INDEX<LUT_SIZE)
						LUT_INDEX	<=	LUT_INDEX+1;
					else
						LUT_INDEX	<=	LCD_RESTART;
					mLCD_ST	<=	0;
				end
			endcase
		end
	end
end
function [8:0] hex2char;
	input [3:0] h;
	hex2char = (h>9 ? 9'h137 : 9'h130) + h;	
endfunction
always
begin
	case(LUT_INDEX)
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	LCD_LINE1+0:	LUT_DATA	<=	9'h120;	
	LCD_LINE1+1:	LUT_DATA	<=	hex2char(d0[15:12]);
	LCD_LINE1+2:	LUT_DATA	<=	hex2char(d0[11: 8]);
	LCD_LINE1+3:	LUT_DATA	<=	hex2char(d0[ 7: 4]);
	LCD_LINE1+4:	LUT_DATA	<=	hex2char(d0[ 3: 0]);
	LCD_LINE1+5:	LUT_DATA	<=	9'h120;             
	LCD_LINE1+6:	LUT_DATA	<=	hex2char(d1[15:12]);
	LCD_LINE1+7:	LUT_DATA	<=	hex2char(d1[11: 8]);
	LCD_LINE1+8:	LUT_DATA	<=	hex2char(d1[ 7: 4]);
	LCD_LINE1+9:	LUT_DATA	<=	hex2char(d1[ 3: 0]);
	LCD_LINE1+10:	LUT_DATA	<=	9'h120;             
	LCD_LINE1+11:	LUT_DATA	<=	hex2char(d2[15:12]);
	LCD_LINE1+12:	LUT_DATA	<=	hex2char(d2[11: 8]);
	LCD_LINE1+13:	LUT_DATA	<=	hex2char(d2[ 7: 4]);
	LCD_LINE1+14:	LUT_DATA	<=	hex2char(d2[ 3: 0]);
	LCD_LINE1+15:	LUT_DATA	<=	9'h120;             
	LCD_CH_LINE:	LUT_DATA	<=  9'h0C0;	                    
	LCD_LINE2+0:	LUT_DATA	<=  9'h120;
	LCD_LINE2+1:	LUT_DATA	<=	hex2char(d3[15:12]);
	LCD_LINE2+2:	LUT_DATA	<=	hex2char(d3[11: 8]);
	LCD_LINE2+3:	LUT_DATA	<=	hex2char(d3[ 7: 4]);
	LCD_LINE2+4:	LUT_DATA	<=	hex2char(d3[ 3: 0]);
	LCD_LINE2+5:	LUT_DATA	<=	9'h120;             
	LCD_LINE2+6:	LUT_DATA	<=	hex2char(d4[15:12]);
	LCD_LINE2+7:	LUT_DATA	<=	hex2char(d4[11: 8]);
	LCD_LINE2+8:	LUT_DATA	<=	hex2char(d4[ 7: 4]);
	LCD_LINE2+9:	LUT_DATA	<=	hex2char(d4[ 3: 0]);
	LCD_LINE2+10:	LUT_DATA	<=	9'h120;             
	LCD_LINE2+11:	LUT_DATA	<=	hex2char(d5[15:12]);
	LCD_LINE2+12:	LUT_DATA	<=	hex2char(d5[11: 8]);
	LCD_LINE2+13:	LUT_DATA	<=	hex2char(d5[ 7: 4]);
	LCD_LINE2+14:	LUT_DATA	<=	hex2char(d5[ 3: 0]);
	LCD_LINE2+15:	LUT_DATA	<=	9'h120;
	default:	    LUT_DATA	<=	9'h120;
	endcase
end
LCD_Controller 		u0	(	
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(iCLK),
							.iRST_N(iRST_N),
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);
endmodule
