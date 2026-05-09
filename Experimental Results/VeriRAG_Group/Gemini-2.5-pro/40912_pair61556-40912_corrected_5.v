module uart6_kc705 (
    input   uart_rx,
    output  uart_tx,
    input   clk200_p,
    input   clk200_n,
    input   test_i, // DFT test mode enable
    input   rst_n_i // DFT primary reset input (active low)
);

    wire        clk200;
    wire        clk;
    wire        dft_clk; // DFT clock
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
    wire        kcpsm6_reset; // Functional reset for processor
    wire        dft_kcpsm6_reset; // DFT reset for processor
    wire        dft_general_reset; // DFT reset for general logic (synchronous)
    wire        rdl;
    wire [7:0]  uart_tx_data_in;
    wire        write_to_uart_tx;
    reg         pipe_port_id0;
    wire        uart_tx_data_present;
    wire        uart_tx_half_full;
    wire        uart_tx_full;
    reg         uart_tx_reset_internal; // Internal reset signal for tx
    wire        dft_uart_tx_reset;      // DFT reset for tx module
    wire [7:0]  uart_rx_data_out;
    reg         read_from_uart_rx;
    wire        uart_rx_data_present;
    wire        uart_rx_half_full;
    wire        uart_rx_full;
    reg         uart_rx_reset_internal; // Internal reset signal for rx
    wire        dft_uart_rx_reset;      // DFT reset for rx module
    reg [7:0]   set_baud_rate;
    reg [7:0]   baud_rate_counter;
    reg         en_16_x_baud;

    // DFT Clock Mux: Select primary clock (clk200) in test mode
    // In functional mode, use the buffered clock 'clk'
    assign dft_clk = test_i ? clk200 : clk;

    // Functional reset for processor comes from program_rom's rdl signal
    assign kcpsm6_reset = rdl;

    // DFT Reset Muxes: Select primary reset (!rst_n_i) in test mode (assuming active high resets internally)
    // Note: dft_general_reset is used for synchronous reset logic below
    assign dft_kcpsm6_reset  = test_i ? !rst_n_i : kcpsm6_reset; // For processor (could be async or sync depending on kcpsm6)
    assign dft_uart_tx_reset = test_i ? !rst_n_i : uart_tx_reset_internal; // For tx module (assuming sync reset input)
    assign dft_uart_rx_reset = test_i ? !rst_n_i : uart_rx_reset_internal; // For rx module (assuming sync reset input)
    // General reset for internal logic FFs (synchronous active high)
    assign dft_general_reset = test_i ? !rst_n_i : kcpsm6_reset; // Use processor functional reset source for sync reset

    assign clock_frequency_in_MHz = 8'd200;

    IBUFGDS diff_clk_buffer (
        .I(clk200_p),
        .IB(clk200_n),
        .O(clk200)
    );

    BUFG clock_divide (
        .I(clk200),
        .O(clk)
    );

    kcpsm6 #(
        .interrupt_vector(12'h7FF),
        .scratch_pad_memory_size(64),
        .hwbuild(8'h41)
    ) processor (
        .address(address),
        .instruction(instruction),
        .bram_enable(bram_enable),
        .port_id(port_id),
        .write_strobe(write_strobe),
        .k_write_strobe(k_write_strobe),
        .out_port(out_port),
        .read_strobe(read_strobe),
        .in_port(in_port),
        .interrupt(interrupt),
        .interrupt_ack(interrupt_ack),
        .reset(dft_kcpsm6_reset), // Use DFT reset mux output
        .sleep(kcpsm6_sleep),
        .clk(dft_clk) // Use DFT clock mux output
    );

    assign kcpsm6_sleep = write_strobe && k_write_strobe;
    assign interrupt    = 1'b0; // Avoid combinational loop - connect to actual sources if known

    auto_baud_rate_control #(
        .C_FAMILY("7S"),
        .C_RAM_SIZE_KWORDS(2),
        .C_JTAG_LOADER_ENABLE(1)
    ) program_rom (
        .rdl(rdl), // This drives the functional kcpsm6_reset
        .enable(bram_enable),
        .address(address),
        .instruction(instruction),
        .clk(dft_clk) // Use DFT clock mux output
    );

    uart_tx6 tx (
        .data_in(uart_tx_data_in),
        .en_16_x_baud(en_16_x_baud),
        .serial_out(uart_tx),
        .buffer_write(write_to_uart_tx),
        .buffer_data_present(uart_tx_data_present),
        .buffer_half_full(uart_tx_half_full),
        .buffer_full(uart_tx_full),
        .buffer_reset(dft_uart_tx_reset), // Use DFT reset mux output (assuming synchronous reset)
        .clk(dft_clk) // Use DFT clock mux output
    );

    uart_rx6 rx (
        .serial_in(uart_rx),
        .en_16_x_baud(en_16_x_baud),
        .data_out(uart_rx_data_out),
        .buffer_read(read_from_uart_rx),
        .buffer_data_present(uart_rx_data_present),
        .buffer_half_full(uart_rx_half_full),
        .buffer_full(uart_rx_full),
        .buffer_reset(dft_uart_rx_reset), // Use DFT reset mux output (assuming synchronous reset)
        .clk(dft_clk) // Use DFT clock mux output
    );

    // Baud rate generation logic (Synchronous Reset)
    always @(posedge dft_clk) begin
        if (dft_general_reset) begin // Check reset synchronously
            baud_rate_counter <= 8'b0;
            en_16_x_baud      <= 1'b0;
        end else begin
            if (baud_rate_counter == set_baud_rate) begin
                baud_rate_counter <= 8'b0;
                en_16_x_baud      <= 1'b1;
            end else begin
                baud_rate_counter <= baud_rate_counter + 1'b1;
                en_16_x_baud      <= 1'b0;
            end
        end
    end

    // Input port multiplexing and read strobe logic (Synchronous Reset)
    always @(posedge dft_clk) begin
        if (dft_general_reset) begin // Check reset synchronously
            in_port           <= 8'b0; // Defined reset value
            read_from_uart_rx <= 1'b0;
        end else begin
            // Default assignments to prevent latches
            in_port <= 8'b0; // Assign a defined default value
            read_from_uart_rx <= 1'b0;

            case (port_id[1:0])
                2'b00:   in_port <= { 2'b00,
                                     uart_rx_full,
                                     uart_rx_half_full,
                                     uart_rx_data_present,
                                     uart_tx_full,
                                     uart_tx_half_full,
                                     uart_tx_data_present };
                2'b01:   in_port <= uart_rx_data_out;
                2'b10:   in_port <= clock_frequency_in_MHz;
                default: in_port <= 8'b0; // Use defined default value
            endcase

            if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
                read_from_uart_rx <= 1'b1;
            end // read_from_uart_rx defaults to 1'b0 otherwise via the default assignment above
        end
    end

    // Baud rate setting and output port pipelining (Synchronous Reset)
    always @(posedge dft_clk) begin
        if (dft_general_reset) begin // Check reset synchronously
             set_baud_rate <= 8'b0;
             pipe_port_id0 <= 1'b0;
        end else begin
            // Hold previous value if condition not met (implicit behavior of regs)
            if (write_strobe == 1'b1) begin
                if (port_id[1] == 1'b1) begin
                    set_baud_rate <= out_port;
                end
            end
            pipe_port_id0 <= port_id[0];
        end
    end

    assign uart_tx_data_in  = out_port;
    assign write_to_uart_tx = write_strobe & pipe_port_id0; // Use pipelined value

    // Internal UART reset generation logic (Synchronous Reset for internal regs)
    // These signals drive the DFT muxes for submodule resets.
    always @(posedge dft_clk) begin
        if (dft_general_reset) begin // Synchronous reset for these state registers
            uart_tx_reset_internal <= 1'b0;
            uart_rx_reset_internal <= 1'b0;
        end else begin
            // Default assignments
            uart_tx_reset_internal <= 1'b0;
            uart_rx_reset_internal <= 1'b0;

            if (k_write_strobe == 1'b1) begin
                if (port_id[0] == 1'b1) begin // Check port_id[0] for reset control
                    uart_tx_reset_internal <= out_port[0];
                    uart_rx_reset_internal <= out_port[1];
                end // else defaults apply
            end // else defaults apply
        end
    end

endmodule