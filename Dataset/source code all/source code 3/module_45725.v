`timescale 1ns / 1ps
`timescale 1ns / 1ps
module GTPA1_DUAL_WRAPPER #(
    parameter   WRAPPER_SIM_GTPRESET_SPEEDUP    = 0,    
    parameter   WRAPPER_CLK25_DIVIDER_0         = 4,
    parameter   WRAPPER_CLK25_DIVIDER_1         = 4,
    parameter   WRAPPER_PLL_DIVSEL_FB_0         = 5,
    parameter   WRAPPER_PLL_DIVSEL_FB_1         = 5,
    parameter   WRAPPER_PLL_DIVSEL_REF_0        = 2,
    parameter   WRAPPER_PLL_DIVSEL_REF_1        = 2,
    parameter   WRAPPER_SIMULATION              = 0     
)
(
    input   [1:0]   TILE0_RXPOWERDOWN0_IN,
    input   [1:0]   TILE0_RXPOWERDOWN1_IN,
    input   [1:0]   TILE0_TXPOWERDOWN0_IN,
    input   [1:0]   TILE0_TXPOWERDOWN1_IN,
    input           TILE0_CLK00_IN,
    input           TILE0_CLK01_IN,
    input           TILE0_GTPRESET0_IN,
    input           TILE0_GTPRESET1_IN,
    output          TILE0_PLLLKDET0_OUT,
    output          TILE0_PLLLKDET1_OUT,
    output          TILE0_RESETDONE0_OUT,
    output          TILE0_RESETDONE1_OUT,
    output  [1:0]   TILE0_RXCHARISK0_OUT,
    output  [1:0]   TILE0_RXCHARISK1_OUT,
    output  [1:0]   TILE0_RXDISPERR0_OUT,
    output  [1:0]   TILE0_RXDISPERR1_OUT,
    output  [1:0]   TILE0_RXNOTINTABLE0_OUT,
    output  [1:0]   TILE0_RXNOTINTABLE1_OUT,
    output  [2:0]   TILE0_RXCLKCORCNT0_OUT,
    output  [2:0]   TILE0_RXCLKCORCNT1_OUT,
    input           TILE0_RXENMCOMMAALIGN0_IN,
    input           TILE0_RXENMCOMMAALIGN1_IN,
    input           TILE0_RXENPCOMMAALIGN0_IN,
    input           TILE0_RXENPCOMMAALIGN1_IN,
    output  [15:0]  TILE0_RXDATA0_OUT,
    output  [15:0]  TILE0_RXDATA1_OUT,
    input           TILE0_RXRESET0_IN,
    input           TILE0_RXRESET1_IN,
    input           TILE0_RXUSRCLK0_IN,
    input           TILE0_RXUSRCLK1_IN,
    input           TILE0_RXUSRCLK20_IN,
    input           TILE0_RXUSRCLK21_IN,
    input           TILE0_GATERXELECIDLE0_IN,
    input           TILE0_GATERXELECIDLE1_IN,
    input           TILE0_IGNORESIGDET0_IN,
    input           TILE0_IGNORESIGDET1_IN,
    output          TILE0_RXELECIDLE0_OUT,
    output          TILE0_RXELECIDLE1_OUT,
    input           TILE0_RXN0_IN,
    input           TILE0_RXN1_IN,
    input           TILE0_RXP0_IN,
    input           TILE0_RXP1_IN,
    output  [2:0]   TILE0_RXSTATUS0_OUT,
    output  [2:0]   TILE0_RXSTATUS1_OUT,
    output          TILE0_PHYSTATUS0_OUT,
    output          TILE0_PHYSTATUS1_OUT,
    output          TILE0_RXVALID0_OUT,
    output          TILE0_RXVALID1_OUT,
    input           TILE0_RXPOLARITY0_IN,
    input           TILE0_RXPOLARITY1_IN,
    output  [1:0]   TILE0_GTPCLKOUT0_OUT,
    output  [1:0]   TILE0_GTPCLKOUT1_OUT,
    input   [1:0]   TILE0_TXCHARDISPMODE0_IN,
    input   [1:0]   TILE0_TXCHARDISPMODE1_IN,
    input   [1:0]   TILE0_TXCHARISK0_IN,
    input   [1:0]   TILE0_TXCHARISK1_IN,
    input   [15:0]  TILE0_TXDATA0_IN,
    input   [15:0]  TILE0_TXDATA1_IN,
    input           TILE0_TXUSRCLK0_IN,
    input           TILE0_TXUSRCLK1_IN,
    input           TILE0_TXUSRCLK20_IN,
    input           TILE0_TXUSRCLK21_IN,
    output          TILE0_TXN0_OUT,
    output          TILE0_TXN1_OUT,
    output          TILE0_TXP0_OUT,
    output          TILE0_TXP1_OUT,
    input           TILE0_TXDETECTRX0_IN,
    input           TILE0_TXDETECTRX1_IN,
    input           TILE0_TXELECIDLE0_IN,
    input           TILE0_TXELECIDLE1_IN,
    input [1:0]     rx_equalizer_ctrl,
    input [3:0]     tx_diff_ctrl,
    input [2:0]     tx_pre_emphasis
);
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;
    wire            tile0_plllkdet0_i;
    wire            tile0_plllkdet1_i;
    reg            tile0_plllkdet0_i2;
    reg            tile0_plllkdet1_i2;
    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;
