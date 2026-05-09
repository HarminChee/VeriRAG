`timescale 1ps/1ps

module pll_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous Reset Input
  output [2:1]  CLK_OUT,
  output [2:1]  COUNT
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 2;

  genvar        count_gen;

  wire          reset_int = COUNTER_RESET; // Use input directly

  // Reset synchronizer registers for each clock domain
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2; // Synchronized reset output for each domain

  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk_n;
  wire [NUM_C:1] clk;

  reg [C_W-1:0]  counter [NUM_C:1];

  // Instantiate the PLL primitive
  // Note: The definition for 'pll' module is assumed to exist elsewhere.
  pll clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2])
    // Add other PLL ports like LOCKED if needed
   );

  // Assign internal clocks
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];

  // Generate Output Clocks using ODDR
  genvar clk_out_pins;
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
      assign clk_n[clk_out_pins] = ~clk[clk_out_pins];
      // Assuming ODDR2 primitive exists in the target technology
      ODDR2 clkout_oddr
       (
        .Q  (CLK_OUT[clk_out_pins]),
        .C0 (clk[clk_out_pins]),
        .C1 (clk_n[clk_out_pins]),
        .CE (1'b1),
        .D0 (1'b1),
        .D1 (1'b0),
        .R  (1'b0), // Assuming reset is handled by the counter reset logic
        .S  (1'b0)
       );
    end
  endgenerate

  // Generate Reset Synchronizers (one for each clock domain)
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: reset_sync_gen
      // Synchronize the asynchronous reset_int to the clk[count_gen] domain
      // Use asynchronous reset for the synchronizer flip-flops
      always @(posedge clk[count_gen] or posedge reset_int)
      begin
         if (reset_int) begin // Asynchronous reset condition (active high)
              rst_sync[count_gen]      <= #TCQ 1'b1;
              rst_sync_int[count_gen]  <= #TCQ 1'b1;
              rst_sync_int1[count_gen] <= #TCQ 1'b1;
              rst_sync_int2[count_gen] <= #TCQ 1'b1; // Synchronized reset goes active
         end
         else begin // Clocked path, propagate deassertion
              rst_sync[count_gen]      <= #TCQ 1'b0; // Capture deasserted reset state
              rst_sync_int[count_gen]  <= #TCQ rst_sync[count_gen];
              rst_sync_int1[count_gen] <= #TCQ rst_sync_int[count_gen];
              rst_sync_int2[count_gen] <= #TCQ rst_sync_int1[count_gen]; // Synchronized reset eventually goes inactive
         end
      end
    end
  endgenerate

  // Generate Counters (one for each clock domain)
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: counters
      // Counter clocked by clk[count_gen] and reset synchronously by rst_sync_int2[count_gen]
      always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) // Use synchronized reset
      begin
        if (rst_sync_int2[count_gen]) begin // Synchronous reset condition
          counter[count_gen] <= #TCQ {C_W{1'b0}};
        end else begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
        end
      end

      // Assign MSB of counter to output COUNT for observation
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule

// Placeholder for the PLL module definition (replace with actual PLL instance)
// This is needed for simulation/synthesis but depends on the specific PLL IP/primitive used.
/*
module pll (
    input  CLK_IN1,
    output CLK_OUT1,
    output CLK_OUT2
    // Add other ports like reset, locked etc. as needed
);
    // PLL implementation details
    assign CLK_OUT1 = CLK_IN1; // Example: pass-through (replace with actual PLL behavior)
    assign CLK_OUT2 = CLK_IN1; // Example: pass-through (replace with actual PLL behavior)
endmodule
*/

// Note: ODDR2 is often a specific primitive (e.g., Xilinx). Ensure it's available
// or replace with a generic equivalent if needed for portability.