`timescale 1ps/1ps

module serdes_1_to_n_clk_pll_s8_diff (
    input clkin_p,
    input clkin_n,
    input reset,
    input [S-1:0] pattern1,
    input [S-1:0] pattern2,
    output rxioclk,
    output rx_serdesstrobe,
    output rx_bufg_pll_x1,
    output rx_pll_lckd,
    output rx_pllout_xs,
    output bitslip,
    output rx_bufpll_lckd,
    output [S-1:0] datain
);
parameter integer S = 8;
parameter BS = "FALSE";
parameter PLLX = 7;
parameter PLLD = 1;
parameter real CLKIN_PERIOD = 6.000;
parameter DIFF_TERM = "FALSE";

wire P_clk;
wire buf_pll_fb_clk;
wire ddly_m;
wire ddly_s;
wire [7:0] mdataout;
wire busys;
wire busym;
wire rx_clk_in;
wire buf_P_clk;
wire iob_datain;
reg [3:0] state;
reg bslip;
reg [2:0] count;
reg busyd;
reg [11:0] counter;
wire [S-1:0] clk_iserdes_data;
reg cal_clk;
reg rst_clk;
wire rx_bufplllckd;
wire not_rx_bufpll_lckd;
reg enable;
reg flag1;
reg flag2;
parameter RX_SWAP_CLK = 1'b0;

assign busy_clk = busym;
assign datain = clk_iserdes_data;
assign bitslip = bslip;

always @(posedge rx_bufg_pll_x1 or posedge not_rx_bufpll_lckd) begin
    if (not_rx_bufpll_lckd) begin
        state <= 0;
        enable <= 1'b0;
        cal_clk <= 1'b0;
        rst_clk <= 1'b0;
        bslip <= 1'b0;
        busyd <= 1'b1;
        counter <= 12'b0;
    end else begin
        busyd <= busy_clk;
        if (counter[5]) begin
            enable <= 1'b1;
        end
        if (counter[11]) begin
            state <= 0;
            cal_clk <= 1'b0;
            rst_clk <= 1'b0;
            bslip <= 1'b0;
            busyd <= 1'b1;
            counter <= 12'b0;
        end else begin
            counter <= counter + 1;
            flag1 <= (clk_iserdes_data != pattern1);
            flag2 <= (clk_iserdes_data != pattern2);
            case (state)
                0: if (enable && !busyd) state <= 1;
                1: begin cal_clk <= 1'b1; state <= 2; end
                2: begin
                    cal_clk <= 1'b0;
                    if (busyd) state <= 3;
                end
                3: if (!busyd) begin rst_clk <= 1'b1; state <= 4; end
                4: begin rst_clk <= 1'b0; state <= 5; end
                5: if (!busyd) begin state <= 6; count <= 3'b000; end
                6: begin
                    count <= count + 1;
                    if (count == 3'b111) state <= 7;
                end
                7: if (BS == "TRUE" && flag1 && flag2) begin
                    bslip <= 1'b1;
                    state <= 8;
                    count <= 3'b000;
                end else begin
                    state <= 9;
                end
                8: begin
                    bslip <= 1'b0;
                    count <= count + 1;
                    if (count == 3'b111) state <= 7;
                end
                9: state <= 9;
            endcase
        end
    end
end

IBUFGDS #(.DIFF_TERM(DIFF_TERM)) iob_clk_in (
    .I(clkin_p),
    .IB(clkin_n),
    .O(rx_clk_in)
);

assign iob_datain = rx_clk_in ^ RX_SWAP_CLK;

genvar i;
generate
    for (i = 0; i < S; i = i + 1) begin : loop0
        assign clk_iserdes_data[i] = mdataout[8 + i - S];
    end
endgenerate

IODELAY2 #(
    .DATA_RATE("SDR"),
    .SIM_TAPDELAY_VALUE(49),
    .IDELAY_VALUE(0),
    .IDELAY2_VALUE(0),
    .ODELAY_VALUE(0),
    .IDELAY_MODE("NORMAL"),
    .SERDES_MODE("MASTER"),
    .IDELAY_TYPE("VARIABLE_FROM_HALF_MAX"),
    .COUNTER_WRAPAROUND("STAY_AT_LIMIT"),
    .DELAY_SRC("IDATAIN")
) iodelay_m (
    .IDATAIN(iob_datain),
    .DATAOUT(ddly_m),
    .IOCLK0(rxioclk),
    .CLK(rx_bufg_pll_x1),
    .CAL(cal_clk),
    .RST(rst_clk),
    .BUSY(busym)
);

BUFG bufg_pll_x1 (.I(rx_pllout_x1), .O(rx_bufg_pll_x1));

BUFPLL #(.DIVIDE(S)) rx_bufpll_inst (
    .PLLIN(rx_pllout_xs),
    .GCLK(rx_bufg_pll_x1),
    .LOCKED(rx_pll_lckd),
    .IOCLK(rxioclk),
    .LOCK(rx_bufplllckd),
    .SERDESSTROBE(rx_serdesstrobe)
);

assign rx_bufpll_lckd = rx_pll_lckd & rx_bufplllckd;
assign not_rx_bufpll_lckd = ~rx_bufpll_lckd;

endmodule