module   i_m_areg(
                   clk,
                   rst,
                   i_flits_m,
                   v_i_flits_m,
                   mem_done_access,
                   i_m_areg_flits,
                   v_i_areg_m_flits
                   );
input                   clk;
input                   rst;
input      [47:0]       i_flits_m;
input                   v_i_flits_m;
input                   mem_done_access;
output     [47:0]    i_m_areg_flits;
output               v_i_areg_m_flits;
reg      i_m_cstate;
reg      [47:0]   flits_reg;
always@(posedge clk)
begin
  if(rst||mem_done_access)
    flits_reg<=48'h0000;
else if(v_i_flits_m)
    flits_reg<=i_flits_m;
end
always@(posedge clk)
begin
  if(rst||mem_done_access)
    i_m_cstate<=1'b0;
  else if(v_i_flits_m)
    i_m_cstate<=1'b1;
end
assign v_i_areg_m_flits=i_m_cstate;
assign i_m_areg_flits=flits_reg;
endmodule
