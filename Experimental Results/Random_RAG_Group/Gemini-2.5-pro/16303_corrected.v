module basys3_demo (
	input clk,
	input rst_n_i, // Added primary reset input for DFT
	input test_i,  // Added test mode input for DFT
	output tx,
	input rx,
    input [15:0] sw,
	output [15:0] led
);
    wire clk100;
    BUFG bufg100 (.I(clk), .O(clk100));
    reg clk50_ce;
    // This FF is clocked by clk100 (derived from primary clk), which is acceptable.
    always @(posedge clk100)
        clk50_ce <= !clk50_ce;
    wire clk50;
    // BUFGCE generates clk50 based on clk (primary) and clk50_ce (internal FF).
    // clk50 is an internally generated clock, causing CLKNPI for downstream FFs.
    BUFGCE bufg50 (.I(clk), .CE(clk50_ce), .O(clk50));

    // DFT Mux for clock: Use primary 'clk' during test mode.
    wire dft_clk;
    assign dft_clk = test_i ? clk : clk50;

	reg [5:0] reset_cnt = 0;
	wire resetn = &reset_cnt; // Internal reset signal

    // DFT Mux for reset: Use primary 'rst_n_i' during test mode.
    wire dft_resetn;
    assign dft_resetn = test_i ? rst_n_i : resetn;

    // This FF uses the internally generated reset 'resetn' during functional mode.
    // During test mode, it uses the primary 'rst_n_i' via 'dft_resetn'.
    // It is clocked by 'dft_clk' which is 'clk' during test mode.
	always @(posedge dft_clk or negedge dft_resetn) begin // Use muxed clock and synchronous muxed reset
		if (!dft_resetn) begin
			reset_cnt <= 0;
		end else begin
			// Functional logic: counter stops when full.
			// Note: Using 'resetn' (derived from reset_cnt) in the update logic is complex,
			// but the DFT rule violation (ACNCPI/CLKNPI) is addressed by using dft_clk/dft_resetn.
			reset_cnt <= reset_cnt + !resetn;
		end
	end

	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata; // Should ideally be assigned combinationally
	reg [31:0] gpio;
	assign led = gpio[15:0];

    // These FFs (gpio, iomem_ready) use the internally generated reset 'resetn' during functional mode.
    // During test mode, they use the primary 'rst_n_i' via 'dft_resetn'.
    // They are clocked by 'dft_clk' which is 'clk' during test mode.
	always @(posedge dft_clk or negedge dft_resetn) begin // Use muxed clock and synchronous muxed reset
		if (!dft_resetn) begin
			gpio <= 0;
			iomem_ready <= 0; // Reset state registers
		end else begin
			// Functional logic
			iomem_ready <= 0; // Default assignment
			if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
				iomem_ready <= 1;
				// Assigning iomem_rdata here is synchronous, depends on prior gpio/sw state.
				iomem_rdata <= {sw, gpio[15:0]};
				if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
				if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
			end
		end
	end

	picosoc_noflash soc (
		.clk          (dft_clk),    // Use muxed clock for DFT compliance
		.resetn       (dft_resetn), // Use muxed reset for DFT compliance
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