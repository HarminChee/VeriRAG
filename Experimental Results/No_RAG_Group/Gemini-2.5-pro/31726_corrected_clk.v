module top_corrected_clk (
    input clk,
    output tx,
    input  rx,
    input  [15:0] sw,
    output [15:0] led,
    input rst_n // Added primary asynchronous reset input for DFT
);

  // Removed BUFG as clk is used directly now.
  // Using the primary clock 'clk' directly for all sequential elements.

  reg [5:0] reset_cnt = 0;
  // Using external asynchronous reset 'rst_n' instead of internally generated synchronous reset
  // wire resetn = &reset_cnt; // Removed internal reset generation
  // always @(posedge clk) begin // Changed clock source to primary 'clk'
  //   reset_cnt <= reset_cnt + !resetn; // Removed internal reset logic
  // end

  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  always @(posedge clk or negedge rst_n) begin // Changed clock source and added async reset
    if (!rst_n) begin // Use primary reset
      gpio <= 32'b0;
      iomem_ready <= 1'b0; // Ensure ready is reset
      iomem_rdata <= 32'b0; // Ensure read data is reset
    end else begin
      // Original logic under synchronous control
      iomem_ready <= 0; // Default assignment moved inside else
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1;
        // Read operation should ideally be combinational or registered differently,
        // but keeping original structure for minimal change focus.
        // Be cautious about read-during-write hazards if addr/valid/wstrb change same cycle.
        iomem_rdata <= {sw, gpio[15:0]}; // Consider potential timing of sw input

        // Write operations
        if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
      // If not valid/ready condition, gpio retains its value (implied latch removed by reset)
    end
  end

  // Instantiating picosoc_noflash with primary clock and reset
  picosoc_noflash soc (
      .clk   (clk),       // Use primary clock 'clk'
      .resetn(rst_n),     // Use primary reset 'rst_n'
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