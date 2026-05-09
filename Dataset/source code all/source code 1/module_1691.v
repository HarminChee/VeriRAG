module SRAM(read,    
            write,   
            address, 
            dataIn,  
            dataOut, 
            clk      
);
  parameter bits = 8;
  parameter depth = 3;
  parameter ad_length = 1<<depth;
  input read;
  input write;
  input [depth-1:0] address; 
  input [bits-1:0] dataIn;
  output [bits-1:0] dataOut;
  reg [bits-1:0] dataOut;
  input clk;
  reg [bits-1:0] memArray [ad_length-1:0];
  always @(posedge clk) begin
    if(write)
      memArray[address] <= dataIn;
    if(read)
      dataOut <= memArray[address];
    if (read & write) begin
      $display("ERROR: simultaneous read and write to memory");
      dataOut <= {bits{1'bx}};
      $stop;
    end
  end
endmodule
