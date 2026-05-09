module system_controller_xilinx (
                                 clk_i, rst_i, nrst_i,
                                 clk_sys_i, rst_sys_i
                                 );
   input wire clk_sys_i;
   input wire rst_sys_i;
   output wire clk_i;
   output reg  rst_i;
   output wire nrst_i;
   
   wire xclk_buf;
   wire LOCKED;
   wire CLKFBOUT;
   
   IBUF clk_ibuf(
      .I(clk_sys_i),
      .O(xclk_buf)
   );
   
   BUFG clk_buf (
      .I(CLKFBOUT),
      .O(clk_i)
   );

   MMCM_BASE #(
      .BANDWIDTH("OPTIMIZED"),
      .CLKFBOUT_MULT_F(6.000),
      .CLKFBOUT_PHASE(0.000),
      .CLKIN1_PERIOD(10.000),
      .CLKOUT0_DIVIDE_F(1.000),
      .CLKOUT0_DUTY_CYCLE(0.500),
      .CLKOUT0_PHASE(0.000),
      .CLKOUT1_DIVIDE(1),
      .CLKOUT1_DUTY_CYCLE(0.500),
      .CLKOUT1_PHASE(0.000),
      .CLKOUT2_DIVIDE(1),
      .CLKOUT2_DUTY_CYCLE(0.500), 
      .CLKOUT2_PHASE(0.000),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT3_DUTY_CYCLE(0.500),
      .CLKOUT3_PHASE(0.000),
      .CLKOUT4_CASCADE("FALSE"),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT4_DUTY_CYCLE(0.500),
      .CLKOUT4_PHASE(0.000),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT5_DUTY_CYCLE(0.500),
      .CLKOUT5_PHASE(0.000),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT6_DUTY_CYCLE(0.500),
      .CLKOUT6_PHASE(0.000),
      .DIVCLK_DIVIDE(1),
      .REF_JITTER1(0.010),
      .STARTUP_WAIT("FALSE")
   ) MMCM_BASE_inst (
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

   reg [3:0] rst_count;
   
   assign nrst_i = ~rst_i;
   
   always @(posedge clk_i or posedge rst_sys_i)
     if (rst_sys_i | ~LOCKED) begin
        rst_i <= 1'b1;
        rst_count <= 4'hF;
     end
     else begin
        if (rst_count) begin
           rst_count <= rst_count - 4'b1;
        end
        else begin
           rst_i <= 1'b0;
        end
     end

endmodule