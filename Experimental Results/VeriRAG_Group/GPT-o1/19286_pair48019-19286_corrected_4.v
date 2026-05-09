`timescale 1ps/1ps

module test_bench_onboard(
    input        clk,
    input        rst,
    input        test_start,
    output       test_done,
    output       test_pass,
    input        ap_ready,
    input        ap_idle,
    input        ap_done,
    input        dut_vld_y,
    input [47:0] dut_y,
    output       dut_rst,
    output       dut_start,
    output       dut_vld_x,
    output [15:0] dut_x,
    output [2:0]  dut_rat
);
    assign test_done = 1'b0;
    assign test_pass = 1'b0;
    assign dut_rst = 1'b0;
    assign dut_start = 1'b0;
    assign dut_vld_x = 1'b0;
    assign dut_x = 16'b0;
    assign dut_rat = 3'b0;
endmodule

module multiSRC(
    input        ap_clk,
    input        ap_rst,
    input        ap_start,
    output       ap_done,
    output       ap_idle,
    output       ap_ready,
    input        vld_i,
    input [15:0] x_i_V,
    input [2:0]  rat_i_V,
    output       vld_o,
    output [47:0] y_o_V
);
    assign ap_done = 1'b0;
    assign ap_idle = 1'b0;
    assign ap_ready = 1'b0;
    assign vld_o = 1'b0;
    assign y_o_V = 48'b0;
endmodule

module multiSRC_onboard(
    input  SYSCLK_N,
    input  SYSCLK_P,
    input  GPIO_SW_RIGHT,
    input  GPIO_SW_CENTER,
    output GPIO_LED_CENTER,
    output GPIO_LED_LEFT,
    output GPIO_LED_RIGHT,
    input  test_i
);
    wire clk;
    wire rst;
    wire locked;
    wire dft_clk;
    reg [26:0] cnt;

    assign rst = GPIO_SW_CENTER;

    clk_wiz_0 CLKPLL
    (
        .clk_in1_p(SYSCLK_P),
        .clk_in1_n(SYSCLK_N),
        .clk_out1(clk),
        .reset(rst),
        .locked(locked)
    );

    assign dft_clk = test_i ? SYSCLK_P : clk;

    always @(posedge dft_clk or posedge rst) begin
        if(rst) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
        end
    end

    wire test_start;
    wire test_pass;
    assign test_start      = GPIO_SW_RIGHT;
    assign GPIO_LED_CENTER = test_pass;
    assign GPIO_LED_RIGHT  = cnt[26];
    assign GPIO_LED_LEFT   = locked;

    wire ap_start;
    wire ap_ready;
    wire ap_idle;
    wire ap_done;
    wire dut_rst;
    wire vld_x;
    wire vld_y;
    wire [15:0] x;
    wire [2:0]  rat;
    wire [47:0] y;

    test_bench_onboard TB
    (
        .clk(dft_clk),
        .rst(rst),
        .test_start(test_start),
        .test_done(),
        .test_pass(test_pass),
        .ap_ready(ap_ready),
        .ap_idle(ap_idle),
        .ap_done(ap_done),
        .dut_vld_y(vld_y),
        .dut_y(y),
        .dut_rst(dut_rst),
        .dut_start(ap_start),
        .dut_vld_x(vld_x),
        .dut_x(x),
        .dut_rat(rat)
    );

    multiSRC DUT
    (
        .ap_clk(dft_clk),
        .ap_rst(dut_rst),
        .ap_start(ap_start),
        .ap_done(ap_done),
        .ap_idle(ap_idle),
        .ap_ready(ap_ready),
        .vld_i(vld_x),
        .x_i_V(x),
        .rat_i_V(rat),
        .vld_o(vld_y),
        .y_o_V(y)
    );

endmodule