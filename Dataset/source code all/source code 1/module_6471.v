`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v2_0_mc #
  (
    parameter TCQ                   = 100,          
    parameter ADDR_CMD_MODE         = "1T",         
    parameter BANK_WIDTH            = 3,            
    parameter BM_CNT_WIDTH          = 2,            
    parameter BURST_MODE            = "8",          
    parameter CL                    = 5,            
    parameter CMD_PIPE_PLUS1        = "ON",         
    parameter COL_WIDTH             = 12,           
    parameter CS_WIDTH              = 4,            
    parameter CWL                   = 5,            
    parameter DATA_BUF_ADDR_WIDTH   = 8,            
    parameter DATA_BUF_OFFSET_WIDTH = 1,            
    parameter DATA_WIDTH            = 64,           
    parameter DQ_WIDTH              = 64,           
    parameter DQS_WIDTH             = 8,            
    parameter DRAM_TYPE             = "DDR3",       
    parameter ECC                   = "OFF",        
    parameter ECC_WIDTH             = 8,            
    parameter MAINT_PRESCALER_PERIOD= 200000,       
    parameter MC_ERR_ADDR_WIDTH     = 31,           
    parameter nBANK_MACHS           = 4,            
    parameter nCK_PER_CLK           = 4,            
    parameter nCS_PER_RANK          = 1,            
    parameter nREFRESH_BANK         = 1,            
    parameter nSLOTS                = 1,            
    parameter ORDERING              = "NORM",       
    parameter PAYLOAD_WIDTH         = 64,           
    parameter RANK_WIDTH            = 2,            
    parameter RANKS                 = 4,            
    parameter REG_CTRL              = "ON",         
    parameter ROW_WIDTH             = 16,           
    parameter RTT_NOM               = "40",         
    parameter RTT_WR                = "120",        
    parameter SLOT_0_CONFIG         = 8'b0000_0101, 
    parameter SLOT_1_CONFIG         = 8'b0000_1010, 
    parameter STARVE_LIMIT          = 2,            
    parameter tCK                   = 2500,         
    parameter tCKE                  = 10000,        
    parameter tFAW                  = 40000,        
    parameter tRAS                  = 37500,        
    parameter tRCD                  = 12500,        
    parameter tREFI                 = 7800000,      
    parameter CKE_ODT_AUX           = "FALSE",      
    parameter tRFC                  = 110000,       
    parameter tRP                   = 12500,        
    parameter tRRD                  = 10000,        
    parameter tRTP                  = 7500,         
    parameter tWTR                  = 7500,         
    parameter tZQCS                 = 64,           
    parameter tZQI                  = 128_000_000,  
    parameter tPRDI                 = 1_000_000,    
    parameter USER_REFRESH          = "OFF"         
  )
  (
    input                                     clk,
    input                                     rst,
    input         [7:0]                       slot_0_present,
    input         [7:0]                       slot_1_present,
    input         [2:0]                       cmd,
    input         [DATA_BUF_ADDR_WIDTH-1:0]   data_buf_addr,
    input                                     hi_priority,
    input                                     size,
    input         [BANK_WIDTH-1:0]            bank,
    input         [COL_WIDTH-1:0]             col,
    input         [RANK_WIDTH-1:0]            rank,
    input         [ROW_WIDTH-1:0]             row,
    input                                     use_addr,
    input         [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0] wr_data,
    input         [2*nCK_PER_CLK*DATA_WIDTH/8-1:0]  wr_data_mask,
    output                                    accept,
    output                                    accept_ns,
    output        [BM_CNT_WIDTH-1:0]          bank_mach_next,
    output wire   [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0] rd_data,
    output        [DATA_BUF_ADDR_WIDTH-1:0]   rd_data_addr,
    output                                    rd_data_en,
    output                                    rd_data_end,
    output        [DATA_BUF_OFFSET_WIDTH-1:0] rd_data_offset,
 output  reg   [DATA_BUF_ADDR_WIDTH-1:0]   wr_data_addr ,
    output  reg                               wr_data_en,
output  reg   [DATA_BUF_OFFSET_WIDTH-1:0] wr_data_offset ,
    output                                    mc_read_idle,
    output                                    mc_ref_zq_wip,
    input                                     correct_en,   
    input         [2*nCK_PER_CLK-1:0]         raw_not_ecc,
    input	  [DQS_WIDTH - 1:0]	      fi_xor_we,
    input	  [DQ_WIDTH -1 :0 ]	      fi_xor_wrdata,
    output        [MC_ERR_ADDR_WIDTH-1:0]     ecc_err_addr,
    output        [2*nCK_PER_CLK-1:0]         ecc_single,
    output        [2*nCK_PER_CLK-1:0]         ecc_multiple,
    input                                     app_periodic_rd_req,
    input                                     app_ref_req,
    input                                     app_zq_req,
    input                                     app_sr_req,
    output                                    app_sr_active,
    output                                    app_ref_ack,
    output                                    app_zq_ack,
    output reg  [nCK_PER_CLK-1:0]             mc_ras_n,
    output reg  [nCK_PER_CLK-1:0]             mc_cas_n,
    output reg  [nCK_PER_CLK-1:0]             mc_we_n,
    output reg  [nCK_PER_CLK*ROW_WIDTH-1:0]   mc_address,
    output reg  [nCK_PER_CLK*BANK_WIDTH-1:0]  mc_bank,
    output reg  [CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK-1:0] mc_cs_n,
    output reg  [1:0]                         mc_odt,
    output reg  [nCK_PER_CLK-1:0]             mc_cke,
    output wire                               mc_reset_n,
    output wire [2*nCK_PER_CLK*DQ_WIDTH-1:0]  mc_wrdata,
    output wire [2*nCK_PER_CLK*DQ_WIDTH/8-1:0]mc_wrdata_mask,
    output reg                                mc_wrdata_en,
    output wire                               mc_cmd_wren,
    output wire                               mc_ctl_wren,
    output reg  [2:0]                         mc_cmd,
    output reg  [5:0]                         mc_data_offset,
    output reg  [5:0]                         mc_data_offset_1,
    output reg  [5:0]                         mc_data_offset_2,
    output reg  [1:0]                         mc_cas_slot,
    output reg  [3:0]                         mc_aux_out0,
    output reg  [3:0]                         mc_aux_out1,
    output reg  [1:0]                         mc_rank_cnt,
    input                                     phy_mc_ctl_full,
    input                                     phy_mc_cmd_full,
    input                                     phy_mc_data_full,
    input       [2*nCK_PER_CLK*DQ_WIDTH-1:0]  phy_rd_data,
    input                                     phy_rddata_valid,
    input                                     init_calib_complete,
    input [6*RANKS-1:0]                       calib_rd_data_offset,
    input [6*RANKS-1:0]                       calib_rd_data_offset_1,
    input [6*RANKS-1:0]                       calib_rd_data_offset_2
  );
  assign mc_reset_n = 1'b1;   
  assign mc_cmd_wren = 1'b1;  
  assign mc_ctl_wren = 1'b1;  
  `ifdef MC_SVA
    ranks_present: assert property
      (@(posedge clk) (rst || (|(slot_0_present | slot_1_present))));
  `endif
  localparam nPHY_WRLAT = 2;
  localparam DELAY_WR_DATA_CNTRL = ECC == "ON" ? 0 : 1;
  localparam EARLY_WR_DATA_ADDR = "OFF";
  localparam nCKE = cdiv(tCKE, tCK);
  localparam nRP = cdiv(tRP, tCK);
  localparam nRCD = cdiv(tRCD, tCK);
  localparam nRAS = cdiv(tRAS, tCK);
  localparam nFAW = cdiv(tFAW, tCK);
  localparam nRFC = cdiv(tRFC, tCK);
  localparam nWR_CK = cdiv(15000, tCK) ;
  localparam nWR = (nWR_CK == 9) ? 10 : (nWR_CK == 11) ? 12 : nWR_CK;
  localparam nRRD_CK = cdiv(tRRD, tCK);
  localparam nRRD = (DRAM_TYPE == "DDR3") ? (nRRD_CK < 4) ? 4 : nRRD_CK
                                          : (nRRD_CK < 2) ? 2 : nRRD_CK;
  localparam nWTR_CK = cdiv(tWTR, tCK);
  localparam nWTR = (DRAM_TYPE == "DDR3") ? (nWTR_CK < 4) ? 4 : nWTR_CK
                                          : (nWTR_CK < 2) ? 2 : nWTR_CK;
  localparam nRTP_CK = cdiv(tRTP, tCK);
  localparam nRTP = (DRAM_TYPE == "DDR3") ? (nRTP_CK < 4) ? 4 : nRTP_CK
                                          : (nRTP_CK < 2) ? 2 : nRTP_CK;
  localparam CWL_M = (REG_CTRL == "ON") ? CWL + 1 : CWL;
  localparam CL_M = (REG_CTRL == "ON") ? CL + 1 : CL;
  localparam DQRD2DQWR_DLY = 4;
  localparam nCKESR = nCKE + 1;
  localparam tXSDLL = 512;
  localparam MAINT_PRESCALER_DIV = MAINT_PRESCALER_PERIOD / (tCK*nCK_PER_CLK);
  localparam REFRESH_TIMER_DIV =
    USER_REFRESH == "ON" ? 0 :
    (tREFI-((tRCD+((CL+4)*tCK)+tRP)*nBANK_MACHS)) / MAINT_PRESCALER_PERIOD;
  localparam PERIODIC_RD_TIMER_DIV = tPRDI / MAINT_PRESCALER_PERIOD;
  localparam MAINT_PRESCALER_PERIOD_NS = MAINT_PRESCALER_PERIOD / 1000;
  localparam ZQ_TIMER_DIV = tZQI / MAINT_PRESCALER_PERIOD_NS;
  localparam RANK_BM_BV_WIDTH = nBANK_MACHS * RANKS;
  localparam EVEN_CWL_2T_MODE =
    ((ADDR_CMD_MODE == "2T") && (!(CWL % 2))) ? "ON" : "OFF";
  localparam nOP_WAIT                 = 0;  
  localparam LOW_IDLE_CNT             = 0;  
  wire [RANK_BM_BV_WIDTH-1:0]       act_this_rank_r;
  wire [ROW_WIDTH-1:0]              col_a;
  wire [BANK_WIDTH-1:0]             col_ba;
  wire [DATA_BUF_ADDR_WIDTH-1:0]    col_data_buf_addr;
  wire                              col_periodic_rd;
  wire [RANK_WIDTH-1:0]             col_ra;
  wire                              col_rmw;
  wire                              col_rd_wr;
  wire [ROW_WIDTH-1:0]              col_row;
  wire                              col_size;
  wire [DATA_BUF_ADDR_WIDTH-1:0]    col_wr_data_buf_addr;
  wire                              dq_busy_data;
  wire                              ecc_status_valid;
  wire [RANKS-1:0]                  inhbt_act_faw_r;
  wire [RANKS-1:0]                  inhbt_rd;
  wire [RANKS-1:0]                  inhbt_wr;
  wire                              insert_maint_r1;
  wire [RANK_WIDTH-1:0]             maint_rank_r;
  wire                              maint_req_r;
  wire                              maint_wip_r;
  wire                              maint_zq_r;
  wire                              maint_sre_r;
  wire                              maint_srx_r;
  wire                              periodic_rd_ack_r;
  wire                              periodic_rd_r;
  wire [RANK_WIDTH-1:0]             periodic_rd_rank_r;
  wire [(RANKS*nBANK_MACHS)-1:0]    rank_busy_r;
  wire                              rd_rmw;
  wire [RANK_BM_BV_WIDTH-1:0]       rd_this_rank_r;
  wire [nBANK_MACHS-1:0]            sending_col;
  wire [nBANK_MACHS-1:0]            sending_row;
  wire                              sent_col;
  wire                              sent_col_r;
  wire                              wr_ecc_buf;
  wire [RANK_BM_BV_WIDTH-1:0]       wr_this_rank_r;
  wire [nCK_PER_CLK-1:0]              mc_ras_n_ns;
  wire [nCK_PER_CLK-1:0]              mc_cas_n_ns;
  wire [nCK_PER_CLK-1:0]              mc_we_n_ns;
  wire [nCK_PER_CLK*ROW_WIDTH-1:0]    mc_address_ns;
  wire [nCK_PER_CLK*BANK_WIDTH-1:0]   mc_bank_ns;
  wire [CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK-1:0] mc_cs_n_ns;
  wire [1:0]                          mc_odt_ns;
  wire [nCK_PER_CLK-1:0]              mc_cke_ns;
  wire [3:0]                          mc_aux_out0_ns;
  wire [3:0]                          mc_aux_out1_ns;
  wire [1:0]                          mc_rank_cnt_ns = col_ra;
  wire [2:0]                          mc_cmd_ns;
  wire [5:0]                          mc_data_offset_ns;
  wire [5:0]                          mc_data_offset_1_ns;
  wire [5:0]                          mc_data_offset_2_ns;
  wire [1:0]                          mc_cas_slot_ns;
  wire                                mc_wrdata_en_ns;
  wire [DATA_BUF_ADDR_WIDTH-1:0]    wr_data_addr_ns;
  wire                              wr_data_en_ns;
  wire [DATA_BUF_OFFSET_WIDTH-1:0]  wr_data_offset_ns;
  integer                           i;
  wire                              col_read_fifo_empty;
  wire                              mc_read_idle_ns;
  reg                               mc_read_idle_r;
  wire                              maint_ref_zq_wip;
  wire                              mc_ref_zq_wip_ns;
  reg                               mc_ref_zq_wip_r;
  function integer cdiv (input integer num, input integer div);
    begin
      cdiv = (num/div) + (((num%div)>0) ? 1 : 0);
    end
  endfunction 
  generate
    if (CMD_PIPE_PLUS1 == "ON") begin : cmd_pipe_plus 
      always @(posedge clk) begin
        mc_address <= #TCQ mc_address_ns;
        mc_bank <= #TCQ mc_bank_ns;
        mc_cas_n <= #TCQ mc_cas_n_ns;
        mc_cs_n <= #TCQ mc_cs_n_ns;
        mc_odt  <= #TCQ mc_odt_ns;
        mc_cke  <= #TCQ mc_cke_ns;
        mc_aux_out0 <= #TCQ mc_aux_out0_ns;
        mc_aux_out1 <= #TCQ mc_aux_out1_ns;
        mc_cmd <= #TCQ mc_cmd_ns;
        mc_ras_n <= #TCQ mc_ras_n_ns;
        mc_we_n <= #TCQ mc_we_n_ns;
        mc_data_offset <= #TCQ mc_data_offset_ns;
        mc_data_offset_1 <= #TCQ mc_data_offset_1_ns;
        mc_data_offset_2 <= #TCQ mc_data_offset_2_ns;
        mc_cas_slot <= #TCQ mc_cas_slot_ns;
        mc_wrdata_en <= #TCQ mc_wrdata_en_ns;
        mc_rank_cnt <= #TCQ mc_rank_cnt_ns;
        wr_data_addr <= #TCQ wr_data_addr_ns;
        wr_data_en <= #TCQ wr_data_en_ns;
        wr_data_offset <= #TCQ wr_data_offset_ns;
      end 
    end 
    else begin : cmd_pipe_plus0 
      always @( mc_address_ns or mc_aux_out0_ns or mc_aux_out1_ns or
                mc_bank_ns or mc_cas_n_ns or mc_cmd_ns or mc_cs_n_ns or
                mc_odt_ns or mc_cke_ns or mc_data_offset_ns or
                mc_data_offset_1_ns or mc_data_offset_2_ns or mc_rank_cnt_ns or
                mc_ras_n_ns or mc_we_n_ns or mc_wrdata_en_ns or 
                wr_data_addr_ns or wr_data_en_ns or wr_data_offset_ns or
                mc_cas_slot_ns)
      begin
        mc_address = #TCQ mc_address_ns;
        mc_bank = #TCQ mc_bank_ns;
        mc_cas_n = #TCQ mc_cas_n_ns;
        mc_cs_n = #TCQ mc_cs_n_ns;
        mc_odt  = #TCQ mc_odt_ns;
        mc_cke  = #TCQ mc_cke_ns;
        mc_aux_out0 = #TCQ mc_aux_out0_ns;
        mc_aux_out1 = #TCQ mc_aux_out1_ns;
        mc_cmd = #TCQ mc_cmd_ns;
        mc_ras_n = #TCQ mc_ras_n_ns;
        mc_we_n = #TCQ mc_we_n_ns;
        mc_data_offset = #TCQ mc_data_offset_ns;
        mc_data_offset_1 = #TCQ mc_data_offset_1_ns;
        mc_data_offset_2 = #TCQ mc_data_offset_2_ns;
        mc_cas_slot = #TCQ mc_cas_slot_ns;
        mc_wrdata_en = #TCQ mc_wrdata_en_ns;
        mc_rank_cnt = #TCQ mc_rank_cnt_ns;
        wr_data_addr = #TCQ wr_data_addr_ns;
        wr_data_en = #TCQ wr_data_en_ns;
        wr_data_offset = #TCQ wr_data_offset_ns;
      end 
    end 
  endgenerate
  assign mc_read_idle_ns = col_read_fifo_empty & init_calib_complete;
  always @(posedge clk) mc_read_idle_r <= #TCQ mc_read_idle_ns;
  assign mc_read_idle = mc_read_idle_r;
  assign mc_ref_zq_wip_ns = maint_ref_zq_wip && col_read_fifo_empty;
  always @(posedge clk) mc_ref_zq_wip_r <= mc_ref_zq_wip_ns;
  assign mc_ref_zq_wip = mc_ref_zq_wip_r;
  mig_7series_v2_0_rank_mach #
    (
      .BURST_MODE             (BURST_MODE),
      .CL                     (CL),
      .CWL                    (CWL),
      .CS_WIDTH               (CS_WIDTH),
      .DQRD2DQWR_DLY          (DQRD2DQWR_DLY),
      .DRAM_TYPE              (DRAM_TYPE),
      .MAINT_PRESCALER_DIV    (MAINT_PRESCALER_DIV),
      .nBANK_MACHS            (nBANK_MACHS),
      .nCKESR                 (nCKESR),
      .nCK_PER_CLK            (nCK_PER_CLK),
      .nFAW                   (nFAW),
      .nREFRESH_BANK          (nREFRESH_BANK),
      .nRRD                   (nRRD),
      .nWTR                   (nWTR),
      .PERIODIC_RD_TIMER_DIV  (PERIODIC_RD_TIMER_DIV),
      .RANK_BM_BV_WIDTH       (RANK_BM_BV_WIDTH),
      .RANK_WIDTH             (RANK_WIDTH),
      .RANKS                  (RANKS),
      .REFRESH_TIMER_DIV      (REFRESH_TIMER_DIV),
      .ZQ_TIMER_DIV           (ZQ_TIMER_DIV)
    )
    rank_mach0
      (
        .inhbt_act_faw_r      (inhbt_act_faw_r[RANKS-1:0]),
        .inhbt_rd             (inhbt_rd[RANKS-1:0]),
        .inhbt_wr             (inhbt_wr[RANKS-1:0]),
        .maint_rank_r         (maint_rank_r[RANK_WIDTH-1:0]),
        .maint_req_r          (maint_req_r),
        .maint_zq_r           (maint_zq_r),
        .maint_sre_r          (maint_sre_r),
        .maint_srx_r          (maint_srx_r),
        .maint_ref_zq_wip     (maint_ref_zq_wip),
        .periodic_rd_r        (periodic_rd_r),
        .periodic_rd_rank_r   (periodic_rd_rank_r[RANK_WIDTH-1:0]),
        .act_this_rank_r      (act_this_rank_r[RANK_BM_BV_WIDTH-1:0]),
        .app_periodic_rd_req  (app_periodic_rd_req),
        .app_ref_req          (app_ref_req),
        .app_ref_ack          (app_ref_ack),
        .app_zq_req           (app_zq_req),
        .app_zq_ack           (app_zq_ack),
        .app_sr_req           (app_sr_req),
        .app_sr_active        (app_sr_active),
        .col_rd_wr            (col_rd_wr),
        .clk                  (clk),
        .init_calib_complete  (init_calib_complete),
        .insert_maint_r1      (insert_maint_r1),
        .maint_wip_r          (maint_wip_r),
        .periodic_rd_ack_r    (periodic_rd_ack_r),
        .rank_busy_r          (rank_busy_r[(RANKS*nBANK_MACHS)-1:0]),
        .rd_this_rank_r       (rd_this_rank_r[RANK_BM_BV_WIDTH-1:0]),
        .rst                  (rst),
        .sending_col          (sending_col[nBANK_MACHS-1:0]),
        .sending_row          (sending_row[nBANK_MACHS-1:0]),
        .slot_0_present       (slot_0_present[7:0]),
        .slot_1_present       (slot_1_present[7:0]),
        .wr_this_rank_r       (wr_this_rank_r[RANK_BM_BV_WIDTH-1:0])
      );
  mig_7series_v2_0_bank_mach #
    (
      .TCQ                     (TCQ),
      .EVEN_CWL_2T_MODE        (EVEN_CWL_2T_MODE),
      .ADDR_CMD_MODE           (ADDR_CMD_MODE),
      .BANK_WIDTH              (BANK_WIDTH),
      .BM_CNT_WIDTH            (BM_CNT_WIDTH),
      .BURST_MODE              (BURST_MODE),
      .COL_WIDTH               (COL_WIDTH),
      .CS_WIDTH                (CS_WIDTH),
      .CL                      (CL_M),
      .CWL                     (CWL_M),
      .CKE_ODT_AUX             (CKE_ODT_AUX),
      .DATA_BUF_ADDR_WIDTH     (DATA_BUF_ADDR_WIDTH),
      .DRAM_TYPE               (DRAM_TYPE),
      .EARLY_WR_DATA_ADDR      (EARLY_WR_DATA_ADDR),
      .ECC                     (ECC),
      .LOW_IDLE_CNT            (LOW_IDLE_CNT),
      .nBANK_MACHS             (nBANK_MACHS),
      .nCK_PER_CLK             (nCK_PER_CLK),
      .nCS_PER_RANK            (nCS_PER_RANK),
      .nOP_WAIT                (nOP_WAIT),
      .nRAS                    (nRAS),
      .nRCD                    (nRCD),
      .nRFC                    (nRFC),
      .nRP                     (nRP),
      .nRTP                    (nRTP),
      .nSLOTS                  (nSLOTS),
      .nWR                     (nWR),
      .nXSDLL                  (tXSDLL),
      .ORDERING                (ORDERING),
      .RANK_BM_BV_WIDTH        (RANK_BM_BV_WIDTH),
      .RANK_WIDTH              (RANK_WIDTH),
      .RANKS                   (RANKS),
      .ROW_WIDTH               (ROW_WIDTH),
      .RTT_NOM                 (RTT_NOM),
      .RTT_WR                  (RTT_WR),
      .SLOT_0_CONFIG           (SLOT_0_CONFIG),
      .SLOT_1_CONFIG           (SLOT_1_CONFIG),
      .STARVE_LIMIT            (STARVE_LIMIT),
      .tZQCS                   (tZQCS)
    )
    bank_mach0
      (
        .accept                (accept),
        .accept_ns             (accept_ns),
        .act_this_rank_r       (act_this_rank_r[RANK_BM_BV_WIDTH-1:0]),
        .bank_mach_next        (bank_mach_next[BM_CNT_WIDTH-1:0]),
        .col_a                 (col_a[ROW_WIDTH-1:0]),
        .col_ba                (col_ba[BANK_WIDTH-1:0]),
        .col_data_buf_addr     (col_data_buf_addr[DATA_BUF_ADDR_WIDTH-1:0]),
        .col_periodic_rd       (col_periodic_rd),
        .col_ra                (col_ra[RANK_WIDTH-1:0]),
        .col_rmw               (col_rmw),
        .col_rd_wr             (col_rd_wr),
        .col_row               (col_row[ROW_WIDTH-1:0]),
        .col_size              (col_size),
        .col_wr_data_buf_addr  (col_wr_data_buf_addr[DATA_BUF_ADDR_WIDTH-1:0]),
        .mc_bank               (mc_bank_ns),
        .mc_address            (mc_address_ns),
        .mc_ras_n              (mc_ras_n_ns),
        .mc_cas_n              (mc_cas_n_ns),
        .mc_we_n               (mc_we_n_ns),
        .mc_cs_n               (mc_cs_n_ns),
        .mc_odt                (mc_odt_ns),
        .mc_cke                (mc_cke_ns),
        .mc_aux_out0           (mc_aux_out0_ns),
        .mc_aux_out1           (mc_aux_out1_ns),
        .mc_cmd                (mc_cmd_ns),
        .mc_data_offset        (mc_data_offset_ns),
        .mc_data_offset_1      (mc_data_offset_1_ns),
        .mc_data_offset_2      (mc_data_offset_2_ns),
        .mc_cas_slot           (mc_cas_slot_ns),
        .insert_maint_r1       (insert_maint_r1),
        .maint_wip_r           (maint_wip_r),
        .periodic_rd_ack_r     (periodic_rd_ack_r),
        .rank_busy_r           (rank_busy_r[(RANKS*nBANK_MACHS)-1:0]),
        .rd_this_rank_r        (rd_this_rank_r[RANK_BM_BV_WIDTH-1:0]),
        .sending_row           (sending_row[nBANK_MACHS-1:0]),
        .sending_col           (sending_col[nBANK_MACHS-1:0]),
        .sent_col              (sent_col),
        .sent_col_r            (sent_col_r),
        .wr_this_rank_r        (wr_this_rank_r[RANK_BM_BV_WIDTH-1:0]),
        .bank                  (bank[BANK_WIDTH-1:0]),
        .calib_rddata_offset   (calib_rd_data_offset),
        .calib_rddata_offset_1 (calib_rd_data_offset_1),
        .calib_rddata_offset_2 (calib_rd_data_offset_2),
        .clk                   (clk),
        .cmd                   (cmd[2:0]),
        .col                   (col[COL_WIDTH-1:0]),
        .data_buf_addr         (data_buf_addr[DATA_BUF_ADDR_WIDTH-1:0]),
        .init_calib_complete   (init_calib_complete),
        .phy_rddata_valid      (phy_rddata_valid),
        .dq_busy_data          (dq_busy_data),
        .hi_priority           (hi_priority),
        .inhbt_act_faw_r       (inhbt_act_faw_r[RANKS-1:0]),
        .inhbt_rd              (inhbt_rd[RANKS-1:0]),
        .inhbt_wr              (inhbt_wr[RANKS-1:0]),
        .maint_rank_r          (maint_rank_r[RANK_WIDTH-1:0]),
        .maint_req_r           (maint_req_r),
        .maint_zq_r            (maint_zq_r),
        .maint_sre_r           (maint_sre_r),
        .maint_srx_r           (maint_srx_r),
        .periodic_rd_r         (periodic_rd_r),
        .periodic_rd_rank_r    (periodic_rd_rank_r[RANK_WIDTH-1:0]),
        .phy_mc_cmd_full       (phy_mc_cmd_full),
        .phy_mc_ctl_full       (phy_mc_ctl_full),
        .phy_mc_data_full      (phy_mc_data_full),
        .rank                  (rank[RANK_WIDTH-1:0]),
        .rd_data_addr          (rd_data_addr[DATA_BUF_ADDR_WIDTH-1:0]),
        .rd_rmw                (rd_rmw),
        .row                   (row[ROW_WIDTH-1:0]),
        .rst                   (rst),
        .size                  (size),
        .slot_0_present        (slot_0_present[7:0]),
        .slot_1_present        (slot_1_present[7:0]),
        .use_addr              (use_addr)
      );
  mig_7series_v2_0_col_mach #
    (
      .TCQ                     (TCQ),
      .BANK_WIDTH              (BANK_WIDTH),
      .BURST_MODE              (BURST_MODE),
      .COL_WIDTH               (COL_WIDTH),
      .CS_WIDTH                (CS_WIDTH),
      .DATA_BUF_ADDR_WIDTH     (DATA_BUF_ADDR_WIDTH),
      .DATA_BUF_OFFSET_WIDTH   (DATA_BUF_OFFSET_WIDTH),
      .DELAY_WR_DATA_CNTRL     (DELAY_WR_DATA_CNTRL),
      .DQS_WIDTH               (DQS_WIDTH),
      .DRAM_TYPE               (DRAM_TYPE),
      .EARLY_WR_DATA_ADDR      (EARLY_WR_DATA_ADDR),
      .ECC                     (ECC),
      .MC_ERR_ADDR_WIDTH       (MC_ERR_ADDR_WIDTH),
      .nCK_PER_CLK             (nCK_PER_CLK),
      .nPHY_WRLAT              (nPHY_WRLAT),
      .RANK_WIDTH              (RANK_WIDTH),
      .ROW_WIDTH               (ROW_WIDTH)
    )
    col_mach0
      (
        .mc_wrdata_en         (mc_wrdata_en_ns),
        .dq_busy_data         (dq_busy_data),
        .ecc_err_addr         (ecc_err_addr[MC_ERR_ADDR_WIDTH-1:0]),
        .ecc_status_valid     (ecc_status_valid),
        .rd_data_addr         (rd_data_addr[DATA_BUF_ADDR_WIDTH-1:0]),
        .rd_data_en           (rd_data_en),
        .rd_data_end          (rd_data_end),
        .rd_data_offset       (rd_data_offset),
        .rd_rmw               (rd_rmw),
        .wr_data_addr         (wr_data_addr_ns),
        .wr_data_en           (wr_data_en_ns),
        .wr_data_offset       (wr_data_offset_ns),
        .wr_ecc_buf           (wr_ecc_buf),
        .col_read_fifo_empty  (col_read_fifo_empty),
        .clk                  (clk),
        .rst                  (rst),
        .col_a                (col_a[ROW_WIDTH-1:0]),
        .col_ba               (col_ba[BANK_WIDTH-1:0]),
        .col_data_buf_addr    (col_data_buf_addr[DATA_BUF_ADDR_WIDTH-1:0]),
        .col_periodic_rd      (col_periodic_rd),
        .col_ra               (col_ra[RANK_WIDTH-1:0]),
        .col_rmw              (col_rmw),
        .col_rd_wr            (col_rd_wr),
        .col_row              (col_row[ROW_WIDTH-1:0]),
        .col_size             (col_size),
        .col_wr_data_buf_addr (col_wr_data_buf_addr[DATA_BUF_ADDR_WIDTH-1:0]),
        .phy_rddata_valid     (phy_rddata_valid),
        .sent_col             (EVEN_CWL_2T_MODE == "ON" ? sent_col_r : sent_col)
      );
  localparam CODE_WIDTH = DATA_WIDTH + ECC_WIDTH;
  generate
    if (ECC == "OFF") begin : ecc_off
      assign rd_data = phy_rd_data;
      assign mc_wrdata = wr_data;
      assign mc_wrdata_mask = wr_data_mask;
      assign ecc_single = 4'b0;
      assign ecc_multiple = 4'b0;
    end
    else begin : ecc_on
      wire [CODE_WIDTH*ECC_WIDTH-1:0] h_rows;
      wire [2*nCK_PER_CLK*DATA_WIDTH-1:0] rd_merge_data;
      wire [2*nCK_PER_CLK*DQ_WIDTH-1:0] mc_wrdata_i;
      mig_7series_v2_0_ecc_merge_enc #
        (
          .TCQ                      (TCQ),
          .CODE_WIDTH               (CODE_WIDTH),
          .DATA_BUF_ADDR_WIDTH      (DATA_BUF_ADDR_WIDTH),
          .DATA_WIDTH               (DATA_WIDTH),
          .DQ_WIDTH                 (DQ_WIDTH),
          .ECC_WIDTH                (ECC_WIDTH),
          .PAYLOAD_WIDTH            (PAYLOAD_WIDTH),
          .nCK_PER_CLK              (nCK_PER_CLK)
        )
        ecc_merge_enc0
          (
            .mc_wrdata              (mc_wrdata_i),
            .mc_wrdata_mask         (mc_wrdata_mask),
            .clk                    (clk),
            .rst                    (rst),
            .h_rows                 (h_rows),
            .rd_merge_data          (rd_merge_data),
            .raw_not_ecc            (raw_not_ecc),
            .wr_data                (wr_data),
            .wr_data_mask           (wr_data_mask)
          );
      mig_7series_v2_0_ecc_dec_fix #
        (
          .TCQ                      (TCQ),
          .CODE_WIDTH               (CODE_WIDTH), 
          .DATA_WIDTH               (DATA_WIDTH),
          .DQ_WIDTH                 (DQ_WIDTH),
          .ECC_WIDTH                (ECC_WIDTH),
          .PAYLOAD_WIDTH            (PAYLOAD_WIDTH),
          .nCK_PER_CLK              (nCK_PER_CLK)
        )
        ecc_dec_fix0
          (
            .ecc_multiple           (ecc_multiple), 
            .ecc_single             (ecc_single),
            .rd_data                (rd_data),
            .clk                    (clk),
            .rst                    (rst),
            .correct_en             (correct_en),
            .phy_rddata             (phy_rd_data),          
            .ecc_status_valid       (ecc_status_valid),
            .h_rows                 (h_rows)
          );
      mig_7series_v2_0_ecc_buf #
        (
          .TCQ                      (TCQ),
          .DATA_BUF_ADDR_WIDTH      (DATA_BUF_ADDR_WIDTH),
          .DATA_BUF_OFFSET_WIDTH    (DATA_BUF_OFFSET_WIDTH),
          .DATA_WIDTH               (DATA_WIDTH),
          .PAYLOAD_WIDTH            (PAYLOAD_WIDTH),
          .nCK_PER_CLK              (nCK_PER_CLK)
        )
        ecc_buf0
          (           
            .rd_merge_data          (rd_merge_data),
            .clk                    (clk),
            .rst                    (rst),
            .rd_data                (rd_data),
            .rd_data_addr           (rd_data_addr),
            .rd_data_offset         (rd_data_offset),
            .wr_data_addr           (wr_data_addr),
            .wr_data_offset         (wr_data_offset),
            .wr_ecc_buf             (wr_ecc_buf)
          );
      mig_7series_v2_0_ecc_gen #
        (
          .CODE_WIDTH               (CODE_WIDTH),
          .DATA_WIDTH               (DATA_WIDTH),
          .ECC_WIDTH                (ECC_WIDTH)
        )
        ecc_gen0
          (
            .h_rows                 (h_rows)
          );
      if (ECC == "ON") begin : gen_fi_xor_inst
        reg mc_wrdata_en_r; 
        wire mc_wrdata_en_i;
        always @(posedge clk) begin
          mc_wrdata_en_r <= mc_wrdata_en;
        end
        assign mc_wrdata_en_i = mc_wrdata_en_r;
        mig_7series_v2_0_fi_xor #(
          .DQ_WIDTH (DQ_WIDTH),
          .DQS_WIDTH (DQS_WIDTH),
          .nCK_PER_CLK (nCK_PER_CLK)
        )
        fi_xor0
        (
          .clk (clk),
          .wrdata_in (mc_wrdata_i),
          .wrdata_out (mc_wrdata),
          .wrdata_en (mc_wrdata_en_i),
          .fi_xor_we (fi_xor_we),
          .fi_xor_wrdata (fi_xor_wrdata)
        );
     end
     else begin : gen_wrdata_passthru
       assign mc_wrdata = mc_wrdata_i;
     end
  `ifdef DISPLAY_H_MATRIX
    integer i;
      always @(negedge rst) begin
        $display ("**********************************************");
        $display ("H Matrix:");
        for (i=0; i<ECC_WIDTH; i=i+1)
          $display ("%b", h_rows[i*CODE_WIDTH+:CODE_WIDTH]);
       $display ("**********************************************");
      end
  `endif
    end
  endgenerate
endmodule 
