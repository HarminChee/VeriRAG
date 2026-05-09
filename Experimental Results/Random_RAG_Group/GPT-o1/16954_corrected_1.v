`timescale 1ns / 1ps
`default_nettype none
module plle2_test
(
    input  wire         CLK_50,
    input  wire         CLK_100,
    input  wire         RST,
    input  wire         I_CLKINSEL,
    output wire         O_LOCKED,
    output wire [5:0]   O_CNT
);

wire clk50;
wire clk100;
assign clk50  = CLK_50;
assign clk100 = CLK_100;

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk_pll;

PLLE2_ADV #
(
    .BANDWIDTH          ("HIGH"),
    .COMPENSATION       ("BUF_IN"),
    .CLKIN1_PERIOD      (20.0),
    .CLKIN2_PERIOD      (10.0),
    .CLKFBOUT_MULT      (16),
    .CLKFBOUT_PHASE     (0.0),
    .CLKOUT0_DIVIDE     (16),
    .CLKOUT0_DUTY_CYCLE (0.53125),
    .CLKOUT0_PHASE      (45.0),
    .CLKOUT1_DIVIDE     (32),
    .CLKOUT1_DUTY_CYCLE (0.5),
    .CLKOUT1_PHASE      (90.0),
    .CLKOUT2_DIVIDE     (48),
    .CLKOUT2_DUTY_CYCLE (0.5),
    .CLKOUT2_PHASE      (135.0),
    .CLKOUT3_DIVIDE     (64),
    .CLKOUT3_DUTY_CYCLE (0.5),
    .CLKOUT3_PHASE      (315.0),
    .CLKOUT4_DIVIDE     (80),
    .CLKOUT4_DUTY_CYCLE (0.5),
    .CLKOUT4_PHASE      (270.0),
    .CLKOUT5_DIVIDE     (96),
    .CLKOUT5_DUTY_CYCLE (0.5),
    .CLKOUT5_PHASE      (225.0),
    .STARTUP_WAIT       ("FALSE")
)
pll
(
    .CLKIN1    (clk50),
    .CLKIN2    (clk100),
    .CLKINSEL  (I_CLKINSEL),
    .RST       (RST),
    .LOCKED    (O_LOCKED),
    .CLKFBIN   (clk_fb_i),
    .CLKFBOUT  (clk_fb_o),
    .CLKOUT0   (clk_pll[0]),
    .CLKOUT1   (clk_pll[1]),
    .CLKOUT2   (clk_pll[2]),
    .CLKOUT3   (clk_pll[3]),
    .CLKOUT4   (clk_pll[4]),
    .CLKOUT5   (clk_pll[5])
);

BUFG clk_fb_buf
(
    .I (clk_fb_o),
    .O (clk_fb_i)
);

wire rst = RST || !O_LOCKED;

genvar i;
generate
    for (i=0; i<6; i=i+1)
    begin : gen_counter
        reg [23:0] counter;
        always @(posedge clk_pll[i] or posedge rst)
            if (rst)
                counter <= 0;
            else
                counter <= counter + 1;
        assign O_CNT[i] = counter[21];
    end
endgenerate

endmodule