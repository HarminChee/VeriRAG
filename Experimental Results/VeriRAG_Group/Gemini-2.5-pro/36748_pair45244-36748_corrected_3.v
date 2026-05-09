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
wire        kcpsm6_reset_func; // Functional reset signal
wire        rdl;
wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
reg         pipe_port_id0;
wire        uart_tx_data_present;
wire        uart_tx_half_full;
wire        uart_tx_full;
// Removed uart_tx_reset_reg, uart_rx_reset_reg
wire        uart_tx_reset;     // Muxed reset signal for TX module
wire        uart_rx_reset;     // Muxed reset signal for RX module
wire [7:0]  uart_rx_data_out;
reg         read_from_uart_rx;
wire        uart_rx_data_present;
wire        uart_rx_half_full;
wire        uart_rx_full;
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

  // DFT Clock Mux: Use primary-derived clock in test mode
  assign dft_clk = test_i ? clk200 : clk;

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
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset), // Use muxed reset
	.sleep		(kcpsm6_sleep),
	.clk 			(dft_clk)); // Use DFT clock

  // DFT Reset Mux for kcpsm6: Use primary test reset in test mode
  assign kcpsm6_reset_func = rdl;
  assign kcpsm6_reset = test_i ? test_rst_i : kcpsm6_reset_func;

  assign kcpsm6_sleep = write_strobe && k_write_strobe;
  // Corrected interrupt logic: Generate interrupt based on peripheral status (example)
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
      .data_in(uart_tx_data_in),
      .en_16_x_baud(en_16_x_baud),
      .serial_out(uart_tx),
      .buffer_write(write_to_uart_tx),
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(uart_tx_full),
      .buffer_reset(uart_tx_reset),  // Use muxed reset signal
      .clk(dft_clk)); // Use DFT clock

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ), // Use muxed reset signal
      .clk(dft_clk )); // Use DFT clock

  // Baud rate generation logic
  always @ (posedge dft_clk ) // Use DFT clock
  begin
    if (baud_rate_counter == set_baud_rate) begin
      baud_rate_counter <= 8'b00000000;
      en_16_x_baud <= 1'b1;
    end
    else begin
      baud_rate_counter <= baud_rate_counter + 8'b00000001;
      en_16_x_baud <= 1'b0;
    end
  end

  // Input port mux logic and read strobe generation
  always @ (posedge dft_clk) // Use DFT clock
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
        2'b10 : in_port <= clock_frequency_in_MHz;
        default : in_port <= 8'bXXXXXXXX ;
    endcase

    if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
        read_from_uart_rx <= 1'b1;
      end
      else begin
        read_from_uart_rx <= 1'b0;
      end
  end

  // Baud rate setting and output port logic
  always @ (posedge dft_clk) // Use DFT clock
  begin
      if (write_strobe == 1'b1) begin
        if (port_id[1] == 1'b1) begin // Baud rate setting port
          set_baud_rate <= out_port;
        end
      end
      pipe_port_id0