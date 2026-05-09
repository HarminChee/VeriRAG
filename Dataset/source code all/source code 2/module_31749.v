`timescale 1ps/1ps
`timescale 1ps/1ps
module example_top #
  (
   parameter BEGIN_ADDRESS         = 32'h00000000,
   parameter END_ADDRESS           = 32'h00ffffff,
   parameter PRBS_EADDR_MASK_POS   = 32'hff000000,
   parameter ENFORCE_RD_WR         = 0,
   parameter ENFORCE_RD_WR_CMD     = 8'h11,
   parameter ENFORCE_RD_WR_PATTERN = 3'b000,
   parameter C_EN_WRAP_TRANS       = 0,
   parameter C_AXI_NBURST_TEST     = 0,
   parameter CK_WIDTH              = 1,
   parameter nCS_PER_RANK          = 1,
   parameter CKE_WIDTH             = 1,
   parameter DM_WIDTH              = 8,
   parameter ODT_WIDTH             = 1,
   parameter BANK_WIDTH            = 3,
   parameter COL_WIDTH             = 10,
   parameter CS_WIDTH              = 1,
   parameter DQ_WIDTH              = 64,
   parameter DQS_WIDTH             = 8,
   parameter DQS_CNT_WIDTH         = 3,
   parameter DRAM_WIDTH            = 8,
   parameter ECC                   = "OFF",
   parameter ECC_TEST              = "OFF",
   parameter nBANK_MACHS           = 4,
   parameter RANKS                 = 1,
   parameter ROW_WIDTH             = 14,
   parameter ADDR_WIDTH            = 28,
   parameter BURST_MODE            = "8",
   parameter CLKIN_PERIOD          = 5000,
   parameter CLKFBOUT_MULT         = 8,
   parameter DIVCLK_DIVIDE         = 1,
   parameter CLKOUT0_PHASE         = 337.5,
   parameter CLKOUT0_DIVIDE        = 2,
   parameter CLKOUT1_DIVIDE        = 2,
   parameter CLKOUT2_DIVIDE        = 32,
   parameter CLKOUT3_DIVIDE        = 8,
   parameter MMCM_VCO              = 800,
   parameter MMCM_MULT_F           = 4,
   parameter MMCM_DIVCLK_DIVIDE    = 1,
   parameter MMCM_CLKOUT0_EN       = "TRUE",
   parameter MMCM_CLKOUT1_EN       = "FALSE",
   parameter MMCM_CLKOUT2_EN       = "FALSE",
   parameter MMCM_CLKOUT3_EN       = "FALSE",
   parameter MMCM_CLKOUT4_EN       = "FALSE",
   parameter MMCM_CLKOUT0_DIVIDE   = 16.000,
   parameter MMCM_CLKOUT1_DIVIDE   = 1,
   parameter MMCM_CLKOUT2_DIVIDE   = 1,
   parameter MMCM_CLKOUT3_DIVIDE   = 1,
   parameter MMCM_CLKOUT4_DIVIDE   = 1,
   parameter SIMULATION            = "FALSE",
   parameter TCQ                   = 100,
   parameter DRAM_TYPE             = "DDR3",
   parameter nCK_PER_CLK           = 4,
   parameter C_S_AXI_ID_WIDTH              = 4,
   parameter C_S_AXI_ADDR_WIDTH            = 30,
   parameter C_S_AXI_DATA_WIDTH            = 32,
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 1,
   parameter DEBUG_PORT            = "OFF",
   parameter RST_ACT_LOW           = 0
   )
  (
   inout [63:0]                         ddr3_dq,
   inout [7:0]                        ddr3_dqs_n,
   inout [7:0]                        ddr3_dqs_p,
   output [13:0]                       ddr3_addr,
   output [2:0]                      ddr3_ba,
   output                                       ddr3_ras_n,
   output                                       ddr3_cas_n,
   output                                       ddr3_we_n,
   output                                       ddr3_reset_n,
   output [0:0]                        ddr3_ck_p,
   output [0:0]                        ddr3_ck_n,
   output [0:0]                       ddr3_cke,
   output [0:0]           ddr3_cs_n,
   output [7:0]                        ddr3_dm,
   output [0:0]                       ddr3_odt,
   input                                        sys_clk_p,
   input                                        sys_clk_n,
   output                                       tg_compare_error,
   output                                       init_calib_complete,
   input                                        sys_rst
   );
