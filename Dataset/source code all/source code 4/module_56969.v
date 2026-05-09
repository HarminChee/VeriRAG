module generic_output #(
  parameter OW  = 1,    
  parameter DS  = 1'b0, 
  parameter DBG = 0     
)(
  output wire [ OW-1:0] i
);
reg  [ OW-1:0] state_old = {OW{DS}};
always @ (i) begin
  if (i != state_old) begin
  if (DBG) $display ("BENCH : %M : %t : changing state from [%b] to [%b].", $time, state_old, i);
  state_old = #1 i;
  end
end
task read;
output [ OW-1:0] data;
begin
  data = state_old;
end
endtask
endmodule
