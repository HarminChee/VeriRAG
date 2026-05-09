`define CLKDEL_PIPE_SZ 3
`define RIPPLE_DIVIDER
`ifdef USE_DIVIDER_23
  `define USE_LATCH_ENABLE 1
`endif
`define SINGLE_HS_RETIMER 1

module clkctrl_phi2(
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

  always @ (posedge hsclk_in or negedge rst_b) begin
    if (!rst_b)
      ripple_div2_q <= 0;
    else
      ripple_div2_q <= ~ripple_div2_q;
  end

  always @ (posedge ripple_div2_q or negedge rst_b) begin
    if (!rst_b)
      ripple_div4_q <= 0;
    else
      ripple_div4_q <= ~ripple_div4_q;
  end

  `ifdef RIPPLE_DIV8
  always @ (posedge ripple_div4_q or negedge rst_b) begin
    if (!rst_b)
      ripple_div8_q <= 0;
    else
      ripple_div8_q <= ~ripple_div8_q;
  end
  assign cpuclk_w = (cpuclk_div_sel) ? ripple_div8_q : ripple_div2_q;
  `else
  assign cpuclk_w = (cpuclk_div_sel) ? ripple_div4_q : ripple_div2_q;
  `endif
`else
  clkdiv234 divider_u (.clkin(hsclk_in),
                       .rstb(rst_b),
`ifdef USE_DIVIDER_23
                       .div4(1'b0),
                       .div3(cpuclk_div_sel),
`else
                       .div4(cpuclk_div_sel),
                       .div3(1'b0),
`endif
                       .div2(~cpuclk_div_sel),
                       .clkout(cpuclk_w));
`endif 

  always @ (posedge hsclk_in or negedge rst_b) begin
    if (!rst_b)
      del_q <= 0;
    else
      del_q <= {lsclk_in, del_q[`CLKDEL_PIPE_SZ-1:1]};
  end

  always @ (posedge lsclk_del_w or negedge rst_b) begin
    if (!rst_b)
      selected_ls_q <= 1'b1;
    else
      selected_ls_q <= ~hsclk_sel & ~retimed_hs_enable_q;
  end

  always @ (posedge cpuclk_w or negedge rst_b) begin
    if (!rst_b)
      selected_hs_q <= 1'b0;
    else
      selected_hs_q <= hs_enable_q;
  end

`ifdef USE_LATCH_ENABLE
  always @ (posedge cpuclk_w or negedge rst_b) begin
    if (!rst_b)
      hs_enable_q <= 1'b0;
    else if (~cpuclk_w)
      hs_enable_q <= hsclk_sel & ~retimed_ls_enable_w;
  end
`else
  always @ (negedge hsclk_in or negedge rst_b) begin
    if (!rst_b)
      hs_enable_q <= 1'b0;
    else if (~cpuclk_w)
      hs_enable_q <= hsclk_sel & ~retimed_ls_enable_w;
  end
`endif 

  always @ (negedge lsclk_del_w or negedge rst_b) begin
    if (!rst_b)
      ls_enable_q <= 1'b1;
    else
      ls_enable_q <= ~hsclk_sel & ~retimed_hs_enable_q;
  end

  always @ (negedge lsclk_del_w or posedge hs_enable_q or negedge rst_b) begin
    if (!rst_b)
      retimed_hs_enable_q <= 0;
    else if (hs_enable_q)
      retimed_hs_enable_q <= 1'b1;
    else
      retimed_hs_enable_q <= selected_hs_q;
  end

`ifdef SINGLE_HS_RETIMER
  always @ (negedge cpuclk_w or posedge ls_enable_q or negedge rst_b) begin
    if (!rst_b)
      retimed_ls_enable_q <= 0;
    else if (ls_enable_q)
      retimed_ls_enable_q <= 1'b1;
    else
      retimed_ls_enable_q <= selected_ls_q;
  end
  assign retimed_ls_enable_w = retimed_ls_enable_q;
`else
  always @ (negedge cpuclk_w or posedge ls_enable_q or negedge rst_b) begin
    if (!rst_b)
      retimed_ls_enable_q <= 0;
    else if (ls_enable_q)
      retimed_ls_enable_q <= 2'b11;
    else
      retimed_ls_enable_q <= {selected_ls_q, retimed_ls_enable_q[1]};
  end
  assign retimed_ls_enable_w = retimed_ls_enable_q[0];
`endif 
endmodule