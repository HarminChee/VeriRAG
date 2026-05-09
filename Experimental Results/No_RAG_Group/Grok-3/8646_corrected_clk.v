`timescale 1ps/1ps
module clk_wiz_v3_6_exdes_corrected_clk 
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
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;
  wire          clk_in1_buf;
  wire          clk_n;
  reg           clk_reg;
  reg  [C_W-1:0] counter;
  
  BUFG clkin1_buf
   (.O (clk_in1_buf),
    .I (CLK_IN1));
    
  assign clk_n = ~clk_in1_buf;
  
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk_in1_buf),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
    
  always @(posedge clk_in1_buf or posedge reset_int) begin
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
  
  always @(posedge clk_in1_buf or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end
  
  assign COUNT = counter[C_W-1];
endmodule