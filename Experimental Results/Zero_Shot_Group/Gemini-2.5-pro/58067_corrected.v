module pcie_clocking #
( parameter    G_DIVIDE_VAL = 2,
  parameter    REF_CLK_FREQ = 1
)
(
  input  clkin_pll,
  input  clkin_dcm, // Unused input - potential cleanup candidate, but kept as per original structure
  input  rst,
  output coreclk,
  output userclk,
  output gtx_usrclk,
  output txsync_clk,
  output locked,
  input  fast_train_simulation_only
 );
  wire clkfbout;
  wire clkfbin;
  wire clkout0;
  wire clkout1;
  wire clkout2;
  wire txsync_clkout;
  wire clk0; // Unused wire - potential cleanup candidate
  wire clkfb; // Unused wire - potential cleanup candidate
  wire clkdv; // Unused wire - potential cleanup candidate
  wire pll_lk_out; // Added declaration for PLL lock output
  wire [15:0] not_connected; // Unused wire - potential cleanup candidate

  reg  [7:0]  lock_wait_cntr_7_0;
  reg  [7:0]  lock_wait_cntr_15_8;
  reg         pll_locked_out_r;
  reg         pll_locked_out_r_d;
  reg         pll_locked_out_r_2d;
  reg         time_elapsed;

  // Corrected parameter name typo: G_DVIDED_VAL_PLL -> G_DIVIDED_VAL_PLL
  parameter G_DIVIDED_VAL_PLL = G_DIVIDE_VAL*2;

   generate
       begin : use_pll
          PLL_ADV #
          (
            .CLKFBOUT_MULT (5-(REF_CLK_FREQ*3)), // Note: Formula might need review based on actual requirements/target device
            .CLKFBOUT_PHASE(0),
            .CLKIN1_PERIOD (10-(REF_CLK_FREQ*6)), // Note: Formula might need review based on actual requirements/target device
            .CLKIN2_PERIOD (10-(REF_CLK_FREQ*6)), // Note: CLKIN2 not used based on CLKINSEL=1'b1
            .CLKOUT0_DIVIDE(2),
            .CLKOUT0_PHASE (0),
            // Corrected usage of parameter name
            .CLKOUT1_DIVIDE(G_DIVIDED_VAL_PLL),
            .CLKOUT1_PHASE (0),
            .CLKOUT2_DIVIDE (4),
            .CLKOUT2_PHASE (0),
            .CLKOUT3_DIVIDE (4),
            .CLKOUT3_PHASE (0),
            // Added other potentially required parameters with default-like values if needed (check PLL_ADV documentation)
            .CLKOUT4_DIVIDE(1),
            .CLKOUT5_DIVIDE(1),
            .CLKOUT4_PHASE(0.0),
            .CLKOUT5_PHASE(0.0),
            .CLKOUT0_DUTY_CYCLE(0.5),
            .CLKOUT1_DUTY_CYCLE(0.5),
            .CLKOUT2_DUTY_CYCLE(0.5),
            .CLKOUT3_DUTY_CYCLE(0.5),
            .CLKOUT4_DUTY_CYCLE(0.5),
            .CLKOUT5_DUTY_CYCLE(0.5),
            .CLKFBOUT_DUTY_CYCLE(0.5),
            .COMPENSATION("INTERNAL"), // Or other appropriate value
            .DIVCLK_DIVIDE(1), // Or other appropriate value
            .REF_JITTER(0.1), // Or other appropriate value
            .SIM_DEVICE("VIRTEX5") // Or appropriate target device family
          )
          pll_adv_i
          (
            .CLKIN1(clkin_pll),
            .CLKIN2(1'b0), // Tied off as CLKINSEL selects CLKIN1
            .CLKINSEL(1'b1),
            .CLKFBIN(clkfbin),
            .RST(rst),
            .PWRDWN(1'b0), // Typically tied low unless power down is needed
            .CLKOUT0(clkout0),
            .CLKOUT1(clkout1),
            .CLKOUT2(clkout2),
            .CLKOUT3(txsync_clkout),
            .CLKOUT4(), // Unconnected output
            .CLKOUT5(), // Unconnected output
            .CLKFBOUT(clkfbout),
            .CLKFBDCM(), // Unconnected output
            .LOCKED(pll_lk_out),
            .DO(), // Unconnected DRP output
            .DRDY(), // Unconnected DRP output
            .DADDR(5'b0), // Unconnected DRP input
            .DCLK(1'b0), // Unconnected DRP input
            .DEN(1'b0), // Unconnected DRP input
            .DI(16'b0), // Unconnected DRP input
            .DWE(1'b0) // Unconnected DRP input
          );

          assign clkfbin = clkfbout;

          BUFG coreclk_pll_bufg  (.O(coreclk),    .I(clkout0));
          BUFG gtxclk_pll_bufg   (.O(gtx_usrclk), .I(clkout2));
          BUFG txsync_clk_pll_bufg   (.O(txsync_clk), .I(txsync_clkout));

      // Lock wait counter logic
      if (REF_CLK_FREQ == 1) // Assuming REF_CLK_FREQ=1 means 100MHz
      begin : lock_wait_100mhz
          always @(posedge clkin_pll or posedge rst)
          begin
             if(rst)
             begin
                lock_wait_cntr_7_0  <= 8'h0;
                lock_wait_cntr_15_8 <= 8'h0;
                pll_locked_out_r  <= 1'b0;
                time_elapsed      <= 1'b0;
             end else begin
                // Wait ~32k cycles (e.g., ~320us @ 100MHz) before checking lock
                if ((lock_wait_cntr_15_8 == 8'h80) || time_elapsed)
                begin
                   pll_locked_out_r <= pll_lk_out;
                   time_elapsed     <= 1'b1;
                end else begin
                   lock_wait_cntr_7_0  <= lock_wait_cntr_7_0 + 1'b1;
                   if (lock_wait_cntr_7_0 == 8'hff) begin
                       lock_wait_cntr_15_8 <= lock_wait_cntr_15_8 + 1'b1;
                   end
                end
             end
          end
      end
      else // Assuming REF_CLK_FREQ != 1 means 125MHz or other
      begin : lock_wait_other
          always @(posedge clkin_pll or posedge rst)
          begin
             if(rst)
             begin
                lock_wait_cntr_7_0  <= 8'h0;
                lock_wait_cntr_15_8 <= 8'h0;
                pll_locked_out_r  <= 1'b0;
                time_elapsed      <= 1'b0;
             end else begin
                 // Wait ~13k cycles (e.g., ~104us @ 125MHz) before checking lock
                if ((lock_wait_cntr_15_8 == 8'h33) || time_elapsed)
                begin
                   pll_locked_out_r <= pll_lk_out;
                   time_elapsed     <= 1'b1;
                end else begin
                   lock_wait_cntr_7_0  <= lock_wait_cntr_7_0 + 1'b1;
                   if (lock_wait_cntr_7_0 == 8'hff) begin
                       lock_wait_cntr_15_8 <= lock_wait_cntr_15_8 + 1'b1;
                   end
                end
             end
          end
      end

          // Synchronize lock signal to coreclk domain
          always @(posedge coreclk or posedge rst)
          begin
             if (rst)
             begin
                pll_locked_out_r_d  <= 1'b0;
                pll_locked_out_r_2d <= 1'b0;
             end
             else
             begin
                pll_locked_out_r_d  <= pll_locked_out_r;
                pll_locked_out_r_2d <= pll_locked_out_r_d;
             end
          end

            // Select final lock output based on simulation mode
            assign locked = fast_train_simulation_only ? pll_lk_out : pll_locked_out_r_2d;

       end
   endgenerate

   generate
     if (G_DIVIDE_VAL == 1)
      begin : sameclk
        assign userclk = coreclk;
      end
     else
      begin : notsame
        BUFG usrclk_pll_bufg (.O(userclk), .I(clkout1));
      end
   endgenerate

endmodule