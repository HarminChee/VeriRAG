`timescale 1ns/1ps
module gt0000_digital_top(
    clk             ,
    rst_n           ,
    en              ,
    clk_sel         ,
    led_sel         ,
    led             ,
    test_o           
);
    `define CLK_TEST_EN
    input               clk             ;
    input               rst_n           ;
    input               en              ;
    input               clk_sel         ;
    input               led_sel         ;
    output  [7:0]       led             ;
    output  [7:0]       test_o          ;
    wire                div_2_clk       ;
    wire                div_4_clk       ;
    wire                clk_en          ;
    wire                gated_clk       ;
    wire                sw_clk          ;
    reg     [7:0]       aux_data_i      ;
    wire    [15:0]      aux_data_o      ;
    `ifdef CLK_TEST_EN
    reg     [3:0]       test_cnt_1      ;
    reg     [3:0]       test_cnt_2      ;
    reg     [3:0]       test_cnt_3      ;
    `endif
    assign  led         = led_sel ? aux_data_o[15:8] : aux_data_o[7:0];
    assign  clk_en      = en;
    always @(posedge clk or negedge rst_n) begin : AUX_DATA_IN
        if(!rst_n)
            aux_data_i <= 8'd0;
        else
            aux_data_i <= aux_data_i + 1'b1;
    end
    `ifdef CLK_TEST_EN
    always @(posedge div_2_clk or negedge rst_n) begin : TEST_LOGIC_1
        if(!rst_n)
            test_cnt_1 <= 4'd0;
        else
            test_cnt_1 <= test_cnt_1 + 1'b1;
    end
    always @(posedge div_4_clk or negedge rst_n) begin : TEST_LOGIC_2
        if(!rst_n)
            test_cnt_2 <= 4'd0;
        else
            test_cnt_2 <= test_cnt_2 + 1'b1;
    end
    always @(posedge gated_clk or negedge rst_n) begin : TEST_LOGIC_3
        if(!rst_n)
            test_cnt_3 <= 4'd0;
        else
            test_cnt_3 <= test_cnt_3 + 1'b1;
    end
    reg     ccd_log_test_1;
    reg     ccd_log_test_2;
    reg     ccd_log_test_3;
    reg     ccd_log_test_4;
    reg     ccd_log_test_5;
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_1
        if(!rst_n)
            ccd_log_test_1 <= 1'b0;
        else
            ccd_log_test_1 <= ~test_cnt_3[0];
    end
    always @(posedge div_4_clk or negedge rst_n) begin : CCD_LOG_2
        if(!rst_n)
            ccd_log_test_2 <= 1'b0;
        else
            ccd_log_test_2 <= ~test_cnt_1[1];
    end
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_3
        if(!rst_n)
            ccd_log_test_3 <= 1'b0;
        else
            ccd_log_test_3 <= ~test_cnt_2[1];
    end
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_4
        if(!rst_n)
            ccd_log_test_4 <= 1'b0;
        else if(ccd_log_test_3)
            ccd_log_test_4 <= ((test_cnt_1 == 4'd3) | (test_cnt_1 == 4'd2) | (test_cnt_1 == 4'd1)) 
                              | ((test_cnt_1 & 4'b0101) == 4'b0010);
        else
            ccd_log_test_4 <= ccd_log_test_4;
    end
    always @(posedge sw_clk or negedge rst_n) begin : CCD_LOG_5
        if(!rst_n)
            ccd_log_test_5 <= 1'b0;
        else
            ccd_log_test_5 <= ccd_log_test_4;
    end
    assign  test_o[0] = test_cnt_1[3];
    assign  test_o[1] = test_cnt_2[3];
    assign  test_o[2] = test_cnt_3[3];
    assign  test_o[3] = ccd_log_test_1;
    assign  test_o[4] = ccd_log_test_2;
    assign  test_o[5] = ccd_log_test_3;
    assign  test_o[6] = ccd_log_test_4;
    assign  test_o[7] = ccd_log_test_5;
    `else
    assign  test_o    = 8'b00000000;
    `endif
    clk_gen_top clk_gen_inst(
        .clk        (clk        ),
        .rst_n      (rst_n      ),
        .div_2_clk  (div_2_clk  ),
        .div_4_clk  (div_4_clk  ),
        .clk_en     (clk_en     ),
        .clk_sel    (clk_sel    ),
        .sw_clk     (sw_clk     ),
        .gated_clk  (gated_clk  )
    );
    sys_aux_module sys_aux_inst(
        .aux_clk    (clk        ),
        .aux_rst_n  (rst_n      ),
        .aux_data_i (aux_data_i ),
        .aux_data_o (aux_data_o )
    );
    `ifdef UDP
    udpip_stack_module udpip_stack_inst(
        .udp_clk    (sys_clk        ),
        .clk_200mhz (adc_refclk_s   ),
        .clk_in_p   (clk_in_p       ),
        .udp_reset  (udp_reset      ),
        .mgtclk_p   (mgtclk_p       ),
        .phy_disable(               )
    );  
    `endif
endmodule