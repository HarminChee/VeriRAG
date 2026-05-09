module uart6_ml605 (
    input   wire test_mode,          // DFT Test Mode input
    input   wire rst,                // DFT Reset input (active high)
    input   uart_rx,
    input   clk200_p,
    input   clk200_n,
    output  uart_tx
);
wire          clk200;
wire          clk;
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

// DFT signals for reset control
wire        dft_kcpsm6_reset;
wire        dft_uart_tx_reset_driver;
wire        dft_uart_rx_reset_driver;

  IBUFGDS diff_clk_buffer(
      .I(clk200_p),
      .IB(clk200_n),
      .O(clk200));

  BUFR #(
      .BUFR_DIVIDE("4"),
      .SIM_DEVICE("VIRTEX6"))
  clock_divide (
      .I(clk200),
      .O(clk),
      .CE(1'b1),
      .CLR(1'b0));

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
	.reset 		(dft_kcpsm6_reset), // Use DFT controlled reset
	.sleep		(kcpsm6_sleep),
	.clk 			(clk));

  // DFT Fix: Control kcpsm6 reset with primary input 'rst' during test_mode
  assign dft_kcpsm6_reset = test_mode ? rst : rdl;
  assign kcpsm6_sleep = 1'b0;
  assign interrupt = interrupt_ack; // Note: This creates a combinational loop, which might be intended for interrupt handling but can be problematic.

  uart_control #(
	.C_FAMILY		   ("V6"),
	.C_RAM_SIZE_KWORDS	(2),
	.C_JTAG_LOADER_ENABLE	(1))
  program_rom (
 	.rdl 			(rdl),
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
      .buffer_reset(dft_uart_tx_reset_driver), // Use DFT controlled reset driver
      .clk(clk));

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(dft_uart_rx_reset_driver ), // Use DFT controlled reset driver
      .clk(clk ));

  // DFT Fix: Generate reset driver signals, bypassing registers in test mode
  assign dft_uart_tx_reset_driver = test_mode ? rst : uart_tx_reset;
  assign dft_uart_rx_reset_driver = test_mode ? rst : uart_rx_reset;

  always @ (posedge clk )
  begin
    // Baud rate generation logic (remains unchanged)
    if (baud_count == 5'b11010) begin
      baud_count <= 5'b00000;
      en_16_x_baud <= 1'b1;
    end
    else begin
      baud_count <= baud_count + 5'b00001;
      en_16_x_baud <= 1'b0;
    end
  end

  always @ (posedge clk)
  begin
    // Input port mux logic (remains unchanged)
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

    // UART RX read logic (remains unchanged)
    if ((read_strobe == 1'b1) && (port_id[0] == 1'b1)) begin
        read_from_uart_rx <= 1'b1;
      end
      else begin
        read_from_uart_rx <= 1'b0;
      end
  end

  // UART TX write logic (remains unchanged)
  assign uart_tx_data_in = out_port;
  assign write_to_uart_tx = write_strobe & port_id[0];

  // Internal reset generation logic for functional mode
  always @ (posedge clk)
  begin
    // DFT Fix: Only update functional resets when not in test mode
    //          In test mode, the bypass logic takes precedence for submodule resets.
    //          The state of these regs in test mode might not matter if scan clears them,
    //          or they should be held/reset based on test methodology.
    //          Here, we simply disable functional updates in test mode.
    if (!test_mode) begin
        if (k_write_strobe == 1'b1) begin
          if (port_id[0] == 1'b1) begin
              uart_tx_reset <= out_port[0];
              uart_rx_reset <= out_port[1];
          end
          // else: regs hold previous value in functional mode
        end
        // else: regs hold previous value in functional mode
    end
    // else: In test mode, regs hold previous value (or could be forced by scan)
  end

endmodule