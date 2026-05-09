`timescale 1ps/1ps
module dcm_exdes
 #(
  parameter TCQ = 100
  )
 (
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
  // wire           clk_int; // Removed - internal clock
  // wire           clk_n; // Removed - internal clock
  // wire           clk; // Removed - internal clock
  reg  [C_W-1:0] counter;

  // dcm clknetwork // Removed - internal clock generation violates CLKNPI/FFCKNP
  //  (
  //   .CLK_IN            (CLK_IN1),
  //   .CLK_OUT           (clk_int));

  // assign clk_n = ~clk; // Removed
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (CLK_IN1), // Changed clock to PI
    .C1 (~CLK_IN1), // Changed clock to PI inverted
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
  // assign clk = clk_int; // Removed

    // Changed clock to CLK_IN1 (PI)
    always @(posedge reset_int or posedge CLK_IN1) begin
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

  // Changed clock to CLK_IN1 (PI)
  // Changed async reset to reset_int (derived from PI) to fix ACNCPI
  always @(posedge CLK_IN1 or posedge reset_int) begin
    if (reset_int) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule