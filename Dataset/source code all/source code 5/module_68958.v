module cmm_errman_ftl (
                ftl_num,                
                inc_dec_b,
                cmmp_training_err,      
                cmml_protocol_err_n,    
                cmmt_err_rbuf_overflow,
                cmmt_err_fc,
                cmmt_err_tlp_malformed,
                decr_ftl,
                rst,
                clk
                );
  output  [2:0] ftl_num;
  output        inc_dec_b;              
  input         cmmp_training_err;
  input         cmml_protocol_err_n;
  input         cmmt_err_rbuf_overflow;
  input         cmmt_err_fc;
  input         cmmt_err_tlp_malformed;
  input         decr_ftl;
  input         rst;
  input         clk;
  parameter FFD       = 1;        
  reg     [2:0] to_incr;
  reg           add_sub_b;
  always @(cmmt_err_tlp_malformed or
           cmmp_training_err or 
           cmml_protocol_err_n or 
           cmmt_err_rbuf_overflow or cmmt_err_fc or 
           decr_ftl) begin
    case ({cmmt_err_tlp_malformed, cmml_protocol_err_n, cmmt_err_rbuf_overflow, cmmp_training_err, cmmt_err_fc, 
           decr_ftl})   
    6'b000000: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b000001: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b000010: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b000011: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b000100: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b000101: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b000110: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b000111: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001000: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001001: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b001010: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b001011: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001100: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b001101: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001110: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b001111: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b010000: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b010001: begin to_incr = 3'b001; add_sub_b = 1'b0; end
    6'b010010: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b010011: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b010100: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b010101: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b010110: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b010111: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011000: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011001: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b011010: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b011011: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011100: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b011101: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011110: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b011111: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100000: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100001: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b100010: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b100011: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100100: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b100101: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100110: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b100111: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101000: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101001: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b101010: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b101011: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101100: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b101101: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101110: begin to_incr = 3'b101; add_sub_b = 1'b1; end
    6'b101111: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b110000: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b110001: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b110010: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b110011: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b110100: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b110101: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b110110: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b110111: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111000: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111001: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b111010: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b111011: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111100: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b111101: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111110: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b111111: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    default:   begin to_incr = 3'b000; add_sub_b = 1'b1; end
    endcase
  end
  reg     [2:0] reg_ftl_num;
  reg           reg_inc_dec_b;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      reg_ftl_num   <= #FFD 3'b000;
      reg_inc_dec_b <= #FFD 1'b0;
    end
    else begin
      reg_ftl_num   <= #FFD to_incr;
      reg_inc_dec_b <= #FFD add_sub_b;
    end
  end
  assign ftl_num   = reg_ftl_num;
  assign inc_dec_b = reg_inc_dec_b;
endmodule