generate
if (WRAPPER_SIMULATION==1)
begin : simulation
    assign TILE0_PLLLKDET0_OUT = tile0_plllkdet0_i2;
    always@(tile0_plllkdet0_i)
    begin
        if (tile0_plllkdet0_i) begin
            #100
            tile0_plllkdet0_i2 <= tile0_plllkdet0_i;
        end
        else
        begin
            tile0_plllkdet0_i2 <= tile0_plllkdet0_i;
        end
     end
    assign TILE0_PLLLKDET1_OUT = tile0_plllkdet1_i2;
    always@(tile0_plllkdet1_i)
    begin
        if (tile0_plllkdet1_i) begin
            #100
            tile0_plllkdet1_i2 <= tile0_plllkdet1_i;
        end
        else
        begin
            tile0_plllkdet1_i2 <= tile0_plllkdet1_i;
        end
     end
end 
else
begin: implementation
    assign TILE0_PLLLKDET0_OUT = tile0_plllkdet0_i;
    assign TILE0_PLLLKDET1_OUT = tile0_plllkdet1_i;
end
endgenerate 
    GTPA1_DUAL_WRAPPER_TILE #
    (
        .TILE_SIM_GTPRESET_SPEEDUP   (WRAPPER_SIM_GTPRESET_SPEEDUP),
        .TILE_CLK25_DIVIDER_0        (WRAPPER_CLK25_DIVIDER_0),
        .TILE_CLK25_DIVIDER_1        (WRAPPER_CLK25_DIVIDER_1),
        .TILE_PLL_DIVSEL_FB_0        (WRAPPER_PLL_DIVSEL_FB_0),
        .TILE_PLL_DIVSEL_FB_1        (WRAPPER_PLL_DIVSEL_FB_1),
        .TILE_PLL_DIVSEL_REF_0       (WRAPPER_PLL_DIVSEL_REF_0),
        .TILE_PLL_DIVSEL_REF_1       (WRAPPER_PLL_DIVSEL_REF_1),
        .TILE_PLL_SOURCE_0               ("PLL0"),
        .TILE_PLL_SOURCE_1               ("PLL1")
    )
    tile0_gtpa1_dual_wrapper_i
    (
        .RXPOWERDOWN0_IN                (TILE0_RXPOWERDOWN0_IN),
        .RXPOWERDOWN1_IN                (TILE0_RXPOWERDOWN1_IN),
        .TXPOWERDOWN0_IN                (TILE0_TXPOWERDOWN0_IN),
        .TXPOWERDOWN1_IN                (TILE0_TXPOWERDOWN1_IN),
        .CLK00_IN                       (TILE0_CLK00_IN),
        .CLK01_IN                       (TILE0_CLK01_IN),
        .GTPRESET0_IN                   (TILE0_GTPRESET0_IN),
        .GTPRESET1_IN                   (TILE0_GTPRESET1_IN),
        .PLLLKDET0_OUT                  (tile0_plllkdet0_i),
        .PLLLKDET1_OUT                  (tile0_plllkdet1_i),
        .RESETDONE0_OUT                 (TILE0_RESETDONE0_OUT),
        .RESETDONE1_OUT                 (TILE0_RESETDONE1_OUT),
        .RXCHARISK0_OUT                 (TILE0_RXCHARISK0_OUT),
        .RXCHARISK1_OUT                 (TILE0_RXCHARISK1_OUT),
        .RXDISPERR0_OUT                 (TILE0_RXDISPERR0_OUT),
        .RXDISPERR1_OUT                 (TILE0_RXDISPERR1_OUT),
        .RXNOTINTABLE0_OUT              (TILE0_RXNOTINTABLE0_OUT),
        .RXNOTINTABLE1_OUT              (TILE0_RXNOTINTABLE1_OUT),
        .RXCLKCORCNT0_OUT               (TILE0_RXCLKCORCNT0_OUT),
        .RXCLKCORCNT1_OUT               (TILE0_RXCLKCORCNT1_OUT),
        .RXENMCOMMAALIGN0_IN            (TILE0_RXENMCOMMAALIGN0_IN),
        .RXENMCOMMAALIGN1_IN            (TILE0_RXENMCOMMAALIGN1_IN),
        .RXENPCOMMAALIGN0_IN            (TILE0_RXENPCOMMAALIGN0_IN),
        .RXENPCOMMAALIGN1_IN            (TILE0_RXENPCOMMAALIGN1_IN),
        .RXDATA0_OUT                    (TILE0_RXDATA0_OUT),
        .RXDATA1_OUT                    (TILE0_RXDATA1_OUT),
        .RXRESET0_IN                    (TILE0_RXRESET0_IN),
        .RXRESET1_IN                    (TILE0_RXRESET1_IN),
        .RXUSRCLK0_IN                   (TILE0_RXUSRCLK0_IN),
        .RXUSRCLK1_IN                   (TILE0_RXUSRCLK1_IN),
        .RXUSRCLK20_IN                  (TILE0_RXUSRCLK20_IN),
        .RXUSRCLK21_IN                  (TILE0_RXUSRCLK21_IN),
        .GATERXELECIDLE0_IN             (TILE0_GATERXELECIDLE0_IN),
        .GATERXELECIDLE1_IN             (TILE0_GATERXELECIDLE1_IN),
        .IGNORESIGDET0_IN               (TILE0_IGNORESIGDET0_IN),
        .IGNORESIGDET1_IN               (TILE0_IGNORESIGDET1_IN),
        .RXELECIDLE0_OUT                (TILE0_RXELECIDLE0_OUT),
        .RXELECIDLE1_OUT                (TILE0_RXELECIDLE1_OUT),
        .RXN0_IN                        (TILE0_RXN0_IN),
        .RXN1_IN                        (TILE0_RXN1_IN),
        .RXP0_IN                        (TILE0_RXP0_IN),
        .RXP1_IN                        (TILE0_RXP1_IN),
        .RXSTATUS0_OUT                  (TILE0_RXSTATUS0_OUT),
        .RXSTATUS1_OUT                  (TILE0_RXSTATUS1_OUT),
        .PHYSTATUS0_OUT                 (TILE0_PHYSTATUS0_OUT),
        .PHYSTATUS1_OUT                 (TILE0_PHYSTATUS1_OUT),
        .RXVALID0_OUT                   (TILE0_RXVALID0_OUT),
        .RXVALID1_OUT                   (TILE0_RXVALID1_OUT),
        .RXPOLARITY0_IN                 (TILE0_RXPOLARITY0_IN),
        .RXPOLARITY1_IN                 (TILE0_RXPOLARITY1_IN),
        .GTPCLKOUT0_OUT                 (TILE0_GTPCLKOUT0_OUT),
        .GTPCLKOUT1_OUT                 (TILE0_GTPCLKOUT1_OUT),
        .TXCHARDISPMODE0_IN             (TILE0_TXCHARDISPMODE0_IN),
        .TXCHARDISPMODE1_IN             (TILE0_TXCHARDISPMODE1_IN),
        .TXCHARISK0_IN                  (TILE0_TXCHARISK0_IN),
        .TXCHARISK1_IN                  (TILE0_TXCHARISK1_IN),
        .TXDATA0_IN                     (TILE0_TXDATA0_IN),
        .TXDATA1_IN                     (TILE0_TXDATA1_IN),
        .TXUSRCLK0_IN                   (TILE0_TXUSRCLK0_IN),
        .TXUSRCLK1_IN                   (TILE0_TXUSRCLK1_IN),
        .TXUSRCLK20_IN                  (TILE0_TXUSRCLK20_IN),
        .TXUSRCLK21_IN                  (TILE0_TXUSRCLK21_IN),
        .TXN0_OUT                       (TILE0_TXN0_OUT),
        .TXN1_OUT                       (TILE0_TXN1_OUT),
        .TXP0_OUT                       (TILE0_TXP0_OUT),
        .TXP1_OUT                       (TILE0_TXP1_OUT),
        .TXDETECTRX0_IN                 (TILE0_TXDETECTRX0_IN),
        .TXDETECTRX1_IN                 (TILE0_TXDETECTRX1_IN),
        .TXELECIDLE0_IN                 (TILE0_TXELECIDLE0_IN),
        .TXELECIDLE1_IN                 (TILE0_TXELECIDLE1_IN),
        .rx_equalizer_ctrl              (rx_equalizer_ctrl),
        .tx_diff_ctrl                   (tx_diff_ctrl),
        .tx_pre_emphasis                (tx_pre_emphasis)
    );
endmodule
