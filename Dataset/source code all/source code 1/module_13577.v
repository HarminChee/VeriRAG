module xlr8_fdiv
  #(parameter DENOM_W = 32,
    parameter NUMER_W = 32,
    parameter EXP_W   = 8,
    parameter FRAC_W =  23,
    parameter QUOTI_W = 32,
    parameter REMAI_W = DENOM_W)
  (input logic clk,
   input logic                rst_n,
   input logic                clken,
   input logic [DENOM_W-1:0]  denom,
   input logic [NUMER_W-1:0]  numer,
   input logic                start, 
   output logic [QUOTI_W-1:0] q_out
   );
   localparam MANT_W = FRAC_W+1;
   localparam QUO_W = MANT_W+3;
   localparam CNT_W = $clog2(MANT_W+1);
   localparam SUB_W = 28; 
  logic                       sign;
  logic [EXP_W-1:0]           exp_q;
  logic [EXP_W-1:0]           temp_exp;
  logic [EXP_W-1:0]           exp_numer;
  logic [EXP_W-1:0]           exp_denom;
  logic [FRAC_W-1:0]          frac_numer;
  logic [FRAC_W-1:0]          frac_denom;
  logic [MANT_W-1:0]          mant_numer;
  logic [MANT_W-1:0]          mant_denom;
  logic [MANT_W-1:0]          mant_q;
  logic                     exp_numer_0;
  logic                     exp_denom_0;
  logic                     exp_numer_255;
  logic                     exp_denom_255;
  logic                     frac_numer_0;
  logic                     frac_denom_0;
  logic                     numer_nan;
  logic                     denom_nan;
  logic                     numer_inf;
  logic                     denom_inf;
  logic                     numer_0;
  logic                     denom_0;
  logic [CNT_W-1:0]         cnt;
  logic [CNT_W-1:0]         cnt_nxt;
  logic [MANT_W:0]          q_rnd;
   logic [QUO_W:0]          quotient;
   logic [QUO_W:0]          quotient_nxt;
   logic                    bsy;
  logic [MANT_W-1:0]        divisor, divisor_nxt;
  logic [MANT_W:0]          dividend, dividend_nxt, dividend_mux;
  logic                     quotient_val;       
  logic [QUO_W:0] q_adjst;
  logic [EXP_W-1:0] exp_adjst;
  assign exp_numer = numer[23 +: EXP_W];
  assign exp_denom = denom[23 +: EXP_W];
  assign frac_numer = numer[FRAC_W-1:0];
  assign frac_denom = denom[FRAC_W-1:0];
  assign mant_numer = {1'b1,numer[FRAC_W-1:0]};
  assign mant_denom = {1'b1,denom[FRAC_W-1:0]};
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      sign <= 1'b0;
      temp_exp <= 8'h0;
    end
    else begin
      sign <= numer[31]^denom[31]; 
      temp_exp <= exp_numer - exp_denom + 'd127; 
    end
  always_comb begin
    exp_numer_0 = exp_numer == 0;
    exp_denom_0 = exp_denom == 0;
    exp_numer_255 = exp_numer == 8'hff;
    exp_denom_255 = exp_denom == 8'hff;
    frac_numer_0 = frac_numer == 0;
    frac_denom_0 = frac_denom == 0;
    numer_nan = (exp_numer_255) && !frac_numer_0;
    denom_nan = (exp_denom_255) && !frac_denom_0;
    numer_inf = (exp_numer_255) && frac_numer_0;
    denom_inf = (exp_denom_255) && frac_denom_0;
    numer_0 = exp_numer_0;
    denom_0 = exp_denom_0;
  end
  always_comb begin
    if (numer_nan || denom_nan || (numer_0 && denom_0) || (numer_inf && denom_inf)) begin
      q_out = 32'h7fffffff;
    end
    else if (numer_inf || denom_0) begin
      q_out = {sign,8'hff,23'h0};
    end
         else if (numer_0 || denom_inf) begin
           q_out = {sign,31'h0};
         end
              else begin
                q_out = {sign,exp_adjst,q_rnd[FRAC_W-1:0]};
              end
  end 
   logic [23:0] rslt;
   logic        brw;      
  always_comb begin: calc_nxt
    {brw,rslt} = dividend - divisor;
     dividend_mux = brw ? dividend : rslt;
     dividend_nxt = dividend_mux << 1;
     quotient_nxt = (brw) ? {quotient[26:0],1'b0} : {quotient[26:0],1'b1};
     divisor_nxt = divisor;
    cnt_nxt = cnt - 'd1;
    bsy = |cnt;
  end
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      cnt <= {CNT_W{1'b0}};
      dividend <= {25{1'b0}};
      divisor <= {MANT_W{1'b0}};
      quotient <= {QUO_W{1'b0}};
    end
    else begin
      if (clken) begin
         cnt <= start && !bsy ? SUB_W :
                   bsy ? cnt_nxt : cnt;
         divisor <= start && !bsy ? mant_denom :
                       bsy ? divisor_nxt :
                       divisor;
        dividend <= start && !bsy ? {1'b0, mant_numer} :
                        bsy ? dividend_nxt :
                        dividend;
        quotient <= start && !bsy ? '0 :
                        bsy ? quotient_nxt :
                        quotient;
      end
    end 
  logic stcky, g, r;
  logic [25:0] q_inc_g;
  always_comb begin
    if (quotient >= 28'h8000000) begin
      exp_adjst = temp_exp ;
      q_adjst = quotient >>1;
    end
    else begin
      q_adjst = quotient;
      exp_adjst = temp_exp-1;
    end 
  end 
  always_comb begin
    stcky = q_adjst[0] || |dividend;
    g = q_adjst[2];
    r = q_adjst[1];
    q_inc_g = q_adjst[27:2] +1;
    q_rnd[0] = g&&!r&&!stcky ? 1'b0 : q_inc_g[1];
    q_rnd[24:1] = q_inc_g[25:2];
  end
  always_ff @(posedge clk) begin
    quotient_val <= bsy && (~|cnt_nxt);
  end
endmodule 
