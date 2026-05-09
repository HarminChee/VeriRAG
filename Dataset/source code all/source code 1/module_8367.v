module Ram
  #(
      parameter ADDR_WIDTH = 4,
      parameter DATA_WIDTH = 8,
      parameter MEM_DEPTH = 64
  )(
  input clk,
  input[ADDR_WIDTH-1:0] addrA,
  input[ADDR_WIDTH-1:0] addrB,
  input wr_enaA,
  input wr_enaB,
  input[DATA_WIDTH-1:0] ram_inA,
  input[DATA_WIDTH-1:0] ram_inB,
  output reg[DATA_WIDTH-1:0] ram_outA,
  output reg[DATA_WIDTH-1:0] ram_outB
  );
  reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
  always@(posedge clk)
  begin:Port_One
    if(wr_enaA == 1'b1)
    begin:MEM_WRITE
        mem[addrA] <= ram_inA;
    end       
    ram_outA <= mem[addrA];  
  end
  always@(posedge clk)
  begin:Port_Two
    if(wr_enaB == 1'b1)
    begin:MEM_WRITE
        mem[addrB] <= ram_inB;
    end       
    ram_outB <= mem[addrB];  
  end
endmodule
