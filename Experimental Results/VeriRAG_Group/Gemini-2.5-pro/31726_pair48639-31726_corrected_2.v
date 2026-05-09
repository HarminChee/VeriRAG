module top (
    input clk,
    input rst_n_i, // Added primary reset input for DFT (active low)
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
  wire func_resetn_internal_high = &reset_cnt; // Active high functional reset
  // Registered version of the functional reset to avoid potential timing issues
  reg func_resetn_internal_high_reg = 1'b0;

  always @(posedge clk_bufg) begin
      // This counter generates the functional reset
      if (&reset_cnt) begin
          reset_cnt <= reset_cnt; // Hold when high
          func_resetn_internal_high_reg <= 1'b1; // Functional reset is active (high)
      end else begin
          reset_cnt <= reset_cnt + 1'b1;
          func_resetn_internal_high_reg <= 1'b0; // Functional reset is inactive (low)
      end
  end

  // DFT reset signal selection (ensure consistent active low polarity)
  wire dft_resetn; // This will be the active low reset used throughout
  // In test mode (test_mode_i=1), use external active low reset rst_n_i
  // In functional mode (test_mode_i=0), use inverted internal power-on reset (!func_resetn_internal_high_reg)
  assign dft_resetn = test_mode_i ? rst_n_i : !func_resetn_internal_high_reg;

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
      iomem_rdata <= iomem_rdata; // Hold previous value unless updated

      // Process I/O request
      // Check for GPIO address range (e.g., 0x03000000)
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1; // Acknowledge request
        // Provide read data: Read switches into lower 16 bits, 0 in upper
        iomem_rdata <= {16'b0, sw};
        // Handle writes based on byte strobes
        if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
        if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
    end
  end

  // Instantiate PicoSoC core using DFT-friendly reset
  // IMPORTANT: The definition of 'picosoc_noflash' module must be available
  //            during compilation/elaboration for this code to work.
  picosoc_noflash soc (
      .clk   (clk_bufg),
      .resetn(dft_resetn), // Connect DFT controlled active low reset
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