module Freq_Count_Top(
    input           sys_clk_50m,
    input           ch_c,
    output  reg [63:0]  freq_reg,
    input           sys_rst_n
    );

    reg     Gate_1S;
    wire    Load;
    reg     EN_FT;
    reg [31:0] count;
    reg [63:0] FT_out;

    parameter   HIGH_TIME_Gate_1S   = 50_000_000;
    parameter   LOW_TIME_Gate_1S    = 100_000_000;

    always @(posedge sys_clk_50m or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            count <= 32'b0;
            Gate_1S <= 1'b0;
        end else begin
            count <= count + 1'b1;
            if (count == HIGH_TIME_Gate_1S)
                Gate_1S <= 1'b0;
            else if (count == LOW_TIME_Gate_1S) begin
                count <= 32'b1;
                Gate_1S <= 1'b1;
            end
        end
    end

    always @(posedge ch_c or negedge sys_rst_n) begin
        if (!sys_rst_n)
            EN_FT <= 1'b0;
        else
            EN_FT <= Gate_1S;
    end

    always @(posedge ch_c or negedge sys_rst_n) begin
        if (!sys_rst_n)
            FT_out <= 64'b0;
        else if ((Gate_1S == 1'b0) && (EN_FT == 1'b0))
            FT_out <= 64'b0;
        else if (EN_FT)
            FT_out <= FT_out + 1'b1;
    end

    assign Load = ~EN_FT;

    always @(posedge Load or negedge sys_rst_n) begin
        if (!sys_rst_n)
            freq_reg <= 64'b0;
        else
            freq_reg <= FT_out;
    end

endmodule