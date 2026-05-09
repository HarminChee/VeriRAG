`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PdmDes(
    input clk,
    input en,
    input test_mode,
    output done,
    output [15:0] dout,
    output pdm_m_clk_o,
    input pdm_m_data_i,
    input rst_n
    );
parameter C_PDM_FREQ_HZ=2000000;
reg en_int=0;
reg done_int=0;
reg clk_int=0;
reg pdm_clk_rising;
reg [15:0] pdm_tmp;
reg [15:0] dout_reg;
integer cnt_bits=0;
integer cnt_clk=0;
wire pdm_clk;

assign done = done_int;
assign pdm_m_clk_o = clk_int;
assign pdm_clk = test_mode ? clk : clk_int;
assign dout = dout_reg;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        en_int <= 0;
    else
        en_int <= en;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n)
        pdm_tmp <= 0;
    else if (en==0)
        pdm_tmp <= 0;
    else if (pdm_clk_rising) 
        pdm_tmp <= {pdm_tmp[14:0],pdm_m_data_i};
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        cnt_bits <= 0;
    else if (en_int==0)
        cnt_bits <= 0;
    else if (pdm_clk_rising)
    begin
        if (cnt_bits == 15)
            cnt_bits <= 0;
        else
            cnt_bits <= cnt_bits + 1;
    end           
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        done_int <= 0;
        dout_reg <= 0;
    end
    else if (pdm_clk_rising) begin
        if (cnt_bits==0) begin
            if (en_int) begin
                done_int <= 1;
                dout_reg <= pdm_tmp;
            end
        end
    end
    else
        done_int <= 0;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        cnt_clk <= 0;
        clk_int <= 0;
        pdm_clk_rising <= 0;
    end
    else if (cnt_clk == 24) begin
        cnt_clk <= 0;
        clk_int <= ~clk_int;
        if (clk_int == 0)
            pdm_clk_rising <= 1;
    end
    else begin
        cnt_clk <= cnt_clk + 1;
        pdm_clk_rising <= 0;
    end
end

endmodule