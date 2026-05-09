module nexys_video_demo (
    input clk,
    input rst_n_i, // Added primary reset input
    input test_i,  // Added test mode input
    output tx,
    input rx,
    input [7:0] sw,
    output [7:0] led
);
    wire clk100;
    BUFG bufg100 (.I(clk), .O(clk100));
    reg [5:0] reset_cnt = 0;
    wire internal_resetn = &reset_cnt; // Renamed original reset
    wire dft_resetn; // Muxed reset signal for DFT

    // Select primary reset in test mode, internal reset otherwise
    assign dft_resetn = test_i ? rst_n_i : internal_resetn;

    // Internal reset counter logic (remains for functional mode)
    always @(posedge clk100) begin
        reset_cnt <= reset_cnt + !internal_resetn;
    end

    wire        iomem_valid;
    reg         iomem_ready;
    wire [3:0]  iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    reg  [31:0] iomem_rdata;
    reg [31:0] gpio;
    assign led = gpio[7:0];

    // Use the DFT-friendly reset signal 'dft_resetn'
    always @(posedge clk100 or negedge dft_resetn) begin // Changed sensitivity list
        if (!dft_resetn) begin // Changed reset condition check
            gpio <= 0;
            iomem_ready <= 0; // Ensure ready is reset too
            iomem_rdata <= 0; // Ensure rdata is reset too
        end else begin
            iomem_ready <= 0; // Default assignment
            if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
                iomem_ready <= 1;
                iomem_rdata <= {gpio[31:24], sw, gpio[15:0]};
                if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
                if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
                if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
            end
        end
    end

    picosoc_noflash soc (
        .clk          (clk100),
        .resetn       (dft_resetn      ), // Connect DFT-friendly reset
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