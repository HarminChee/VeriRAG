`timescale 1 ps / 1 ps
module dvi_gen_top (
  input wire        test_i,
  input wire        scan_chain_rst,
  input wire        rst_n_pad_i,
  input wire        dvi_clk_i,
  input wire [15:0] hlen,
  input wire [15:0] vlen,
  output wire [3:0] TMDS,
  output wire [3:0] TMDSB,
  output wire       pclk_o,
  input wire        hsync_i, 
  input wire        vsync_i, 
  input wire        blank_i, 
  input wire [7:0]  red_data_i,
  input wire [7:0]  green_data_i,
  input wire [7:0]  blue_data_i
);
  wire          locked;
  wire          reset;
  wire          clk50m, clk50m_bufg;
  wire          pwrup;
  assign clk50m = dvi_clk_i;
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
    .CLK(clk50m_bufg),
    .D(1'b0)
  );

  wire busy;
  reg switch = 1'b0;
  reg [15:0] hlen_q, vlen_q;
  always @ (posedge clk50m_bufg) begin
    switch <= pwrup | ({hlen_q,vlen_q} != {hlen,vlen});
  end

  wire gopclk;
  SRL16E #(.INIT(16'h0000)) SRL16E_0 (
    .Q(gopclk),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(1'b1),
    .CLK(clk50m_bufg),
    .D(switch)
  );

  reg [7:0] pclk_M, pclk_D;
  always @(posedge clk50m_bufg) begin
    hlen_q <= hlen;
    vlen_q <= vlen;
    if (switch) begin
      case ({hlen,vlen})
        32'h031f01c1:  begin pclk_M <= 8'd53;  pclk_D <= 8'd124; end
        32'h031f020c:  begin pclk_M <= 8'd62;  pclk_D <= 8'd124; end
        32'h03ff0270:  begin pclk_M <= 8'd95;  pclk_D <= 8'd124; end
        32'h04ef0330:  begin pclk_M <= 8'd201; pclk_D <= 8'd162; end
        32'h033f01bc:  begin pclk_M <= 8'd3;   pclk_D <= 8'd8;   end
        32'h035f0208:  begin pclk_M <= 8'd120; pclk_D <= 8'd223; end
        32'h041f0273:  begin pclk_M <= 8'd151; pclk_D <= 8'd190; end
        32'h033f01fc:  begin pclk_M <= 8'd30;  pclk_D <= 8'd60;  end
        32'h05c703d8:  begin pclk_M <= 8'd6;   pclk_D <= 8'd3;   end
        32'h040f0299:  begin pclk_M <= 8'd63;  pclk_D <= 8'd76;  end
        32'h053f0325:  begin pclk_M <= 8'd12;  pclk_D <= 8'd9;   end
        32'h035f0211:  begin pclk_M <= 8'd110; pclk_D <= 8'd201; end
        32'h068f037b:  begin pclk_M <= 8'd204; pclk_D <= 8'd113; end
        32'h043f0290:  begin pclk_M <= 8'd192; pclk_D <= 8'd224; end
        32'h052f0325:  begin pclk_M <= 8'd139; pclk_D <= 8'd108; end
        32'h061f048c:  begin pclk_M <= 8'd216; pclk_D <= 8'd98;  end
        32'h043f027f:  begin pclk_M <= 8'd187; pclk_D <= 8'd224; end
        32'h054f0336:  begin pclk_M <= 8'd136; pclk_D <= 8'd101; end
        32'h05c1037e:  begin pclk_M <= 8'd18;  pclk_D <= 8'd11;  end
        32'h06af041d:  begin pclk_M <= 8'd248; pclk_D <= 8'd114; end
        32'h0697042a:  begin pclk_M <= 8'd66;  pclk_D <= 8'd30;  end
        32'h06970447:  begin pclk_M <= 8'd110; pclk_D <= 8'd49;  end
        32'h068f0428:  begin pclk_M <= 8'd72;  pclk_D <= 8'd33;  end
        32'h057f0335:  begin pclk_M <= 8'd24;  pclk_D <= 8'd17;  end
        32'h060f038b:  begin pclk_M <= 8'd207; pclk_D <= 8'd122; end
        32'h069f042b:  begin pclk_M <= 8'd212; pclk_D <= 8'd97;  end
        32'h086f04e1:  begin pclk_M <= 8'd80;  pclk_D <= 8'd24;  end
        32'h06ef038b:  begin pclk_M <= 8'd208; pclk_D <= 8'd107; end
        32'h06af0427:  begin pclk_M <= 8'd246; pclk_D <= 8'd112; end
        32'h059f0321:  begin pclk_M <= 8'd254; pclk_D <= 8'd183; end
        32'h067f0427:  begin pclk_M <= 8'd16;  pclk_D <= 8'd7;   end
        32'h05ff0385:  begin pclk_M <= 8'd132; pclk_D <= 8'd79;  end
        32'h06bf042f:  begin pclk_M <= 8'd248; pclk_D <= 8'd111; end
        32'h08bf0440:  begin pclk_M <= 8'd160; pclk_D <= 8'd54;  end
        32'h081f04db:  begin pclk_M <= 8'd58;  pclk_D <= 8'd18;  end
        32'h069f042f:  begin pclk_M <= 8'd23;  pclk_D <= 8'd10;  end
        32'h095705d1:  begin pclk_M <= 8'd200; pclk_D <= 8'd46;  end
        32'h027f0193:  begin pclk_M <= 8'd75;  pclk_D <= 8'd244; end
        32'h018f00e0:  begin pclk_M <= 8'd26;  pclk_D <= 8'd249; end
        32'h018f0105:  begin pclk_M <= 8'd20;  pclk_D <= 8'd166; end
        32'h01ff0137:  begin pclk_M <= 8'd36;  pclk_D <= 8'd192; end
        32'h020f0139:  begin pclk_M <= 8'd37;  pclk_D <= 8'd190; end
        32'h0207014c:  begin pclk_M <= 8'd15;  pclk_D <= 8'd76;  end
        32'h02670137:  begin pclk_M <= 8'd2;   pclk_D <= 8'd12;  end
        32'h02770139:  begin pclk_M <= 8'd4;   pclk_D <= 8'd20;  end
        32'h026f014c:  begin pclk_M <= 8'd62;  pclk_D <= 8'd252; end
        32'h0a1f04d9:  begin pclk_M <= 8'd196; pclk_D <= 8'd50;  end
        32'h05bf0325:  begin pclk_M <= 8'd83;  pclk_D <= 8'd58;  end
        32'h05f70315:  begin pclk_M <= 8'd196; pclk_D <= 8'd135; end
        32'h068f033b:  begin pclk_M <= 8'd216; pclk_D <= 8'd129; end
        32'h035f0270:  begin pclk_M <= 8'd80;  pclk_D <= 8'd124; end
        32'h043f0270:  begin pclk_M <= 8'd101; pclk_D <= 8'd124; end
        default:       begin pclk_M <= 8'd1;   pclk_D <= 8'd3;   end
      endcase
    end
  end

  wire progdone, progen, progdata;
  dcmspi dcmspi_0 (
    .RST(switch),
    .PROGCLK(clk50m_bufg),
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
    .CLKIN(clk50m),
    .FREEZEDCM(1'b0),
    .PROGCLK(clk50m_bufg),
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

  wire serdes_rst;
  assign serdes_rst = RSTBTN | ~pll_lckd;

  wire async_rst_dft;
  assign async_rst_dft = test_i ? scan_chain_rst : !pclk_lckd;

  synchro #(.INITIALIZE(1)) synchro_reset (
    .async(async_rst_dft),
    .sync(reset),
    .clk(pclk)
  );

  wire pll_rst_dft;
  assign pll_rst_dft = test_i ? scan_chain_rst : ~pclk_lckd;

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
    .RST(pll_rst_dft)
  );

  wire serdesstrobe;
  wire bufpll_lock;
  BUFPLL #(.DIVIDE(5)) ioclk_buf (.PLLIN(pllclk0), .GCLK(pclkx2), .LOCKED(pll_lckd),
           .IOCLK(pclkx10), .SERDESSTROBE(serdesstrobe), .LOCK(bufpll_lock));

  wire [4:0] tmds_data0, tmds_data1, tmds_data2;
  wire not_blank = !blank_i;
  dvi_encoder enc0 (
    .clkin      (pclk),
    .clkx2in    (pclkx2),
    .rstin      (reset),
    .blue_din   (blue_data_i),
    .green_din  (green_data_i),
    .red_din    (red_data_i),
    .hsync      (hsync_i),
    .vsync      (vsync_i),
    .de         (not_blank),
    .tmds_data0 (tmds_data0),
    .tmds_data1 (tmds_data1),
    .tmds_data2 (tmds_data2)
  );

  wire [2:0] tmdsint;
  wire pclkx2_dft, serdes_rst_dft;
  assign pclkx2_dft = test_i ? dvi_clk_i : pclkx2;
  assign serdes_rst_dft = test_i ? scan_chain_rst : serdes_rst;

  serdes_n_to_1 #(.SF(5)) oserdes0 (
    .ioclk(pclkx10),
    .serdesstrobe(serdesstrobe),
    .reset(serdes_rst_dft),
    .gclk(pclkx2_dft),
    .datain(tmds_data0),
    .iob_data_out(tmdsint[0])
  );
  serdes_n_to_1 #(.SF(5)) oserdes1 (
    .ioclk(pclkx10),
    .serdesstrobe(serdesstrobe),
    .reset(serdes_rst_dft),
    .gclk(pclkx2_dft),
    .datain(tmds_data1),
    .iob_data_out(tmdsint[1])
  );
  serdes_n_to_1 #(.SF(5)) oserdes2 (
    .ioclk(pclkx10),
    .serdesstrobe(serdesstrobe),
    .reset(serdes_rst_dft),
    .gclk(pclkx2_dft),
    .datain(tmds_data2),
    .iob_data_out(tmdsint[2])
  );

  OBUFDS TMDS0 (.I(tmdsint[0]), .O(TMDS[0]), .OB(TMDSB[0])) ;
  OBUFDS TMDS1 (.I(tmdsint[1]), .O(TMDS[1]), .OB(TMDSB[1])) ;
  OBUFDS TMDS2 (.I(tmdsint[2]), .O(TMDS[2]), .OB(TMDSB[2])) ;

  reg [4:0] tmdsclkint = 5'b00000;
  reg toggle = 1'b0;

  always @ (posedge pclkx2_dft) begin
    if (serdes_rst_dft == 1'b1)
      toggle <= 1'b0;
    else
      toggle <= ~toggle;
  end

  always @ (posedge pclkx2_dft) begin
    if (serdes_rst_dft == 1'b1)
      tmdsclkint <= 5'b00000;
    else if (toggle)
      tmdsclkint <= 5'b11111;
    else
      tmdsclkint <= 5'b00000;
  end

  wire tmdsclk;
  serdes_n_to_1 #(.SF(5))
  clkout (
    .iob_data_out (tmdsclk),
    .ioclk        (pclkx10),
    .serdesstrobe (serdesstrobe),
    .gclk         (pclkx2_dft),
    .reset        (serdes_rst_dft),
    .datain       (tmdsclkint)
  );
  OBUFDS TMDS3 (.I(tmdsclk), .O(TMDS[3]), .OB(TMDSB[3])) ;
endmodule