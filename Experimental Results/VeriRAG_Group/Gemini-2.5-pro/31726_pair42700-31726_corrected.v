module top (
    input clk,
    // No primary rst_n needed if internal reset is kept
    output tx,
    input  rx,
    input  [15:0] sw,
    output [15:0] led,
    input wire test_i,      // DFT control
    input wire scan_clk,     // DFT clock
    input wire scan_rst_n    // DFT reset (active low assumed)
);
  wire clk_bufg;
  BUFG bufg (
      .I(clk),
      .O(clk_bufg)
  );

  // DFT Muxing for Clock
  wire dft_clk;
  assign dft_clk = test_i ? scan_clk : clk_bufg;

  // Internal Reset Generation Logic (Modified for DFT)
  reg [5:0] reset_cnt = 0;
  wire resetn_internal = &reset_cnt; // Functional reset signal

  // Muxed Reset for controlling the counter itself
  wire dft_resetn_for_counter;
  assign dft_resetn_for_counter = test_i ? scan_rst_n : resetn_internal; // Use scan reset in test mode

  // Counter logic using DFT clock and controlled by muxed reset
  // Note: This assumes reset_cnt is part of the scan chain
  always @(posedge dft_clk) begin
     // Use synchronous reset based on the muxed signal
     if (!dft_resetn_for_counter) begin
         reset_cnt <= 6'b0;
     end else begin
         // Functional count logic: count until full
         // Original logic: reset_cnt <= reset_cnt + !resetn;
         // Corrected logic uses the signal derived from the register's previous state
         reset_cnt <= reset_cnt + !resetn_internal;
     end
  end

  // Muxed Reset for controlling other logic (GPIO, etc.)
  wire dft_resetn_external;
  assign dft_resetn_external = test_i ? scan_rst_n : resetn_internal;

  // GPIO and IO Mem Interface Logic
  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  // Note: This assumes gpio, iomem_ready, iomem_rdata are part of the scan chain
  always @(posedge dft_clk) begin // Use DFT clock
    if (!dft_resetn_external) begin // Use muxed external reset
      gpio <= 32'b0;
      iomem_ready <= 1'b0;
      iomem_rdata <= 32'b0;
    end else begin
      iomem_ready <= 1'b0; // Default to not ready
      // Check for valid IO access to GPIO region
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1; // Assert ready for one cycle
        // Prepare read data (combinational read of sw + gpio lower bits)
        iomem_rdata <= {sw, gpio[15:0]};
        // Handle writes based on strobes
        if (iomem_wstrb[0]) gpio[7:0]   <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8]  <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      // If not valid/ready/addr match, registers hold values (except iomem_ready which defaults low)
      end
      // else begin
      //   // If no transaction this cycle, gpio and iomem_rdata hold their values.
      //   // iomem_ready is already set to 0 at the start of the 'else' block.
      // end
    end
  end

  // Instantiate picosoc_noflash with DFT signals
  // Pass the DFT-muxed clock and reset to the subsystem
  picosoc_noflash soc (
      .clk   (dft_clk),             // Pass DFT clock
      .resetn(dft_resetn_external), // Pass DFT reset
      .ser_tx(tx),
      .ser_rx(rx),
      .irq_5(1'b0),
      .irq_6(1'b0),
      .irq_7(1'b0),
      .iomem_valid(iomem_valid), // Output from soc
      .iomem_ready(iomem_ready), // Input to soc (driven by logic above)
      .iomem_wstrb(iomem_wstrb), // Output from soc
      .iomem_addr (iomem_addr),  // Output from soc
      .iomem_wdata(iomem_wdata), // Output from soc
      .iomem_rdata(iomem_rdata)  // Input to soc (driven by logic above)
  );
endmodule