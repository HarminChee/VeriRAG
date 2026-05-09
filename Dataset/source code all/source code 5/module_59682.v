`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif
`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif
module pcie_blk_plus_ll_tx #
  ( parameter   TX_CPL_STALL_THRESHOLD   = 6,
    parameter   TX_DATACREDIT_FIX_EN     = 1,
    parameter   TX_DATACREDIT_FIX_1DWONLY= 1,
    parameter   TX_DATACREDIT_FIX_MARGIN = 6,
    parameter   MPS = 0,
    parameter   LEGACY_EP = 1'b0             
  )
  (
   input             clk,
   input             rst_n,
   input             trn_lnk_up_n,
   output [63:0]     llk_tx_data,
   output            llk_tx_src_rdy_n,
   output            llk_tx_src_dsc_n,
   output            llk_tx_sof_n,
   output            llk_tx_eof_n,
   output            llk_tx_sop_n,
   output            llk_tx_eop_n,
   output [1:0]      llk_tx_enable_n,
   output [2:0]      llk_tx_ch_tc,
   output [1:0]      llk_tx_ch_fifo,
   input             llk_tx_dst_rdy_n,
   input [9:0]       llk_tx_chan_space,            
   input [7:0]       llk_tx_ch_posted_ready_n,     
   input [7:0]       llk_tx_ch_non_posted_ready_n, 
   input [7:0]       llk_tx_ch_completion_ready_n, 
   input [63:0]      trn_td,
   input [7:0]       trn_trem_n,
   input             trn_tsof_n,
   input             trn_teof_n,
   input             trn_tsrc_rdy_n,
   input             trn_tsrc_dsc_n,    
   input             trn_terrfwd_n,     
   output            trn_tdst_rdy_n,
   output            trn_tdst_dsc_n,
   output reg [3:0]  trn_tbuf_av,
   input [63:0]      cfg_tx_td,
   input             cfg_tx_rem_n,
   input             cfg_tx_sof_n,
   input             cfg_tx_eof_n,
   input             cfg_tx_src_rdy_n,
   output            cfg_tx_dst_rdy_n,
   output reg         tx_err_wr_ep_n = 1'b1,
   input  wire  [7:0] tx_ch_credits_consumed,
   input  wire [11:0] tx_pd_credits_available,
   input  wire [11:0] tx_pd_credits_consumed,
   input  wire [11:0] tx_npd_credits_available,
   input  wire [11:0] tx_npd_credits_consumed,
   input  wire [11:0] tx_cd_credits_available,
   input  wire [11:0] tx_cd_credits_consumed,
   input  wire        pd_credit_limited,
   input  wire        npd_credit_limited,
   input  wire        cd_credit_limited,
   output wire        clear_cpl_count,
   input  wire  [7:0] trn_pfc_cplh_cl,
   input  wire        trn_pfc_cplh_cl_upd,
   input  wire        l0_stats_cfg_transmitted
   );
   wire [63:0] tx_td;
   wire        tx_sof_n;
   wire        tx_eof_n;
   wire [7:0]  tx_rem_n;
   wire        tx_src_dsc_n;
   wire        tx_src_rdy_n;
   wire        tx_dst_rdy_n;
   reg  [2:0]  trn_tbuf_av_int;
  pcie_blk_ll_tx_arb tx_arb
    (
     .clk( clk ),                                                    
     .rst_n( rst_n ),                                                
     .tx_td( tx_td ),                                                
     .tx_sof_n( tx_sof_n ),                                          
     .tx_eof_n( tx_eof_n ),                                          
     .tx_rem_n( tx_rem_n ),                                          
     .tx_src_dsc_n( tx_src_dsc_n ),                                  
     .tx_src_rdy_n( tx_src_rdy_n ),                                  
     .tx_dst_rdy_n( tx_dst_rdy_n ),                                  
     .trn_td( trn_td ),                                              
     .trn_trem_n( trn_trem_n ),                                      
     .trn_tsof_n( trn_tsof_n ),                                      
     .trn_teof_n( trn_teof_n ),                                      
     .trn_tsrc_rdy_n( trn_tsrc_rdy_n ),                              
     .trn_tsrc_dsc_n( trn_tsrc_dsc_n ),                              
     .trn_tdst_rdy_n( trn_tdst_rdy_n ),                              
     .trn_tdst_dsc_n( trn_tdst_dsc_n ),                              
     .cfg_tx_td( cfg_tx_td ),                                        
     .cfg_tx_rem_n( cfg_tx_rem_n ),                                  
     .cfg_tx_sof_n( cfg_tx_sof_n ),                                  
     .cfg_tx_eof_n( cfg_tx_eof_n ),                                  
     .cfg_tx_src_rdy_n( cfg_tx_src_rdy_n ),                          
     .cfg_tx_dst_rdy_n( cfg_tx_dst_rdy_n )                           
     );
  always @(posedge clk) begin
    tx_err_wr_ep_n  <= #`TCQ !(!tx_sof_n && !tx_src_rdy_n &&
                               !tx_dst_rdy_n && tx_td[46]);
  end
  pcie_blk_ll_tx #
    ( .TX_CPL_STALL_THRESHOLD   ( TX_CPL_STALL_THRESHOLD ),
      .TX_DATACREDIT_FIX_EN     ( TX_DATACREDIT_FIX_EN ),
      .TX_DATACREDIT_FIX_1DWONLY( TX_DATACREDIT_FIX_1DWONLY ),
      .TX_DATACREDIT_FIX_MARGIN ( TX_DATACREDIT_FIX_MARGIN ),
      .MPS                      ( MPS ),
      .LEGACY_EP                ( LEGACY_EP )
    )
  tx_bridge
    (
     .clk( clk ),                                                    
     .rst_n( rst_n ),                                                
     .trn_lnk_up_n (trn_lnk_up_n),                                   
     .llk_tx_data( llk_tx_data ),                                    
     .llk_tx_src_rdy_n( llk_tx_src_rdy_n ),                          
     .llk_tx_src_dsc_n( llk_tx_src_dsc_n ),                          
     .llk_tx_sof_n( llk_tx_sof_n ),                                  
     .llk_tx_eof_n( llk_tx_eof_n ),                                  
     .llk_tx_sop_n( llk_tx_sop_n ),                                  
     .llk_tx_eop_n( llk_tx_eop_n ),                                  
     .llk_tx_enable_n( llk_tx_enable_n ),                            
     .llk_tx_ch_tc( llk_tx_ch_tc ),                                  
     .llk_tx_ch_fifo( llk_tx_ch_fifo ),                              
     .llk_tx_dst_rdy_n( llk_tx_dst_rdy_n ),                          
     .llk_tx_chan_space( llk_tx_chan_space ),                        
     .llk_tx_ch_posted_ready_n( llk_tx_ch_posted_ready_n ),          
     .llk_tx_ch_non_posted_ready_n( llk_tx_ch_non_posted_ready_n ),  
     .llk_tx_ch_completion_ready_n( llk_tx_ch_completion_ready_n ),  
     .trn_td( tx_td ),                                               
     .trn_trem_n( tx_rem_n ),                                        
     .trn_tsof_n( tx_sof_n ),                                        
     .trn_teof_n( tx_eof_n ),                                        
     .trn_tsrc_rdy_n( tx_src_rdy_n ),                                
     .trn_tsrc_dsc_n( tx_src_dsc_n ),                                
     .trn_terrfwd_n( 1'b1 ), 
     .trn_tdst_rdy_n( tx_dst_rdy_n ),                                
     .trn_tdst_dsc_n( tx_dst_dsc_n ),                                
     .trn_tbuf_av_cpl( trn_tbuf_av_cpl ),
     .tx_ch_credits_consumed   ( tx_ch_credits_consumed ),
     .tx_pd_credits_available  ( tx_pd_credits_available ),
     .tx_pd_credits_consumed   ( tx_pd_credits_consumed ),
     .tx_npd_credits_available ( tx_npd_credits_available ),
     .tx_npd_credits_consumed  ( tx_npd_credits_consumed ),
     .tx_cd_credits_available  ( tx_cd_credits_available ),
     .tx_cd_credits_consumed   ( tx_cd_credits_consumed ),
     .clear_cpl_count          ( clear_cpl_count ),
     .pd_credit_limited        ( pd_credit_limited ),
     .npd_credit_limited       ( npd_credit_limited ),
     .cd_credit_limited        ( cd_credit_limited ),
     .trn_pfc_cplh_cl          ( trn_pfc_cplh_cl ),
     .trn_pfc_cplh_cl_upd      ( trn_pfc_cplh_cl_upd ),
     .l0_stats_cfg_transmitted ( l0_stats_cfg_transmitted )
    );
  always @(posedge clk) begin
    if (!rst_n) begin
      trn_tbuf_av_int    <= #`TCQ 3'b000;
    end else begin
      trn_tbuf_av_int[0] <= &(~llk_tx_ch_non_posted_ready_n);
      trn_tbuf_av_int[1] <= &(~llk_tx_ch_posted_ready_n);
      trn_tbuf_av_int[2] <= &(~llk_tx_ch_completion_ready_n);
    end
  end
  always @* begin
     trn_tbuf_av[2:0] = trn_tbuf_av_int[2:0];
     trn_tbuf_av[3]   = trn_tbuf_av_cpl;
  end
endmodule 
