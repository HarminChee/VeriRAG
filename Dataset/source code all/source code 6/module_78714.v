`timescale 1ns / 1ps
`timescale 1ns / 1ps
module tx_engine(
    input clk,
    input rst,
	 input hostreset,
	 input  [31:0] Mrd_data_in,    
	 output [11:0] Mrd_data_addr,
    input [15:0] pcie_id,
    output [63:0] trn_td,
    output [7:0] trn_trem_n,
    output trn_tsof_n,
    output trn_teof_n,
    output trn_tsrc_rdy_n,
    output trn_tsrc_dsc_n, 
    input trn_tdst_rdy_n,
    input trn_tdst_dsc_n,
    output trn_terrfwd_n,
    input [2:0] trn_tbuf_av,
   input        non_posted_fifo_wren,
   input [63:0] non_posted_fifo_data,
   input        posted_fifo_wren,
   input [63:0] posted_fifo_data,
	output       posted_fifo_full,
	 input [63:0] dma_write_data_fifo_data,
	 input        dma_write_data_fifo_wren,
	 output       dma_write_data_fifo_full,	 
    input [6:0] bar_hit,
    input MRd,                
    input MWr,   
    input [31:0] MEM_addr,
    input [15:0] MEM_req_id,
    input [7:0] MEM_tag,
    input header_fields_valid,
	 input       rd_dma_start,  
    input  [12:3] dmarxs,        
	 input [9:0] np_rx_cnt_qw,
	 input       transferstart,
 	 input       Wait_for_TX_desc,
	 output [31:0] Debug21RX2,
	 output [31:0] Debug25RX6,
	 output [7:0]  FIFOErrors
);
   wire posted_hdr_fifo_rden;
   wire [63:0] posted_hdr_fifo;
   wire posted_hdr_fifo_empty;
   wire non_posted_hdr_fifo_rden;
   wire [63:0] non_posted_hdr_fifo;
   wire non_posted_hdr_fifo_empty;
   wire non_posted_hdr_fifo_full; 
   wire comp_fifo_wren;
   wire [63:0] comp_fifo_data;
   wire comp_hdr_fifo_rden;
   wire [63:0] comp_hdr_fifo;
   wire comp_hdr_fifo_empty;
   wire comp_hdr_fifo_full;
	wire [63:0] posted_data_fifo_data;
	wire        posted_data_fifo_rden;
	wire        posted_data_fifo_empty;
	wire        posted_data_fifo_real_full;
	wire rst_tx;
	reg  p_hdr_fifo_overflow;
	reg  p_hdr_fifo_underflow;
	reg  p_data_fifo_overflow;
	reg  p_data_fifo_underflow;
	reg  cmp_hdr_fifo_overflow;
	reg  cmp_hdr_fifo_underflow;
	reg  np_hdr_fifo_overflow;
	reg  np_hdr_fifo_underflow;
	assign FIFOErrors[0] = p_hdr_fifo_overflow;
	assign FIFOErrors[1] = p_hdr_fifo_underflow;
	assign FIFOErrors[2] = p_data_fifo_overflow;
	assign FIFOErrors[3] = p_data_fifo_underflow;
	assign FIFOErrors[4] = cmp_hdr_fifo_overflow;
	assign FIFOErrors[5] = cmp_hdr_fifo_underflow;
	assign FIFOErrors[6] = np_hdr_fifo_overflow;
	assign FIFOErrors[7] = np_hdr_fifo_underflow;
	always@(posedge clk) begin
	   if (rst_tx)
		    p_hdr_fifo_overflow <= 1'b0;
		else if (posted_fifo_full & posted_fifo_wren)
		    p_hdr_fifo_overflow <= 1'b1;
		else
		    p_hdr_fifo_overflow <= p_hdr_fifo_overflow;
	end
	always@(posedge clk) begin
	   if (rst_tx)
		    p_hdr_fifo_underflow <= 1'b0;
		else if (posted_hdr_fifo_empty & posted_hdr_fifo_rden)
		    p_hdr_fifo_underflow <= 1'b1;
		else
		    p_hdr_fifo_underflow <= p_hdr_fifo_underflow;
	end
	always@(posedge clk) begin
	   if (rst_tx)
		    p_data_fifo_overflow <= 1'b0;
		else if (posted_data_fifo_real_full & dma_write_data_fifo_wren)
		    p_data_fifo_overflow <= 1'b1;
		else
		    p_data_fifo_overflow <= p_data_fifo_overflow;
	end
	always@(posedge clk) begin
	   if (rst_tx)
		    p_data_fifo_underflow <= 1'b0;
		else if (posted_data_fifo_empty & posted_data_fifo_rden)
		    p_data_fifo_underflow <= 1'b1;
		else
		    p_data_fifo_underflow <= p_data_fifo_underflow;
	end
	always@(posedge clk) begin
	   if (rst_tx)
		    cmp_hdr_fifo_overflow <= 1'b0;
		else if (comp_hdr_fifo_full & comp_fifo_wren)
		    cmp_hdr_fifo_overflow <= 1'b1;
		else
		    cmp_hdr_fifo_overflow <= cmp_hdr_fifo_overflow;
	end
	always@(posedge clk) begin
	   if (rst_tx)
		    cmp_hdr_fifo_underflow <= 1'b0;
		else if (comp_hdr_fifo_empty & comp_hdr_fifo_rden)
		    cmp_hdr_fifo_underflow <= 1'b1;
		else
		    cmp_hdr_fifo_underflow <= cmp_hdr_fifo_underflow;
	end
	always@(posedge clk) begin
	   if (rst_tx)
		    np_hdr_fifo_overflow <= 1'b0;
		else if (non_posted_hdr_fifo_full & non_posted_fifo_wren)
		    np_hdr_fifo_overflow <= 1'b1;
		else
		    np_hdr_fifo_overflow <= np_hdr_fifo_overflow;
	end
	always@(posedge clk) begin
	   if (rst_tx)
		    np_hdr_fifo_underflow <= 1'b0;
		else if (non_posted_hdr_fifo_empty & non_posted_hdr_fifo_rden)
		    np_hdr_fifo_underflow <= 1'b1;
		else
		    np_hdr_fifo_underflow <= np_hdr_fifo_underflow;
	end
  a64_128_distram_fifo a64_128_distram_fifo_p(  
   .clk(clk),
   .rst(rst_tx),
   .din(posted_fifo_data),
   .wr_en(posted_fifo_wren),
   .full(posted_fifo_full),
   .dout(posted_hdr_fifo),
   .rd_en(posted_hdr_fifo_rden),
   .empty(posted_hdr_fifo_empty)
);   
  a64_64_distram_fifo a64_64_distram_fifo_np(  
   .clk(clk),
   .rst(rst_tx),
   .din(non_posted_fifo_data),
   .wr_en(non_posted_fifo_wren),
   .full(non_posted_hdr_fifo_full),
   .dout(non_posted_hdr_fifo),
   .rd_en(non_posted_hdr_fifo_rden),
   .empty(non_posted_hdr_fifo_empty)
   );      
   completer_pkt_gen completer_pkt_gen_inst (
      .clk(clk), 
      .rst(rst_tx), 
      .bar_hit(bar_hit[6:0]),
      .comp_req(MRd & header_fields_valid),                 
      .MEM_addr(MEM_addr[31:0]),
      .MEM_req_id(MEM_req_id[15:0]),
      .comp_id(pcie_id[15:0]), 
      .MEM_tag(MEM_tag[7:0]),
      .comp_fifo_wren(comp_fifo_wren), 
      .comp_fifo_data(comp_fifo_data[63:0])
   );
  a64_64_distram_fifo a64_64_distram_fifo_comp(  
   .clk(clk),
   .rst(rst_tx),
   .din(comp_fifo_data[63:0]),
   .wr_en(comp_fifo_wren),
   .full(comp_hdr_fifo_full),
   .dout(comp_hdr_fifo),
   .rd_en(comp_hdr_fifo_rden),
   .empty(comp_hdr_fifo_empty)
 ); 
