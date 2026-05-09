`timescale 1ps/1ps

module DemoInterconnect_clk_wiz_0_0_clk_wiz (
    output        aclk,
    output        uart,
    input         reset,
    output        locked,
    input         clk_in1
);

    wire clk_in1_buf;
    wire clk_fb;
    wire clk_fb_buf;
    wire locked_int;
    wire reset_high;
    
    reg [7:0] seq_reg1 = 0;
    reg [7:0] seq_reg2 = 0;
    
    IBUF clkin1_ibufg (
        .O (clk_in1_buf),
        .I (clk_in1)
    );

    MMCME2_ADV #(
        .BANDWIDTH("HIGH"),
        .CLKOUT4_CASCADE("FALSE"),
        .COMPENSATION("ZHOLD"),
        .STARTUP_WAIT("FALSE"),
        .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(63.000),
        .CLKFBOUT_PHASE(0.000),
        .CLKFBOUT_USE_FINE_PS("FALSE"),
        .CLKOUT0_DIVIDE_F(10.500),
        .CLKOUT0_PHASE(0.000),
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT0_USE_FINE_PS("FALSE"),
        .CLKOUT1_DIVIDE(63),
        .CLKOUT1_PHASE(0.000),
        .CLKOUT1_DUTY_CYCLE(0.500),
        .CLKOUT1_USE_FINE_PS("FALSE"),
        .CLKIN1_PERIOD(83.333)
    ) mmcm_adv_inst (
        .CLKFBOUT(clk_fb),
        .CLKOUT0(aclk_buf),
        .CLKOUT1(uart_buf),
        .CLKFBIN(clk_fb_buf),
        .CLKIN1(clk_in1_buf),
        .CLKINSEL(1'b1),
        .LOCKED(locked_int),
        .RST(reset_high)
    );

    assign reset_high = reset;
    assign locked = locked_int;

    BUFG clkf_buf (
        .O (clk_fb_buf),
        .I (clk_fb)
    );

    BUFGCE clkout1_buf (
        .O (aclk),
        .CE (seq_reg1[7]),
        .I (aclk_buf)
    );

    BUFH clkout1_buf_en (
        .O (aclk_buf_en_clk),
        .I (aclk_buf)
    );

    always @(posedge aclk_buf_en_clk or posedge reset_high) begin
        if (reset_high)
            seq_reg1 <= 8'h00;
        else
            seq_reg1 <= {seq_reg1[6:0], locked_int};
    end

    BUFGCE clkout2_buf (
        .O (uart),
        .CE (seq_reg2[7]),
        .I (uart_buf)
    );

    BUFH clkout2_buf_en (
        .O (uart_buf_en_clk),
        .I (uart_buf)
    );

    always @(posedge uart_buf_en_clk or posedge reset_high) begin
        if (reset_high)
            seq_reg2 <= 8'h00;
        else
            seq_reg2 <= {seq_reg2[6:0], locked_int};
    end

endmodule