function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction 
  function integer STR_TO_INT;
    input [7:0] in;
    begin
      if(in == "8")
        STR_TO_INT = 8;
      else if(in == "4")
        STR_TO_INT = 4;
      else
        STR_TO_INT = 0;
    end
  endfunction
  localparam DATA_WIDTH            = 64;
  localparam RANK_WIDTH = clogb2(RANKS);
  localparam PAYLOAD_WIDTH         = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
  localparam BURST_LENGTH          = STR_TO_INT(BURST_MODE);
  localparam APP_DATA_WIDTH        = 2 * nCK_PER_CLK * PAYLOAD_WIDTH;
  localparam APP_MASK_WIDTH        = APP_DATA_WIDTH / 8;
  localparam  TG_ADDR_WIDTH = ((CS_WIDTH == 1) ? 0 : RANK_WIDTH)
                                 + BANK_WIDTH + ROW_WIDTH + COL_WIDTH;
  localparam MASK_SIZE             = DATA_WIDTH/8;
  localparam DBG_WR_STS_WIDTH      = 40;
  localparam DBG_RD_STS_WIDTH      = 40;
  wire                              clk;
  wire                              rst;
  wire                              ui_addn_clk_0;
  wire                              ui_addn_clk_1;
  wire                              ui_addn_clk_2;
  wire                              ui_addn_clk_3;
  wire                              ui_addn_clk_4;
  wire                              mmcm_locked;
  reg                               aresetn;
  wire                              app_sr_active;
  wire                              app_ref_ack;
  wire                              app_zq_ack;
  wire                              app_rd_data_valid;
  wire [APP_DATA_WIDTH-1:0]         app_rd_data;
  wire                              mem_pattern_init_done;
  wire                              cmd_err;
  wire                              data_msmatch_err;
  wire                              write_err;
  wire                              read_err;
  wire                              test_cmptd;
  wire                              write_cmptd;
  wire                              read_cmptd;
  wire                              cmptd_one_wr_rd;
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_awid;
  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_awaddr;
  wire [7:0]                        s_axi_awlen;
  wire [2:0]                        s_axi_awsize;
  wire [1:0]                        s_axi_awburst;
  wire [0:0]                        s_axi_awlock;
  wire [3:0]                        s_axi_awcache;
  wire [2:0]                        s_axi_awprot;
  wire                              s_axi_awvalid;
  wire                              s_axi_awready;
  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_wdata;
  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]   s_axi_wstrb;
  wire                              s_axi_wlast;
  wire                              s_axi_wvalid;
  wire                              s_axi_wready;
  wire                              s_axi_bready;
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_bid;
  wire [1:0]                        s_axi_bresp;
  wire                              s_axi_bvalid;
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_arid;
  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_araddr;
  wire [7:0]                        s_axi_arlen;
  wire [2:0]                        s_axi_arsize;
  wire [1:0]                        s_axi_arburst;
  wire [0:0]                        s_axi_arlock;
  wire [3:0]                        s_axi_arcache;
  wire [2:0]                        s_axi_arprot;
  wire                              s_axi_arvalid;
  wire                              s_axi_arready;
  wire                              s_axi_rready;
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_rid;
  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata;
  wire [1:0]                        s_axi_rresp;
  wire                              s_axi_rlast;
  wire                              s_axi_rvalid;
  wire                              cmp_data_valid;
  wire [C_S_AXI_DATA_WIDTH-1:0]      cmp_data;     
  wire [C_S_AXI_DATA_WIDTH-1:0]      rdata_cmp;      
  wire                              dbg_wr_sts_vld;
  wire [DBG_WR_STS_WIDTH-1:0]       dbg_wr_sts;
  wire                              dbg_rd_sts_vld;
  wire [DBG_RD_STS_WIDTH-1:0]       dbg_rd_sts;
  wire [11:0]                           device_temp;
