module etx(
   ecfg_tx_datain, ecfg_tx_debug, emrq_progfull, emwr_progfull,
   emrr_progfull, txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n,
   txo_data_p, txo_data_n, mi_dout,
   reset, tx_lclk, tx_lclk_out, tx_lclk_par, s_axi_aclk, m_axi_aclk,
   ecfg_tx_enable, ecfg_tx_gpio_enable, ecfg_tx_mmu_enable,
   ecfg_dataout, emrq_access, emrq_write, emrq_datamode,
   emrq_ctrlmode, emrq_dstaddr, emrq_data, emrq_srcaddr, emwr_access,
   emwr_write, emwr_datamode, emwr_ctrlmode, emwr_dstaddr, emwr_data,
   emwr_srcaddr, emrr_access, emrr_write, emrr_datamode,
   emrr_ctrlmode, emrr_dstaddr, emrr_data, emrr_srcaddr,
   txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n, mi_clk,
   mi_en, mi_we, mi_addr, mi_din
   );
   parameter AW   = 32;
   parameter DW   = 32;
   parameter RFAW = 12;
   input         reset;
   input 	 tx_lclk;	       
   input 	 tx_lclk_out;	       
   input 	 tx_lclk_par;	       
   input 	 s_axi_aclk;           
   input 	 m_axi_aclk;           
   input 	 ecfg_tx_enable;       
   input 	 ecfg_tx_gpio_enable;    
   input 	 ecfg_tx_mmu_enable;     
   input [8:0] 	 ecfg_dataout;	       
   output [1:0]  ecfg_tx_datain;       
   output [15:0] ecfg_tx_debug;       
   input 	 emrq_access;
   input 	 emrq_write;
   input [1:0] 	 emrq_datamode;
   input [3:0] 	 emrq_ctrlmode;
   input [31:0]  emrq_dstaddr;
   input [31:0]  emrq_data;
   input [31:0]  emrq_srcaddr;  
   output 	 emrq_progfull;
   input 	 emwr_access;
   input 	 emwr_write;
   input [1:0] 	 emwr_datamode;
   input [3:0] 	 emwr_ctrlmode;
   input [31:0]  emwr_dstaddr;
   input [31:0]  emwr_data;
   input [31:0]  emwr_srcaddr;  
   output 	 emwr_progfull;
   input 	 emrr_access;
   input 	 emrr_write;
   input [1:0] 	 emrr_datamode;
   input [3:0] 	 emrr_ctrlmode;
   input [31:0]  emrr_dstaddr;
   input [31:0]  emrr_data;
   input [31:0]  emrr_srcaddr;  
   output 	 emrr_progfull;
   output        txo_lclk_p, txo_lclk_n;        
   output        txo_frame_p, txo_frame_n;     
   output [7:0]  txo_data_p, txo_data_n;       
   input 	 txi_wr_wait_p,txi_wr_wait_n;  
   input 	 txi_rd_wait_p, txi_rd_wait_n; 
   input 	 mi_clk;     
   input 	 mi_en;      
   input 	 mi_we;      
   input [15:0]  mi_addr;    
   input [31:0]  mi_din;     
   output [31:0] mi_dout;    
   reg [15:0] 	 ecfg_tx_debug; 
   wire 	 emwr_full;
   wire 	 emrr_full;
   wire 	 emrq_full;
   wire			emrq_fifo_access;	
   wire [3:0]		emrq_fifo_ctrlmode;	
   wire [31:0]		emrq_fifo_data;		
   wire [1:0]		emrq_fifo_datamode;	
   wire [31:0]		emrq_fifo_dstaddr;	
   wire [31:0]		emrq_fifo_srcaddr;	
   wire			emrq_fifo_write;	
   wire			emrq_rd_en;		
   wire			emrr_fifo_access;	
   wire [3:0]		emrr_fifo_ctrlmode;	
   wire [31:0]		emrr_fifo_data;		
   wire [1:0]		emrr_fifo_datamode;	
   wire [31:0]		emrr_fifo_dstaddr;	
   wire [31:0]		emrr_fifo_srcaddr;	
   wire			emrr_fifo_write;	
   wire			emrr_rd_en;		
   wire			emwr_fifo_access;	
   wire [3:0]		emwr_fifo_ctrlmode;	
   wire [31:0]		emwr_fifo_data;		
   wire [1:0]		emwr_fifo_datamode;	
   wire [31:0]		emwr_fifo_dstaddr;	
   wire [31:0]		emwr_fifo_srcaddr;	
   wire			emwr_fifo_write;	
   wire			emwr_rd_en;		
   wire			etx_access;		
   wire			etx_ack;		
   wire [3:0]		etx_ctrlmode;		
   wire [31:0]		etx_data;		
   wire [1:0]		etx_datamode;		
   wire [31:0]		etx_dstaddr;		
   wire			etx_rd_wait;		
   wire [31:0]		etx_srcaddr;		
   wire			etx_wr_wait;		
   wire			etx_write;		
   wire [63:0]		tx_data_par;		
   wire [7:0]		tx_frame_par;		
   wire			tx_rd_wait;		
   wire			tx_wr_wait;		
   fifo_async_emesh s_wr_fifo(.fifo_full	(emwr_full),
			      .emesh_access_out	(emwr_fifo_access), 
			      .emesh_write_out	(emwr_fifo_write), 
			      .emesh_datamode_out(emwr_fifo_datamode[1:0]), 
			      .emesh_ctrlmode_out(emwr_fifo_ctrlmode[3:0]), 
			      .emesh_dstaddr_out(emwr_fifo_dstaddr[31:0]), 
			      .emesh_data_out	(emwr_fifo_data[31:0]), 
			      .emesh_srcaddr_out(emwr_fifo_srcaddr[31:0]), 
			      .fifo_progfull	(emwr_progfull), 
			      .rd_clk		(tx_lclk_par),	 
			      .wr_clk		(s_axi_aclk),	 
			      .reset		(reset),	 
			      .emesh_access_in	(emwr_access),	 
			      .emesh_write_in	(emwr_write),	 
			      .emesh_datamode_in(emwr_datamode[1:0]), 
			      .emesh_ctrlmode_in(emwr_ctrlmode[3:0]), 
			      .emesh_dstaddr_in	(emwr_dstaddr[31:0]), 
			      .emesh_data_in	(emwr_data[31:0]), 
			      .emesh_srcaddr_in	(emwr_srcaddr[31:0]), 
			      .fifo_read	(emwr_rd_en));	 
   fifo_async_emesh  s_rq_fifo(.fifo_full	(emrq_full),
			       .emesh_access_out(emrq_fifo_access), 
			       .emesh_write_out	(emrq_fifo_write), 
			       .emesh_datamode_out(emrq_fifo_datamode[1:0]), 
			       .emesh_ctrlmode_out(emrq_fifo_ctrlmode[3:0]), 
			       .emesh_dstaddr_out(emrq_fifo_dstaddr[31:0]), 
			       .emesh_data_out	(emrq_fifo_data[31:0]), 
			       .emesh_srcaddr_out(emrq_fifo_srcaddr[31:0]), 
			       .fifo_progfull	(emrq_progfull), 
			       .rd_clk		(tx_lclk_par),	 
			       .wr_clk		(s_axi_aclk),	 
			       .reset		(reset),	 
			       .emesh_access_in	(emrq_access),	 
			       .emesh_write_in	(emrq_write),	 
			       .emesh_datamode_in(emrq_datamode[1:0]), 
			       .emesh_ctrlmode_in(emrq_ctrlmode[3:0]), 
			       .emesh_dstaddr_in(emrq_dstaddr[31:0]), 
			       .emesh_data_in	(emrq_data[31:0]), 
			       .emesh_srcaddr_in(emrq_srcaddr[31:0]), 
			       .fifo_read	(emrq_rd_en));	 
   fifo_async_emesh  m_rr_fifo(.fifo_full	(emrr_full),
			       .emesh_access_out(emrr_fifo_access), 
			       .emesh_write_out	(emrr_fifo_write), 
			       .emesh_datamode_out(emrr_fifo_datamode[1:0]), 
			       .emesh_ctrlmode_out(emrr_fifo_ctrlmode[3:0]), 
			       .emesh_dstaddr_out(emrr_fifo_dstaddr[31:0]), 
			       .emesh_data_out	(emrr_fifo_data[31:0]), 
			       .emesh_srcaddr_out(emrr_fifo_srcaddr[31:0]), 
			       .fifo_progfull	(emrr_progfull), 
			       .rd_clk		(tx_lclk_par),	 
			       .wr_clk		(m_axi_aclk),	 
			       .reset		(reset),	 
			       .emesh_access_in	(emrr_access),	 
			       .emesh_write_in	(emrr_write),	 
			       .emesh_datamode_in(emrr_datamode[1:0]), 
			       .emesh_ctrlmode_in(emrr_ctrlmode[3:0]), 
			       .emesh_dstaddr_in(emrr_dstaddr[31:0]), 
			       .emesh_data_in	(emrr_data[31:0]), 
			       .emesh_srcaddr_in(emrr_srcaddr[31:0]), 
			       .fifo_read	(emrr_rd_en));	 
   etx_arbiter etx_arbiter (
			    .emwr_rd_en		(emwr_rd_en),
			    .emrq_rd_en		(emrq_rd_en),
			    .emrr_rd_en		(emrr_rd_en),
			    .etx_access		(etx_access),
			    .etx_write		(etx_write),
			    .etx_datamode	(etx_datamode[1:0]),
			    .etx_ctrlmode	(etx_ctrlmode[3:0]),
			    .etx_dstaddr	(etx_dstaddr[31:0]),
			    .etx_srcaddr	(etx_srcaddr[31:0]),
			    .etx_data		(etx_data[31:0]),
			    .tx_lclk_par	(tx_lclk_par),
			    .reset		(reset),
			    .emwr_fifo_access	(emwr_fifo_access),
			    .emwr_fifo_write	(emwr_fifo_write),
			    .emwr_fifo_datamode	(emwr_fifo_datamode[1:0]),
			    .emwr_fifo_ctrlmode	(emwr_fifo_ctrlmode[3:0]),
			    .emwr_fifo_dstaddr	(emwr_fifo_dstaddr[31:0]),
			    .emwr_fifo_data	(emwr_fifo_data[31:0]),
			    .emwr_fifo_srcaddr	(emwr_fifo_srcaddr[31:0]),
			    .emrq_fifo_access	(emrq_fifo_access),
			    .emrq_fifo_write	(emrq_fifo_write),
			    .emrq_fifo_datamode	(emrq_fifo_datamode[1:0]),
			    .emrq_fifo_ctrlmode	(emrq_fifo_ctrlmode[3:0]),
			    .emrq_fifo_dstaddr	(emrq_fifo_dstaddr[31:0]),
			    .emrq_fifo_data	(emrq_fifo_data[31:0]),
			    .emrq_fifo_srcaddr	(emrq_fifo_srcaddr[31:0]),
			    .emrr_fifo_access	(emrr_fifo_access),
			    .emrr_fifo_write	(emrr_fifo_write),
			    .emrr_fifo_datamode	(emrr_fifo_datamode[1:0]),
			    .emrr_fifo_ctrlmode	(emrr_fifo_ctrlmode[3:0]),
			    .emrr_fifo_dstaddr	(emrr_fifo_dstaddr[31:0]),
			    .emrr_fifo_data	(emrr_fifo_data[31:0]),
			    .emrr_fifo_srcaddr	(emrr_fifo_srcaddr[31:0]),
			    .etx_rd_wait	(etx_rd_wait),
			    .etx_wr_wait	(etx_wr_wait),
			    .etx_ack		(etx_ack));
   etx_protocol etx_protocol (
			      .etx_rd_wait	(etx_rd_wait),
			      .etx_wr_wait	(etx_wr_wait),
			      .etx_ack		(etx_ack),
			      .tx_frame_par	(tx_frame_par[7:0]),
			      .tx_data_par	(tx_data_par[63:0]),
			      .ecfg_tx_datain	(ecfg_tx_datain[1:0]),
			      .reset		(reset),
			      .etx_access	(etx_access),
			      .etx_write	(etx_write),
			      .etx_datamode	(etx_datamode[1:0]),
			      .etx_ctrlmode	(etx_ctrlmode[3:0]),
			      .etx_dstaddr	(etx_dstaddr[31:0]),
			      .etx_srcaddr	(etx_srcaddr[31:0]),
			      .etx_data		(etx_data[31:0]),
			      .tx_lclk_par	(tx_lclk_par),
			      .tx_rd_wait	(tx_rd_wait),
			      .tx_wr_wait	(tx_wr_wait));
   etx_io etx_io (
		  .txo_lclk_p		(txo_lclk_p),
		  .txo_lclk_n		(txo_lclk_n),
		  .txo_frame_p		(txo_frame_p),
		  .txo_frame_n		(txo_frame_n),
		  .txo_data_p		(txo_data_p[7:0]),
		  .txo_data_n		(txo_data_n[7:0]),
		  .tx_wr_wait		(tx_wr_wait),
		  .tx_rd_wait		(tx_rd_wait),
		  .reset		(reset),
		  .txi_wr_wait_p	(txi_wr_wait_p),
		  .txi_wr_wait_n	(txi_wr_wait_n),
		  .txi_rd_wait_p	(txi_rd_wait_p),
		  .txi_rd_wait_n	(txi_rd_wait_n),
		  .tx_lclk_par		(tx_lclk_par),
		  .tx_lclk		(tx_lclk),
		  .tx_lclk_out		(tx_lclk_out),
		  .tx_frame_par		(tx_frame_par[7:0]),
		  .tx_data_par		(tx_data_par[63:0]),
		  .ecfg_tx_enable	(ecfg_tx_enable),
		  .ecfg_tx_gpio_enable	(ecfg_tx_gpio_enable),
		  .ecfg_dataout		(ecfg_dataout[8:0]));
   always @ (posedge tx_lclk_par)
     begin
	ecfg_tx_debug[15:0] <= {2'b0,                     
				etx_rd_wait,              
				etx_wr_wait,              
				emrr_rd_en,               
				emrr_progfull,            
				emrr_access,	          
				emrq_rd_en,               
				emrq_progfull,            
				emrq_access,	          
				emwr_rd_en,               
				emwr_progfull,            
				emwr_access,              
				emrr_full,                
				emrq_full,                
				emwr_full	          
				};
     end
endmodule 
