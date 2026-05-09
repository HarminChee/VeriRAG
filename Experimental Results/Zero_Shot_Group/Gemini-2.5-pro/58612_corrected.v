`timescale 1ps/1ps

module bclk_dll_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output        CLK_OUT,      // Corrected: Changed from output [1:1]
  output        COUNT,
  input         RESET,
  output        LOCKED
 );

  localparam C_W = 16;

  wire          clk_in1_buf;  // Added: Declaration for BUFG output
  wire          clk_int;
  wire          clk;
  wire          reset_int = !LOCKED || RESET || COUNTER_RESET;

  // Reset Synchronizer Registers
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2; // Synchronized reset signal

  reg  [C_W-1:0] counter;


  BUFG clkin1_buf
   (.O (clk_in1_buf),
    .I (CLK_IN1));

  // Assuming bclk_dll module exists elsewhere
  bclk_dll clknetwork
   (
    .clk133in           (clk_in1_buf),
    .clk133             (clk_int),
    .RESET              (RESET),      // Pass top-level RESET if needed by DLL
    .LOCKED             (LOCKED)
   );

  assign clk = clk_int;         // Internal clock driven by DLL output
  assign CLK_OUT = clk_int;     // Corrected: Assign to single-bit output


  // Asynchronous Reset Synchronizer (Standard 4-flop synchronizer)
  // Synchronizes the combined reset signal 'reset_int' into the 'clk' domain.
  always @(posedge clk) begin
      rst_sync      <= reset_int;
      rst_sync_int  <= rst_sync;
      rst_sync_int1 <= rst_sync_int;
      rst_sync_int2 <= rst_sync_int1; // Output is rst_sync_int2
  end


  // Counter block with asynchronous reset (using synchronized reset signal)
  always @(posedge clk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  // Assign MSB of counter to output COUNT
  assign COUNT = counter[C_W-1];

endmodule

// Note: Definition for the 'bclk_dll' module is required for simulation/synthesis.
// Example placeholder:
/*
module bclk_dll (
    input clk133in,
    output clk133,
    input RESET,
    output LOCKED
);
    // Dummy DLL logic - replace with actual DLL model or instantiation
    assign clk133 = clk133in; // Simple pass-through for basic testing
    assign LOCKED = 1'b1;     // Assume locked for basic testing
endmodule
*/