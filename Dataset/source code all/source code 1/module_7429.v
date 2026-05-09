module mig_7series_v2_0_axi4_wrapper #(
   parameter C_AXI_ID_WIDTH       = 4, 
   parameter C_AXI_ADDR_WIDTH     = 32, 
   parameter C_AXI_DATA_WIDTH     = 32, 
   parameter C_AXI_NBURST_SUPPORT = 0, 
   parameter C_BEGIN_ADDRESS      = 0, 
   parameter C_END_ADDRESS        = 32'hFFFF_FFFF, 
   parameter CTL_SIG_WIDTH        = 2, 
   parameter WR_STS_WIDTH         = 16, 
   parameter RD_STS_WIDTH         = 16,  
   parameter EN_UPSIZER           = 0, 
   parameter WDG_TIMER_WIDTH      = 9
)
(
   input                               aclk, 
   input                               aresetn, 
   input                               cmd_en, 
   input [2:0]                         cmd,    
   input [7:0]                         blen,   
   input [31:0]                        addr,   
   input [CTL_SIG_WIDTH-1:0]           ctl,    
   input                               wdog_mask, 
   output                              cmd_ack,
   input                               wrdata_vld,  
   input [C_AXI_DATA_WIDTH-1:0]        wrdata,      
   input [C_AXI_DATA_WIDTH/8-1:0]      wrdata_bvld, 
   input                               wrdata_cmptd,
   output reg                          wrdata_rdy,  
   output reg                          wrdata_sts_vld, 
   output [WR_STS_WIDTH-1:0]           wrdata_sts,     
   input                               rddata_rdy,   
   output reg                          rddata_vld,   
   output reg [C_AXI_DATA_WIDTH-1:0]   rddata,       
   output [C_AXI_DATA_WIDTH/8-1:0]     rddata_bvld,  
   output reg                          rddata_cmptd, 
   output [RD_STS_WIDTH-1:0]           rddata_sts,   
   input                               axi_wready, 
   output [C_AXI_ID_WIDTH-1:0]         axi_wid,    
   output [C_AXI_ADDR_WIDTH-1:0]       axi_waddr,  
   output [7:0]                        axi_wlen,   
   output [2:0]                        axi_wsize,  
   output [1:0]                        axi_wburst, 
   output [1:0]                        axi_wlock,  
   output [3:0]                        axi_wcache, 
   output [2:0]                        axi_wprot,  
   output reg                          axi_wvalid, 
   input                               axi_wd_wready,  
   output [C_AXI_ID_WIDTH-1:0]         axi_wd_wid,     
   output reg [C_AXI_DATA_WIDTH-1:0]   axi_wd_data,    
   output reg [C_AXI_DATA_WIDTH/8-1:0] axi_wd_strb,    
   output reg                          axi_wd_last,    
   output                              axi_wd_valid,   
   input  [C_AXI_ID_WIDTH-1:0]         axi_wd_bid,     
   input  [1:0]                        axi_wd_bresp,   
   input                               axi_wd_bvalid,  
   output reg                          axi_wd_bready,  
   input                               axi_rready,     
   output [C_AXI_ID_WIDTH-1:0]         axi_rid,        
   output [C_AXI_ADDR_WIDTH-1:0]       axi_raddr,      
   output [7:0]                        axi_rlen,       
   output [2:0]                        axi_rsize,      
   output [1:0]                        axi_rburst,     
   output [1:0]                        axi_rlock,      
   output [3:0]                        axi_rcache,     
   output [2:0]                        axi_rprot,      
   output reg                          axi_rvalid,     
   input  [C_AXI_ID_WIDTH-1:0]         axi_rd_bid,     
   input  [1:0]                        axi_rd_rresp,   
   input                               axi_rd_rvalid,  
   input  [C_AXI_DATA_WIDTH-1:0]       axi_rd_data,    
   input                               axi_rd_last,    
   output reg                          axi_rd_rready   
);
  parameter [8:0]                      AXI_WRIDLE    = 9'd0,
                                       AXI_WRCTL     = 9'd1,
                                       AXI_WRRDY     = 9'd2,
                                       AXI_WRDAT     = 9'd3,
                                       AXI_WRDAT_WT  = 9'd4,
                                       AXI_WRDAT_LST = 9'd5,
                                       AXI_WRDAT_DMY = 9'd6,
                                       AXI_WRRESP_WT = 9'd7,
                                       AXI_WRTO      = 9'd8;
  parameter [5:0]                      AXI_RDIDLE    = 6'd0,
                                       AXI_RDCTL     = 6'd1,
                                       AXI_RDDAT     = 6'd2,
                                       AXI_RDDAT_LST = 6'd3,
                                       AXI_RDDAT_WT  = 6'd4,
                                       AXI_RDTO      = 6'd5;
  reg                                  wrap_w;
  reg [7:0]                            blen_w;
  reg [7:0]                            blen_w_minus_1;
  reg [C_AXI_ADDR_WIDTH-1:0]           addr_w;
  reg [CTL_SIG_WIDTH-1:0]              ctl_w;
  reg                                  wrap_r;
  reg [7:0]                            blen_r;
  reg [C_AXI_ADDR_WIDTH-1:0]           addr_r;
  reg [CTL_SIG_WIDTH-1:0]              ctl_r;
  reg [8:0]                            wstate;
  reg [8:0]                            next_wstate;
  reg                                  wr_cmd_start;
  reg [WDG_TIMER_WIDTH-1:0]            wr_wdog_cntr;
  reg                                  wrdata_vld_r;
  reg                                  wrdata_cmptd_r;
  reg [7:0]                            wr_len_cntr;
  reg [7:0]                            rd_len_cntr;
  reg [7:0]                            blen_cntr;
  reg [3:0]                            wr_cntr;
  reg [C_AXI_DATA_WIDTH-1:0]           wrdata_r1;
  reg [C_AXI_DATA_WIDTH-1:0]           wrdata_r2;
  reg                                  wrdata_mux_ctrl;
  reg [2:0]                            wrdata_fsm_sts;
  reg [3:0]                            brespid_r;
  reg [1:0]                            bresp_r;
  reg [5:0]                            rstate;
  reg [5:0]                            next_rstate;
  reg [WDG_TIMER_WIDTH-1:0]            rd_wdog_cntr;
  reg                                  rd_cmd_start;
  reg                                  rlast;
  reg [3:0]                            rd_cntr;
  reg                                  rddata_ppld;
  reg [C_AXI_DATA_WIDTH-1:0]           rddata_p1;
  reg                                  err_resp;
  reg [1:0]                            rddata_fsm_sts;
  reg                                  rrid_err;
  reg                                  pending_one_trans;
  reg                                  axi_wready_l;
  wire                                 wr_cmd_timeout;
  wire                                 wr_done;
  wire                                 wr_last;
  wire                                 rd_cmd_timeout;
  always @(posedge aclk) begin
    if (!aresetn) begin
      wrap_w <= 1'b0; 
      blen_w <= 8'h0;
      blen_w_minus_1 <= 8'h0;
      addr_w <= {C_AXI_ADDR_WIDTH{1'b0}};
      ctl_w  <= {CTL_SIG_WIDTH{1'b0}};
    end
    else if (wstate[AXI_WRIDLE] & next_wstate[AXI_WRIDLE] & 
        cmd_en & cmd[2]) begin
      wrap_w <= cmd[0]; 
      blen_w <= blen;
      blen_w_minus_1 <= blen - 8'h01;
      addr_w <= addr;
      ctl_w  <= ctl;
    end
  end 
  always @(posedge aclk) begin
    if (!aresetn) begin
      wrap_r <= 1'b0; 
      blen_r <= 8'h0;
      addr_r <= {C_AXI_ADDR_WIDTH{1'b0}};
      ctl_r  <= {CTL_SIG_WIDTH{1'b0}};
    end
    else if (rstate[AXI_RDIDLE] & next_rstate[AXI_RDIDLE] & 
        cmd_en & !cmd[2]) begin
      wrap_r <= cmd[0]; 
      blen_r <= blen;
      addr_r <= addr;
      ctl_r  <= ctl;
    end
  end 
  assign cmd_ack = (wstate[AXI_WRIDLE] & next_wstate[AXI_WRCTL]) |
                   (rstate[AXI_RDIDLE] & next_rstate[AXI_RDCTL]);
  always @(posedge aclk)
    if (!aresetn)
      wr_cmd_start <= 1'b0;
    else if (cmd_en & cmd[2] & wstate[AXI_WRIDLE])
      wr_cmd_start <= 1'b1;
    else if (wstate[AXI_WRCTL])
      wr_cmd_start <= 1'b0;
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE] | 
        (axi_wd_wready & (wstate[AXI_WRDAT] | wstate[AXI_WRDAT_WT] | wstate[AXI_WRDAT_LST] | wstate[AXI_WRDAT_DMY])) |
        (axi_wd_bvalid & wstate[AXI_WRRESP_WT])) 
      wr_wdog_cntr <= 'h0;
    else if (!wstate[AXI_WRTO] & !wdog_mask)
      wr_wdog_cntr <= wr_wdog_cntr + 'h1;
  always @(posedge aclk)
    wrdata_vld_r <= wrdata_vld;
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE])    
      wrdata_cmptd_r <= 1'b0;
    else if (wrdata_cmptd & wrdata_vld)
      wrdata_cmptd_r <= 1'b1;
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE])    
      blen_cntr <= 8'h0; 
    else if (wrdata_vld & wrdata_rdy)
      blen_cntr <= blen_cntr + 8'h01; 
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE])    
      pending_one_trans <= 1'b0; 
    else if (next_wstate[AXI_WRDAT] & wstate[AXI_WRDAT_WT])
      pending_one_trans <= 1'b0; 
    else if (wstate[AXI_WRDAT] & next_wstate[AXI_WRDAT_WT] & wr_last & !axi_wd_wready)
      pending_one_trans <= 1'b1; 
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE])    
      wr_len_cntr <= 8'h0; 
    else if ((wstate[AXI_WRDAT_DMY] | wstate[AXI_WRDAT] | wstate[AXI_WRDAT_WT]) & 
             axi_wd_valid & axi_wd_wready)             
      wr_len_cntr <= wr_len_cntr + 8'h01;
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE])    
      axi_wready_l <= 1'b0; 
    else if (axi_wready)
      axi_wready_l <= 1'b1; 
  assign wr_cmd_timeout = wr_wdog_cntr[WDG_TIMER_WIDTH-1] & !wdog_mask; 
  assign wr_last        = (wr_len_cntr >= blen_w_minus_1);
  assign wr_done        = (blen_cntr >= blen_w);
  always @(posedge aclk) begin
    if (!aresetn)
      wstate <= 9'h1;
    else 
      wstate <= next_wstate;
  end
  always @(*) begin
    next_wstate = 9'h0;
    case (1'b1)
      wstate[AXI_WRIDLE]: begin 
        if (wr_cmd_start)
          next_wstate[AXI_WRCTL] = 1'b1;
        else
          next_wstate[AXI_WRIDLE] = 1'b1;
      end
      wstate[AXI_WRCTL]: begin 
        if (wr_cmd_timeout)
          next_wstate[AXI_WRTO] = 1'b1;
        else if (axi_wvalid)
          next_wstate[AXI_WRRDY] = 1'b1;
        else
          next_wstate[AXI_WRCTL] = 1'b1;
      end 
      wstate[AXI_WRRDY]: begin 
        if (wrdata_cmptd_r & wrdata_rdy)
          next_wstate[AXI_WRDAT_LST] = 1'b1;
        else if (wrdata_vld_r & wrdata_rdy)
          next_wstate[AXI_WRDAT] = 1'b1;
        else
          next_wstate[AXI_WRRDY] = 1'b1;
      end
      wstate[AXI_WRDAT]: begin 
        if (wr_cmd_timeout)
          next_wstate[AXI_WRTO] = 1'b1;
        else if (axi_wd_wready & wrdata_cmptd_r & (wr_last | ~(|blen_w)))
          next_wstate[AXI_WRDAT_LST] = 1'b1;
        else if (axi_wd_wready & wrdata_cmptd_r & !wr_done & 
                 (wr_len_cntr != 8'h00))
          next_wstate[AXI_WRDAT_DMY] = 1'b1;
        else if (!axi_wd_wready)
          next_wstate[AXI_WRDAT_WT] = 1'b1;
        else
          next_wstate[AXI_WRDAT] = 1'b1;
      end
      wstate[AXI_WRDAT_WT]: begin 
        if (wr_cmd_timeout)
          next_wstate[AXI_WRTO] = 1'b1;
        else if (axi_wd_wready) begin
          if (pending_one_trans & wrdata_cmptd_r & (wr_last | ~(|blen_w)))
            next_wstate[AXI_WRDAT_LST] = 1'b1;
          else if (!pending_one_trans & wrdata_cmptd_r & !wr_done & 
                   (wr_len_cntr != 8'h00))
            next_wstate[AXI_WRDAT_DMY] = 1'b1;
          else
            next_wstate[AXI_WRDAT] = 1'b1;
        end
        else
          next_wstate[AXI_WRDAT_WT] = 1'b1;
      end
      wstate[AXI_WRDAT_LST]: begin 
        if (wr_cmd_timeout)
          next_wstate[AXI_WRTO] = 1'b1;
        else if (axi_wd_valid & axi_wd_wready)
          next_wstate[AXI_WRRESP_WT] = 1'b1;
        else
          next_wstate[AXI_WRDAT_LST] = 1'b1;
      end
      wstate[AXI_WRDAT_DMY]: begin 
        if (wr_cmd_timeout)
          next_wstate[AXI_WRTO] = 1'b1;
        else if (wrdata_cmptd_r & wr_last)
          next_wstate[AXI_WRDAT_LST] = 1'b1;
        else if (!wr_last & !axi_wd_wready)
          next_wstate[AXI_WRDAT_WT] = 1'b1;  
        else
          next_wstate[AXI_WRDAT_DMY] = 1'b1;  
      end
      wstate[AXI_WRRESP_WT]: begin 
        if (wr_cmd_timeout)
          next_wstate[AXI_WRTO] = 1'b1;
        else if (axi_wd_bvalid & 
                 (EN_UPSIZER == 1 || (EN_UPSIZER == 0 & axi_wready_l)))
          next_wstate[AXI_WRIDLE] = 1'b1;
        else
          next_wstate[AXI_WRRESP_WT] = 1'b1;
      end
      wstate[AXI_WRTO]: begin 
        next_wstate[AXI_WRIDLE] = 1'b1;
      end
    endcase
  end
  always @(posedge aclk)
    if (!aresetn)
      wr_cntr <= 4'h0;
    else if (wstate[AXI_WRRESP_WT] & next_wstate[AXI_WRIDLE])
      wr_cntr <= wr_cntr + 4'h1;
  always @(posedge aclk)
    if (!aresetn)
      axi_wvalid <= 1'b0;
    else if ((wstate[AXI_WRCTL] & next_wstate[AXI_WRRDY] & axi_wready) ||
             (axi_wready & !wstate[AXI_WRCTL]))
      axi_wvalid <= 1'b0;
    else if (wstate[AXI_WRCTL])
      axi_wvalid <= 1'b1;
  assign awid = wr_cntr;
  assign axi_waddr = addr_w;
  assign axi_wid   = wr_cntr;
  assign axi_wlen  = blen_w;
  assign axi_wburst = {1'b0, wrap_w} + 2'b01;
  assign axi_wsize = ctl_w[2:0];
  assign axi_wlock = 2'b0;
  assign axi_wcache = 4'b0;
  assign axi_wprot = 3'b0;
  always @(posedge aclk) begin
    if (wstate[AXI_WRIDLE]) begin
      wrdata_r1 <= 'h0;
      wrdata_r2 <= 'h0; 
    end
    else if (wrdata_rdy & wrdata_vld & (wstate[AXI_WRDAT] | wstate[AXI_WRRDY] | 
             wstate[AXI_WRDAT_LST])) begin
      wrdata_r1 <= wrdata;
      wrdata_r2 <= wrdata_r1; 
    end 
  end
  always @(posedge aclk)
    if (!aresetn)
      wrdata_rdy <= 1'b0;
    else if (wstate[AXI_WRDAT_LST] | (wstate[AXI_WRDAT] & next_wstate[AXI_WRDAT_WT]))
      wrdata_rdy <= 1'b0;
    else if (wstate[AXI_WRDAT] | 
             (wstate[AXI_WRCTL] & next_wstate[AXI_WRRDY]) |
             (wstate[AXI_WRDAT_WT] & next_wstate[AXI_WRDAT])) 
      wrdata_rdy <= 1'b1;
  always @(posedge aclk)
    if (!aresetn)
      wrdata_sts_vld <= 1'b0;
    else if (wstate[AXI_WRIDLE])
      wrdata_sts_vld <= 1'b0;
    else if ((wstate[AXI_WRRESP_WT] | wstate[AXI_WRTO]) & next_wstate[AXI_WRIDLE])
      wrdata_sts_vld <= 1'b1;
  always @(posedge aclk)
    if (!aresetn)
      wrdata_mux_ctrl <= 1'b0;
    else if ((wstate[AXI_WRDAT_WT] & (next_wstate[AXI_WRDAT] | next_wstate[AXI_WRDAT_LST])) |
             wstate[AXI_WRIDLE])
      wrdata_mux_ctrl <= 1'b0;
    else if (wstate[AXI_WRDAT] & next_wstate[AXI_WRDAT_WT] & !pending_one_trans)
      wrdata_mux_ctrl <= 1'b1;
  always @(posedge aclk)
    if (!aresetn)
      axi_wd_last <= 1'b0;
    else if (wstate[AXI_WRDAT_LST] & next_wstate[AXI_WRRESP_WT])
      axi_wd_last <= 1'b0;
    else if ((wstate[AXI_WRDAT] | wstate[AXI_WRDAT_DMY] | wstate[AXI_WRRDY] | wstate[AXI_WRDAT_WT]) & 
             next_wstate[AXI_WRDAT_LST])
      axi_wd_last <= 1'b1;
  generate 
    begin: data_axi_wr
      if (C_AXI_NBURST_SUPPORT == 1) begin
      end
      else begin
        always @(posedge aclk)
          if (wstate[AXI_WRIDLE])
            axi_wd_data <= 'h0;
          else if (axi_wd_wready & (wstate[AXI_WRDAT] | wstate[AXI_WRDAT_WT]) & wrdata_mux_ctrl &
                   ~next_wstate[AXI_WRDAT_LST])
            axi_wd_data <= wrdata_r2;
          else if ((axi_wd_wready & (wstate[AXI_WRDAT] | 
                                    (wstate[AXI_WRDAT_WT] & next_wstate[AXI_WRDAT_LST]) | 
                                    (wstate[AXI_WRDAT_LST] & !next_wstate[AXI_WRRESP_WT]))) |
                                    (wstate[AXI_WRRDY] & next_wstate[AXI_WRDAT]))
            axi_wd_data <= wrdata_r1;
        always @(posedge aclk)
          if (wstate[AXI_WRIDLE])
            axi_wd_strb <= {(C_AXI_DATA_WIDTH/8){1'b0}};
          else if ((axi_wd_wready & (wstate[AXI_WRDAT] | 
                                    (next_wstate[AXI_WRDAT_LST] & (wstate[AXI_WRRDY] | wstate[AXI_WRDAT])) |
                                    ((wstate[AXI_WRRDY] | wstate[AXI_WRDAT_WT]) & 
                                     next_wstate[AXI_WRDAT]))) | 
                   (next_wstate[AXI_WRDAT_LST] & !axi_wd_wready & 
                    (wstate[AXI_WRDAT] | wstate[AXI_WRDAT_LST] | 
                     wstate[AXI_WRDAT_DMY] | wstate[AXI_WRDAT_WT])) |
                   (wstate[AXI_WRRDY] & next_wstate[AXI_WRDAT]) | 
                   ((wstate[AXI_WRDAT] | wstate[AXI_WRDAT_DMY]) & next_wstate[AXI_WRDAT_WT]) | 
                   (wstate[AXI_WRDAT_WT])) 
            axi_wd_strb <= {(C_AXI_DATA_WIDTH/8){1'b1}};
          else
            axi_wd_strb <= {(C_AXI_DATA_WIDTH/8){1'b0}};
      end
    end
  endgenerate
  assign axi_wd_wid = wr_cntr;
  assign axi_wd_valid = wstate[AXI_WRDAT] | wstate[AXI_WRDAT_LST] | 
                        wstate[AXI_WRDAT_DMY] | wstate[AXI_WRDAT_WT];
  always @(posedge aclk)
    if (!aresetn)
      axi_wd_bready <= 1'b0;
    else if (next_wstate[AXI_WRIDLE] & wstate[AXI_WRRESP_WT])
      axi_wd_bready <= 1'b0;
    else if (wstate[AXI_WRRESP_WT])
      axi_wd_bready <= 1'b1;
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE]) 
      wrdata_fsm_sts <= 3'b000;  
    else begin
      if (next_wstate[AXI_WRTO]) begin
        if (wstate[AXI_WRDAT])
          wrdata_fsm_sts <= 3'b001;
        else if (wstate[AXI_WRDAT_WT])
          wrdata_fsm_sts <= 3'b010;
        else if (wstate[AXI_WRDAT_DMY])
          wrdata_fsm_sts <= 3'b011;
        else if (wstate[AXI_WRRESP_WT])
          wrdata_fsm_sts <= 3'b100;
      end
    end
  always @(posedge aclk)
    if (wstate[AXI_WRIDLE]) begin 
      brespid_r <= 4'h0;  
      bresp_r   <= 2'b00;
    end
    else if (wstate[AXI_WRRESP_WT] & axi_wd_bvalid) begin
      brespid_r <= axi_wd_bid;  
      bresp_r   <= axi_wd_bresp;
    end
  assign wrdata_sts = {{{WR_STS_WIDTH-8}{1'b0}},wrdata_fsm_sts,brespid_r[3:0],bresp_r}; 
  always @(posedge aclk)
    if (rstate[AXI_RDIDLE] | axi_rready | axi_rd_rvalid) 
      rd_wdog_cntr <= 'h0;
    else if (!rstate[AXI_RDTO])
      rd_wdog_cntr <= rd_wdog_cntr + 'h1;
  always @(posedge aclk)
    if (!aresetn)
      rd_cmd_start <= 1'b0;
    else if (cmd_en & !cmd[2] & rstate[AXI_RDIDLE])
      rd_cmd_start <= 1'b1;
    else if (rstate[AXI_RDCTL])
      rd_cmd_start <= 1'b0;
  always @(posedge aclk)
    if (rstate[AXI_RDIDLE])
      rlast <= 1'b0;
    else if (axi_rd_last & axi_rd_rvalid)
      rlast <= 1'b1; 
  assign rd_cmd_timeout = rd_wdog_cntr[WDG_TIMER_WIDTH-1] & !wdog_mask; 
  always @(posedge aclk) begin
    if (!aresetn)
      rstate <= 6'h1;
    else 
      rstate <= next_rstate;
  end
  always @(*) begin
    next_rstate = 6'h0;
    case (1'b1)
      rstate[AXI_RDIDLE]: begin 
        if (rd_cmd_start)
          next_rstate[AXI_RDCTL] = 1'b1;
        else
          next_rstate[AXI_RDIDLE] = 1'b1;
      end
      rstate[AXI_RDCTL]: begin 
        if (rd_cmd_timeout)
          next_rstate[AXI_RDTO] = 1'b1;
        else if (axi_rready & axi_rvalid) begin
          if (rddata_rdy)
            next_rstate[AXI_RDDAT] = 1'b1;
          else
            next_rstate[AXI_RDDAT_WT] = 1'b1;
        end 
        else
          next_rstate[AXI_RDCTL] = 1'b1;
      end
      rstate[AXI_RDDAT]: begin 
        if (rd_cmd_timeout)
          next_rstate[AXI_RDTO] = 1'b1;
        else if (rddata_rdy) begin
          if (rlast)
            next_rstate[AXI_RDDAT_LST] = 1'b1;
          else
            next_rstate[AXI_RDDAT] = 1'b1;
        end
        else
          next_rstate[AXI_RDDAT_WT] = 1'b1;
      end
      rstate[AXI_RDDAT_LST]: begin 
        if (rddata_cmptd & rddata_vld & rddata_rdy)
          next_rstate[AXI_RDIDLE] = 1'b1;
        else      
          next_rstate[AXI_RDDAT_LST] = 1'b1;
      end
      rstate[AXI_RDDAT_WT]: begin 
        if (rddata_rdy) begin
          if (rlast)
            next_rstate[AXI_RDDAT_LST] = 1'b1;
          else
            next_rstate[AXI_RDDAT] = 1'b1;
        end
        else
          next_rstate[AXI_RDDAT_WT] = 1'b1;
      end
      rstate[AXI_RDTO]: begin 
        next_rstate[AXI_RDIDLE] = 1'b1;
      end
    endcase
  end
  always @(posedge aclk)
    if (!aresetn)
      rd_cntr <= 4'h0;
    else if (rstate[AXI_RDDAT_LST] & next_rstate[AXI_RDIDLE])
      rd_cntr <= rd_cntr + 4'h1;
  always @(posedge aclk)
    if (!aresetn)
      axi_rvalid <= 1'b0;
    else if (rstate[AXI_RDCTL] & next_rstate[AXI_RDDAT])
      axi_rvalid <= 1'b0;
    else if (rstate[AXI_RDCTL])     
      axi_rvalid <= 1'b1;
  assign axi_rid = rd_cntr; 
  generate 
    begin: addr_axi_rd
      if (C_AXI_DATA_WIDTH == 256)
        assign axi_raddr = {addr_r[C_AXI_ADDR_WIDTH-1:5], 5'b0};
      else if (C_AXI_DATA_WIDTH == 128)
        assign axi_raddr = {addr_r[C_AXI_ADDR_WIDTH-1:4], 4'b0};
      else if (C_AXI_DATA_WIDTH == 64)
        assign axi_raddr = {addr_r[C_AXI_ADDR_WIDTH-1:3], 3'b0};
      else
        assign axi_raddr = {addr_r[C_AXI_ADDR_WIDTH-1:2], 2'b0};
    end
  endgenerate
  assign axi_rlen = blen_r;
  assign axi_rburst = {1'b0, wrap_r} + 2'b01;
  assign axi_rsize = ctl_r[2:0];
  assign axi_rlock = 2'b0;
  assign axi_rcache = 4'b0;
  assign axi_rprot = 3'b0; 
  always @(posedge aclk)
    if (!aresetn)
      rddata_vld <= 1'b0;
    else if ((rddata_vld & !axi_rd_rvalid & rstate[AXI_RDDAT]) |
             (rddata_rdy & rstate[AXI_RDDAT_LST]) | 
             (rstate[AXI_RDDAT_WT] & next_rstate[AXI_RDDAT] & rddata_ppld) | 
             (rddata_rdy & axi_rd_rvalid & axi_rd_last) |
             rstate[AXI_RDIDLE])
      rddata_vld <= 1'b0;
    else if ((rstate[AXI_RDDAT] & axi_rd_rvalid & !axi_rd_last) |
             ((rstate[AXI_RDDAT] | rstate[AXI_RDDAT_WT]) & next_rstate[AXI_RDDAT_LST] & rlast) |
             (rstate[AXI_RDDAT_LST] & axi_rd_rvalid & axi_rd_last & axi_rd_rready) | 
             rstate[AXI_RDTO])
      rddata_vld <= 1'b1;
  always @(posedge aclk)
    if (!aresetn)
      rddata_ppld <= 1'b0;
    else if (rddata_vld & rddata_rdy)
      rddata_ppld <= 1'b0;
    else if (!rddata_vld & axi_rd_rvalid & axi_rd_rready & rstate[AXI_RDDAT_WT])
      rddata_ppld <= 1'b1;
  always @(posedge aclk)
    if (!aresetn)
      axi_rd_rready <= 1'b0;
    else if (rstate[AXI_RDIDLE] |
             (rstate[AXI_RDDAT] & next_rstate[AXI_RDDAT_WT]) |
             (rstate[AXI_RDDAT_WT] & !next_rstate[AXI_RDDAT] & rddata_ppld) |
             (next_rstate[AXI_RDDAT_LST] & (rstate[AXI_RDDAT] | rstate[AXI_RDDAT_WT])))
      axi_rd_rready <= 1'b0;
    else if ((next_rstate[AXI_RDDAT] & (rstate[AXI_RDCTL] | rstate[AXI_RDDAT_WT])) |
             (next_rstate[AXI_RDDAT_LST] & rstate[AXI_RDDAT_WT] & rddata_ppld) |
             (rstate[AXI_RDDAT_WT] & !rddata_ppld) |
             (rstate[AXI_RDDAT_LST] & axi_rd_rvalid & axi_rd_last))
      axi_rd_rready <= 1'b1;
  always @(posedge aclk)
    if (axi_rd_rvalid)
      rddata_p1 <= axi_rd_data;
  generate 
    begin: data_axi_rd
      if (C_AXI_NBURST_SUPPORT == 1) begin
      end
      else begin
        always @(posedge aclk)
          if (axi_rd_rvalid & !rddata_ppld)
            rddata <= axi_rd_data;
          else if (rddata_rdy & rddata_vld & rddata_ppld)
            rddata <= rddata_p1;
        assign rddata_bvld = {{C_AXI_DATA_WIDTH/32}{4'hF}};
      end
    end
  endgenerate
  always @(posedge aclk)
    if (!aresetn)
      rddata_cmptd <= 1'b0;
    else if ((next_rstate[AXI_RDIDLE] & rstate[AXI_RDDAT_LST]) |
             rstate[AXI_RDIDLE])
      rddata_cmptd <= 1'b0;
    else if (((rstate[AXI_RDDAT] | rstate[AXI_RDDAT_WT]) & next_rstate[AXI_RDDAT_LST] & rlast) |
             (rstate[AXI_RDDAT_LST] & axi_rd_rvalid & axi_rd_last & axi_rd_rready) | 
             rstate[AXI_RDTO])
      rddata_cmptd <= 1'b1;
  always @(posedge aclk)
    if (rstate[AXI_RDIDLE])
      err_resp <= 1'b0;
    else if (axi_rd_rvalid & axi_rd_rresp[1])
      err_resp <= 1'b1;
  always @(posedge aclk)
    if (rstate[AXI_RDIDLE] & next_rstate[AXI_RDCTL])
      rddata_fsm_sts <= 2'b00;
    else if (rstate[AXI_RDCTL] & next_rstate[AXI_RDTO])
      rddata_fsm_sts <= 2'b01;
    else if (rstate[AXI_RDDAT] & next_rstate[AXI_RDTO])
      rddata_fsm_sts <= 2'b10;
  always @(posedge aclk)
    if (rstate[AXI_RDIDLE] & next_rstate[AXI_RDCTL])
      rrid_err <= 1'b0;
    else if (axi_rd_rvalid & axi_rd_bid != rd_cntr)
      rrid_err <= 1'b1;
  always @(posedge aclk)
    if (rstate[AXI_RDIDLE])    
      rd_len_cntr <= 8'h0; 
    else if (axi_rd_rvalid & axi_rd_rready)
      rd_len_cntr <= rd_len_cntr + 8'h01;
  assign rddata_sts = {{(RD_STS_WIDTH-12){1'b0}},rd_len_cntr,rddata_fsm_sts,rrid_err,err_resp}; 
  always @(posedge aclk) begin
    if (rd_cmd_timeout)
      $display ("ERR: Read timeout occured at time %t", $time);
    if (wr_cmd_timeout)
      $display ("ERR: Write timeout occured at time %t", $time);
  end
endmodule
