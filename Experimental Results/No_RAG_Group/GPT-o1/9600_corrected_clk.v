`default_nettype none
module plle2_test_corrected_clk
(
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

wire clk50_bufg;
wire clk100_bufg;

BUFG bufg_50   (.I(CLK_50),   .O(clk50_bufg));
BUFG bufg_100  (.I(CLK_100),  .O(clk100_bufg));

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk;
wire [5:0] gclk;

PLLE2_ADV #
(
    .BANDWIDTH          ("HIGH"),
    .COMPENSATION       ("ZHOLD"),
    .CLKIN1_PERIOD      (20.0),
    .CLKIN2_PERIOD      (10.0),
    .CLKFBOUT_MULT      (16),
    .CLKFBOUT_PHASE     (0),
    .CLKOUT0_DIVIDE     (16),
    .CLKOUT0_DUTY_CYCLE (53125),
    .CLKOUT0_PHASE      (45000),
    .CLKOUT1_DIVIDE     (32),
    .CLKOUT1_DUTY_CYCLE (50000),
    .CLKOUT1_PHASE      (90000),
    .CLKOUT2_DIVIDE     (48),
    .CLKOUT2_DUTY_CYCLE (50000),
    .CLKOUT2_PHASE      (135000),
    .CLKOUT3_DIVIDE     (64),
    .CLKOUT3_DUTY_CYCLE (50000),
    .CLKOUT3_PHASE      (-45000),
    .CLKOUT4_DIVIDE     (80),
    .CLKOUT4_DUTY_CYCLE (50000),
    .CLKOUT4_PHASE      (-90000),
    .CLKOUT5_DIVIDE     (96),
    .CLKOUT5_DUTY_CYCLE (50000),
    .CLKOUT5_PHASE      (-135000),
    .STARTUP_WAIT       ("FALSE")
)
pll
(
    .CLKIN1     (clk50_bufg),
    .CLKIN2     (clk100_bufg),
    .CLKINSEL   (I_CLKINSEL),
    .RST        (RST),
    .PWRDWN     (I_PWRDWN),
    .LOCKED     (O_LOCKED),
    .CLKFBIN    (clk_fb_i),
    .CLKFBOUT   (clk_fb_o),
    .CLKOUT0    (clk[0]),
    .CLKOUT1    (clk[1]),
    .CLKOUT2    (clk[2]),
    .CLKOUT3    (clk[3]),
    .CLKOUT4    (clk[4]),
    .CLKOUT5    (clk[5])
);

generate
    if (FEEDBACK == "INTERNAL") begin
        assign clk_fb_i = clk_fb_o;
    end else if (FEEDBACK == "BUFG") begin
        BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));
    end else if (FEEDBACK == "EXTERNAL") begin
        assign CLKFBOUT = clk_fb_o;
        assign clk_fb_i = CLKFBIN;
    end
endgenerate

wire rst = RST || !O_LOCKED;

genvar i;
generate
    for (i = 0; i < 6; i = i + 1) begin
        BUFG bufg(.I(clk[i]), .O(gclk[i]));
        reg [23:0] counter;
        always @(posedge gclk[i] or posedge rst)
            if (rst) counter <= 0;
            else     counter <= counter + 1;
        assign O_CNT[i] = counter[21];
    end
endgenerate

endmodule