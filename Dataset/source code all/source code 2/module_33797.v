module GEN( input wire  CLK_IN,
            input wire  RST_X_IN,
            output wire CLK_OUT,
            output wire VGA_CLK_OUT,
            output wire RST_X_OUT
            );
    wire                LOCKED, VLOCKED, CLK_IBUF;
    wire                RST_X_BUF;
    clk_wiz_0 clkgen(CLK_IN, CLK_OUT, VGA_CLK_OUT, LOCKED);
    RSTGEN rstgen(CLK_OUT, (RST_X_IN & LOCKED), RST_X_OUT);
endmodule
module RSTGEN(CLK, RST_X_I, RST_X_O);
    input  CLK, RST_X_I;
    output RST_X_O;
    reg [23:0] cnt;
    assign RST_X_O = cnt[23];
    always @(posedge CLK or negedge RST_X_I) begin
        if      (!RST_X_I) cnt <= 0;
        else if (~RST_X_O) cnt <= (cnt + 1'b1);
    end
endmodule
