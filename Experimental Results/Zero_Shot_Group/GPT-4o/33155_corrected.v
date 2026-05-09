module system_controller_xilinx (
                                 clk_i, rst_i, nrst_i,
                                 clk_sys_i, rst_sys_i
                                 ) ;
   input wire clk_sys_i;
   input wire rst_sys_i;
   output wire clk_i;
   output reg  rst_i;
   output wire nrst_i;
   wire        xclk_buf;
   wire        CLKFBOUT;
   wire        LOCKED;

   IBUF clk_ibuf(.I(clk_sys_i), .O(xclk_buf));

   BUFGCE clk_buf (
                   .CE(1'b1),
                   .O(clk_i), 
                   .I(CLKFBOUT) 
                   );

   MMCME2_BASE #(
                 .BANDWIDTH("OPTIMIZED"),
                 .CLKFBOUT_MULT_F(6.0),
                 .CLKFBOUT_PHASE(0.0),
                 .CLKIN1_PERIOD(10.0),
                 .CLKOUT0_DIVIDE_F(1.0),
                 .CLKOUT0_DUTY_CYCLE(0.5),
                 .CLKOUT0_PHASE(0.0),
                 .DIVCLK_DIVIDE(1),
                 .REF_JITTER1(0.0),
                 .STARTUP_WAIT("FALSE")
                 )
   MMCME2_BASE_inst (
                     .CLKOUT0(),
                     .CLKFBOUT(CLKFBOUT),
                     .LOCKED(LOCKED),
                     .CLKIN1(xclk_buf),
                     .PWRDWN(1'b0),
                     .RST(rst_sys_i),
                     .CLKFBIN(clk_i)
                     );

   reg [3:0]  rst_count;   
   assign nrst_i = ~rst_i;

   always @(posedge xclk_buf) begin
     if (rst_sys_i | ~LOCKED) begin
        rst_i <= 1;       
        rst_count <= 4'hF;        
     end else begin
        if (LOCKED) begin
           if (rst_count != 4'h0) begin
              rst_count <= rst_count - 1;              
           end else begin
              rst_i <= 0;              
           end           
        end        
     end 
   end 
endmodule