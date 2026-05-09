module uart6_kc705 (  input   uart_rx,
                     output   uart_tx,
                      input   clk200_p,
                      input   clk200_n,
                      input   test_i,       // Added test mode input
                      input   scan_rst_n);  // Added primary scan reset input (active low)
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
wire        kcpsm6_reset_internal; // Internal reset signal
wire        rdl;
wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
reg         pipe_port_id0;
wire        uart_tx_data_present;
wire        uart_tx_half_full;
wire        uart_tx_full;
reg         uart_tx_reset_internal; // Internal reset signal
wire        uart_tx_reset;          // Actual reset signal (MUXed)
wire [7:0]  uart_rx_data_out;
reg         read_from_uart_rx;
wire        uart_rx_data_present;
wire        uart_rx_half_full;
wire        uart_rx_full;
reg         uart_rx_reset_internal; // Internal reset signal
wire        uart_rx_reset;          // Actual reset signal (MUXed)
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
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset), // Use MUXed reset
	.sleep		(kcpsm6_sleep),
	.clk 			(clk));

  // MUX for DFT reset (Assuming active high reset needed for processor)
  assign kcpsm6_reset_internal = rdl; // Original reset logic
  assign kcpsm6_reset = test_i ? !scan_rst_n : kcpsm6_reset_internal; // Select primary reset (active high) in test mode

  assign kcpsm6_sleep = write_strobe && k_write_strobe;
  // Assign interrupt based on UART RX data presence (example fix for combinational loop)
  assign interrupt = uart_rx_data_present;

  auto_baud_rate_control #(
	.C_FAMILY		   ("7S"),
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
      .buffer_reset(uart_tx_reset), // Use MUXed reset
      .clk(clk));

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ), // Use MUXed reset
      .clk(clk ));

  // Baud rate generation logic with asynchronous reset controlled by primary input
  always @ (posedge clk or negedge scan_rst_n) // Use primary reset
  begin
    if (!scan_rst_n) begin // Check primary reset (active low)
      baud_rate_counter <= 8'b0;
      en_16_x_baud      <= 1'b0;
    end else begin
      // Functional logic
      if (baud_rate_counter[4:0] == set_baud_rate[4:0]) begin
        baud_rate_counter <= {baud_rate_counter[7:5], 5'b00000};
        en_16_x_baud <= 1'b1;
      end
      else begin
        baud_rate_counter <= {baud_rate_counter[7:5], (baud_rate_counter[4:0] + 5'b00001)};
        en_16_x_baud <= 1'b0;
      end
    end
  end

  // Input port muxing and read strobe logic with asynchronous reset controlled by primary input
  always @ (posedge clk or negedge scan_rst_n) // Use primary reset
  begin
    if (!scan_rst_n) begin // Check primary reset (active low)
      in_port           <= 8'b0;
      read_from_uart_rx <= 1'b0;
    end else begin
      // Functional logic: Input port mux
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

      // Functional logic: UART RX read strobe
      if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
          read_from_uart_rx <= 1'b1;
        end
        else begin
          read_from_uart_rx <= 1'b0;
        end
    end
  end

  // Baud rate setting and port_id pipeline register with asynchronous reset controlled by primary input
  always @ (posedge clk or negedge scan_rst_n) // Use primary reset
  begin
    if (!scan_rst_n) begin // Check primary reset (active low)
      set_baud_rate <= 8'b0; // Example reset value
      pipe_port_id0 <= 1'b0;
    end else begin
      // Functional logic: Baud rate setting
      if (write_strobe == 1'b1) begin
        if (port_id[1] == 1'b1) begin // Assuming port_id[1] selects baud rate
          set_baud_rate <= out_port;
        end
      end
      // Functional logic: Pipeline port_id[0]
      pipe_port_id0 <= port_id[0];
    end
  end

  assign uart_tx_data_in = out_port;
  // Use pipelined version of port_id[0] for UART TX write strobe
  assign write_to_uart_tx = write_strobe & pipe_port_id0;

  // Internal UART reset generation logic with asynchronous reset controlled by primary input
  // Added explicit else to prevent inferred latches
  always @ (posedge clk or negedge scan_rst_n) // Use primary reset
  begin
    if (!scan_rst_n) begin // Check primary reset (active low)
        uart_tx_reset_internal <= 1'b0; // Reset internal reset FFs
        uart_rx_reset_internal <= 1'b0;
    end else begin
      // Functional logic for internal resets
      if (k_write_strobe == 1'b1) begin
        if (port_id[0] == 1'b1) begin // Assuming port_id[0] selects reset control
            uart_tx_reset_internal <= out_port[0];
            uart_rx_reset_internal <= out_port[1];
        end else begin
            // Explicitly hold value if port_id[0] is not 1
            uart_tx_reset_internal <= uart_tx_reset_internal;
            uart_rx_reset_internal <= uart_rx_reset_internal;
        end
      end else begin
         // Explicitly hold value if k_write_strobe is not 1
         uart_tx_reset_internal <= uart_tx_reset_internal;
         uart_rx_reset_internal <= uart_rx_reset_internal;
      end
    end
  end

  // MUX for DFT reset (Assuming active high reset needed for UARTs)
  assign uart_tx_reset = test_i ? !scan_rst_n : uart_tx_reset_internal; // Select primary reset (active high) in test mode
  assign uart_rx_reset = test_i ? !scan_rst_n : uart_rx_reset_internal; // Select primary reset (active high) in test mode

endmodule