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
    wire resetn = &reset_cnt;
    wire dft_resetn; // DFT reset signal
    assign dft_resetn = test_i ? rst_ni : resetn; // MUX for test reset

    // Reset counter logic - uses functional reset logic but clocked by DFT clock
    always @(posedge dft_clk100) begin
        // Use dft_resetn to hold counter during test reset assertion if needed,
        // or simply let it run. The original logic uses !resetn as enable.
        // For consistency during test, use dft_resetn.
        reset_cnt <= reset_cnt + !dft_resetn;
    end

    wire        iomem_valid;
    reg         iomem_ready;
    wire [3:0]  iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    reg  [31:0] iomem_rdata;
    reg [31:0] gpio;
    assign led = gpio[7:0];

    // GPIO and I/O memory logic - uses DFT clock and DFT reset
    always @(posedge dft_clk100) begin
        if (!dft_resetn) begin // Use DFT reset
            gpio <= 0;
            iomem_ready <= 0; // Reset ready signal as well
            iomem_rdata <= 0; // Reset read data
        end else begin
            iomem_ready <= 0; // Default value
            if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
                iomem_ready <= 1;
                // Read operation - Ensure SW input is properly handled during scan
                // Read data muxing happens combinationally based on current state
                iomem_rdata <= {gpio[31:24], sw, gpio[15:0]};
                // Write operation
                if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
                if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
                if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
            end else begin
                 // If not accessing GPIO, hold iomem_rdata or set to default?
                 // Setting to 0 if not read, might be safer for test.
                 iomem_rdata <= 32'b0;
            end
        end
    end

    // Instantiate PicoSoC - uses DFT clock and DFT reset
    picosoc_noflash soc (
        .clk          (dft_clk100), // Use DFT clock
        .resetn       (dft_resetn), // Use DFT reset
        .ser_tx       (tx),
        .ser_rx       (rx),
        .irq_5        (1'b0        ),
        .irq_6        (1'b0        ),
        .irq_7        (1'b0        ),
        .iomem_valid  (iomem_valid ),
        .iomem_ready  (iomem_ready ),
        .iomem_wstrb  (iomem_wstrb ),
        .iomem_addr   (iomem_addr  ),
        .iomem_wdata  (iomem_wdata ),
        .iomem_rdata  (iomem_rdata )
    );
endmodule