module tri_mode_eth_mac_v5_2_example_design 
   (
      input         test_i,
      input         glbl_rst,
      input         clk_in_p,
      input         clk_in_n,
      output        phy_resetn,
      output [7:0]  gmii_txd,
      output        gmii_tx_en,
      output        gmii_tx_er,
      output        gmii_tx_clk,
      input  [7:0]  gmii_rxd,
      input         gmii_rx_dv,
      input         gmii_rx_er,
      input         gmii_rx_clk,
      input         gmii_col,
      input         gmii_crs,
      inout         mdio,
      output        mdc,
      output        tx_statistics_s,
      output        rx_statistics_s,
      input         pause_req_s,
      input  [1:0]  mac_speed,
      input         update_speed,
      input         config_board,
      output        serial_response,
      input         gen_tx_data,
      input         chk_tx_data,
      input         reset_error,
      output        frame_error,
      output        frame_errorn,
      output        activity_flash,
      output        activity_flashn
    );

   // ... existing code ...

   wire gtx_clk_bufg_mux;
   assign gtx_clk_bufg_mux = test_i ? clk_in_p : gtx_clk_bufg;

   // ... existing code ...

   clk_wiz_v2_1 clock_generator
   (   
      .CLK_IN1_P     (clk_in_p),
      .CLK_IN1_N     (clk_in_n),
      .CLK_OUT1      (gtx_clk_bufg),
      .CLK_OUT2      (s_axi_aclk),
      .CLK_OUT3      (refclk_bufg),
      .RESET         (glbl_rst),
      .LOCKED        (dcm_locked)
   );

   // ... existing code ...

   always @(posedge gtx_clk_bufg_mux)
   begin
      if (!glbl_rst_intn) begin
         phy_resetn_int <= 0;
         phy_reset_count <= 0;
      end
      else begin
         if (!(&phy_reset_count)) begin
            phy_reset_count <= phy_reset_count + 1;
         end
         else begin
            phy_resetn_int <= 1;
         end
      end
   end

   // ... existing code ...

   tri_mode_eth_mac_v5_2_fifo_block #(
       .C_BASE_ADDRESS              (MAC_BASE_ADDR)
   ) trimac_fifo_block (
      .gtx_clk                      (gtx_clk_bufg_mux),
      // ... rest of existing port connections ...
   );

   // ... existing code ...

endmodule