`timescale 1ns / 1ps
module PdmDes(
    input clk,
    input en,
    input rst,
    input test_i,
    output done,
    output [15:0] dout,
    output pdm_m_clk_o,
    input pdm_m_data_i
    );
parameter C_PDM_FREQ_HZ=2000000;
reg en_int=0;
reg done_int=0;
reg clk_int=0;
reg pdm_clk_rising;
reg [15:0] pdm_tmp, dout;
integer cnt_bits=0;
integer cnt_clk=0;
wire dft_clk;
assign done = done_int;
assign pdm_m_clk_o = clk_int;
assign dft_clk = test_i ? clk : clk_int;
always @(posedge clk or posedge rst)
    if (rst)
        en_int <= 0;
    else
        en_int <= en;
always @(posedge clk or posedge rst) 
    if (rst)
        pdm_tmp <= 0;
    else if (en == 0)
        pdm_tmp <= 0;
    else if (pdm_clk_rising) 
        pdm_tmp <= {pdm_tmp[14:0], pdm_m_data_i};
always @(posedge clk or posedge rst)
    if (rst)
        cnt_bits <= 0;
    else if (en_int == 0)
        cnt_bits <= 0;
    else if (pdm_clk_rising)
        if (cnt_bits == 15)
            cnt_bits <= 0;
        else
            cnt_bits <= cnt_bits + 1;
always @(posedge clk or posedge rst)
    if (rst)
        done_int <= 0;
    else if (pdm_clk_rising)
        if (cnt_bits == 0)
            if (en_int)
            begin
                done_int <= 1;
                dout <= pdm_tmp;
            end
        else
            done_int <= 0;
    else
        done_int <= 0;
always @(posedge clk or posedge rst)
    if (rst)
    begin
        cnt_clk <= 0;
        clk_int <= 0;
        pdm_clk_rising <= 0;
    end
    else if (cnt_clk == 24) 
    begin
        cnt_clk <= 0;
        clk_int <= ~clk_int;
        if (clk_int == 0)
            pdm_clk_rising <= 1;
        else
            pdm_clk_rising <= 0;
    end
    else
    begin
        cnt_clk <= cnt_clk + 1;
        pdm_clk_rising <= 0;
    end
endmodule