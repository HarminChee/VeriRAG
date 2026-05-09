`timescale 1ps/1ps

module clk_dll_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [3:1]  CLK_OUT,
  output [3:1]  COUNT,
  input         RESET,
  output        LOCKED
 );

  localparam C_W       = 16;
  localparam NUM_C     = 3;

  genvar        count_gen;
  genvar        clk_out_pins;

  wire          reset_comb = !LOCKED || RESET || COUNTER_RESET;

  // Internal clock signals
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;
  wire [NUM_C:1] clk_n;

  // Counter registers
  reg [C_W-1:0] counter [NUM_C:1];

  // Reset synchronization registers
  reg [NUM_C:1] reset_sync_p1;
  reg [NUM_C:1] reset_sync_p2; // Synchronized reset for each clock domain

  // Instantiate the DLL core
  clk_dll clknetwork
   (
    .clk50in            (CLK_IN1),
    .clk50              (clk_int[1]),
    .clk25              (clk_int[2]),
    .clk3p2             (clk_int[3]),
    .RESET              (RESET),      // Pass external reset directly if needed by core
    .LOCKED             (LOCKED)
   );

  // Assign internal clocks (can be optimized, kept for clarity matching original)
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];

  // Generate ODDR outputs for each clock
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
      assign clk_n[clk_out_pins] = ~clk[clk_out_pins];

      // Assuming ODDR2 primitive is available (e.g., Xilinx specific)
      ODDR2 clkout_oddr
       (
        .Q  (CLK_OUT[clk_out_pins]), // Corrected index
        .C0 (clk[clk_out_pins]),
        .C1 (clk_n[clk_out_pins]),
        .CE (1'b1),
        .D0 (1'b1),
        .D1 (1'b0),
        .R  (1'b0), // Using synchronous reset in counter logic instead
        .S  (1'b0)
       );
    end
  endgenerate

  // Generate reset synchronizers for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: reset_synchronizers
      // 2-flop synchronizer for the combined reset signal into each clock domain
      always @(posedge clk[count_gen]) begin
        reset_sync_p1[count_gen] <= reset_comb;
        reset_sync_p2[count_gen] <= reset_sync_p1[count_gen];
      end
    end
  endgenerate

  // Generate counters for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: counters
      // Use the synchronized reset for this clock domain
      wire sync_reset = reset_sync_p2[count_gen];

      always @(posedge clk[count_gen]) begin
        if (sync_reset) begin // Use synchronous reset
          counter[count_gen] <= #TCQ {C_W{1'b0}};
        end else begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
        end
      end

      // Assign the MSB of the counter to the output COUNT signal
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule

// Dummy module for clk_dll to allow compilation - replace with actual DLL instance
module clk_dll (
    input clk50in,
    output clk50,
    output clk25,
    output clk3p2,
    input RESET,
    output LOCKED
);
    // Dummy logic - replace with actual DLL model or instance
    assign clk50 = clk50in; // Example passthrough
    assign clk25 = clk50in; // Example passthrough
    assign clk3p2 = clk50in; // Example passthrough
    assign LOCKED = ~RESET; // Example simple locked logic
endmodule