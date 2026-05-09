module top (
    input clk,
    input rst_n_i,    // DFT: Added primary reset input (active low)
    input test_mode_i,// DFT: Added test mode input
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
  reg [5:0] reset_cnt = 0;
  wire func_resetn_deasserted = &reset_cnt; // Functional reset deasserted (high) when count finishes
  wire func_resetn = !func_resetn_deasserted; // Functional reset active low

  // DFT: Mux for controllable reset (active low)
  wire dft_resetn;
  assign dft_resetn = test_mode_i ? rst_n_i : func_resetn;

  always @(posedge clk_bufg) begin
    // Use func_resetn for the counter logic itself
    reset_cnt <= reset_cnt + !func_resetn_deasserted;
  end

  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  always @(posedge clk_bufg) begin
    // Use the DFT-controllable reset for the GPIO logic
    if (dft_resetn) begin // Reset when dft_resetn is asserted (low)
      gpio <= 0;
      iomem_ready <= 0; // Also reset iomem_ready state
    end else begin
      iomem_ready <= 0; // Default assignment
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1;
        iomem_rdata <= {sw, gpio[15:0]};
        if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
    end
  end

  picosoc_noflash soc (
      .clk   (clk_bufg),
      // DFT: Pass the controllable reset (active low) to the SOC instance
      .resetn(dft_resetn),
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