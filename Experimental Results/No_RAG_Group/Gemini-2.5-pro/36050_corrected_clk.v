`timescale 1ns/1ps
// File: gt0000_corrected_clk.v
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
    // Removed internal clock wires: div_2_clk, div_4_clk, gated_clk, sw_clk
    wire                clk_en          ;
    reg     [07:00]     aux_data_i      ;
    wire    [15:00]     aux_data_o      ;

    `ifdef CLK_TEST_EN
    // DFT Clock Enables Generation
    reg [1:0] div4_counter;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) div4_counter <= 2'b00;
        else div4_counter <= div4_counter + 1'b1;
    end
    wire enable_div_4 = (div4_counter == 2'b11); // Pulse high once every 4 clk cycles
    wire enable_div_2 = (div4_counter[0] == 1'b1); // Pulse high once every 2 clk cycles
    wire enable_gated = en; // Use the 'en' input directly as enable (assuming gated_clk was clk & en)
    // Assuming original sw_clk = clk_sel ? clk : div_4_clk equivalent behavior
    wire enable_sw = clk_sel | (~clk_sel & enable_div_4);

    reg     [03:00]     test_cnt_1      ;
    reg     [03:00]     test_cnt_2      ;
    reg     [03:00]     test_cnt_3      ;
    `endif

    assign  led         = led_sel ? aux_data_o[15:08] : aux_data_o[07:00]   ;
    assign  clk_en      = en                ; // clk_en wire assigned from en input

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
    // Modified TEST_LOGIC blocks to use primary clock 'clk' and enables
    always @(posedge clk or negedge rst_n) begin : TEST_LOGIC_1
        if(!rst_n)
            begin
                test_cnt_1     <= 'd0;
            end
        else if (enable_div_2) // Use enable_div_2
            begin
                test_cnt_1     <= test_cnt_1 + 1'b1;
            end
    end

    always @(posedge clk or negedge rst_n) begin : TEST_LOGIC_2
        if(!rst_n)
            begin
                test_cnt_2     <= 'd0;
            end
        else if (enable_div_4) // Use enable_div_4
            begin
                test_cnt_2     <= test_cnt_2 + 1'b1;
            end
    end

    always @(posedge clk or negedge rst_n) begin : TEST_LOGIC_3
        if(!rst_n)
            begin
                test_cnt_3     <= 'd0;
            end
        else if (enable_gated) // Use enable_gated (derived from 'en' input)
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

    // Modified CCD_LOG_2 to use primary clock 'clk' and enable
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_2
        if(!rst_n)
            begin
                ccd_log_test_2  <= 'd0;
            end
        else if (enable_div_4) // Use enable_div_4
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
        // No else specified, implies holding the value, which is synthesizable.
        // else begin
        //     ccd_log_test_4 <= ccd_log_test_4;
        // end
    end

    // Modified CCD_LOG_5 to use primary clock 'clk' and enable
    always @(posedge clk or negedge rst_n) begin : CCD_LOG_5
        if(!rst_n)
            begin
                ccd_log_test_5  <= 'd0;
            end
        else if (enable_sw) // Use enable_sw
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

    // clk_gen_top instance removed as internally generated clocks are no longer used to clock FFs
    /*
    clk_gen_top clk_gen_inst(
        .clk                (clk                ),
        .rst_n              (rst_n              ),
        .div_2_clk          (                   ), // No longer connected
        .div_4_clk          (                   ), // No longer connected
        .clk_en             (clk_en             ), // Input 'en'/'clk_en' used directly for enable logic
        .clk_sel            (clk_sel            ), // Input 'clk_sel' used directly for enable logic
        .sw_clk             (                   ), // No longer connected
        .gated_clk          (                   )  // No longer connected
    );
    */

    sys_aux_module sys_aux_inst(
        .aux_clk            (clk                ),
        .aux_rst_n          (rst_n              ),
        .aux_data_i         (aux_data_i         ),
        .aux_data_o         (aux_data_o         )
    );

    // Note: The UDP block below seems to have issues unrelated to CLKNPI
    // - `sys_clk` is used but not defined (assuming it should be `clk`)
    // - `clk_in_p` listed twice
    // - `mgtclk_p` used but not defined
    // Corrected sys_clk to clk, leaving other potential issues as is.
    `ifdef UDP
    udpip_stack_module udpip_stack_inst(
        .udp_clk            (clk                ), // Assuming sys_clk was meant to be clk
        .clk_200mhz         (adc_refclk_s       ), // Assuming adc_refclk_s is defined elsewhere
        .clk_in_p           (clk_in_p           ), // Assuming clk_in_p is defined elsewhere
        // .clk_in_p           (clk_in_p           ), // Duplicate removed
        .udp_reset          (udp_reset          ), // Assuming udp_reset is defined elsewhere
        .mgtclk_p           (mgtclk_p           ), // Assuming mgtclk_p is defined elsewhere
        .phy_disable        (                   )
    );
    `endif
endmodule