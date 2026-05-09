`timescale 1ns / 1ps
`timescale 1ns / 1ps
module rx_engine(
	input  wire         clk,
	input  wire         rst,
	output wire [127:0] ingress_data,
	output wire   [1:0] ingress_fifo_ctrl,   
	input  wire   [1:0] ingress_fifo_status, 
	output wire   [2:0] ingress_xfer_size,
	output wire  [27:6] ingress_start_addr,
	output wire         ingress_data_req,
	input  wire         ingress_data_ack,
	input  wire         rd_dma_start,  
	input  wire  [31:0] dmarad,        
	input  wire  [31:0] dmarxs, 
	output wire         rd_dma_done,   
	output              new_des_one,
	output wire        [31:0]  SourceAddr_L,
	output wire        [31:0]  SourceAddr_H,
	output wire        [31:0]  DestAddr,
	output wire        [23:0]  FrameSize,
	output wire        [7:0]   FrameControl,
	input  wire        Wait_for_TX_desc,
	input  wire        transferstart,     
	output [4:0] rx_waddr,
	output [31:0] rx_wdata,
	output rx_we,
	output [4:0] rx_raddr,
	input [31:0] rx_rdata,
	output  pending_comp_done,
	input [31:0] completion_pending,
	input wire [63:0] trn_rd,
	input wire [7:0] trn_rrem_n,
	input wire trn_rsof_n,
	input wire trn_reof_n,
	input wire trn_rsrc_rdy_n,
	input wire trn_rsrc_dsc_n,
	output wire trn_rdst_rdy_n,
	input wire trn_rerrfwd_n,
	output wire trn_rnp_ok_n,
	input wire [6:0] trn_rbar_hit_n,
	input wire [11:0] trn_rfc_npd_av,
	input wire [7:0] trn_rfc_nph_av,
	input wire [11:0] trn_rfc_pd_av,
	input wire [7:0] trn_rfc_ph_av,
	input wire [11:0] trn_rfc_cpld_av,
	input wire [7:0] trn_rfc_cplh_av,
	output wire trn_rcpl_streaming_n,
	output wire [6:0] bar_hit_o,
	output wire MRd_o,                
	output wire MWr_o,   
	output wire [31:0] MEM_addr_o,
	output wire [15:0] MEM_req_id_o,
	output wire [7:0] MEM_tag_o,
	output wire header_fields_valid_o,
	output wire [31:0] write_data,
	output wire write_data_wren,
	input wire  read_last,
	output wire [9:0] np_rx_cnt_qw,
	output [9:0] Debug30RXEngine,
	output reg [11:0] Debug31RXDataFIFOfullcnt,
	output reg [11:0] Debug32RXXferFIFOfullcnt,
	output reg [23:0] Debug33RXDataFIFOWRcnt,
	output reg [23:0] Debug34RXDataFIFORDcnt,
	output reg [23:0] Debug35RXXferFIFOWRcnt,
	output reg [23:0] Debug36RXXferFIFORDcnt
);
wire  [27:6] mem_dest_addr;
wire  [10:0] mem_dma_size;
wire         mem_dma_start;
wire  [63:0] write_data_fifo_data;
wire         write_data_fifo_cntrl;
wire         write_data_fifo_status;
wire [127:0] read_data_fifo_data;
wire         read_data_fifo_cntrl;
wire         read_data_fifo_status;
wire fourdw_n_threedw; 
wire payload;
wire [2:0] tc; 
wire td; 
wire ep;  
wire [1:0] attr;
wire [9:0] dw_length;
wire [15:0] MEM_req_id;
wire [7:0] MEM_tag;
wire [15:0] CMP_comp_id;
wire [2:0] CMP_compl_stat;
wire CMP_bcm;
wire [11:0] CMP_byte_count;
wire [63:0] MEM_addr;  
wire [15:0] CMP_req_id;
wire [7:0] CMP_tag;
wire [6:0] CMP_lower_addr;
wire MRd;
wire MWr;
wire CplD;
reg  CplD_r;   
wire Msg;
wire UR;
wire [6:0] bar_hit;
wire header_fields_valid;
reg [63:0] trn_rd_reg;
reg [7:0] trn_rrem_reg_n;
reg trn_rsof_reg_n;
reg trn_reof_reg_n;
reg trn_rsrc_rdy_reg_n;
reg trn_rsrc_dsc_reg_n;
reg trn_rerrfwd_reg_n;
reg [6:0] trn_rbar_hit_reg_n;
reg [11:0] trn_rfc_npd_av_reg;
reg [7:0] trn_rfc_nph_av_reg;
reg [11:0] trn_rfc_pd_av_reg;
reg [7:0] trn_rfc_ph_av_reg;
reg [11:0] trn_rfc_cpld_av_reg;
reg [7:0] trn_rfc_cplh_av_reg;
wire read_xfer_fifo_status;
wire write_xfer_fifo_status;
wire xfer_trn_mem_fifo_rden;
wire  [27:6] mem_dest_addr_fifo;
wire  [10:0] mem_dma_size_fifo;
wire isDes;
wire isDes_fifo;
assign bar_hit_o[6:0] = bar_hit[6:0];
assign MRd_o = MRd;                
assign MWr_o = MWr;   
assign MEM_addr_o[31:0] = MEM_addr[31:0];
assign MEM_req_id_o[15:0] = MEM_req_id[15:0];
assign MEM_tag_o[7:0] = MEM_tag[7:0];
assign header_fields_valid_o = header_fields_valid;
assign write_data[31:0] = write_data_fifo_data[31:0]; 
assign write_data_wren = write_data_fifo_cntrl;
always @ (posedge clk)
begin
    trn_rd_reg[63:0]          <= trn_rd[63:0]         ;
    trn_rrem_reg_n[7:0]       <= trn_rrem_n[7:0]      ;
    trn_rsof_reg_n            <= trn_rsof_n           ;
    trn_reof_reg_n            <= trn_reof_n           ;
    trn_rsrc_rdy_reg_n        <= trn_rsrc_rdy_n       ;
    trn_rsrc_dsc_reg_n        <= trn_rsrc_dsc_n       ;
    trn_rerrfwd_reg_n         <= trn_rerrfwd_n        ;
    trn_rbar_hit_reg_n[6:0]   <= trn_rbar_hit_n[6:0]  ;
    trn_rfc_npd_av_reg[11:0]  <= trn_rfc_npd_av[11:0] ;
    trn_rfc_nph_av_reg[7:0]   <= trn_rfc_nph_av[7:0]  ;
    trn_rfc_pd_av_reg[11:0]   <= trn_rfc_pd_av[11:0]  ;
    trn_rfc_ph_av_reg[7:0]    <= trn_rfc_ph_av[7:0]   ;
    trn_rfc_cpld_av_reg[11:0] <= trn_rfc_cpld_av[11:0];
    trn_rfc_cplh_av_reg[7:0]  <= trn_rfc_cplh_av[7:0] ;
