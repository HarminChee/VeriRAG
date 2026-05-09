module  omsp_clock_mux (
    clk_out,                   
    clk_in0,                   
    clk_in1,                   
    reset,                     
    scan_mode,                 
    select_in                  
);
output         clk_out;        
input          clk_in0;        
input          clk_in1;        
input          reset;          
input          scan_mode;      
input          select_in;      
wire in0_select;
reg  in0_select_s;
reg  in0_select_ss;
wire in0_enable;
wire in1_select;
reg  in1_select_s;
reg  in1_select_ss;
wire in1_enable;
wire clk_in0_inv;
wire clk_in1_inv;
wire clk_in0_scan_fix_inv;
wire clk_in1_scan_fix_inv;
wire gated_clk_in0;
wire gated_clk_in1;
`ifdef SCAN_REPAIR_INV_CLOCKS
   omsp_scan_mux scan_mux_repair_clk_in0_inv (.scan_mode(scan_mode), .data_in_scan(clk_in0), .data_in_func(~clk_in0), .data_out(clk_in0_scan_fix_inv));
   omsp_scan_mux scan_mux_repair_clk_in1_inv (.scan_mode(scan_mode), .data_in_scan(clk_in1), .data_in_func(~clk_in1), .data_out(clk_in1_scan_fix_inv));
`else
   assign clk_in0_scan_fix_inv = ~clk_in0;
   assign clk_in1_scan_fix_inv = ~clk_in1;
`endif
assign in0_select = ~select_in & ~in1_select_ss;
always @ (posedge clk_in0_scan_fix_inv or posedge reset)
  if (reset) in0_select_s  <=  1'b1;
  else       in0_select_s  <=  in0_select;
always @ (posedge clk_in0              or posedge reset)
  if (reset) in0_select_ss <=  1'b1;
  else       in0_select_ss <=  in0_select_s;
assign in0_enable = in0_select_ss | scan_mode;
assign in1_select =  select_in & ~in0_select_ss;
always @ (posedge clk_in1_scan_fix_inv or posedge reset)
  if (reset) in1_select_s  <=  1'b0;
  else       in1_select_s  <=  in1_select;
always @ (posedge clk_in1     or posedge reset)
  if (reset) in1_select_ss <=  1'b0;
  else       in1_select_ss <=  in1_select_s;
assign in1_enable = in1_select_ss & ~scan_mode;
assign clk_in0_inv   = ~clk_in0;
assign clk_in1_inv   = ~clk_in1;
assign gated_clk_in0 = ~(clk_in0_inv & in0_enable);
assign gated_clk_in1 = ~(clk_in1_inv & in1_enable);
assign clk_out       =  (gated_clk_in0 & gated_clk_in1);
endmodule 
