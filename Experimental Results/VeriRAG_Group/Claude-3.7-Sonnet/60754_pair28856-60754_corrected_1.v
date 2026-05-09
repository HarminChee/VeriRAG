`timescale 1ps / 1ps
module dvi_gen_top (
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
  input  wire        test_i
);

  wire          locked;
  wire          reset;
  wire          clk50m, clk50m_bufg;
  wire          pwrup;
  wire          pclk;
  
  assign clk50m = dvi_clk_i;
  wire dft_clk50m_bufg = test_i ? dvi_clk_i : clk50m_bufg;

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
        32'h031f01c1:  
        begin
          pclk_M <= 8'd54 - 8'd1;
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

  wire pllclk0, pllclk1, pllclk2;
  wire pclkx2, pclkx10, pll_lckd;
  wire clkfbout;
  wire dft_pclk = test_i ? dvi_clk_i : pclk;

  BUFG pclkbufg (.I(pllclk1), .O(pclk));
  assign pclk_o = pclk;
  BUFG pclkx2bufg (.I(pllclk2), .O(pclkx2));

  wire serdesstrobe;
  wire bufpll_lock;

  BUFPLL #(.DIVIDE(5)) ioclk_buf (
    .PLLIN(pllclk0),
    .GCLK(pclkx2),
    .LOCKED(pll_lckd),
    .IOCLK(pclkx10),
    .SERDESSTROBE(serdesstrobe),
    .LOCK(bufpll_lock)
  );

  synchro #(.INITIALIZE("LOGIC1")) synchro_reset (
    .async(!pll_lckd),
    .sync(reset),
    .clk(dft_pclk)
  );

endmodule