module uart6_kc705_corrected_clk (
    input   uart_rx,
    output  uart_tx,
    input   clk200_p,
    input   clk200_n,
    input   test_mode // Added test_mode input for DFT
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
wire        en_16_x_baud_functional; // Internal signal for functional enable

// Clock frequency constant
assign clock_frequency_in_MHz = 8'd200;

// Differential clock buffer
IBUFGDS diff_clk_buffer(
    .I(clk200_p),
    .IB(clk200_n),
    .O(clk200));

// Clock buffer/divider (assuming BUFG is just buffering here)
BUFG clock_divide (
    .I(clk200),
    .O(clk));

// KCPSM6 Processor Instantiation
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
    .reset(kcpsm6_reset),
    .sleep(kcpsm6_sleep),
    .clk(clk)
);

// Processor reset and sleep logic
assign kcpsm6_reset = rdl;
assign kcpsm6_sleep = write_strobe && k_write_strobe;
assign interrupt = interrupt_ack; // Simple loopback for interrupt acknowledge

// Program ROM Instantiation
auto_baud_rate_control #(
    .C_FAMILY("7S"),
    .C_RAM_SIZE_KWORDS(2),
    .C_JTAG_LOADER_ENABLE(1)
) program_rom (
    .rdl(rdl),
    .enable(bram_enable),
    .address(address),
    .instruction(instruction),
    .clk(clk)
);

// UART TX Instantiation
uart_tx6 tx (
    .data_in(uart_tx_data_in),
    .en_16_x_baud(en_16_x_baud), // Use DFT-controlled enable
    .serial_out(uart_tx),
    .buffer_write(write_to_uart_tx),
    .buffer_data_present(uart_tx_data_present),
    .buffer_half_full(uart_tx_half_full),
    .buffer_full(uart_tx_full),
    .buffer_reset(uart_tx_reset),
    .clk(clk)
);

// UART RX Instantiation
uart_rx6 rx (
    .serial_in(uart_rx),
    .en_16_x_baud(en_16_x_baud), // Use DFT-controlled enable
    .data_out(uart_rx_data_out),
    .buffer_read(read_from_uart_rx),
    .buffer_data_present(uart_rx_data_present),
    .buffer_half_full(uart_rx_half_full),
    .buffer_full(uart_rx_full),
    .buffer_reset(uart_rx_reset),
    .clk(clk)
);

// Baud rate generation logic (functional part)
assign en_16_x_baud_functional = (baud_rate_counter == set_baud_rate);

always @(posedge clk) begin
    if (baud_rate_counter == set_baud_rate) begin
        baud_rate_counter <= 8'b0; // Use 8 bits consistently if set_baud_rate is 8 bits
    end else begin
        baud_rate_counter <= baud_rate_counter + 8'b1;
    end
end

// Control en_16_x_baud based on test_mode
// During test mode (test_mode=1), force en_16_x_baud high to bypass functional generation.
// During functional mode (test_mode=0), use the generated signal.
always @(posedge clk) begin
    if (test_mode) begin
        en_16_x_baud <= 1'b1; // Force enable high during test
    end else begin
        en_16_x_baud <= en_16_x_baud_functional; // Use functional enable
    end
end


// Input Port Logic
always @(posedge clk) begin
    case (port_id[1:0])
        2'b00: in_port <= { 2'b00,
                           uart_rx_full,
                           uart_rx_half_full,
                           uart_rx_data_present,
                           uart_tx_full,
                           uart_tx_half_full,
                           uart_tx_data_present };
        2'b01: in_port <= uart_rx_data_out;
        2'b10: in_port <= clock_frequency_in_MHz;
        default: in_port <= 8'bXXXXXXXX;
    endcase

    // UART RX Read Control
    if ((read_strobe == 1'b1) && (port_id[1:0] == 2'b01)) begin
        read_from_uart_rx <= 1'b1;
    end else begin
        read_from_uart_rx <= 1'b0;
    end
end

// Output Port Logic and Baud Rate Setting
always @(posedge clk) begin
    // Set Baud Rate Register
    if (write_strobe == 1'b1) begin
        if (port_id[1] == 1'b1) begin // Assuming port_id[1]=1 selects baud rate setting
            set_baud_rate <= out_port;
        end
    end
    // Pipelining port_id[0] for UART TX write strobe generation
    pipe_port_id0 <= port_id[0];
end

// UART TX Write Logic
assign uart_tx_data_in = out_port;
assign write_to_uart_tx = write_strobe & pipe_port_id0; // Write occurs if write_strobe is active and LSB of port_id was 1 in previous cycle

// UART Reset Logic
always @(posedge clk) begin
    if (k_write_strobe == 1'b1) begin // Assuming k_write_strobe is for control registers
        if (port_id[0] == 1'b1) begin // Assuming port_id[0]=1 selects reset control
            uart_tx_reset <= out_port[0];
            uart_rx_reset <= out_port[1];
        end
    end
end

endmodule