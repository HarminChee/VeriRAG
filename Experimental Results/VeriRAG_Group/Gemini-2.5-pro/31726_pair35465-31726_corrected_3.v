module top (
    input clk,
    output tx,
    input  rx,
    input  [15:0] sw,
    output [15:0] led,
    input rst_n_i,    // Primary asynchronous reset input (active low)
    input test_mode_i // Test mode control input (can be used for scan enable etc.)
);
  wire clk_bufg;
  // BUFG instantiation - Assumes BUFG is defined (e.g., primitive)
  BUFG bufg (
      .I(clk),
      .O(clk_bufg)
  );

  // --- Reset Synchronization ---
  // Synchronize the asynchronous reset to the clock domain
  reg rst_sync1_n, rst_sync2_n;
  wire sync_reset_n; // Synchronous, active-low reset signal

  always @(posedge clk_bufg or negedge rst_n_i) begin // Asynchronous reset for synchronizer FFs
    if (!rst_n_i) begin
      rst_sync1_n <= 1'b0;
      rst_sync2_n <= 1'b0;
    end else begin
      rst_sync1_n <= 1'b1;       // De-assert asynchronously, capture synchronously
      rst_sync2_n <= rst_sync1_n; // Pass synchronized value
    end
  end
  assign sync_reset_n = rst_sync2_n; // Use the second stage output as the synchronous reset

  // --- Internal Counter (Example: Generate enable after reset) ---
  // This counter is reset by the main synchronous reset.
  // Its purpose might be functional, e.g., delay enable after reset.
  reg [5:0] reset_cnt = 6'b0;
  reg functional_enable = 1'b0; // Example signal derived from counter

  always @(posedge clk_bufg) begin
    if (!sync_reset_n) begin // Use the synchronized reset (active low)
        reset_cnt <= 6'b0;
        functional_enable <= 1'b0; // Disable during reset
    end else begin
        // Example counter logic: enable after counting to max
        if (&reset_cnt) begin // If counter reached max (6'b111111)
            functional_enable <= 1'b1; // Enable functionality
            // Keep reset_cnt at max (hold value)
        end else begin
            reset_cnt <= reset_cnt + 1'b1; // Increment counter
            functional_enable <= 1'b0; // Remain disabled until counter is full
        end
    end
  end

  // --- I/O Memory Interface Logic ---
  wire        iomem_valid; // From picosoc
  reg         iomem_ready; // To picosoc
  wire [ 3:0] iomem_wstrb; // From picosoc
  wire [31:0] iomem_addr;  // From picosoc
  wire [31:0] iomem_wdata; // From picosoc
  reg  [31:0] iomem_rdata; // To picosoc
  reg  [31:0] gpio;        // Internal GPIO register
  assign led = gpio[15:0]; // Output LEDs from GPIO reg

  // GPIO and I/O memory logic block - uses synchronous reset
  always @(posedge clk_bufg) begin
    // Synchronous reset using the synchronized primary reset
    if (!sync_reset_n) begin // active low synchronous reset
      gpio        <= 32'b0;
      iomem_ready <= 1'b0;
      iomem_rdata <= 32'b0;
    end else begin
      // Default assignments to hold values unless updated
      iomem_ready <= 1'b0;
      // iomem_rdata <= iomem_rdata; // Implicit hold if not assigned below
      // gpio        <= gpio;        // Implicit hold if not assigned below

      // Functional logic: Respond to picosoc I/O requests
      // Consider gating with 'functional_enable' if needed: if (functional_enable && iomem_valid ...)
      if (iomem_valid && iomem_addr[31:24] == 8'h03) begin // Check valid and address range
        iomem_ready <= 1'b1; // Signal ready to picosoc
        // Read operation: Provide switch values to picosoc
        iomem_rdata <= {16'b0, sw}; // Read SW inputs into lower 16 bits
        // Write operation: Update GPIO register based on write strobes
        if (iomem_wstrb[0]) gpio[7:0]   <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8]  <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end else begin
        // If not a valid I/O access for this block, ensure read data is defined (e.g., zero or hold)
        // If iomem_rdata should be driven zero when not accessed:
        // iomem_rdata <= 32'b0;
        // Otherwise, it holds its value (implicit above)
      end
    end
  end

  // --- Sub-module instantiation ---
  // Assumes picosoc_noflash module is defined elsewhere
  // Uses DFT-friendly clock (clk_bufg) and synchronous reset (sync_reset_n)
  picosoc_noflash soc (
      .clk   (clk_bufg),        // Clock input
      .resetn(sync_reset_n),    // Synchronous Reset input (active low)
      .ser_tx(tx),              // Serial TX output
      .ser_rx(rx),              // Serial RX input
      .irq_5(1'b0),             // IRQ input (tied low)
      .irq_6(1'b0),             // IRQ input (tied low)
      .irq_7(1'b0),             // IRQ input (tied low)
      // I/O Memory Interface
      .iomem_valid(iomem_valid), // Output: Request valid
      .iomem_ready(iomem_ready), // Input: Peripheral ready
      .iomem_wstrb(iomem_wstrb), // Output: Write strobes
      .iomem_addr (iomem_addr),  // Output: Address
      .iomem_wdata(iomem_wdata), // Output: Write data
      .iomem_rdata(iomem_rdata)  // Input: Read data
  );

endmodule