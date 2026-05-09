module amiga_clk_xilinx (
  input  wire areset,
  input  wire inclk0,
  output wire c0,
  output wire c1,
  output wire c2,
  output wire locked
);
wire pll_114;
wire dll_114;
wire dll_28;
reg [1:0] clk_7 = 0;
DCM #(
  .CLKDV_DIVIDE(2.0), 
  .CLKFX_DIVIDE(17),   
  .CLKFX_MULTIPLY(29), 
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
  .CLKIN(inclk0),   
  .CLKFX(pll_114)   
);
DCM #(
  .CLKDV_DIVIDE(4.0), 
  .CLKFX_DIVIDE(1),   
  .CLKFX_MULTIPLY(4), 
  .CLKIN_DIVIDE_BY_2("FALSE"), 
  .CLKIN_PERIOD(8.802),  
  .CLKOUT_PHASE_SHIFT("FIXED"), 
  .CLK_FEEDBACK("1X"),  
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
  .DFS_FREQUENCY_MODE("LOW"),  
  .DLL_FREQUENCY_MODE("LOW"),  
  .DUTY_CYCLE_CORRECTION("TRUE"), 
  .FACTORY_JF(16'h8080),   
  .PHASE_SHIFT(104),     
  .STARTUP_WAIT("TRUE")   
) dll (
  .RST(areset),
  .CLKIN(pll_114),   
  .CLK0(dll_114),
  .CLKDV(dll_28),
  .CLKFB(c0),
  .LOCKED(locked)
);
always @ (posedge c1) begin
  clk_7 <= #1 clk_7 + 2'd1;
end
BUFG  BUFG_SDR (.I(pll_114),  .O(c2));
BUFG  BUFG_114 (.I(dll_114),  .O(c0));
BUFG  BUFG_28  (.I(dll_28),   .O(c1));
endmodule
