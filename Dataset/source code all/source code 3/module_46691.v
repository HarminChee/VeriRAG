`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module pace_catcher
          (
           clk_fast,
			  clk_slow,
			  signal_i,
			  signal_o
          );
input clk_fast;
input clk_slow;
input signal_i;
output signal_o;
parameter COUNT = 15; 
parameter s_idle = 0;
parameter s_out = 1;
reg[15:0] cnt = 0;
reg state = 0;
always @(posedge clk_fast) begin
		case(state)
			s_idle:
			begin
				state <= (signal_i) ? s_out : s_idle;
			end
			s_out:
			begin
				state <= (cnt >= COUNT) ? s_idle : s_out;
			end
		endcase
end
always @(posedge clk_slow) begin
		if (state == s_out) cnt <= cnt + 8'b1;
		else if (state == s_idle) cnt  <= 8'b0;
end
assign signal_o = (state == s_out);
endmodule
