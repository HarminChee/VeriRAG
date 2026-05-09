module uart6_kc705 (  input   uart_rx,
                     output   uart_tx,
                      input   clk200_p,
                      input   clk200_n,
                      input   test_i,       // Added test mode input
                      input   test_rst_i);  // Added test reset input
wire        clk200;
wire        clk;
wire        dft_clk;        // Added DFT clock wire
wire [7:0]  clock_frequency_in_MHz;
wire [11:0] address;
wire [17:0] instruction;
wire        bram_enable;
wire [7:0]  in_port;        // Changed to wire, assigned combinationally
wire [7:0]  out_port;
wire [7:0]  port_id;
wire        write_strobe;
wire        k_write_strobe;
wire        read_strobe;
wire        interrupt;
wire        interrupt_ack;
wire        kcpsm6_sleep;
wire        kcpsm6_reset;      // Muxed reset signal
wire        kcpsm6_reset_func; // Functional reset signal
wire        rdl;
wire [7:0]  uart_tx_data_in; // Changed to wire, assigned combinationally
wire        write_to_uart_tx;  // Changed to wire, assigned combinationally
wire        uart_tx_data_present;
wire        uart_tx_half_full;
wire        uart_tx_full;
wire        uart_tx_reset;     // Muxed reset signal for TX module
wire        uart_rx_reset;     // Muxed reset signal for RX module
wire [7:0]  uart_rx_data_out;
reg         read_from_uart_rx; // Registered signal
wire        uart_rx_data_present;
wire        uart_rx_half_full;
wire        uart_rx_full;
reg [7:0]   set_baud_rate;     // Registered signal
reg [7:0]   baud_rate_counter; // Registered signal
reg         en_16_x_baud;      // Registered signal
// Removed reg pipe_port_id0;

  assign clock_frequency_in_MHz = 8'd200;

  IBUFGDS diff_clk_buffer(
      .I(clk200_p),
      .IB(clk200_n),
      .O(clk200));

  BUFG clock_divide (
      .I(clk200),
      .O(clk));

  // DFT Clock Mux: Use primary-derived clock in test mode
  assign dft_clk = test_i ? clk200 : clk;

  // Functional reset signal from ROM
  assign kcpsm6_reset_func = rdl;
  // DFT Reset Mux: Use primary test reset in test mode
  assign kcpsm6_reset = test_i ? test_rst_i : kcpsm6_reset_func;

  // Assign UART resets from the muxed reset
  assign uart_tx_reset = kcpsm6_reset;
  assign uart_rx_reset = kcpsm6_reset;

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
	.in_port 		(in_port),       // Connect combinational in_port
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset),  // Use muxed reset
	.sleep		(kcpsm6_sleep),
	.clk 			(dft_clk));      // Use DFT clock

  assign kcpsm6_sleep = write_strobe && k_write_strobe;
  // Corrected interrupt logic: Generate interrupt based on peripheral status
  assign interrupt = uart_rx_data_present | (~uart_tx_full); // Example condition

  auto_baud_rate_control #(
	.C_FAMILY		   ("7S"),
	.C_RAM_SIZE_KWORDS	(2),
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(dft_clk)); // Use DFT clock

  uart_tx6 tx(
      .data_in(uart_tx_data_in),       // Connect combinational signal
      .en_16_x_baud(en_16_x_baud),
      .serial_out(uart_tx),
      .buffer_write(write_to_uart_tx), // Connect combinational signal
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(uart_tx_full),
      .buffer_reset(uart_tx_reset),    // Use assigned muxed reset signal
      .clk(dft_clk));                  // Use DFT clock

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ), // Connect registered signal
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ),   // Use assigned muxed reset signal
      .clk(dft_clk ));                 // Use DFT clock

  // Baud rate generation logic with synchronous reset
  always @ (posedge dft_clk) // Changed sensitivity list for synchronous reset
  begin
    if (kcpsm6_reset) begin // Check reset level synchronously
        baud_rate_counter <= 8'b0;
        en_16_x_baud      <= 1'b0;
    end else begin
        // Check if set_baud_rate is non-zero to prevent division by zero or lockup
        if (set_baud_rate != 8'b0 && baud_rate_counter == set_baud_rate) begin
          baud_rate_counter <= 8'b00000000;
          en_16_x_baud <= 1'b1;
        end
        else begin
          // Only increment if set_baud_rate is non-zero
          baud_rate_counter <= (set_baud_rate == 8'b0) ? 8'b0 : baud_rate_counter + 8'b00000001;
          en_16_x_baud <= 1'b0;
        end
    end
  end

  // Port interaction logic (Registered signals only) with synchronous reset
  always @ (posedge dft_clk) // Changed sensitivity list for synchronous reset
  begin
    if (kcpsm6_reset) begin // Check reset level synchronously
        read_from_uart_rx <= 1'b0;
        set_baud_rate     <= 8'b0; // Default to 0 (requires setting via processor)
    end else begin
        // Handle read strobe for UART RX buffer (generate registered read signal)
        if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
            read_from_uart_rx <= 1'b1;
        end else begin
            read_from_uart_rx <= 1'b0;
        end

        // Handle write strobe for baud rate setting (register the setting)
        if (write_strobe == 1'b1) begin
            if (port_id[1:0] == 2'b10) begin // Assuming port 10 is baud rate setting
                set_baud_rate <= out_port;
            end
            // else: set_baud_rate retains value unless reset
        end
        // else: set_baud_rate retains value unless reset
    end
  end

  // Combinational logic for input port mux (maps peripheral status/data to processor input)
  assign in_port = (port_id[1:0] == 2'b00) ? { 2'b00, uart_rx_full, uart_rx_half_full, uart_rx_data_present, uart_tx_full, uart_tx_half_full, uart_tx_data_present } : // Status Port
                   (port_id[1:0] == 2'b01) ? uart_rx_data_out :           // UART RX Data Port
                   (port_id[1:0] == 2'b10) ? clock_frequency_in_MHz :    // Clock Freq Port
                   8'bXXXXXXXX; // Default for unused port IDs

  // Combinational assignments for TX write (connect processor output and strobe to TX module)
  assign uart_tx_data_in = out_port; // Processor data out goes to TX data in
  assign write_to_uart_tx = write_strobe && (port_id[1:0] == 2'b00); // Generate write pulse when processor writes to port 00

endmodule