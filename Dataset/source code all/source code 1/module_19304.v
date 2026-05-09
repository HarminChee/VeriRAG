module cordic_rom (
	address,
	X5,
	Y5,clk);
input	[3:0]  address;
input clk;
output	reg [21:0]  X5;
output reg [21:0]  Y5;
parameter[21:0] c0=22'b0111111111101010101010;
parameter[21:0] c1=22'b0111111101101010110010;
parameter[21:0] c2=22'b0111111001101011100010;
parameter[21:0] c3=22'b0111110011101101111010;
parameter[21:0] c4=22'b0111101011110011011001;
parameter[21:0] c5=22'b0111100001111101111101;
parameter[21:0] c6=22'b0111010110010000000101;
parameter[21:0] c7=22'b0111001000101100101011;
parameter[21:0] c8=22'b0110111001010111001000;
parameter[21:0] c9=22'b0110101000010011010010;
parameter[21:0] c10=22'b0110010101100101011001;
parameter[21:0] c11=22'b0110000001010010001001;
parameter[21:0] c12=22'b0101101011011110100110;
parameter[21:0] s0=22'b0000001111111111101010;
parameter[21:0] s1=22'b0000101111111011000000;
parameter[21:0] s2=22'b0001001111101010010111;
parameter[21:0] s3=22'b0001101111000101110100;
parameter[21:0] s4=22'b0010001110000101011111;
parameter[21:0] s5=22'b0010101100100001101011;
parameter[21:0] s6=22'b0011001010010010101111;
parameter[21:0] s7=22'b0011100111010001001111;
parameter[21:0] s8=22'b0100000011010101111100;
parameter[21:0] s9=22'b0100011110011001110101;
parameter[21:0] s10=22'b0100111000010110001001;
parameter[21:0] s11=22'b0101010001000100011001;
parameter[21:0] s12=22'b0101101000011110011001;
		always@(posedge clk)
			begin
				case(address)
					4'b0000:
					begin
					X5<=c0;
					Y5<=s0;
					end
					4'b0001:
					begin
					X5<=c1;
					Y5<=s1;		
					end		
					4'b0010:
					begin
					X5<=c2;
					Y5<=s2;		
					end
					4'b0011:
					begin
					X5<=c3;
					Y5<=s3;		
					end
					4'b0100:
					begin
					X5<=c4;
					Y5<=s4;		
					end
					4'b0101:
					begin
					X5<=c5;
					Y5<=s5;		
					end
					4'b0110:
					begin
					X5<=c6;
					Y5<=s6;		
					end
					4'b0111:
					begin
					X5<=c7;
					Y5<=s7;		
					end
					4'b1000:
					begin
					X5<=c8;
					Y5<=s8;		
					end
					4'b1001:
					begin
					X5<=c9; 
					Y5<=s9;		
					end
					4'b1010:
					begin
					X5<=c10;
					Y5<=s10;		
					end
					4'b1011:
					begin
					X5<=c11;
					Y5<=s11;		
					end
					4'b1100:
					begin
					X5<=c12;
					Y5<=s12;		
					end
					default:
					begin
					X5<=0;
					Y5<=0;
					end
				endcase
			end
endmodule
