`timescale 1ns / 10ps
`timescale 1ns / 10ps
module gry_cntr #(WIDTH = 8)
  (
    clk,
    rst_n,
    rst_val,
    en,
    gry_cnt,
    gry_cnt_nxt
  );
  input                       clk;
  input                       rst_n;
  input   [WIDTH-1:0]         rst_val;
  input                       en;
  output  [WIDTH-1:0]         gry_cnt;
  output  [WIDTH-1:0]         gry_cnt_nxt;
  reg     [WIDTH-1:0]         gry_cnt;
  reg     [WIDTH-1:0]         gry_cnt_nxt;
  reg     [WIDTH-1:0]         bin_cnt_f;
  reg     [WIDTH-1:0]         rst_val2bin_c;
  reg     [WIDTH-1:0]         bin_cnt_nxt_c;
  genvar  i;
  generate
    for(i=WIDTH-1;  i>=0; i--)
    begin : RST_VAL2BIN
      assign  rst_val2bin_c[i]  = ^rst_val[WIDTH-1:i];
    end
  endgenerate
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      bin_cnt_f               <=  rst_val2bin_c;
      gry_cnt                 <=  rst_val;
    end
    else
    begin
      bin_cnt_f               <=  bin_cnt_nxt_c;
      gry_cnt                 <=  gry_cnt_nxt;
    end
  end
  assign  bin_cnt_nxt_c = bin_cnt_f + en;
  assign  gry_cnt_nxt   = bin_cnt_nxt_c ^ {1'b0,bin_cnt_nxt_c[WIDTH-1:1]};
endmodule 
