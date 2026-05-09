module hdmi_encoder_1_corrected_clk (
    input clk,
    input rst,
    output reg pclk,
    output reg [3:0] tmds,
    output reg [3:0] tmdsb,
    output reg active,
    output reg [10:0] x,
    output reg [9:0] y,
    input [7:0] red,
    input [7:0] green,
    input [7:0] blue
  );
  localparam LATENCY = 2'h2;
  localparam PCLK_DIV = 1'h1;
  localparam Y_RES = 9'h1e0;
  localparam X_RES = 10'h280;
  localparam Y_FRAME = 9'h1f4;
  localparam X_FRAME = 10'h340;
  
  // Use primary clock input directly instead of PLL generated clocks
  wire pclk_int = clk;  // Direct connection to primary input clk
  
  wire [1-1:0] M_ioclk_buf_IOCLK;
  wire [1-1:0] M_ioclk_buf_SERDESSTROBE;
  wire [1-1:0] M_ioclk_buf_LOCK;
  
  reg [10:0] M_ctrX_d, M_ctrX_q = 1'h0;
  reg [9:0] M_ctrY_d, M_ctrY_q = 1'h0;
  reg [1:0] M_vsync_ff_d, M_vsync_ff_q = 1'h0;
  reg [1:0] M_active_ff_d, M_active_ff_q = 1'h0;
  integer i;
  reg hSync;
  reg vSync;
  reg drawArea;
  wire [4-1:0] M_dvi_tmds;
  wire [4-1:0] M_dvi_tmdsb;
  
  dvi_encoder_8 dvi (
    .pclk(pclk_int),
    .pclkx2(pclk_int),
    .pclkx10(pclk_int),
    .strobe(1'b1),
    .rst(rst),
    .blue(blue),
    .green(green),
    .red(red),
    .hsync(hSync),
    .vsync(vSync),
    .de(M_active_ff_q[1+0-:1]),
    .tmds(M_dvi_tmds),
    .tmdsb(M_dvi_tmdsb)
  );
  
  always @* begin
    M_ctrX_d = M_ctrX_q;
    M_active_ff_d = M_active_ff_q;
    M_vsync_ff_d = M_vsync_ff_q;
    M_ctrY_d = M_ctrY_q;
    M_ctrX_d = (M_ctrX_q == 11'h33f) ? 1'h0 : M_ctrX_q + 1'h1;
    if (M_ctrX_q == 11'h33f) begin
      M_ctrY_d = (M_ctrY_q == 10'h1f3) ? 1'h0 : M_ctrY_q + 1'h1;
    end
    pclk = pclk_int;
    hSync = (M_ctrX_q >= 12'h28c) && (M_ctrX_q < 12'h296);
    M_vsync_ff_d[0+0-:1] = (M_ctrY_q >= 10'h1ea) && (M_ctrY_q < 10'h1ec);
    drawArea = (M_ctrX_q < 10'h280) && (M_ctrY_q < 9'h1e0);
    M_active_ff_d[0+0-:1] = drawArea;
    for (i = 1'h1; i < 2'h2; i = i + 1) begin
      M_active_ff_d[(i)*1+0-:1] = M_active_ff_q[(i - 1'h1)*1+0-:1];
      M_vsync_ff_d[(i)*1+0-:1] = M_active_ff_q[(i - 1'h1)*1+0-:1];
    end
    vSync = M_vsync_ff_q[1+0-:1];
    active = M_active_ff_q[1+0-:1];
    x = M_ctrX_q;
    y = M_ctrY_q;
    tmds = M_dvi_tmds;
    tmdsb = M_dvi_tmdsb;
  end
  
  always @(posedge pclk_int) begin
    M_vsync_ff_q <= M_vsync_ff_d;
    M_active_ff_q <= M_active_ff_d;
    if (rst == 1'b1) begin
      M_ctrX_q <= 1'h0;
      M_ctrY_q <= 1'h0;
    end else begin
      M_ctrX_q <= M_ctrX_d;
      M_ctrY_q <= M_ctrY_d;
    end
  end
endmodule