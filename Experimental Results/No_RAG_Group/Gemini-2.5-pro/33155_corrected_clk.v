module system_controller_xilinx_corrected_clk (
                                 // Original Ports
                                 clk_sys_i, rst_sys_i,
                                 clk_i, rst_i, nrst_i,
                                 // DFT Ports
                                 scan_mode_i, scan_clk_i, scan_rst_i // Active high reset
                                 ) ;
   input wire clk_sys_i;
   input wire rst_sys_i;
   input wire scan_mode_i; // Test mode enable
   input wire scan_clk_i;  // Test clock input
   input wire scan_rst_i;  // Test reset input (active high)

   output wire clk_i;      // Clock output (muxed)
   output wire rst_i;      // Reset output (muxed, active high)
   output wire nrst_i;     // Inverted reset output

   // Internal signals
   wire        xclk_buf;
   wire        clk_mmcm_internal; // Internal wire from MMCM CLKOUT0
   wire        clk_mmcm_out; // Output from BUFGCE driven by MMCM
   wire        CLKFBOUT;
   wire        LOCKED;
   reg         rst_functional; // Functionally generated reset (active high)
   reg [3:0]   rst_count;

   // Input Buffer for system clock
   IBUF clk_ibuf(.I(clk_sys_i), .O(xclk_buf));

   // MMCM instantiation (held in reset during scan mode)
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
                 .CLKOUT0_DIVIDE_F(1.0), // Assuming CLKOUT0 drives clk_mmcm_out via BUFGCE
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
                     .CLKOUT0(clk_mmcm_internal), // Internal wire before BUFGCE
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
                     .PWRDWN(1'b0), // Consider controlling PWRDWN with scan_mode_i if needed
                     .RST(rst_sys_i | scan_mode_i), // Reset MMCM in system reset or scan mode
                     .CLKFBIN(clk_mmcm_out) // Feedback from the BUFGCE output
                     );

   // Clock Buffer for the functional clock
   BUFGCE clk_bug (
                   .CE(1'b1), // Assuming clock is always enabled when MMCM is running
                   .O(clk_mmcm_out), // Output is the functional clock
                   .I(clk_mmcm_internal) // Input from MMCM CLKOUT0
                   );

   // Functional Reset Generation Logic
   // Clocked by xclk_buf (derived from clk_sys_i).
   // Asynchronously reset by rst_sys_i.
   always @(posedge xclk_buf or posedge rst_sys_i)
     if (rst_sys_i) begin // System reset has priority
        rst_functional <= 1'b1;
        rst_count      <= 4'hF;
     end else begin
        // Use LOCKED signal from MMCM
        if (~LOCKED) begin // Keep reset asserted until MMCM locks
            rst_functional <= 1'b1;
            rst_count      <= 4'hF;
        end else begin // MMCM is locked
            if (rst_count != 4'h0) begin
                rst_functional <= 1'b1; // Keep reset asserted during countdown
                rst_count      <= rst_count - 1;
            end else begin
                rst_functional <= 1'b0; // Deassert functional reset
                rst_count      <= 4'h0; // Keep count at 0
            end
        end
     end

   // DFT MUX for Clock Output
   // Selects scan_clk_i in test mode, otherwise the functional clock from MMCM
   assign clk_i = scan_mode_i ? scan_clk_i : clk_mmcm_out;

   // DFT MUX for Reset Output
   // Selects scan_rst_i in test mode, otherwise the functional reset
   assign rst_i = scan_mode_i ? scan_rst_i : rst_functional;

   // Inverted Reset Output derived from the final muxed reset
   assign nrst_i = ~rst_i;

endmodule