// 1_corrected_cdf.v
module combine_res (clk, wen, din_1, din_2, din_3, dout);
    input clk;
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
    always @(posedge clk)
    begin
          if (wen == 1'b1)
          begin
             din_1_reg <= {din_1[7], din_1} ;
             din_2_reg <= din_2 ;
             din_3_reg <= din_3 ;
             dout <= dout_reg ;
          end
          add_tmp <= ({din_1_reg[8], din_1_reg[8], din_1_reg}) + ({din_2_reg[8], din_2_reg[8], din_2_reg}) ;
          dout_reg <= add_tmp + ({din_3_reg[8], din_3_reg[8], din_3_reg}) ;
       end
 endmodule

module v_fltr_496 (tm3_clk_v0, vidin_new_data, vidin_in, vidin_out);
   input tm3_clk_v0;
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
   assign buff_out0 = vidin_in ;
	my_fifo_496 fifo0(tm3_clk_v0, buff_out0, buff_out1, vidin_new_data);
	my_fifo_496 fifo1(tm3_clk_v0, buff_out1, buff_out2, vidin_new_data);
	my_fifo_496 fifo2(tm3_clk_v0, buff_out2, buff_out3, vidin_new_data);
	my_fifo_496 fifo3(tm3_clk_v0, buff_out3, buff_out4, vidin_new_data);
	my_fifo_496 fifo4(tm3_clk_v0, buff_out4, buff_out5, vidin_new_data);
	my_fifo_496 fifo5(tm3_clk_v0, buff_out5, buff_out6, vidin_new_data);
	my_fifo_496 fifo6(tm3_clk_v0, buff_out6, buff_out7, vidin_new_data);
	my_fifo_496 fifo7(tm3_clk_v0, buff_out7, buff_out8, vidin_new_data);
	my_fifo_496 fifo8(tm3_clk_v0, buff_out8, buff_out9, vidin_new_data);
	my_fifo_496 fifo9(tm3_clk_v0, buff_out9, buff_out10, vidin_new_data);
	my_fifo_496 fifo10(tm3_clk_v0, buff_out10, buff_out11, vidin_new_data);
   my_fifo_496 more_inst (tm3_clk_v0, buff_out11, vidin_out, vidin_new_data);
endmodule

module v_fltr_316 (tm3_clk_v0, vidin_new_data, vidin_in, vidin_out);
   input tm3_clk_v0;
   input vidin_new_data;
   input[7:0] vidin_in;
   output[7:0] vidin_out;
   wire[7:0] vidin_out;
   wire[7:0] buff_out0;
   wire[7:0] buff_out1;
   wire[7:0] buff_out2;
   wire[7:0] buff_out3;
   assign buff_out0 = vidin_in ;
	my_fifo_316 fifo0(tm3_clk_v0, buff_out0, buff_out1, vidin_new_data);
	my_fifo_316 fifo1(tm3_clk_v0, buff_out1, buff_out2, vidin_new_data);
	my_fifo_316 fifo2(tm3_clk_v0, buff_out2, buff_out3, vidin_new_data);
   my_fifo_316 more_inst (tm3_clk_v0, buff_out3, vidin_out, vidin_new_data);
endmodule

module lp_fltr_v1 (clk, din, dout_1, dout_2, nd);
   input clk;
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
   my_fifo_359 ints_fifo_1 (clk, din, buff_out_1, nd);
   my_fifo_359 ints_fifo_2 (clk, buff_out_1, buff_out_2, nd);
   always @(posedge clk)
   begin
         if (nd == 1'b1)
         begin
            din_1_reg <= din ;
            din_2_reg <= buff_out_1 ;
            din_3_reg <= buff_out_2 ;
            dout_1 <= din ;
            dout_2 <= add_tmp_2[8 + 1:2] ;
         end
         add_tmp_1 <= ({din_3_reg[8 - 1], din_3_reg[8 - 1], din_3_reg}) + ({din_1_reg[8 - 1], din_1_reg[8 - 1], din_1_reg}) ;
         add_tmp_2 <= add_tmp_1 + ({din_2_reg[8 - 1], din_2_reg, 1'b0}) ;
   end
endmodule

module lp_fltr_v2 (clk, din, dout_1, dout_2, nd);
   input clk;
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
   my_fifo_179 ints_fifo_1 (clk, din, buff_out_1, nd);
   my_fifo_179 ints_fifo_2 (clk, buff_out_1, buff_out_2, nd);
   always @(posedge clk)
   begin
         if (nd == 1'b1)
         begin
            din_1_reg <= din ;
            din_2_reg <= buff_out_1 ;
            din_3_reg <= buff_out_2 ;
            dout_1 <= din ;
            dout_2 <= add_tmp_2[8 + 1:2] ;
         end
         add_tmp_1 <= ({din_3_reg[8 - 1], din_3_reg[8 - 1], din_3_reg}) + ({din_1_reg[8 - 1], din_1_reg[8 - 1], din_1_reg}) ;
         add_tmp_2 <= add_tmp_1 + ({din_2_reg[8 - 1], din_2_reg, 1'b0}) ;
   end
endmodule

module lp_fltr_v4 (clk, din, dout_1, dout_2, nd);
   input clk;
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
   my_fifo_89 ints_fifo_1 (clk, din, buff_out_1, nd);
   my_fifo_89 ints_fifo_2 (clk, buff_out_1, buff_out_2, nd);
   always @(posedge clk)
   begin
         if (nd == 1'b1)
         begin
            din_1_reg <= din ;
            din_2_reg <= buff_out_1 ;
            din_3_reg <= buff_out_2 ;
            dout_1 <= din ;
            dout_2 <= add_tmp_2[8 + 1:2] ;
         end
         add_tmp_1 <= ({din_3_reg[8 - 1], din_3_reg[8 - 1], din_3_reg}) + ({din_1_reg[8 - 1], din_1_reg[8 - 1], din_1_reg}) ;
         add_tmp_2 <= add_tmp_1 + ({din_2_reg[8 - 1], din_2_reg, 1'b0}) ;
   end
endmodule

module scaler (
    tm3_clk_v0,
    vidin_new_data,
    vidin_rgb_reg,
    vidin_addr_reg,
    vidin_new_data_scld_1,
    vidin_new_data_scld_2,
    vidin_new_data_scld_4,
    vidin_gray_scld_1,
    vidin_gray_scld_2,
    vidin_gray_scld_4
);
   input tm3_clk_v0;
   input vidin_new_data;
   input[7:0] vidin_rgb_reg;
   input[3:0] vidin_addr_reg;
   output vidin_new_data_scld_1;
   reg vidin_new_data_scld_1;
   output vidin_new_data_scld_2;
   reg vidin_new_data_scld_2;
   output vidin_new_data_scld_4;
   reg vidin_new_data_scld_4;
   output[7:0] vidin_gray_scld_1;
   reg[7:0] vidin_gray_scld_1;
   output[7:0] vidin_gray_scld_2;
   reg[7:0] vidin_gray_scld_2;
   output[7:0] vidin_gray_scld_4;
   reg[7:0] vidin_gray_scld_4;
   wire[7:0] v_fltr_sc_1;
   wire[7:0] v_fltr_sc_2;
   wire[7:0] v_fltr_sc_4;
   wire[7:0] h_fltr_sc_1;
   wire[7:0] h_fltr_sc_2;
   wire[7:0] h_fltr_sc_4;
   scl_v_fltr scl_v_fltr_inst (tm3_clk_v0, vidin_new_data, vidin_rgb_reg, v_fltr_sc_1, v_fltr_sc_2, v_fltr_sc_4);
   scl_h_fltr scl_h_fltr_inst (tm3_clk_v0, vidin_new_data, v_fltr_sc_1, v_fltr_sc_2, v_fltr_sc_4, h_fltr_sc_1, h_fltr_sc_2, h_fltr_sc_4);
   always @(posedge tm3_clk_v0)
   begin
         vidin_new_data_scld_1 <= vidin_new_data ;
         if (vidin_new_data == 1'b1)
         begin
            vidin_gray_scld_1 <= h_fltr_sc_1 ;
            if ((vidin_addr_reg[0]) == 1'b0 & (vidin_addr_reg[2]) == 1'b0)
            begin
               vidin_gray_scld_2 <= h_fltr_sc_2 ;
               vidin_new_data_scld_2 <= 1'b1 ;
               if ((vidin_addr_reg[1]) == 1'b0 & (vidin_addr_reg[3]) == 1'b0)
               begin
                    vidin_gray_scld_4 <= h_fltr_sc_4 ;
                    vidin_new_data_scld_4 <= 1'b1 ;
               end
               else
               begin
                   vidin_new_data_scld_4 <= 1'b0 ;
               end
            end
            else
            begin
                vidin_new_data_scld_2 <= 1'b0;
                vidin_new_data_scld_4 <= 1'b0;
            end
         end
         else
         begin
            vidin_new_data_scld_2 <= 1'b0;
            vidin_new_data_scld_4 <= 1'b0 ;
         end
   end
endmodule

module scl_v_fltr (clk, nd, d_in, d_out_1, d_out_2, d_out_4);
   input clk;
   input nd;
   input[7:0] d_in;
   output[7:0] d_out_1;
   reg[7:0] d_out_1;
   output[7:0] d_out_2;
   reg[7:0] d_out_2;
   output[7:0] d_out_4;
   reg[7:0] d_out_4;
   wire[7:0] buff_out0;
   wire[7:0] buff_out1;
   wire[7:0] buff_out2;
   wire[7:0] buff_out3;
   wire[7:0] buff_out4;
   wire[7:0] buff_out5;
   wire[7:0] buff_out6;
   wire[7:0] buff_out7;
   reg[7:0] buff_out_reg0;
   reg[7:0] buff_out_reg1;
   reg[7:0] buff_out_reg2;
   reg[7:0] buff_out_reg3;
   reg[7:0] buff_out_reg4;
   reg[7:0] buff_out_reg5;
   reg[7:0] buff_out_reg6;
   reg[7:0] buff_out_reg7;
   reg[9:0] add_2_tmp_1;
   reg[9:0] add_2_tmp_2;
   reg[9:0] add_2_tmp;
   reg[11:0] add_4_tmp_1;
   reg[11:0] add_4_tmp_2;
   reg[11:0] add_4_tmp_3;
   reg[11:0] add_4_tmp_4;
   reg[11:0] add_4_tmp_5;
   reg[11:0] add_4_tmp_6;
   reg[11:0] add_4_tmp_7;
   reg[11:0] add_4_tmp_8;
   reg[11:0] add_4_tmp;
   assign buff_out0 = d_in ;
   my_fifo_496 ints_fifo_gen_0 (clk, buff_out0, buff_out1, nd);
   my_fifo_496 ints_fifo_gen_1 (clk, buff_out1, buff_out2, nd);
   my_fifo_496 ints_fifo_gen_2 (clk, buff_out2, buff_out3, nd);
   my_fifo_496 ints_fifo_gen_3 (clk, buff_out3, buff_out4, nd);
   my_fifo_496 ints_fifo_gen_4 (clk, buff_out4, buff_out5, nd);
   my_fifo_496 ints_fifo_gen_5 (clk, buff_out5, buff_out6, nd);
   my_fifo_496 ints_fifo_gen_6 (clk, buff_out6, buff_out7, nd);
   always @(posedge clk)
   begin
         if (nd == 1'b1)
         begin
            buff_out_reg1 <= buff_out1 ;
            buff_out_reg2 <= buff_out2 ;
            buff_out_reg3 <= buff_out3 ;
            buff_out_reg4 <= buff_out4 ;
            buff_out_reg5 <= buff_out5 ;
            buff_out_reg6 <= buff_out6 ;
            buff_out_reg7 <= buff_out7 ;
            d_out_1 <= buff_