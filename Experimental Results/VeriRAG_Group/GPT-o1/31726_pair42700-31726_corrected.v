`timescale 1ns/1ns
module top (
    input  wire clk,
    input  wire external_reset_n,
    input  wire test_i,
    input  wire scan_locked,
    output wire tx,
    input  wire rx,
    input  wire [15:0] sw,
    output wire [15:0] led
);
  wire clk_bufg;
  BUFG bufg (
      .I(clk),
      .O(clk_bufg)
  );

  wire dft_clk_int   = test_i ? clk : clk_bufg;
  wire dft_reset_n   = test_i ? scan_locked : external_reset_n;

  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;

  assign led = gpio[15:0];

  always @(posedge dft_clk_int) begin
    if (!dft_reset_n) begin
      gpio        <= 0;
      iomem_ready <= 0;
    end else begin
      iomem_ready <= 0;
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1;
        iomem_rdata <= {sw, gpio[15:0]};
        if (iomem_wstrb[0]) gpio[7:0]   <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8]  <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
    end
  end

  picosoc_noflash soc (
      .clk         (dft_clk_int),
      .resetn      (dft_reset_n),
      .ser_tx      (tx),
      .ser_rx      (rx),
      .irq_5       (1'b0),
      .irq_6       (1'b0),
      .irq_7       (1'b0),
      .iomem_valid (iomem_valid),
      .iomem_ready (iomem_ready),
      .iomem_wstrb (iomem_wstrb),
      .iomem_addr  (iomem_addr),
      .iomem_wdata (iomem_wdata),
      .iomem_rdata (iomem_rdata)
  );
endmodule