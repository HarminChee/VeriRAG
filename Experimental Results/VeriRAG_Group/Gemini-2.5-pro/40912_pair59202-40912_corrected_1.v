module uart6_kc705 (  input   uart_rx,
                     output   uart_tx,
                      input   clk200_p,
                      input   clk200_n,
                      // DFT Inputs
                      input   dft_test_mode,
                      input   dft_kcpsm6_reset_in,
                      input   dft_uart_tx_reset_in,
                      input   dft_uart_rx_reset_in
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
wire        kcpsm6_reset;
wire        rdl;
wire [7:0]  uart_tx_data_in;
wire        write_to_uart_tx;
reg         pipe_port_id0;
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
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset), // Connects corrected reset
	.sleep		(kcpsm6_sleep),
	.clk 			(clk));

  // DFT Correction for ACNCPI on kcpsm6_reset
  wire kcpsm6_reset_functional = rdl;
  assign kcpsm6_reset = dft_test_mode ? dft_kcpsm6_reset_in : kcpsm6_reset_functional;

  assign kcpsm6_sleep = write_strobe && k_write_strobe;
  assign interrupt = interrupt_ack; // Note: Potential combinational loop

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
      .buffer_reset(uart_tx_reset), // Connects corrected reset
      .clk(clk));

  uart_rx6 rx(
      .serial_in(uart_rx),
      .en_16_x_baud(en_16_x_baud ),
      .data_out(uart_rx_data_out ),
      .buffer_read(read_from_uart_rx ),
      .buffer_data_present(uart_rx_data_present ),
      .buffer_half_full(uart_rx_half_full ),
      .buffer_full(uart_rx_full ),
      .buffer_reset(uart_rx_reset ), // Connects corrected reset
      .clk(clk ));

  always @ (posedge clk )
  begin
    // Use DFT-controllable kcpsm6_reset for synchronous reset
    if (kcpsm6_reset) begin
        baud_rate_counter <= 8'd0;
        en_16_x_baud <= 1'b0;
    end else begin
        if (baud_rate_counter == set_baud_rate) begin
          baud_rate_counter <= 8'd0;
          en_16_x_baud <= 1'b1;
        end
        else begin
          baud_rate_counter <= baud_rate_counter + 8'd1;
          en_16_x_baud <= 1'b0;
        end
    end
  end

  always @ (posedge clk)
  begin
    // Use DFT-controllable kcpsm6_reset for synchronous reset
    if (kcpsm6_reset) begin
        in_port <= 8'b0;
        read_from_uart_rx <= 1'b0;
    end else begin
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
            default : in_port <= 8'b00000000 ; // Assign defined value instead of X
        endcase;

        if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
            read_from_uart_rx <= 1'b1;
          end
          else begin
            read_from_uart_rx <= 1'b0;
          end
    end
  end

  always @ (posedge clk)
  begin
      // Use DFT-controllable kcpsm6_reset for synchronous reset
      if (kcpsm6_reset) begin
          set_baud_rate <= 8'd0;
          pipe_port_id0 <= 1'b0;
      end else begin
          if (write_strobe == 1'b1) begin
            if (port_id[1] == 1'b1) begin
              set_baud_rate <= out_port;
            end
          end
          pipe_port_id0 <= port_id[0];
      end
  end

  assign uart_tx_data_in = out_port;
  assign write_to_uart_tx = write_strobe & pipe_port_id0;

  // DFT Correction for ACNCPI on uart_tx_reset and uart_rx_reset
  // Generate reset signals with DFT control
  always @ (posedge clk)
  begin
      if (dft_test_mode) begin
          // Test mode: Control FFs directly from primary inputs (synchronous set/reset)
          uart_tx_reset <= dft_uart_tx_reset_in;
          uart_rx_reset <= dft_uart_rx_reset_in;
      end else begin
          // Functional mode: Apply synchronous reset and functional logic
          if (kcpsm6_reset) begin // Use controllable processor reset
              uart_tx_reset <= 1'b0; // Define reset state
              uart_rx_reset <= 1'b0; // Define reset state
          end else begin
              // Functional update logic
              // Default assignment to hold current value if conditions below aren't met
              uart_tx_reset <= uart_tx_reset;
              uart_rx_reset <= uart_rx_reset;

              if (k_write_strobe == 1'b1) begin
                  if (port_id[0] == 1'b1) begin
                      uart_tx_reset <= out_port[0];
                      uart_rx_reset <= out_port[1];
                  end
              end
          end
      end
  end

endmodule