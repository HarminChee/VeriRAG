module top (
    input clk,
    input rst_n_i, // Added primary reset input
    input test_i,  // Added test mode input
    output tx,
    input  rx,
    input  [15:0] sw,
    output [15:0] led
);

  // DFT Clock MUX - Use clk directly for both paths if BUFG is undefined/problematic
  wire clk_dft;
  // Assuming clk is the intended clock source for both test and functional modes
  // If a buffered clock is needed functionally, ensure the buffer (e.g., BUFG)
  // is correctly instantiated and available in the environment.
  // For this correction, we prioritize using the primary input clk for DFT.
  assign clk_dft = test_i ? clk : clk;

  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  always @(posedge clk_dft) begin // Use DFT clock
    // Use primary reset rst_n_i (active low)
    if (!rst_n_i) begin
      gpio <= 32'b0;
      iomem_ready <= 1'b0;
      iomem_rdata <= 32'b0;
    end else begin
      iomem_ready <= 1'b0; // Default assignment
      iomem_rdata <= iomem_rdata; // Hold previous value if not reading
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1;
        iomem_rdata <= {sw, gpio[15:0]}; // Read data assignment
        // Write logic
        if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
    end
  end

  // Assuming picosoc_noflash module definition is provided elsewhere
  picosoc_noflash soc (
      .clk   (clk_dft), // Use DFT clock
      .resetn(rst_n_i), // Use primary reset
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