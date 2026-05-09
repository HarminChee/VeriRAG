module eight_bit_counter(count_out,enable,clock,clear);
    input enable,clock,clear;
	 output [7:0] count_out;
	 wire [6:0] temp;
	 wire counter_clock;
	 frequency_divider clk_1hz(counter_clock,clock);
	 t_ff tff0(count_out[0],enable,counter_clock,clear);
	 assign temp[0] = count_out[0] & enable;
	 t_ff tff1(count_out[1],temp[0],counter_clock,clear);
	 assign temp[1] = temp[0] & count_out[1];
	 t_ff tff2(count_out[2],temp[1],counter_clock,clear);
	 assign temp[2] = temp[1] & count_out[2];
	 t_ff tff3(count_out[3],temp[2],counter_clock,clear);
	 assign temp[3] = temp[2] & count_out[3];
	 t_ff tff4(count_out[4],temp[3],counter_clock,clear);
	 assign temp[4] = temp[3] & count_out[4];
	 t_ff tff5(count_out[5],temp[4],counter_clock,clear);
	 assign temp[5] = temp[4] & count_out[5];
	 t_ff tff6(count_out[6],temp[5],counter_clock,clear);
	 assign temp[6] = temp[5] & count_out[6];
	 t_ff tff7(count_out[7],temp[6],counter_clock,clear);
endmodule
module t_ff(q_out,t_in,clock,clear);
    input t_in,clock,clear;
	 output reg q_out;
	 always @(posedge clock or negedge clear)
	     begin
		      if(~clear)
				   q_out <= 1'b0;
				else
				    q_out <= t_in ^ q_out;  
		  end
endmodule
