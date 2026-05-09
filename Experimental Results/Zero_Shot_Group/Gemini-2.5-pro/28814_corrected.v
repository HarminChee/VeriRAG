`timescale 1ps/1ps

module clk_gen_83M_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // External counter reset
  output [3:1]  COUNT,         // MSB of each counter
  input         RESET,         // Global reset for clock generator
  output        LOCKED         // Clock generator lock status
 );

  localparam C_W       = 16; // Counter width
  localparam NUM_C     = 3;  // Number of counters/clocks

  genvar        count_gen;

  // Combined asynchronous reset signal for counters
  wire          reset_int = !LOCKED || RESET || COUNTER_RESET;

  // Registers for reset synchronization (4 stages per clock domain)
   reg [NUM_C:1] rst_sync;
   reg [NUM_C:1] rst_sync_int;
   reg [NUM_C:1] rst_sync_int1;
   reg [NUM_C:1] rst_sync_int2; // Synchronized reset for each domain

  wire [NUM_C:1] clk_int; // Internal clock wires from clk_gen_83M
  wire [NUM_C:1] clk;     // Clock wires used by counters

  // Array of counters, one for each clock output
  reg [C_W-1:0]  counter [NUM_C:1];

  // Instantiate the clock generator module
  clk_gen_83M clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .RESET              (RESET),
    .LOCKED             (LOCKED)
   );

  // Connect internal clocks to clock wires used by logic
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];

  // Generate reset synchronizers for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: reset_sync_gen
      // Synchronize the combined reset signal to the respective clock domain
      always @(posedge clk[count_gen]) begin
        rst_sync[count_gen]      <= #TCQ reset_int;             // Stage 1
        rst_sync_int[count_gen]  <= #TCQ rst_sync[count_gen];      // Stage 2
        rst_sync_int1[count_gen] <= #TCQ rst_sync_int[count_gen]; // Stage 3
        rst_sync_int2[count_gen] <= #TCQ rst_sync_int1[count_gen];// Stage 4 (Synchronized Reset Output)
      end
    end
  endgenerate

  // Generate counters, one for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_gen
      // Counter logic with asynchronous reset (using the synchronized reset signal)
      always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
        if (rst_sync_int2[count_gen]) begin // Reset condition check
          counter[count_gen] <= #TCQ {C_W{1'b0}}; // Reset counter to 0
        end else begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1; // Increment counter
        end
      end

      // Assign the most significant bit (MSB) of each counter to the output port
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule