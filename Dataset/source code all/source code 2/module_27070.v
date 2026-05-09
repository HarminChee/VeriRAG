`timescale 1ns/1ps
`timescale 1ns/1ps
module minimac_graycounter
   #(parameter   COUNTER_WIDTH = 2)
    (output reg  [COUNTER_WIDTH-1:0]    GrayCount_out,  
     input wire                         Enable_in,  
     input wire                         Clear_in,   
     input wire                         Clk);
    reg    [COUNTER_WIDTH-1:0]         BinaryCount;
    always @ (posedge Clk)
        if (Clear_in) begin
            BinaryCount   <= {COUNTER_WIDTH{1'b 0}} + 1;  
            GrayCount_out <= {COUNTER_WIDTH{1'b 0}};      
        end
        else if (Enable_in) begin
            BinaryCount   <= BinaryCount + 1;
            GrayCount_out <= {BinaryCount[COUNTER_WIDTH-1],
                              BinaryCount[COUNTER_WIDTH-2:0] ^ BinaryCount[COUNTER_WIDTH-1:1]};
        end
endmodule
