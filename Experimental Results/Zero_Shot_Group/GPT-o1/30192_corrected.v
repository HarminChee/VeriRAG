`timescale 1ns / 1ps
module ps2_receiver(
    input wire clk, clr,
    input wire ps2c, ps2d,
    output wire [15:0] xkey
    );
    reg PS2Cf, PS2Df;
    reg [7:0] ps2c_filter, ps2d_filter;
    reg [10:0] shift1, shift2;

    assign xkey = {shift2[8:1], shift1[8:1]};

    always @(posedge clk or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            ps2c_filter <= 8'b0;
            ps2d_filter <= 8'b0;
            PS2Cf       <= 1'b1;
            PS2Df       <= 1'b1;
        end
        else
        begin
            ps2c_filter <= {ps2c, ps2c_filter[7:1]};
            ps2d_filter <= {ps2d, ps2d_filter[7:1]};
            if (ps2c_filter == 8'b11111111)
                PS2Cf <= 1'b1;
            else if (ps2c_filter == 8'b00000000)
                PS2Cf <= 1'b0;
            if (ps2d_filter == 8'b11111111)
                PS2Df <= 1'b1;
            else if (ps2d_filter == 8'b00000000)
                PS2Df <= 1'b0;
        end
    end

    always @(negedge PS2Cf or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            shift1 <= 11'b0;
            shift2 <= 11'b0;
        end
        else
        begin
            shift1 <= {PS2Df, shift1[10:1]};
            shift2 <= {shift1[0], shift2[10:1]};
        end
    end
endmodule