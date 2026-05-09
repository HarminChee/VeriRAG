module ad9777_spi(
output reg sdio,
output reg csb,
input rst,
input clk,
output reg spi_ok
);
wire [6:0] lut_index=7'd5;
function [15:0] lut_data;
	input [5:0] addr;
	begin
		case(addr)
			6'd0 :lut_data=16'b0_00_00000_0000_0100;
			6'd1 :lut_data=16'b0_00_00001_0000_0000;
			6'd2 :lut_data=16'b0_00_00101_0000_0001;
			6'd3 :lut_data=16'b0_00_00110_0000_1111;
			6'd4 :lut_data=16'b0_00_01001_0000_0000;
			6'd5 :lut_data=16'b0_00_01010_0000_1111;
		endcase
	end
endfunction
reg [5:0] addr;
reg [4:0] state;
reg [15:0] dout_reg;
reg [4:0] shift_reg;
always @ (negedge clk or negedge rst)
if(!rst)
	begin
		csb<=1'b1;
		sdio<=1'b1;
		state<=5'd0;
		addr<=6'd0;
		dout_reg<=16'd0;
		shift_reg<=5'd0;
		spi_ok<=1'b0;
	end
else
	begin
		case(state)
			5'd0:
				begin
					csb<=1'b1;
					dout_reg<=lut_data(addr);
					state<=5'd1;
				end
			5'd1:
				begin
					if(shift_reg<=5'd15)
						begin
							csb<=1'b0;
							sdio<=dout_reg[15];
							dout_reg<=dout_reg<<1;
							shift_reg<=shift_reg+1'b1;
							state<=5'd1;
						end
					else
						begin
							shift_reg<=5'd0;
							csb<=1'b1;
							sdio<=1'b1;
							if(addr<lut_index)
								begin
									addr<=addr+1'b1;
									state<=5'd0;
								end
							else
								begin
									addr<=6'd0;
									state<=5'd2;
								end
						end
				end
			5'd2:
				begin
					spi_ok<=1'b1;
					state<=5'd3;
				end
		endcase
	end
endmodule
