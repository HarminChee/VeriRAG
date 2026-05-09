module acl_fp_custom_mul_hc_core_mult(
  input logic clock,
  input logic resetn,
  input logic input_enable,
  input logic output_enable,
  input logic [23:0] dataa,
  input logic [23:0] datab,
  output logic [47:0] result
);
  logic [35:0] mult_a_result, mult_b_result, mult_c_result, mult_d_result;
  logic [71:0] mac_result;
  logic [35:0] dataa_ext, datab_ext;
  assign dataa_ext = {dataa, 12'd0};  
  assign datab_ext = {datab, 12'd0};  
  assign result = mac_result[71 -: 48];
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("false"),
    .signb_internally_grounded("false")
  ) 
  mac_mult_a(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[35:18]),
    .datab(datab_ext[35:18]),
    .dataout(mult_a_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("true"),
    .signb_internally_grounded("false")
  )
  mac_mult_b(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[17:0]),
    .datab(datab_ext[35:18]),
    .dataout(mult_b_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("false"),
    .signb_internally_grounded("true")
  )
  mac_mult_c(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[35:18]),
    .datab(datab_ext[17:0]),
    .dataout(mult_c_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("true"),
    .signb_internally_grounded("true")
  )
  mac_mult_d(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[17:0]),
    .datab(datab_ext[17:0]),
    .dataout(mult_d_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_out #(
    .dataa_width(36),
    .datab_width(36),
    .datac_width(36),
    .datad_width(36),
    .first_adder0_clock("0"),
    .first_adder1_clock("0"),
    .first_adder0_clear("0"),
    .first_adder1_clear("0"),
    .output_clock("0"),
    .output_clear("0"),
    .operation_mode("36_bit_multiply")
  )
  mac_out(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(mult_a_result),
    .datab(mult_b_result),
    .datac(mult_c_result),
    .datad(mult_d_result),
    .dataout(mac_result),
    .clk({3'b000, clock}),
    .ena({3'b000, output_enable}),
    .aclr({3'b000, ~resetn})
  );
endmodule
module acl_fp_custom_mul_hc_core #(
  parameter integer HIGH_CAPACITY = 1   
)
(
	input logic clock, 
  input logic resetn,
	input logic valid_in, 
  input logic stall_in,
	output logic valid_out, 
  output logic stall_out,
  input logic enable,
	input logic [31:0] dataa,
	input logic [31:0] datab,
	output logic [31:0] result
);
  struct packed
  {
    logic sign_a, sign_b;
    logic [7:0] exponent_a, exponent_b;
    logic [22:0] mantissa_a, mantissa_b;
  } s0;
  assign {s0.sign_a, s0.exponent_a, s0.mantissa_a} = dataa;
  assign {s0.sign_b, s0.exponent_b, s0.mantissa_b} = datab;
  typedef struct packed
  {
    logic valid;
    logic sign_a, sign_b;
    logic [7:0] exponent_a, exponent_b;
    logic mantissa_a_0s, mantissa_b_0s;
    logic [10:0] top_mantissa_a, top_mantissa_b;
  } stage1_regs;
  stage1_regs s1 ;
	logic stall_in_1, stall_out_1;
	logic valid_in_1, valid_out_1;
  assign valid_in_1 = valid_in;
  assign valid_out_1 = s1.valid;
  assign stall_out_1 = HIGH_CAPACITY ? (valid_out_1 & stall_in_1) : ~enable;
  assign stall_out = stall_out_1;
	always @(posedge clock or negedge resetn)
	begin
		if (~resetn)
		begin
      s1 <= 'x;
      s1.valid <= 1'b0;
		end
		else if (~stall_out_1)
		begin
			s1.valid <= valid_in_1;
			s1.sign_a <= s0.sign_a;
			s1.exponent_a <= s0.exponent_a;
			s1.sign_b <= s0.sign_b;
			s1.exponent_b <= s0.exponent_b;
      s1.mantissa_a_0s <= (s0.mantissa_a[11:0] == '0);
      s1.mantissa_b_0s <= (s0.mantissa_b[11:0] == '0);
      s1.top_mantissa_a <= s0.mantissa_a[22:12];
      s1.top_mantissa_b <= s0.mantissa_b[22:12];
		end
	end
  typedef struct packed
  {
    logic valid;
    logic sign;
    logic [8:0] exponent;   
    logic exponent_a_0s, exponent_b_0s;
    logic exponent_a_1s, exponent_b_1s;
    logic mantissa_a_0s, mantissa_b_0s;
  } stage2_regs;
  stage2_regs s2 ;
	logic stall_in_2, stall_out_2, stall_out_3;
	logic valid_in_2, valid_out_2;
  assign valid_in_2 = valid_out_1;
  assign valid_out_2 = s2.valid;
  assign stall_out_2 = HIGH_CAPACITY ? stall_out_3 : ~enable;
  assign stall_in_1 = stall_out_2;
  always @(posedge clock or negedge resetn)
  begin
    if (~resetn)
    begin
      s2 <= 'x;
      s2.valid <= 1'b0;
    end
    else if (~stall_out_2)
    begin
      s2.valid <= valid_in_2;
      s2.sign <= s1.sign_a ^ s1.sign_b;
      s2.exponent <= {1'b0, s1.exponent_a} + {1'b0, s1.exponent_b};
      s2.exponent_a_0s <= (s1.exponent_a == '0);
      s2.exponent_b_0s <= (s1.exponent_b == '0);
      s2.exponent_a_1s <= (s1.exponent_a == '1);
      s2.exponent_b_1s <= (s1.exponent_b == '1);
      s2.mantissa_a_0s <= s1.mantissa_a_0s & (s1.top_mantissa_a == '0);
      s2.mantissa_b_0s <= s1.mantissa_b_0s & (s1.top_mantissa_b == '0);
    end
  end
  typedef struct packed
  {
    logic valid;
    logic sign;
    logic [7:0] exponent;   
    logic exponent_ge_254;  
    logic exponent_gt_254;  
    logic exponent_ge_0;  
    logic exponent_gt_0;  
    logic nan;
  } stage3_regs;
  struct packed
  {
    logic [47:0] mantissa;  
  } s3mult;
  stage3_regs s3 ;
	logic stall_in_3;   
	logic valid_in_3, valid_out_3;
  assign valid_in_3 = valid_out_2;
  assign valid_out_3 = s3.valid;
  assign stall_out_3 = HIGH_CAPACITY ? (valid_out_3 & stall_in_3) : ~enable;
  assign stall_in_2 = stall_out_3;
  logic a_is_inf_3, b_is_inf_3;
  logic a_is_nan_3, b_is_nan_3;
  logic a_is_zero_3, b_is_zero_3;
  assign a_is_inf_3 = (s2.exponent_a_1s & s2.mantissa_a_0s);
  assign b_is_inf_3 = (s2.exponent_b_1s & s2.mantissa_b_0s);
  assign a_is_nan_3 = (s2.exponent_a_1s & ~s2.mantissa_a_0s);
  assign b_is_nan_3 = (s2.exponent_b_1s & ~s2.mantissa_b_0s);
  assign a_is_zero_3 = (s2.exponent_a_0s & s2.mantissa_a_0s);
  assign b_is_zero_3 = (s2.exponent_b_0s & s2.mantissa_b_0s);
  logic inf_times_zero_3, inf_times_non_zero_3;
  assign inf_times_zero_3 = (a_is_inf_3 & b_is_zero_3) | (b_is_inf_3 & a_is_zero_3);
  assign inf_times_non_zero_3 = (a_is_inf_3 & ~b_is_zero_3) | (b_is_inf_3 & ~a_is_zero_3);
  logic one_input_is_denorm_3;
  assign one_input_is_denorm_3 = s2.exponent_a_0s | s2.exponent_b_0s;
  logic one_input_is_nan_3;
  assign one_input_is_nan_3 = a_is_nan_3 | b_is_nan_3;
  always @(posedge clock or negedge resetn)
  begin
    if (~resetn)
    begin
      s3 <= 'x;
      s3.valid <= 1'b0;
    end
    else if (~stall_out_3)
    begin
      s3.valid <= valid_in_3;
      s3.sign <= s2.sign;
      s3.exponent <= s2.exponent - 9'd127;
      if( inf_times_non_zero_3 )
      begin
        s3.exponent_ge_254 <= 1'b1;
        s3.exponent_gt_254 <= 1'b1;
        s3.exponent_ge_0 <= 1'b1;
        s3.exponent_gt_0 <= 1'b1;
      end
      else if( one_input_is_denorm_3 )
      begin
        s3.exponent_ge_254 <= 1'b0;
        s3.exponent_gt_254 <= 1'b0;
        s3.exponent_ge_0 <= 1'b0;
        s3.exponent_gt_0 <= 1'b0;
      end
      else
      begin
        s3.exponent_ge_254 <= (s2.exponent >= (9'd254 + 9'd127));
        s3.exponent_gt_254 <= (s2.exponent >  (9'd254 + 9'd127));
        s3.exponent_ge_0 <= (s2.exponent >= (9'd0 + 9'd127));
        s3.exponent_gt_0 <= (s2.exponent >  (9'd0 + 9'd127));
      end
      if( one_input_is_nan_3 | inf_times_zero_3 )
        s3.nan <= 1'b1;
      else
        s3.nan <= 1'b0;
    end
  end
  logic [23:0] man_mult_dataa, man_mult_datab;
  assign man_mult_dataa = {1'b1, s0.mantissa_a};
  assign man_mult_datab = {1'b1, s0.mantissa_b};
  acl_fp_custom_mul_hc_core_mult man_mult(
    .clock(clock),
    .resetn(1'b1),  
    .input_enable(~stall_out_1),
    .output_enable(~stall_out_3),
    .dataa(man_mult_dataa),
    .datab(man_mult_datab),
    .result(s3mult.mantissa)
  );
  typedef struct packed
  {
    logic valid;
    logic sign;
    logic [7:0] exponent;     
    logic exponent_ge_254;    
    logic exponent_gt_254;    
    logic exponent_ge_0;    
    logic exponent_gt_0;    
    logic nan;
    logic [24:0] mantissa;    
    logic [1:0] round_amount;   
    logic [1:0] round;      
  } stage4_regs;
  stage4_regs s4 ;
	logic stall_in_4, stall_out_4;
	logic valid_in_4, valid_out_4;
  assign valid_in_4 = valid_out_3;
  assign valid_out_4 = s4.valid;
  assign stall_out_4 = HIGH_CAPACITY ? (valid_out_4 & stall_in_4) : ~enable;
  assign stall_in_3 = stall_out_4;
  always @(posedge clock or negedge resetn)
  begin
    if (~resetn)
    begin
      s4 <= 'x;
      s4.valid <= 1'b0;
    end
    else if (~stall_out_4)
    begin
      s4.valid <= valid_in_4;
      s4.sign <= s3.sign;
      s4.exponent <= s3.exponent;
      s4.exponent_ge_254 <= s3.exponent_ge_254;
      s4.exponent_gt_254 <= s3.exponent_gt_254;
      s4.exponent_ge_0 <= s3.exponent_ge_0;
      s4.exponent_gt_0 <= s3.exponent_gt_0;
      s4.nan <= s3.nan;
      s4.mantissa <= s3mult.mantissa[47 -: 25];
      s4.round <= '0;
      if( s3mult.mantissa[47] )
      begin
        s4.round_amount <= 2'd1;
        if( s3mult.mantissa[23] )   
        begin
          if( s3mult.mantissa[24] )
            s4.round[1] <= 1'b1;
          if( |s3mult.mantissa[22:16] )
            s4.round[1] <= 1'b1;
          if( |s3mult.mantissa[15:0] )
            s4.round[0] <= 1'b1;
        end
      end
      else
      begin
        if( s3.exponent_ge_0 & ~s3.exponent_gt_0 )  
        begin
          s4.round_amount <= 2'd1;
          if( s3mult.mantissa[23] )   
          begin
            if( s3mult.mantissa[24] )
              s4.round[1] <= 1'b1;
            if( |s3mult.mantissa[22:16] )
              s4.round[1] <= 1'b1;
            if( |s3mult.mantissa[15:0] )
              s4.round[0] <= 1'b1;
          end
        end
        else
        begin
          s4.round_amount <= 2'd1;
          if( s3mult.mantissa[22] )   
          begin
            if( s3mult.mantissa[23] )
              s4.round[1] <= 1'b1;
            if( |s3mult.mantissa[21:16] )
              s4.round[1] <= 1'b1;
            if( |s3mult.mantissa[15:0] )
              s4.round[0] <= 1'b1;
          end
        end
      end
    end
  end
  typedef struct packed
  {
    logic valid;
    logic sign;
    logic [7:0] exponent;   
    logic exponent_ge_254;  
    logic exponent_gt_254;  
    logic exponent_ge_0;  
    logic exponent_gt_0;  
    logic nan;
    logic [24:0] mantissa;  
  } stage5_regs;
  stage5_regs s5 ;
	logic stall_in_5, stall_out_5;
	logic valid_in_5, valid_out_5;
  assign valid_in_5 = valid_out_4;
  assign valid_out_5 = s5.valid;
  assign stall_out_5 = HIGH_CAPACITY ? (valid_out_5 & stall_in_5) : ~enable;
  assign stall_in_4 = stall_out_5;
  always @(posedge clock or negedge resetn)
  begin
    if (~resetn)
    begin
      s5 <= 'x;
      s5.valid <= 1'b0;
    end
    else if (~stall_out_5)
    begin
      s5.valid <= valid_in_5;
      s5.sign <= s4.sign;
      s5.exponent <= s4.exponent;
      s5.exponent_ge_254 <= s4.exponent_ge_254;
      s5.exponent_gt_254 <= s4.exponent_gt_254;
      s5.exponent_ge_0 <= s4.exponent_ge_0;
      s5.exponent_gt_0 <= s4.exponent_gt_0;
      s5.nan <= s4.nan;
      s5.mantissa <= s4.mantissa + (|s4.round ? s4.round_amount : '0);
    end
  end
  typedef struct packed
  {
    logic valid;
    logic sign;
    logic [7:0] exponent;
    logic [24:0] mantissa;  
  } stage6_regs;
  stage6_regs s6 ;
	logic stall_in_6, stall_out_6;
	logic valid_in_6, valid_out_6;
  assign valid_in_6 = valid_out_5;
  assign valid_out_6 = s6.valid;
  assign stall_out_6 = HIGH_CAPACITY ? (valid_out_6 & stall_in_6) : ~enable;
  assign stall_in_5 = stall_out_6;
  always @(posedge clock or negedge resetn)
  begin
    if (~resetn)
    begin
      s6 <= 'x;
      s6.valid <= 1'b0;
    end
    else if (~stall_out_6)
    begin
      s6.valid <= valid_in_6;
      s6.sign <= s5.sign;
      if( s5.nan )
      begin
        s6.exponent <= '1;
        s6.mantissa <= '1;
      end
      else
      begin
        if( s5.mantissa[24] )
        begin
          if( s5.exponent_ge_254 )
          begin
            s6.exponent <= '1;
            s6.mantissa <= '0;
          end
          else if( s5.exponent_ge_0 )
          begin
            s6.exponent <= s5.exponent + 8'd1;
            s6.mantissa <= s5.mantissa[24:1];
          end
          if( ~s5.exponent_ge_0 )
          begin
            s6.exponent <= '0;
            s6.mantissa <= '0;
          end
        end
        else
        begin
          if( s5.exponent_gt_254 )
          begin
            s6.exponent <= '1;
            s6.mantissa <= '0;
          end
          else if( s5.exponent_gt_0 )
          begin
            s6.exponent <= s5.exponent;
            s6.mantissa <= s5.mantissa[23:0];
          end
          if( ~s5.exponent_gt_0 )
          begin
            s6.exponent <= '0;
            s6.mantissa <= '0;
          end
        end
      end
    end
  end
  generate
  if( HIGH_CAPACITY )
  begin
    acl_staging_reg #(
      .WIDTH(32)
    )
    output_sr(
      .clk(clock),
      .reset(~resetn),
      .i_valid(s6.valid),
      .i_data({s6.sign, s6.exponent, s6.mantissa[22:0]}),
      .o_stall(stall_in_6),
      .o_valid(valid_out),
      .o_data(result),
      .i_stall(stall_in)
    );
  end
  else
  begin
    assign valid_out = s6.valid;
    assign result = {s6.sign, s6.exponent, s6.mantissa[22:0]};
    assign stall_in_6 = stall_in;
  end
  endgenerate
endmodule
module acl_fp_custom_mul_hc_core_mult(
  input logic clock,
  input logic resetn,
  input logic input_enable,
  input logic output_enable,
  input logic [23:0] dataa,
  input logic [23:0] datab,
  output logic [47:0] result
);
  logic [35:0] mult_a_result, mult_b_result, mult_c_result, mult_d_result;
  logic [71:0] mac_result;
  logic [35:0] dataa_ext, datab_ext;
  assign dataa_ext = {dataa, 12'd0};  
  assign datab_ext = {datab, 12'd0};  
  assign result = mac_result[71 -: 48];
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("false"),
    .signb_internally_grounded("false")
  ) 
  mac_mult_a(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[35:18]),
    .datab(datab_ext[35:18]),
    .dataout(mult_a_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("true"),
    .signb_internally_grounded("false")
  )
  mac_mult_b(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[17:0]),
    .datab(datab_ext[35:18]),
    .dataout(mult_b_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("false"),
    .signb_internally_grounded("true")
  )
  mac_mult_c(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[35:18]),
    .datab(datab_ext[17:0]),
    .dataout(mult_c_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_mult #(
    .dataa_width(18),
    .datab_width(18),
    .dataa_clock("0"),
    .datab_clock("0"),
    .dataa_clear("0"),
    .datab_clear("0"),
    .signa_internally_grounded("true"),
    .signb_internally_grounded("true")
  )
  mac_mult_d(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(dataa_ext[17:0]),
    .datab(datab_ext[17:0]),
    .dataout(mult_d_result),
    .clk({3'b000, clock}),
    .ena({3'b000, input_enable}),
    .aclr({3'b000, ~resetn})
  );
  stratixiv_mac_out #(
    .dataa_width(36),
    .datab_width(36),
    .datac_width(36),
    .datad_width(36),
    .first_adder0_clock("0"),
    .first_adder1_clock("0"),
    .first_adder0_clear("0"),
    .first_adder1_clear("0"),
    .output_clock("0"),
    .output_clear("0"),
    .operation_mode("36_bit_multiply")
  )
  mac_out(
    .signa(1'b0),
    .signb(1'b0),
    .dataa(mult_a_result),
    .datab(mult_b_result),
    .datac(mult_c_result),
    .datad(mult_d_result),
    .dataout(mac_result),
    .clk({3'b000, clock}),
    .ena({3'b000, output_enable}),
    .aclr({3'b000, ~resetn})
  );
endmodule
