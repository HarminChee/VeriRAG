module ctrl_clk_xilinx (
  input  wire inclk0,
  input  wire test_i,
  input  wire scan_clk,
  output wire c0,
  output wire c1,
  output wire c2,
  output wire locked
);
wire pll_50;
wire dll_50;
wire dll_100;
reg  clk_25 = 0;
wire dft_clk;
assign dft_clk = test_i ? scan_clk : inclk0;

DCM #(
  .CLKDV_DIVIDE(2.0), 
  .CLKFX_DIVIDE(32),   
  .CLKFX_MULTIPLY(24), 
  .CLKIN_DIVIDE_BY_2("FALSE"), 
  .CLKIN_PERIOD(15.015),  
  .CLKOUT_PHASE_SHIFT("NONE"), 
  .CLK_FEEDBACK("NONE"),  
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
  .DFS_FREQUENCY_MODE("LOW"),  
  .DLL_FREQUENCY_MODE("LOW"),  
  .DUTY_CYCLE_CORRECTION("TRUE"), 
  .FACTORY_JF(16'h8080),   
  .PHASE_SHIFT(0),     
  .STARTUP_WAIT("TRUE")   
) pll (
  .CLKIN(dft_clk),   
  .CLKFX(pll_50)   
);
DCM #(
  .CLKDV_DIVIDE(2.0), 
  .CLKFX_DIVIDE(1),   
  .CLKFX_MULTIPLY(4), 
  .CLKIN_DIVIDE_BY_2("FALSE"), 
  .CLKIN_PERIOD(20.020),  
  .CLKOUT_PHASE_SHIFT("NONE"), 
  .CLK_FEEDBACK("1X"),  
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
  .DFS_FREQUENCY_MODE("LOW"),  
  .DLL_FREQUENCY_MODE("LOW"),  
  .DUTY_CYCLE_CORRECTION("TRUE"), 
  .FACTORY_JF(16'h8080),   
  .PHASE_SHIFT(0),     
  .STARTUP_WAIT("TRUE")   
) dll (
  .CLKIN(pll_50),   
  .CLK0(dll_50),
  .CLK2X(dll_100),
  .CLKFB(c1),
  .LOCKED(locked)
);
always @ (posedge c0) begin
  clk_25 <= #1 ~clk_25;
end
BUFG  BUFG_100 (.I(dll_100), .O(c0));
BUFG  BUFG_50  (.I(dll_50),  .O(c1));
BUFG  BUFG_25  (.I(clk_25),  .O(c2));
endmodule