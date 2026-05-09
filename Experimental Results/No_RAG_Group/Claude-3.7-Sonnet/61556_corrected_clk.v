`timescale 1ps/1ps
module Clock50MHz_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         CLK_REF,      // Added primary input clock reference
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
  wire           clk;
  reg  [C_W-1:0] counter;
  Clock50MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (),        // Removed internal clock generation
    .LOCKED             (LOCKED));
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (CLK_REF),     // Using primary input clock
    .C1 (~CLK_REF),    // Using inverted primary input clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
    always @(posedge CLK_REF or posedge reset_int) begin
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
  always @(posedge CLK_REF or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule