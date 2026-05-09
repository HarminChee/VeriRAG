`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_count_to_128(
		input	clk, 
		input	rst, 
		input	count, 
		input	ud, 
		output reg [6:0]	counter_value
	);
wire [6:0] counter_value_preserver;
always@(posedge clk or posedge rst)	begin
	if(rst == 1'b1)
		counter_value = 7'h00;
	else begin
	  case({count,ud})
			2'b00: counter_value = 7'h00;
			2'b01: counter_value = counter_value_preserver;
			2'b10: counter_value = counter_value_preserver - 1;
			2'b11: counter_value = counter_value_preserver + 1;
			default: counter_value = 7'h00;
	  endcase
	end
end
assign counter_value_preserver = counter_value;
endmodule	