end
rx_trn_monitor rx_trn_monitor_inst(
   .clk                (clk),
   .rst                (rst),
   .rd_dma_start       (rd_dma_start), 
   .dmarad             (dmarad[31:0]),        
   .dmarxs             (dmarxs[31:0]),  
   .rd_dma_done        (rd_dma_done), 
   .read_last          (read_last),
	.Wait_for_TX_desc   (Wait_for_TX_desc),
	.transferstart      (transferstart),
   .rx_waddr (rx_waddr[4:0]),
   .rx_wdata  (rx_wdata[31:0]),
   .rx_we (rx_we),
   .rx_raddr  (rx_raddr[4:0]),
   .rx_rdata(rx_rdata[31:0]),
   .pending_comp_done(pending_comp_done),
   .completion_pending(completion_pending[31:0]),
   .trn_rd             (trn_rd_reg),         
   .trn_rrem_n         (trn_rrem_reg_n),     
   .trn_rsof_n         (trn_rsof_reg_n),     
   .trn_reof_n         (trn_reof_reg_n),     
   .trn_rsrc_rdy_n     (trn_rsrc_rdy_reg_n), 
   .trn_rsrc_dsc_n     (trn_rsrc_dsc_reg_n), 
   .trn_rerrfwd_n      (trn_rerrfwd_reg_n),  
   .trn_rbar_hit_n     (trn_rbar_hit_reg_n), 
   .trn_rfc_npd_av     (trn_rfc_npd_av_reg), 
   .trn_rfc_nph_av     (trn_rfc_nph_av_reg), 
   .trn_rfc_pd_av      (trn_rfc_pd_av_reg),  
   .trn_rfc_ph_av      (trn_rfc_ph_av_reg),  
   .trn_rfc_cpld_av    (trn_rfc_cpld_av_reg),
   .trn_rfc_cplh_av    (trn_rfc_cplh_av_reg),
   .fourdw_n_threedw   (fourdw_n_threedw), 
   .payload            (payload),
   .tc                 (tc[2:0]), 
   .td                 (td), 
   .ep                 (ep),  
   .attr               (attr[1:0]),
   .dw_length          (dw_length[9:0]),
   .MEM_req_id         (MEM_req_id[15:0]),
   .MEM_tag            (MEM_tag[7:0]),
   .CMP_comp_id        (CMP_comp_id[15:0]),
   .CMP_compl_stat     (CMP_compl_stat[2:0]),
   .CMP_bcm            (CMP_bcm),
   .CMP_byte_count     (CMP_byte_count[11:0]),
   .MEM_addr           (MEM_addr[63:0]),  
   .CMP_req_id         (CMP_req_id[15:0]),
   .CMP_tag            (CMP_tag[7:0]),
   .CMP_lower_addr     (CMP_lower_addr[6:0]),
   .MRd                (MRd),
   .MWr                (MWr),
   .CplD               (CplD),
   .Msg                (Msg),
   .UR                 (UR),
   .header_fields_valid(header_fields_valid),
   .data_valid         (write_data_fifo_cntrl),
	.isDes              (isDes),        
   .mem_dest_addr      (mem_dest_addr),
   .mem_dma_size       (mem_dma_size),
   .mem_dma_start      (mem_dma_start),
	.np_rx_cnt_qw       (np_rx_cnt_qw),
	.Debug30RXEngine    (Debug30RXEngine)
   );
