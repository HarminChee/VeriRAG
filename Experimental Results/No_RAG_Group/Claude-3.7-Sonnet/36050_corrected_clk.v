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
    output  [07:00]     led             ;
    output  [07:00]     test_o          ;
    wire                div_2_clk       ;
    wire                div_4_clk       ;
    wire                clk_en          ;
    wire                gated_clk       ;
    wire                sw_clk          ;
    reg     [07:00]     aux_data_i      ;
    wire    [15:00]     aux_data_o      ;
    `ifdef CLK_TEST_EN
    reg     [03:00]     test_cnt_1      ;
    reg     [03:00]     test_cnt_2      ;
    reg     [03:00]     test_cnt_3      ;
    `endif
    assign  led         = led_sel ? aux_data_o[15:08] : aux_data_o[07:00]   ;
    assign  clk_en      = en                ;
    always @(posedge clk or negedge rst_n) begin : AUX_DATA_IN
        if(!rst_n)
            begin
                aux_data_i     <= 'd0;
            end
        else
            begin
                aux_data_i      <= aux_data_i + 1'b1;
            end   
    end
    `ifdef CLK_TEST_EN
    always @(posedge clk or negedge rst_n) begin : TEST_LOGIC_1
        if(!rst_n)
            begin
                test_cnt_1     <= 'd0;
            end
        else
            begin
                test_cnt_1     <= test_cnt_1 + 1'b1;
            end   
    end
    always @(posedge clk or negedge rst_n) begin : TEST_LOGIC_2
        if(!rst_n)
            begin
                test_cnt_2     <= 'd0;
            end
        else
            begin
                test_cnt_2     <= test_cnt_2 + 1'b1;
            end   
    end
    always @(posedge clk or negedge rst_n) begin : TEST_LOGIC_3
        if(!rst_n)
            begin
                test_cnt_3     <= 'd0;
            end
        else
            begin
                test_cnt_3     <= test_cnt_3 + 1'b1;
            end   
    end
    reg     ccd_log_test_1;
    reg     ccd_log_test_2;
    reg     ccd_log_test_3;
    reg     ccd_log_test_4;
    reg     ccd_log_test_5;
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_1
        if(!rst_n)
            begin
                ccd_log_test_1  <= 'd0;
            end
        else
            begin
                ccd_log_test_1  <= ~test_cnt_3[0];
            end   
    end
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_2
        if(!rst_n)
            begin
                ccd_log_test_2  <= 'd0;
            end
        else
            begin
                ccd_log_test_2  <= ~test_cnt_1[1];
            end   
    end
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_3
        if(!rst_n)
            begin
                ccd_log_test_3  <= 'd0;
            end
        else
            begin
                ccd_log_test_3  <= ~test_cnt_2[1];
            end   
    end
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_4
        if(!rst_n)
            begin
                ccd_log_test_4  <= 'd0;
            end
        else if(ccd_log_test_3)
            begin
                ccd_log_test_4  <= ((test_cnt_1 == 'd3) | (test_cnt_1 == 'd2) | (test_cnt_1 == 'd1)) | (test_cnt_1 & 'b101 == 'b010);
            end
        else
            begin
                ccd_log_test_4  <= ccd_log_test_4;
            end 
    end
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_5
        if(!rst_n)
            begin
                ccd_log_test_5  <= 'd0;
            end
        else
            begin
                ccd_log_test_5  <= ccd_log_test_4;
            end 
    end
    assign  test_o[0]   = test_cnt_1[03]        ;
    assign  test_o[1]   = test_cnt_2[03]        ;
    assign  test_o[2]   = test_cnt_3[03]        ;
    assign  test_o[3]   = ccd_log_test_1        ;   
    assign  test_o[4]   = ccd_log_test_2        ;   
    assign  test_o[5]   = ccd_log_test_3        ;   
    assign  test_o[6]   = ccd_log_test_4        ;   
    assign  test_o[7]   = ccd_log_test_5        ;   
    `else
    assign  test_o      = 8'b00000000           ;
    `endif
    clk_gen_top clk_gen_inst(
        .clk                (clk                ),
        .rst_n              (rst_n              ),
        .div_2_clk          (div_2_clk          ),
        .div_4_clk          (div_4_clk          ),
        .clk_en             (clk_en             ),
        .clk_sel            (clk_sel            ),
        .sw_clk             (sw_clk             ),
        .gated_clk          (gated_clk          ) 
    );
    sys_aux_module sys_aux_inst(
        .aux_clk            (clk                ),
        .aux_rst_n          (rst_n              ),
        .aux_data_i         (aux_data_i         ),
        .aux_data_o         (aux_data_o         ) 
    );
    
endmodule