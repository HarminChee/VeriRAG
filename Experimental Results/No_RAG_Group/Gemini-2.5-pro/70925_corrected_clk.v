`timescale 1 ps / 1 ps
module dvi_gen_top_corrected_clk (
  input  wire        rst_n_pad_i,
  input  wire        dvi_clk_i,
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
  input  wire [7:0]  blue_data_i,
  // DFT signals
  input  wire        scan_mode      // Test mode enable
);
  wire          locked;
  wire          reset;
  wire          clk50m, clk50m_bufg;
  wire          pwrup;

  // DFT Test Clock (derived from primary clock)
  wire          test_clk;
  assign clk50m = dvi_clk_i;
  BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));
  assign test_clk = clk50m_bufg; // Use buffered primary clock as test clock

  // DFT Test Reset (synchronous, active high, derived from primary reset)
  reg test_rst_sync1, test_rst_sync2;
  wire test_rst;
  always @(posedge test_clk or negedge rst_n_pad_i) begin
      if (!rst_n_pad_i) begin
          test_rst_sync1 <= 1'b1;
          test_rst_sync2 <= 1'b1;
      end else begin
          test_rst_sync1 <= 1'b0;
          test_rst_sync2 <= test_rst_sync1;
      end
  end
  assign test_rst = test_rst_sync2; // Active high synchronous test reset


  wire pclk_lckd;
  wire RSTBTN;
  assign RSTBTN = ~rst_n_pad_i;
  SRL16E #(.INIT(16'h1)) pwrup_0 (
    .Q(pwrup),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(pclk_lckd), // CE logic might need DFT attention (gating) - outside CLKNPI scope
    .CLK(clk50m_bufg), // Clocked by primary derived clock - OK
    .D(1'b0)
  );
  wire busy;
  reg switch = 1'b0;
  reg [15:0] hlen_q, vlen_q;
  always @ (posedge clk50m_bufg) // Clocked by primary derived clock - OK
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
    .CLK(clk50m_bufg), // Clocked by primary derived clock - OK
    .D(switch)
  );
  defparam SRL16E_0.INIT = 16'h0;
  reg [7:0] pclk_M, pclk_D;
  always @(posedge clk50m_bufg) // Clocked by primary derived clock - OK
  begin
    hlen_q <= hlen;
    vlen_q <= vlen;
    if (switch) begin
      case ({hlen,vlen})
        32'h031f01c1:
        begin
          pclk_M <= 8'd54 - 8'd1;
          pclk_D <= 8'd125 - 8'd1;
        end
        32'h031f020c:
        begin
          pclk_M <= 8'd63 - 8'd1;
          pclk_D <= 8'd125 - 8'd1;
        end
        32'h03ff0270:
        begin
          pclk_M <= 8'd96 - 8'd1;
          pclk_D <= 8'd125 - 8'd1;
        end
        32'h04ef0330:
        begin
          pclk_M <= 8'd202 - 8'd1;
          pclk_D <= 8'd163 - 8'd1;
        end
        32'h033f01bc:
        begin
          pclk_M <= 8'd4 - 8'd1;
          pclk_D <= 8'd9 - 8'd1;
        end
        32'h035f0208:
        begin
          pclk_M <= 8'd121 - 8'd1;
          pclk_D <= 8'd224 - 8'd1;
        end
        32'h041f0273:
        begin
          pclk_M <= 8'd152 - 8'd1;
          pclk_D <= 8'd191 - 8'd1;
        end
        32'h033f01fc:
        begin
          pclk_M <= 8'd31 - 8'd1;
          pclk_D <= 8'd61 - 8'd1;
        end
        32'h05c703d8:
        begin
          pclk_M <= 8'd7 - 8'd1;
          pclk_D <= 8'd4 - 8'd1;
        end
        32'h040f0299:
        begin
          pclk_M <= 8'd64 - 8'd1;
          pclk_D <= 8'd77 - 8'd1;
        end
        32'h053f0325:
        begin
          pclk_M <= 8'd13 - 8'd1;
          pclk_D <= 8'd10 - 8'd1;
        end
        32'h035f0211:
        begin
          pclk_M <= 8'd111 - 8'd1;
          pclk_D <= 8'd202 - 8'd1;
        end
        32'h068f037b:
        begin
          pclk_M <= 8'd205 - 8'd1;
          pclk_D <= 8'd114 - 8'd1;
        end
        32'h043f0290:
        begin
          pclk_M <= 8'd193 - 8'd1;
          pclk_D <= 8'd225 - 8'd1;
        end
        32'h052f0325:
        begin
          pclk_M <= 8'd140 - 8'd1;
          pclk_D <= 8'd109 - 8'd1;
        end
        32'h061f048c:
        begin
          pclk_M <= 8'd217 - 8'd1;
          pclk_D <= 8'd99 - 8'd1;
        end
        32'h043f027f:
        begin
          pclk_M <= 8'd188 - 8'd1;
          pclk_D <= 8'd225 - 8'd1;
        end
        32'h054f0336:
        begin
          pclk_M <= 8'd137 - 8'd1;
          pclk_D <= 8'd102 - 8'd1;
        end
        32'h05c1037e:
        begin
          pclk_M <= 8'd19 - 8'd1;
          pclk_D <= 8'd12 - 8'd1;
        end
        32'h06af041d:
        begin
          pclk_M <= 8'd249 - 8'd1;
          pclk_D <= 8'd115 - 8'd1;
        end
        32'h0697042a:
        begin
          pclk_M <= 8'd67 - 8'd1;
          pclk_D <= 8'd31 - 8'd1;
        end
        32'h06970447:
        begin
          pclk_M <= 8'd111 - 8'd1;
          pclk_D <= 8'd50 - 8'd1;
        end
        32'h068f0428:
        begin
          pclk_M <= 8'd73 - 8'd1;
          pclk_D <= 8'd34 - 8'd1;
        end
        32'h057f0335:
        begin
          pclk_M <= 8'd25 - 8'd1;
          pclk_D <= 8'd18 - 8'd1;
        end
        32'h060f038b:
        begin
          pclk_M <= 8'd208 - 8'd1;
          pclk_D <= 8'd123 - 8'd1;
        end
        32'h069f042b:
        begin
          pclk_M <= 8'd213 - 8'd1;
          pclk_D <= 8'd98 - 8'd1;
        end
        32'h086f04e1:
        begin
          pclk_M <= 8'd81 - 8'd1;
          pclk_D <= 8'd25 - 8'd1;
        end
        32'h06ef038b:
        begin
          pclk_M <= 8'd209 - 8'd1;
          pclk_D <= 8'd108 - 8'd1;
        end
        32'h06af0427:
        begin
          pclk_M <= 8'd247 - 8'd1;
          pclk_D <= 8'd113 - 8'd1;
        end
        32'h059f0321:
        begin
          pclk_M <= 8'd255 - 8'd1;
          pclk_D <= 8'd184 - 8'd1;
        end
        32'h067f0427:
        begin
          pclk_M <= 8'd17 - 8'd1;
          pclk_D <= 8'd8 - 8'd1;
        end
        32'h05ff0385:
        begin
          pclk_M <= 8'd133 - 8'd1;
          pclk_D <= 8'd80 - 8'd1;
        end
        32'h06bf042f:
        begin
          pclk_M <= 8'd249 - 8'd1;
          pclk_D <= 8'd112 - 8'd1;
        end
        32'h08bf0440:
        begin
          pclk_M <= 8'd161 - 8'd1;
          pclk_D <= 8'd55 - 8'd1;
        end
        32'h081f04db:
        begin
          pclk_M <= 8'd59 - 8'd1;
          pclk_D <= 8'd19 - 8'd1;
        end
        32'h069f042f:
        begin
          pclk_M <= 8'd24 - 8'd1;
          pclk_D <= 8'd11 - 8'd1;
        end
        32'h095705d1:
        begin
          pclk_M <= 8'd201 - 8'd1;
          pclk_D <= 8'd47 - 8'd1;
        end
        32'h027f0193:
        begin
          pclk_M <= 8'd76 - 8'd1;
          pclk_D <= 8'd245 - 8'd1;
        end
        32'h018f00e0:
        begin
          pclk_M <= 8'd27 - 8'd1;
          pclk_D <= 8'd250 - 8'd1;
        end
        32'h018f0105:
        begin
          pclk_M <= 8'd21 - 8'd1;
          pclk_D <= 8'd167 - 8'd1;
        end
        32'h01ff0137:
        begin
          pclk_M <= 8'd37 - 8'd1;
          pclk_D <= 8'd193 - 8'd1;
        end
        32'h020f0139:
        begin
          pclk_M <= 8'd38 - 8'd1;
          pclk_D <= 8'd191 - 8'd1;
        end
        32'h0207014c:
        begin
          pclk_M <= 8'd16 - 8'd1;
          pclk_D <= 8'd77 - 8'd1;
        end
        32'h02670137:
        begin
          pclk_M <= 8'd3 - 8'd1;
          pclk_D <= 8'd13 - 8'd1;
        end
        32'h02770139:
        begin
          pclk_M <= 8'd5 - 8'd1;
          pclk_D <= 8'd21 - 8'd1;
        end
        32'h026f014c:
        begin
          pclk_M <= 8'd63 - 8'd1;
          pclk_D <= 8'd253 - 8'd1;
        end
        32'h0a1f04d9:
        begin
          pclk_M <= 8'd197 - 8'd1;
          pclk_D <= 8'd51 - 8'd1;
        end
        32'h05bf0325:
        begin
          pclk_M <= 8'd84 - 8'd1;
          pclk_D <= 8'd59 - 8'd1;
        end
        32'h05f70315:
        begin
          pclk_M <= 8'd197 - 8'd1;
          pclk_D <= 8'd136 - 8'd1;
        end
        32'h068f033b:
        begin
          pclk_M <= 8'd217 - 8'd1;
          pclk_D <= 8'd130 - 8'd1;
        end
        32'h035f0270:
        begin
          pclk_M <= 8'd81 - 8'd1;
          pclk_D <= 8'd125 - 8'd1;
        end
        32'h043f0270:
        begin
          pclk_M <= 8'd102 - 8'd1;
          pclk_D <= 8'd125 - 8'd1;
        end
        default:
        begin
          pclk_M <= 8'd2 - 8'd1;
          pclk_D <= 8'd4 - 8'd1;
        end
      endcase
    end
  end
  wire progdone, progen, progdata;
  // dcmspi drives DCM/PLL control signals based on primary derived clock - OK
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
  wire          clkfx, pclk; // clkfx, pclk are internally generated clocks
  // DCM/PLL generates clocks based on primary clock but are internal sources
  DCM_CLKGEN #(
    .CLKFX_DIVIDE (21),
    .CLKFX_MULTIPLY (31),
    .CLKIN_PERIOD(20.000)
  )
  PCLK_GEN_INST (
    .CLKFX(clkfx), // Internal clock
    .CLKFX180(),
    .CLKFXDV(),
    .LOCKED(pclk_lckd),
    .PROGDONE(progdone),
    .STATUS(),
    .CLKIN(clk50m), // Input is primary derived - OK
    .FREEZEDCM(1'b0),
    .PROGCLK(clk50m_bufg),
    .PROGDATA(progdata),
    .PROGEN(progen),
    .RST(1'b0) // Consider DFT control for reset if needed
  );
  wire pllclk0, pllclk1, pllclk2; // Internal clocks
  wire pclkx2, pclkx10, pll_lckd; // Internal clocks
  wire clkfbout;
  BUFG pclkbufg (.I(pllclk1), .O(pclk)); // pclk is internal
  assign pclk_o = pclk;
  BUFG pclkx2bufg (.I(pllclk2), .O(pclkx2)); // pclkx2 is internal

  // DFT Reset Mux for PLL
  wire rst_pll_mux = scan_mode ? test_rst : ~pclk_lckd;

  PLL_BASE # (
    .CLKIN_PERIOD(13), // Period calculation depends on clkfx freq.
    .CLKFBOUT_MULT(10),
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("INTERNAL")
  ) PLL