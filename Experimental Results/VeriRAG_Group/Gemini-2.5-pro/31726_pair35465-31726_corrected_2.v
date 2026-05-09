module top (
    input clk,
    output tx,
    input  rx,
    input  [15:0] sw,
    output [15:0] led,
    input rst_n_i,    // Primary asynchronous reset input
    input test_mode_i // Test mode control input
);
  wire clk_bufg;
  // BUFG instantiation - Assumes BUFG is defined (e.g., primitive)
  BUFG bufg (
      .I(clk),
      .O(clk_bufg)
  );

  // Internal reset generation (functional mode)
  reg [5:0] reset_cnt = 6'b0; // Explicit initial value
  wire resetn = &reset_cnt; // Functional reset signal (active low when counter is full)

  // DFT reset selection logic
  wire dft_resetn;
  assign dft_resetn = test_mode_i ? rst_n_i : resetn; // Select primary reset in test mode

  // Internal reset counter logic (generates functional reset) - Now includes DFT reset
  always @(posedge clk_bufg) begin
    if (!dft_resetn) begin // Reset the counter using the DFT reset (active low)
        reset_cnt <= 6'b0;
    end else begin
        // Increment counter only if it's not already full (resetn is low when not full)
        if (!resetn) begin // equivalent to: if (reset_cnt != 6'b111111)
            reset_cnt <= reset_cnt + 1'b1;
        end
        // else: hold value when full (resetn is high)
    end
  end

  // I/O Memory Interface Logic
  wire        iomem_valid; // From picosoc
  reg         iomem_ready; // To picosoc
  wire [ 3:0] iomem_wstrb; // From picosoc
  wire [31:0] iomem_addr;  // From picosoc
  wire [31:0] iomem_wdata; // From picosoc
  reg  [31:0] iomem_rdata; // To picosoc
  reg  [31:0] gpio;        // Internal GPIO register
  assign led = gpio[15:0]; // Output LEDs from GPIO reg

  // GPIO and I/O memory logic block - uses DFT reset
  always @(posedge clk_bufg) begin
    // Synchronous reset using the selected reset signal
    if (!dft_resetn) begin // active low reset
      gpio        <= 32'b0;
      iomem_ready <= 1'b0;
      iomem_rdata <= 32'b0; // Reset read data register
    end else begin
      // Default assignments
      iomem_ready <= 1'b0;
      // Functional logic: Respond to picosoc I/O requests
      if (iomem_valid && iomem_addr[31:24] == 8'h03) begin // Check valid and address range
        iomem_ready <= 1'b1; // Signal ready to picosoc
        // Read operation: Provide switch values to picosoc
        iomem_rdata <= {16'b0, sw}; // Read SW inputs into lower 16 bits
        // Write operation: Update GPIO register based on write strobes
        if (iomem_wstrb[0]) gpio[7:0]   <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8]  <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
      // If not valid or address doesn't match, iomem_ready remains 0 (from default)
      // and gpio/iomem_rdata retain their values from the previous cycle (or reset).
    end
  end

  // Sub-module instantiation - assumes picosoc_noflash module is defined elsewhere
  // Uses DFT-friendly clock (clk_bufg) and reset (dft_resetn)
  picosoc_noflash soc (
      .clk   (clk_bufg),    // Clock input
      .resetn(dft_resetn),  // Reset input (active low)
      .ser_tx(tx),          // Serial TX output
      .ser_rx(rx),          // Serial RX input
      .irq_5(1'b0),         // IRQ input (tied low)
      .irq_6(1'b0),         // IRQ input (tied low)
      .irq_7(1'b0),         // IRQ input (tied low)
      // I/O Memory Interface
      .iomem_valid(iomem_valid), // Output: Request valid
      .iomem_ready(iomem_ready), // Input: Peripheral ready
      .iomem_wstrb(iomem_wstrb), // Output: Write strobes
      .iomem_addr (iomem_addr),  // Output: Address
      .iomem_wdata(iomem_wdata), // Output: Write data
      .iomem_rdata(iomem_rdata)  // Input: Read data
  );

endmodule