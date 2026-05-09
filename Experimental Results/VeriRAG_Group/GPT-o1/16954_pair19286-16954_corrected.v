`default_nettype none
module plle2_test
(
    input  wire         CLK,
    input  wire         RST,
    input  wire         I_CLKINSEL,
    input  wire         scan_clk,
    input  wire         test_i,
    output wire         O_LOCKED,
    output wire [5:0]   O_CNT
);

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk_out;

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
    .CLKOUT3_PHASE      (-45.0),
    .CLKOUT4_DIVIDE     (80),
    .CLKOUT4_DUTY_CYCLE (0.5),
    .CLKOUT4_PHASE      (-90.0),
    .CLKOUT5_DIVIDE     (96),
    .CLKOUT5_DUTY_CYCLE (0.5),
    .CLKOUT5_PHASE      (-135.0),
    .STARTUP_WAIT       ("FALSE")
)
pll
(
    .CLKIN1     (CLK),
    .CLKIN2     (1'b0),
    .CLKINSEL   (I_CLKINSEL),
    .RST        (RST),
    .LOCKED     (O_LOCKED),
    .CLKFBIN    (clk_fb_i),
    .CLKFBOUT   (clk_fb_o),
    .CLKOUT0    (clk_out[0]),
    .CLKOUT1    (clk_out[1]),
    .CLKOUT2    (clk_out[2]),
    .CLKOUT3    (clk_out[3]),
    .CLKOUT4    (clk_out[4]),
    .CLKOUT5    (clk_out[5])
);

BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));

wire rst_int = RST;

genvar i;
generate
    for (i = 0; i < 6; i = i + 1) begin : CLKGEN
        wire dft_clk = test_i ? scan_clk : clk_out[i];
        reg [23:0] counter;
        always @(posedge dft_clk or posedge rst_int) begin
            if (rst_int) counter <= 0;
            else         counter <= counter + 1;
        end
        assign O_CNT[i] = counter[21];
    end
endgenerate

endmodule