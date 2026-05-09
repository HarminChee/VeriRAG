module pcie_clocking_corrected_clk #
( parameter    G_DIVIDE_VAL = 2,  
  parameter    REF_CLK_FREQ = 1  
)
(
  input  clkin_pll,
  input  clkin_dcm,
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
  wire clk0;
  wire clkfb;
  wire clkdv;
  wire [15:0] not_connected;
  reg  [7:0]  lock_wait_cntr_7_0;
  reg  [7:0]  lock_wait_cntr_15_8;
  reg         pll_locked_out_r;
  reg         pll_locked_out_r_d;
  reg         pll_locked_out_r_2d;
  reg         time_elapsed;
  parameter G_DVIDED_VAL_PLL = G_DIVIDE_VAL*2;
   generate
       begin : use_pll
          PLL_ADV #
          (
            .CLKFBOUT_MULT (5-(REF_CLK_FREQ*3)),
            .CLKFBOUT_PHASE(0),
            .CLKIN1_PERIOD (10-(REF_CLK_FREQ*6)),
            .CLKIN2_PERIOD (10-(REF_CLK_FREQ*6)),
            .CLKOUT0_DIVIDE(2),
            .CLKOUT0_PHASE (0),
            .CLKOUT1_DIVIDE(G_DVIDED_VAL_PLL),
            .CLKOUT1_PHASE (0),
            .CLKOUT2_DIVIDE (4), 
            .CLKOUT2_PHASE (0),
            .CLKOUT3_DIVIDE (4), 
            .CLKOUT3_PHASE (0)
          )
          pll_adv_i
          (
            .CLKIN1(clkin_pll),
            .CLKINSEL(1'b1),
            .CLKFBIN(clkfbin),
            .RST(rst),
            .CLKOUT0(clkout0),
            .CLKOUT1(clkout1),
            .CLKOUT2(clkout2),
            .CLKOUT3(txsync_clkout),
            .CLKFBOUT(clkfbout),
            .LOCKED(pll_lk_out)
          );
          assign clkfbin = clkfbout;
          BUFG coreclk_pll_bufg  (.O(coreclk),    .I(clkout0)); 
          BUFG gtxclk_pll_bufg   (.O(gtx_usrclk), .I(clkout2));  
          BUFG txsync_clk_pll_bufg   (.O(txsync_clk), .I(txsync_clkout));  
      if (REF_CLK_FREQ == 1) 
      begin
          always @(posedge clkin_pll or posedge rst)
          begin
             if(rst) 
             begin
                lock_wait_cntr_7_0  <= 8'h0;
                lock_wait_cntr_15_8 <= 8'h0;
                pll_locked_out_r  <= 1'b0;
                time_elapsed      <= 1'b0;
             end else begin
                if ((lock_wait_cntr_15_8 == 8'h80) | time_elapsed)
                begin
                   pll_locked_out_r <= pll_lk_out;
                   time_elapsed     <= 1'b1;
                end else begin
                   lock_wait_cntr_7_0  <= lock_wait_cntr_7_0 + 1'b1;
                   lock_wait_cntr_15_8 <= (lock_wait_cntr_7_0 == 8'hff) ?
                       (lock_wait_cntr_15_8 + 1'b1) : lock_wait_cntr_15_8;
                end
             end
          end
      end
      else  
      begin
          always @(posedge clkin_pll or posedge rst)
          begin
             if(rst) 
             begin
                lock_wait_cntr_7_0  <= 8'h0;
                lock_wait_cntr_15_8 <= 8'h0;
                pll_locked_out_r  <= 1'b0;
                time_elapsed      <= 1'b0;
             end else begin
                if ((lock_wait_cntr_15_8 == 8'h33) | time_elapsed)
                begin
                   pll_locked_out_r <= pll_lk_out;
                   time_elapsed     <= 1'b1;
                end else begin
                   lock_wait_cntr_7_0  <= lock_wait_cntr_7_0 + 1'b1;
                   lock_wait_cntr_15_8 <= (lock_wait_cntr_7_0 == 8'hff) ?
                       (lock_wait_cntr_15_8 + 1'b1) : lock_wait_cntr_15_8;
                end
             end
          end
      end
          always @(posedge clkin_pll or posedge rst)
          begin
             if (rst)
             begin
                pll_locked_out_r_d  <= 0;
                pll_locked_out_r_2d <= 0;
             end
             else
             begin
                pll_locked_out_r_d  <= pll_locked_out_r;
                pll_locked_out_r_2d <= pll_locked_out_r_d;
             end
          end
            assign locked = fast_train_simulation_only ?
                                     pll_lk_out : pll_locked_out_r_2d;
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