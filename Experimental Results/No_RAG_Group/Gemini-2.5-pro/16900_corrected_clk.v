module uart6_ml605_corrected_clk (
                      input   uart_rx,
                      input   clk200_p,
                      input   clk200_n,
                      input   test_clk,       // Added test clock input for DFT
                      input   test_mode,      // Added test mode control input for DFT
                     output   uart_tx );

// Internal signals
wire          clk200;
wire          clk;              // Original functional clock (internally generated)
wire          scan_clk;         // Multiplexed clock for functional/test mode

wire [11:0] address;
wire [17:0]	instruction;
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
reg [4:0]   baud_count;
reg         en_16_x_baud;

  // Differential clock input buffer
  IBUFGDS diff_clk_buffer(
      .I(clk200_p),
      .IB(clk200_n),
      .O(clk200));

  // Clock divider (generates internal clock 'clk')
  BUFR #(
      .BUFR_DIVIDE("4"),
      .SIM_DEVICE("VIRTEX6"))
  clock_divide (
      .I(clk200),
      .O(clk),            // Output the internally generated functional clock
      .CE(1'b1),
      .CLR(1'b0));

  // DFT Clock MUX: Selects functional clock or test clock based on test_mode
  // In test mode (test_mode=1), use test_clk (primary input derived)
  // In functional mode (test_mode=0), use clk (internally generated)
  assign scan_clk = test_mode ? test_clk : clk;

  // PicoBlaze processor instance
  kcpsm6 #(
	.interrupt_vector	(12'h7F0),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h42))
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
	.clk 			(scan_clk)); // Changed clk to scan_clk

  assign kcpsm6_reset = rdl;
  assign kcpsm6_sleep = 1'b0;
  assign interrupt = interrupt_ack; // Simple loopback for interrupt handling

  // Program ROM (BRAM) instance
  uart_control #(
	.C_FAMILY		   ("V6"),
	.C_RAM_SIZE_KWORDS	(2),
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(scan_clk)); // Changed clk to scan_clk

  // UART Transmitter instance
  uart_tx6 tx(
      .data_in(uart_tx_data_in),
      .en_16_x_baud(en_16_x_baud),
      .serial_out(uart_tx),
      .buffer_write(write_to_uart_tx),
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(uart_tx_full),
      .buffer_reset(uart_tx_reset),
      .clk(scan_clk)); // Changed clk to scan_clk

  // UART Receiver instance
  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ),
      .clk(scan_clk )); // Changed clk to scan_clk

  // Baud rate generator logic
  always @ (posedge scan_clk ) // Changed clk to scan_clk
  begin
    // Specific count value for baud rate generation (example value)
    if (baud_count == 5'b11010) begin
      baud_count <= 5'b00000;
      en_16_x_baud <= 1'b1;                 // Enable baud tick
    end
    else begin
      baud_count <= baud_count + 5'b00001;
      en_16_x_baud <= 1'b0;                 // Disable baud tick
    end
  end

  // Input port logic for PicoBlaze
  always @ (posedge scan_clk) // Changed clk to scan_clk
  begin
    // Multiplex input port based on port_id LSB
    case (port_id[0])
        1'b0 : in_port <= { 2'b00,             // Read UART status flags
                            uart_rx_full,
                            uart_rx_half_full,
                            uart_rx_data_present,
                            uart_tx_full,
                            uart_tx_half_full,
                            uart_tx_data_present };
        1'b1 : in_port <= uart_rx_data_out; // Read UART received data
        default : in_port <= 8'bXXXXXXXX ;  // Default case (should not occur)
    endcase;

    // Control signal for reading from UART RX buffer
    if ((read_strobe == 1'b1) && (port_id[0] == 1'b1)) begin
        read_from_uart_rx <= 1'b1; // Assert read signal
      end
      else begin
        read_from_uart_rx <= 1'b0; // Deassert read signal
      end
  end

  // Output port assignments
  assign uart_tx_data_in = out_port; // Data to be transmitted
  assign write_to_uart_tx = write_strobe & port_id[0]; // Write enable for TX buffer

  // UART Reset control logic
  always @ (posedge scan_clk) // Changed clk to scan_clk
  begin
    // Use K_WRITE_STROBE for special register writes (e.g., resets)
    if (k_write_strobe == 1'b1) begin
      if (port_id[0] == 1'b1) begin // Check if targeting the control register port
          uart_tx_reset <= out_port[0]; // Reset TX buffer based on LSB of output data
          uart_rx_reset <= out_port[1]; // Reset RX buffer based on bit 1 of output data
      end
    end
    // Note: Resets should ideally be synchronous and handled carefully in DFT
    // Consider adding explicit synchronous reset logic if needed for testability.
  end

endmodule