data_trn_dma_write_fifo data_trn_dma_write_fifo_inst(
   .din    (dma_write_data_fifo_data),
   .rd_en  (posted_data_fifo_rden),
   .rst    (rst_tx),
   .clk    (clk),
   .wr_en  (dma_write_data_fifo_wren),
   .dout   (posted_data_fifo_data),
   .empty  (posted_data_fifo_empty),
   .full   (posted_data_fifo_real_full),
   .prog_full (dma_write_data_fifo_full)	
);
   tx_trn_sm tx_trn_sm_inst   (
      .clk(clk), 
      .rst_in(rst),
		.hostreset_in(hostreset),
      .rst_out(rst_tx),		
      .posted_hdr_fifo(posted_hdr_fifo), 
      .posted_hdr_fifo_rden(posted_hdr_fifo_rden), 
      .posted_hdr_fifo_empty(posted_hdr_fifo_empty), 
      .nonposted_hdr_fifo(non_posted_hdr_fifo), 
      .nonposted_hdr_fifo_rden(non_posted_hdr_fifo_rden), 
      .nonposted_hdr_fifo_empty(non_posted_hdr_fifo_empty), 
      .comp_hdr_fifo(comp_hdr_fifo), 
      .comp_hdr_fifo_empty(comp_hdr_fifo_empty),
      .comp_hdr_fifo_rden(comp_hdr_fifo_rden),
		.posted_data_fifo_data(posted_data_fifo_data),
		.posted_data_fifo_rden(posted_data_fifo_rden),
		.posted_data_fifo_empty(posted_data_fifo_empty),
      .Mrd_data_addr(Mrd_data_addr),		
      .Mrd_data_in(Mrd_data_in),
      .trn_td(trn_td[63:0]),           
      .trn_trem_n(trn_trem_n[7:0]),    
      .trn_tsof_n(trn_tsof_n),         
      .trn_teof_n(trn_teof_n),         
      .trn_tsrc_rdy_n(trn_tsrc_rdy_n), 
      .trn_tsrc_dsc_n(trn_tsrc_dsc_n), 
      .trn_tdst_rdy_n(trn_tdst_rdy_n), 
      .trn_tdst_dsc_n(trn_tdst_dsc_n), 
      .trn_terrfwd_n(trn_terrfwd_n),   
      .trn_tbuf_av(trn_tbuf_av[2:0]),  
		.rd_dma_start(rd_dma_start),
		.dmarxs(dmarxs),
		.np_rx_cnt_qw(np_rx_cnt_qw),
		.transferstart (transferstart),
 	   .Wait_for_TX_desc(Wait_for_TX_desc),
	   .Debug21RX2(Debug21RX2),
		.Debug25RX6(Debug25RX6)		
   );
endmodule
