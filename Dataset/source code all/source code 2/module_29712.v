`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Registrodesplazamiento  #(parameter Width = 10)
(CLK,reset,Enable,Indato,Y0,Y1,Y2,Y3,Y4,Y5,Y6,Y7,Y8,Y9);
	 input CLK,reset,Enable;
	 input signed [Width-1:0] Indato;
	 output signed  [Width-1:0] Y0,Y1,Y2,Y3,Y4,Y5,Y6,Y7,Y8,Y9;
	 reg [(Width*10)-1:0] Aux = 0;
   always @(posedge CLK) begin
      if (reset) begin
         Aux <= 0;
      end else if (Enable) begin
			Aux  <= {Indato, Aux[(Width*10)-1:Width]};
		end
	end
   assign Y0 = Aux[(Width)-1:0];
	assign Y1 = Aux[(Width*2)-1:Width];
	assign Y2 = Aux[(Width*3)-1:Width*2];
	assign Y3 = Aux[(Width*4)-1:Width*3];
	assign Y4 = Aux[(Width*5)-1:Width*4];
	assign Y5 = Aux[(Width*6)-1:Width*5];
	assign Y6 = Aux[(Width*7)-1:Width*6];
	assign Y7 = Aux[(Width*8)-1:Width*7];
	assign Y8 = Aux[(Width*9)-1:Width*8];
	assign Y9 = Aux[(Width*10)-1:Width*9];
endmodule
