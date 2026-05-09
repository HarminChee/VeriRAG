module basys3_demo_corrected_clk (
	input clk,
	input test_mode, // Added test_mode input for DFT
	output tx,
	input rx,
    input [15:0] sw,
	output [15:0] led
);
    wire clk100;
    // Use a clock buffer for the primary clock
    BUFG bufg100 (.I(clk), .O(clk100));

    // Functional clock generation logic (divider)
    reg clk50_ce_reg; // Register to generate clock enable for clk50
    // This flop is clocked by clk100 (derived from primary input), which is acceptable
    always @(posedge clk100)
        clk50_ce_reg <= !clk50_ce_reg;

    wire clk50_func; // Functional clock (potentially gated/divided)
    // BUFGCE generates a clock based on clk and the enable signal.
    // This clk50_func is considered internally generated and problematic for DFT if used directly.
    BUFGCE bufg50 (.I(clk), .CE(clk50_ce_reg), .O(clk50_func));

    // DFT Clock Selection Logic
    // Select clk100 (derived from primary input) during test_mode (scan)
    // Select clk50_func (internally generated) during functional mode
    wire dft_clk;
    assign dft_clk = test_mode ? clk100 : clk50_func;

	reg [5:0] reset_cnt = 6'b0; // Initialize reset counter
	// Reset generation logic - ensure reset is synchronous to the selected clock
	// Note: For robust DFT, an asynchronous test reset (test_reset_n) is often preferred.
	// Here, we keep the synchronous reset derived from the counter, clocked by dft_clk.
	wire resetn;
	assign resetn = (reset_cnt == 6'h3F); // Reset active low after counter reaches max

	always @(posedge dft_clk) begin
		if (!resetn) // Keep counting until resetn goes high
		    reset_cnt <= reset_cnt + 6'b1;
        // else // Optionally hold counter value after reset is released
            // reset_cnt <= reset_cnt;
	end

	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	reg [31:0] gpio;
	assign led = gpio[15:0];

	// Main GPIO and I/O memory interface logic
	// All flip-flops here are clocked by dft_clk
	always @(posedge dft_clk) begin
		if (!resetn) begin // Synchronous reset condition
			gpio <= 32'b0;
			iomem_ready <= 1'b0;
            iomem_rdata <= 32'b0;
		end else begin
			// Default state for ready signal
			iomem_ready <= 1'b0;
			// Handle I/O memory access
			if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
				iomem_ready <= 1'b1; // Signal ready for this cycle
				// Read operation: Combine switch inputs and lower GPIO bits
				iomem_rdata <= {sw, gpio[15:0]};
				// Write operation based on write strobe
				if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
				if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
			end
            // Note: iomem_rdata retains its value if not read in the specific address range.
            // If a default value is needed when not accessed, add an 'else' condition for iomem_rdata.
		end
	end

	// Instantiate the PicoSoC core
	// Ensure the core is clocked by the DFT-friendly clock (dft_clk)
	// and reset by the synchronous reset (resetn)
	picosoc_noflash soc (
		.clk          (dft_clk),     // Use the multiplexed DFT clock
		.resetn       (resetn      ), // Use the synchronous reset
		.ser_tx       (tx),
		.ser_rx       (rx),
		.irq_5        (1'b0        ),
		.irq_6        (1'b0        ),
		.irq_7        (1'b0        ),
		.iomem_valid  (iomem_valid ),
		.iomem_ready  (iomem_ready ), // Driven by the always block above
		.iomem_wstrb  (iomem_wstrb ),
		.iomem_addr   (iomem_addr  ),
		.iomem_wdata  (iomem_wdata ),
		.iomem_rdata  (iomem_rdata )  // Driven by the always block above
	);
endmodule