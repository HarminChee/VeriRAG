`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module rp_adc #
(
)
(
  input    [ 14-1: 0] adc_dat_a_i        ,  
  input    [ 14-1: 0] adc_dat_b_i        ,  
  input               adc_clk            ,
  output [ 2-1: 0]    adc_clk_source     ,  
  output              adc_cdcs_o         ,  
  output   [ 14-1: 0] adc_dat_a_o        ,  
  output   [ 14-1: 0] adc_dat_b_o        ,  
  input               adc_rst_i             
);
  assign adc_cdcs_o = 1'b1 ;
  assign adc_clk_source = 2'b10;
  reg  [14-1: 0] adc_dat_a  ;
  reg  [14-1: 0] adc_dat_b  ;
  always @(posedge adc_clk) begin
     adc_dat_a <= adc_dat_a_i[14-1:0]; 
     adc_dat_b <= adc_dat_b_i[14-1:0];
  end
  assign adc_dat_a_o = {adc_dat_a[14-1], ~adc_dat_a[14-2:0]}; 
  assign adc_dat_b_o = {adc_dat_b[14-1], ~adc_dat_b[14-2:0]};
endmodule
