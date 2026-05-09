`define CLKDEL_PIPE_SZ 3
`define RIPPLE_DIVIDER
`ifdef USE_DIVIDER_23
  `define USE_LATCH_ENABLE 1
`endif
`define SINGLE_HS_RETIMER 1
`define CLKDEL_PIPE_SZ 3
`define RIPPLE_DIVIDER
`ifdef USE_DIVIDER_23
  `define USE_LATCH_ENABLE 1
`endif
`define SINGLE_HS_RETIMER 1
module clkctrl_phi2(
				input test_i,
				input scan_clk,
               input  hsclk_in,
               input  lsclk_in,
               input  rst_b,
               input  hsclk_sel,
               input  delay_bypass,
               input  cpuclk_div_sel,
               output hsclk_selected,
               output lsclk_selected,
               output clkout,              
               output fast_clkout          
               );
  reg                      hs_enable_q, ls_enable_q;
  reg                      selected_ls_q;
  reg                      selected_hs_q;
`ifdef SINGLE_HS_RETIMER
  reg                      retimed_ls_enable_q;
`else
  reg [1:0]                retimed_ls_enable_q;
`endif
  reg                      retimed_hs_enable_q;
  reg [`CLKDEL_PIPE_SZ-1:0] del_q;
  wire                     retimed_ls_enable_w;
  (* KEEP="TRUE" *) wire  cpuclk_w;
  (* KEEP="TRUE" *) wire  lsclk_del_w;
  assign lsclk_del_w = (delay_bypass) ? lsclk_in : del_q[0];
  assign clkout = (cpuclk_w & hs_enable_q) | (lsclk_del_w & ls_enable_q);
  assign lsclk_selected = selected_ls_q;
  assign hsclk_selected = selected_hs_q;
  assign fast_clkout = cpuclk_w;
`ifdef RIPPLE_DIVIDER
  reg                       ripple_div2_q;
  reg                       ripple_div4_q;
  `ifdef RIPPLE_DIV8
  reg                       ripple_div8_q;
  `endif
  wire dft_hsclk_in;
  assign dft_hsclk_in = test_i ? scan_clk : hsclk_in ;
  always @ ( posedge dft_hsclk_in )
    ripple_div2_q <= !ripple_div2_q;
  always @ ( posedge ripple_div2_q )
    ripple_div4_q <= !ripple_div4_q;
  `ifdef RIPPLE_DIV8
  always @ ( posedge ripple_div4_q )
    ripple_div8_q <= !ripple_div8_q;
  assign cpuclk_w = ( cpuclk_div_sel) ? ripple_div8_q : ripple_div2_q;
  `else
  assign cpuclk_w = ( cpuclk_div_sel) ? ripple_div4_q : ripple_div2_q;
  `endif
`else
  clkdiv234 divider_u ( .clkin(dft_hsclk_in),
                        .rstb(rst_b),
`ifdef USE_DIVIDER_23
                        .div4(1'b0),
                        .div3(cpuclk_div_sel==1'b1),
`else
                        .div4(cpuclk_div_sel==1'b1),
                        .div3(1'b0),
`endif
                        .div2(cpuclk_div_sel==1'b0),
                        .clkout(cpuclk_w));
`endif 
  always @ (posedge dft_hsclk_in) begin
    del_q <= { lsclk_in, del_q[`CLKDEL_PIPE_SZ-1:1]};
  end
  always @ (posedge lsclk_del_w or negedge rst_b)
    if ( ! rst_b )
      selected_ls_q <= 1'b1;
    else
      selected_ls_q <= !hsclk_sel & !retimed_hs_enable_q;
  always @ ( posedge cpuclk_w or negedge rst_b )
    if ( ! rst_b )
      selected_hs_q <= 1'b0;
    else
      selected_hs_q <= hs_enable_q;
`ifdef USE_LATCH_ENABLE
  always @ ( cpuclk_w or rst_b )
    if ( !rst_b )
      hs_enable_q <= 1'b0;
    else if ( !cpuclk_w )
      hs_enable_q <= hsclk_sel & !retimed_ls_enable_w;
`else
  always @ ( negedge dft_hsclk_in or negedge rst_b )
    if ( !rst_b )
      hs_enable_q <= 1'b0;
    else if ( !cpuclk_w )
      hs_enable_q <= hsclk_sel & !retimed_ls_enable_w;
`endif 
  always @ ( negedge lsclk_del_w or negedge rst_b )
    if ( ! rst_b )
      ls_enable_q <= 1'b1;
    else
      ls_enable_q <= !hsclk_sel & !retimed_hs_enable_q;
  always @ ( negedge  lsclk_del_w or posedge hs_enable_q )
    if ( hs_enable_q )
      retimed_hs_enable_q <= 1'b1;
    else
      retimed_hs_enable_q <= selected_hs_q;
`ifdef SINGLE_HS_RETIMER
  always @ ( negedge cpuclk_w or posedge ls_enable_q )
    if (ls_enable_q)
      retimed_ls_enable_q <= 1'b1;
    else
      retimed_ls_enable_q <= selected_ls_q;
  assign retimed_ls_enable_w = retimed_ls_enable_q;
`else
  always @ ( negedge cpuclk_w or posedge ls_enable_q )
    if (ls_enable_q)
      retimed_ls_enable_q <= 2'b11;
    else
      retimed_ls_enable_q <= {selected_ls_q, retimed_ls_enable_q[1]} ;
  assign retimed_ls_enable_w = retimed_ls_enable_q[0];
`endif 
endmodule
