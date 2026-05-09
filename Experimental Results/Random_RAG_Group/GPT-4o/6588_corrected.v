`timescale 1ps/1ps
module serdes_1_to_n_clk_pll_s16_diff (
    clkin_p,
    clkin_n,
    rxioclk,
    rx_serdesstrobe,
    reset,
    pattern1,
    rx_bufg_pll_x1,
    rx_bufg_pll_x2,
    bitslip,
    rx_toggle,
    rx_bufpll_lckd,
    datain,
    test_i,
    scan_clk_iserdes_data
);
parameter integer S = 16;
parameter integer BS = "FALSE";
parameter PLLX = 2;
parameter PLLD = 1;
parameter real CLKIN_PERIOD = 6.000;
parameter DIFF_TERM = "FALSE";
input clkin_p;
input clkin_n;
output rxioclk;
output rx_serdesstrobe;
input reset;
input [S-1:0] pattern1;
output rx_bufg_pll_x1;
output rx_bufg_pll_x2;
output bitslip;
output rx_toggle;
output rx_bufpll_lckd;
output [S-1:0] datain;
input test_i;
input [S-1:0] scan_clk_iserdes_data;
wire P_clk;
wire pll_fb_clk;
wire ddly_m;
wire ddly_s;
wire [7:0] mdataout;
wire busys;
wire busym;
wire feedback;
wire rx_clk_in;
reg bslip;
reg [S-1:0] clk_iserdes_data;
wire [S/2-1:0] clk_iserdes_data_int;
reg [3:0] state;
reg cal_clk;
reg rst_clk;
wire not_rx_bufpll_lckd;
reg [11:0] counter;
reg [S/2-1:0] clkh;
reg busyd;
reg [3:0] count;
reg rx_toggle_int;
reg enable;
parameter RX_SWAP_CLK = 1'b0;
assign busy_clk = busym;
assign datain = clk_iserdes_data;
assign rx_toggle = rx_toggle_int;
assign bitslip = bslip;
always @ (posedge rx_bufg_pll_x1)
begin
    clk_iserdes_data <= test_i ? scan_clk_iserdes_data : {clk_iserdes_data_int, clkh};
end
always @ (posedge rx_bufg_pll_x2 or posedge not_rx_bufpll_lckd)
if (not_rx_bufpll_lckd == 1'b1) begin
    rx_toggle_int <= 1'b0;
end
else begin
    if (rx_toggle_int == 1'b1) begin
        clkh <= clk_iserdes_data_int;
        if (clk_iserdes_data_int == pattern1[S-1 : S/2] && count == 4'hF) begin
            rx_toggle_int <= rx_toggle_int;
        end
        else begin
            rx_toggle_int <= ~rx_toggle_int;
        end
    end
    else begin
        rx_toggle_int <= ~rx_toggle_int;
    end
end
always @ (posedge rx_bufg_pll_x2 or posedge not_rx_bufpll_lckd)
begin
if (not_rx_bufpll_lckd == 1'b1) begin
    state <= 0;
    enable <= 1'b0;
    cal_clk <= 1'b0;
    rst_clk <= 1'b0;
    bslip <= 1'b0;
    busyd <= 1'b1;
    counter <= 12'b000000000000;
end
else begin
    busyd <= busy_clk;
    if (counter[5] == 1'b1) begin
        enable <= 1'b1;
    end
    if (counter[11] == 1'b1) begin
        state <= 0;
        cal_clk <= 1'b0;
        rst_clk <= 1'b0;
        bslip <= 1'b0;
        busyd <= 1'b1;
        counter <= 12'b000000000000;
    end
    else begin
        counter <= counter + 12'b000000000001;
        if (state == 0 && enable == 1'b1 && busyd == 1'b0) begin
            state <= 1;
        end
        else if (state == 1) begin
            cal_clk <= 1'b1; state <= 2;
        end
        else if (state == 2 && busyd == 1'b1) begin
            cal_clk <= 1'b0; state <= 3;
        end
        else if (state == 3 && busyd == 1'b0) begin
            rst_clk <= 1'b1; state <= 4;
        end
        else if (state == 4) begin
            rst_clk <= 1'b0; state <= 5;
        end
        else if (state == 5 && busyd == 1'b0) begin
            state <= 6;
            count <= 3'b000;
        end
        else if (state == 6) begin
            count <= count + 3'b001;
            if (count == 3'b111) begin
                state <= 7;
            end
        end
        else if (state == 7) begin
            if (BS == "TRUE" && clk_iserdes_data != pattern1) begin
                bslip <= 1'b1;
                state <= 8;
                count <= 3'b000;
            end
            else begin
                state <= 9;
            end
        end
        else if (state == 8) begin
            bslip <= 1'b0;
            count <= count + 3'b001;
            if (count == 3'b111) begin
                state <= 7;
            end
        end
        else if (state == 9) begin
            state <= 9;
        end
    end
end
end
IBUFGDS #(
    .DIFF_TERM (DIFF_TERM))
iob_clk_in (
    .I (clkin_p),
    .IB (clkin_n),
    .O (rx_clk_in));
assign iob_data_in = rx_clk_in ^ RX_SWAP_CLK;
genvar i;
generate
for (i = 0 ; i <= (S/2 - 1) ; i = i + 1)
begin : loop0
assign clk_iserdes_data_int[i] = mdataout[8+i-S/2];
end
endgenerate
IODELAY2 #(
    .DATA_RATE ("SDR"),
    .SIM_TAPDELAY_VALUE (49),
    .IDELAY_VALUE (0),
    .IDELAY2_VALUE (0),
    .ODELAY_VALUE (0),
    .IDELAY_MODE ("NORMAL"),
    .SERDES_MODE ("MASTER"),
    .IDELAY_TYPE ("VARIABLE_FROM_HALF_MAX"),
    .COUNTER_WRAPAROUND ("STAY_AT_LIMIT"),
    .DELAY_SRC ("IDATAIN"))
iodelay_m (
    .IDATAIN (iob_data_in),
    .TOUT (),
    .DOUT (),
    .T (1'b1),
    .ODATAIN (1'b0),
    .DATAOUT (ddly_m),
    .DATAOUT2 (),
    .IOCLK0 (rxioclk),
    .IOCLK1 (1'b0),
    .CLK (rx_bufg_pll_x2),
    .CAL (cal_clk),
    .INC (1'b0),
    .CE (1'b0),
    .RST (rst_clk),
    .BUSY (busym));
IODELAY2 #(
    .DATA_RATE ("SDR"),
    .SIM_TAPDELAY_VALUE (49),
    .IDELAY_VALUE (0),
    .IDELAY2_VALUE (0),
    .ODELAY_VALUE (0),
    .IDELAY_MODE ("NORMAL"),
    .SERDES_MODE ("SLAVE"),
    .IDELAY_TYPE ("FIXED"),
    .COUNTER_WRAPAROUND ("STAY_AT_LIMIT"),
    .DELAY_SRC ("IDATAIN"))
iodelay_s (
    .IDATAIN (iob_data_in),
    .TOUT (),
    .DOUT (),
    .T (1'b1),
    .ODATAIN (1'b0),
    .DATAOUT (ddly_s),
    .DATAOUT2 (),
    .IOCLK0 (1'b0),
    .IOCLK1 (1'b0),
    .CLK (1'b0),
    .CAL (1'b0),
    .INC (1'b0),
    .CE (1'b0),
    .RST (1'b0),
    .BUSY ());
BUFIO2 #(
    .DIVIDE (1),
    .DIVIDE_BYPASS ("TRUE"))
P_clk_bufio2_inst (
    .I (P_clk),
    .IOCLK (),
    .DIVCLK (buf_P_clk),
    .SERDESSTROBE ());
BUFIO2FB #(
    .DIVIDE_BYPASS ("TRUE"))
P_clk_bufio2fb_inst (
    .I (feedback),
    .O (buf_pll_fb_clk));
ISERDES2 #(
    .DATA_WIDTH (S/2),
    .DATA_RATE ("SDR"),
    .BITSLIP_ENABLE ("TRUE"),
    .SERDES_MODE ("MASTER"),
    .INTERFACE_TYPE ("RETIMED"))
iserdes_m (
    .D (ddly_m),
    .CE0 (1'b1),
    .CLK0 (rxioclk),
    .CLK1 (1'b0),
    .IOCE (rx_serdesstrobe),
    .RST (reset),
    .CLKDIV (rx_bufg_pll_x2),
    .SHIFTIN (pd_edge),
    .BITSLIP (bitslip),
    .FABRICOUT (),
    .DFB (),
    .CFB0 (),
    .CFB1 (),
    .Q4 (mdataout[7]),
    .Q3 (mdataout[6]),
    .Q2 (mdataout[5]),
    .Q1 (mdataout[4]),
    .VALID (),
    .INCDEC (),
    .SHIFTOUT (cascade));
ISERDES2 #(
    .DATA_WIDTH (S/2),
    .DATA_RATE ("SDR"),
    .BITSLIP_ENABLE ("TRUE"),
    .SERDES_MODE ("SLAVE"),
    .INTERFACE_TYPE ("RETIMED"))
iserdes_s (
    .D (ddly_s),
    .CE0 (1'b1),
    .CLK0 (rxioclk),
    .CLK1 (1'b0),
    .IOCE (rx_serdesstrobe),
    .RST (reset),
    .CLKDIV (rx_bufg_pll_x2),
    .SHIFTIN (cascade),
    .BITSLIP (bitslip),
    .FABRICOUT (),
    .DFB (P_clk),
    .CFB0 (feedback),
    .CFB1 (),
    .Q4 (mdataout[3]),
    .Q3 (mdataout[2]),
    .Q2 (mdataout[1]),
    .Q1 (mdataout[0]),
    .VALID (),
    .INCDEC (),
    .SHIFTOUT (pd_edge));
PLL_ADV #(
    .BANDWIDTH ("OPTIMIZED"),
    .CLKFBOUT_MULT (PLLX),
    .CLKFBOUT_PHASE (0.0),
    .CLKIN1_PERIOD (CLKIN_PERIOD),
    .CLKIN2_PERIOD (CLKIN_PERIOD),
    .CLKOUT0_DIVIDE (1),
    .CLKOUT0_DUTY_CYCLE (0.5),
    .CLKOUT0_PHASE (0.0),
    .CLKOUT1_DIVIDE (S/2),
    .CLKOUT1_DUTY_CYCLE (0.5),
    .CLKOUT1_PHASE (0.0),
    .CLKOUT2_DIVIDE (S),
    .CLKOUT2_DUTY_CYCLE (0.5),
    .CLKOUT2_PHASE (0.0),
    .CLKOUT3_DIVIDE (7),
    .CLKOUT3_DUTY_CYCLE (0.5),
    .CLKOUT3_PHASE (0.0),
    .CLKOUT4_DIVIDE (7),
    .CLKOUT4_DUTY_CYCLE (0.5),
    .CLKOUT4_PHASE (0.0),
    .CLKOUT5_DIVIDE (7),
    .CLKOUT5_DUTY_CYCLE (0.5),
    .CLKOUT5_PHASE (0.0),
    .COMPENSATION ("SOURCE_SYNCHRONOUS"),
    .DIVCLK_DIVIDE (PLLD),
    .CLK_FEEDBACK ("CLKOUT0"),
    .REF_JITTER (0.100))
rx_pll_adv_inst (
    .CLKFBDCM (),
    .CLKFBOUT (),
    .CLKOUT0 (rx_pllout_xs),
    .CLKOUT1 (rx_pllout_x2),
    .CLKOUT2 (rx_pllout_x1),
    .CLKOUT3 (),
    .CLKOUT4 (),
    .CLKOUT5 (),
    .CLKOUTDCM0 (),
    .CLKOUTDCM1 (),
    .CLKOUTDCM2 (),
    .CLKOUTDCM3 (),
    .CLKOUTDCM4 (),
    .CLKOUTDCM5 (),
    .DO (),
    .DRDY (),
    .LOCKED (rx_pll_lckd),
    .CLKFBIN (buf_pll_fb_clk),
    .CLKIN1 (buf_P_clk),
    .CLKIN2 (1'b0),
    .CLKINSEL (1'b1),
    .DADDR (5'b00000),
    .DCLK (1'b0),
    .DEN (1'b0),
    .DI (16'h0000),
    .DWE (1'b0),
    .RST (reset),
    .REL (1'b0));
BUFG bufg_pll_x1 (.I(rx_pllout_x1), .O(rx_bufg_pll_x1));
BUFG bufg_pll_x2 (.I(rx_pllout_x2), .O(rx_bufg_pll_x2);
BUFPLL #(
    .DIVIDE (S/2))
rx_bufpll_inst (
    .PLLIN (rx_pllout_xs),
    .GCLK (rx_bufg_pll_x2),
    .LOCKED (rx_pll_lckd),
    .IOCLK (rxioclk),
    .LOCK (rx_bufplllckd),
    .SERDESSTROBE (rx_serdesstrobe));
assign rx_bufpll_lckd = rx_pll_lckd & rx_bufplllckd;
assign not_rx_bufpll_lckd = ~rx_bufpll_lckd;
endmodule