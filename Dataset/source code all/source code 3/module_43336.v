`timescale 1ns / 1ps
module sr_timer_variable #(WIDTH = 8)
(
    input S,
    input R,
	 input CLK,
	 input [WIDTH-1:0] TIME,
    output reg OUT = 0
);
reg [WIDTH-1:0] COUNTER = 0;
reg running = 0;
always @(posedge CLK) begin
	if(R) begin
		OUT <= 0;
		COUNTER <= 0;
		running <= 0;
	end else if(S & !running) begin
		OUT <= 1;
		running <= 1;
	end else if(running) begin
		COUNTER <= COUNTER + 1;
		if(COUNTER+1 == TIME) begin
			running <= 0;
			OUT <= 0;
			COUNTER <= 0;
		end
	end
end
endmodule
`timescale 1ns / 1ps
module sr_timer #(TIME = 8)
(
    input S,
    input R,
	 input CLK,
    output reg OUT = 0
);
reg [$clog2(TIME)-1:0] COUNTER = 0;
reg running = 0;
always @(posedge CLK) begin
	if(R) begin
		OUT <= 0;
		COUNTER <= 0;
		running <= 0;
	end else if(S & !running) begin
		OUT <= 1;
		running <= 1;
	end else if(running) begin
		COUNTER <= COUNTER + 1;
		if(COUNTER+1 == TIME) begin
			running <= 0;
			OUT <= 0;
			COUNTER <= 0;
		end
	end
end
endmodule
module sr_timer_variable #(WIDTH = 8)
(
    input S,
    input R,
	 input CLK,
	 input [WIDTH-1:0] TIME,
    output reg OUT = 0
);
reg [WIDTH-1:0] COUNTER = 0;
reg running = 0;
always @(posedge CLK) begin
	if(R) begin
		OUT <= 0;
		COUNTER <= 0;
		running <= 0;
	end else if(S & !running) begin
		OUT <= 1;
		running <= 1;
	end else if(running) begin
		COUNTER <= COUNTER + 1;
		if(COUNTER+1 == TIME) begin
			running <= 0;
			OUT <= 0;
			COUNTER <= 0;
		end
	end
end
endmodule
