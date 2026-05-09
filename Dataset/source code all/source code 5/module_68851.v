module serial_transmit # (
   parameter baud_rate = 115_200,
   parameter comm_clk_frequency = 100_000_000 )
  (clk, TxD, busy, send, word);
   wire TxD_start;
   wire TxD_ready;
   reg [7:0]  out_byte = 0;
   reg        serial_start = 0;
   reg [3:0]  mux_state = 4'b0000;
   assign TxD_start = serial_start;
   input      clk;
   output     TxD;
   input [31:0] word;
   input 	send;
   output 	busy;
   reg [31:0] 	word_copy = 0;
   assign busy = (|mux_state);
   always @(posedge clk)
     begin
	if (!busy && send)
	  begin
	     mux_state <= 4'b1000;
	     word_copy <= word;
	  end  
	else if (mux_state[3] && ~mux_state[0] && TxD_ready)
	  begin
	     serial_start <= 1;
	     mux_state <= mux_state + 1;
	     out_byte <= word_copy[31:24];
	     word_copy <= (word_copy << 8);
	  end
	else if (mux_state[3] && mux_state[0])
	  begin
	     serial_start <= 0;
	     if (TxD_ready) mux_state <= mux_state + 1;
	  end
     end
   uart_transmitter #(.comm_clk_frequency(comm_clk_frequency), .baud_rate(baud_rate)) utx (.clk(clk), .uart_tx(TxD), .rx_new_byte(TxD_start), .rx_byte(out_byte), .tx_ready(TxD_ready));
endmodule 
module serial_receive # (
   parameter baud_rate = 115_200,
   parameter comm_clk_frequency = 100_000_000 )
  ( clk, RxD, data1, data2, data3, target, rx_done );
   input      clk;
   input      RxD;
   wire       RxD_data_ready;
   wire [7:0] RxD_data;
   `ifdef CONFIG_SERIAL_TIMEOUT
	parameter SERIAL_TIMEOUT = `CONFIG_SERIAL_TIMEOUT;
   `else
	parameter SERIAL_TIMEOUT = 24'h800000;
   `endif
   uart_receiver #(.comm_clk_frequency(comm_clk_frequency), .baud_rate(baud_rate)) urx (.clk(clk), .uart_rx(RxD), .tx_new_byte(RxD_data_ready), .tx_byte(RxD_data));
   output [255:0] data1;
   output [255:0] data2;
   output [127:0] data3;
   output [31:0] target;
   output reg rx_done = 1'b0;
   reg [671:0] input_buffer = 0;
   reg [671:0] input_copy = 0;
   reg [6:0]   demux_state = 7'b0000000;
   reg [23:0]  timer = 0;
`ifdef SIM	
   assign target = input_copy[671:640];		
   assign data1 = 256'h18e7b1e8eaf0b62a90d1942ea64d250357e9a09c063a47827c57b44e01000000;
   assign data2 = 256'hc791d4646240fc2a2d1b80900020a24dc501ef1599fc48ed6cbac920af755756;
   assign data3 = 128'h0000318f7e71441b141fe951b2b0c7df;	
`else   
   assign target = input_copy[671:640];
   assign data3 = input_copy[639:512];
   assign data2 = input_copy[511:256];
   assign data1 = input_copy[255:0];
`endif
   always @(posedge clk)
     case (demux_state)
       7'd84:				
	 begin
		rx_done <= 1;
	    input_copy <= input_buffer;
	    demux_state <= 0;
	 end
       default:
     begin
        rx_done <= 0;
	    if(RxD_data_ready)
	      begin
	         input_buffer <= input_buffer << 8;
             input_buffer[7:0] <= RxD_data;
             demux_state <= demux_state + 1;
	         timer <= 0;
	      end
	      else
	      begin
	         timer <= timer + 1;
	         if (timer == SERIAL_TIMEOUT)
	           demux_state <= 0;
	      end
     end 
     endcase 
endmodule 
module serial_transmit # (
   parameter baud_rate = 115_200,
   parameter comm_clk_frequency = 100_000_000 )
  (clk, TxD, busy, send, word);
   wire TxD_start;
   wire TxD_ready;
   reg [7:0]  out_byte = 0;
   reg        serial_start = 0;
   reg [3:0]  mux_state = 4'b0000;
   assign TxD_start = serial_start;
   input      clk;
   output     TxD;
   input [31:0] word;
   input 	send;
   output 	busy;
   reg [31:0] 	word_copy = 0;
   assign busy = (|mux_state);
   always @(posedge clk)
     begin
	if (!busy && send)
	  begin
	     mux_state <= 4'b1000;
	     word_copy <= word;
	  end  
	else if (mux_state[3] && ~mux_state[0] && TxD_ready)
	  begin
	     serial_start <= 1;
	     mux_state <= mux_state + 1;
	     out_byte <= word_copy[31:24];
	     word_copy <= (word_copy << 8);
	  end
	else if (mux_state[3] && mux_state[0])
	  begin
	     serial_start <= 0;
	     if (TxD_ready) mux_state <= mux_state + 1;
	  end
     end
   uart_transmitter #(.comm_clk_frequency(comm_clk_frequency), .baud_rate(baud_rate)) utx (.clk(clk), .uart_tx(TxD), .rx_new_byte(TxD_start), .rx_byte(out_byte), .tx_ready(TxD_ready));
endmodule 
