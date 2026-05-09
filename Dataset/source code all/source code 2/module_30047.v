module Servo #(
  parameter CLK_FREQUENCY = 50000000,
  parameter VALUE_SCALING = 256,
  parameter CTR_LEN = 21,
  parameter SPEED_DATA_LEN = 5,
  parameter POSITION_DATA_LEN = 8,  
  parameter ADDR_LEN = 8,
  parameter MAX_RAM_POS = 256,
  parameter DATA_LEN = 13
)(
input  clk,
input  rst,
input  [DATA_LEN-1:0] data,
output reg [ADDR_LEN-1:0] address,
output reg servo_q
);
wire[CTR_LEN-1:0] freq;
wire[SPEED_DATA_LEN-1:0] speed;
assign speed = data[POSITION_DATA_LEN+:SPEED_DATA_LEN-1];
assign freq = CLK_FREQUENCY*(speed/1000.0);
reg[CTR_LEN-1:0] ctr;
always@(posedge clk)begin
  if(rst)begin
    address<= '0;
    ctr <= '0;
  end else begin
    ctr = ctr + 1'b1;
    if(ctr>=freq )begin
      if(address!=MAX_RAM_POS-1)begin
        address <= address+1'b1;
      end
      ctr = '0;
    end
  end
end
wire[POSITION_DATA_LEN-1:0] pos;
wire[CTR_LEN-1-8:0] pulseCount ;
assign pos = data[0+:POSITION_DATA_LEN-1];
assign pulseCount = ctr[8+:CTR_LEN-1];
always @(posedge clk) begin
  servo_q = pulseCount < (pos + 9'd165) ;
end
endmodule
