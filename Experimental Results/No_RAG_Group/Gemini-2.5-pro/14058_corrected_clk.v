module uart6_ml605_corrected_clk ( // Renamed module as requested (using a generic number '1')
                      input   uart_rx,
                      input   clk200_p,
                      input   clk200_n,
                      input   test_mode, // Added test mode input
                     output   uart_tx );
wire          clk200;
wire          clk; // Original divided clock
wire          dft_clk; // Multiplexed clock for DFT
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

  // Clock input buffering
  IBUFGDS diff_clk_buffer(
      .I(clk200_p),
      .IB(clk200_n),
      .O(clk200));

  // Clock divider (functional clock)
  BUFR #(
      .BUFR_DIVIDE("4"),
      .SIM_DEVICE("VIRTEX6"))
  clock_divide (
      .I(clk200),
      .O(clk),
      .CE(1'b1),
      .CLR(1'b0));

  // DFT Clock Mux: Select between functional divided clock (clk) and test clock (clk200)
  // clk200 is used as test clock as it's derived directly from primary inputs
  assign dft_clk = test_mode ? clk200 : clk;

  // Processor instantiation using DFT clock
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
	.clk 			(dft_clk)); // Changed clk to dft_clk

  assign kcpsm6_reset = rdl;
  assign kcpsm6_sleep = 1'b0;
  assign interrupt = interrupt_ack;

  // Program ROM instantiation using DFT clock
  uart_control #(
	.C_FAMILY		   ("V6"),
	.C_RAM_SIZE_KWORDS	(2),
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(dft_clk)); // Changed clk to dft_clk

  // UART TX instantiation using DFT clock
  uart_tx6 tx(
      .data_in(uart_tx_data_in),
      .en_16_x_baud(en_16_x_baud),
      .serial_out(uart_tx),
      .buffer_write(write_to_uart_tx),
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(uart_tx_full),
      .buffer_reset(uart_tx_reset),
      .clk(dft_clk)); // Changed clk to dft_clk

  // UART RX instantiation using DFT clock
  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ),
      .clk(dft_clk )); // Changed clk to dft_clk

  // Baud rate generator logic using DFT clock
  always @ (posedge dft_clk ) // Changed clk to dft_clk
  begin
    // Assuming reset is handled externally or implicitly for DFT purposes
    if (baud_count == 5'b11010) begin
      baud_count <= 5'b00000;
      en_16_x_baud <= 1'b1;
    end
    else begin
      baud_count <= baud_count + 5'b00001;
      en_16_x_baud <= 1'b0;
    end
  end

  // Input port logic using DFT clock
  always @ (posedge dft_clk) // Changed clk to dft_clk
  begin
    // Assuming reset is handled externally or implicitly for DFT purposes
    case (port_id[0])
        1'b0 : in_port <= { 2'b00,
                            uart_rx_full,
                            uart_rx_half_full,
                            uart_rx_data_present,
                            uart_tx_full,
                            uart_tx_half_full,
                            uart_tx_data_present };
        1'b1 : in_port <= uart_rx_data_out;
        default : in_port <= 8'bXXXXXXXX ;
    endcase;
    if ((read_strobe == 1'b1) && (port_id[0] == 1'b1)) begin
        read_from_uart_rx <= 1'b1;
      end
      else begin
        read_from_uart_rx <= 1'b0;
      end
  end

  assign uart_tx_data_in = out_port;
  assign write_to_uart_tx = write_strobe & port_id[0];

  // UART reset logic using DFT clock
  always @ (posedge dft_clk) // Changed clk to dft_clk
  begin
    // Assuming reset is handled externally or implicitly for DFT purposes
    if (k_write_strobe == 1'b1) begin
      if (port_id[0] == 1'b1) begin
          uart_tx_reset <= out_port[0];
          uart_rx_reset <= out_port[1];
      end
    end
    // Note: Lack of 'else' implies registers hold value. Consider if explicit reset control during test is needed.
  end
endmodule