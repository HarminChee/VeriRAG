`timescale 1ps/1ps
module pll_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  // Functional Ports
  input         CLK_IN1,        // Primary functional clock input
  input         COUNTER_RESET,  // Primary functional reset input
  input         RESET,          // Primary functional reset input
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  output        LOCKED,         // PLL Locked signal

  // DFT Ports
  input         test_mode,      // Scan enable / Test mode select
  input         test_clk,       // Scan clock input
  input         test_reset      // Scan reset input (active high synchronous)
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 4;
  genvar        count_gen;

  // Internal signals
  wire          reset_int = !LOCKED || RESET || COUNTER_RESET; // Functional reset condition
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;       // Raw clocks from PLL
  wire [NUM_C:1] clk;           // Functional clocks (buffered/assigned)
  wire [NUM_C:1] scan_clk;      // Clock selected for FFs (functional or test)
  reg [C_W-1:0]  counter [NUM_C:1];

  // PLL Instantiation
  pll clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .CLK_OUT4           (clk_int[4]),
    .RESET              (RESET),        // Assuming PLL reset is primary
    .LOCKED             (LOCKED));

  // Assign functional clocks (can be buffered if needed)
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];
  assign clk[4] = clk_int[4];

  // Clock MUX for DFT: Selects test_clk in test_mode, otherwise functional clock
  genvar mux_gen;
  generate
    for (mux_gen = 1; mux_gen <= NUM_C; mux_gen = mux_gen + 1) begin: gen_scan_clk_mux
      // Use a simple mux; synthesis tool will implement appropriately
      assign scan_clk[mux_gen] = test_mode ? test_clk : clk[mux_gen];
    end
  endgenerate

  // Output clock generation using ODDR (clocked by scan_clk now)
  genvar clk_out_pins;
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
      ODDR clkout_oddr
       (.Q  (CLK_OUT[clk_out_pins]),
        .C  (scan_clk[clk_out_pins]), // Use muxed clock
        .CE (1'b1),
        .D1 (1'b1),
        .D2 (1'b0),
        .R  (1'b0), // Assuming ODDR reset is handled separately or unused
        .S  (1'b0));
    end
  endgenerate

  // Reset synchronizer stages (converted to synchronous reset)
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: sync_reset_logic
    wire current_sync_reset;
    // Reset is active if in functional mode AND reset_int is active,
    // OR if in test mode AND test_reset is active.
    assign current_sync_reset = (!test_mode && reset_int) || (test_mode && test_reset);

    always @(posedge scan_clk[count_gen]) begin // Clocked by muxed clock
       if (current_sync_reset) begin // Synchronous reset logic
            rst_sync[count_gen]      <= #TCQ 1'b1;
            rst_sync_int[count_gen]  <= #TCQ 1'b1;
            rst_sync_int1[count_gen] <= #TCQ 1'b1;
            rst_sync_int2[count_gen] <= #TCQ 1'b1;
       end else begin
            rst_sync[count_gen]      <= #TCQ 1'b0;
            rst_sync_int[count_gen]  <= #TCQ rst_sync[count_gen];
            rst_sync_int1[count_gen] <= #TCQ rst_sync_int[count_gen];
            rst_sync_int2[count_gen] <= #TCQ rst_sync_int1[count_gen];
       end
    end
  end
  endgenerate

  // Counter logic (converted to synchronous reset)
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
    wire current_counter_reset;
    // Reset is active if in functional mode AND internal sync reset is active,
    // OR if in test mode AND test_reset is active.
    assign current_counter_reset = (!test_mode && rst_sync_int2[count_gen]) || (test_mode && test_reset);

    always @(posedge scan_clk[count_gen]) begin // Clocked by muxed clock
      if (current_counter_reset) begin // Synchronous reset logic
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