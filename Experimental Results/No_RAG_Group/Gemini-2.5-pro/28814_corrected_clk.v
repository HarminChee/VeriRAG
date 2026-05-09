`timescale 1ps/1ps
module clk_gen_83M_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,         // Primary clock, also serves as test clock
  input         COUNTER_RESET,
  input         RESET,
  input         test_mode,       // Test mode enable signal
  output [3:1]  COUNT,
  output        LOCKED
 );

  localparam    C_W       = 16;
  localparam    NUM_C     = 3;
  genvar        count_gen;

  // Internal signals
  wire          reset_int;
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;        // Clocks from the generator
  wire [NUM_C:1] func_clk;       // Functional clocks
  wire [NUM_C:1] scan_clk;       // Muxed clock for FFs (DFT compliant)
  reg [C_W-1:0]  counter [NUM_C:1];

  // Instantiate the internal clock generator
  clk_gen_83M clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .RESET              (RESET),
    .LOCKED             (LOCKED));

  // Assign functional clocks (output of the clock generator)
  assign func_clk[1] = clk_int[1];
  assign func_clk[2] = clk_int[2];
  assign func_clk[3] = clk_int[3];

  // Clock multiplexing for DFT: Selects test clock (CLK_IN1) in test_mode
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: clk_muxing
    assign scan_clk[count_gen] = test_mode ? CLK_IN1 : func_clk[count_gen];
  end
  endgenerate

  // Combined reset logic (active high)
  // Note: Using !LOCKED directly in combinatorial logic might have timing issues depending on LOCKED source.
  // Assuming LOCKED is stable enough or properly handled upstream.
  assign reset_int = !LOCKED || RESET || COUNTER_RESET;

  // Reset synchronizer chain - Now clocked by scan_clk and using synchronous reset
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: reset_sync_gen
    always @(posedge scan_clk[count_gen]) begin // Clocked by DFT-friendly scan_clk
       if (reset_int) begin // Synchronous reset condition
            rst_sync[count_gen] <= 1'b1;
            rst_sync_int[count_gen]<= 1'b1;
            rst_sync_int1[count_gen]<= 1'b1;
            rst_sync_int2[count_gen]<= 1'b1;
       end
       else begin
            // Propagate reset signal through synchronizer stages
            rst_sync[count_gen] <= 1'b0; // Assuming reset needs to deassert through stages
            rst_sync_int[count_gen] <= rst_sync[count_gen];
            rst_sync_int1[count_gen] <= rst_sync_int[count_gen];
            rst_sync_int2[count_gen] <= rst_sync_int1[count_gen];
       end
    end
  end
  endgenerate

  // Counter logic - Now clocked by scan_clk and using synchronous reset
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_gen
    always @(posedge scan_clk[count_gen]) begin // Clocked by DFT-friendly scan_clk
      if (rst_sync_int2[count_gen]) begin // Synchronous reset using the synchronized signal
        counter[count_gen] <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter[count_gen] <= #TCQ counter[count_gen] + 1'b 1;
      end
    end
    // Assign MSB of counter to output COUNT
    assign COUNT[count_gen] = counter[count_gen][C_W-1];
  end
  endgenerate

endmodule

// Note: The definition for the clk_gen_83M module is not provided,
// it is assumed to be an existing module that generates clocks.
// The fix focuses on how the generated clocks are used within this module.