rx_trn_data_fsm rx_trn_data_fsm_inst(
   .clk                   (clk),
   .rst                   (rst),
   .trn_rd              (trn_rd_reg),            
   .trn_rrem_n          (trn_rrem_reg_n),        
   .trn_rsof_n          (trn_rsof_reg_n),        
   .trn_reof_n          (trn_reof_reg_n),        
   .trn_rsrc_rdy_n      (trn_rsrc_rdy_reg_n),    
   .trn_rsrc_dsc_n      (trn_rsrc_dsc_reg_n),    
   .trn_rdst_rdy_n      (trn_rdst_rdy_n),        
   .trn_rerrfwd_n       (trn_rerrfwd_reg_n),     
   .trn_rnp_ok_n        (trn_rnp_ok_n),          
   .trn_rbar_hit_n      (trn_rbar_hit_reg_n),    
   .trn_rfc_npd_av      (trn_rfc_npd_av_reg),    
   .trn_rfc_nph_av      (trn_rfc_nph_av_reg),    
   .trn_rfc_pd_av       (trn_rfc_pd_av_reg),     
   .trn_rfc_ph_av       (trn_rfc_ph_av_reg),     
   .trn_rfc_cpld_av     (trn_rfc_cpld_av_reg),   
   .trn_rfc_cplh_av     (trn_rfc_cplh_av_reg),   
   .trn_rcpl_streaming_n(trn_rcpl_streaming_n),  
   .data_out            (write_data_fifo_data[63:0]),
   .data_out_be         (),
   .data_valid          (write_data_fifo_cntrl),
   .data_fifo_status    (write_data_fifo_status),
   .fourdw_n_threedw   (fourdw_n_threedw), 
   .payload            (payload),
   .tc                 (tc[2:0]), 
   .td                 (td), 
   .ep                 (ep),  
   .attr               (attr[1:0]),
   .dw_length          (dw_length[9:0]),
   .MEM_req_id         (MEM_req_id[15:0]),
   .MEM_tag            (MEM_tag[7:0]),
   .CMP_comp_id        (CMP_comp_id[15:0]),
   .CMP_compl_stat     (CMP_compl_stat[2:0]),
   .CMP_bcm            (CMP_bcm),
   .CMP_byte_count     (CMP_byte_count[11:0]),
   .MEM_addr           (MEM_addr[63:0]),  
   .CMP_req_id         (CMP_req_id[15:0]),
   .CMP_tag            (CMP_tag[7:0]),
   .CMP_lower_addr     (CMP_lower_addr[6:0]),
   .MRd                (MRd),
   .MWr                (MWr),
   .CplD               (CplD),
   .Msg                (Msg),
   .UR                 (UR),
   .bar_hit            (bar_hit[6:0]),
   .header_fields_valid(header_fields_valid)
);
always@(posedge clk) CplD_r <= CplD;
data_trn_mem_fifo data_trn_mem_fifo_inst(
   .din    (write_data_fifo_data[63:0]),
   .rd_clk (clk),
   .rd_en  (read_data_fifo_cntrl),
   .rst    (rst),
   .wr_clk (clk),
   .wr_en  (write_data_fifo_cntrl & CplD_r),     
   .dout   ({read_data_fifo_data[63:0],read_data_fifo_data[127:64]}),
   .empty  (read_data_fifo_status),
   .full   (write_data_fifo_status)    
);
xfer_trn_mem_fifo xfer_trn_mem_fifo_inst(
   .din    ({isDes,mem_dest_addr[27:6],mem_dma_size[10:0]}),
   .clk    (clk),
   .rd_en  (xfer_trn_mem_fifo_rden),
   .rst    (rst),
   .wr_en  (mem_dma_start),
   .dout   ({isDes_fifo,mem_dest_addr_fifo[27:6],mem_dma_size_fifo[10:0]}),
   .empty  (read_xfer_fifo_status),
   .full   (write_xfer_fifo_status)          
);
always@(posedge clk)begin
   if (rst)
	   Debug31RXDataFIFOfullcnt <= 32'h0000_0000;
	else if (write_data_fifo_status)
	   Debug31RXDataFIFOfullcnt <= Debug31RXDataFIFOfullcnt + 1'b1;
	else
	   Debug31RXDataFIFOfullcnt <= Debug31RXDataFIFOfullcnt;
