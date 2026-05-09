`timescale 1ns / 1ps
module PdmDes(
    input clk,
    input en,
    input test_mode,
    output done,
    output reg [15:0] dout,
    output pdm_m_clk_o,
    input pdm_m_data_i
    );

parameter C_PDM_FREQ_HZ=2000000;
reg en_int=0;
reg done_int=0;
reg clk_int=0;
reg pdm_clk_rising;
reg [15:0] pdm_tmp;
integer cnt_bits=0;
integer cnt_clk=0;

assign done = done_int;
assign pdm_m_clk_o = clk_int;

always @(posedge clk)
    en_int <= en;

always @(posedge clk) 
begin
    if (!en)
        pdm_tmp <= 16'd0;
    else if (pdm_clk_rising)
        pdm_tmp <= {pdm_tmp[14:0], pdm_m_data_i};
end

always @(posedge clk)
begin
    if (!en_int)
        cnt_bits <= 0;
    else if (pdm_clk_rising)
    begin
        if (cnt_bits == 15)
            cnt_bits <= 0;
        else
            cnt_bits <= cnt_bits + 1;
    end
end

always @(posedge clk)
begin
    if (pdm_clk_rising)
    begin
        if (cnt_bits == 0)
        begin
            if (en_int)
            begin
                done_int <= 1;
                dout <= pdm_tmp;
            end
        end
    end
    else
        done_int <= 0;
end

always @(posedge clk)
begin
    if (test_mode)
    begin
        cnt_clk <= cnt_clk;
        clk_int <= clk_int;
        pdm_clk_rising <= 1'b0;
    end
    else
    begin
        if (cnt_clk == 24) 
        begin
            cnt_clk <= 0;
            clk_int <= ~clk_int;
            if (clk_int == 0)
                pdm_clk_rising <= 1'b1;
            else
                pdm_clk_rising <= 1'b0;
        end
        else
        begin
            cnt_clk <= cnt_clk + 1;
            pdm_clk_rising <= 1'b0;
        end
    end
end

endmodule