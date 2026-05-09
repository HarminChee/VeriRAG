module apu_envelope_generator
(
  input  wire       clk_in,       
  input  wire       rst_in,       
  input  wire       eg_pulse_in,  
  input  wire [5:0] env_in,       
  input  wire       env_wr_in,    
  input  wire       env_restart,  
  output wire [3:0] env_out       
);
reg  [5:0] q_reg;
wire [5:0] d_reg;
reg  [3:0] q_cnt,        d_cnt;
reg        q_start_flag, d_start_flag;
always @(posedge clk_in)
  begin
    if (rst_in)
      begin
        q_reg        <= 6'h00;
        q_cnt        <= 4'h0;
        q_start_flag <= 1'b0;
      end
    else
      begin
        q_reg        <= d_reg;
        q_cnt        <= d_cnt;
        q_start_flag <= d_start_flag;
      end
  end
reg  divider_pulse_in;
reg  divider_reload;
wire divider_pulse_out;
apu_div #(.PERIOD_BITS(4)) divider(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .pulse_in(divider_pulse_in),
  .reload_in(divider_reload),
  .period_in(q_reg[3:0]),
  .pulse_out(divider_pulse_out)
);
always @*
  begin
    d_cnt        = q_cnt;
    d_start_flag = q_start_flag;
    divider_pulse_in = 1'b0;
    divider_reload   = 1'b0;
    if (divider_pulse_out)
      begin
        divider_reload = 1'b1;
        if (q_cnt != 4'h0)
          d_cnt = q_cnt - 4'h1;
        else if (q_reg[5])
          d_cnt = 4'hF;
      end
    if (eg_pulse_in)
      begin
        if (q_start_flag == 1'b0)
          begin
            divider_pulse_in = 1'b1;
          end
        else
          begin
            d_start_flag = 1'b0;
            d_cnt        = 4'hF;
          end
      end
    if (env_restart)
      d_start_flag = 1'b1;
  end
assign d_reg = (env_wr_in) ? env_in : q_reg;
assign env_out = (q_reg[4]) ? q_reg[3:0] : q_cnt;
endmodule
