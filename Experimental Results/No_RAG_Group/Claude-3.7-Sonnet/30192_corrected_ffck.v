Here's the modified Verilog code:


`timescale 1ns / 1ps
module ps2_receiver(
    input wire clk, clr,
    input wire ps2c, ps2d,
    output wire [15:0] xkey
);
    reg [7:0] ps2c_filter, ps2d_filter;
    reg [10:0] shift1, shift2;
    wire PS2Cf, PS2Df;

    assign xkey = {shift2[8:1], shift1[8:1]};
    assign PS2Cf = (ps2c_filter == 8'b1111_1111) ? 1'b1 :
                   (ps2c_filter == 8'b0000_0000) ? 1'b0 : PS2Cf;
    assign PS2Df = (ps2d_filter == 8'b1111_1111) ? 1'b1 :
                   (ps2d_filter == 8'b0000_0000) ? 1'b0 : PS2Df;

    always @(posedge clk or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            ps2c_filter <= 8'b0;
            ps2d_filter <= 8'b0;
        end
        else
        begin
            ps2c_filter <= {ps2c, ps2c_filter[7:1]};
            ps2d_filter <= {ps2d, ps2d_filter[7:1]};
        end
    end

    always @(negedge clk or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            shift1 <= 11'b0;
            shift2 <= 11'b1;
        end
        else if (!PS2Cf)
        begin
            shift1 <= {PS2Df, shift1[10:1]};
            shift2 <= {shift1[0], shift2[10:1]};
        end
    end
endmodule