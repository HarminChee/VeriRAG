`timescale 1ps/1ps
module Clock35MHz_exdes_corrected_clk 
#( 
  parameter TCQ = 100
)
(
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
);

  localparam C_W = 16;

  // Tie LOCKED high for simplicity (removing internally generated clock dependency)
  assign LOCKED    = 1'b1;
  wire reset_int   = !LOCKED || COUNTER_RESET;  // effectively COUNTER_RESET

  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2;
  reg [C_W-1:0] counter;

  wire clk_n = ~CLK_IN1;

  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (CLK_IN1),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  always @(posedge reset_int or posedge CLK_IN1) begin
    if (reset_int) begin
      rst_sync       <= 1'b1;
      rst_sync_int   <= 1'b1;
      rst_sync_int1  <= 1'b1;
      rst_sync_int2  <= 1'b1;
    end else begin
      rst_sync       <= 1'b0;
      rst_sync_int   <= rst_sync;
      rst_sync_int1  <= rst_sync_int;
      rst_sync_int2  <= rst_sync_int1;
    end
  end

  always @(posedge CLK_IN1 or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule