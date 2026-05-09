module uart6_atlys (
  input        uart_rx,
  output       uart_tx,
  output [7:0] led,
  input  [7:0] switch,
  input        reset_b,
  input        clk );
wire [11:0] address;
wire [17:0]	instruction;
wire        bram_enable;
reg  [7:0]  in_port;
wire [7:0]  out_port;
wire [7:0]  port_id;
wire        write_strobe;
wire        k_write_strobe;
wire        read_strobe;
reg         interrupt;   
wire        interrupt_ack;
wire        kcpsm6_sleep;  
wire        kcpsm6_reset;
wire        rdl;
wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
wire        uart_tx_data_present;
wire        uart_tx_half_full;
wire        uart_tx_full;
reg         uart_tx_reset;
wire [7:0]  uart_rx_data_out;
reg         read_from_uart_rx;
wire        uart_rx_data_present;
wire        uart_rx_half_full;
wire        uart_rx_full;
reg         uart_rx_reset;
reg [5:0]   baud_count;
reg         en_16_x_baud;
reg [7:0]   led_port;
reg [26:0]  int_count;
reg         event_1hz;
  kcpsm6 #(
	.interrupt_vector	(12'h3C0),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h41))            
  processor (
	.address 		(address),
	.instruction 	(instruction),
	.bram_enable 	(bram_enable),
	.port_id 		(port_id),
	.write_strobe 	(write_strobe),
	.k_write_strobe 	(k_write_strobe),
	.out_port 		(out_port),
	.read_strobe 	(read_strobe),
	.in_port 		(in_port),
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset),
	.sleep		(kcpsm6_sleep),
	.clk 			(clk)); 
  assign kcpsm6_reset = rdl | ~reset_b;
  assign kcpsm6_sleep = write_strobe & k_write_strobe;  
  atlys_real_time_clock #(
	.C_FAMILY		   ("S6"),  
	.C_RAM_SIZE_KWORDS	(1),  
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(clk));
  always @ (posedge clk )
  begin
    if (int_count == 27'b101111101011110000011111111) begin
      int_count <= 27'b000000000000000000000000000;
      event_1hz <= 1'b1;                 
    end
    else begin
      int_count <= int_count + 27'b000000000000000000000000001;
      event_1hz  <= 1'b0;
    end
    if (interrupt_ack == 1'b1) begin
      interrupt <= 1'b0;
    end
    else begin
      if (event_1hz == 1'b1) begin
        interrupt <= 1'b1;
      end
      else begin
        interrupt <= interrupt;
      end
    end
  end
  uart_tx6 tx(
      .data_in(uart_tx_data_in),
      .en_16_x_baud(en_16_x_baud),
      .serial_out(uart_tx),
      .buffer_write(write_to_uart_tx),
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(uart_tx_full),
      .buffer_reset(uart_tx_reset),              
      .clk(clk));
  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ),              
      .clk(clk ));
  always @ (posedge clk )
  begin
    if (baud_count == 6'b110101) begin      
      baud_count <= 6'b000000;
      en_16_x_baud <= 1'b1;                 
    end
    else begin
      baud_count <= baud_count + 6'b000001;
      en_16_x_baud <= 1'b0;
    end
  end
  always @ (posedge clk)
  begin
    case (port_id[1:0]) 
        2'b00 : in_port <= { 2'b00,
                            uart_rx_full,
                            uart_rx_half_full,
                            uart_rx_data_present,
                            uart_tx_full, 
                            uart_tx_half_full,
                            uart_tx_data_present };
        2'b01 : in_port <= uart_rx_data_out;
        2'b10 : in_port <= switch;
        default : in_port <= 8'bXXXXXXXX ;  
    endcase;
    if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
        read_from_uart_rx <= 1'b1;
      end
      else begin
        read_from_uart_rx <= 1'b0;
      end
  end
  always @ (posedge clk)
  begin
      if (write_strobe == 1'b1) begin
        if (port_id[1] == 1'b1) begin
          led_port <= out_port;
        end
      end
  end
  assign led = led_port;
  assign uart_tx_data_in = out_port;
  assign write_to_uart_tx = write_strobe & port_id[0];
  always @ (posedge clk)
  begin
    if (k_write_strobe == 1'b1) begin
      if (port_id[0] == 1'b1) begin
          uart_tx_reset <= out_port[0];
          uart_rx_reset <= out_port[1];
      end
    end
  end
endmodule
