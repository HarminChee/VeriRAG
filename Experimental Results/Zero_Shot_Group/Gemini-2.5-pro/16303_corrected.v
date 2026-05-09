module basys3_demo (
	input clk,          // System clock (e.g., 100MHz)
	output tx,         // UART TX
	input rx,          // UART RX
    input [15:0] sw,   // Switches
	output [15:0] led  // LEDs
);

    // Clock generation
    wire clk100;
    BUFG bufg100 (.I(clk), .O(clk100)); // Buffer for high-fanout 100MHz clock

    reg clk50_ce = 1'b0;
    always @(posedge clk100) begin
        clk50_ce <= !clk50_ce; // Toggle every clk100 cycle for 50MHz enable
    end

    wire clk50;
    // Corrected: Use clk100 as input for the gated buffer
    BUFGCE bufg50 (.I(clk100), .CE(clk50_ce), .O(clk50)); // Generate 50MHz clock

	// Reset generation (active low)
	reg [5:0] reset_cnt = 6'b0;
	wire resetn = (&reset_cnt); // resetn is high after counter reaches 63

	always @(posedge clk50) begin
		if (!resetn) begin // Increment counter only while in reset
			reset_cnt <= reset_cnt + 1'b1;
		end
	end

	// I/O Memory Interface signals for PicoSoC
	wire        iomem_valid; // PicoSoC asserts when accessing I/O memory
	reg         iomem_ready; // Peripheral asserts when ready for transaction
	wire [3:0]  iomem_wstrb; // Write strobes (byte enables)
	wire [31:0] iomem_addr;  // Address from PicoSoC
	wire [31:0] iomem_wdata; // Write data from PicoSoC
	reg  [31:0] iomem_rdata; // Read data to PicoSoC

	// GPIO Register and LED output
	reg [31:0] gpio;
	assign led = gpio[15:0]; // Connect lower 16 bits of GPIO to LEDs

	// GPIO Logic (Memory Mapped at 0x03xxxxxx)
	always @(posedge clk50) begin
		if (!resetn) begin // Reset condition
			gpio <= 32'b0;
			iomem_ready <= 1'b0;
			iomem_rdata <= 32'b0; // Optional: clear read data on reset
		end else begin
			// Default state: de-assert ready unless a valid transaction occurs this cycle
			iomem_ready <= 1'b0;

			// Check for valid I/O access to GPIO address range
			if (iomem_valid && iomem_addr[31:24] == 8'h03) begin
				iomem_ready <= 1'b1; // Acknowledge the transaction

				// Prepare read data (current switches and LED state)
                // Read happens before potential write in the same cycle
				iomem_rdata <= {sw, gpio[15:0]};

				// Handle writes based on byte strobes
				if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
				if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
			end
            // If iomem_valid is high but address doesn't match, ready remains low.
            // If iomem_valid is low, ready remains low.
		end
	end

	// Instantiate the PicoSoC core
	picosoc_noflash soc (
		.clk          (clk50),     // Use the generated 50MHz clock
		.resetn       (resetn),    // Use the generated active-low reset
		.ser_tx       (tx),        // UART TX
		.ser_rx       (rx),        // UART RX
		.irq_5        (1'b0),      // Unused IRQs
		.irq_6        (1'b0),
		.irq_7        (1'b0),
		.iomem_valid  (iomem_valid), // Connect I/O memory interface signals
		.iomem_ready  (iomem_ready),
		.iomem_wstrb  (iomem_wstrb),
		.iomem_addr   (iomem_addr),
		.iomem_wdata  (iomem_wdata),
		.iomem_rdata  (iomem_rdata)
	);

endmodule