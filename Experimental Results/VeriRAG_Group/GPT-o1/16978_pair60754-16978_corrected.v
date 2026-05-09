`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes 
#( 
  parameter TCQ = 100
)
(
  input  wire       test_i,
  input  wire       CLK_IN1,
  input  wire       COUNTER_RESET,
  output wire [1:1] CLK_OUT,
  output wire       COUNT,
  output wire       LOCKED
);

  localparam C_W = 16;

  wire clk_int;
  wire dft_clk_int;
  wire dft_clk_n;
  wire reset_int = ~LOCKED || COUNTER_RESET;
  reg  [C_W-1:0] counter;

  Clock70MHz clknetwork
   (
    .CLK_IN1  (CLK_IN1),
    .CLK_OUT1 (clk_int),
    .LOCKED   (LOCKED)
   );

  assign dft_clk_int = test_i ? CLK_IN1 : clk_int;
  assign dft_clk_n   = ~dft_clk_int;

  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (dft_clk_int),
    .C1 (dft_clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  always @(posedge dft_clk_int) begin
    if (reset_int) begin
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule