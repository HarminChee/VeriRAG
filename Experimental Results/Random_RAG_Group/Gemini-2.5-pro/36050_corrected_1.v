`timescale 1ns/1ps

module gt0000_digital_top (
    input               test_mode       , // Added DFT signal
    input               clk             ,
    input               rst_n           ,
    input               en              ,
    input               clk_sel         ,
    input               led_sel         ,
    output  [07:00]     led             ,
    output  [07:00]     test_o
);

    `define CLK_TEST_EN

    wire                div_2_clk       ;
    wire                div_4_clk       ;
    wire                clk_en          ;
    wire                gated_clk       ;
    wire                sw_clk          ;
    reg     [07:00]     aux_data_i      ;
    wire    [15:00]     aux_data_o      ;

    // Muxed clocks for DFT
    wire                dft_clk_div_2;
    wire                dft_clk_div_4;
    wire                dft_clk_gated;
    wire                dft_clk_sw;

    assign dft_clk_div_2 = test_mode ? clk : div_2_clk;
    assign dft_clk_div_4 = test_mode ? clk : div_4_clk;
    assign dft_clk_gated = test_mode ? clk : gated_clk; // Assumes 'en' is handled during test
    assign dft_clk_sw    = test_mode ? clk : sw_clk;    // Assumes 'clk_sel' is handled during test

`ifdef CLK_TEST_EN
    reg     [03:00]     test_cnt_1      ;
    reg     [03:00]     test_cnt_2      ;
    reg     [03:00]     test_cnt_3      ;

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

    always @(posedge dft_clk_div_2 or negedge rst_n) begin : TEST_LOGIC_1 // Modified clock
        if(!rst_n)
            begin
                test_cnt_1     <= 'd0;
            end
        else
            begin
                test_cnt_1     <= test_cnt_1 + 1'b1;
            end
    end

    always @(posedge dft_clk_div_4 or negedge rst_n) begin : TEST_LOGIC_2 // Modified clock
        if(!rst_n)
            begin
                test_cnt_2     <= 'd0;
            end
        else
            begin
                test_cnt_2     <= test_cnt_2 + 1'b1;
            end
    end

    always @(posedge dft_clk_gated or negedge rst_n) begin : TEST_LOGIC_3 // Modified clock
        if(!rst_n)
            begin
                test_cnt_3     <= 'd0;
            end
        // In test mode (test_mode=1), dft_clk_gated=clk.
        // In func mode (test_mode=0), dft_clk_gated=gated_clk.
        // The flop behavior depends on whether gated_clk runs when test_mode=0.
        // Assuming gated_clk only runs when en=1 functionally.
        // If test_mode=1, it clocks with 'clk'.
        // If test_mode=0, it clocks with 'gated_clk' (which depends on 'en').
        else begin
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

    always @(posedge dft_clk_div_4 or negedge rst_n) begin : CCD_LOG_2 // Modified clock
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
                // Simplified combinatorial logic for clarity, original logic kept
                ccd_log_test_4  <= ((test_cnt_1 == 4'd3) || (test_cnt_1 == 4'd2) || (test_cnt_1 == 4'd1)) || ((test_cnt_1 & 4'b101) == 4'b010);
            end
        // Removed explicit self-assignment else branch, implied latch is standard
        // else begin
        //     ccd_log_test_4  <= ccd_log_test_4;
        // end
    end

    always @(posedge dft_clk_sw or negedge rst_n) begin : CCD_LOG_5 // Modified clock
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
`else // Default assignment if CLK_TEST_EN is not defined
    assign  led         = 8'b0; // Provide a default
    assign  clk_en      = en;   // Still needed for clk_gen_top
    assign  test_o      = 8'b00000000           ;
    // Need to handle aux_data_i if CLK_TEST_EN is not defined but sys_aux_inst is
    always @(posedge clk or negedge rst_n) begin : AUX_DATA_IN_ELSE
        if(!rst_n)
            begin
                aux_data_i     <= 'd0;
            end
        else
            begin
                aux_data_i      <= aux_data_i + 1'b1; // Example behavior
            end
    end
`endif

    // Instantiations
    clk_gen_top clk_gen_inst(
        .clk                (clk                ),
        .rst_n              (rst_n              ),
        .div_2_clk          (div_2_clk          ),
        .div_4_clk          (div_4_clk          ),
        .clk_en             (clk_en             ), // Use assigned clk_en
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

    // `ifdef UDP
    // // This block appears incomplete and uses undefined signals (sys_clk, adc_refclk_s, etc.)
    // // It also has a duplicated port (clk_in_p). Commenting out for now.
    // udpip_stack_module udpip_stack_inst(
    //     .udp_clk            (sys_clk            ), // Undefined
    //     .clk_200mhz         (adc_refclk_s       ), // Undefined
    //     .clk_in_p           (clk_in_p           ), // Undefined
    //   //.clk_in_p           (clk_in_p           ), // Duplicated port
    //     .udp_reset          (udp_reset          ), // Undefined
    //     .mgtclk_p           (mgtclk_p           ), // Undefined
    //     .phy_disable        (                   )  // Empty connection
    // );
    // `endif

endmodule