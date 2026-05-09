`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Priority_Codec_64(
    input wire [54:0]  Data_Dec_i,
    output reg [5:0] Data_Bin_o
    );
always @(Data_Dec_i)
	begin
	Data_Bin_o=6'b000000;
		if(~Data_Dec_i[54]) begin Data_Bin_o = 6'b000000;
		end else if(~Data_Dec_i[53]) begin Data_Bin_o = 6'b000001;
		end else if(~Data_Dec_i[52]) begin Data_Bin_o = 6'b000010;
		end else if(~Data_Dec_i[51]) begin Data_Bin_o = 6'b000011;
		end else if(~Data_Dec_i[50]) begin Data_Bin_o = 6'b000100;
		end else if(~Data_Dec_i[49]) begin Data_Bin_o = 6'b000101;
		end else if(~Data_Dec_i[48]) begin Data_Bin_o = 6'b000110;
		end else if(~Data_Dec_i[47]) begin Data_Bin_o = 6'b000111;
		end else if(~Data_Dec_i[46]) begin Data_Bin_o = 6'b001000;
		end else if(~Data_Dec_i[45]) begin Data_Bin_o = 6'b001001;
		end else if(~Data_Dec_i[44]) begin Data_Bin_o = 6'b001010;
		end else if(~Data_Dec_i[43]) begin Data_Bin_o = 6'b001011;
		end else if(~Data_Dec_i[42]) begin Data_Bin_o = 6'b001100;
		end else if(~Data_Dec_i[41]) begin Data_Bin_o = 6'b001101;
		end else if(~Data_Dec_i[40]) begin Data_Bin_o = 6'b001110;
		end else if(~Data_Dec_i[39]) begin Data_Bin_o = 6'b001111;
		end else if(~Data_Dec_i[38]) begin Data_Bin_o = 6'b010000;
		end else if(~Data_Dec_i[37]) begin Data_Bin_o = 6'b010001;
		end else if(~Data_Dec_i[36]) begin Data_Bin_o = 6'b010010;
		end else if(~Data_Dec_i[35]) begin Data_Bin_o = 6'b010011;
		end else if(~Data_Dec_i[34]) begin Data_Bin_o = 6'b010100;
		end else if(~Data_Dec_i[33]) begin Data_Bin_o = 6'b010101;
		end else if(~Data_Dec_i[32]) begin Data_Bin_o = 6'b010110;
		end else if(~Data_Dec_i[31]) begin Data_Bin_o = 6'b010111;
		end else if(~Data_Dec_i[30]) begin Data_Bin_o = 6'b011000;
		end else if(~Data_Dec_i[29]) begin Data_Bin_o = 6'b010101;
		end else if(~Data_Dec_i[28]) begin Data_Bin_o = 6'b010110;
		end else if(~Data_Dec_i[27]) begin Data_Bin_o = 6'b010111;
		end else if(~Data_Dec_i[26]) begin Data_Bin_o = 6'b011000;
		end else if(~Data_Dec_i[25]) begin Data_Bin_o = 6'b011001;
		end else if(~Data_Dec_i[24]) begin Data_Bin_o = 6'b011010;
		end else if(~Data_Dec_i[23]) begin Data_Bin_o = 6'b011011;
		end else if(~Data_Dec_i[22]) begin Data_Bin_o = 6'b011100;
		end else if(~Data_Dec_i[21]) begin Data_Bin_o = 6'b011101;
		end else if(~Data_Dec_i[20]) begin Data_Bin_o = 6'b011110;
		end else if(~Data_Dec_i[19]) begin Data_Bin_o = 6'b011111;
		end else if(~Data_Dec_i[18]) begin Data_Bin_o = 6'b100000;
		end else if(~Data_Dec_i[17]) begin Data_Bin_o = 6'b100001;
		end else if(~Data_Dec_i[16]) begin Data_Bin_o = 6'b100010;
		end else if(~Data_Dec_i[15]) begin Data_Bin_o = 6'b100011;
		end else if(~Data_Dec_i[14]) begin Data_Bin_o = 6'b100100;
		end else if(~Data_Dec_i[13]) begin Data_Bin_o = 6'b100101;
		end else if(~Data_Dec_i[12]) begin Data_Bin_o = 6'b100110;
		end else if(~Data_Dec_i[11]) begin Data_Bin_o = 6'b100111;
		end else if(~Data_Dec_i[10]) begin Data_Bin_o = 6'b101000;
		end else if(~Data_Dec_i[9]) begin Data_Bin_o = 6'b101001;
		end else if(~Data_Dec_i[8]) begin Data_Bin_o = 6'b101010;
		end else if(~Data_Dec_i[7]) begin Data_Bin_o = 6'b101011;
		end else if(~Data_Dec_i[6]) begin Data_Bin_o = 6'b101100;
		end else if(~Data_Dec_i[5]) begin Data_Bin_o = 6'b101101;
		end else if(~Data_Dec_i[4]) begin Data_Bin_o = 6'b101110;
		end else if(~Data_Dec_i[3]) begin Data_Bin_o = 6'b101111;
		end else if(~Data_Dec_i[2]) begin Data_Bin_o = 6'b110000;
		end else if(~Data_Dec_i[1]) begin Data_Bin_o = 6'b110001;
		end else if(~Data_Dec_i[0]) begin Data_Bin_o = 6'b110010;
		end else begin Data_Bin_o = 6'b000000;
		end		
	end
endmodule
