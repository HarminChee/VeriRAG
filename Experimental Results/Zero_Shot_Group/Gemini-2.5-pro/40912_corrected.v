module uart6_kc705 (  input   uart_rx,
                     output   uart_tx,
                      input   clk200_p,
                      input   clk200_n);
wire        clk200;
wire        clk;
wire [7:0]  clock_frequency_in_MHz;
wire [11:0] address;
wire [17:0] instruction;
wire        bram_enable;
reg  [7:0]  in_port;
wire [7:0]  out_port;
wire [7:0]  port_id;
wire        write_strobe;
wire        k_write_strobe;
wire        read_strobe;
wire        interrupt;
wire        interrupt_ack;
wire        kcpsm6_sleep;
wire        kcpsm6_reset;
wire        rdl;
wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
reg         pipe_port_id0; // Registered version of port_id[0]
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
reg [7:0]   set_baud_rate;
reg [7:0]   baud_rate_counter;
reg         en_16_x_baud;

  assign clock_frequency_in_MHz = 8'd200;

  IBUFGDS diff_clk_buffer(
      .I(clk200_p),
      .IB(clk200_n),
      .O(clk200));

  BUFG clock_divide (
      .I(clk200),
      .O(clk));

  kcpsm6 #(
	.interrupt_vector	(12'h7FF),
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
	.interrupt 		(interrupt), // Input to processor
	.interrupt_ack 	(interrupt_ack), // Output from processor
	.reset 		(kcpsm6_reset),
	.sleep		(kcpsm6_sleep),
	.clk 			(clk));

  assign kcpsm6_reset = rdl; // Assuming rdl is the main reset
  assign kcpsm6_sleep = 1'b0; // Sleep typically controlled differently, tie low for now
  assign interrupt = uart_rx_data_present; // Interrupt when RX data is available

  // Assuming this is the program ROM based on ports
  // The module name 'auto_baud_rate_control' might be misleading
  program_rom #(
	.C_FAMILY		   ("kintex7"), // Example: Use appropriate family
	.C_RAM_SIZE_KWORDS	(2),
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom_inst ( // Renamed instance for clarity
 	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address[10:0]), // Address width depends on C_RAM_SIZE_KWORDS (2K = 11 bits)
	.instruction 	(instruction),
	.clk 			(clk));

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

  // Baud Rate Generation
  always @ (posedge clk )
  begin
    if (baud_rate_counter == set_baud_rate) begin
      baud_rate_counter <= 8'd0; // Use 8-bit value
      en_16_x_baud <= 1'b1;
    end
    else begin
      baud_rate_counter <= baud_rate_counter + 1'b1; // Use 1-bit increment
      en_16_x_baud <= 1'b0;
    end
  end

  // Processor Input Port Logic
  always @ (posedge clk)
  begin
    // Default read action
    read_from_uart_rx <= 1'b0;

    // Input Mux based on port_id
    case (port_id[1:0]) // Only decode lower 2 bits based on usage
        2'b00 : in_port <= { 2'b00,
                             uart_rx_full,
                             uart_rx_half_full,
                             uart_rx_data_present,
                             uart_tx_full,
                             uart_tx_half_full,
                             uart_tx_data_present };
        2'b01 : begin
                  in_port <= uart_rx_data_out;
                  // Read strobe handling for Port 01 (UART RX Data)
                  if (read_strobe == 1'b1) begin
                    read_from_uart_rx <= 1'b1;
                  end
                end
        2'b10 : in_port <= clock_frequency_in_MHz; // Assuming Port 10 reads frequency
        default : in_port <= 8'bXXXXXXXX ;
    endcase
  end

  // Processor Output Port Logic & Pipelining
  always @ (posedge clk)
  begin
      // Register port_id[0] for pipelined TX write control
      pipe_port_id0 <= port_id[0];

      // Handle write strobes
      if (write_strobe == 1'b1) begin
        // Port 10 (assuming based on input mux) might be baud rate setting
        if (port_id[1:0] == 2'b10) begin
          set_baud_rate <= out_port;
        end
      end

      // Handle k_write_strobes (special writes, e.g., resets)
      // Assuming Port 01 is used for UART reset control
      if (k_write_strobe == 1'b1) begin
        if (port_id[1:0] == 2'b01) begin // Check specific port for reset
          uart_tx_reset <= out_port[0];
          uart_rx_reset <= out_port[1];
        end
      end else begin
          // Deassert resets when not actively being written by k_write_strobe to port 01
          // Alternatively, resets could be edge-triggered or require explicit deassertion
          // Depending on uart_tx6/uart_rx6 behavior, this might need adjustment
          // uart_tx_reset <= 1'b0;
          // uart_rx_reset <= 1'b0;
      end
  end

  // Combinational assignment for UART TX data input
  assign uart_tx_data_in = out_port;

  // Combinational assignment for UART TX write enable
  // Write occurs if write_strobe is active AND the *previous* cycle's port_id[0] was 0 (targeting port 00)
  assign write_to_uart_tx = write_strobe & ~pipe_port_id0;

endmodule