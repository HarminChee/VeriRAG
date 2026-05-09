`timescale 1ns/1ns
`timescale 1ns/1ns
module register
    #(parameter C_WIDTH = 1,
      parameter C_VALUE = 0
      )
    (input CLK,
     input                RST_IN,
     output [C_WIDTH-1:0] RD_DATA,
     input [C_WIDTH-1:0]  WR_DATA,
     input                WR_EN
     );
    reg [C_WIDTH-1:0]     rData;
    assign RD_DATA = rData;
    always @(posedge CLK) begin
        if(RST_IN) begin
            rData <= C_VALUE;
        end else if(WR_EN) begin
            rData <= WR_DATA;
        end 
    end
endmodule
