`timescale 1ps/1ps

module ddr3_clkgen_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,         // Input clock
  input         COUNTER_RESET,   // External counter reset
  output [3:1]  CLK_OUT,         // Generated clocks
  output [3:1]  COUNT,           // MSB of counters
  input         RESET,           // General reset
  output        LOCKED           // PLL/MMCM Locked signal
 );

  localparam C_W       = 16; // Counter width
  localparam NUM_C     = 3;  // Number of clocks/counters

  genvar        count_gen;

  wire          pll_locked;      // Internal wire for LOCKED output
  wire          reset_int;       // Combined asynchronous reset

  // Reset generation: Reset is active if PLL is not locked OR external RESET is active OR COUNTER_RESET is active
  assign reset_int = !pll_locked || RESET || COUNTER_RESET;

  // Internal clock wires
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;

  // Counter registers
  reg [C_W-1:0]  counter [NUM_C:1];

  // Reset synchronizer registers for each clock domain
  reg [NUM_C:1] reset_sync_0;
  reg [NUM_C:1] reset_sync_1;
  wire [NUM_C:1] reset_sync_out; // Synchronized reset for each domain

  // Instantiate the clock generator module (assuming it's defined elsewhere)
  ddr3_clkgen clknetwork
   (
    .clk50in            (CLK_IN1),
    // Assign outputs to internal wires
    .clk50              (clk_int[1]), // Assuming clk_int[1] is 50MHz
    .clk400             (clk_int[2]), // Assuming clk_int[2] is 400MHz
    .clk100             (clk_int[3]), // Assuming clk_int[3] is 100MHz
    .RESET              (RESET),      // Pass general reset
    .LOCKED             (pll_locked)  // Receive lock status
   );

  // Assign internal clocks to output port and internal clock array
  assign CLK_OUT = clk_int;
  assign clk     = clk_int; // Simplified assignment
  assign LOCKED  = pll_locked; // Assign internal lock status to output

  // Generate reset synchronizers for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: reset_synchronizers
      // Standard 2-flop synchronizer with asynchronous reset input
      // The first flop captures the async reset, the second synchronizes it to the clock domain
      always @(posedge clk[count_gen] or posedge reset_int) begin
        if (reset_int) begin
          reset_sync_0[count_gen] <= 1'b1;
          reset_sync_1[count_gen] <= 1'b1;
        end else begin
          reset_sync_0[count_gen] <= 1'b0;
          reset_sync_1[count_gen] <= #TCQ reset_sync_0[count_gen]; // Add delay for timing sim
        end
      end
      assign reset_sync_out[count_gen] = reset_sync_1[count_gen]; // Output of the synchronizer
    end
  endgenerate

  // Generate counters for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
      // Counter with synchronous clock enable and asynchronous reset
      // Reset is driven by the synchronized reset signal for this clock domain
      always @(posedge clk[count_gen] or posedge reset_sync_out[count_gen]) begin
        if (reset_sync_out[count_gen]) begin // Check level of synchronized reset
          counter[count_gen] <= #TCQ { C_W { 1'b0 } };
        end else begin
          // Counter increments on every positive clock edge when not in reset
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
        end
      end
      // Assign the most significant bit of the counter to the output port
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule

// Placeholder for the actual clock generator module (replace with actual IP or RTL)
// This is needed for the example design to compile, but its internal logic is not part of the correction.
module ddr3_clkgen (
    input clk50in,
    output clk50,
    output clk400,
    output clk100,
    input RESET,
    output LOCKED
);
    // Dummy assignments - replace with actual clock generation logic (e.g., MMCM/PLL)
    assign clk50 = clk50in; // Example pass-through
    assign clk400 = clk50in; // Example pass-through
    assign clk100 = clk50in; // Example pass-through
    assign LOCKED = ~RESET; // Example lock logic (locked when not in reset)

endmodule