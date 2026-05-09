module hdu(
  d_raddr1, d_raddr2, d_addrselector, d_jr_or_exec, d_immonly, e_isLoad, e_wreg, 
  pc_stall, ifid_stall
);
input [3:0] d_raddr1;
input [3:0] d_raddr2;
input d_addrselector;
input d_jr_or_exec;
input d_immonly;
input e_isLoad;
input e_wreg;
output pc_stall;
output ifid_stall; 
reg pc_stall_temp;
reg ifid_stall_temp;
reg [1:0] stallCount;
always @ (*)
begin
  stallCount = (e_isLoad===1'b1 && d_immonly!==1'b1 && (
(d_addrselector===1'b1 && d_jr_or_exec!==1'b1 && (d_raddr1===e_wreg || d_raddr2===e_wreg)) ||
(d_addrselector===1'b1 && d_jr_or_exec===1'b1 && (d_raddr2===e_wreg)) || 
(d_addrselector!==1'b1 && (d_raddr1===e_wreg || d_raddr2===e_wreg))
)) ? 2'b111 :  stallCount;
  if(stallCount>3'b00) begin
    pc_stall_temp = 1'b1;
    ifid_stall_temp = 1'b1;
    stallCount = stallCount-1'b1;
  end
  else begin
    pc_stall_temp = 1'b0;
    ifid_stall_temp = 1'b0;
  end  
end
assign pc_stall = pc_stall_temp;
assign ifid_stall = ifid_stall_temp;
endmodule
