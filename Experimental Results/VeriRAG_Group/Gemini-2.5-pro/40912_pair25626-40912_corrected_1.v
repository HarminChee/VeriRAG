`timescale 1ns / 1ps
module uart6_kc705 (  input   uart_rx,
                     output   uart_tx,
                      input   clk200_p,
                      input   clk200_n,
                      input   dft_test_mode, // Added for DFT
                      input   dft_reset      // Added for DFT (active high assumed)
                      );
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
// wire        kcpsm6_reset; // Original reset signal from program_rom
wire        kcpsm6_reset_muxed; // Muxed reset for DFT
wire        rdl;
wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
reg         pipe_port_id0;
wire        uart_tx_data_present;
wire        uart_tx_half_full;
wire        uart_tx_full;
reg         uart_tx_reset; // Original reset signal generated internally
wire        uart_tx_reset_muxed; // Muxed reset for DFT
wire [7:0]  uart_rx_data_out;
reg         read_from_uart_rx;
wire        uart_rx_data_present;
wire        uart_rx_half_full;
wire        uart_rx_full;
reg         uart_rx_reset; // Original reset signal generated internally
wire        uart_rx_reset_muxed; // Muxed reset for DFT
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

  // DFT Reset Muxing Logic
  assign kcpsm6_reset_muxed = dft_test_mode ? dft_reset : rdl;
  assign uart_tx_reset_muxed = dft_test_mode ? dft_reset : uart_tx_reset;
  assign uart_rx_reset_muxed = dft_test_mode ? dft_reset : uart_rx_reset;

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
	.reset 		(kcpsm6_reset_muxed), // Use muxed reset
	.sleep		(kcpsm6_sleep),
	.clk 			(clk));

  // assign kcpsm6_reset = rdl; // Original assignment replaced by mux
  assign kcpsm6_sleep = write_strobe && k_write_strobe;
  assign interrupt = interrupt_ack;

  auto_baud_rate_control #(
	.C_FAMILY		   ("7S"),
	.C_RAM_SIZE_KWORDS	(2),
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl), // rdl drives the functional reset part of kcpsm6_reset_muxed
	.enable 		(bram_enable),
	.address 		(address),
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
      .buffer_reset(uart_tx_reset_muxed), // Use muxed reset
      .clk(clk));

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset_muxed ), // Use muxed reset
      .clk(clk ));

  always @ (posedge clk )
  begin
    if (baud_rate_counter == set_baud_rate) begin
      baud_rate_counter <= 8'd0; // Use 8'd0 for clarity
      en_16_x_baud <= 1'b1;
    end
    else begin
      baud_rate_counter <= baud_rate_counter + 8'd1; // Use 8'd1 for clarity
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
        2'b10 : in_port <= clock_frequency_in_MHz;
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
        if (port_id[1] == 1'b1) begin // Check if this condition is correct for setting baud rate
          set_baud_rate <= out_port;
        end
      end
      pipe_port_id0 <= port_id[0]; // Latches port_id[0] for use in next assignment
  end

  assign uart_tx_data_in = out_port;
  assign write_to_uart_tx = write_strobe & pipe_port_id0; // Use latched value

  always @ (posedge clk)
  begin
    // This block generates the functional part of uart_tx_reset and uart_rx_reset
    // The actual reset fed to the modules is muxed (uart_tx_reset_muxed, uart_rx_reset_muxed)
    // Note: This generation method might still be flagged by DFT tools (ACNCPI)
    // as it's synchronous logic driving an asynchronous reset pin functionally.
    // The mux ensures controllability during test mode.
    if (k_write_strobe == 1'b1) begin
      if (port_id[0] == 1'b1) begin // Check if this condition is correct for UART resets
          uart_tx_reset <= out_port[0];
          uart_rx_reset <= out_port[1];
      end
      // Implicitly holds value if port_id[0] is not 1'b1
    end
    // Implicitly holds value if k_write_strobe is not 1'b1
    // Consider adding explicit deassertion logic if required by functional spec.
  end

endmodule