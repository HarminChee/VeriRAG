`default_nettype none
module mmcme2_test
(
  input  wire         test_i,
  input  wire         CLK_50,
  input  wire         CLK_100,
  input  wire         RST,
  output wire         CLKFBOUT,
  input  wire         CLKFBIN,
  input  wire         I_PWRDWN,
  input  wire         I_CLKINSEL,
  output wire         O_LOCKED,
  output wire [5:0]   O_CNT
);
parameter FEEDBACK = "INTERNAL";
parameter CLKFBOUT_MULT_F  = 12.000;
parameter CLKOUT0_DIVIDE_F = 12.000;

wire clk50;
wire clk100;
assign clk50  = CLK_50;
assign clk100 = CLK_100;

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk;
wire [5:0] gclk;

generate
if (FEEDBACK == "NONE") begin : no_fb
    MMCME2_ADV #(
      .BANDWIDTH("HIGH"),
      .CLKIN1_PERIOD(20.0),
      .CLKIN2_PERIOD(10.0),
      .CLKFBOUT_MULT_F(CLKFBOUT_MULT_F),
      .CLKFBOUT_PHASE(0),
      .CLKOUT0_DIVIDE_F(CLKOUT0_DIVIDE_F),
      .CLKOUT0_DUTY_CYCLE(0.50),
      .CLKOUT0_PHASE(45.0),
      .CLKOUT1_DIVIDE(32),
      .CLKOUT1_DUTY_CYCLE(0.53125),
      .CLKOUT1_PHASE(90.0),
      .CLKOUT2_DIVIDE(48),
      .CLKOUT2_DUTY_CYCLE(0.50),
      .CLKOUT2_PHASE(135.0),
      .CLKOUT3_DIVIDE(64),
      .CLKOUT3_DUTY_CYCLE(0.50),
      .CLKOUT3_PHASE(45.0),
      .CLKOUT4_DIVIDE(80),
      .CLKOUT4_DUTY_CYCLE(0.50),
      .CLKOUT4_PHASE(90.0),
      .CLKOUT5_DIVIDE(96),
      .CLKOUT5_DUTY_CYCLE(0.50),
      .CLKOUT5_PHASE(135.0),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT6_DUTY_CYCLE(0.50),
      .CLKOUT6_PHASE(0.0),
      .STARTUP_WAIT("FALSE")
    ) mmcm (
      .CLKIN1   (clk50),
      .CLKIN2   (clk100),
      .CLKINSEL (I_CLKINSEL),
      .RST      (RST),
      .PWRDWN   (I_PWRDWN),
      .LOCKED   (O_LOCKED),
      .CLKFBIN  (clk_fb_i),
      .CLKFBOUT (clk_fb_o),
      .CLKOUT0  (clk[0]),
      .CLKOUT1  (clk[1]),
      .CLKOUT2  (clk[2]),
      .CLKOUT3  (clk[3]),
      .CLKOUT4  (clk[4]),
      .CLKOUT5  (clk[5]),
      .CLKOUT6  ()
    );
end else begin : with_fb
    MMCME2_ADV #(
      .BANDWIDTH   ("HIGH"),
      .COMPENSATION((FEEDBACK == "EXTERNAL") ? "EXTERNAL" : "INTERNAL"),
      .CLKIN1_PERIOD(20.0),
      .CLKIN2_PERIOD(10.0),
      .CLKFBOUT_MULT_F(CLKFBOUT_MULT_F),
      .CLKFBOUT_PHASE(0),
      .CLKOUT0_DIVIDE_F(CLKOUT0_DIVIDE_F),
      .CLKOUT0_DUTY_CYCLE(0.50),
      .CLKOUT0_PHASE(45.0),
      .CLKOUT1_DIVIDE(32),
      .CLKOUT1_DUTY_CYCLE(0.53125),
      .CLKOUT1_PHASE(90.0),
      .CLKOUT2_DIVIDE(48),
      .CLKOUT2_DUTY_CYCLE(0.50),
      .CLKOUT2_PHASE(135.0),
      .CLKOUT3_DIVIDE(64),
      .CLKOUT3_DUTY_CYCLE(0.50),
      .CLKOUT3_PHASE(45.0),
      .CLKOUT4_DIVIDE(80),
      .CLKOUT4_DUTY_CYCLE(0.50),
      .CLKOUT4_PHASE(90.0),
      .CLKOUT5_DIVIDE(96),
      .CLKOUT5_DUTY_CYCLE(0.50),
      .CLKOUT5_PHASE(135.0),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT6_DUTY_CYCLE(0.50),
      .CLKOUT6_PHASE(0.0),
      .STARTUP_WAIT("FALSE")
    ) mmcm (
      .CLKIN1   (clk50),
      .CLKIN2   (clk100),
      .CLKINSEL (I_CLKINSEL),
      .RST      (RST),
      .PWRDWN   (I_PWRDWN),
      .LOCKED   (O_LOCKED),
      .CLKFBIN  (clk_fb_i),
      .CLKFBOUT (clk_fb_o),
      .CLKOUT0  (clk[0]),
      .CLKOUT1  (clk[1]),
      .CLKOUT2  (clk[2]),
      .CLKOUT3  (clk[3]),
      .CLKOUT4  (clk[4]),
      .CLKOUT5  (clk[5]),
      .CLKOUT6  ()
    );
end
endgenerate

generate
if (FEEDBACK == "INTERNAL") begin : fb_int
    assign clk_fb_i = clk_fb_o;
end else if (FEEDBACK == "BUFG") begin : fb_bufg
    BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));
end else if (FEEDBACK == "EXTERNAL") begin : fb_ext
    assign CLKFBOUT = clk_fb_o;
    assign clk_fb_i = CLKFBIN;
end
endgenerate

wire rst = RST || !O_LOCKED;
wire [5:0] dft_gclk;

genvar i;
generate
for (i=0; i<6; i=i+1) begin : gen_clocks
  BUFG bufg(.I(clk[i]), .O(gclk[i]));
  assign dft_gclk[i] = test_i ? CLK_100 : gclk[i];
  reg [23:0] counter;
  always @(posedge dft_gclk[i] or posedge rst) begin
    if (rst) counter <= 0;
    else     counter <= counter + 1;
  end
  assign O_CNT[i] = counter[21];
end
endgenerate

endmodule
`default_nettype none