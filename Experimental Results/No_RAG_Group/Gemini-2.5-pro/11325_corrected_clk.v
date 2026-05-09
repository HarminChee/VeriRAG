`timescale 1ps/1ps
module mmcm_mkid_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         TEST_MODE,       // Added TEST_MODE input for DFT
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 4;
  genvar        count_gen;

  // Internal signals
  wire          reset_int_functional;
  wire          reset_int;         // Final reset signal used by logic
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2; // Synchronized reset signal
  wire          CLKFB_OUT;
  wire          CLKFB_IN;
  wire [NUM_C:1] clk_int;       // Clocks from MMCM core
  wire [NUM_C:1] buf_clk_in;    // Inputs to BUFGs (multiplexed for testability)
  wire [NUM_C:1] clk;           // Clock outputs from BUFGs (used by logic)
  reg [C_W-1:0]  counter [NUM_C:1];

  // MMCM Feedback
  assign        CLKFB_IN  = CLKFB_OUT;

  // Instantiate the MMCM
  mmcm_mkid clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLKFB_IN           (CLKFB_IN),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .CLK_OUT4           (clk_int[4]),
    .CLKFB_OUT          (CLKFB_OUT),
    .LOCKED             (LOCKED));

  // Clock Muxing for Testability
  // Selects functional clock (clk_int) or test clock (CLK_IN1) based on TEST_MODE
  genvar mux_gen;
  generate
    for (mux_gen = 1; mux_gen <= NUM_C; mux_gen = mux_gen + 1) begin: gen_clk_mux
      assign buf_clk_in[mux_gen] = TEST_MODE ? CLK_IN1 : clk_int[mux_gen];
    end
  endgenerate

  // Clock Buffers (Input is now the muxed clock)
  BUFG clkout1_buf
   (.O (clk[1]),
    .I (buf_clk_in[1])); // Use muxed clock
  BUFG clkout2_buf
   (.O (clk[2]),
    .I (buf_clk_in[2])); // Use muxed clock
  BUFG clkout3_buf
   (.O (clk[3]),
    .I (buf_clk_in[3])); // Use muxed clock
  BUFG clkout4_buf
   (.O (clk[4]),
    .I (buf_clk_in[4])); // Use muxed clock

  // Output Driver (ODDR) - Clocked by the buffered (potentially muxed) clock
  genvar clk_out_pins;
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
    ODDR clkout_oddr
     (.Q  (CLK_OUT[clk_out_pins]),
      .C  (clk[clk_out_pins]), // Use the final buffered clock
      .CE (1'b1),
      .D1 (1'b1),
      .D2 (1'b0),
      .R  (1'b0),             // Assuming ODDR reset is handled or not critical for this DFT fix
      .S  (1'b0));
    end
  endgenerate

  // Reset Logic Muxing for Testability
  assign reset_int_functional = !LOCKED || COUNTER_RESET; // Functional reset condition
  assign reset_int = TEST_MODE ? COUNTER_RESET : reset_int_functional; // Select reset based on mode

  // Reset Synchronizers (Clocked by the final buffered clock 'clk')
  // Sensitive to the muxed asynchronous reset 'reset_int'
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1_reset_sync
    // Asynchronous reset synchronizer chain
    always @(posedge clk[count_gen] or posedge reset_int) begin // Use final clock and muxed reset
       if (reset_int) begin // Asynchronous reset active high
            rst_sync[count_gen] <= 1'b1;
            rst_sync_int[count_gen]<= 1'b1;
            rst_sync_int1[count_gen]<= 1'b1;
            rst_sync_int2[count_gen]<= 1'b1; // Final synchronized reset signal
       end
       else begin // Synchronous deassertion path
            rst_sync[count_gen] <= 1'b0;
            rst_sync_int[count_gen] <= rst_sync[count_gen];
            rst_sync_int1[count_gen] <= rst_sync_int[count_gen];
            rst_sync_int2[count_gen] <= rst_sync_int1[count_gen];
       end
    end
  end
  endgenerate

  // Counters (Clocked by the final buffered clock 'clk')
  // Using synchronous reset based on the synchronized reset signal rst_sync_int2
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
    always @(posedge clk[count_gen]) begin // Use final clock, synchronous reset logic
      if (rst_sync_int2[count_gen]) begin // Check synchronized reset signal synchronously
        counter[count_gen] <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter[count_gen] <= #TCQ counter[count_gen] + 1'b 1;
      end
    end
    // Output assignment
    assign COUNT[count_gen] = counter[count_gen][C_W-1];
  end
  endgenerate

endmodule