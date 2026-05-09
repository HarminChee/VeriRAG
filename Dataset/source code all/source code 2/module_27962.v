`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Registro_Juego(
	clk,
	reset_in, 
	c1_clear_in,
	c2_clear_in,
	c3_clear_in,
	c4_clear_in,
	c5_clear_in,
	c6_clear_in,
	c7_clear_in,
	c8_clear_in,
	c9_clear_in,
	c1_in,
	c2_in,
	c3_in,
	c4_in,
	c5_in,
	c6_in,
	c7_in,
	c8_in,
	c9_in,
	c1_out,
	c2_out,
	c3_out,
	c4_out,
	c5_out,
	c6_out,
	c7_out,
	c8_out,
	c9_out
	);
	input clk,reset_in;
	input c1_clear_in, c2_clear_in, c3_clear_in, c4_clear_in, c5_clear_in, c6_clear_in, c7_clear_in, c8_clear_in, c9_clear_in;
	input [1:0] c1_in, c2_in, c3_in, c4_in, c5_in, c6_in, c7_in, c8_in, c9_in;
	output [1:0] c1_out, c2_out, c3_out, c4_out, c5_out, c6_out, c7_out, c8_out, c9_out;
	reg clear_c1, clear_c2, clear_c3, clear_c4, clear_c5, clear_c6, clear_c7, clear_c8, clear_c9;
	Registro2Bits espacio_1 (
		.clk(clk),
		.datos_i (c1_in),
		.clear_i(c1_clear_in),
		.salida_o(c1_out)
	);
	Registro2Bits espacio_2 (
		.clk(clk),
		.datos_i (c2_in),
		.clear_i(c2_clear_in),
		.salida_o(c2_out)
	);
	Registro2Bits espacio_3 (
		.clk(clk),
		.datos_i (c3_in),
		.clear_i(c3_clear_in),
		.salida_o(c3_out)
	);
	Registro2Bits espacio_4 (
		.clk(clk),
		.datos_i (c4_in),
		.clear_i(c4_clear_in),
		.salida_o(c4_out)
	);
	Registro2Bits espacio_5 (
		.clk(clk),
		.datos_i (c5_in),
		.clear_i(c5_clear_in),
		.salida_o(c5_out)
	);
	Registro2Bits espacio_6 (
		.clk(clk),
		.datos_i (c6_in),
		.clear_i(c6_clear_in),
		.salida_o(c6_out)
	);
	Registro2Bits espacio_7 (
		.clk(clk),
		.datos_i (c7_in),
		.clear_i(c7_clear_in),
		.salida_o(c7_out)
	);
	Registro2Bits espacio_8 (
		.clk(clk),
		.datos_i (c8_in),
		.clear_i(c8_clear_in),
		.salida_o(c8_out)
	);
	Registro2Bits espacio_9 (
		.clk(clk),
		.datos_i (c9_in),
		.clear_i(c9_clear_in),
		.salida_o(c9_out)
	);
	always @( posedge clk or posedge reset_in) begin
		if(reset_in) 
			begin
			clear_c1 <= 1; 
			clear_c2 <= 1;
			clear_c3 <= 1;
			clear_c4 <= 1;
			clear_c5 <= 1;
			clear_c6 <= 1;
			clear_c7 <= 1;
			clear_c8 <= 1;
			clear_c9 <= 1;
			end 
		else 
			begin
			clear_c1 <= c1_clear_in; 
			clear_c2 <= c2_clear_in;
			clear_c3 <= c3_clear_in;
			clear_c4 <= c4_clear_in;
			clear_c5 <= c5_clear_in;
			clear_c6 <= c6_clear_in;
			clear_c7 <= c7_clear_in;
			clear_c8 <= c8_clear_in;
			clear_c9 <= c9_clear_in;
			end
	end
endmodule
