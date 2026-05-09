module nexys_video_demo_corrected_clk (
    input clk,
    input test_clk,    // DFT Test Clock Input
    input test_mode,   // DFT Test Mode Enable
    input test_resetn, // DFT Test Reset Input (active low)
    output tx,
    input rx,
    input [7:0] sw,
    output [7:0] led
);
    wire clk100;
    BUFG bufg100 (.I(clk), .O(clk100));

    // DFT Clock Mux
    wire dft_clk;
    // Select test_clk in test_mode, otherwise use functional clock clk100
    assign dft_clk = test_mode ? test_clk : clk100;

    // Functional Reset Generation (Power-on Reset Counter)
    reg [5:0] reset_cnt = 0;
    wire func_resetn = &reset_cnt;

    // The reset counter should run on the functional clock unless it needs DFT control itself.
    // Assuming it's part of the power-on sequence and not directly part of scan chain logic.
    always @(posedge clk100) begin
        // Stop counting once reset is deasserted (all 1s)
        if (reset_cnt != 6'b111111) begin
             reset_cnt <= reset_cnt + 1;
        end
    end

    // DFT Reset Mux
    wire dft_resetn;
    // Select test_resetn in test_mode, otherwise use functional reset func_resetn
    assign dft_resetn = test_mode ? test_resetn : func_resetn;


    wire        iomem_valid;
    reg         iomem_ready;
    wire [3:0]  iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    reg  [31:0] iomem_rdata;

    reg [31:0] gpio;
    assign led = gpio[7:0];

    // GPIO and I/O Memory Interface Logic using DFT clock and reset
    always @(posedge dft_clk) begin
        if (!dft_resetn) begin // Use DFT reset
            gpio <= 32'b0;
            iomem_ready <= 1'b0; // Ensure ready signal is reset
            iomem_rdata <= 32'b0; // Ensure read data is reset
        end else begin
            // Default assignments
            iomem_ready <= 1'b0;

            // I/O Memory Access Logic
            if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
                iomem_ready <= 1'b1;
                // Read operation: Provide GPIO/SW state
                iomem_rdata <= {gpio[31:24], sw, gpio[15:0]};

                // Write operation: Update GPIO based on write strobe
                if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
                if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
                if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
            end else begin
                 // If not accessing the GPIO memory region, ensure read data is stable or zero
                 // Depending on spec, maybe keep previous value or set to 0. Setting to 0 is safer.
                 // iomem_rdata <= 32'b0; // Or keep previous value if needed
            end
        end
    end

    // Instantiate the PicoSoC core with DFT clock and reset
    picosoc_noflash soc (
        .clk          (dft_clk),     // Use DFT clock
        .resetn       (dft_resetn),  // Use DFT reset
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