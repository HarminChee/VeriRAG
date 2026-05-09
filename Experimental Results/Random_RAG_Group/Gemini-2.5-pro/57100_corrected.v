module h_fltr (tm3_clk_v0, vidin_new_data, vidin_in_f1, vidin_in_f2, vidin_in_f3, vidin_in_h1, vidin_in_h2, vidin_in_h3, vidin_in_h4, real_z_reg, imag_z_reg, real_p_reg, imag_p_reg, real_n_reg, imag_n_reg);
   input tm3_clk_v0;
   input vidin_new_data;
   input[15:0] vidin_in_f1;
   input[15:0] vidin_in_f2;
   input[15:0] vidin_in_f3;
   input[15:0] vidin_in_h1;
   input[15:0] vidin_in_h2;
   input[15:0] vidin_in_h3;
   input[15:0] vidin_in_h4;
   output[15:0] real_z_reg;
   reg[15:0] real_z_reg;
   output[15:0] imag_z_reg;
   reg[15:0] imag_z_reg;
   output[15:0] real_p_reg;
   reg[15:0] real_p_reg;
   output[15:0] imag_p_reg;
   reg[15:0] imag_p_reg;
   output[15:0] real_n_reg;
   reg[15:0] real_n_reg;
   output[15:0] imag_n_reg;
   reg[15:0] imag_n_reg;
   wire[27:0] vidin_out_temp_f1;
   reg[27:0] vidin_out_reg_f1;
   wire my_fir_rdy_f1;
   wire[27:0] vidin_out_temp_f2;
   reg[27:0] vidin_out_reg_f2;
   wire my_fir_rdy_f2;
   wire[27:0] vidin_out_temp_f3;
   reg[27:0] vidin_out_reg_f3;
   wire my_fir_rdy_f3;
   wire[27:0] vidin_out_temp_h1;
   reg[27:0] vidin_out_reg_h1;
   wire my_fir_rdy_h1;
   wire[27:0] vidin_out_temp_h2;
   reg[27:0] vidin_out_reg_h2;
   wire my_fir_rdy_h2;
   wire[27:0] vidin_out_temp_h3;
   reg[27:0] vidin_out_reg_h3;
   wire my_fir_rdy_h3;
   wire[27:0] vidin_out_temp_h4;
   reg[27:0] vidin_out_reg_h4;
   wire my_fir_rdy_h4;
   wire[28:0] sum_tmp_1;
   wire[28:0] sum_tmp_2;
   wire[28:0] sum_tmp_3;
   wire[28:0] sum_tmp_4;
   wire[30:0] sum_tmp_5;
   wire[15:0] real_p;
   wire[15:0] imag_p;
   wire[15:0] real_z;
   wire[15:0] imag_z;
   wire[15:0] real_n;
   wire[15:0] imag_n;
   wire[16:0] tmp;
   my_fir_f1 your_instance_name_f1 (tm3_clk_v0, vidin_new_data, my_fir_rdy_f1, vidin_in_f2, vidin_out_temp_f1);
   my_fir_f2 your_instance_name_f2 (tm3_clk_v0, vidin_new_data, my_fir_rdy_f2, vidin_in_f1, vidin_out_temp_f2);
   my_fir_f3 your_instance_name_f3 (tm3_clk_v0, vidin_new_data, my_fir_rdy_f3, vidin_in_f3, vidin_out_temp_f3);
   my_fir_h1 your_instance_name_h1 (tm3_clk_v0, vidin_new_data, my_fir_rdy_h1, vidin_in_h2, vidin_out_temp_h1);
   my_fir_h2 your_instance_name_h2 (tm3_clk_v0, vidin_new_data, my_fir_rdy_h2, vidin_in_h1, vidin_out_temp_h2);
   my_fir_h3 your_instance_name_h3 (tm3_clk_v0, vidin_new_data, my_fir_rdy_h3, vidin_in_h4, vidin_out_temp_h3);
   my_fir_h4 your_instance_name_h4 (tm3_clk_v0, vidin_new_data, my_fir_rdy_h4, vidin_in_h3, vidin_out_temp_h4);
   steer_fltr my_steer_fltr_inst (tm3_clk_v0, vidin_new_data, vidin_out_reg_f1, vidin_out_reg_f2, vidin_out_reg_f3, vidin_out_reg_h1, vidin_out_reg_h2, vidin_out_reg_h3, vidin_out_reg_h4, real_z, imag_z, real_p, imag_p, real_n, imag_n);
   always @(posedge tm3_clk_v0)
   begin
         if (my_fir_rdy_f1 == 1'b1)
         begin
            vidin_out_reg_f1 <= vidin_out_temp_f1 ;
         end
         if (my_fir_rdy_f2 == 1'b1)
         begin
            vidin_out_reg_f2 <= vidin_out_temp_f2 ;
         end
         if (my_fir_rdy_f3 == 1'b1)
         begin
            vidin_out_reg_f3 <= vidin_out_temp_f3 ;
         end
         if (my_fir_rdy_h1 == 1'b1)
         begin
            vidin_out_reg_h1 <= vidin_out_temp_h1 ;
         end
         if (my_fir_rdy_h2 == 1'b1)
         begin
            vidin_out_reg_h2 <= vidin_out_temp_h2 ;
         end
         if (my_fir_rdy_h3 == 1'b1)
         begin
            vidin_out_reg_h3 <= vidin_out_temp_h3 ;
         end
         if (my_fir_rdy_h4 == 1'b1)
         begin
            vidin_out_reg_h4 <= vidin_out_temp_h4 ;
         end
   end
   always @(posedge tm3_clk_v0)
   begin
         real_z_reg <= real_z ;
         imag_z_reg <= imag_z ;
         real_p_reg <= real_p ;
         imag_p_reg <= imag_p ;
         real_n_reg <= real_n ;
         imag_n_reg <= imag_n ;
   end
endmodule
module steer_fltr (clk, new_data, f1, f2, f3, h1, h2, h3, h4, re_z, im_z, re_p, im_p, re_n, im_n);
   input clk;
   input new_data;
   input[27:0] f1;
   input[27:0] f2;
   input[27:0] f3;
   input[27:0] h1;
   input[27:0] h2;
   input[27:0] h3;
   input[27:0] h4;
   output[15:0] re_z;
   reg[15:0] re_z;
   output[15:0] im_z;
   reg[15:0] im_z;
   output[15:0] re_p;
   reg[15:0] re_p;
   output[15:0] im_p;
   reg[15:0] im_p;
   output[15:0] re_n;
   reg[15:0] re_n;
   output[15:0] im_n;
   reg[15:0] im_n;
   reg[27:0] f1_reg;
   reg[27:0] f2_reg;
   reg[27:0] f3_reg;
   reg[27:0] h1_reg;
   reg[27:0] h2_reg;
   reg[27:0] h3_reg;
   reg[27:0] h4_reg;
   reg[28:0] re_z_tmp_1;
   reg[28:0] im_z_tmp_1;
   reg[28:0] re_p_tmp_1;
   reg[28:0] re_p_tmp_2;
   reg[28:0] re_p_tmp_3;
   reg[28:0] im_p_tmp_1;
   reg[28:0] im_p_tmp_2;
   reg[28:0] im_p_tmp_3;
   reg[28:0] im_p_tmp_4;
   reg[30:0] re_z_tmp;
   reg[30:0] im_z_tmp;
   reg[30:0] re_p_tmp;
   reg[30:0] im_p_tmp;
   reg[30:0] re_n_tmp;
   reg[30:0] im_n_tmp;
   always @(posedge clk)
   begin
         if (new_data == 1'b1)
         begin
            f1_reg <= f1 ;
            f2_reg <= f2 ;
            f3_reg <= f3 ;
            h1_reg <= h1 ;
            h2_reg <= h2 ;
            h3_reg <= h3 ;
            h4_reg <= h4 ;
         end
   end
   always @(posedge clk)
   begin
         re_z_tmp_1 <= {f1_reg[27], f1_reg} ;
         im_z_tmp_1 <= {h1_reg[27], h1_reg} ;
         re_p_tmp_1 <= {f1_reg[27], f1_reg[27], f1_reg[27:1]} ;
         re_p_tmp_2 <= {f3_reg[27], f3_reg[27:0]} ;
         re_p_tmp_3 <= {f2_reg[27], f2_reg[27], f2_reg[27:1]} ;
         im_p_tmp_1 <= ({h1_reg[27], h1_reg[27], h1_reg[27], h1_reg[27:2]}) + ({h1_reg[27], h1_reg[27], h1_reg[27], h1_reg[27], h1_reg[27:3]}) ;
         im_p_tmp_2 <= ({h4_reg[27], h4_reg}) + ({h4_reg[27], h4_reg[27], h4_reg[27], h4_reg[27], h4_reg[27], h4_reg[27:4]}) ;
         im_p_tmp_3 <= ({h3_reg[27], h3_reg}) + ({h3_reg[27], h3_reg[27], h3_reg[27], h3_reg[27], h3_reg[27], h3_reg[27:4]}) ;
         im_p_tmp_4 <= ({h2_reg[27], h2_reg[27], h2_reg[27], h2_reg[27:2]}) + ({h2_reg[27], h2_reg[27], h2_reg[27], h2_reg[27], h2_reg[27:3]}) ;
         re_z_tmp <= {re_z_tmp_1[28], re_z_tmp_1[28], re_z_tmp_1} ;
         im_z_tmp <= {im_z_tmp_1[28], im_z_tmp_1[28], im_z_tmp_1} ;
         re_p_tmp <= ({re_p_tmp_1[28], re_p_tmp_1[28], re_p_tmp_1}) - ({re_p_tmp_2[28], re_p_tmp_2[28], re_p_tmp_2}) + ({re_p_tmp_3[28], re_p_tmp_3[28], re_p_tmp_3}) ;
         im_p_tmp <= ({im_p_tmp_1[28], im_p_tmp_1[28], im_p_tmp_1}) - ({im_p_tmp_2[28], im_p_tmp_2[28], im_p_tmp_2}) + ({im_p_tmp_3[28], im_p_tmp_3[28], im_p_tmp_3}) - ({im_p_tmp_4[28], im_p_tmp_4[28], im_p_tmp_4}) ;
         re_n_tmp <= ({re_p_tmp_1[28], re_p_tmp_1[28], re_p_tmp_1}) + ({re_p_tmp_2[28], re_p_tmp_2[28], re_p_tmp_2}) + ({re_p_tmp_3[28], re_p_tmp_3[28], re_p_tmp_3}) ;
         im_n_tmp <= ({im_p_tmp_1[28], im_p_tmp_1[28], im_p_tmp_1}) + ({im_p_tmp_2[28], im_p_tmp_2[28], im_p_tmp_2}) + ({im_p_tmp_3[28], im_p_tmp_3[28], im_p_tmp_3}) + ({im_p_tmp_4[28], im_p_tmp_4[28], im_p_tmp_4}) ;
         re_z <= re_z_tmp[30:15] ;
         im_z <= im_z_tmp[30:15] ;
         re_p <= re_p_tmp[30:15] ;
         im_p <= im_p_tmp[30:15] ;
         re_n <= re_n_tmp[30:15] ;
         im_n <= im_n_tmp[30:15] ;
   end
endmodule
module v_fltr_496x7 (tm3_clk_v0, vidin_new_data, vidin_in, vidin_out_f1, vidin_out_f2, vidin_out_f3, vidin_out_h1, vidin_out_h2, vidin_out_h3, vidin_out_h4);
   parameter horiz_length  = 9'b111110000;
   parameter vert_length  = 3'b111;
   input tm3_clk_v0;
   input vidin_new_data;
   input[7:0] vidin_in;
   output[15:0] vidin_out_f1;
   wire[15:0] vidin_out_f1;
   output[15:0] vidin_out_f2;
   wire[15:0] vidin_out_f2;
   output[15:0] vidin_out_f3;
   wire[15:0] vidin_out_f3;
   output[15:0] vidin_out_h1;
   wire[15:0] vidin_out_h1;
   output[15:0] vidin_out_h2;
   wire[15:0] vidin_out_h2;
   output[15:0] vidin_out_h3;
   wire[15:0] vidin_out_h3;
   output[15:0] vidin_out_h4;
   wire[15:0] vidin_out_h4;
   wire[7:0] buff_out0;
   wire[7:0] buff_out1;
   wire[7:0] buff_out2;
   wire[7:0] buff_out3;
   wire[7:0] buff_out4;
   wire[7:0] buff_out5;
   wire[7:0] buff_out6;
   wire[7:0] buff_out7;
 	fifo496 fifo0(tm3_clk_v0, vidin_new_data, buff_out0, buff_out1);
 	fifo496 fifo1(tm3_clk_v0, vidin_new_data, buff_out1, buff_out2);
 	fifo496 fifo2(tm3_clk_v0, vidin_new_data, buff_out2, buff_out3);
 	fifo496 fifo3(tm3_clk_v0, vidin_new_data, buff_out3, buff_out4);
 	fifo496 fifo4(tm3_clk_v0, vidin_new_data, buff_out4, buff_out5);
 	fifo496 fifo5(tm3_clk_v0, vidin_new_data, buff_out5, buff_out6);
 	fifo496 fifo6(tm3_clk_v0, vidin_new_data, buff_out6, buff_out7);
   fltr_compute_f1 inst_fltr_compute_f1 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_f1);
   fltr_compute_f2 inst_fltr_compute_f2 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_f2);
   fltr_compute_f3 inst_fltr_compute_f3 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_f3);
   fltr_compute_h1 inst_fltr_compute_h1 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h1);
   fltr_compute_h2 inst_fltr_compute_h2 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h2);
   fltr_compute_h3 inst_fltr_compute_h3 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h3);
   fltr_compute_h4 inst_fltr_compute_h4 (tm3_clk_v0, {buff_out1, buff_out2, buff_out3, buff_out4, buff_out5, buff_out6, buff_out7}, vidin_out_h4);
         assign buff_out0 = vidin_in ;
endmodule
module v_fltr_316x7 (tm3_clk_v0, vidin_new_data, vidin_in, vidin_out_f1, vidin_out_f2, vidin_out_f3, vidin_out_h1, vidin_out_h2, vidin_out_h3, vidin_out_h4);
   parameter horiz_length  = 9'b100111100;
   parameter vert_length  = 3'b111;
   input tm3_clk_v0;
   input vidin_new_data;
   input[7:0] vidin_in;
   output[15:0] vidin_out_f1;
   wire[15:0] vidin_out_f1;
   output[15:0] vidin_out_f2;
   wire[1