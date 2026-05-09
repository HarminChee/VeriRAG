module system_controller_xilinx (
    input wire clk_sys_i,
    input wire rst_sys_i,
    output wire clk_i,
    output reg rst_i,
    output wire nrst_i
);
   wire xclk_buf;
   wire mmcm_clkout0;
   wire mmcm_clk_fb;
   wire CLKFBOUT;
   wire LOCKED;

   IBUF clk_ibuf (
      .I(clk_sys_i),
      .O(xclk_buf)
   );

   BUFG bufg_fb (
      .I(CLKFBOUT),
      .O(mmcm_clk_fb)
   );

   MMCME2_BASE #(
      .BANDWIDTH("OPTIMIZED"),
      .CLKFBOUT_MULT_F(6.0),
      .CLKFBOUT_PHASE(0.0),
      .CLKIN1_PERIOD(10.0),
      .CLKOUT0_DIVIDE_F(1.0),
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_DIVIDE(1),
      .CLKOUT2_DIVIDE(1),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT6_DUTY_CYCLE(0.5),
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
   ) MMCME2_BASE_inst (
      .CLKOUT0(mmcm_clkout0),
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
      .CLKFBIN(mmcm_clk_fb)
   );

   BUFGCE clk_buf (
      .CE(1'b1),
      .O(clk_i),
      .I(mmcm_clkout0)
   );

   reg [3:0] rst_count;
   assign nrst_i = ~rst_i;

   always @(posedge clk_i or posedge rst_sys_i)
     if (rst_sys_i) begin
        rst_i <= 1;
        rst_count <= 4'hF;
     end else if (~LOCKED) begin
        rst_i <= 1;
        rst_count <= 4'hF;
     end else begin
        if (LOCKED) begin
           if (rst_count != 0) begin
              rst_count <= rst_count - 1;
           end else begin
              rst_i <= 0;
           end
        end
     end

endmodule