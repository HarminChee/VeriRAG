`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PicoBlaze_OutReg
	#(parameter LOCAL_PORT_ID = 8'h00)
	(
	clk,
	reset,
	port_id,
	write_strobe,
	out_port,
	new_out_port);
input  wire        clk;
input  wire        reset;
input  wire    	 [7:0] port_id;
input  wire        write_strobe;
input  wire        [7:0] out_port;
output reg  		 [7:0] new_out_port;
reg RegEnable=1;
	always @ (*)
	begin
		if (write_strobe == 1)
			begin
				case (port_id)
					LOCAL_PORT_ID: RegEnable = 1;
					default: RegEnable = 0;
				endcase
			end
		else
			RegEnable=0;
	end
	always @ (posedge clk, posedge reset)
	begin
		if(reset == 1)
			new_out_port <= 8'h00;
		else
			begin
				if(RegEnable == 1)
					new_out_port <= out_port;
				else
					new_out_port <= new_out_port;
			end
	end
endmodule
