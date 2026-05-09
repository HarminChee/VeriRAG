module top (
    input clk,
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

  // Reset generation (active low resetn for 64 cycles)
  reg [5:0] reset_cnt = 6'b0;
  wire resetn = &reset_cnt; // resetn is low until reset_cnt reaches 63
  always @(posedge clk_bufg) begin
    if (!resetn) begin
        reset_cnt <= reset_cnt + 6'd1;
    end
    // Note: counter stops once resetn goes high
  end

  // PicoSoC IO Memory Interface Wires/Regs
  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;

  // GPIO Register and LED connection
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  // GPIO Memory-Mapped Peripheral Logic
  always @(posedge clk_bufg) begin
    if (!resetn) begin
      gpio <= 32'b0;
      iomem_ready <= 1'b0;
      iomem_rdata <= 32'b0;
    end else begin
      // Default state: not ready unless specifically addressed
      iomem_ready <= 1'b0;

      // Check if GPIO address space (0x03xxxxxx) is accessed
      if (iomem_valid && iomem_addr[31:24] == 8'h03) begin
        // Peripheral is ready in this cycle (0 wait states)
        iomem_ready <= 1'b1;

        // Read operation: Return switches and lower 16 bits of GPIO
        iomem_rdata <= {sw, gpio[15:0]};

        // Write operation: Update GPIO based on write strobes
        if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
        if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
    end
  end

  // Instantiate PicoSoC
  picosoc_noflash soc (
      .clk   (clk_bufg),
      .resetn(resetn),

      // UART
      .ser_tx(tx),
      .ser_rx(rx),

      // Unused IRQs
      .irq_5(1'b0),
      .irq_6(1'b0),
      .irq_7(1'b0),

      // IO Memory Interface
      .iomem_valid(iomem_valid),
      .iomem_ready(iomem_ready),
      .iomem_wstrb(iomem_wstrb),
      .iomem_addr (iomem_addr),
      .iomem_wdata(iomem_wdata),
      .iomem_rdata(iomem_rdata)
  );

endmodule