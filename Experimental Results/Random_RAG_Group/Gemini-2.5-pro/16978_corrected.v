`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i, // Added test mode input
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  wire          reset_int = !LOCKED || COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  reg  [C_W-1:0] counter;

  // DFT Muxing logic for asynchronous resets
  wire dft_reset_sync_trigger;
  wire dft_reset_counter_trigger;

  assign dft_reset_sync_trigger = test_i ? COUNTER_RESET : reset_int;
  assign dft_reset_counter_trigger = test_i ? COUNTER_RESET : rst_sync_int2;


  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));
  assign clk_n = ~clk;
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
  assign clk = clk_int;

    // Changed sensitivity list to use DFT muxed reset trigger
    always @(posedge clk or posedge dft_reset_sync_trigger) begin
       // Internal reset condition remains based on functional reset
       if (reset_int) begin
            rst_sync <= #TCQ 1'b1;
            rst_sync_int <= #TCQ 1'b1;
            rst_sync_int1 <= #TCQ 1'b1;
            rst_sync_int2 <= #TCQ 1'b1;
       end
       else begin
            rst_sync <= #TCQ 1'b0;
            rst_sync_int <= #TCQ rst_sync;
            rst_sync_int1 <= #TCQ rst_sync_int;
            rst_sync_int2 <= #TCQ rst_sync_int1;
       end
    end

  // Changed sensitivity list to use DFT muxed reset trigger
  always @(posedge clk or posedge dft_reset_counter_trigger) begin
    // Internal reset condition remains based on functional reset
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule