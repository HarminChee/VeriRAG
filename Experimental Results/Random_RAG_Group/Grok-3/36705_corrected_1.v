`timescale 1 ps/1 ps
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
   parameter MAC_BASE_ADDR = 32'h0;
   wire                 gtx_clk_bufg;
   wire                 refclk_bufg;
   wire                 s_axi_aclk;                 
   wire                 rx_mac_aclk;
   reg                  phy_resetn_int;
   wire                 s_axi_reset_int;
   reg                  s_axi_pre_resetn = 0;
   reg                  s_axi_resetn = 0;
   wire                 chk_reset_int;
   reg                  chk_pre_resetn = 0;
   reg                  chk_resetn = 0;
   wire                 gtx_clk_reset_int;
   reg                  gtx_pre_resetn = 0;
   reg                  gtx_resetn = 0;
   wire                 rx_reset;
   wire                 tx_reset;
   wire                 dcm_locked;
   wire                 glbl_rst_int;
   reg   [5:0]          phy_reset_count;
   wire                 glbl_rst_intn;
   wire                 rx_fifo_clock;
   wire                 rx_fifo_resetn;  
   wire  [7:0]          rx_axis_fifo_tdata;
   wire                 rx_axis_fifo_tvalid;
   wire                 rx_axis_fifo_tlast;
   wire                 rx_axis_fifo_tready;
   wire                 tx_fifo_clock;
   wire                 tx_fifo_resetn;
   wire  [7:0]          tx_axis_fifo_tdata;
   wire                 tx_axis_fifo_tvalid;
   wire                 tx_axis_fifo_tlast;
   wire                 tx_axis_fifo_tready;
   wire                 rx_statistics_valid;
   reg                  rx_statistics_valid_reg;
   wire  [27:0]         rx_statistics_vector;
   reg   [27:0]         rx_stats;
   reg                  rx_stats_toggle = 0;
   wire                 rx_stats_toggle_sync;
   reg                  rx_stats_toggle_sync_reg = 0;
   reg   [29:0]         rx_stats_shift;
   wire                 tx_statistics_valid;
   reg                  tx_statistics_valid_reg;
   wire  [31:0]         tx_statistics_vector;
   reg   [33:0]         tx_stats_shift;
   reg   [18:0]         pause_shift;
   reg                  pause_req;
   reg   [15:0]         pause_val;
   wire  [31:0]         s_axi_awaddr;
   wire                 s_axi_awvalid;
   wire                 s_axi_awready;
   wire  [31:0]         s_axi_wdata;
   wire                 s_axi_wvalid;
   wire                 s_axi_wready;
   wire  [1:0]          s_axi_bresp;
   wire                 s_axi_bvalid;
   wire                 s_axi_bready;
   wire  [31:0]         s_axi_araddr;
   wire                 s_axi_arvalid;
   wire                 s_axi_arready;
   wire  [31:0]         s_axi_rdata;   
   wire  [1:0]          s_axi_rresp;
   wire                 s_axi_rvalid;
   wire                 s_axi_rready;
   reg                  enable_address_swap = 1;
   reg                  enable_phy_loopback = 0;
   wire  [7:0]          tx_ifg_delay = 0;    
   assign frame_errorn = !frame_error;
   assign activity_flashn = !activity_flash;
   wire                 mdio_i;
   wire                 mdio_o;
   wire                 mdio_t;
   assign mdio = mdio_t ? 1'bz : mdio_o;
   assign mdio_i = mdio;
   wire                 dft_rx_fifo_clock;
   wire                 dft_tx_fifo_clock;
   wire                 dft_rx_fifo_resetn;
   wire                 dft_tx_fifo_resetn;
   assign dft_rx_fifo_clock = test_i ? gtx_clk_bufg : rx_fifo_clock;
   assign dft_tx_fifo_clock = test_i ? gtx_clk_bufg : tx_fifo_clock;
   assign dft_rx_fifo_resetn = test_i ? gtx_resetn : rx_fifo_resetn;
   assign dft_tx_fifo_resetn = test_i ? gtx_resetn : tx_fifo_resetn;
  always @(posedge dft_tx_fifo_clock or posedge glbl_rst)
  begin
     if (glbl_rst) begin
        enable_address_swap <= 1;
     end else if (config_board) begin
        enable_address_swap <= gen_tx_data;
     end
  end
  always @(posedge s_axi_aclk or posedge glbl_rst)
  begin
     if (glbl_rst) begin
        enable_phy_loopback <= 0;
     end else if (config_board) begin
        enable_phy_loopback <= chk_tx_data;
     end
  end
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
   reset_sync glbl_reset_gen (
      .clk              (gtx_clk_bufg),
      .enable           (dcm_locked),
      .reset_in         (glbl_rst),
      .reset_out        (glbl_rst_int)
   );
   assign glbl_rst_intn = !glbl_rst_int;
  assign tx_fifo_clock = gtx_clk_bufg;
  assign rx_fifo_clock = gtx_clk_bufg;
   reset_sync axi_lite_reset_gen (
      .clk              (s_axi_aclk),
      .enable           (phy_resetn_int),
      .reset_in         (glbl_rst),
      .reset_out        (s_axi_reset_int)
   );
   always @(posedge s_axi_aclk)
   begin
     if (s_axi_reset_int) begin
       s_axi_pre_resetn <= 0;
       s_axi_resetn     <= 0;
     end
     else begin
       s_axi_pre_resetn <= 1;
       s_axi_resetn     <= s_axi_pre_resetn;
     end
   end 
   reset_sync gtx_reset_gen (
      .clk              (gtx_clk_bufg),
      .enable           (dcm_locked),
      .reset_in         (glbl_rst || rx_reset || tx_reset),
      .reset_out        (gtx_clk_reset_int)
   );
   always @(posedge gtx_clk_bufg)
   begin
     if (gtx_clk_reset_int) begin
       gtx_pre_resetn  <= 0;
       gtx_resetn      <= 0;
     end
     else begin
       gtx_pre_resetn  <= 1;
       gtx_resetn      <= gtx_pre_resetn;
     end
   end 
   reset_sync chk_reset_gen (
      .clk              (gtx_clk_bufg),
      .enable           (dcm_locked),
      .reset_in         (glbl_rst || reset_error),
      .reset_out        (chk_reset_int)
   );
   always @(posedge gtx_clk_bufg)
   begin
     if (chk_reset_int) begin
       chk_pre_resetn  <= 0;
       chk_resetn      <= 0;
     end
     else begin
       chk_pre_resetn  <= 1;
       chk_resetn      <= chk_pre_resetn;
     end
   end 
   always @(posedge gtx_clk_bufg)
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
   assign phy_resetn = phy_resetn_int;
   assign tx_fifo_resetn = gtx_resetn;
   assign rx_fifo_resetn = gtx_resetn;
  always @(posedge rx_mac_aclk)
  begin
     rx_statistics_valid_reg <= rx_statistics_valid;
     if (!rx_statistics_valid_reg & rx_statistics_valid) begin
        rx_stats <= rx_statistics_vector;
        rx_stats_toggle <= !rx_stats_toggle;
     end
  end
  sync_block rx_stats_sync (
     .clk              (gtx_clk_bufg),
     .data_in          (rx_stats_toggle),
     .data_out         (rx_stats_toggle_sync)
  );
  always @(posedge gtx_clk_bufg)
  begin
     rx_stats_toggle_sync_reg <= rx_stats_toggle_sync;
  end
  always @(posedge gtx_clk_bufg)
  begin
     if (rx_stats_toggle_sync_reg != rx_stats_toggle_sync) begin
        rx_stats_shift <= {1'b1, rx_stats, 1'b1};
     end
     else begin
        rx_stats_shift <= {rx_stats_shift[28:0], 1'b0};
     end
  end
  assign rx_statistics_s = rx_stats_shift[29];
  always @(posedge dft_tx_fifo_clock)
  begin
     tx_statistics_valid_reg <= tx_statistics_valid;
     if (!tx_statistics_valid_reg & tx_statistics_valid) begin
        tx_stats_shift <= {1'b1, tx_statistics_vector, 1'b1};
     end
     else begin
        tx_stats_shift <= {tx_stats_shift[32:0], 1'b0};
     end
  end
  assign tx_statistics_s = tx_stats_shift[33];
  always @(posedge dft_tx_fifo_clock)
  begin
     pause_shift <= {pause_shift[17:0], pause_req_s};
  end
  always @(posedge dft_tx_fifo_clock)
  begin
     if (pause_shift[18] === 1'b0 & pause_shift[17] === 1'b1 & pause_shift[0] === 1'b1) begin
        pause_req <= 1'b1;
        pause_val <= pause_shift[16:1];
     end
     else begin
        pause_req <= 1'b0;
        pause_val <= 0;
     end
  end
   axi_lite_sm #(
      .MAC_BASE_ADDR               (MAC_BASE_ADDR)
   ) axi_lite_controller (
      .s_axi_aclk                   (s_axi_aclk),                  
      .s_axi_resetn                 (s_axi_resetn),
      .mac_speed                    (mac_speed),              
      .update_speed                 (update_speed),   
      .serial_command               (pause_req_s),
      .serial_response              (serial_response),
      .phy_loopback                 (enable_phy_loopback),
      .s_axi_awaddr                 (s_axi_awaddr),       
      .s_axi_awvalid                (s_axi_awvalid),      
      .s_axi_awready                (s_axi_awready),      
      .s_axi_wdata                  (s_axi_wdata),        
      .s_axi_wvalid                 (s_axi_wvalid),       
      .s_axi_wready                 (s_axi_wready),       
      .s_axi_bresp                  (s_axi_bresp),        
      .s_axi_bvalid                 (s_axi_bvalid),       
      .s_axi_bready                 (s_axi_bready),       
      .s_axi_araddr                 (s_axi_araddr),       
      .s_axi_arvalid                (s_axi_arvalid),      
      .s_axi_arready                (s_axi_arready),      
      .s_axi_rdata                  (s_axi_rdata),                            
      .s_axi_rresp                  (s_axi_rresp),         
      .s_axi_rvalid                 (s_axi_rvalid),        
      .s_axi_rready                 (s_axi_rready)
   );
  tri_mode_eth_mac_v5_2_fifo_block #(
       .C_BASE_ADDRESS              (MAC_BASE_ADDR)
   ) trimac_fifo_block (
      .gtx_clk                      (gtx_clk_bufg),
      .glbl_rstn                    (glbl_rst_intn),
      .rx_axi_rstn                  (1'b1),
      .tx_axi_rstn                  (1'b1),
      .refclk                       (refclk_bufg),
      .rx_mac_aclk                  (rx_mac_aclk),
      .rx_reset                     (rx_reset),
      .rx_statistics_vector         (rx_statistics_vector),
      .rx_statistics_valid          (rx_statistics_valid),
      .rx_fifo_clock                (rx_fifo_clock),
      .rx_fifo_resetn               (rx_fifo_resetn),
      .rx_axis_fifo_tdata           (rx_axis_fifo_tdata),
      .rx_axis_fifo_tvalid          (rx_axis_fifo_tvalid),
      .rx_axis_fifo_tready          (rx_axis_fifo_tready),
      .rx_axis_fifo_tlast           (rx_axis_fifo_tlast),
      .tx_reset                     (tx_reset),
      .tx_ifg_delay                 (tx_ifg_delay),
      .tx_statistics_vector         (tx_statistics_vector),
      .tx_statistics_valid          (tx_statistics_valid),
      .tx_fifo_clock                (tx_fifo_clock),
      .tx_fifo_resetn               (tx_fifo_resetn),
      .tx_axis_fifo_tdata           (tx_axis_fifo_tdata),
      .tx_axis_fifo_tvalid          (tx_axis_fifo_tvalid),
      .tx_axis_fifo_tready          (tx_axis_fifo_tready),
      .tx_axis_fifo_tlast           (tx_axis_fifo_tlast),
      .pause_req                    (pause_req),
      .pause_val                    (pause_val),
      .gmii_txd                     (gmii_txd),
      .gmii_tx_en                   (gmii_tx_en),
      .gmii_tx_er                   (gmii_tx_er),
      .gmii_tx_clk                  (gmii_tx_clk),
      .gmii_rxd                     (gmii_rxd),
      .gmii_rx_dv                   (gmii_rx_dv),
      .gmii_rx_er                   (gmii_rx_er),
      .gmii_rx_clk                  (gmii_rx_clk),
      .gmii_col                     (gmii_col),
      .gmii_crs                     (gmii_crs),
      .mdio_i                       (mdio_i),
      .mdio_o                       (mdio_o),
      .mdio_t                       (mdio_t),
      .mdc                          (mdc),
      .s_axi_aclk                   (s_axi_aclk),
      .s_axi_resetn                 (s_axi_resetn),
      .s_axi_awaddr                 (s_axi_awaddr),
      .s_axi_awvalid                (s_axi_awvalid),
      .s_axi_awready                (s_axi_awready),
      .s_axi_wdata                  (s_axi_wdata),
      .s_axi_wvalid                 (s_axi_wvalid),
      .s_axi_wready                 (s_axi_wready),
      .s_axi_bresp                  (s_axi_bresp),
      .s_axi_bvalid                 (s_axi_bvalid),
      .s_axi_bready                 (s_axi_bready),
      .s_axi_araddr                 (s_axi_araddr),
      .s_axi_arvalid                (s_axi_arvalid),
      .s_axi_arready                (s_axi_arready),
      .s_axi_rdata                  (s_axi_rdata),
      .s_axi_rresp                  (s_axi_rresp),
      .s_axi_rvalid                 (s_axi_rvalid),
      .s_axi_rready                 (s_axi_rready)
   );
   basic_pat_gen basic_pat_gen (
      .axi_tclk                     (dft_tx_fifo_clock),
      .axi_tresetn                  (dft_tx_fifo_resetn),
      .check_resetn                 (chk_resetn),
      .enable_pat_gen               (gen_tx_data),
      .enable_pat_chk               (chk_tx_data),    
      .enable_address_swap          (enable_address_swap),
      .speed                        (mac_speed),
      .rx_axis_tdata                (rx_axis_fifo_tdata),
      .rx_axis_tvalid               (rx_axis_fifo_tvalid),
      .rx_axis_tlast                (rx_axis_fifo_tlast),
      .rx_axis_tuser                (1'b0), 
      .rx_axis_tready               (rx_axis_fifo_tready),
      .tx_axis_tdata                (tx_axis_fifo_tdata),
      .tx_axis_tvalid               (tx_axis_fifo_tvalid),
      .tx_axis_tlast                (tx_axis_fifo_tlast),
      .tx_axis_tready               (tx_axis_fifo_tready),
      .frame_error                  (frame_error),
      .activity_flash               (activity_flash)
   );
endmodule