module ALU(opcode,funct,in1,in2,result,rw,clk);
  input clk;
  input [5:0] opcode, funct;
  input [31:0] in1, in2;
  output [31:0] result; 
  reg [31:0] result;
  output rw;
  reg rw;
  
  wire [31:0] sum, diff, product, sum_or;
  wire carry, carryout;
  
  thirtytwobitadder ADD(in1, in2, 1'b0, sum, carryout);
  thirtytwobitsubtractor SUBTRACT(in1, in2, 1'b0, diff, carry);
  
  // Renamed modules to avoid Verilog keywords
  and_gate prod(in1, in2, product);
  or_gate orop(in1, in2, sum_or);

  always @(*)
  begin
    if(opcode == 6'b000000)
    begin
      if(funct == 6'b100000)
      begin
        rw = 1'b0;
        result = sum;
        rw = 1'b1;
      end
      else if(funct == 6'b100010)
      begin
        rw = 1'b0;
        result = diff;
        rw = 1'b1;
      end
      else if(funct == 6'b100100)
      begin
        rw = 1'b0;
        result = product;
        rw = 1'b1;
      end
      else if(funct == 6'b100101)
      begin
        rw = 1'b0;
        result = sum_or;
        rw = 1'b1;
      end
    end
    
    if(opcode == 6'b100011)
    begin
      rw = 1'b0;
      result = sum;
      rw = 1'b1;
    end
    
    if(opcode == 6'b101011)
    begin
      rw = 1'b0;
      result = sum;
    end
    
    if(opcode == 6'b000100)
    begin
      rw = 1'b0;
      if(diff == 32'b0)
      begin
        result = diff;
      end
    end
  end
endmodule