`resetall
`timescale 1ns / 1ps
`default_nettype none

module combine_res (clk, test_i, wen, din_1, din_2, din_3, dout);
    input clk; 
    input test_i; 
    input wen; 
    input[7:0] din_1; 
    input[8:0] din_2; 
    input[8:0] din_3; 
    output[10:0] dout; 
    reg[10:0] dout;
    reg[8:0] din_1_reg; 
    reg[8:0] din_2_reg; 
    reg[8:0] din_3_reg; 
    reg[10:0] add_tmp; 
    reg[10:0] dout_reg; 
    wire dft_clk;

    assign dft_clk = test_i ? clk : clk;

    always @(posedge dft_clk)
    begin
        if (wen == 1'b1)
        begin
            din_1_reg <= {din_1[7], din_1}; 
            din_2_reg <= din_2; 
            din_3_reg <= din_3; 
            dout <= dout_reg; 
        end 
        add_tmp <= ({din_1_reg[8], din_1_reg[8], din_1_reg}) + ({din_2_reg[8], din_2_reg[8], din_2_reg}); 
        dout_reg <= add_tmp + ({din_3_reg[8], din_3_reg[8], din_3_reg}); 
    end 
endmodule

module v_fltr_496 (tm3_clk_v0, test_i, vidin_new_data, vidin_in, vidin_out);
    input tm3_clk_v0; 
    input test_i; 
    input vidin_new_data; 
    input[7:0] vidin_in; 
    output[7:0] vidin_out; 
    wire[7:0] vidin_out;
    wire[7:0] buff_out0; 
    wire[7:0] buff_out1; 
    wire[7:0] buff_out2; 
    wire[7:0] buff_out3; 
    wire[7:0] buff_out4; 
    wire[7:0] buff_out5; 
    wire[7:0] buff_out6; 
    wire[7:0] buff_out7; 
    wire[7:0] buff_out8; 
    wire[7:0] buff_out9; 
    wire[7:0] buff_out10; 
    wire[7:0] buff_out11; 
    wire dft_clk;

    assign dft_clk = test_i ? tm3_clk_v0 : tm3_clk_v0;

    assign buff_out0 = vidin_in;
    my_fifo_496 fifo0(dft_clk, buff_out0, buff_out1, vidin_new_data);
    my_fifo_496 fifo1(dft_clk, buff_out1, buff_out2, vidin_new_data);
    my_fifo_496 fifo2(dft_clk, buff_out2, buff_out3, vidin_new_data);
    my_fifo_496 fifo3(dft_clk, buff_out3, buff_out4, vidin_new_data);
    my_fifo_496 fifo4(dft_clk, buff_out4, buff_out5, vidin_new_data);
    my_fifo_496 fifo5(dft_clk, buff_out5, buff_out6, vidin_new_data);
    my_fifo_496 fifo6(dft_clk, buff_out6, buff_out7, vidin_new_data);
    my_fifo_496 fifo7(dft_clk, buff_out7, buff_out8, vidin_new_data);
    my_fifo_496 fifo8(dft_clk, buff_out8, buff_out9, vidin_new_data);
    my_fifo_496 fifo9(dft_clk, buff_out9, buff_out10, vidin_new_data);
    my_fifo_496 fifo10(dft_clk, buff_out10, buff_out11, vidin_new_data);
    my_fifo_496 more_inst(dft_clk, buff_out11, vidin_out, vidin_new_data); 
endmodule

module v_fltr_316 (tm3_clk_v0, test_i, vidin_new_data, vidin_in, vidin_out);
    input tm3_clk_v0; 
    input test_i; 
    input vidin_new_data; 
    input[7:0] vidin_in; 
    output[7:0] vidin_out; 
    wire[7:0] vidin_out;
    wire[7:0] buff_out0;
    wire[7:0] buff_out1;
    wire[7:0] buff_out2;
    wire[7:0] buff_out3;
    wire dft_clk;

    assign dft_clk = test_i ? tm3_clk_v0 : tm3_clk_v0;

    assign buff_out0 = vidin_in;
    my_fifo_316 fifo0(dft_clk, buff_out0, buff_out1, vidin_new_data);
    my_fifo_316 fifo1(dft_clk, buff_out1, buff_out2, vidin_new_data);
    my_fifo_316 fifo2(dft_clk, buff_out2, buff_out3, vidin_new_data);
    my_fifo_316 more_inst(dft_clk, buff_out3, vidin_out, vidin_new_data); 
endmodule

module lp_fltr_v1 (clk, test_i, din, dout_1, dout_2, nd);
    input clk; 
    input test_i; 
    input[8 - 1:0] din; 
    output[8 - 1:0] dout_1; 
    reg[8 - 1:0] dout_1;
    output[8 - 1:0] dout_2; 
    reg[8 - 1:0] dout_2;
    input nd; 
    reg[8 - 1:0] din_1_reg; 
    wire[8 - 1:0] buff_out_1; 
    wire[8 - 1:0] buff_out_2; 
    reg[8 - 1:0] din_2_reg; 
    reg[8 - 1:0] din_3_reg; 
    reg[8 + 1:0] add_tmp_1; 
    reg[8 + 1:0] add_tmp_2; 
    wire dft_clk;

    assign dft_clk = test_i ? clk : clk;

    my_fifo_359 ints_fifo_1(dft_clk, din, buff_out_1, nd); 
    my_fifo_359 ints_fifo_2(dft_clk, buff_out_1, buff_out_2, nd); 

    always @(posedge dft_clk)
    begin
        if (nd == 1'b1)
        begin
            din_1_reg <= din; 
            din_2_reg <= buff_out_1; 
            din_3_reg <= buff_out_2; 
            dout_1 <= din; 
            dout_2 <= add_tmp_2[8 + 1:2]; 
        end 
        add_tmp_1 <= ({din_3_reg[8 - 1], din_3_reg[8 - 1], din_3_reg}) + ({din_1_reg[8 - 1], din_1_reg[8 - 1], din_1_reg}); 
        add_tmp_2 <= add_tmp_1 + ({din_2_reg[8 - 1], din_2_reg, 1'b0}); 
    end 
endmodule

module lp_fltr_v2 (clk, test_i, din, dout_1, dout_2, nd);
    input clk; 
    input test_i; 
    input[8 - 1:0] din; 
    output[8 - 1:0] dout_1; 
    reg[8 - 1:0] dout_1;
    output[8 - 1:0] dout_2; 
    reg[8 - 1:0] dout_2;
    input nd; 
    reg[8 - 1:0] din_1_reg; 
    wire[8 - 1:0] buff_out_1; 
    wire[8 - 1:0] buff_out_2; 
    reg[8 - 1:0] din_2_reg; 
    reg[8 - 1:0] din_3_reg; 
    reg[8 + 1:0] add_tmp_1; 
    reg[8 + 1:0] add_tmp_2; 
    wire dft_clk;

    assign dft_clk = test_i ? clk : clk;

    my_fifo_179 ints_fifo_1(dft_clk, din, buff_out_1, nd); 
    my_fifo_179 ints_fifo_2(dft_clk, buff_out_1, buff_out_2, nd); 

    always @(posedge dft_clk)
    begin
        if (nd == 1'b1)
        begin
            din_1_reg <= din; 
            din_2_reg <= buff_out_1; 
            din_3_reg <= buff_out_2; 
            dout_1 <= din; 
            dout_2 <= add_tmp_2[8 + 1:2]; 
        end 
        add_tmp_1 <= ({din_3_reg[8 - 1], din_3_reg[8 - 1], din_3_reg}) + ({din_1_reg[8 - 1], din_1_reg[8 - 1], din_1_reg}); 
        add_tmp_2 <= add_tmp_1 + ({din_2_reg[8 - 1], din_2_reg, 1'b0}); 
    end 
endmodule

`resetall