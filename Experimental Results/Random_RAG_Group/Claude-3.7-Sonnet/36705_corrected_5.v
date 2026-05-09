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

   wire gtx_clk_bufg;
   wire gtx_clk_bufg_mux;
   wire s_axi_aclk;
   wire refclk_bufg;
   wire dcm_locked;
   wire glbl_rst_intn;
   reg phy_resetn_int;
   reg [7:0] phy_reset_count;
   wire clk_mux;
   wire rst_mux;

   assign gtx_clk_bufg_mux = clk_in_p;
   assign clk_mux = test_i ? clk_in_p : gtx_clk_bufg;
   assign rst_mux = test_i ? glbl_rst : ~dcm_locked;

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

   always @(posedge clk_mux)
   begin
      if (rst_mux) begin
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

   assign phy_resetn = phy_resetn_int;

   tri_mode_eth_mac_v5_2_fifo_block #(
       .C_BASE_ADDRESS              (MAC_BASE_ADDR)
   ) trimac_fifo_block (
      .gtx_clk                      (clk_mux),
      // ... rest of existing port connections ...
   );

endmodule