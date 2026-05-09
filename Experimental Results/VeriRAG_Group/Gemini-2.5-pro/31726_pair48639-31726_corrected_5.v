// Dummy module definition for picosoc_noflash to allow compilation
// In a real scenario, the actual definition of this module should be provided.
module picosoc_noflash (
    input clk,
    input resetn,
    output ser_tx,
    input ser_rx,
    input irq_5,
    input irq_6,
    input irq_7,
    output iomem_valid,
    input iomem_ready,
    output [3:0] iomem_wstrb,
    output [31:0] iomem_addr,
    output [31:0] iomem_wdata,
    input [31:0] iomem_rdata
);
    // Assign default values to outputs to avoid potential issues
    // during elaboration/synthesis if the module remains empty.
    assign ser_tx = 1'b0;
    assign iomem_valid = 1'b0;
    assign iomem_wstrb = 4'b0;
    assign iomem_addr = 32'b0;
    assign iomem_wdata = 32'b0;

endmodule

// Dummy module definition for BUFG if not recognized as a primitive
// In many FPGA/ASIC flows, BUFG is a known primitive and doesn't need explicit definition.
// Uncomment the following lines if BUFG causes an elaboration error.
// module BUFG (
//     input I,
//     output O
// );
//     assign O = I; // Simplistic behavioral model
// endmodule


module top (
    input clk,
    input rst_n_i,      // Primary reset input for DFT (active low)
    input test_mode_i,  // Test mode input for DFT
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

  // Internal functional reset generation logic
  reg [5:0] reset_cnt = 6'b0;
  wire func_reset_condition = (&reset_cnt); // Condition to activate functional reset (active high)
  reg func_reset_active_reg = 1'b0; // Registered state of functional reset (active high)

  // Global DFT-friendly reset signal (active low)
  // In test mode (test_mode_i=1), use external rst_n_i.
  // In functional mode (test_mode_i=0), use the internally generated functional reset (active low version: !func_reset_active_reg).
  wire global_resetn;
  assign global_resetn = test_mode_i ? rst_n_i : !func_reset_active_reg;

  // Process for generating the internal functional reset state
  // This process itself must be resettable using the global reset signal.
  always @(posedge clk_bufg) begin
    if (!global_resetn) begin // Synchronous active-low reset using the global signal
        reset_cnt <= 6'b0;
        func_reset_active_reg <= 1'b0; // Functional reset is inactive after reset
    end else begin
        // Functional mode operation: Only count if functional reset is not yet active
        if (!test_mode_i && !func_reset_active_reg) begin
            if (func_reset_condition) begin
                func_reset_active_reg <= 1'b1; // Activate functional reset
                reset_cnt <= reset_cnt;     // Hold counter at max
            end else begin
                reset_cnt <= reset_cnt + 1'b1; // Increment counter
                func_reset_active_reg <= 1'b0; // Keep reset inactive
            end
        // In test mode, or once functional reset is active, hold the state
        // (Scan chains will control FFs in test mode if they are scanned)
        end else begin // Hold state in test mode or when functional reset is already active
             reset_cnt <= reset_cnt;
             func_reset_active_reg <= func_reset_active_reg;
        end
    end
  end

  // GPIO and I/O memory interface logic
  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  reg  [31:0] iomem_rdata;
  reg  [31:0] gpio;
  assign led = gpio[15:0];

  // GPIO logic using the global DFT-friendly reset
  always @(posedge clk_bufg) begin
    if (!global_resetn) begin // Use global DFT controlled reset (active low synchronous)
      gpio <= 32'b0;
      iomem_ready <= 1'b0;
      iomem_rdata <= 32'b0;
    end else begin
      // Default state
      iomem_ready <= 1'b0;
      // Keep previous read data unless updated
      // iomem_rdata <= iomem_rdata; // Default FF behavior

      // Process I/O request
      if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
        iomem_ready <= 1'b1;
        iomem_rdata <= {16'b0, sw}; // Update read data based on switch inputs
        if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
        if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
        if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
        if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
      end
      // Note: If no valid request, FFs 'gpio' and 'iomem_rdata' hold their values naturally.
      // No explicit 'else' needed to assign them to themselves.
    end
  end

  // Instantiate PicoSoC core using DFT-friendly reset
  picosoc_noflash soc (
      .clk   (clk_bufg),
      .resetn(global_resetn), // Connect global DFT controlled active low reset
      .ser_tx(tx),
      .ser_rx(rx),
      .irq_5(1'b0), // Assuming these are tied off inputs
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