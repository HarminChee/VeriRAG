`ifndef FFD
  `define FFD 1
`endif
`ifndef FFD
  `define FFD 1
`endif
module cmm_errman_cnt_en (
                count,                  
                index,                  
                inc_dec_b,
                enable,
                rst,
                clk
                );
  output  [3:0] count;
  input   [2:0] index;       
  input         inc_dec_b;   
  input         enable;      
  input         rst;
  input         clk;
  parameter FFD       = 1;        
  reg     [3:0] reg_cnt;
  reg           reg_extra;
  reg           reg_inc_dec_b;
  reg           reg_uflow;
  reg     [3:0] cnt;
  wire          oflow;
  wire          uflow;
  always @(posedge clk or posedge rst) begin
    if (rst)              {reg_extra, reg_cnt} <= #`FFD 5'b00000;
    else if (~enable)     {reg_extra, reg_cnt} <= #`FFD 5'b00000;
    else if (inc_dec_b)   {reg_extra, reg_cnt} <= #`FFD cnt + index;
    else                  {reg_extra, reg_cnt} <= #`FFD cnt - index;
  end
  always @(oflow or uflow or reg_cnt) begin  
    case ({oflow,uflow})    
      2'b11: cnt = 4'hF;
      2'b10: cnt = 4'hF;
      2'b01: cnt = 4'h0;
      2'b00: cnt = reg_cnt;
    endcase
  end
  always @(posedge clk or posedge rst) begin
    if (rst)  reg_inc_dec_b <= #`FFD 1'b0;
    else      reg_inc_dec_b <= #`FFD inc_dec_b;
  end
  assign oflow = reg_extra & reg_inc_dec_b;
  always @(posedge clk or posedge rst) begin
    if (rst)
      reg_uflow <= #`FFD 1'b0;
    else
      reg_uflow <= #`FFD ~|count & |index[2:0] & ~inc_dec_b;
  end
  assign uflow = reg_uflow;
  reg     [3:0] reg_count;
  always @(posedge clk or posedge rst) begin
    if (rst)            reg_count <= #`FFD 4'b0000;
    else if (~enable)   reg_count <= #`FFD 4'b0000;
    else if (oflow)     reg_count <= #`FFD 4'b1111;
    else if (uflow)     reg_count <= #`FFD 4'b0000;
    else                reg_count <= #`FFD cnt;
  end
  assign count = reg_count;
endmodule
