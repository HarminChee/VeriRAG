`timescale 1ns / 1ps
module PdmDes(
    input clk,
    input test_mode,
    input en,
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

assign done = done_int;
assign pdm_m_clk_o = clk_int;

always @(posedge clk)
    en_int <= en;

always @(posedge clk) 
  if (en==0)
    pdm_tmp <= 0;
  else if (test_mode)
    pdm_tmp <= {pdm_tmp[14:0], pdm_m_data_i};
  else if (pdm_clk_rising)
    pdm_tmp <= {pdm_tmp[14:0], pdm_m_data_i};

always @(posedge clk)
begin
  if (en_int==0)
    cnt_bits <=0;
  else if (test_mode)
    cnt_bits <= (cnt_bits == 15) ? 0 : cnt_bits + 1;
  else if (pdm_clk_rising)
    cnt_bits <= (cnt_bits == 15) ? 0 : cnt_bits + 1;
end

always @(posedge clk)
begin
  if (test_mode) begin
    if (cnt_bits==0 && en_int) begin
      done_int <= 1;
      dout <= pdm_tmp;
    end
    else begin
      done_int <= 0;
    end
  end
  else if (pdm_clk_rising) begin
    if (cnt_bits==0 && en_int) begin
      done_int <= 1;
      dout <= pdm_tmp;
    end
    else begin
      done_int <= 0;
    end
  end
  else begin
    done_int <= 0;
  end
end

always @(posedge clk)
begin
  if (test_mode) begin
    cnt_clk <= 0;
    clk_int <= 0;
    pdm_clk_rising <= 0;
  end
  else if (cnt_clk == 24) begin
    cnt_clk <= 0;
    clk_int <= ~clk_int;
    pdm_clk_rising <= (clk_int == 0);
  end
  else begin
    cnt_clk <= cnt_clk + 1;
    pdm_clk_rising <= 0;
  end
end

endmodule