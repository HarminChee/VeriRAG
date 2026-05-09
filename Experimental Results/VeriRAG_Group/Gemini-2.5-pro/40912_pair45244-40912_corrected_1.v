module uart6_kc705 (
    input   uart_rx,
    output  uart_tx,
    input   clk200_p,
    input   clk200_n,
    input   test_mode, // Added test mode input
    input   test_rst_n // Added active-low asynchronous test reset input
);

wire        clk200;
wire        clk;
wire        dft_clk; // Added DFT clock wire
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
// wire        kcpsm6_reset; // Replaced by dft_processor_reset
wire        rdl;
wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
reg         pipe_port_id0;
wire        uart_tx_data_present;
wire        uart_tx_half_full;
wire        uart_tx_full;
reg         uart_tx_reset; // Internal signal generating functional reset for TX UART
wire        dft_uart_tx_reset; // Muxed reset signal for TX UART instance
wire [7:0]  uart_rx_data_out;
reg         read_from_uart_rx;
wire        uart_rx_data_present;
wire        uart_rx_half_full;
wire        uart_rx_full;
reg         uart_rx_reset; // Internal signal generating functional reset for RX UART
wire        dft_uart_rx_reset; // Muxed reset signal for RX UART instance
reg [7:0]   set_baud_rate;
reg [7:0]   baud_rate_counter; // Changed width from [4:0] to [7:0] to match set_baud_rate
reg         en_16_x_baud;
wire        dft_processor_reset; // Muxed reset signal for processor instance

  assign clock_frequency_in_MHz = 8'd200;

  IBUFGDS diff_clk_buffer(
      .I(clk200_p),
      .IB(clk200_n),
      .O(clk200));

  BUFG clock_divide (
      .I(clk200),
      .O(clk));

  // DFT Clock Mux: Select primary clock source (clk200) in test mode
  assign dft_clk = test_mode ? clk200 : clk;

  // DFT Reset Muxes (Assuming processor and UART resets are active high)
  assign dft_processor_reset = test_mode ? !test_rst_n : rdl;
  assign dft_uart_tx_reset   = test_mode ? !test_rst_n : uart_tx_reset;
  assign dft_uart_rx_reset   = test_mode ? !test_rst_n : uart_rx_reset;


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
	.interrupt 		(interrupt), // Driven below
	.interrupt_ack 	(interrupt_ack),
	.reset 		(dft_processor_reset), // Use muxed DFT reset
	.sleep		(kcpsm6_sleep),
	.clk 			(dft_clk)); // Use DFT clock

  // assign kcpsm6_reset = rdl; // Original assignment, now handled by mux
  assign kcpsm6_sleep = write_strobe && k_write_strobe;
  // assign interrupt = interrupt_ack; // Removed potential loop causing HAL error
  assign interrupt = 1'b0; // Tie interrupt low (assuming no sources in this snippet)

  auto_baud_rate_control #(
	.C_FAMILY		   ("7S"),
	.C_RAM_SIZE_KWORDS	(2),
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl), // Functional reset source
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(dft_clk)); // Use DFT clock

  uart_tx6 tx(
      .data_in(uart_tx_data_in),
      .en_16_x_baud(en_16_x_baud),
      .serial_out(uart_tx),
      .buffer_write(write_to_uart_tx),
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(uart_tx_full),
      .buffer_reset(dft_uart_tx_reset), // Use muxed DFT reset
      .clk(dft_clk)); // Use DFT clock

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(dft_uart_rx_reset ), // Use muxed DFT reset
      .clk(dft_clk )); // Use DFT clock

  // Baud rate generation logic with asynchronous reset
  always @ (posedge dft_clk or negedge test_rst_n)
  begin
    if (!test_rst_n) begin
      baud_rate_counter <= 8'b00000000; // Reset counter
      en_16_x_baud <= 1'b0;             // Reset enable signal
    end
    else begin
      if (baud_rate_counter == set_baud_rate) begin // Compare full width
        baud_rate_counter <= 8'b00000000;
        en_16_x_baud <= 1'b1;
      end
      else begin
        baud_rate_counter <= baud_rate_counter + 8'b00000001; // Increment full width
        en_16_x_baud <= 1'b0;
      end
    end
  end

  // Input port logic with asynchronous reset
  always @ (posedge dft_clk or negedge test_rst_n)
  begin
    if (!test_rst_n) begin
      in_port <= 8'b00000000;
      read_from_uart_rx <= 1'b0;
    end
    else begin
      // Combinational assignment based on port_id
      case (port_id[1:0])
          2'b00 : in_port <= { 2'b00,
                               uart_rx_full,
                               uart_rx_half_full,
                               uart_rx_data_present,
                               uart_tx_full,
                               uart_tx_half_full,
                               uart_tx_data_present };
          2'b01 : in_port <= uart_rx_data_out;
          2'b10 : in_port <= clock_frequency_in_MHz;
          default : in_port <= 8'b00000000 ; // Assign defined value
      endcase;

      // Sequential assignment for read_from_uart_rx
      if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
          read_from_uart_rx <= 1'b1;
        end
        else begin
          read_from_uart_rx <= 1'b0;
        end
    end
  end

  // Baud rate setting and port ID pipe logic with asynchronous reset
  always @ (posedge dft_clk or negedge test_rst_n)
  begin
    if (!test_rst_n) begin
      set_baud_rate <= 8'b00000000; // Reset baud rate setting
      pipe_port_id0 <= 1'b0;         // Reset pipe register
    end
    else begin
        // Conditional update for set_baud_rate
        if (write_strobe == 1'b1) begin
          if (port_id[1] == 1'b1) begin
            set_baud_rate <= out_port;
          end
        end
        // Unconditional update for pipe_port_id0 based on current port_id
        pipe_port_id0 <= port_id[0];
    end
  end

  assign uart_tx_data_in = out_port;
  assign write_to_uart_tx = write_strobe & pipe_port_id0;

  // UART functional reset generation logic with asynchronous reset
  always @ (posedge dft_clk or negedge test_rst_n)
  begin
    if (!test_rst_n) begin
      uart_tx_reset <= 1'b0; // Reset to inactive state (assuming active-high reset)
      uart_rx_reset <= 1'b0; // Reset to inactive state (assuming active-high reset)
    end
    else begin
      // Generate functional resets based on processor commands
      if (k_write_strobe == 1'b1) begin
        if (port_id[0] == 1'b1) begin
            uart_tx_reset <= out_port[0];
            uart_rx_reset <= out_port[1];
        end
        // Consider adding 'else' clauses if resets should be de-asserted otherwise
        // else begin
        //   uart_tx_reset <= 1'b0; // De-assert if condition not met