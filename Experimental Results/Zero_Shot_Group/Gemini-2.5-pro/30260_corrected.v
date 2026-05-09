`timescale 1ps/1ps

module Clock48MHZ_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  output        LOCKED
 );

  localparam    C_W       = 16;
  localparam    NUM_C     = 4;

  genvar        count_gen;
  genvar        clk_out_pins;

  wire          reset_int = !LOCKED || COUNTER_RESET;

  // Reset synchronizer registers for each clock domain
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2; // Synchronized reset for each domain

  wire [NUM_C:1] clk_int; // Clocks from the Clock48MHZ primitive
  wire [NUM_C:1] clk;     // Clocks potentially buffered/routed (used by counters)

  reg [C_W-1:0]  counter [NUM_C:1]; // Counter array

  // Instantiate the clocking network primitive
  Clock48MHZ clknetwork
   (
    .CLK_100            (CLK_IN1),      // Input clock (e.g., 100MHz)
    .CLK_48             (clk_int[1]),   // Output clock 1 (e.g., 48MHz)
    .CLK_OUT1           (clk_int[2]),   // Output clock 2
    .CLK_OUT2           (clk_int[3]),   // Output clock 3
    .CLK_OUT4           (clk_int[4]),   // Output clock 4
    .LOCKED             (LOCKED)        // Lock status indicator
   );

  // Generate ODDR instances for clock outputs (FPGA specific)
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
      ODDR clkout_oddr
       (
        .Q  (CLK_OUT[clk_out_pins]), // Output clock pin
        .C  (clk[clk_out_pins]),     // Clock input to ODDR
        .CE (1'b1),                  // Clock enable (always enabled)
        .D1 (1'b1),                  // Data input for rising edge
        .D2 (1'b0),                  // Data input for falling edge
        .R  (1'b0),                  // Reset (inactive)
        .S  (1'b0)                   // Set (inactive)
       );
    end
  endgenerate

  // Assign internal clocks to potentially buffered clock wires
  // This structure allows for potential insertion of clock buffers (e.g., BUFG) here if needed
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];
  assign clk[4] = clk_int[4];

  // Generate reset synchronizers for each clock domain
  // Synchronizes the active-high asynchronous 'reset_int' signal
  // to each 'clk[count_gen]' domain.
  // The output 'rst_sync_int2[count_gen]' asserts asynchronously with 'reset_int'
  // but deasserts synchronously with 'clk[count_gen]'.
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
      always @(posedge clk[count_gen] or posedge reset_int) begin
         if (reset_int) begin // Asynchronous set/reset assertion
              rst_sync[count_gen]      <= #TCQ 1'b1;
              rst_sync_int[count_gen]  <= #TCQ 1'b1;
              rst_sync_int1[count_gen] <= #TCQ 1'b1;
              rst_sync_int2[count_gen] <= #TCQ 1'b1;
         end
         else begin // Synchronous deassertion path
              rst_sync[count_gen]      <= #TCQ 1'b0; // First FF captures deassertion edge
              rst_sync_int[count_gen]  <= #TCQ rst_sync[count_gen];
              rst_sync_int1[count_gen] <= #TCQ rst_sync_int[count_gen];
              rst_sync_int2[count_gen] <= #TCQ rst_sync_int1[count_gen]; // Final synchronized reset
         end
      end
    end
  endgenerate

  // Generate counters, one for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
      // Counter with asynchronous reset using the synchronized reset signal
      always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
        if (rst_sync_int2[count_gen]) begin // Check for active-high asynchronous reset
          counter[count_gen] <= #TCQ { C_W { 1'b0 } }; // Reset counter to zero
        end else begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1; // Increment counter
        end
      end
      // Assign the most significant bit of the counter to the output COUNT bus
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule