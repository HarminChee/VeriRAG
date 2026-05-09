module uart6_kc705 (
    input   uart_rx,
    output  uart_tx,
    input   clk200_p,
    input   clk200_n,
    input   test_i,       // DFT Test Mode Input
    input   test_rst,     // DFT Test Reset Input (Active High assumed for test mode)
    input   func_rst_n    // DFT Functional Reset Input (Active Low)
);

    wire        clk200;
    wire        clk;
    wire        dft_clk;         // DFT Muxed Clock
    wire        dft_kcpsm6_reset; // DFT Muxed Reset
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
    wire        interrupt;       // Processor interrupt input
    wire        interrupt_ack;   // Processor interrupt acknowledge output
    wire        kcpsm6_sleep;
    // wire        kcpsm6_reset; // Removed redundant wire
    wire        rdl;             // Output from program_rom, usage unchanged there
    wire [7:0]  uart_tx_data_in;
    wire        write_to_uart_tx;
    reg         pipe_port_id0;
    wire        uart_tx_data_present;
    wire        uart_tx_half_full;
    wire        uart_tx_full;
    reg         uart_tx_reset;   // Synchronous reset for TX UART
    wire [7:0]  uart_rx_data_out;
    reg         read_from_uart_rx;
    wire        uart_rx_data_present; // Interrupt source
    wire        uart_rx_half_full;
    wire        uart_rx_full;
    reg         uart_rx_reset;   // Synchronous reset for RX UART
    reg [7:0]   set_baud_rate;
    reg [7:0]   baud_rate_counter;
    reg         en_16_x_baud;

    assign clock_frequency_in_MHz = 8'd200;

    IBUFGDS diff_clk_buffer(
        .I(clk200_p),
        .IB(clk200_n),
        .O(clk200)
    );

    BUFG clock_divide (
        .I(clk200),
        .O(clk)
    );

    // DFT Clock Mux: Select test clock (clk200) in test mode, functional clock (clk) otherwise
    assign dft_clk = test_i ? clk200 : clk;

    // DFT Reset Mux: Select test reset (test_rst) in test mode,
    // or functional reset (~func_rst_n) otherwise.
    // Ensures reset is always controllable from Primary Inputs (PIs).
    assign dft_kcpsm6_reset = test_i ? test_rst : ~func_rst_n;

    kcpsm6 #(
        .interrupt_vector       (12'h7FF),
        .scratch_pad_memory_size(64),
        .hwbuild                (8'h41)
    ) processor (
        .address        (address),
        .instruction    (instruction),
        .bram_enable    (bram_enable),
        .port_id        (port_id),
        .write_strobe   (write_strobe),
        .k_write_strobe (k_write_strobe),
        .out_port       (out_port),
        .read_strobe    (read_strobe),
        .in_port        (in_port),
        .interrupt      (interrupt),       // Use corrected interrupt signal
        .interrupt_ack  (interrupt_ack),
        .reset          (dft_kcpsm6_reset), // Use DFT Muxed Reset from PIs
        .sleep          (kcpsm6_sleep),
        .clk            (dft_clk)          // Use DFT Muxed Clock
    );

    // Removed: assign kcpsm6_reset = rdl;

    assign kcpsm6_sleep = write_strobe && k_write_strobe;

    // Connect interrupt source (UART RX data present) to processor interrupt input
    // Removed: assign interrupt = interrupt_ack; // Removed loop/multiple driver source
    assign interrupt = uart_rx_data_present; // Example: Connect RX ready as interrupt source

    auto_baud_rate_control #(
        .C_FAMILY              ("7S"),
        .C_RAM_SIZE_KWORDS     (2),
        .C_JTAG_LOADER_ENABLE  (1)
    ) program_rom (
        .rdl            (rdl),          // rdl output connection remains
        .enable         (bram_enable),
        .address        (address),
        .instruction    (instruction),
        .clk            (dft_clk)       // Use DFT Muxed Clock
    );

    uart_tx6 tx (
        .data_in            (uart_tx_data_in),
        .en_16_x_baud       (en_16_x_baud),
        .serial_out         (uart_tx),
        .buffer_write       (write_to_uart_tx),
        .buffer_data_present(uart_tx_data_present),
        .buffer_half_full   (uart_tx_half_full),
        .buffer_full        (uart_tx_full),
        .buffer_reset       (uart_tx_reset),
        .clk                (dft_clk)       // Use DFT Muxed Clock
    );

    uart_rx6 rx (
        .serial_in          (uart_rx),
        .en_16_x_baud       (en_16_x_baud),
        .data_out           (uart_rx_data_out),
        .buffer_read        (read_from_uart_rx),
        .buffer_data_present(uart_rx_data_present), // Drives 'interrupt' signal
        .buffer_half_full   (uart_rx_half_full),
        .buffer_full        (uart_rx_full),
        .buffer_reset       (uart_rx_reset),
        .clk                (dft_clk)       // Use DFT Muxed Clock
    );

    // Baud rate generation logic - Uses DFT Muxed Clock
    // Added synchronous reset logic
    always @ (posedge dft_clk) begin
        if (dft_kcpsm6_reset) begin // Use processor reset for this block
             baud_rate_counter <= 5'b0;
             en_16_x_baud <= 1'b0;
        end else begin
             if (baud_rate_counter == set_baud_rate) begin
                 baud_rate_counter <= 5'b00000;
                 en_16_x_baud <= 1'b1;
             end else begin
                 baud_rate_counter <= baud_rate_counter + 5'b00001;
                 en_16_x_baud <= 1'b0;
             end
        end
    end

    // Input port mux logic - Uses DFT Muxed Clock
    // Added synchronous reset logic
    always @ (posedge dft_clk) begin
        if (dft_kcpsm6_reset) begin // Use processor reset for this block
            in_port <= 8'b0;
            read_from_uart_rx <= 1'b0;
        end else begin
            // Default assignment to avoid latches
            read_from_uart_rx <= 1'b0;
            in_port <= 8'bXXXXXXXX; // Default for unassigned cases

            case (port_id[1:0