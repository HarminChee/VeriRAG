`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module FIR_Interpolation
               (
                clk,
                enb_1_1_1,
                reset,
                FIR_Interpolation_in_re,
                FIR_Interpolation_in_im,
                FIR_Interpolation_out_re,
                FIR_Interpolation_out_im
                );
  input   clk;
  input   enb_1_1_1;
  input   reset;
  input   signed [15:0] FIR_Interpolation_in_re; 
  input   signed [15:0] FIR_Interpolation_in_im; 
  output  signed [15:0] FIR_Interpolation_out_re; 
  output  signed [15:0] FIR_Interpolation_out_im; 
  parameter signed [15:0] coeffphase1_1 = 16'b1111111100110010; 
  parameter signed [15:0] coeffphase1_2 = 16'b1111111000101100; 
  parameter signed [15:0] coeffphase1_3 = 16'b1111100001010001; 
  parameter signed [15:0] coeffphase1_4 = 16'b0111001100111111; 
  parameter signed [15:0] coeffphase1_5 = 16'b1111100001010001; 
  parameter signed [15:0] coeffphase1_6 = 16'b1111111000101100; 
  parameter signed [15:0] coeffphase1_7 = 16'b1111111100110010; 
  parameter signed [15:0] coeffphase2_1 = 16'b1111111101100001; 
  parameter signed [15:0] coeffphase2_2 = 16'b1111111010000110; 
  parameter signed [15:0] coeffphase2_3 = 16'b1111100011000010; 
  parameter signed [15:0] coeffphase2_4 = 16'b0110110010100111; 
  parameter signed [15:0] coeffphase2_5 = 16'b1111101111000100; 
  parameter signed [15:0] coeffphase2_6 = 16'b1111111011011011; 
  parameter signed [15:0] coeffphase2_7 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase3_1 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase3_2 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase3_3 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase3_4 = 16'b0101101010000011; 
  parameter signed [15:0] coeffphase3_5 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase3_6 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase3_7 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase4_1 = 16'b0000000010111111; 
  parameter signed [15:0] coeffphase4_2 = 16'b0000000111111010; 
  parameter signed [15:0] coeffphase4_3 = 16'b0000111110000110; 
  parameter signed [15:0] coeffphase4_4 = 16'b0100000100110001; 
  parameter signed [15:0] coeffphase4_5 = 16'b0000001011001001; 
  parameter signed [15:0] coeffphase4_6 = 16'b0000000011101010; 
  parameter signed [15:0] coeffphase4_7 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase5_1 = 16'b0000000100101010; 
  parameter signed [15:0] coeffphase5_2 = 16'b0000001101001011; 
  parameter signed [15:0] coeffphase5_3 = 16'b0010011001101010; 
  parameter signed [15:0] coeffphase5_4 = 16'b0010011001101010; 
  parameter signed [15:0] coeffphase5_5 = 16'b0000001101001011; 
  parameter signed [15:0] coeffphase5_6 = 16'b0000000100101010; 
  parameter signed [15:0] coeffphase5_7 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase6_1 = 16'b0000000011101010; 
  parameter signed [15:0] coeffphase6_2 = 16'b0000001011001001; 
  parameter signed [15:0] coeffphase6_3 = 16'b0100000100110001; 
  parameter signed [15:0] coeffphase6_4 = 16'b0000111110000110; 
  parameter signed [15:0] coeffphase6_5 = 16'b0000000111111010; 
  parameter signed [15:0] coeffphase6_6 = 16'b0000000010111111; 
  parameter signed [15:0] coeffphase6_7 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase7_1 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase7_2 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase7_3 = 16'b0101101010000011; 
  parameter signed [15:0] coeffphase7_4 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase7_5 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase7_6 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase7_7 = 16'b0000000000000000; 
  parameter signed [15:0] coeffphase8_1 = 16'b1111111011011011; 
  parameter signed [15:0] coeffphase8_2 = 16'b1111101111000100; 
  parameter signed [15:0] coeffphase8_3 = 16'b0110110010100111; 
  parameter signed [15:0] coeffphase8_4 = 16'b1111100011000010; 
  parameter signed [15:0] coeffphase8_5 = 16'b1111111010000110; 
  parameter signed [15:0] coeffphase8_6 = 16'b1111111101100001; 
  parameter signed [15:0] coeffphase8_7 = 16'b0000000000000000; 
  reg  [2:0] cur_count; 
  wire phase_7; 
  reg  signed [15:0] delay_pipeline_re [0:5] ; 
  reg  signed [15:0] delay_pipeline_im [0:5] ; 
  wire signed [15:0] product_re; 
  wire signed [15:0] product_im; 
  wire signed [15:0] product_mux; 
  wire signed [31:0] mul_temp; 
  wire signed [31:0] mul_temp_1; 
  wire signed [15:0] product_1_re; 
  wire signed [15:0] product_1_im; 
  wire signed [15:0] product_mux_1; 
  wire signed [31:0] mul_temp_2; 
  wire signed [31:0] mul_temp_3; 
  wire signed [15:0] product_2_re; 
  wire signed [15:0] product_2_im; 
  wire signed [15:0] product_mux_2; 
  wire signed [31:0] mul_temp_4; 
  wire signed [31:0] mul_temp_5; 
  wire signed [15:0] product_3_re; 
  wire signed [15:0] product_3_im; 
  wire signed [15:0] product_mux_3; 
  wire signed [31:0] mul_temp_6; 
  wire signed [31:0] mul_temp_7; 
  wire signed [15:0] product_4_re; 
  wire signed [15:0] product_4_im; 
  wire signed [15:0] product_mux_4; 
  wire signed [31:0] mul_temp_8; 
  wire signed [31:0] mul_temp_9; 
  wire signed [15:0] product_5_re; 
  wire signed [15:0] product_5_im; 
  wire signed [15:0] product_mux_5; 
  wire signed [31:0] mul_temp_10; 
  wire signed [31:0] mul_temp_11; 
  wire signed [15:0] product_6_re; 
  wire signed [15:0] product_6_im; 
  wire signed [15:0] product_mux_6; 
  wire signed [31:0] mul_temp_12; 
  wire signed [31:0] mul_temp_13; 
  wire signed [15:0] sum1_re; 
  wire signed [15:0] sum1_im; 
  wire signed [15:0] add_cast; 
  wire signed [15:0] add_cast_1; 
  wire signed [16:0] add_temp; 
  wire signed [15:0] add_cast_2; 
  wire signed [15:0] add_cast_3; 
  wire signed [16:0] add_temp_1; 
  wire signed [15:0] sum2_re; 
  wire signed [15:0] sum2_im; 
  wire signed [15:0] add_cast_4; 
  wire signed [15:0] add_cast_5; 
  wire signed [16:0] add_temp_2; 
  wire signed [15:0] add_cast_6; 
  wire signed [15:0] add_cast_7; 
  wire signed [16:0] add_temp_3; 
  wire signed [15:0] sum3_re; 
  wire signed [15:0] sum3_im; 
  wire signed [15:0] add_cast_8; 
  wire signed [15:0] add_cast_9; 
  wire signed [16:0] add_temp_4; 
  wire signed [15:0] add_cast_10; 
  wire signed [15:0] add_cast_11; 
  wire signed [16:0] add_temp_5; 
  wire signed [15:0] sum4_re; 
  wire signed [15:0] sum4_im; 
  wire signed [15:0] add_cast_12; 
  wire signed [15:0] add_cast_13; 
  wire signed [16:0] add_temp_6; 
  wire signed [15:0] add_cast_14; 
  wire signed [15:0] add_cast_15; 
  wire signed [16:0] add_temp_7; 
  wire signed [15:0] sum5_re; 
  wire signed [15:0] sum5_im; 
  wire signed [15:0] add_cast_16; 
  wire signed [15:0] add_cast_17; 
  wire signed [16:0] add_temp_8; 
  wire signed [15:0] add_cast_18; 
  wire signed [15:0] add_cast_19; 
  wire signed [16:0] add_temp_9; 
  wire signed [15:0] sum6_re; 
  wire signed [15:0] sum6_im; 
  wire signed [15:0] add_cast_20; 
  wire signed [15:0] add_cast_21; 
  wire signed [16:0] add_temp_10; 
  wire signed [15:0] add_cast_22; 
  wire signed [15:0] add_cast_23; 
  wire signed [16:0] add_temp_11; 
  reg  signed [15:0] regout_re; 
  reg  signed [15:0] regout_im; 
  wire signed [15:0] muxout_re; 
  wire signed [15:0] muxout_im; 
  always @ (posedge clk or posedge reset)
    begin: ce_output
      if (reset == 1'b1) begin
        cur_count <= 3'b000;
      end
      else begin
        if (enb_1_1_1 == 1'b1) begin
          if (cur_count == 3'b111) begin
            cur_count <= 3'b000;
          end
          else begin
            cur_count <= cur_count + 1;
          end
        end
      end
    end 
  assign  phase_7 = (cur_count == 3'b111 && enb_1_1_1 == 1'b1)? 1 : 0;
  always @( posedge clk or posedge reset)
    begin: Delay_Pipeline_process
      if (reset == 1'b1) begin
        delay_pipeline_re[0] <= 0;
        delay_pipeline_re[1] <= 0;
        delay_pipeline_re[2] <= 0;
        delay_pipeline_re[3] <= 0;
        delay_pipeline_re[4] <= 0;
        delay_pipeline_re[5] <= 0;
              delay_pipeline_im[0] <= 0;
        delay_pipeline_im[1] <= 0;
        delay_pipeline_im[2] <= 0;
        delay_pipeline_im[3] <= 0;
        delay_pipeline_im[4] <= 0;
        delay_pipeline_im[5] <= 0;
      end
      else begin
        if (phase_7 == 1'b1) begin
          delay_pipeline_re[0] <= FIR_Interpolation_in_re;
          delay_pipeline_re[1] <= delay_pipeline_re[0];
          delay_pipeline_re[2] <= delay_pipeline_re[1];
          delay_pipeline_re[3] <= delay_pipeline_re[2];
          delay_pipeline_re[4] <= delay_pipeline_re[3];
          delay_pipeline_re[5] <= delay_pipeline_re[4];
                  delay_pipeline_im[0] <= FIR_Interpolation_in_im;
          delay_pipeline_im[1] <= delay_pipeline_im[0];
          delay_pipeline_im[2] <= delay_pipeline_im[1];
          delay_pipeline_im[3] <= delay_pipeline_im[2];
          delay_pipeline_im[4] <= delay_pipeline_im[3];
          delay_pipeline_im[5] <= delay_pipeline_im[4];
        end
      end
    end 
  assign product_mux = (cur_count == 3'b000) ? coeffphase1_7 :
                      (cur_count == 3'b001) ? coeffphase2_7 :
                      (cur_count == 3'b010) ? coeffphase3_7 :
                      (cur_count == 3'b011) ? coeffphase4_7 :
                      (cur_count == 3'b100) ? coeffphase5_7 :
                      (cur_count == 3'b101) ? coeffphase6_7 :
                      (cur_count == 3'b110) ? coeffphase7_7 :
                      coeffphase8_7;
  assign mul_temp = delay_pipeline_re[5] * product_mux;
  assign product_re = mul_temp[31:16];
  assign mul_temp_1 = delay_pipeline_im[5] * product_mux;
  assign product_im = mul_temp_1[31:16];
  assign product_mux_1 = (cur_count == 3'b000) ? coeffphase1_6 :
                        (cur_count == 3'b001) ? coeffphase2_6 :
                        (cur_count == 3'b010) ? coeffphase3_6 :
                        (cur_count == 3'b011) ? coeffphase4_6 :
                        (cur_count == 3'b100) ? coeffphase5_6 :
                        (cur_count == 3'b101) ? coeffphase6_6 :
                        (cur_count == 3'b110) ? coeffphase7_6 :
                        coeffphase8_6;
  assign mul_temp_2 = delay_pipeline_re[4] * product_mux_1;
  assign product_1_re = mul_temp_2[31:16];
  assign mul_temp_3 = delay_pipeline_im[4] * product_mux_1;
  assign product_1_im = mul_temp_3[31:16];
  assign product_mux_2 = (cur_count == 3'b000) ? coeffphase1_5 :
                        (cur_count == 3'b001) ? coeffphase2_5 :
                        (cur_count == 3'b010) ? coeffphase3_5 :
                        (cur_count == 3'b011) ? coeffphase4_5 :
                        (cur_count == 3'b100) ? coeffphase5_5 :
                        (cur_count == 3'b101) ? coeffphase6_5 :
                        (cur_count == 3'b110) ? coeffphase7_5 :
                        coeffphase8_5;
  assign mul_temp_4 = delay_pipeline_re[3] * product_mux_2;
  assign product_2_re = mul_temp_4[31:16];
  assign mul_temp_5 = delay_pipeline_im[3] * product_mux_2;
  assign product_2_im = mul_temp_5[31:16];
  assign product_mux_3 = (cur_count == 3'b000) ? coeffphase1_4 :
                        (cur_count == 3'b001) ? coeffphase2_4 :
                        (cur_count == 3'b010) ? coeffphase3_4 :
                        (cur_count == 3'b011) ? coeffphase4_4 :
                        (cur_count == 3'b100) ? coeffphase5_4 :
                        (cur_count == 3'b101) ? coeffphase6_4 :
                        (cur_count == 3'b110) ? coeffphase7_4 :
                        coeffphase8_4;
  assign mul_temp_6 = delay_pipeline_re[2] * product_mux_3;
  assign product_3_re = mul_temp_6[31:16];
  assign mul_temp_7 = delay_pipeline_im[2] * product_mux_3;
  assign product_3_im = mul_temp_7[31:16];
  assign product_mux_4 = (cur_count == 3'b000) ? coeffphase1_3 :
                        (cur_count == 3'b001) ? coeffphase2_3 :
                        (cur_count == 3'b010) ? coeffphase3_3 :
                        (cur_count == 3'b011) ? coeffphase4_3 :
                        (cur_count == 3'b100) ? coeffphase5_3 :
                        (cur_count == 3'b101) ? coeffphase6_3 :
                        (cur_count == 3'b110) ? coeffphase7_3 :
                        coeffphase8_3;
  assign mul_temp_8 = delay_pipeline_re[1] * product_mux_4;
  assign product_4_re = mul_temp_8[31:16];
  assign mul_temp_9 = delay_pipeline_im[1] * product_mux_4;
  assign product_4_im = mul_temp_9[31:16];
  assign product_mux_5 = (cur_count == 3'b000) ? coeffphase1_2 :
                        (cur_count == 3'b001) ? coeffphase2_2 :
                        (cur_count == 3'b010) ? coeffphase3_2 :
                        (cur_count == 3'b011) ? coeffphase4_2 :
                        (cur_count == 3'b100) ? coeffphase5_2 :
                        (cur_count == 3'b101) ? coeffphase6_2 :
                        (cur_count == 3'b110) ? coeffphase7_2 :
                        coeffphase8_2;
  assign mul_temp_10 = delay_pipeline_re[0] * product_mux_5;
  assign product_5_re = mul_temp_10[31:16];
  assign mul_temp_11 = delay_pipeline_im[0] * product_mux_5;
  assign product_5_im = mul_temp_11[31:16];
  assign product_mux_6 = (cur_count == 3'b000) ? coeffphase1_1 :
                        (cur_count == 3'b001) ? coeffphase2_1 :
                        (cur_count == 3'b010) ? coeffphase3_1 :
                        (cur_count == 3'b011) ? coeffphase4_1 :
                        (cur_count == 3'b100) ? coeffphase5_1 :
                        (cur_count == 3'b101) ? coeffphase6_1 :
                        (cur_count == 3'b110) ? coeffphase7_1 :
                        coeffphase8_1;
  assign mul_temp_12 = FIR_Interpolation_in_re * product_mux_6;
  assign product_6_re = mul_temp_12[31:16];
  assign mul_temp_13 = FIR_Interpolation_in_im * product_mux_6;
  assign product_6_im = mul_temp_13[31:16];
  assign add_cast = product_6_re;
  assign add_cast_1 = product_5_re;
  assign add_temp = add_cast + add_cast_1;
  assign sum1_re = add_temp[15:0];
  assign add_cast_2 = product_6_im;
  assign add_cast_3 = product_5_im;
  assign add_temp_1 = add_cast_2 + add_cast_3;
  assign sum1_im = add_temp_1[15:0];
  assign add_cast_4 = sum1_re;
  assign add_cast_5 = product_4_re;
  assign add_temp_2 = add_cast_4 + add_cast_5;
  assign sum2_re = add_temp_2[15:0];
  assign add_cast_6 = sum1_im;
  assign add_cast_7 = product_4_im;
  assign add_temp_3 = add_cast_6 + add_cast_7;
  assign sum2_im = add_temp_3[15:0];
  assign add_cast_8 = sum2_re;
  assign add_cast_9 = product_3_re;
  assign add_temp_4 = add_cast_8 + add_cast_9;
  assign sum3_re = add_temp_4[15:0];
  assign add_cast_10 = sum2_im;
  assign add_cast_11 = product_3_im;
  assign add_temp_5 = add_cast_10 + add_cast_11;
  assign sum3_im = add_temp_5[15:0];
  assign add_cast_12 = sum3_re;
  assign add_cast_13 = product_2_re;
  assign add_temp_6 = add_cast_12 + add_cast_13;
  assign sum4_re = add_temp_6[15:0];
  assign add_cast_14 = sum3_im;
  assign add_cast_15 = product_2_im;
  assign add_temp_7 = add_cast_14 + add_cast_15;
  assign sum4_im = add_temp_7[15:0];
  assign add_cast_16 = sum4_re;
  assign add_cast_17 = product_1_re;
  assign add_temp_8 = add_cast_16 + add_cast_17;
  assign sum5_re = add_temp_8[15:0];
  assign add_cast_18 = sum4_im;
  assign add_cast_19 = product_1_im;
  assign add_temp_9 = add_cast_18 + add_cast_19;
  assign sum5_im = add_temp_9[15:0];
  assign add_cast_20 = sum5_re;
  assign add_cast_21 = product_re;
  assign add_temp_10 = add_cast_20 + add_cast_21;
  assign sum6_re = add_temp_10[15:0];
  assign add_cast_22 = sum5_im;
  assign add_cast_23 = product_im;
  assign add_temp_11 = add_cast_22 + add_cast_23;
  assign sum6_im = add_temp_11[15:0];
  always @ (posedge clk or posedge reset)
    begin: DataHoldRegister_process
      if (reset == 1'b1) begin
        regout_re <= 0;
        regout_im <= 0;
      end
      else begin
        if (enb_1_1_1 == 1'b1) begin
          regout_re <= sum6_re;
  regout_im <= sum6_im;
        end
      end
    end 
  assign muxout_re = (enb_1_1_1 == 1'b1) ? sum6_re :
               regout_re;
  assign muxout_im = (enb_1_1_1 == 1'b1) ? sum6_im :
               regout_im;
  assign FIR_Interpolation_out_re = muxout_re;
  assign FIR_Interpolation_out_im = muxout_im;
endmodule  
