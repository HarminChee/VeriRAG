module cmm_errman_cor (
                cor_num,                
                inc_dec_b,
                reg_decr_cor,
                add_input_one,      
                add_input_two_n,
                add_input_three_n,
                add_input_four_n,
                add_input_five_n,
                add_input_six_n,
                decr_cor,
                rst,
                clk
                );
  output  [2:0] cor_num;
  output        inc_dec_b;              
  output        reg_decr_cor;
  input         add_input_one;
  input         add_input_two_n;
  input         add_input_three_n;
  input         add_input_four_n;
  input         add_input_five_n;
  input         add_input_six_n;
  input         decr_cor;
  input         rst;
  input         clk;
  parameter FFD       = 1;        
  reg     [2:0] to_incr         ;
  reg           add_sub_b       ;
  reg           add_input_one_d;
  reg           add_input_two_n_d;
  reg           add_input_three_n_d;
  reg           add_input_four_n_d;
  reg           add_input_five_n_d;
  reg           add_input_six_n_d;
  always @(posedge clk)
  begin
    if (rst) begin
      add_input_one_d     <= #FFD 0;
      add_input_two_n_d   <= #FFD 1;
      add_input_three_n_d <= #FFD 1;
      add_input_four_n_d  <= #FFD 1;
      add_input_five_n_d  <= #FFD 1;
      add_input_six_n_d   <= #FFD 1;
    end else begin
      add_input_one_d     <= #FFD add_input_one;
      add_input_two_n_d   <= #FFD add_input_two_n;
      add_input_three_n_d <= #FFD add_input_three_n;
      add_input_four_n_d  <= #FFD add_input_four_n;
      add_input_five_n_d  <= #FFD add_input_five_n;
      add_input_six_n_d   <= #FFD add_input_six_n;
    end
  end
  always @*
  begin
    case ({add_input_six_n_d, add_input_one_d,    
           add_input_two_n_d, add_input_three_n_d, 
           add_input_four_n_d,  add_input_five_n_d})   
    6'b00_0000: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0001: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0010: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0011: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0100: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0101: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0110: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_0111: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1000: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1001: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1010: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1011: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1100: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1101: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1110: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b00_1111: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b01_0000: begin   to_incr  = 3'b110;
                        add_sub_b = 1'b1;
                end
    6'b01_0001: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_0010: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_0011: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_0100: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_0101: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_0110: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_0111: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1000: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b01_1001: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_1010: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_1011: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1100: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b01_1101: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1110: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b01_1111: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b10_0000: begin   to_incr  = 3'b100;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0001: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0010: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0011: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0100: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0101: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0110: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_0111: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1000: begin   to_incr  = 3'b011;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1001: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1010: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1011: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1100: begin   to_incr  = 3'b010;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1101: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1110: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b10_1111: begin   to_incr  = 3'b001;                      
                        add_sub_b = 1'b1;                         
                end                                               
    6'b11_0000: begin   to_incr  = 3'b101;
                        add_sub_b = 1'b1;
                end
    6'b11_0001: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_0010: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_0011: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_0100: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_0101: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_0110: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_0111: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1000: begin   to_incr  = 3'b100;
                        add_sub_b = 1'b1;
                end
    6'b11_1001: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_1010: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_1011: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1100: begin   to_incr  = 3'b011;
                        add_sub_b = 1'b1;
                end
    6'b11_1101: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1110: begin   to_incr  = 3'b010;
                        add_sub_b = 1'b1;
                end
    6'b11_1111: begin   to_incr  = 3'b001;
                        add_sub_b = 1'b1;
                end
    default:  begin   to_incr   = 3'b000;
                      add_sub_b = 1'b1;
              end
    endcase
  end
  reg     [2:0] reg_cor_num;
  reg           reg_inc_dec_b;
  reg           reg_decr_cor;
  always @(posedge clk)
  begin
    if (rst)
    begin
      reg_cor_num   <= #FFD 3'b000;   
      reg_inc_dec_b <= #FFD 1'b0;
      reg_decr_cor  <= #FFD 1'b0;
    end
    else
    begin
      reg_cor_num   <= #FFD to_incr;
      reg_inc_dec_b <= #FFD ~(add_input_six_n_d && ~add_input_one_d &&
                              add_input_two_n_d && add_input_three_n_d &&
                              add_input_four_n_d && add_input_five_n_d && decr_cor);
      reg_decr_cor  <= #FFD  (add_input_six_n_d && ~add_input_one_d &&
                              add_input_two_n_d && add_input_three_n_d &&
                              add_input_four_n_d && add_input_five_n_d) ?
                             ~decr_cor : decr_cor;
    end
  end
  assign cor_num   = reg_cor_num;
  assign inc_dec_b = reg_inc_dec_b;
endmodule
