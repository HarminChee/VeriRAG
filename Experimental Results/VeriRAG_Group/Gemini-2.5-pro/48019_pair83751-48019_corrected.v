`timescale 1ps/1ps
`timescale 1ps/1ps
module dcm_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i,
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
  wire           dft_clk_n,clk_n;
  wire           dft_clk,clk;
  wire           dft_counter_reset;
  reg  [C_W-1:0] counter;
  dcm clknetwork
   (
    .CLK_IN            (CLK_IN1),
    .CLK_OUT           (clk_int));

  assign clk = clk_int;
  assign clk_n = ~clk;

  assign dft_clk = test_i ? CLK_IN1 : clk;
  assign dft_clk_n = test_i ? ~CLK_IN1 : clk_n;
  assign dft_counter_reset = test_i ? reset_int : rst_sync_int2;


  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (dft_clk),
    .C1 (dft_clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0), // Assuming R/S are tied off for DFT compliance if not PI controlled
    .S  (1'b0));


    // Use standard async reset structure: posedge clock or posedge async_reset (active high)
    always @(posedge dft_clk or posedge reset_int) begin // reset_int is PI COUNTER_RESET
       if (reset_int) begin
            rst_sync <= #TCQ 1'b1;
            rst_sync_int <= #TCQ 1'b1;
            rst_sync_int1 <= #TCQ 1'b1;
            rst_sync_int2 <= #TCQ 1'b1;
       end
       else begin
            // Synchronizer chain logic for reset deassertion propagation
            rst_sync <= #TCQ 1'b0;
            rst_sync_int <= #TCQ rst_sync;
            rst_sync_int1 <= #TCQ rst_sync_int;
            rst_sync_int2 <= #TCQ rst_sync_int1;
       end
    end

  // Use dft_clk and the muxed reset dft_counter_reset
  always @(posedge dft_clk or posedge dft_counter_reset) begin
    if (dft_counter_reset) begin // Active high reset
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];
endmodule