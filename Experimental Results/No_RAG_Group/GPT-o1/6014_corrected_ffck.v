`timescale 1ns / 1ps

module Freq_Count_Top_corrected_ffc(
    input               sys_clk_50m,
    input               ch_c,
    output  reg [63:0]  freq_reg,
    input               sys_rst_n
    );

    parameter   HIGH_TIME_Gate_1S  = 50_000_000;
    parameter   LOW_TIME_Gate_1S   = 100_000_000;

    reg [31:0]  count;
    reg         Gate_1S;
    reg         EN_FT;
    reg         CLR;
    wire        Load;
    reg [63:0]  FT_out;

    // Synchronize and detect rising edge of ch_c
    reg ch_c_reg1, ch_c_reg2;
    always @(posedge sys_clk_50m or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            ch_c_reg1 <= 1'b0;
            ch_c_reg2 <= 1'b0;
        end else begin
            ch_c_reg1 <= ch_c;
            ch_c_reg2 <= ch_c_reg1;
        end
    end
    wire rising_ch_c = (ch_c_reg1 & ~ch_c_reg2);

    // Generate Gate_1S
    always @(posedge sys_clk_50m or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            count  <= 32'b0;
            Gate_1S <= 1'b0;
        end else begin
            count <= count + 1'b1;
            if(count == HIGH_TIME_Gate_1S)
                Gate_1S <= 1'b0;
            else if(count == LOW_TIME_Gate_1S) begin
                count  <= 32'b1;
                Gate_1S <= 1'b1;
            end
        end
    end

    // CLR, EN_FT logic moved to sys_clk_50m domain, updating on rising_ch_c
    always @(posedge sys_clk_50m or negedge sys_rst_n) begin
        if(!sys_rst_n)
            CLR <= 1'b0;
        else if(rising_ch_c)
            CLR <= Gate_1S | EN_FT;
    end

    always @(posedge sys_clk_50m or negedge sys_rst_n) begin
        if(!sys_rst_n)
            EN_FT <= 1'b0;
        else if(rising_ch_c)
            EN_FT <= Gate_1S;
    end

    // FT_out counter under sys_clk_50m, reset by CLR
    always @(posedge sys_clk_50m or negedge sys_rst_n) begin
        if(!sys_rst_n)
            FT_out <= 64'b0;
        else if(!CLR)
            FT_out <= 64'b0;
        else if(rising_ch_c && EN_FT)
            FT_out <= FT_out + 1'b1;
    end

    assign Load = !EN_FT;

    // Update freq_reg on sys_clk_50m when Load is active
    always @(posedge sys_clk_50m or negedge sys_rst_n) begin
        if(!sys_rst_n)
            freq_reg <= 64'b0;
        else if(Load)
            freq_reg <= FT_out;
    end

endmodule