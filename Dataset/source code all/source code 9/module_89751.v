module ghrd_10m50da_top (
  input  wire       clk_50,
  input  wire       fpga_reset_n,
  input wire	     uart_rx,
  output wire 		  uart_tx,
  output wire [4:0] user_led
);
reg   [25:0]  heart_beat_cnt;
ghrd_10m50da ghrd_10m50da_inst (
		.clk_clk                                                  (clk_50), 
		.reset_reset_n                                            (fpga_reset_n),
		.a_16550_uart_0_rs_232_serial_sin (uart_rx),                    
		.a_16550_uart_0_rs_232_serial_sout (uart_tx),                   
		.a_16550_uart_0_rs_232_serial_sout_oe ()                
);  
always @(posedge clk_50 or negedge fpga_reset_n)
  if (!fpga_reset_n)
      heart_beat_cnt <= 26'h0; 
  else
      heart_beat_cnt <= heart_beat_cnt + 1'b1;
assign user_led = {4'hf,heart_beat_cnt[25]};
endmodule
