`timescale 1ns / 1ps
module control_digitos_2
	(
	input  [7:0] estado,
	input  [3:0]RG1_Unit,
   input  [3:0]RG2_Unit,
   input  [3:0]RG3_Unit,
	input escribiendo,
	input en_out,
	input wire clk,
	input wire [3:0] dig1_Unit,
	input  [3:0] direccion,
	output reg [3:0] dig_Unit_Ho, dig_Unit_min, dig_Unit_seg, dig_Unit_mes, dig_Unit_dia, dig_Unit_an, dig_Unit_Ho_Ti, dig_Unit_min_Ti, dig_Unit_seg_Ti
	);
	always @(posedge clk)
	if (~escribiendo)
		if (en_out)
			case (direccion)
				4'b0000:
							dig_Unit_Ho<=dig1_Unit;		
				4'b0001:
							dig_Unit_min<=dig1_Unit;	
				4'b0010:
							dig_Unit_seg<=dig1_Unit;		
				4'b0011:
							dig_Unit_mes<=dig1_Unit;		
				4'b0100:
							dig_Unit_dia<=dig1_Unit;	
				4'b0101:
							dig_Unit_an<=dig1_Unit;	
				4'b0110:
							dig_Unit_Ho_Ti<=dig1_Unit;	
				4'b0111:
						   dig_Unit_min_Ti<=dig1_Unit;					
				4'b1000: 
						   dig_Unit_seg_Ti<=dig1_Unit;
				default:
							begin
								dig_Unit_Ho<=dig_Unit_Ho;	
								dig_Unit_min<=dig_Unit_min;
								dig_Unit_seg<=dig_Unit_seg;
								dig_Unit_mes<=dig_Unit_mes;
								dig_Unit_an<=dig_Unit_an;
								dig_Unit_dia<=dig_Unit_dia;
								dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
								dig_Unit_min_Ti<=dig_Unit_min_Ti;
								dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
							end
			endcase
		else
			begin
				dig_Unit_Ho<=dig_Unit_Ho;
				dig_Unit_min<=dig_Unit_min;
				dig_Unit_seg<=dig_Unit_seg;
				dig_Unit_mes<=dig_Unit_mes;
				dig_Unit_dia<=dig_Unit_dia;
				dig_Unit_an<=dig_Unit_an;
				dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
				dig_Unit_min_Ti<=dig_Unit_min_Ti;
				dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
			end
	else 
		case (estado)
			8'h7d:
					begin
						if (direccion==4'b0011)
							dig_Unit_mes<=RG2_Unit;
						else
						if (direccion==4'b0100)
							dig_Unit_dia<=RG1_Unit;
						else
						if (direccion==4'b0101)
							dig_Unit_an<=RG3_Unit;
						else
							begin
							dig_Unit_mes<=dig_Unit_mes;
							dig_Unit_dia<=dig_Unit_dia;
							dig_Unit_an<=dig_Unit_an;
							end
					end
			8'h6c:
					begin
						if (direccion==4'b0000)
							dig_Unit_Ho<=RG3_Unit;
						else
						if (direccion==4'b0001)
							dig_Unit_min<=RG2_Unit;
						else
						if (direccion==4'b0010)
							dig_Unit_seg<=RG1_Unit;
						else
							begin
							dig_Unit_Ho<=dig_Unit_Ho;
							dig_Unit_min<=dig_Unit_min;
							dig_Unit_seg<=dig_Unit_seg;
							end
					end
			8'h75:
					begin
						if (direccion==4'b0110)
							dig_Unit_Ho_Ti<=RG3_Unit;
						else
						if (direccion==4'b0111)
							dig_Unit_min_Ti<=RG2_Unit;
						else
						if (direccion==4'b1000)
							dig_Unit_seg_Ti<=RG1_Unit;
						else
							begin
							dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
							dig_Unit_min_Ti<=dig_Unit_min_Ti;
							dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
							end
					end
			default:
						begin
							dig_Unit_Ho<=dig_Unit_Ho;
							dig_Unit_min<=dig_Unit_min;
							dig_Unit_seg<=dig_Unit_seg;
							dig_Unit_mes<=dig_Unit_mes;
							dig_Unit_dia<=dig_Unit_dia;
							dig_Unit_an<=dig_Unit_an;
							dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
							dig_Unit_min_Ti<=dig_Unit_min_Ti;
							dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
						end
		endcase
	endmodule
`timescale 1ns / 1ps
module control_digitos_2
	(
	input  [7:0] estado,
	input  [3:0]RG1_Unit,
   input  [3:0]RG2_Unit,
   input  [3:0]RG3_Unit,
	input escribiendo,
	input en_out,
	input wire clk,
	input wire [3:0] dig1_Unit,
	input  [3:0] direccion,
	output reg [3:0] dig_Unit_Ho, dig_Unit_min, dig_Unit_seg, dig_Unit_mes, dig_Unit_dia, dig_Unit_an, dig_Unit_Ho_Ti, dig_Unit_min_Ti, dig_Unit_seg_Ti
	);
	always @(posedge clk)
	if (~escribiendo)
		if (en_out)
			case (direccion)
				4'b0000:
							dig_Unit_Ho<=dig1_Unit;		
				4'b0001:
							dig_Unit_min<=dig1_Unit;	
				4'b0010:
							dig_Unit_seg<=dig1_Unit;		
				4'b0011:
							dig_Unit_mes<=dig1_Unit;		
				4'b0100:
							dig_Unit_dia<=dig1_Unit;	
				4'b0101:
							dig_Unit_an<=dig1_Unit;	
				4'b0110:
							dig_Unit_Ho_Ti<=dig1_Unit;	
				4'b0111:
						   dig_Unit_min_Ti<=dig1_Unit;					
				4'b1000: 
						   dig_Unit_seg_Ti<=dig1_Unit;
				default:
							begin
								dig_Unit_Ho<=dig_Unit_Ho;	
								dig_Unit_min<=dig_Unit_min;
								dig_Unit_seg<=dig_Unit_seg;
								dig_Unit_mes<=dig_Unit_mes;
								dig_Unit_an<=dig_Unit_an;
								dig_Unit_dia<=dig_Unit_dia;
								dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
								dig_Unit_min_Ti<=dig_Unit_min_Ti;
								dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
							end
			endcase
		else
			begin
				dig_Unit_Ho<=dig_Unit_Ho;
				dig_Unit_min<=dig_Unit_min;
				dig_Unit_seg<=dig_Unit_seg;
				dig_Unit_mes<=dig_Unit_mes;
				dig_Unit_dia<=dig_Unit_dia;
				dig_Unit_an<=dig_Unit_an;
				dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
				dig_Unit_min_Ti<=dig_Unit_min_Ti;
				dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
			end
	else 
		case (estado)
			8'h7d:
					begin
						if (direccion==4'b0011)
							dig_Unit_mes<=RG2_Unit;
						else
						if (direccion==4'b0100)
							dig_Unit_dia<=RG1_Unit;
						else
						if (direccion==4'b0101)
							dig_Unit_an<=RG3_Unit;
						else
							begin
							dig_Unit_mes<=dig_Unit_mes;
							dig_Unit_dia<=dig_Unit_dia;
							dig_Unit_an<=dig_Unit_an;
							end
					end
			8'h6c:
					begin
						if (direccion==4'b0000)
							dig_Unit_Ho<=RG3_Unit;
						else
						if (direccion==4'b0001)
							dig_Unit_min<=RG2_Unit;
						else
						if (direccion==4'b0010)
							dig_Unit_seg<=RG1_Unit;
						else
							begin
							dig_Unit_Ho<=dig_Unit_Ho;
							dig_Unit_min<=dig_Unit_min;
							dig_Unit_seg<=dig_Unit_seg;
							end
					end
			8'h75:
					begin
						if (direccion==4'b0110)
							dig_Unit_Ho_Ti<=RG3_Unit;
						else
						if (direccion==4'b0111)
							dig_Unit_min_Ti<=RG2_Unit;
						else
						if (direccion==4'b1000)
							dig_Unit_seg_Ti<=RG1_Unit;
						else
							begin
							dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
							dig_Unit_min_Ti<=dig_Unit_min_Ti;
							dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
							end
					end
			default:
						begin
							dig_Unit_Ho<=dig_Unit_Ho;
							dig_Unit_min<=dig_Unit_min;
							dig_Unit_seg<=dig_Unit_seg;
							dig_Unit_mes<=dig_Unit_mes;
							dig_Unit_dia<=dig_Unit_dia;
							dig_Unit_an<=dig_Unit_an;
							dig_Unit_Ho_Ti<=dig_Unit_Ho_Ti;
							dig_Unit_min_Ti<=dig_Unit_min_Ti;
							dig_Unit_seg_Ti<=dig_Unit_seg_Ti;
						end
		endcase
	endmodule
