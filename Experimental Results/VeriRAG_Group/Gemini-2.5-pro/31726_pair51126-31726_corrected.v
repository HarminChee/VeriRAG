module top (
    input clk,
    input rst_n, // Added primary reset input
    input test_i, // Added test mode input
    output tx,
    input  rx,
    input  [15:0] sw,
    output [15:0] led
);
  wire clk_bufg;
  BUFG bufg (
      .I(clk),
      .O(clk_bufg)
  );

  // Removed internally generated reset logic:
  // reg [5:0] reset_cnt = 0;
  // wire resetn = &reset_cnt;
  // always @(posedge clk_bufg) begin
  //   reset_cnt <= reset_cnt + !resetn;
  // end

  // Use primary reset directly
  wire dft_clk;
  wire dft_rst_n;

  // Mux clock and reset for test mode (optional for clock if BUFG is considered transparent, but good practice)
  assign dft_clk = test_i ? clk : clk_bufg; // Use primary clk in test mode
  assign dft_rst_n = rst_n; // Use primary reset in both modes

  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  always @(posedge dft_clk) begin // Use DFT clock
    // Use synchronous reset based on primary reset input
    if (!dft_rst_n) begin
      gpio <= 32'b0;
      iomem_ready <= 1'b0; // Reset ready signal
      iomem_rdata <= 32'b0; // Reset read data
    end else begin
      // Default assignments moved inside else for clarity after reset
      iomem_ready <= 1'b0;
      // Keep iomem_rdata unless updated

      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1;
        iomem_rdata <= {sw, gpio[15:0]}; // Read operation combines switch inputs and lower GPIO bits
        // Write operations based on write strobe
        if (iomem_wstrb[0]) gpio[7:0]   <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8]  <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
      // If not valid/ready/correct address, iomem_ready remains 0 from default assignment
    end
  end

  picosoc_noflash soc (
      .clk   (dft_clk),    // Use DFT clock
      .resetn(dft_rst_n),  // Use DFT reset
      .ser_tx(tx),
      .ser_rx(rx),
      .irq_5(1'b0),
      .irq_6(1'b0),
      .irq_7(1'b0),
      .iomem_valid(iomem_valid),
      .iomem_ready(iomem_ready),
      .iomem_wstrb(iomem_wstrb),
      .iomem_addr (iomem_addr),
      .iomem_wdata(iomem_wdata),
      .iomem_rdata(iomem_rdata)
  );
endmodule