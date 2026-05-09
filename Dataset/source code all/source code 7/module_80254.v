module radar_tx(clk_i,rst_i,ena_i,strobe_i,
		ampl_i,fstart_i,fincr_i,
		tx_i_o,tx_q_o);
   input clk_i;
   input rst_i;
   input ena_i;
   input strobe_i;
   input [15:0]  ampl_i;
   input [31:0]  fstart_i;
   input [31:0]  fincr_i;
   output [13:0] tx_i_o;
   output [13:0] tx_q_o;
   wire   [15:0] cordic_i, cordic_q;
   reg [31:0] freq;
   always @(posedge clk_i)
     if (rst_i | ~ena_i)
       freq <= fstart_i;
     else
       if (strobe_i)
	 freq <= freq + fincr_i;
   cordic_nco nco(.clk_i(clk_i),.rst_i(rst_i),.ena_i(ena_i),.strobe_i(strobe_i),
		  .ampl_i(ampl_i),.freq_i(freq),.phs_i(0),
		  .data_i_o(cordic_i),.data_q_o(cordic_q));
   assign tx_i_o = cordic_i[13:0];
   assign tx_q_o = cordic_q[13:0];
endmodule 
