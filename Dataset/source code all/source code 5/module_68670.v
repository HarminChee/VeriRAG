module axi_slave 
#(
parameter           AXI_DW         =  64           , 
parameter           AXI_AW         =  32           , 
parameter           AXI_IW         =   8           , 
parameter           AXI_SW         = AXI_DW >> 3     
)
(
   input                     axi_clk_i      ,  
   input                     axi_rstn_i     ,  
   input      [ AXI_IW-1: 0] axi_awid_i     ,  
   input      [ AXI_AW-1: 0] axi_awaddr_i   ,  
   input      [      4-1: 0] axi_awlen_i    ,  
   input      [      3-1: 0] axi_awsize_i   ,  
   input      [      2-1: 0] axi_awburst_i  ,  
   input      [      2-1: 0] axi_awlock_i   ,  
   input      [      4-1: 0] axi_awcache_i  ,  
   input      [      3-1: 0] axi_awprot_i   ,  
   input                     axi_awvalid_i  ,  
   output                    axi_awready_o  ,  
   input      [ AXI_IW-1: 0] axi_wid_i      ,  
   input      [ AXI_DW-1: 0] axi_wdata_i    ,  
   input      [ AXI_SW-1: 0] axi_wstrb_i    ,  
   input                     axi_wlast_i    ,  
   input                     axi_wvalid_i   ,  
   output                    axi_wready_o   ,  
   output     [ AXI_IW-1: 0] axi_bid_o      ,  
   output reg [      2-1: 0] axi_bresp_o    ,  
   output reg                axi_bvalid_o   ,  
   input                     axi_bready_i   ,  
   input      [ AXI_IW-1: 0] axi_arid_i     ,  
   input      [ AXI_AW-1: 0] axi_araddr_i   ,  
   input      [      4-1: 0] axi_arlen_i    ,  
   input      [      3-1: 0] axi_arsize_i   ,  
   input      [      2-1: 0] axi_arburst_i  ,  
   input      [      2-1: 0] axi_arlock_i   ,  
   input      [      4-1: 0] axi_arcache_i  ,  
   input      [      3-1: 0] axi_arprot_i   ,  
   input                     axi_arvalid_i  ,  
   output                    axi_arready_o  ,  
   output     [ AXI_IW-1: 0] axi_rid_o      ,  
   output reg [ AXI_DW-1: 0] axi_rdata_o    ,  
   output reg [      2-1: 0] axi_rresp_o    ,  
   output reg                axi_rlast_o    ,  
   output reg                axi_rvalid_o   ,  
   input                     axi_rready_i   ,  
   output     [ AXI_AW-1: 0] sys_addr_o     ,  
   output     [ AXI_DW-1: 0] sys_wdata_o    ,  
   output reg [ AXI_SW-1: 0] sys_sel_o      ,  
   output reg                sys_wen_o      ,  
   output reg                sys_ren_o      ,  
   input      [ AXI_DW-1: 0] sys_rdata_i    ,  
   input                     sys_err_i      ,  
   input                     sys_ack_i         
);
wire                 ack         ;
reg   [      6-1: 0] ack_cnt     ;
reg                  rd_do       ;
reg   [ AXI_IW-1: 0] rd_arid     ;
reg   [ AXI_AW-1: 0] rd_araddr   ;
reg                  rd_error    ;
wire                 rd_errorw   ;
reg                  wr_do       ;
reg   [ AXI_IW-1: 0] wr_awid     ;
reg   [ AXI_AW-1: 0] wr_awaddr   ;
reg   [ AXI_IW-1: 0] wr_wid      ;
reg   [ AXI_DW-1: 0] wr_wdata    ;
reg                  wr_error    ;
wire                 wr_errorw   ;
assign wr_errorw = (axi_awlen_i != 4'h0) || (axi_awsize_i != 3'b010); 
assign rd_errorw = (axi_arlen_i != 4'h0) || (axi_arsize_i != 3'b010); 
always @(posedge axi_clk_i) begin
   if (axi_rstn_i == 1'b0) begin
      rd_do    <= 1'b0 ;
      rd_error <= 1'b0 ;
   end
   else begin
      if (axi_arvalid_i && !rd_do && !axi_awvalid_i && !wr_do) 
         rd_do  <= 1'b1 ;
      else if (axi_rready_i && rd_do && ack)
         rd_do  <= 1'b0 ;
      if (axi_arvalid_i && axi_arready_o) begin 
         rd_arid   <= axi_arid_i   ;
         rd_araddr <= axi_araddr_i ;
         rd_error  <= rd_errorw    ;
      end
   end
end
always @(posedge axi_clk_i) begin
   if (axi_rstn_i == 1'b0) begin
      wr_do    <= 1'b0 ;
      wr_error <= 1'b0 ;
   end
   else begin
      if (axi_awvalid_i && !wr_do && !rd_do) 
         wr_do  <= 1'b1 ;
      else if (axi_bready_i && wr_do && ack)
         wr_do  <= 1'b0 ;
      if (axi_awvalid_i && axi_awready_o) begin 
         wr_awid   <= axi_awid_i   ;
         wr_awaddr <= axi_awaddr_i ;
         wr_error  <= wr_errorw    ;
      end
      if (axi_wvalid_i && wr_do) begin 
         wr_wid    <= axi_wid_i    ;
         wr_wdata  <= axi_wdata_i  ;
      end
   end
end
assign axi_awready_o = !wr_do && !rd_do                      ;
assign axi_wready_o  = (wr_do && axi_wvalid_i) || (wr_errorw && axi_wvalid_i)    ;
assign axi_bid_o     = wr_awid                               ;
assign axi_arready_o = !rd_do && !wr_do && !axi_awvalid_i     ;
assign axi_rid_o     = rd_arid                                ;
always @(posedge axi_clk_i) begin
   if (axi_rstn_i == 1'b0) begin
      axi_bvalid_o  <= 1'b0 ;
      axi_bresp_o   <= 2'h0 ;
      axi_rlast_o   <= 1'b0 ;
      axi_rvalid_o  <= 1'b0 ;
      axi_rresp_o   <= 2'h0 ;
   end
   else begin
      axi_bvalid_o  <= wr_do && ack  ;
      axi_bresp_o   <= {(wr_error || ack_cnt[5]),1'b0} ;  
      axi_rlast_o   <= rd_do && ack  ;
      axi_rvalid_o  <= rd_do && ack  ;
      axi_rresp_o   <= {(rd_error || ack_cnt[5]),1'b0} ;  
      axi_rdata_o   <= sys_rdata_i   ;
   end
end
always @(posedge axi_clk_i) begin
   if (axi_rstn_i == 1'b0) begin
      ack_cnt   <= 6'h0 ;
   end
   else begin
      if ((axi_arvalid_i && axi_arready_o) || (axi_awvalid_i && axi_awready_o))  
         ack_cnt <= 6'h1 ;
      else if (ack)
         ack_cnt <= 6'h0 ;
      else if (|ack_cnt)
         ack_cnt <= ack_cnt + 6'h1 ;
   end
end
assign ack = sys_ack_i || ack_cnt[5] || (rd_do && rd_errorw) || (wr_do && wr_errorw); 
always @(posedge axi_clk_i) begin
   if (axi_rstn_i == 1'b0) begin
      sys_wen_o  <= 1'b0 ;
      sys_ren_o  <= 1'b0 ;
      sys_sel_o  <= {AXI_SW{1'b0}} ;
   end
   else begin
      sys_wen_o  <= wr_do && axi_wvalid_i && !wr_errorw ;
      sys_ren_o  <= axi_arvalid_i && axi_arready_o && !rd_errorw ;
      sys_sel_o  <= {AXI_SW{1'b1}} ;
   end
end
assign sys_addr_o  = rd_do ? rd_araddr : wr_awaddr  ;
assign sys_wdata_o = wr_wdata                       ;
endmodule
