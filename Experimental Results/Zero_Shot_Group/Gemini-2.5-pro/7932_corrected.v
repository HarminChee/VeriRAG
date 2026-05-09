`timescale 1ps/1ps

module sdram_clk_gen_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous Reset Input
  output [1:1]  CLK_OUT,       // Clock Output (using index 1)
  output        COUNT          // MSb of counter
 );

  localparam C_W = 16; // Counter Width

  // Internal signals
  wire          reset_int = COUNTER_RESET; // Alias for reset input
  wire          clk_int;   // Clock from sdram_clk_gen instance
  wire          clk;       // Internal clock signal
  wire          clk_n;     // Inverted internal clock

  // Reset Synchronization Registers
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2; // Final synchronized reset signal

  // Counter Register
  reg  [C_W-1:0] counter;

  // Instantiate the clock generator module
  // Assumes sdram_clk_gen module definition exists elsewhere
  sdram_clk_gen clknetwork (
    .clk_in  (CLK_IN1),
    .clk_out (clk_int)
  );

  // Assign internal clock and its inverse
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Output clock generation using ODDR primitive
  // Outputs '1' on rising edge of clk, '0' on falling edge (rising edge of clk_n)
  // Effectively buffers 'clk' to the output pin CLK_OUT[1]
  ODDR2 clkout_oddr (
    .Q  (CLK_OUT[1]), // Output connected to the single bit CLK_OUT[1]
    .C0 (clk),        // Clock input for rising edge data
    .C1 (clk_n),      // Clock input for falling edge data
    .CE (1'b1),       // Clock Enable (always enabled)
    .D0 (1'b1),       // Data captured on C0 edge
    .D1 (1'b0),       // Data captured on C1 edge
    .R  (1'b0),       // Reset (inactive)
    .S  (1'b0)        // Set (inactive)
  );

  // Asynchronous Reset Synchronizer (4-stage)
  // Samples the asynchronous reset input on the clock edge
  // Uses non-blocking assignments for sequential logic
  always @(posedge clk) begin
     rst_sync      <= #TCQ reset_int;     // Stage 1: Sample async reset
     rst_sync_int  <= #TCQ rst_sync;      // Stage 2
     rst_sync_int1 <= #TCQ rst_sync_int;  // Stage 3
     rst_sync_int2 <= #TCQ rst_sync_int1; // Stage 4: Output synchronized reset
  end

  // Counter with synchronous reset using the synchronized reset signal
  // Uses non-blocking assignments for sequential logic
  always @(posedge clk) begin
    if (rst_sync_int2) begin // Check level of synchronized reset
      counter <= #TCQ { C_W { 1'b0 } }; // Reset counter synchronously
    end else begin
      counter <= #TCQ counter + 1'b1;   // Increment counter
    end
  end

  // Assign the most significant bit of the counter to the output port COUNT
  assign COUNT = counter[C_W-1];

endmodule