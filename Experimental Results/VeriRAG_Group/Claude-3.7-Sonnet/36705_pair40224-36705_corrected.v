`timescale 1 ps/1 ps
module tri_mode_eth_mac_v5_2_example_design 
   (
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
      output        activity_flashn,
      input         test_i
    );
   parameter MAC_BASE_ADDR = 32'h0;
   // ... existing code ...
   
   wire dft_gtx_clk_bufg;
   wire dft_s_axi_aclk;
   wire dft_refclk_bufg;
   
   assign dft_gtx_clk_bufg = test_i ? clk_in_p : gtx_clk_bufg;
   assign dft_s_axi_aclk = test_i ? clk_in_p : s_axi_aclk;
   assign dft_refclk_bufg = test_i ? clk_in_p : refclk_bufg;
   
   // ... existing code ...
   
   always @(posedge dft_gtx_clk_bufg or negedge glbl_rst_intn)
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
   
   always @(posedge dft_s_axi_aclk or negedge s_axi_resetn)
   begin
     if (!s_axi_resetn) begin
       s_axi_pre_resetn <= 0;
       s_axi_resetn     <= 0;
     end
     else begin
       s_axi_pre_resetn <= 1;
       s_axi_resetn     <= s_axi_pre_resetn;
     end
   end 
   
   // ... existing code ...
   
   always @(posedge dft_gtx_clk_bufg or negedge glbl_rst_intn)
   begin
     if (!glbl_rst_intn) begin
       gtx_pre_resetn  <= 0;
       gtx_resetn      <= 0;
     end
     else begin
       gtx_pre_resetn  <= 1;
       gtx_resetn      <= gtx_pre_resetn;
     end
   end 
   
   // ... existing code ...
   
   always @(posedge dft_gtx_clk_bufg or negedge glbl_rst_intn)
   begin
     if (!glbl_rst_intn) begin
       chk_pre_resetn  <= 0;
       chk_resetn      <= 0;
     end
     else begin
       chk_pre_resetn  <= 1;
       chk_resetn      <= chk_pre_resetn;
     end
   end 
   
   // ... existing code ...
   
   always @(posedge dft_gtx_clk_bufg or negedge glbl_rst_intn)
   begin
     if (!glbl_rst_intn) begin
       enable_address_swap   <= 1'b0;
     end
     else if (config_board) begin
       enable_address_swap   <= gen_tx_data;
     end
  end
  
  // ... existing code ...
  
  always @(posedge dft_s_axi_aclk or negedge s_axi_resetn)
  begin
     if (!s_axi_resetn) begin
       enable_phy_loopback   <= 1'b0;
     end
     else if (config_board) begin
       enable_phy_loopback   <= chk_tx_data;
     end
  end
  
  // ... existing code ...
  
endmodule