`ifdef SKIP_CALIB
  wire                          calib_tap_req;
  reg                           calib_tap_load;
  reg [6:0]                     calib_tap_addr;
  reg [7:0]                     calib_tap_val;
  reg                           calib_tap_load_done;
`endif
  assign tg_compare_error = cmd_err | data_msmatch_err | write_err | read_err;
  mig_wrap_mig_7series_0_0 u_mig_wrap_mig_7series_0_0
      (
       .ddr3_addr                      (ddr3_addr),
       .ddr3_ba                        (ddr3_ba),
       .ddr3_cas_n                     (ddr3_cas_n),
       .ddr3_ck_n                      (ddr3_ck_n),
       .ddr3_ck_p                      (ddr3_ck_p),
       .ddr3_cke                       (ddr3_cke),
       .ddr3_ras_n                     (ddr3_ras_n),
       .ddr3_we_n                      (ddr3_we_n),
       .ddr3_dq                        (ddr3_dq),
       .ddr3_dqs_n                     (ddr3_dqs_n),
       .ddr3_dqs_p                     (ddr3_dqs_p),
       .ddr3_reset_n                   (ddr3_reset_n),
       .init_calib_complete            (init_calib_complete),
       .ddr3_cs_n                      (ddr3_cs_n),
       .ddr3_dm                        (ddr3_dm),
       .ddr3_odt                       (ddr3_odt),
       .ui_clk                         (clk),
       .ui_clk_sync_rst                (rst),
       .ui_addn_clk_0                  (ui_addn_clk_0),
       .ui_addn_clk_1                  (ui_addn_clk_1),
       .ui_addn_clk_2                  (ui_addn_clk_2),
       .ui_addn_clk_3                  (ui_addn_clk_3),
       .ui_addn_clk_4                  (ui_addn_clk_4),
       .mmcm_locked                    (mmcm_locked),
       .aresetn                        (aresetn),
       .app_sr_active                  (app_sr_active),
       .app_ref_ack                    (app_ref_ack),
       .app_zq_ack                     (app_zq_ack),
       .s_axi_awid                     (s_axi_awid),
       .s_axi_awaddr                   (s_axi_awaddr),
       .s_axi_awlen                    (s_axi_awlen),
       .s_axi_awsize                   (s_axi_awsize),
       .s_axi_awburst                  (s_axi_awburst),
       .s_axi_awlock                   (s_axi_awlock),
       .s_axi_awcache                  (s_axi_awcache),
       .s_axi_awprot                   (s_axi_awprot),
       .s_axi_awqos                    (4'h0),
       .s_axi_awvalid                  (s_axi_awvalid),
       .s_axi_awready                  (s_axi_awready),
       .s_axi_wdata                    (s_axi_wdata),
       .s_axi_wstrb                    (s_axi_wstrb),
       .s_axi_wlast                    (s_axi_wlast),
       .s_axi_wvalid                   (s_axi_wvalid),
       .s_axi_wready                   (s_axi_wready),
       .s_axi_bid                      (s_axi_bid),
       .s_axi_bresp                    (s_axi_bresp),
       .s_axi_bvalid                   (s_axi_bvalid),
       .s_axi_bready                   (s_axi_bready),
       .s_axi_arid                     (s_axi_arid),
       .s_axi_araddr                   (s_axi_araddr),
       .s_axi_arlen                    (s_axi_arlen),
       .s_axi_arsize                   (s_axi_arsize),
       .s_axi_arburst                  (s_axi_arburst),
       .s_axi_arlock                   (s_axi_arlock),
       .s_axi_arcache                  (s_axi_arcache),
       .s_axi_arprot                   (s_axi_arprot),
       .s_axi_arqos                    (4'h0),
       .s_axi_arvalid                  (s_axi_arvalid),
       .s_axi_arready                  (s_axi_arready),
       .s_axi_rid                      (s_axi_rid),
       .s_axi_rdata                    (s_axi_rdata),
       .s_axi_rresp                    (s_axi_rresp),
       .s_axi_rlast                    (s_axi_rlast),
       .s_axi_rvalid                   (s_axi_rvalid),
       .s_axi_rready                   (s_axi_rready),
       .sys_clk_p                       (sys_clk_p),
       .sys_clk_n                       (sys_clk_n),
       .device_temp            (device_temp),
       `ifdef SKIP_CALIB
       .calib_tap_req                    (calib_tap_req),
       .calib_tap_load                   (calib_tap_load),
       .calib_tap_addr                   (calib_tap_addr),
       .calib_tap_val                    (calib_tap_val),
       .calib_tap_load_done              (calib_tap_load_done),
       `endif
       .sys_rst                        (sys_rst)
       );
   always @(posedge clk) begin
     aresetn <= ~rst;
   end
   mig_7series_v4_0_axi4_tg #(
     .C_AXI_ID_WIDTH                   (C_S_AXI_ID_WIDTH),
     .C_AXI_ADDR_WIDTH                 (C_S_AXI_ADDR_WIDTH),
     .C_AXI_DATA_WIDTH                 (C_S_AXI_DATA_WIDTH),
     .C_AXI_NBURST_SUPPORT             (C_AXI_NBURST_TEST),
     .C_EN_WRAP_TRANS                  (C_EN_WRAP_TRANS),
     .C_BEGIN_ADDRESS                  (BEGIN_ADDRESS),
     .C_END_ADDRESS                    (END_ADDRESS),
     .PRBS_EADDR_MASK_POS              (PRBS_EADDR_MASK_POS),
     .DBG_WR_STS_WIDTH                 (DBG_WR_STS_WIDTH),
     .DBG_RD_STS_WIDTH                 (DBG_RD_STS_WIDTH),
     .ENFORCE_RD_WR                    (ENFORCE_RD_WR),
     .ENFORCE_RD_WR_CMD                (ENFORCE_RD_WR_CMD),
     .EN_UPSIZER                       (C_S_AXI_SUPPORTS_NARROW_BURST),
     .ENFORCE_RD_WR_PATTERN            (ENFORCE_RD_WR_PATTERN)
   ) u_axi4_tg_inst
   (
     .aclk                             (clk),
     .aresetn                          (aresetn),
     .init_cmptd                       (init_calib_complete),
     .init_test                        (1'b0),
     .wdog_mask                        (~init_calib_complete),
     .wrap_en                          (1'b0),
     .axi_wready                       (s_axi_awready),
     .axi_wid                          (s_axi_awid),
     .axi_waddr                        (s_axi_awaddr),
     .axi_wlen                         (s_axi_awlen),
     .axi_wsize                        (s_axi_awsize),
     .axi_wburst                       (s_axi_awburst),
     .axi_wlock                        (s_axi_awlock),
     .axi_wcache                       (s_axi_awcache),
     .axi_wprot                        (s_axi_awprot),
     .axi_wvalid                       (s_axi_awvalid),
     .axi_wd_wready                    (s_axi_wready),
     .axi_wd_wid                       (s_axi_wid),
     .axi_wd_data                      (s_axi_wdata),
     .axi_wd_strb                      (s_axi_wstrb),
     .axi_wd_last                      (s_axi_wlast),
     .axi_wd_valid                     (s_axi_wvalid),
     .axi_wd_bid                       (s_axi_bid),
     .axi_wd_bresp                     (s_axi_bresp),
     .axi_wd_bvalid                    (s_axi_bvalid),
     .axi_wd_bready                    (s_axi_bready),
     .axi_rready                       (s_axi_arready),
     .axi_rid                          (s_axi_arid),
     .axi_raddr                        (s_axi_araddr),
     .axi_rlen                         (s_axi_arlen),
     .axi_rsize                        (s_axi_arsize),
     .axi_rburst                       (s_axi_arburst),
     .axi_rlock                        (s_axi_arlock),
     .axi_rcache                       (s_axi_arcache),
     .axi_rprot                        (s_axi_arprot),
     .axi_rvalid                       (s_axi_arvalid),
     .axi_rd_bid                       (s_axi_rid),
     .axi_rd_rresp                     (s_axi_rresp),
     .axi_rd_rvalid                    (s_axi_rvalid),
     .axi_rd_data                      (s_axi_rdata),
     .axi_rd_last                      (s_axi_rlast),
     .axi_rd_rready                    (s_axi_rready),
     .cmd_err                          (cmd_err),
     .data_msmatch_err                 (data_msmatch_err),
     .write_err                        (write_err),
     .read_err                         (read_err),
     .test_cmptd                       (test_cmptd),
     .write_cmptd                      (write_cmptd),
     .read_cmptd                       (read_cmptd),
     .cmptd_one_wr_rd                  (cmptd_one_wr_rd),
     .cmp_data_en                      (cmp_data_valid),
     .cmp_data_o                       (cmp_data),
     .rdata_cmp                        (rdata_cmp),
     .dbg_wr_sts_vld                   (dbg_wr_sts_vld),
     .dbg_wr_sts                       (dbg_wr_sts),
     .dbg_rd_sts_vld                   (dbg_rd_sts_vld),
     .dbg_rd_sts                       (dbg_rd_sts)
);
   assign dbg_sel_pi_incdec       = 'b0;
   assign dbg_sel_po_incdec       = 'b0;
   assign dbg_pi_f_inc            = 'b0;
   assign dbg_pi_f_dec            = 'b0;
   assign dbg_po_f_inc            = 'b0;
   assign dbg_po_f_dec            = 'b0;
   assign dbg_po_f_stg23_sel      = 'b0;
   assign po_win_tg_rst           = 'b0;
   assign vio_tg_rst              = 'b0;
`ifdef SKIP_CALIB
  reg[3*DQS_WIDTH-1:0]        po_coarse_tap;
  reg[6*DQS_WIDTH-1:0]        po_stg3_taps;
  reg[6*DQS_WIDTH-1:0]        po_stg2_taps;
  reg[6*DQS_WIDTH-1:0]        pi_stg2_taps;
  reg[5*DQS_WIDTH-1:0]        idelay_taps;
  reg[11:0]                   cal_device_temp;
  always @(posedge clk) begin
    po_coarse_tap   <= #TCQ 'h2;
    po_stg3_taps    <= #TCQ 'h0D;
    po_stg2_taps    <= #TCQ 'h1D;
    pi_stg2_taps    <= #TCQ 'h1E;
    idelay_taps     <= #TCQ 'h08;
        cal_device_temp <= #TCQ 'h000;
  end
  always @(posedge clk) begin
    if (rst)
      calib_tap_load <= #TCQ 1'b0;
    else if (calib_tap_req)
      calib_tap_load <= #TCQ 1'b1;
  end
  always @(posedge clk) begin
    if (rst) begin
      calib_tap_addr      <= #TCQ 'd0;
      calib_tap_val       <= #TCQ po_coarse_tap[3*calib_tap_addr[6:3]+:3]; 
      calib_tap_load_done <= #TCQ 1'b0;
    end else if (calib_tap_load) begin
      case (calib_tap_addr[2:0])
        3'b000: begin
          calib_tap_addr[2:0] <= #TCQ 3'b001;
          calib_tap_val       <= #TCQ po_stg3_taps[6*calib_tap_addr[6:3]+:6]; 
        end
        3'b001: begin
          calib_tap_addr[2:0] <= #TCQ 3'b010;
          calib_tap_val       <= #TCQ po_stg2_taps[6*calib_tap_addr[6:3]+:6]; 
        end
        3'b010: begin
          calib_tap_addr[2:0] <= #TCQ 3'b011;
          calib_tap_val       <= #TCQ pi_stg2_taps[6*calib_tap_addr[6:3]+:6]; 
        end
        3'b011: begin
          calib_tap_addr[2:0] <= #TCQ 3'b100;
          calib_tap_val       <= #TCQ idelay_taps[5*calib_tap_addr[6:3]+:5]; 
        end
        3'b100: begin
          if (calib_tap_addr[6:3] < DQS_WIDTH-1) begin
            calib_tap_addr[2:0] <= #TCQ 3'b000;
            calib_tap_val       <= #TCQ po_coarse_tap[3*(calib_tap_addr[6:3]+1)+:3]; 
            calib_tap_addr[6:3] <= #TCQ calib_tap_addr[6:3] + 1;
          end else begin
            calib_tap_addr[2:0] <= #TCQ 3'b110;
            calib_tap_val       <= #TCQ cal_device_temp[7:0];
            calib_tap_addr[6:3] <= #TCQ 4'b1111;
          end
        end
        3'b110: begin
            calib_tap_addr[2:0] <= #TCQ 3'b111;
            calib_tap_val       <= #TCQ {4'h0,cal_device_temp[11:8]};
            calib_tap_addr[6:3] <= #TCQ 4'b1111;
        end
        3'b111: begin
            calib_tap_load_done <= #TCQ 1'b1;
        end
      endcase
    end
  end
`endif    
endmodule
