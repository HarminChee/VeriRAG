`timescale 1ns / 1ps
`timescale 1ns / 1ps
module top( input clk, 
            output reg [3:0] led,
            input  [3:0] btn,
            input  [3:0] sw );
 reg [7:0] A;
 reg [3:0] B;
wire [3:0] Q;
wire [3:0] R;
div inst( .clk(clk),
          .A(A),
          .B(B),
          .Q(Q),
          .R(R)
         );
always @(posedge clk)
begin
    if(btn[3]) A[7:4] <= sw[3:0];
    if(btn[2]) A[3:0] <= sw[3:0];
    if(btn[1]) B[3:0] <= sw[3:0];
    if(btn[0]) led[3:0] <= R[3:0];
    else       led[3:0] <= Q[3:0];
end
endmodule
