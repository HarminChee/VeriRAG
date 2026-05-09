`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pending_comp_ram_32x1(    
          input clk,
          input d_in,
          input [4:0] addr,
          input we,
          output reg [31:0] d_out = 32'h00000000
       );
    wire [31:0] addr_decode;
    assign addr_decode[31:0] = 32'h00000001 << addr[4:0]; 
    genvar i;
    generate
    for(i=0;i<32;i=i+1)begin: bitram
        always@(posedge clk)begin
           if(addr_decode[i] && we)begin
              d_out[i] <= d_in;
           end
        end                           
    end
    endgenerate
endmodule
