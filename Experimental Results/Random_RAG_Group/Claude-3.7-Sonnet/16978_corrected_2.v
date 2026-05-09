module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         TEST_EN,
  output [0:0]  CLK_OUT,
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
  wire           clk_unbuf;
  reg            clk;
  reg  [C_W-1:0] counter;
  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));
  assign clk_n = ~clk_unbuf;
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[0]),
    .C0 (clk_unbuf),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
  always @(posedge clk_int) begin
    if (TEST_EN) begin
      clk <= #TCQ CLK_IN1;
	  clk_unbuf <= #TCQ CLK_IN1;
    end else begin
      clk <= #TCQ clk_int;
	  clk_unbuf <= #TCQ clk_int;
    end
  end
    always @(posedge clk or posedge reset_int) begin
       if (reset_int) begin
            rst_sync <= 1'b1;
            rst_sync_int <= 1'b1;
            rst_sync_int1 <= 1'b1;
            rst_sync_int2 <= 1'b1;
       end
       else begin
            rst_sync <= rst_sync_int;
            rst_sync_int <= rst_sync_int1;     
            rst_sync_int1 <= rst_sync_int2; 
            rst_sync_int2 <= rst_sync;
       end
    end
  always @(posedge clk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule