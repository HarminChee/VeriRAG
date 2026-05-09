module system_controller_xilinx (
                                 clk_i, rst_i, nrst_i,
                                 clk_sys_i, rst_sys_i,
                                 test_i, scan_clk_i
                                 ) ;
   input wire clk_sys_i;
   input wire rst_sys_i;
   input wire test_i;
   input wire scan_clk_i;
   output wire clk_i;
   output reg  rst_i;
   output wire nrst_i;
   wire        xclk_buf;
   wire        dft_clk;
   assign dft_clk = test_i ? scan_clk_i : xclk_buf;
   IBUF clk_ibuf(.I(clk_sys_i), .O(xclk_buf));
   wire        CLKFBOUT;   
   BUFGCE clk_bug (
                   .CE(1'b1),
                   .O(clk_i), 
                   .I(CLKFBOUT) 
                   );
   MMCME2_BASE #(
                 .BANDWIDTH("OPTIMIZED"),
                 .CLKFBOUT_MULT_F(6.0),
                 .CLKFBOUT_PHASE(0.0),
                 .CLKIN1_PERIOD(10.0),
                 .CLKOUT1_DIVIDE(1),
                 .CLKOUT2_DIVIDE(1),
                 .CLKOUT3_DIVIDE(1),
                 .CLKOUT4_DIVIDE(1),
                 .CLKOUT5_DIVIDE(1),
                 .CLKOUT6_DIVIDE(1),
                 .CLKOUT0_DIVIDE_F(1.0),
                 .CLKOUT0_DUTY_CYCLE(0.5),
                 .CLKOUT1_DUTY_CYCLE(0.5),
                 .CLKOUT2_DUTY_CYCLE(0.5),
                 .CLKOUT3_DUTY_CYCLE(0.5),
                 .CLKOUT4_DUTY_CYCLE(0.5),
                 .CLKOUT5_DUTY_CYCLE(0.5),
                 .CLKOUT6_DUTY_CYCLE(0.5),
                 .CLKOUT0_PHASE(0.0),
                 .CLKOUT1_PHASE(0.0),
                 .CLKOUT2_PHASE(0.0),
                 .CLKOUT3_PHASE(0.0),
                 .CLKOUT4_PHASE(0.0),
                 .CLKOUT5_PHASE(0.0),
                 .CLKOUT6_PHASE(0.0),
                 .CLKOUT4_CASCADE("FALSE"), 
                 .DIVCLK_DIVIDE(1),
                 .REF_JITTER1(0.0),
                 .STARTUP_WAIT("FALSE")
                 )
   MMCME2_BASE_inst (
                     .CLKOUT0(),
                     .CLKOUT0B(),
                     .CLKOUT1(),
                     .CLKOUT1B(),
                     .CLKOUT2(),
                     .CLKOUT2B(),
                     .CLKOUT3(),
                     .CLKOUT3B(),
                     .CLKOUT4(),
                     .CLKOUT5(),
                     .CLKOUT6(),
                     .CLKFBOUT(CLKFBOUT),
                     .CLKFBOUTB(), 
                     .LOCKED(LOCKED),
                     .CLKIN1(xclk_buf),
                     .PWRDWN(1'b0),
                     .RST(rst_sys_i),
                     .CLKFBIN(clk_i)
                     );
   reg [3:0]  rst_count;   
   assign nrst_i = ~rst_i;
   always @(posedge dft_clk)
     if (rst_sys_i | ~LOCKED) begin
        rst_i <= 1;       
        rst_count <= 4'hF;        
     end else begin
        if (LOCKED) begin
           if (rst_count) begin
              rst_count <= rst_count - 1;              
           end else begin
              rst_i <= 0;              
           end           
        end        
     end 
endmodule