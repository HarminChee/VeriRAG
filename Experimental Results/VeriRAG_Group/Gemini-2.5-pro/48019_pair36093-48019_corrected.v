`timescale 1ps/1ps
module dcm_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  input         test_i // Added test mode input
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

  // DFT Mux signals
  wire           dft_clk;
  wire           dft_clk_n;
  wire           dft_counter_reset;

  assign dft_clk = test_i ? CLK_IN1 : clk; // Mux for clock
  assign dft_clk_n = test_i ? ~CLK_IN1 : clk_n; // Mux for inverted clock
  assign dft_counter_reset = test_i ? COUNTER_RESET : rst_sync_int2; // Mux for counter reset

  dcm clknetwork
   (
    .CLK_IN            (CLK_IN1),
    .CLK_OUT           (clk_int));
    
  assign clk = clk_int; // Original clock assignment
  assign clk_n = ~clk; // Original inverted clock assignment

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (dft_clk),     // Use muxed clock
    .C1 (dft_clk_n),   // Use muxed inverted clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

    // Reset synchronizer - Clocked by muxed clock, Async reset by primary input
    always @(posedge dft_clk or posedge reset_int) begin // Use muxed clock, primary reset
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
            rst_sync_int2 <= rst_sync_int1;
       end
    end

  // Counter - Clocked by muxed clock, Async reset by muxed reset
  always @(posedge dft_clk or posedge dft_counter_reset) begin // Use muxed clock and muxed reset
    if (dft_counter_reset) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule