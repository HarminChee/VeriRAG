module Clock65MHz_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         test_i,
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W = 16;
  wire          clk_int;
  wire          clk_n;
  wire          clk;
  wire          dft_clk;
  reg  [C_W-1:0] counter;

  Clock65MHz clknetwork
   (
    .CLK_IN1  (CLK_IN1),
    .CLK_OUT1 (clk_int),
    .LOCKED   (LOCKED)
   );

  assign dft_clk = test_i ? CLK_IN1 : clk_int;
  assign clk_n   = ~clk;
  assign clk     = dft_clk;

  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  always @(posedge clk) begin
    if (!LOCKED || COUNTER_RESET) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule