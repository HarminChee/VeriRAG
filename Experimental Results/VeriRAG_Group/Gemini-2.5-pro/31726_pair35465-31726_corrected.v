module top (
    input clk,
    output tx,
    input  rx,
    input  [15:0] sw,
    output [15:0] led,
    input rst_n_i,    // Added: Primary asynchronous reset input
    input test_mode_i // Added: Test mode control input
);
  wire clk_bufg;
  BUFG bufg (
      .I(clk),
      .O(clk_bufg)
  );

  // Internal reset generation (functional mode)
  reg [5:0] reset_cnt = 0;
  wire resetn = &reset_cnt; // Functional reset signal

  // DFT reset selection logic
  wire dft_resetn;
  assign dft_resetn = test_mode_i ? rst_n_i : resetn;

  // Internal reset counter logic (remains clocked by clk_bufg, uses functional resetn)
  always @(posedge clk_bufg) begin
    reset_cnt <= reset_cnt + !resetn;
  end

  // I/O Memory Interface Logic
  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  // GPIO and I/O memory logic block - uses DFT reset
  always @(posedge clk_bufg) begin
    // Use dft_resetn for synchronous reset condition
    if (!dft_resetn) begin
      gpio <= 32'b0; // Ensure full reset width
      iomem_ready <= 1'b0; // Reset ready signal
      // iomem_rdata is loaded on read, reset might not be needed or defined here
    end else begin
      // Functional logic
      iomem_ready <= 1'b0; // Default assignment for ready
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1;
        // Capture input data on read strobe
        iomem_rdata <= {sw, gpio[15:0]}; // Read operation
        // Write operation based on write strobe
        if (iomem_wstrb[0]) gpio[7:0]   <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8]  <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
      // Note: If iomem_valid goes high but address doesn't match, gpio retains its value.
      // If iomem_valid is low, gpio retains its value.
    end
  end

  // Sub-module instantiation - uses DFT reset
  picosoc_noflash soc (
      .clk   (clk_bufg),
      .resetn(dft_resetn), // Pass DFT-controlled reset
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