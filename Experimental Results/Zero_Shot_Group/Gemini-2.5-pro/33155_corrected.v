module system_controller_xilinx (
    // Inputs
    input wire clk_sys_i,
    input wire rst_sys_i,
    // Outputs
    output wire clk_i,
    output reg  rst_i,
    output wire nrst_i
);

   wire        xclk_buf;
   wire        CLKFBOUT;
   wire        LOCKED; // Added declaration for LOCKED signal

   IBUF clk_ibuf(.I(clk_sys_i), .O(xclk_buf));

   // Note: The feedback path uses clk_i (output of BUFGCE) fed back to CLKFBIN.
   // The BUFGCE input is driven by CLKFBOUT. This configuration compensates
   // for the BUFGCE delay in the feedback path.
   // Ensure MMCM parameters (MULT/DIVIDE) are set correctly for the desired clk_i frequency.

   MMCME2_BASE #(
                 .BANDWIDTH("OPTIMIZED"),
                 .CLKFBOUT_MULT_F(6.0),      // Multiply factor for CLKFBOUT
                 .CLKFBOUT_PHASE(0.0),
                 .CLKIN1_PERIOD(10.0),       // Input clock period (example: 10ns = 100MHz)
                 // CLKOUT0 settings (currently unused, but defined)
                 .CLKOUT0_DIVIDE_F(6.0),     // Divide factor for CLKOUT0 (e.g., 6.0 to match input freq if CLKFBOUT_MULT_F=6.0)
                 .CLKOUT0_DUTY_CYCLE(0.5),
                 .CLKOUT0_PHASE(0.0),
                 // Other CLKOUT dividers (unused)
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
                 .DIVCLK_DIVIDE(1),          // Master division factor
                 .REF_JITTER1(0.0),
                 .STARTUP_WAIT("FALSE")      // Recommended "FALSE" for simulations
                 )
   MMCME2_BASE_inst (
                     // Unused Clock Outputs
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
                     // Feedback Clock Output (to BUFGCE)
                     .CLKFBOUT(CLKFBOUT),
                     .CLKFBOUTB(),
                     // Status
                     .LOCKED(LOCKED),
                     // Clock Input
                     .CLKIN1(xclk_buf),
                     // Control Ports
                     .PWRDWN(1'b0),
                     .RST(rst_sys_i), // Use system reset for MMCM reset
                     // Feedback Clock Input (from BUFGCE output)
                     .CLKFBIN(clk_i)
                     );

   // Global Clock Buffer for the main output clock
   BUFGCE clk_bufg ( // Renamed instance from clk_bug
                   .CE(LOCKED), // Enable BUFGCE only when MMCM is locked
                   .O(clk_i),
                   .I(CLKFBOUT) // Input is the direct feedback output from MMCM
                   );

   // Reset Generation Logic
   reg [3:0]  rst_count;
   assign nrst_i = ~rst_i;

   // Reset logic synchronized to the output clock clk_i
   always @(posedge clk_i or posedge rst_sys_i) begin // Changed clock source, added async reset edge
     if (rst_sys_i) begin // Asynchronous reset using system reset
        rst_i <= 1'b1;
        rst_count <= 4'hF;
     end else begin // Synchronous logic clocked by clk_i
        if (~LOCKED) begin // Hold reset if MMCM loses lock
           rst_i <= 1'b1;
           rst_count <= 4'hF;
        end else begin // MMCM is LOCKED, proceed with reset deassertion sequence
           if (rst_count != 4'h0) begin
              rst_i <= 1'b1; // Keep reset asserted while counting down
              rst_count <= rst_count - 1'b1;
           end else begin
              rst_i <= 1'b0; // Deassert reset after countdown
              rst_count <= 4'h0; // Keep counter at 0
           end
        end
     end
   end

endmodule