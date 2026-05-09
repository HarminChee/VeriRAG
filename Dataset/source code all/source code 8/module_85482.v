`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Decoder
#
(
    parameter OutputWidth = 4
)
(
    I,
    O
);
    input   [$clog2(OutputWidth) - 1:0] I;
    output  [OutputWidth - 1:0]         O;
    reg     [OutputWidth - 1:0]         rO;
    genvar c;
    generate
        for (c = 0; c < OutputWidth; c = c + 1)
        begin: DecodeBits
            always @ (*)
            begin
                if (I == c)
                    rO[c] <= 1'b1;
                else
                    rO[c] <= 1'b0;
            end
        end
    endgenerate
    assign O = rO;
endmodule
