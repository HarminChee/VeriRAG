module mux4(
  input wire clk,
  input wire rst_n,
  output reg [3:0] data
);

parameter NP = 23;         
parameter VAL0 = 4'b0000;  
parameter VAL1 = 4'b1010;  
parameter VAL2 = 4'b1111;  
parameter VAL3 = 4'b0101;  

wire [3:0] val0;
wire [3:0] val1;
wire [3:0] val2;
wire [3:0] val3;
wire [1:0] sel;
reg [1:0] count;

assign val0 = VAL0;
assign val1 = VAL1;
assign val2 = VAL2;
assign val3 = VAL3;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    count <= 2'b00;
  else
    count <= count + 1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    data <= 4'b0000;
  else
    case (sel)
      2'b00 : data <= val0;
      2'b01 : data <= val1;
      2'b10 : data <= val2;
      2'b11 : data <= val3;
      default : data <= 4'b0000;
    endcase
end

assign sel = count;

endmodule