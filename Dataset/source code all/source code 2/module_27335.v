`timescale 1ns / 1ps
`timescale 1ns / 1ps
module control_digitos_1
	(
	input  [7:0] estado,
	input  [3:0]RG1_Dec,
   input  [3:0]RG2_Dec,
   input  [3:0]RG3_Dec,
	input escribiendo,
	input en_out,
	input wire clk,
	input wire [3:0] dig0_Dec,
	input [3:0] direccion,
	output reg [3:0] dig_Dec_Ho, dig_Dec_min, dig_Dec_seg, dig_Dec_mes, dig_Dec_dia, dig_Dec_an, dig_Dec_Ho_Ti, dig_Dec_min_Ti, dig_Dec_seg_Ti
	);
	always @(posedge clk)
	if (~escribiendo)
		if (en_out)
			case (direccion)
				4'b0000:
							dig_Dec_Ho<=dig0_Dec;		
				4'b0001:
							dig_Dec_min<=dig0_Dec;	
				4'b0010:
							dig_Dec_seg<=dig0_Dec;		
				4'b0011:
							dig_Dec_mes<=dig0_Dec;		
				4'b0100:
							dig_Dec_dia<=dig0_Dec;		
				4'b0101:
							dig_Dec_an<=dig0_Dec;	
				4'b0110:
							begin
								if (dig0_Dec==4'b1111)
									dig_Dec_Ho_Ti<=4'b0000;
								else
									dig_Dec_Ho_Ti<=dig0_Dec;
							end				
				4'b0111:
						   dig_Dec_min_Ti<=dig0_Dec;					
				4'b1000: 
						   dig_Dec_seg_Ti<=dig0_Dec;
				default:
							begin
								dig_Dec_Ho<=dig_Dec_Ho;	
								dig_Dec_min<=dig_Dec_min;
								dig_Dec_seg<=dig_Dec_seg;
								dig_Dec_mes<=dig_Dec_mes;
								dig_Dec_an<=dig_Dec_an;
								dig_Dec_dia<=dig_Dec_dia;
								dig_Dec_Ho_Ti<=dig_Dec_Ho_Ti;
								dig_Dec_min_Ti<=dig_Dec_min_Ti;
								dig_Dec_seg_Ti<=dig_Dec_seg_Ti;
							end
			endcase
		else
			begin
				dig_Dec_Ho<=dig_Dec_Ho;
				dig_Dec_min<=dig_Dec_min;
				dig_Dec_seg<=dig_Dec_seg;
				dig_Dec_mes<=dig_Dec_mes;
				dig_Dec_dia<=dig_Dec_dia;
				dig_Dec_an<=dig_Dec_an;
				dig_Dec_Ho_Ti<=dig_Dec_Ho_Ti;
				dig_Dec_min_Ti<=dig_Dec_min_Ti;
				dig_Dec_seg_Ti<=dig_Dec_seg_Ti;
			end
	else 
		case (estado)
			8'h7d:
					begin
						if (direccion==4'b0011)
							dig_Dec_mes<=RG2_Dec;
						else
						if (direccion==4'b0100)
							dig_Dec_dia<=RG1_Dec;
						else
						if (direccion==4'b0101)
							dig_Dec_an<=RG3_Dec;
						else
							begin
							dig_Dec_mes<=dig_Dec_mes;
							dig_Dec_dia<=dig_Dec_dia;
							dig_Dec_an<=dig_Dec_an;
							end
					end
			8'h6c:
					begin
						if (direccion==4'b0000)
							dig_Dec_Ho<=RG3_Dec;
						else
						if (direccion==4'b0001)
							dig_Dec_min<=RG2_Dec;
						else
						if (direccion==4'b0010)
							dig_Dec_seg<=RG1_Dec;
						else
							begin
							dig_Dec_Ho<=dig_Dec_Ho;
							dig_Dec_min<=dig_Dec_min;
							dig_Dec_seg<=dig_Dec_seg;
							end
					end
			8'h75:
					begin
						if (direccion==4'b0110)
							dig_Dec_Ho_Ti<=RG3_Dec;
						else
						if (direccion==4'b0111)
							dig_Dec_min_Ti<=RG2_Dec;
						else
						if (direccion==4'b1000)
							dig_Dec_seg_Ti<=RG1_Dec;
						else
							begin
							dig_Dec_Ho_Ti<=dig_Dec_Ho_Ti;
							dig_Dec_min_Ti<=dig_Dec_min_Ti;
							dig_Dec_seg_Ti<=dig_Dec_seg_Ti;
							end
					end
			default:
						begin
							dig_Dec_Ho<=dig_Dec_Ho;
							dig_Dec_min<=dig_Dec_min;
							dig_Dec_seg<=dig_Dec_seg;
							dig_Dec_mes<=dig_Dec_mes;
							dig_Dec_dia<=dig_Dec_dia;
							dig_Dec_an<=dig_Dec_an;
							dig_Dec_Ho_Ti<=dig_Dec_Ho_Ti;
							dig_Dec_min_Ti<=dig_Dec_min_Ti;
							dig_Dec_seg_Ti<=dig_Dec_seg_Ti;
						end
		endcase
endmodule
