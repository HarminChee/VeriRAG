module nexys_video_demo (
    input clk,
    output tx,
    input rx,
    input [7:0] sw,
    output [7:0] led
);
    wire clk100;
    // Use BUFGCE or MMCM/PLL for better clock management if available and needed,
    // but BUFG is okay for basic buffering.
    BUFG bufg100 (.I(clk), .O(clk100));

    // Reset generation (holds resetn low for 64 cycles)
    reg [5:0] reset_cnt = 6'd0;
    wire resetn;
    assign resetn = (reset_cnt == 6'h3F); // Assert resetn (high) only when counter reaches max

    always @(posedge clk100) begin
        if (!resetn) begin // Increment counter only while reset is active (low)
            reset_cnt <= reset_cnt + 1'b1;
        end
        // else: counter holds its max value (6'h3F)
    end

    // PicoSoC IOMEM Interface Signals
    wire        iomem_valid;
    reg         iomem_ready;
    wire [3:0]  iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    reg  [31:0] iomem_rdata;

    // GPIO Register and LED Output
    reg [31:0] gpio;
    assign led = gpio[7:0];

    // GPIO Memory-Mapped Register Logic
    always @(posedge clk100) begin
        if (!resetn) begin
            gpio <= 32'b0;
            iomem_ready <= 1'b0;
            iomem_rdata <= 32'b0;
        end else begin
            // Default: de-assert ready unless a transaction is accepted this cycle
            iomem_ready <= 1'b0;

            // Check for valid transaction targeting the GPIO address space (0x03xxxxxx)
            if (iomem_valid && iomem_addr[31:24] == 8'h03) begin
                // Acknowledge the transaction this cycle
                iomem_ready <= 1'b1;

                // Handle Write Operation (if any write strobe is active)
                // Use non-blocking assignments for registers
                if (|iomem_wstrb) begin // Check if any bit in wstrb is high
                    if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
                    if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
                    if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                    if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
                end

                // Handle Read Operation (Assume read if wstrb is all zeros)
                // Provide read data combination: gpio high bytes, switches, gpio low bytes
                // Use non-blocking assignment for the registered read data output
                if (iomem_wstrb == 4'b0000) begin
                   iomem_rdata <= {gpio[31:24], sw, gpio[15:0]};
                end
                // If it's a write operation, iomem_rdata retains its previous value
                // because it's a reg and only updated conditionally on read.
            end
            // If not valid or wrong address, iomem_ready remains low (from default above)
            // and iomem_rdata retains its value.
        end
    end

    // Instantiate the PicoSoC core
    // Ensure the 'picosoc_noflash' module definition exists elsewhere in the project.
    picosoc_noflash soc (
        .clk          (clk100),
        .resetn       (resetn      ), // Active high reset input to SoC

        // UART Interface
        .ser_tx       (tx),
        .ser_rx       (rx),

        // Unused Interrupts (tied low)
        .irq_5        (1'b0        ),
        .irq_6        (1'b0        ),
        .irq_7        (1'b0        ),

        // IOMEM Interface (connecting to GPIO logic above)
        .iomem_valid  (iomem_valid ), // Output from SoC: Transaction valid
        .iomem_ready  (iomem_ready ), // Input to SoC: Peripheral ready
        .iomem_wstrb  (iomem_wstrb ), // Output from SoC: Write strobes
        .iomem_addr   (iomem_addr  ), // Output from SoC: Address
        .iomem_wdata  (iomem_wdata ), // Output from SoC: Write data
        .iomem_rdata  (iomem_rdata )  // Input to SoC: Read data
    );

endmodule