`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Lab1_Frustration_Module
  (
	 output reg [9:0] LEDR,
	 output [6:0]     HEX0, 
	 output [6:0]     HEX1, 
	 output [6:0]     HEX2, 
	 output [6:0]     HEX3, 
	 output [6:0]     HEX4, 
	 output [6:0]     HEX5, 
	 input [3:0]      KEY,
	 input            CLOCK_50
   );
	 reg [3:0]        key_value;
	 wire [3:0]       key0_value;
	 wire [3:0]       key1_value;
	 wire [3:0]       key2_value;
	 wire [3:0]       key3_value;
	 assign key0_value = KEY[0] ? 4'h1 : 4'h0; 
	 assign key1_value = KEY[1] ? 4'h2 : 4'h0; 
	 assign key2_value = KEY[2] ? 4'h3 : 4'h0; 
	 assign key3_value = KEY[3] ? 4'h4 : 4'h0; 
	 always @(posedge CLOCK_50)
	   begin
		    key_value = key3_value + key2_value + key1_value + key0_value;
	   end
	 always @(posedge CLOCK_50)
	   begin
		    case (key_value)
			    4'h0 : LEDR <= 10'b0000000000;
			    4'h1 : LEDR <= 10'b0000000001;
			    4'h2 : LEDR <= 10'b0000000011;
			    4'h3 : LEDR <= 10'b0000000111;
			    4'h4 : LEDR <= 10'b0000001111;
			    4'h5 : LEDR <= 10'b0000011111;
			    4'h6 : LEDR <= 10'b0000111111;
			    4'h7 : LEDR <= 10'b0001111111;
			    4'h8 : LEDR <= 10'b0011111111;
			    4'h9 : LEDR <= 10'b0111111111;
			    4'hA : LEDR <= 10'b1111111111;
			    default : LEDR <= 10'b0000000000;
		    endcase
	   end
	 reg [6:0] hex0_reg;
	 reg [6:0] hex1_reg;
	 reg [6:0] hex2_reg;
	 reg [6:0] hex3_reg;
	 reg [6:0] hex4_reg;
	 reg [6:0] hex5_reg;
	 assign HEX0 = ~hex0_reg;
	 assign HEX1 = ~hex1_reg;
	 assign HEX2 = ~hex2_reg;
	 assign HEX3 = ~hex3_reg;
	 assign HEX4 = ~hex4_reg;
	 assign HEX5 = ~hex5_reg;
	 always @(posedge CLOCK_50)
	   begin
		    case (key_value)
			    4'h0 : hex0_reg <= 7'h3F; 
			    4'h1 : hex0_reg <= 7'h06; 
			    4'h2 : hex0_reg <= 7'h5B; 
			    4'h3 : hex0_reg <= 7'h4F; 
			    4'h4 : hex0_reg <= 7'h66; 
			    4'h5 : hex0_reg <= 7'h6D; 
			    4'h6 : hex0_reg <= 7'h7D; 
			    4'h7 : hex0_reg <= 7'h27; 
			    4'h8 : hex0_reg <= 7'h7F; 
			    4'h9 : hex0_reg <= 7'h6F; 
			    4'hA : hex0_reg <= 7'h3F; 
			    default : hex0_reg <= 7'h00; 
		    endcase
	   end
	 always @(posedge CLOCK_50)
	   begin
		    case (key_value)
			    4'hA : hex1_reg <= 7'h06; 
			    default : hex1_reg <= 7'h00; 
		    endcase
	   end
	 always @(posedge CLOCK_50)
	   begin
		    case (key_value)
			    4'hA : hex2_reg <= 7'h79; 
			    default : hex2_reg <= 7'h00; 
		    endcase
	   end
	 always @(posedge CLOCK_50)
	   begin
		    case (key_value)
			    4'h9,
			    4'hA : hex3_reg <= 7'h6D; 
			    default : hex3_reg <= 7'h00; 
		    endcase
	   end
	 always @(posedge CLOCK_50)
	   begin
		    case (key_value)
			    4'h7,
			    4'h8,
			    4'h9,
			    4'hA : hex4_reg <= 7'h77; 
			    default : hex4_reg <= 7'h00; 
		    endcase
	   end
	 always @(posedge CLOCK_50)
	   begin
		    case (key_value)
			    4'h4,
			    4'h5,
			    4'h6,
			    4'h7,
			    4'h8,
			    4'h9,
			    4'hA : hex5_reg <= 7'h39; 
			    default : hex5_reg <= 7'h00; 
		    endcase
	   end
endmodule
