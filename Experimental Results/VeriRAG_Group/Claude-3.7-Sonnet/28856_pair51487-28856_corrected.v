module pcie_compiler_0 (
   test_i, scan_clk,
   CLK_DIV_OUT, DATA_IN_TO_DEVICE,
   CLK_IN_P, CLK_IN_N, CLK_RESET, IO_RESET, DATA_IN_FROM_PINS_P,
   DATA_IN_FROM_PINS_N, BITSLIP
   );

   input       CLK_IN_P, scan_clk, test_i;
   input       CLK_IN_N;
   input       CLK_RESET; 
   input       IO_RESET;
   input [8:0] DATA_IN_FROM_PINS_P;
   input [8:0] DATA_IN_FROM_PINS_N;
   input       BITSLIP;
   output      CLK_DIV_OUT;
   output [71:0] DATA_IN_TO_DEVICE;

   // ... existing code ...

   wire dft_clk;
   assign dft_clk = test_i ? scan_clk : refclk;

   altpcie_pll_100_250 refclk_to_250mhz
     (
      .areset (1'b0),
      .c0 (clk250_out),
      .inclk0 (dft_clk)
     );

   altpcie_pll_125_250 pll_250mhz_to_500mhz
     (
      .areset (1'b0), 
      .c0 (clk500_out),
      .inclk0 (dft_clk)
     );

   // ... existing code ...

   always @(posedge dft_clk or posedge reset)
     if(reset)
       clk_cnt[1:0] <= 2'b00;
     else if(rx_pedge_first)  
       clk_cnt[1:0] <= 2'b11;
     else
       clk_cnt[1:0] <= clk_cnt[1:0] + 2'b01;

   // ... existing code ...

   pcie_compiler_0_serdes serdes
     (
      .cal_blk_clk (test_i ? scan_clk : cal_blk_clk),
      .fixedclk (test_i ? scan_clk : fixedclk_serdes),
      // ... existing ports ...
     );

   // ... rest of existing code ...

endmodule