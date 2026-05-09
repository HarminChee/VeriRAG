`timescale 1 ps / 1 ps
module dvi_gen_top (
  input  wire        rst_n_pad_i,
  input  wire        dvi_clk_i,
  input  wire        test_i,
  input  wire        scan_clk,
  input  wire [15:0] hlen,
  input  wire [15:0] vlen,
  output wire [3:0]  TMDS,
  output wire [3:0]  TMDSB,
  output wire        pclk_o,
  input  wire        hsync_i, 
  input  wire        vsync_i, 
  input  wire        blank_i, 
  input  wire [7:0]  red_data_i,
  input  wire [7:0]  green_data_i,
  input  wire [7:0]  blue_data_i
);

  wire          locked;
  wire          reset;
  wire          clk50m, clk50m_bufg;
  wire          pwrup;
  assign clk50m = dvi_clk_i;

  wire dft_clk50m = test_i ? scan_clk : clk50m;
  wire dft_clk50m_bufg = test_i ? scan_clk : clk50m_bufg;
  wire dft_pclk = test_i ? scan_clk : pclk;
  wire dft_pclkx2 = test_i ? scan_clk : pclkx2;

  BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));

  wire pclk_lckd;
  wire RSTBTN;
  assign RSTBTN = ~rst_n_pad_i;

  SRL16E #(.INIT(16'h1)) pwrup_0 (
    .Q(pwrup),
    .A0(1'b1),
    .A1(1'b1), 
    .A2(1'b1),
    .A3(1'b1),
    .CE(pclk_lckd),
    .CLK(dft_clk50m_bufg),
    .D(1'b0)
  );

  wire busy;
  reg switch = 1'b0;
  reg [15:0] hlen_q, vlen_q;

  always @ (posedge dft_clk50m_bufg)
  begin
    switch <= pwrup | ({hlen_q,vlen_q} != {hlen,vlen});
  end

  wire gopclk;
  SRL16E SRL16E_0 (
    .Q(gopclk),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(1'b1),
    .CLK(dft_clk50m_bufg),
    .D(switch)
  );
  defparam SRL16E_0.INIT = 16'h0;

  reg [7:0] pclk_M, pclk_D;

  always @(posedge dft_clk50m_bufg)
  begin
    hlen_q <= hlen;
    vlen_q <= vlen;
    if (switch) begin
      case ({hlen,vlen})
        // ... existing code ...
      endcase
    end
  end

  wire progdone, progen, progdata;
  dcmspi dcmspi_0 (
    .RST(switch),          
    .PROGCLK(dft_clk50m_bufg),
    .PROGDONE(progdone),   
    .DFSLCKD(pclk_lckd),
    .M(pclk_M),            
    .D(pclk_D),            
    .GO(gopclk),           
    .BUSY(busy),
    .PROGEN(progen),       
    .PROGDATA(progdata)    
  );

  wire          clkfx, pclk;
  DCM_CLKGEN #(
    .CLKFX_DIVIDE (21),
    .CLKFX_MULTIPLY (31),
    .CLKIN_PERIOD(20.000)
  )
  PCLK_GEN_INST (
    .CLKFX(clkfx),
    .CLKFX180(),
    .CLKFXDV(),
    .LOCKED(pclk_lckd),
    .PROGDONE(progdone),
    .STATUS(),
    .CLKIN(dft_clk50m),
    .FREEZEDCM(1'b0),
    .PROGCLK(dft_clk50m_bufg),
    .PROGDATA(progdata),
    .PROGEN(progen),
    .RST(1'b0)
  );

  wire pllclk0, pllclk1, pllclk2;
  wire pclkx2, pclkx10, pll_lckd;
  wire clkfbout;

  BUFG pclkbufg (.I(pllclk1), .O(pclk));
  assign pclk_o = pclk;
  BUFG pclkx2bufg (.I(pllclk2), .O(pclkx2));

  PLL_BASE # (
    .CLKIN_PERIOD(13),
    .CLKFBOUT_MULT(10), 
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("INTERNAL")
  ) PLL_OSERDES (
    .CLKFBOUT(clkfbout),
    .CLKOUT0(pllclk0),
    .CLKOUT1(pllclk1),
    .CLKOUT2(pllclk2),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(pll_lckd),
    .CLKFBIN(clkfbout),
    .CLKIN(clkfx),
    .RST(~pclk_lckd)
  );

  wire serdesstrobe;
  wire bufpll_lock;

  BUFPLL #(.DIVIDE(5)) ioclk_buf (.PLLIN(pllclk0), .GCLK(dft_pclkx2), .LOCKED(pll_lckd),
           .IOCLK(pclkx10), .SERDESSTROBE(serdesstrobe), .LOCK(bufpll_lock));

  synchro #(.INITIALIZE("LOGIC1"))
  synchro_reset (.async(!pll_lckd),.sync(reset),.clk(dft_pclk));

  wire [4:0] tmds_data0, tmds_data1, tmds_data2;
  wire not_blank = !blank_i;

  dvi_encoder enc0 (
    .clkin      (dft_pclk),
    .clkx2in    (dft_pclkx2),
    .rstin      (reset),
    .blue_din   (blue_data_i),
    .green_din  (green_data_i),
    .red_din    (red_data_i),
    .hsync      (hsync_i),
    .vsync      (vsync_i),
    .de         (not_blank),
    .tmds_data0 (tmds_data0),
    .tmds_data1 (tmds_data1),
    .tmds_data2 (tmds_data2));

  wire [2:0] tmdsint;
  wire serdes_rst = RSTBTN | ~bufpll_lock;

  serdes_n_to_1 #(.SF(5)) oserdes0 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(serdes_rst),
             .gclk(dft_pclkx2),
             .datain(tmds_data0),
             .iob_data_out(tmdsint[0])) ;

  serdes_n_to_1 #(.SF(5)) oserdes1 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(serdes_rst),
             .gclk(dft_pclkx2),
             .datain(tmds_data1),
             .iob_data_out(tmdsint[1])) ;

  serdes_n_to_1 #(.SF(5)) oserdes2 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(serdes_rst),
             .gclk(dft_pclkx2),
             .datain(tmds_data2),
             .iob_data_out(tmdsint[2])) ;

  OBUFDS TMDS0 (.I(tmdsint[0]), .O(TMDS[0]), .OB(TMDSB[0])) ;
  OBUFDS TMDS1 (.I(tmdsint[1]), .O(TMDS[1]), .OB(TMDSB[1])) ;
  OBUFDS TMDS2 (.I(tmdsint[2]), .O(TMDS[2]), .OB(TMDSB[2])) ;

  reg [4:0] tmdsclkint = 5'b00000;
  reg toggle = 1'b0;

  always @ (posedge dft_pclkx2 or posedge serdes_rst) begin
    if (serdes_rst)
      toggle <= 1'b0;
    else
      toggle <= ~toggle;
  end

  always @ (posedge dft_pclkx2) begin
    if (toggle)
      tmdsclkint <= 5'b11111;
    else
      tmdsclkint <= 5'b00000;
  end

  wire tmdsclk;

  serdes_n_to_1 #(
    .SF           (5))
  clkout (
    .iob_data_out (tmdsclk),
    .ioclk        (pclkx10),
    .serdesstrobe (serdesstrobe),
    .gclk         (dft_pclkx2),
    .reset        (serdes_rst),
    .datain       (tmdsclkint));

  OBUFDS TMDS3 (.I(tmdsclk), .O(TMDS[3]), .OB(TMDSB[3])) ;

endmodule