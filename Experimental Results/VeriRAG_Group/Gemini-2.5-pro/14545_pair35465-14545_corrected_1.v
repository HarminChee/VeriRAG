module nexys_video_demo (
    input clk,
    output tx,
    input rx,
    input [7:0] sw,
    output [7:0] led,
    input test_i, // Added test mode input
    input rst_ni  // Added test reset input (active low)
);
    wire clk100;
    wire dft_clk100; // DFT clock signal
    BUFG bufg100 (.I(clk), .O(clk100));
    assign dft_clk100 = test_i ? clk : clk100; // MUX for test clock

    reg [5:0] reset_cnt = 0;
    wire resetn = &reset_cnt; // resetn goes high when reset_cnt reaches 6'b111111
    wire dft_resetn; // DFT reset signal
    assign dft_resetn = test_i ? rst_ni : resetn; // MUX for test reset

    // Reset counter logic - counts up when reset is inactive (high)
    // Stops counting when reset_cnt reaches max value (6'b111111)
    always @(posedge dft_clk100) begin
        if (!dft_resetn) begin // Reset counter when dft_resetn is low
            reset_cnt <= 6'b0;
        end else begin
             // Increment only if not already at max value
            if (~(&reset_cnt)) begin
                 reset_cnt <= reset_cnt + 1'b1;
            end
        end
    end

    wire        iomem_valid; // From soc
    reg         iomem_ready; // To soc
    wire [3:0]  iomem_wstrb; // From soc
    wire [31:0] iomem_addr;  // From soc
    wire [31:0] iomem_wdata; // From soc
    reg  [31:0] iomem_rdata; // To soc

    reg [31:0] gpio;
    assign led = gpio[7:0];

    // GPIO and I/O memory logic - uses DFT clock and DFT reset
    // This block acts as a memory-mapped peripheral for the PicoSoC
    always @(posedge dft_clk100) begin
        if (!dft_resetn) begin // Use DFT reset (active low)
            gpio <= 32'b0;
            iomem_ready <= 1'b0;
            iomem_rdata <= 32'b0;
        end else begin
            // Default assignments for next cycle
            iomem_ready <= 1'b0; // Default ready to low, assert high only when transaction occurs

            // Check for valid request to the GPIO address space (0x03xxxxxx)
            if (iomem_valid && iomem_addr[31:24] == 8'h03) begin
                iomem_ready <= 1'b1; // Acknowledge the transaction this cycle

                if (|iomem_wstrb) begin // Write operation
                    if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
                    if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
                    if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                    if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
                    iomem_rdata <= 32'b0; // Read data is not valid during write
                end else begin // Read operation
                    // Present read data on the bus: {gpio_upper, sw_input, gpio_lower}
                    iomem_rdata <= {gpio[31:24], sw, gpio[15:0]};
                end
            end else begin
                // No valid transaction targeting GPIO this cycle
                iomem_rdata <= 32'b0; // Set read data to 0 when not actively reading GPIO
                // iomem_ready remains low (set by default assignment above)
            end
        end
    end

    // Instantiate PicoSoC - uses DFT clock and DFT reset
    // Assumes picosoc_noflash module exists and port directions match connections.
    picosoc_noflash soc (
        .clk          (dft_clk100), // Use DFT clock
        .resetn       (dft_resetn), // Use DFT reset
        .ser_tx       (tx),
        .ser_rx       (rx),
        .irq_5        (1'b0        ),
        .irq_6        (1'b0        ),
        .irq_7        (1'b0        ),
        .iomem_valid  (iomem_valid ), // Output from soc
        .iomem_ready  (iomem_ready ), // Input to soc
        .iomem_wstrb  (iomem_wstrb ), // Output from soc
        .iomem_addr   (iomem_addr  ), // Output from soc
        .iomem_wdata  (iomem_wdata ), // Output from soc
        .iomem_rdata  (iomem_rdata )  // Input to soc
    );
endmodule