end
always@(posedge clk)begin
   if (rst)
	   Debug32RXXferFIFOfullcnt <= 32'h0000_0000;
	else if (write_xfer_fifo_status)
	   Debug32RXXferFIFOfullcnt <= Debug32RXXferFIFOfullcnt + 1'b1;
	else
	   Debug32RXXferFIFOfullcnt <= Debug32RXXferFIFOfullcnt;
end
always@(posedge clk)begin
   if (rst)
	   Debug33RXDataFIFOWRcnt <= 32'h0000_0000;
	else if (write_data_fifo_cntrl & CplD)
	   Debug33RXDataFIFOWRcnt <= Debug33RXDataFIFOWRcnt + 1'b1;
	else
	   Debug33RXDataFIFOWRcnt <= Debug33RXDataFIFOWRcnt;
end
always@(posedge clk)begin
   if (rst)
	   Debug34RXDataFIFORDcnt <= 32'h0000_0000;
	else if (read_data_fifo_cntrl)
	   Debug34RXDataFIFORDcnt <= Debug34RXDataFIFORDcnt + 1'b1;
	else
	   Debug34RXDataFIFORDcnt <= Debug34RXDataFIFORDcnt;
end
always@(posedge clk)begin
   if (rst)
	   Debug35RXXferFIFOWRcnt <= 32'h0000_0000;
	else if (mem_dma_start)
	   Debug35RXXferFIFOWRcnt <= Debug35RXXferFIFOWRcnt + 1'b1;
	else
	   Debug35RXXferFIFOWRcnt <= Debug35RXXferFIFOWRcnt;
end
always@(posedge clk)begin
   if (rst)
	   Debug36RXXferFIFORDcnt <= 32'h0000_0000;
	else if (xfer_trn_mem_fifo_rden)
	   Debug36RXXferFIFORDcnt <= Debug36RXXferFIFORDcnt + 1'b1;
	else
	   Debug36RXXferFIFORDcnt <= Debug36RXXferFIFORDcnt;
end
rx_mem_data_fsm rx_mem_data_fsm_inst(
   .clk                 (clk),
   .rst                 (rst),
   .ingress_data        (ingress_data),
   .ingress_fifo_ctrl   (ingress_fifo_ctrl),  
   .ingress_fifo_status (ingress_fifo_status), 
   .ingress_xfer_size   (ingress_xfer_size),
   .ingress_start_addr  (ingress_start_addr),
   .ingress_data_req    (ingress_data_req),
   .ingress_data_ack    (ingress_data_ack),
	.isDes_fifo(isDes_fifo),                      
   .mem_dest_addr_fifo  (mem_dest_addr_fifo),
   .mem_dma_size_fifo   (mem_dma_size_fifo),
   .mem_dma_start       (1'b0),
   .mem_trn_fifo_empty  (read_xfer_fifo_status),
   .mem_trn_fifo_rden   (xfer_trn_mem_fifo_rden),
   .data_fifo_data      (read_data_fifo_data[127:0]),
   .data_fifo_cntrl     (read_data_fifo_cntrl),   
   .data_fifo_status    (read_data_fifo_status),
   .new_des_one(new_des_one),
   .SourceAddr_L(SourceAddr_L),
   .SourceAddr_H(SourceAddr_H),
   .DestAddr(DestAddr),
   .FrameSize(FrameSize),
   .FrameControl(FrameControl)	
   );
endmodule
