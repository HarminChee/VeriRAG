`timescale 1ps/1ps
`timescale 1ps/1ps
module clk32to40_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i, // Added test mode input
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  wire          reset_int = COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  reg  [C_W-1:0] counter;
  wire dft_counter_reset; // Muxed reset for counter

  clk32to40 clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int));

  assign clk = clk_int;
  assign clk_n = ~clk;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0), // Tied inactive
    .S  (1'b0)); // Tied inactive

   // Reset synchronizer (using primary reset asynchronously is OK)
   always @(posedge clk or posedge reset_int) begin
       if (reset_int) begin
            rst_sync <= 1'b1;
            rst_sync_int <= 1'b1;
            rst_sync_int1 <= 1'b1;
            rst_sync_int2 <= 1'b1;
       end
       else begin
            rst_sync <= 1'b0;
            rst_sync_int <= rst_sync;
            rst_sync_int1 <= rst_sync_int;
            rst_sync_int2 <= rst_sync_int1; // Synchronized active-high reset
       end
   end

  // Select primary reset in test mode, synchronized reset in functional mode
  assign dft_counter_reset = test_i ? reset_int : rst_sync_int2;

  // Counter logic with synchronous, test-controllable reset
  always @(posedge clk) begin // Changed to synchronous reset
    if (dft_counter_reset) begin // Use the muxed reset signal
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule