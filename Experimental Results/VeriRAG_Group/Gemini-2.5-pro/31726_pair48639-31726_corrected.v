module top (
    input clk,
    input rst_n_i, // Added primary reset input for DFT
    input test_mode_i, // Added test mode input for DFT
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

  // Original power-on reset logic (functional mode)
  reg [5:0] reset_cnt = 0;
  wire func_resetn = &reset_cnt;
  always @(posedge clk_bufg) begin
    // This counter generates the functional reset
    reset_cnt <= reset_cnt + !func_resetn;
  end

  // DFT reset signal selection
  wire dft_resetn;
  // In test mode (test_mode_i=1), use external reset rst_n_i
  // In functional mode (test_mode_i=0), use internal power-on reset func_resetn
  assign dft_resetn = test_mode_i ? rst_n_i : func_resetn;

  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  // GPIO and I/O memory interface logic using DFT-friendly reset
  always @(posedge clk_bufg) begin
    if (!dft_resetn) begin // Use DFT controlled reset (active low synchronous)
      gpio <= 32'b0;
      iomem_ready <= 1'b0;
      iomem_rdata <= 32'b0; // Ensure reset state for read data reg
    end else begin
      // Default state when not actively processing a request
      iomem_ready <= 1'b0;
      // Process I/O request
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1; // Acknowledge request
        iomem_rdata <= {sw, gpio[15:0]}; // Provide read data
        // Handle writes based on byte strobes
        if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
      // else: gpio retains value, iomem_ready remains low (set above)
    end
  end

  // Instantiate PicoSoC core using DFT-friendly reset
  picosoc_noflash soc (
      .clk   (clk_bufg),
      .resetn(dft_resetn), // Connect DFT controlled reset
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