module mux4(input wire clk, output reg [3:0] data);
parameter NP = 23;         
parameter VAL0 = 4'b0000;  
parameter VAL1 = 4'b1010;  
parameter VAL2 = 4'b1111;  
parameter VAL3 = 4'b0101;  
reg [3:0] val0;
reg [3:0] val1;
reg [3:0] val2;
reg [3:0] val3;
reg [1:0] sel;  
reg [1:0] count = 0;
wire clk_pres; 

initial begin
  val0 = VAL0;
  val1 = VAL1;
  val2 = VAL2;
  val3 = VAL3;
end

always@*
  case (sel)
     2'b00 : data <= val0;
     2'b01 : data <= val1;
     2'b10 : data <= val2;
     2'b11 : data <= val3;
     default : data <= 4'b0000;
  endcase

always @(posedge clk_pres)
  count <= count + 1;

always @*
  sel = count;

prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );
endmodule