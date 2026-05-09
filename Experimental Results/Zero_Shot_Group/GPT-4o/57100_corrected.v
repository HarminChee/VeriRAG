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