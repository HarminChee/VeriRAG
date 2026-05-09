`timescale 1ps/1ps
module clk_wiz_v3_6_exdes_corrected 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Use primary reset directly if possible, or ensure sync uses test clock
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;

  // Use a test clock mux if necessary, for now assume CLK_IN1 is the test clock
  wire          clk_in1_buf;
  wire          test_clk; // This would typically be selected via a test_mode signal

  // Reset synchronizer needs to be clocked by the test clock
  wire          reset_int = COUNTER_RESET; // Assuming COUNTER_RESET is async primary input
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
   wire reset_sync_out; // Synchronized reset

  // Internal clock generation - keep for functionality if needed, but don't clock scan FFs with it
  wire           clk_int; // Generated clock
  wire           clk;     // Keep for ODDR2 if output clock must be generated one
  wire           clk_n;   // Keep for ODDR2

  reg  [C_W-1:0] counter;

  // Buffer primary input clock
  BUFG clkin1_buf
   (.O (clk_in1_buf),
    .I (CLK_IN1));

  // Assign the primary buffered clock as the clock for scan-testable logic
  // In a real DFT flow, this might be muxed with a dedicated test clock input
  assign test_clk = clk_in1_buf; 

  // Instantiate clock wizard, but its output clk_int should not clock core FFs for scan
  clk_wiz_v3_6 clknetwork
   (
    .clk            (clk_in1_buf), // Input to clock wizard
    .clk_20MHz      (clk_int)      // Output generated clock
   );

  // Assign generated clock for ODDR2 if specific output frequency is required
  assign clk = clk_int; 
  assign clk_n = ~clk;

  // ODDR2 clocked by the generated clock clk_int (via clk/clk_n)
  // This part might need separate DFT handling (e.g., bypass) if CLK_OUT needs testing
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),      // Using generated clock
    .C1 (clk_n),    // Using generated clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),     // Use async reset carefully in DFT
    .S  (1'b0));

  // Reset synchronizer clocked by the primary (test) clock
  // Use asynchronous reset input, synchronous deassertion
  always @(posedge test_clk or posedge reset_int) begin // Use primary clock
     if (reset_int) begin // Asynchronous reset asserted
          rst_sync <= 1'b1;
          rst_sync_int <= 1'b1;
          rst_sync_int1 <= 1'b1;
          rst_sync_int2 <= 1'b1;
     end
     else begin // Synchronous reset deasserted
          rst_sync <= 1'b0; // Should ideally come from test control during scan shift
          rst_sync_int <= rst_sync;     
          rst_sync_int1 <= rst_sync_int; 
          rst_sync_int2 <= rst_sync_int1;
     end
  end
  assign reset_sync_out = rst_sync_int2; // Use the synchronized reset

  // Counter clocked by the primary (test) clock and uses synchronized reset
  always @(posedge test_clk or posedge reset_sync_out) begin // Use primary clock and sync reset
    if (reset_sync_out) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      // Add clock enable logic here if needed, controlled during test
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule

// Dummy module for clk_wiz_v3_6 for compilation purposes
// Replace with actual clk_wiz definition if available
module clk_wiz_v3_6 (
    input clk,
    output clk_20MHz
);
    // Dummy implementation: Pass through for simulation/synthesis check
    // In reality, this generates a clock (e.g., 20MHz) from the input 'clk'
    assign clk_20MHz = clk; // Simplistic passthrough for example
endmodule

// Dummy module for BUFG
module BUFG (output O, input I);
  assign O = I;
endmodule

// Dummy module for ODDR2
module ODDR2 (
    output Q,
    input C0,
    input C1,
    input CE,
    input D0,
    input D1,
    input R,
    input S
);
    // Simplified behavioral model
    reg q_reg;
    always @(posedge C0 or posedge R or posedge S) begin
        if (R) q_reg <= 1'b0;
        else if (S) q_reg <= 1'b1;
        else if (CE) q_reg <= D0;
    end
    // Note: This behavioral model doesn't capture the dual-edge nature accurately.
    // A real ODDR uses both C0 and C1 edges.
    // For DFT fix demonstration, exact ODDR behavior isn't critical.
    assign Q = q_reg; 
endmodule