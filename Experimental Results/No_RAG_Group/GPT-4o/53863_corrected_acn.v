`define CFG_FAKECLK   1      
`define CFG_MDW       32     
`define CFG_DW        32     
`define CFG_AW        32     
`define CFG_LW        8      
`define CFG_NW        13     
module e16_clock_divider(
   clk_out, clk_out90,
   clk_in, reset_sync_1, div_cfg
   );
   
reg reset_sync_0 = 0, reset_sync_1 = 0;
always @(posedge clk_in) begin
    reset_sync_0 <= reset;
    reset_sync_1 <= reset_sync_0;
end
input       clk_in;    
   input       reset_sync_1;
   input [3:0] div_cfg;   
   output      clk_out;   
   output      clk_out90; 
   reg        clk_out_reg;
   reg [5:0]  counter;   
   reg [5:0]  div_cfg_dec;
   wire div2_sel;   
   wire posedge_match;
   wire negedge_match;  
   wire posedge90_match;
   wire negedge90_match; 
   wire clk_out90_div2;
   wire clk_out90_div4;
   wire clk_out90_div2_in;
   wire clk_out90_div4_in;
   always @ (div_cfg[3:0])
     begin
	casez (div_cfg[3:0])
	  4'b0000 : div_cfg_dec[5:0] = 6'b000010;  
	  4'b0001 : div_cfg_dec[5:0] = 6'b000100;  
	  4'b0010 : div_cfg_dec[5:0] = 6'b001000;  
	  4'b0011 : div_cfg_dec[5:0] = 6'b010000;  
	  4'b01?? : div_cfg_dec[5:0] = 6'b100000;  
          4'b1??? : div_cfg_dec[5:0] = 6'b100000;  
	  default : div_cfg_dec[5:0] = 6'b000000;
	endcase 
     end 
   assign div2_sel = div_cfg[3:0]==4'b0;
   always @ (posedge clk_in or posedge reset_sync_1)
     if (reset_sync_1)
       counter[5:0] <= 6'b000001;   
     else if(posedge_match)
       counter[5:0] <= 6'b000001;
     else
       counter[5:0] <= (counter[5:0]+6'b000001);
   assign posedge_match    = (counter[5:0]==div_cfg_dec[5:0]);
   assign negedge_match    = (counter[5:0]=={1'b0,div_cfg_dec[5:1]}); 
   assign posedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}));
   assign negedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}+{1'b0,div_cfg_dec[5:1]})); 
   always @ (posedge clk_in)
     if(posedge_match)
       clk_out_reg <= 1'b1;
     else if(negedge_match)
       clk_out_reg <= 1'b0;
   assign clk_out    = clk_out_reg;
   wire		c0_emesh_wait_in=1'b0;
   wire		c0_rdmesh_wait_in=1'b0;
   wire		c1_rdmesh_wait_in=1'b0;
   wire		c2_rdmesh_wait_in=1'b0;
   wire		c3_emesh_wait_in=1'b0;
   wire		c3_mesh_wait_in=1'b0;
   wire		c3_rdmesh_wait_in=1'b0;
   wire [5:0] 	txo_cfg_reg=6'b0;
   link_port link_port (.c3_mesh_access_in(1'b0),
			.c3_mesh_write_in(1'b0),
			.c3_mesh_dstaddr_in(32'b0),
			.c3_mesh_srcaddr_in(32'b0),
			.c3_mesh_data_in(32'b0),
			.c3_mesh_datamode_in(2'b0),
			.c3_mesh_ctrlmode_in(4'b0),
			.rxi_rd_wait	(rxi_rd_wait),
			.rxi_wr_wait	(rxi_wr_wait),
			.txo_data	(txo_data[LW-1:0]),
			.txo_lclk	(txo_lclk),
			.txo_frame	(txo_frame),
			.c0_emesh_frame_out(c0_emesh_frame_out),
			.c0_emesh_tran_out(c0_emesh_tran_out[2*LW-1:0]),
			.c3_emesh_frame_out(c3_emesh_frame_out),
			.c3_emesh_tran_out(c3_emesh_tran_out[2*LW-1:0]),
			.c0_rdmesh_frame_out(c0_rdmesh_frame_out),
			.c0_rdmesh_tran_out(c0_rdmesh_tran_out[2*LW-1:0]),
			.c1_rdmesh_frame_out(c1_rdmesh_frame_out),
			.c1_rdmesh_tran_out(c1_rdmesh_tran_out[2*LW-1:0]),
			.c2_rdmesh_frame_out(c2_rdmesh_frame_out),
			.c2_rdmesh_tran_out(c2_rdmesh_tran_out[2*LW-1:0]),
			.c3_rdmesh_frame_out(c3_rdmesh_frame_out),
			.c3_rdmesh_tran_out(c3_rdmesh_tran_out[2*LW-1:0]),
			.c0_mesh_access_out(c0_mesh_access_out),
			.c0_mesh_write_out(c0_mesh_write_out),
			.c0_mesh_dstaddr_out(c0_mesh_dstaddr_out[AW-1:0]),
			.c0_mesh_srcaddr_out(c0_mesh_srcaddr_out[AW-1:0]),
			.c0_mesh_data_out(c0_mesh_data_out[DW-1:0]),
			.c0_mesh_datamode_out(c0_mesh_datamode_out[1:0]),
			.c0_mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]),
			.c3_mesh_access_out(c3_mesh_access_out),
			.c3_mesh_write_out(c3_mesh_write_out),
			.c3_mesh_dstaddr_out(c3_mesh_dstaddr_out[AW-1:0]),
			.c3_mesh_srcaddr_out(c3_mesh_srcaddr_out[AW-1:0]),
			.c3_mesh_data_out(c3_mesh_data_out[DW-1:0]),
			.c3_mesh_datamode_out(c3_mesh_datamode_out[1:0]),
			.c3_mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]),
			.c0_emesh_wait_out(c0_emesh_wait_out),
			.c1_emesh_wait_out(c1_emesh_wait_out),
			.c2_emesh_wait_out(c2_emesh_wait_out),
			.c3_emesh_wait_out(c3_emesh_wait_out),
			.c0_rdmesh_wait_out(c0_rdmesh_wait_out),
			.c1_rdmesh_wait_out(c1_rdmesh_wait_out),
			.c2_rdmesh_wait_out(c2_rdmesh_wait_out),
			.c3_rdmesh_wait_out(c3_rdmesh_wait_out),
			.c0_mesh_wait_out(c0_mesh_wait_out),
			.c3_mesh_wait_out(c3_mesh_wait_out),
			.reset		(reset_sync_1),
			.ext_yid_k	(ext_yid_k[3:0]),
			.ext_xid_k	(ext_xid_k[3:0]),
			.txo_cfg_reg	(txo_cfg_reg[5:0]),
			.vertical_k	(vertical_k),
			.who_am_i	(who_am_i[3:0]),
			.cfg_extcomp_dis(cfg_extcomp_dis),
			.rxi_data	(rxi_data[LW-1:0]),
			.rxi_lclk	(rxi_lclk),
			.rxi_frame	(rxi_frame),
			.txo_rd_wait	(txo_rd_wait),
			.txo_wr_wait	(txo_wr_wait),
			.c0_clk_in	(c0_clk_in),
			.c1_clk_in	(c1_clk_in),
			.c2_clk_in	(c2_clk_in),
			.c3_clk_in	(c3_clk_in),
			.c0_emesh_tran_in(16'b0),		 
			.c0_emesh_frame_in(1'b0),		 
			.c1_emesh_tran_in(16'b0),		 
			.c1_emesh_frame_in(1'b0),		 
			.c2_emesh_tran_in(16'b0),		 
			.c2_emesh_frame_in(1'b0),		 
			.c3_emesh_tran_in(16'b0),		 
			.c3_emesh_frame_in(1'b0),		 
			.c0_rdmesh_tran_in(16'b0),		 
			.c0_rdmesh_frame_in(1'b0),		 
			.c1_rdmesh_tran_in(16'b0),		 
			.c1_rdmesh_frame_in(1'b0),		 
			.c2_rdmesh_tran_in(16'b0),		 
			.c2_rdmesh_frame_in(1'b0),		 
			.c3_rdmesh_tran_in(16'b0),		 
			.c3_rdmesh_frame_in(1'b0),		 
			.c0_mesh_access_in(c0_mesh_access_in),
			.c0_mesh_write_in(c0_mesh_write_in),
			.c0_mesh_dstaddr_in(c0_mesh_dstaddr_in[AW-1:0]),
			.c0_mesh_srcaddr_in(c0_mesh_srcaddr_in[AW-1:0]),
			.c0_mesh_data_in(c0_mesh_data_in[DW-1:0]),
			.c0_mesh_datamode_in(c0_mesh_datamode_in[1:0]),
			.c0_mesh_ctrlmode_in(c0_mesh_ctrlmode_in[3:0]),
			.c0_emesh_wait_in(c0_emesh_wait_in),
			.c3_emesh_wait_in(c3_emesh_wait_in),
			.c0_mesh_wait_in(c0_mesh_wait_in),
			.c3_mesh_wait_in(c3_mesh_wait_in),
			.c0_rdmesh_wait_in(c0_rdmesh_wait_in),
			.c1_rdmesh_wait_in(c1_rdmesh_wait_in),
			.c2_rdmesh_wait_in(c2_rdmesh_wait_in),
			.c3_rdmesh_wait_in(c3_rdmesh_wait_in));
endmodule 
module link_port(
   rxi_rd_wait, rxi_wr_wait, txo_data, txo_lclk, txo_frame,
   c0_emesh_frame_out, c0_emesh_tran_out, c3_emesh_frame_out,
   c3_emesh_tran_out, c0_rdmesh_frame_out, c0_rdmesh_tran_out,
   c1_rdmesh_frame_out, c1_rdmesh_tran_out, c2_rdmesh_frame_out,
   c2_rdmesh_tran_out, c3_rdmesh_frame_out, c3_rdmesh_tran_out,
   c0_mesh_access_out, c0_mesh_write_out, c0_mesh_dstaddr_out,
   c0_mesh_srcaddr_out, c0_mesh_data_out, c0_mesh_datamode_out,
   c0_mesh_ctrlmode_out, c3_mesh_access_out, c3_mesh_write_out,
   c3_mesh_dstaddr_out, c3_mesh_srcaddr_out, c3_mesh_data_out,
   c3_mesh_datamode_out, c3_mesh_ctrlmode_out, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_rdmesh_wait_out, c1_rdmesh_wait_out, c2_rdmesh_wait_out,
   c3_rdmesh_wait_out, c0_mesh_wait_out, c3_mesh_wait_out,
   reset_sync_1, ext_yid_k, ext_xid_k, txo_cfg_reg, vertical_k, who_am_i,
   cfg_extcomp_dis, rxi_data, rxi_lclk, rxi_frame, txo_rd_wait,
   txo_wr_wait, c0_clk_in, c1_clk_in, c2_clk_in, c3_clk_in,
   c0_emesh_tran_in, c0_emesh_frame_in, c1_emesh_tran_in,
   c1_emesh_frame_in, c2_emesh_tran_in, c2_emesh_frame_in,
   c3_emesh_tran_in, c3_emesh_frame_in, c0_rdmesh_tran_in,
   c0_rdmesh_frame_in, c1_rdmesh_tran_in, c1_rdmesh_frame_in,
   c2_rdmesh_tran_in, c2_rdmesh_frame_in, c3_rdmesh_tran_in,
   c3_rdmesh_frame_in, c0_mesh_access_in, c0_mesh_write_in,
   c0_mesh_dstaddr_in, c0_mesh_srcaddr_in, c0_mesh_data_in,
   c0_mesh_datamode_in, c0_mesh_ctrlmode_in, c3_mesh_access_in,
   c3_mesh_write_in, c3_mesh_dstaddr_in, c3_mesh_srcaddr_in,
   c3_mesh_data_in, c3_mesh_datamode_in, c3_mesh_ctrlmode_in,
   c0_emesh_wait_in, c3_emesh_wait_in, c0_mesh_wait_in,
   c3_mesh_wait_in, c0_rdmesh_wait_in, c1_rdmesh_wait_in,
   c2_rdmesh_wait_in, c3_rdmesh_wait_in
   );
   parameter DW   = `CFG_DW  ;
   parameter AW   = `CFG_AW  ;
   parameter LW   = `CFG_LW  ;
   input             reset_sync_1;     
   input [3:0] 	     ext_yid_k; 
   input [3:0] 	     ext_xid_k; 
   input [5:0] 	     txo_cfg_reg;
   input             vertical_k; 
   input [3:0] 	     who_am_i;   
   input 	     cfg_extcomp_dis;
   input   [LW-1:0]  rxi_data;        
   input             rxi_lclk;        
   input             rxi_frame;       
   input             txo_rd_wait;     
   input             txo_wr_wait;     
   input 	    c0_clk_in;         
   input 	    c1_clk_in;         
   input 	    c2_clk_in;         
   input 	    c3_clk_in;         
   input [2*LW-1:0] c0_emesh_tran_in;  
   input 	    c0_emesh_frame_in; 
   input [2*LW-1:0] c1_emesh_tran_in;  
   input 	    c1_emesh_frame_in; 
   input [2*LW-1:0] c2_emesh_tran_in;  
   input 	    c2_emesh_frame_in; 
   input [2*LW-1:0] c3_emesh_tran_in;  
   input 	    c3_emesh_frame_in; 
   input [2*LW-1:0] c0_rdmesh_tran_in;  
   input 	    c0_rdmesh_frame_in; 
   input [2*LW-1:0] c1_rdmesh_tran_in;  
   input 	    c1_rdmesh_frame_in; 
   input [2*LW-1:0] c2_rdmesh_tran_in;  
   input 	    c2_rdmesh_frame_in; 
   input [2*LW-1:0] c3_rdmesh_tran_in;  
   input 	    c3_rdmesh_frame_in; 
   input 	    c0_mesh_access_in;  
   input 	    c0_mesh_write_in;   
   input [AW-1:0]   c0_mesh_dstaddr_in; 
   input [AW-1:0]   c0_mesh_srcaddr_in; 
   input [DW-1:0]   c0_mesh_data_in;    
   input [1:0] 	    c0_mesh_datamode_in;
   input [3:0] 	    c0_mesh_ctrlmode_in;
   input 	    c3_mesh_access_in;  
   input 	    c3_mesh_write_in;   
   input [AW-1:0]   c3_mesh_dstaddr_in; 
   input [AW-1:0]   c3_mesh_srcaddr_in; 
   input [DW-1:0]   c3_mesh_data_in;    
   input [1:0] 	    c3_mesh_datamode_in;
   input [3:0] 	    c3_mesh_ctrlmode_in;
   input 	    c0_emesh_wait_in;  
   input 	    c3_emesh_wait_in;  
   input 	    c0_mesh_wait_in;   
   input 	    c3_mesh_wait_in;   
   input 	    c0_rdmesh_wait_in; 
   input 	    c1_rdmesh_wait_in; 
   input 	    c2_rdmesh_wait_in; 
   input 	    c3_rdmesh_wait_in; 
   output 	     rxi_rd_wait;      
   output 	     rxi_wr_wait;      
   output  [LW-1:0]  txo_data;      
   output            txo_lclk;      
   output            txo_frame;     
   output            c0_emesh_frame_out; 
   output [2*LW-1:0] c0_emesh_tran_out;  
   output            c3_emesh_frame_out; 
   output [2*LW-1:0] c3_emesh_tran_out;  
   output            c0_rdmesh_frame_out; 
   output [2*LW-1:0] c0_rdmesh_tran_out;  
   output            c1_rdmesh_frame_out; 
   output [2*LW-1:0] c1_rdmesh_tran_out;  
   output            c2_rdmesh_frame_out; 
   output [2*LW-1:0] c2_rdmesh_tran_out;  
   output            c3_rdmesh_frame_out; 
   output [2*LW-1:0] c3_rdmesh_tran_out;  
   output 	     c0_mesh_access_out;  
   output 	     c0_mesh_write_out;   
   output [AW-1:0]   c0_mesh_dstaddr_out; 
   output [AW-1:0]   c0_mesh_srcaddr_out; 
   output [DW-1:0]   c0_mesh_data_out;    
   output [1:0]      c0_mesh_datamode_out;
   output [3:0]      c0_mesh_ctrlmode_out;
   output 	     c3_mesh_access_out;  
   output 	     c3_mesh_write_out;   
   output [AW-1:0]   c3_mesh_dstaddr_out; 
   output [AW-1:0]   c3_mesh_srcaddr_out; 
   output [DW-1:0]   c3_mesh_data_out;    
   output [1:0]      c3_mesh_datamode_out;
   output [3:0]      c3_mesh_ctrlmode_out;
   output 	     c0_emesh_wait_out; 
   output 	     c1_emesh_wait_out; 
   output 	     c2_emesh_wait_out; 
   output 	     c3_emesh_wait_out; 
   output 	     c0_rdmesh_wait_out; 
   output 	     c1_rdmesh_wait_out; 
   output 	     c2_rdmesh_wait_out; 
   output 	     c3_rdmesh_wait_out; 
   output 	     c0_mesh_wait_out;  
   output 	     c3_mesh_wait_out;  
   link_receiver  link_receiver(
				.rxi_wr_wait	(rxi_wr_wait),
				.rxi_rd_wait	(rxi_rd_wait),
				.c0_emesh_frame_out(c0_emesh_frame_out),
				.c0_emesh_tran_out(c0_emesh_tran_out[2*LW-1:0]),
				.c3_emesh_frame_out(c3_emesh_frame_out),
				.c3_emesh_tran_out(c3_emesh_tran_out[2*LW-1:0]),
				.c0_rdmesh_frame_out(c0_rdmesh_frame_out),
				.c0_rdmesh_tran_out(c0_rdmesh_tran_out[2*LW-1:0]),
				.c1_rdmesh_frame_out(c1_rdmesh_frame_out),
				.c1_rdmesh_tran_out(c1_rdmesh_tran_out[2*LW-1:0]),
				.c2_rdmesh_frame_out(c2_rdmesh_frame_out),
				.c2_rdmesh_tran_out(c2_rdmesh_tran_out[2*LW-1:0]),
				.c3_rdmesh_frame_out(c3_rdmesh_frame_out),
				.c3_rdmesh_tran_out(c3_rdmesh_tran_out[2*LW-1:0]),
				.c0_mesh_access_out(c0_mesh_access_out),
				.c0_mesh_write_out(c0_mesh_write_out),
				.c0_mesh_dstaddr_out(c0_mesh_dstaddr_out[AW-1:0]),
				.c0_mesh_srcaddr_out(c0_mesh_srcaddr_out[AW-1:0]),
				.c0_mesh_data_out(c0_mesh_data_out[DW-1:0]),
				.c0_mesh_datamode_out(c0_mesh_datamode_out[1:0]),
				.c0_mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]),
				.c3_mesh_access_out(c3_mesh_access_out),
				.c3_mesh_write_out(c3_mesh_write_out),
				.c3_mesh_dstaddr_out(c3_mesh_dstaddr_out[AW-1:0]),
				.c3_mesh_srcaddr_out(c3_mesh_srcaddr_out[AW-1:0]),
				.c3_mesh_data_out(c3_mesh_data_out[DW-1:0]),
				.c3_mesh_datamode_out(c3_mesh_datamode_out[1:0]),
				.c3_mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]),
				.reset		(reset_sync_1),
				.ext_yid_k	(ext_yid_k[3:0]),
				.ext_xid_k	(ext_xid_k[3:0]),
				.vertical_k	(vertical_k),
				.who_am_i	(who_am_i[3:0]),
				.cfg_extcomp_dis(cfg_extcomp_dis),
				.rxi_data	(rxi_data[LW-1:0]),
				.rxi_lclk	(rxi_lclk),
				.rxi_frame	(rxi_frame),
				.c0_clk_in	(c0_clk_in),
				.c1_clk_in	(c1_clk_in),
				.c2_clk_in	(c2_clk_in),
				.c3_clk_in	(c3_clk_in),
				.c0_emesh_wait_in(c0_emesh_wait_in),
				.c3_emesh_wait_in(c3_emesh_wait_in),
				.c0_mesh_wait_in(c0_mesh_wait_in),
				.c3_mesh_wait_in(c3_mesh_wait_in),
				.c0_rdmesh_wait_in(c0_rdmesh_wait_in),
				.c1_rdmesh_wait_in(c1_rdmesh_wait_in),
				.c2_rdmesh_wait_in(c2_rdmesh_wait_in),
				.c3_rdmesh_wait_in(c3_rdmesh_wait_in));
   link_transmitter  link_transmitter(.txo_lclk90	(txo_lclk),
				      .txo_data		(txo_data[LW-1:0]),
				      .txo_frame	(txo_frame),
				      .c0_emesh_wait_out(c0_emesh_wait_out),
				      .c1_emesh_wait_out(c1_emesh_wait_out),
				      .c2_emesh_wait_out(c2_emesh_wait_out),
				      .c3_emesh_wait_out(c3_emesh_wait_out),
				      .c0_rdmesh_wait_out(c0_rdmesh_wait_out),
				      .c1_rdmesh_wait_out(c1_rdmesh_wait_out),
				      .c2_rdmesh_wait_out(c2_rdmesh_wait_out),
				      .c3_rdmesh_wait_out(c3_rdmesh_wait_out),
				      .c0_mesh_wait_out	(c0_mesh_wait_out),
				      .c3_mesh_wait_out	(c3_mesh_wait_out),
				      .reset		(reset_sync_1),
				      .ext_yid_k	(ext_yid_k[3:0]),
				      .ext_xid_k	(ext_xid_k[3:0]),
				      .who_am_i		(who_am_i[3:0]),
				      .txo_cfg_reg	(txo_cfg_reg[5:0]),
				      .txo_wr_wait	(txo_wr_wait),
				      .txo_rd_wait	(txo_rd_wait),
				      .c0_clk_in	(c0_clk_in),
				      .c1_clk_in	(c1_clk_in),
				      .c2_clk_in	(c2_clk_in),
				      .c3_clk_in	(c3_clk_in),
				      .c0_mesh_access_in(c0_mesh_access_in),
				      .c0_mesh_write_in	(c0_mesh_write_in),
				      .c0_mesh_dstaddr_in(c0_mesh_dstaddr_in[AW-1:0]),
				      .c0_mesh_srcaddr_in(c0_mesh_srcaddr_in[AW-1:0]),
				      .c0_mesh_data_in	(c0_mesh_data_in[DW-1:0]),
				      .c0_mesh_datamode_in(c0_mesh_datamode_in[1:0]),
				      .c0_mesh_ctrlmode_in(c0_mesh_ctrlmode_in[3:0]),
				      .c3_mesh_access_in(c3_mesh_access_in),
				      .c3_mesh_write_in	(c3_mesh_write_in),
				      .c3_mesh_dstaddr_in(c3_mesh_dstaddr_in[AW-1:0]),
				      .c3_mesh_srcaddr_in(c3_mesh_srcaddr_in[AW-1:0]),
				      .c3_mesh_data_in	(c3_mesh_data_in[DW-1:0]),
				      .c3_mesh_datamode_in(c3_mesh_datamode_in[1:0]),
				      .c3_mesh_ctrlmode_in(c3_mesh_ctrlmode_in[3:0]),
				      .c0_emesh_frame_in(c0_emesh_frame_in),
				      .c0_emesh_tran_in	(c0_emesh_tran_in[2*LW-1:0]),
				      .c1_emesh_frame_in(c1_emesh_frame_in),
				      .c1_emesh_tran_in	(c1_emesh_tran_in[2*LW-1:0]),
				      .c2_emesh_frame_in(c2_emesh_frame_in),
				      .c2_emesh_tran_in	(c2_emesh_tran_in[2*LW-1:0]),
				      .c3_emesh_frame_in(c3_emesh_frame_in),
				      .c3_emesh_tran_in	(c3_emesh_tran_in[2*LW-1:0]));
endmodule 
module link_receiver(
   rxi_wr_wait, rxi_rd_wait, c0_emesh_frame_out, c0_emesh_tran_out,
   c3_emesh_frame_out, c3_emesh_tran_out, c0_rdmesh_frame_out,
   c0_rdmesh_tran_out, c1_rdmesh_frame_out, c1_rdmesh_tran_out,
   c2_rdmesh_frame_out, c2_rdmesh_tran_out, c3_rdmesh_frame_out,
   c3_rdmesh_tran_out, c0_mesh_access_out, c0_mesh_write_out,
   c0_mesh_dstaddr_out, c0_mesh_srcaddr_out, c0_mesh_data_out,
   c0_mesh_datamode_out, c0_mesh_ctrlmode_out, c3_mesh_access_out,
   c3_mesh_write_out, c3_mesh_dstaddr_out, c3_mesh_srcaddr_out,
   c3_mesh_data_out, c3_mesh_datamode_out, c3_mesh_ctrlmode_out,
   reset_sync_1, ext_yid_k, ext_xid_k, vertical_k, who_am_i, cfg_extcomp_dis,
   rxi_data, rxi_lclk, rxi_frame, c0_clk_in, c1_clk_in, c2_clk_in,
   c3_clk_in, c0_emesh_wait_in, c3_emesh_wait_in, c0_mesh_wait_in,
   c3_mesh_wait_in, c0_rdmesh_wait_in, c1_rdmesh_wait_in,
   c2_rdmesh_wait_in, c3_rdmesh_wait_in
   );
   parameter LW   = `CFG_LW;
   parameter DW   = `CFG_DW;
   parameter AW   = `CFG_AW;
   input             reset_sync_1;     
   input [3:0] 	     ext_yid_k; 
   input [3:0] 	     ext_xid_k; 
   input             vertical_k;
   input [3:0] 	     who_am_i;  
   input 	     cfg_extcomp_dis;
   input [LW-1:0]    rxi_data;  
   input             rxi_lclk;  
   input             rxi_frame; 
   input             c0_clk_in; 
   input             c1_clk_in; 
   input             c2_clk_in; 
   input             c3_clk_in; 
   input             c0_emesh_wait_in;  
   input             c3_emesh_wait_in;  
   input 	     c0_mesh_wait_in;   
   input 	     c3_mesh_wait_in;   
   input             c0_rdmesh_wait_in; 
   input             c1_rdmesh_wait_in; 
   input             c2_rdmesh_wait_in; 
   input             c3_rdmesh_wait_in; 
   output 	     rxi_wr_wait;  
   output 	     rxi_rd_wait;  
   output            c0_emesh_frame_out; 
   output [2*LW-1:0] c0_emesh_tran_out;  
   output            c3_emesh_frame_out; 
   output [2*LW-1:0] c3_emesh_tran_out;  
   output            c0_rdmesh_frame_out; 
   output [2*LW-1:0] c0_rdmesh_tran_out;  
   output            c1_rdmesh_frame_out; 
   output [2*LW-1:0] c1_rdmesh_tran_out;  
   output            c2_rdmesh_frame_out; 
   output [2*LW-1:0] c2_rdmesh_tran_out;  
   output            c3_rdmesh_frame_out; 
   output [2*LW-1:0] c3_rdmesh_tran_out;  
   output 	     c0_mesh_access_out;  
   output 	     c0_mesh_write_out;   
   output [AW-1:0]   c0_mesh_dstaddr_out; 
   output [AW-1:0]   c0_mesh_srcaddr_out; 
   output [DW-1:0]   c0_mesh_data_out;    
   output [1:0]      c0_mesh_datamode_out;
   output [3:0]      c0_mesh_ctrlmode_out;
   output 	     c3_mesh_access_out;  
   output 	     c3_mesh_write_out;   
   output [AW-1:0]   c3_mesh_dstaddr_out; 
   output [AW-1:0]   c3_mesh_srcaddr_out; 
   output [DW-1:0]   c3_mesh_data_out;    
   output [1:0]      c3_mesh_datamode_out;
   output [3:0]      c3_mesh_ctrlmode_out;
   link_rxi_wr link_rxi_wr(
			   .rxi_wr_wait		(rxi_wr_wait),
			   .c0_emesh_frame_out	(c0_emesh_frame_out),
			   .c0_emesh_tran_out	(c0_emesh_tran_out[2*LW-1:0]),
			   .c3_emesh_frame_out	(c3_emesh_frame_out),
			   .c3_emesh_tran_out	(c3_emesh_tran_out[2*LW-1:0]),
			   .c0_mesh_access_out	(c0_mesh_access_out),
			   .c0_mesh_write_out	(c0_mesh_write_out),
			   .c0_mesh_dstaddr_out	(c0_mesh_dstaddr_out[AW-1:0]),
			   .c0_mesh_srcaddr_out	(c0_mesh_srcaddr_out[AW-1:0]),
			   .c0_mesh_data_out	(c0_mesh_data_out[DW-1:0]),
			   .c0_mesh_datamode_out(c0_mesh_datamode_out[1:0]),
			   .c0_mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]),
			   .c3_mesh_access_out	(c3_mesh_access_out),
			   .c3_mesh_write_out	(c3_mesh_write_out),
			   .c3_mesh_dstaddr_out	(c3_mesh_dstaddr_out[AW-1:0]),
			   .c3_mesh_srcaddr_out	(c3_mesh_srcaddr_out[AW-1:0]),
			   .c3_mesh_data_out	(c3_mesh_data_out[DW-1:0]),
			   .c3_mesh_datamode_out(c3_mesh_datamode_out[1:0]),
			   .c3_mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]),
			   .reset		(reset_sync_1),
			   .ext_yid_k		(ext_yid_k[3:0]),
			   .ext_xid_k		(ext_xid_k[3:0]),
			   .vertical_k		(vertical_k),
			   .who_am_i		(who_am_i[3:0]),
			   .cfg_extcomp_dis	(cfg_extcomp_dis),
			   .rxi_data		(rxi_data[LW-1:0]),
			   .rxi_lclk		(rxi_lclk),
			   .rxi_frame		(rxi_frame),
			   .c0_clk_in		(c0_clk_in),
			   .c3_clk_in		(c3_clk_in),
			   .c0_emesh_wait_in	(c0_emesh_wait_in),
			   .c3_emesh_wait_in	(c3_emesh_wait_in),
			   .c0_mesh_wait_in	(c0_mesh_wait_in),
			   .c3_mesh_wait_in	(c3_mesh_wait_in));
   link_rxi_rd link_rxi_rd(
			   .rxi_rd_wait		(rxi_rd_wait),
			   .c0_rdmesh_frame_out	(c0_rdmesh_frame_out),
			   .c0_rdmesh_tran_out	(c0_rdmesh_tran_out[2*LW-1:0]),
			   .c1_rdmesh_frame_out	(c1_rdmesh_frame_out),
			   .c1_rdmesh_tran_out	(c1_rdmesh_tran_out[2*LW-1:0]),
			   .c2_rdmesh_frame_out	(c2_rdmesh_frame_out),
			   .c2_rdmesh_tran_out	(c2_rdmesh_tran_out[2*LW-1:0]),
			   .c3_rdmesh_frame_out	(c3_rdmesh_frame_out),
			   .c3_rdmesh_tran_out	(c3_rdmesh_tran_out[2*LW-1:0]),
			   .reset		(reset_sync_1),
			   .ext_yid_k		(ext_yid_k[3:0]),
			   .ext_xid_k		(ext_xid_k[3:0]),
			   .vertical_k		(vertical_k),
			   .who_am_i		(who_am_i[3:0]),
			   .cfg_extcomp_dis	(cfg_extcomp_dis),
			   .rxi_data		(rxi_data[LW-1:0]),
			   .rxi_lclk		(rxi_lclk),
			   .rxi_frame		(rxi_frame),
			   .c0_clk_in		(c0_clk_in),
			   .c1_clk_in		(c1_clk_in),
			   .c2_clk_in		(c2_clk_in),
			   .c3_clk_in		(c3_clk_in),
			   .c0_rdmesh_wait_in	(c0_rdmesh_wait_in),
			   .c1_rdmesh_wait_in	(c1_rdmesh_wait_in),
			   .c2_rdmesh_wait_in	(c2_rdmesh_wait_in),
			   .c3_rdmesh_wait_in	(c3_rdmesh_wait_in));
endmodule 
module link_rxi_assembler (
   rxi_assembled_tran, rxi_c0_access, rxi_c1_access, rxi_c2_access,
   rxi_c3_access,
   reset_sync_1, rxi_lclk, vertical_k, ext_yid_k, ext_xid_k, fifo_data_reg,
   fifo_data_val, start_tran, cfg_extcomp_dis
   );
   parameter LW   = `CFG_LW  ;
   parameter DW   = `CFG_DW  ;
   parameter AW   = `CFG_AW  ;
   input            reset_sync_1;       
   input 	    rxi_lclk;    
   input            vertical_k;  
   input [3:0] 	    ext_yid_k;   
   input [3:0] 	    ext_xid_k;   
   input [2*LW-1:0] fifo_data_reg;
   input 	    fifo_data_val;
   input 	    start_tran;   
   input 	    cfg_extcomp_dis;
   output [14*LW-1:0] rxi_assembled_tran; 
   output             rxi_c0_access; 
   output 	      rxi_c1_access; 
   output 	      rxi_c2_access; 
   output 	      rxi_c3_access; 
   reg [LW-1:0] tran_byte0;
   reg [2:0] 	rxi_assemble_cnt;
   reg [3:0] 	ctrlmode;
   reg [AW-1:0] dstaddr_int;
   reg [1:0] 	datamode;
   reg 		write;
   reg 		access;
   reg [DW-1:0] data;
   reg [AW-1:0] srcaddr;
   reg 		rxi_cx_access;
   wire          byte0_inc8; 
   wire 	 dstaddr_2712_en;
   wire 	 dstaddr_1100_en;
   wire 	 datamode_en;    
   wire 	 write_en;       
   wire 	 access_en;      
   wire 	 data_3116_en;   
   wire 	 data_1500_en;   
   wire 	 srcaddr_3116_en;
   wire 	 srcaddr_1500_en;
   wire [2:0] 	 rxi_assemble_cnt_next; 
   wire [2:0] 	 rxi_assemble_cnt_inc;  
   wire 	 rxi_assemble_cnt_max;  
   wire 	 burst_tran;            
   wire [AW-1:0] dstaddr_inc;           
   wire [AW-1:0] dstaddr_in;            
   wire 	 single_write;          
   wire 	 single_write_complete; 
   wire 	 read_jump;             
   wire 	 tran_assembled;        
   wire [5:0] 	 comp_addr;
   wire [5:0] 	 chip_addr;
   wire [5:0] 	 comp_low;
   wire 	 carry_low;
   wire 	 zero_low;
   wire [5:0] 	 comp_high;
   wire 	 carry_high;
   wire 	 c0_match;
   wire 	 c1_match;
   wire 	 c2_match;
   wire 	 c3_match;
   wire 	 multicast_match;
   wire [AW-1:0] dstaddr;
   assign rxi_assembled_tran[14*LW-1:0]={
                                         srcaddr[7:0],{(LW){1'b0}},
				               srcaddr[23:8],
			                 data[7:0],srcaddr[31:24],
				                 data[23:8],
	                    dstaddr[3:0],datamode[1:0],write,access,data[31:24],
				                dstaddr[19:4],
			                 ctrlmode[3:0],dstaddr[31:20]
                                        };
   always @ (posedge rxi_lclk)
     if(fifo_data_val & start_tran)
       begin
	  tran_byte0[LW-1:0]  <= fifo_data_reg[2*LW-1:LW]; 
	  ctrlmode[3:0]       <= fifo_data_reg[7:4];
       end
   assign byte0_inc8   = ~tran_byte0[2];
   assign dstaddr[31:28] = cfg_extcomp_dis ? ext_yid_k[3:0] : dstaddr_int[31:28];
   assign dstaddr[25:22] = cfg_extcomp_dis ? ext_xid_k[3:0] : dstaddr_int[25:22];
   assign dstaddr[27:26] = dstaddr_int[27:26];
   assign dstaddr[21:0]  = dstaddr_int[21:0];
   assign dstaddr_inc[AW-1:0] = dstaddr[AW-1:0] + {{(AW-4){1'b0}},byte0_inc8,3'b000};
   assign dstaddr_in[31:28] = burst_tran ? dstaddr_inc[31:28] : fifo_data_reg[3:0];
   assign dstaddr_in[27:12] = burst_tran ? dstaddr_inc[27:12] : fifo_data_reg[2*LW-1:0];
   assign dstaddr_in[11:0]  = burst_tran ? dstaddr_inc[11:0]  : fifo_data_reg[2*LW-1:4];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & (start_tran | burst_tran))
       dstaddr_int[31:28] <= dstaddr_in[31:28];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & (dstaddr_2712_en | burst_tran))
       dstaddr_int[27:12] <= dstaddr_in[27:12];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & (dstaddr_1100_en | burst_tran))
       dstaddr_int[11:0] <= dstaddr_in[11:0];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & datamode_en)
       datamode[1:0] <= fifo_data_reg[3:2];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & write_en)
       write <= fifo_data_reg[1];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & access_en)
       access <= fifo_data_reg[0];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & (data_3116_en | burst_tran))
       data[31:16] <= fifo_data_reg[2*LW-1:0];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & data_1500_en)
       data[15:0] <= fifo_data_reg[2*LW-1:0];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & srcaddr_3116_en)
        srcaddr[31:16] <= fifo_data_reg[2*LW-1:0];
   always @ (posedge rxi_lclk)
     if(fifo_data_val & srcaddr_1500_en)
       srcaddr[15:0] <= fifo_data_reg[2*LW-1:0];
   assign dstaddr_2712_en  = (rxi_assemble_cnt[2:0] == 3'b001);
   assign dstaddr_1100_en  = (rxi_assemble_cnt[2:0] == 3'b010);
   assign datamode_en      = (rxi_assemble_cnt[2:0] == 3'b010);
   assign write_en         = (rxi_assemble_cnt[2:0] == 3'b010);
   assign access_en        = (rxi_assemble_cnt[2:0] == 3'b010);
   assign data_3116_en     = (rxi_assemble_cnt[2:0] == 3'b011);
   assign data_1500_en     = (rxi_assemble_cnt[2:0] == 3'b100);
   assign srcaddr_3116_en  = (rxi_assemble_cnt[2:0] == 3'b101);
   assign srcaddr_1500_en  = (rxi_assemble_cnt[2:0] == 3'b110);
   assign rxi_assemble_cnt_inc[2:0]  = rxi_assemble_cnt[2:0] + 3'b001;
   assign rxi_assemble_cnt_next[2:0] = burst_tran           ? 3'b100 :
				       tran_assembled       ? 3'b000 :
				       read_jump            ? 3'b101 :
				                              rxi_assemble_cnt_inc[2:0];
   always @ (posedge rxi_lclk or posedge reset_sync_1)
     if (reset_sync_1)
       rxi_assemble_cnt[2:0] <= 3'b000;
     else if(fifo_data_val)
       rxi_assemble_cnt[2:0] <= rxi_assemble_cnt_next[2:0];
   assign single_write = 1'b0; 
   assign single_write_complete = single_write & (rxi_assemble_cnt[2:0] == 3'b100);
   assign read_jump = 1'b0;
   assign rxi_assemble_cnt_max = (rxi_assemble_cnt[2:0] == 3'b110);
   assign tran_assembled = fifo_data_val & (single_write_complete | rxi_assemble_cnt_max);
   assign burst_tran = (rxi_assemble_cnt[2:0] == 3'b000) & ~start_tran;
   always @ (posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       rxi_cx_access <= 1'b0;
     else
       rxi_cx_access <= tran_assembled;
   assign rxi_c0_access   = (c0_match |  multicast_match) & rxi_cx_access;
   assign rxi_c1_access   = (c1_match & ~multicast_match) & rxi_cx_access;   
   assign rxi_c2_access   = (c2_match & ~multicast_match) & rxi_cx_access;   
   assign rxi_c3_access   = (c3_match & ~multicast_match) & rxi_cx_access;
   assign comp_addr[5:0]  = vertical_k ? dstaddr[31:26] : dstaddr[25:20];   
   assign chip_addr[5:2] = vertical_k ?  ext_yid_k[3:0] : ext_xid_k[3:0];
   assign chip_addr[1:0] = 2'b11;
   assign {carry_high,comp_high[5:0]} = {1'b0,comp_addr[5:0]} - {1'b0,chip_addr[5:0]};
   assign c0_match =  carry_high; 
   assign c1_match =  (comp_addr[5:0] == {chip_addr[5:2],3'b01});
   assign c2_match =  (comp_addr[5:0] == {chip_addr[5:2],3'b10});
   assign c3_match = ~(c0_match | c1_match | c2_match);
   assign multicast_match = write & 
			    (ctrlmode[1:0]==2'b11) & ~(datamode[1:0] == 2'b11);
endmodule 
module link_rxi_buffer (
   rxi_wait, rxi_assembled_tran, rxi_c0_access, rxi_c1_access,
   rxi_c2_access, rxi_c3_access,
   reset_sync_1, vertical_k, ext_yid_k, ext_xid_k, rxi_data, rxi_lclk,
   rxi_frame, rxi_rd, cfg_extcomp_dis, c0_fifo_full, c1_fifo_full,
   c2_fifo_full, c3_fifo_full
   );
   parameter LW   = `CFG_LW  ;
   parameter NC   = 32;
   parameter FAD  = 5; 
   localparam MD = 1<<FAD;
   input          reset_sync_1;       
   input 	  vertical_k;  
   input [3:0] 	  ext_yid_k;   
   input [3:0] 	  ext_xid_k;   
   input [LW-1:0] rxi_data;      
   input 	  rxi_lclk;      
   input 	  rxi_frame;     
   input 	  rxi_rd;         
   input 	  cfg_extcomp_dis;
   input 	  c0_fifo_full;
   input 	  c1_fifo_full;
   input 	  c2_fifo_full;
   input 	  c3_fifo_full;
   output 	      rxi_wait;          
   output [14*LW-1:0] rxi_assembled_tran; 
   output             rxi_c0_access; 
   output 	      rxi_c1_access; 
   output 	      rxi_c2_access; 
   output 	      rxi_c3_access; 
   reg 		   rd_tran;
   reg [2*LW:0]    fifo_mem[MD-1:0];
   reg 		   frame_reg;
   reg 		   frame_reg_del;
   reg [LW-1:0]    data_even_reg;
   reg [LW-1:0]    data_odd_reg;
   reg [FAD:0] 	   wr_binary_pointer;
   reg [FAD:0] 	   rd_binary_pointer;
   reg 		   fifo_read;
   reg 		   rxi_wait;
   reg 		   start_tran;
   reg 		   fifo_data_val;
   reg [2*LW-1:0]  fifo_data_reg;
   wire 	   my_tran;      
   wire 	   new_tran;     
   wire [2*LW:0]   fifo_data_in; 
   wire [2*LW:0]   fifo_data_out;
   wire [FAD:0]	   wr_binary_next; 
   wire [FAD:0]    rd_binary_next; 
   wire 	   fifo_write; 
   wire [FAD-1:0]  wr_addr; 
   wire [FAD-1:0]  rd_addr; 
   wire 	   fifo_empty; 
   wire 	   stop_fifo_read; 
   always @ (posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       begin
	  frame_reg     <= 1'b0;
	  frame_reg_del <= 1'b0;
       end
     else
       begin
	  frame_reg     <= rxi_frame;
	  frame_reg_del <= frame_reg;
       end
   always @ (posedge rxi_lclk)
     data_even_reg[LW-1:0] <= rxi_data[LW-1:0];
   always @ (negedge rxi_lclk)
     data_odd_reg[LW-1:0] <= rxi_data[LW-1:0];
   assign my_tran = ~(rd_tran ^ rxi_rd);
   always @ (posedge rxi_lclk)
     if(~frame_reg)            
       rd_tran <= rxi_data[7];
   assign new_tran = my_tran & frame_reg & ~frame_reg_del;
   assign fifo_data_in[2*LW:0] = {new_tran,data_even_reg[LW-1:0],data_odd_reg[LW-1:0]};
   assign stop_fifo_read = c0_fifo_full | c1_fifo_full | c2_fifo_full | c3_fifo_full;
   always @ (posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       rxi_wait <= 1'b0;
     else if(stop_fifo_read)
       rxi_wait <= 1'b1;
     else if(fifo_empty)
       rxi_wait <= 1'b0;
   always @ (posedge rxi_lclk)
     if (fifo_write)
       fifo_mem[wr_addr[FAD-1:0]] <= fifo_data_in[2*LW:0];
   assign fifo_data_out[2*LW:0] = fifo_mem[rd_addr[FAD-1:0]];
   always @ (posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       start_tran  <= 1'b0;
     else if(fifo_read)
       start_tran  <= fifo_data_out[2*LW];
   always @ (posedge rxi_lclk)
     if(fifo_read)
       fifo_data_reg[2*LW-1:0] <= fifo_data_out[2*LW-1:0];
   always @ (posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       fifo_data_val <= 1'b0;
     else
       fifo_data_val <= fifo_read;
   assign fifo_write = my_tran & frame_reg;
   always @(posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       wr_binary_pointer[FAD:0]     <= {(FAD+1){1'b0}};
     else if(fifo_write)
       wr_binary_pointer[FAD:0]     <= wr_binary_next[FAD:0];	  
   assign wr_addr[FAD-1:0]       = wr_binary_pointer[FAD-1:0];
   assign wr_binary_next[FAD:0]  = wr_binary_pointer[FAD:0] + {{(FAD){1'b0}},fifo_write};
   always @(posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       fifo_read <= 1'b0;
     else
       fifo_read <= ~(fifo_empty | stop_fifo_read);
   always @(posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       rd_binary_pointer[FAD:0]  <= {(FAD+1){1'b0}};
     else if(fifo_read)
       rd_binary_pointer[FAD:0]  <= rd_binary_next[FAD:0];	  
   assign rd_addr[FAD-1:0]       = rd_binary_pointer[FAD-1:0];
   assign rd_binary_next[FAD:0]  = rd_binary_pointer[FAD:0] + {{(FAD){1'b0}},fifo_read};
   assign fifo_empty = (rd_binary_next[FAD:0] == wr_binary_next[FAD:0]);
   link_rxi_assembler link_rxi_assembler(
					 .rxi_assembled_tran	(rxi_assembled_tran[14*LW-1:0]),
					 .rxi_c0_access		(rxi_c0_access),
					 .rxi_c1_access		(rxi_c1_access),
					 .rxi_c2_access		(rxi_c2_access),
					 .rxi_c3_access		(rxi_c3_access),
					 .reset			(reset_sync_1),
					 .rxi_lclk		(rxi_lclk),
					 .vertical_k		(vertical_k),
					 .ext_yid_k		(ext_yid_k[3:0]),
					 .ext_xid_k		(ext_xid_k[3:0]),
					 .fifo_data_reg		(fifo_data_reg[2*LW-1:0]),
					 .fifo_data_val		(fifo_data_val),
					 .start_tran		(start_tran),
					 .cfg_extcomp_dis	(cfg_extcomp_dis));
endmodule 
module link_rxi_channel (
   fifo_full_rlc, rdmesh_tran_out, rdmesh_frame_out,
   reset_sync_1, cclk, cclk_en, rxi_lclk, cfg_extcomp_dis,
   rxi_assembled_tran_rlc, fifo_access_rlc, rdmesh_wait_in
   );
   parameter LW    = `CFG_LW;
   input             reset_sync_1;   
   input 	     cclk;    
   input 	     cclk_en; 
   input 	     rxi_lclk;
   input 	     cfg_extcomp_dis;
   input [14*LW-1:0] rxi_assembled_tran_rlc; 
   input 	     fifo_access_rlc;        
   input 	     rdmesh_wait_in; 
   output 	  fifo_full_rlc;
   output [2*LW-1:0] rdmesh_tran_out;  
   output 	     rdmesh_frame_out; 
   wire			fifo_empty;		
   wire			fifo_read;		
   wire [14*LW-1:0]	fifo_tran_out;		
   wire			rdmesh_frame;		
   wire [2*LW-1:0]	rdmesh_tran;		
endmodule 
module link_rxi_ctrl(
   lclk, 
   io_lclk, rxi_cfg_reg
   );
   parameter DW = `CFG_DW;
   input           io_lclk;    
   input [DW-1:0]  rxi_cfg_reg;
   output  lclk;   
   assign lclk   =  io_lclk;
endmodule 
module link_rxi_double_channel (
   fifo_full_rlc, emesh_tran_out, emesh_frame_out, mesh_access_out,
   mesh_write_out, mesh_dstaddr_out, mesh_srcaddr_out, mesh_data_out,
   mesh_datamode_out, mesh_ctrlmode_out,
   reset_sync_1, cclk, cclk_en, ext_yid_k, ext_xid_k, rxi_lclk, who_am_i,
   cfg_extcomp_dis, rxi_assembled_tran_rlc, fifo_access_rlc,
   emesh_wait_in, mesh_wait_in
   );
   parameter LW   = `CFG_LW;
   parameter DW   = `CFG_DW;
   parameter AW   = `CFG_AW;
   input             reset_sync_1;   
   input 	     cclk;    
   input 	     cclk_en; 
   input [3:0] 	     ext_yid_k;
   input [3:0] 	     ext_xid_k;
   input 	     rxi_lclk;
   input [3:0] 	     who_am_i;
   input 	     cfg_extcomp_dis;
   input [14*LW-1:0] rxi_assembled_tran_rlc; 
   input 	     fifo_access_rlc;  
   input 	     emesh_wait_in; 
   input 	     mesh_wait_in;  
   output 	     fifo_full_rlc;
   output [2*LW-1:0] emesh_tran_out;  
   output 	     emesh_frame_out; 
   output 	     mesh_access_out;  
   output 	     mesh_write_out;   
   output [AW-1:0]   mesh_dstaddr_out; 
   output [AW-1:0]   mesh_srcaddr_out; 
   output [DW-1:0]   mesh_data_out;    
   output [1:0]      mesh_datamode_out;
   output [3:0]      mesh_ctrlmode_out;
   wire			access;			
   wire [3:0]		ctrlmode;		
   wire [DW-1:0]	data;			
   wire [1:0]		datamode;		
   wire [AW-1:0]	dstaddr;		
   wire			emesh_fifo_read;	
   wire			emesh_frame;		
   wire [2*LW-1:0]	emesh_tran;		
   wire			emesh_tran_dis;		
   wire			fifo_empty;		
   wire [14*LW-1:0]	fifo_tran_out;		
   wire			mesh_fifo_read;		
   wire [AW-1:0]	srcaddr;		
   wire			write;			
   wire     fifo_read;
   wire     emesh_fifo_empty;
   assign fifo_read       = mesh_fifo_read;
   link_rxi_fifo link_rxi_fifo (
				.fifo_full_rlc	(fifo_full_rlc),
				.fifo_tran_out	(fifo_tran_out[14*LW-1:0]),
				.fifo_empty	(fifo_empty),
				.reset		(reset_sync_1),
				.cclk		(cclk),
				.cclk_en	(cclk_en),
				.rxi_lclk	(rxi_lclk),
				.rxi_assembled_tran_rlc(rxi_assembled_tran_rlc[14*LW-1:0]),
				.fifo_access_rlc(fifo_access_rlc),
				.fifo_read	(fifo_read));
   link_rxi_mesh_launcher link_rxi_mesh_launcher(
						 .mesh_fifo_read	(mesh_fifo_read),
						 .emesh_tran_dis	(emesh_tran_dis),
						 .access		(access),
						 .write			(write),
						 .datamode		(datamode[1:0]),
						 .ctrlmode		(ctrlmode[3:0]),
						 .data			(data[DW-1:0]),
						 .dstaddr		(dstaddr[AW-1:0]),
						 .srcaddr		(srcaddr[AW-1:0]),
						 .ext_yid_k		(ext_yid_k[3:0]),
						 .ext_xid_k		(ext_xid_k[3:0]),
						 .who_am_i		(who_am_i[3:0]),
						 .cfg_extcomp_dis	(cfg_extcomp_dis),
						 .fifo_tran_out		(fifo_tran_out[14*LW-1:0]),
						 .fifo_empty		(fifo_empty),
						 .mesh_wait_in		(mesh_wait_in));
   e16_mesh_interface mesh_interface(
				 .wait_out		(),		 
				 .access_out		(mesh_access_out), 
				 .write_out		(mesh_write_out), 
				 .datamode_out		(mesh_datamode_out[1:0]), 
				 .ctrlmode_out		(mesh_ctrlmode_out[3:0]), 
				 .data_out		(mesh_data_out[DW-1:0]), 
				 .dstaddr_out		(mesh_dstaddr_out[AW-1:0]), 
				 .srcaddr_out		(mesh_srcaddr_out[AW-1:0]), 
				 .access_reg		(),		 
				 .write_reg		(),		 
				 .datamode_reg		(),		 
				 .ctrlmode_reg		(),		 
				 .data_reg		(),		 
				 .dstaddr_reg		(),		 
				 .srcaddr_reg		(),		 
				 .clk			(cclk),		 
				 .clk_en		(cclk_en),	 
				 .reset			(reset_sync_1),
				 .wait_in		(mesh_wait_in),	 
				 .access_in		(1'b0),		 
				 .write_in		(1'b0),		 
				 .datamode_in		(2'b00),	 
				 .ctrlmode_in		(4'b0000),	 
				 .data_in		({(DW){1'b0}}),	 
				 .dstaddr_in		({(AW){1'b0}}),	 
				 .srcaddr_in		({(AW){1'b0}}),	 
				 .wait_int		(1'b0),		 
				 .access		(access),
				 .write			(write),
				 .datamode		(datamode[1:0]),
				 .ctrlmode		(ctrlmode[3:0]),
				 .data			(data[DW-1:0]),
				 .dstaddr		(dstaddr[AW-1:0]),
				 .srcaddr		(srcaddr[AW-1:0]));
endmodule 
module link_rxi_fifo (
   fifo_full_rlc, fifo_tran_out, fifo_empty,
   reset_sync_1, cclk, cclk_en, rxi_lclk, rxi_assembled_tran_rlc,
   fifo_access_rlc, fifo_read
   );
   parameter LW    = `CFG_LW;
   parameter FAD   = 2; 
   localparam MD = 1<<FAD;
   input          reset_sync_1;   
   input 	  cclk;    
   input 	  cclk_en; 
   input 	  rxi_lclk;
   input [14*LW-1:0] rxi_assembled_tran_rlc; 
   input 	     fifo_access_rlc;        
   input 	     fifo_read;
   output 	     fifo_full_rlc;
   output [14*LW-1:0] fifo_tran_out;
   output 	      fifo_empty;
   reg [14*LW-1:0] fifo_mem[MD-1:0];
   reg [FAD:0] 	   wr_binary_pointer_rlc;
   reg [FAD:0] 	   wr_gray_pointer_rlc;
   reg 		   fifo_full_rlc;
   reg [FAD:0] 	   rd_binary_pointer;
   reg [FAD:0] 	   rd_gray_pointer;
   reg 		   fifo_empty;
   wire 	      wr_write_rlc; 
   wire [FAD-1:0]     wr_addr_rlc;
   wire [FAD:0]       wr_binary_next_rlc;
   wire [FAD:0]       wr_gray_next_rlc;
   wire 	      fifo_full_next_rlc;
   wire [FAD:0]       rd_gray_pointer_rlc;
   wire [FAD-1:0]     rd_addr;
   wire [FAD:0]       rd_binary_next;
   wire [FAD:0]       rd_gray_next;
   wire 	      fifo_empty_next;
   wire [FAD:0]       wr_gray_pointer;
   assign wr_write_rlc = fifo_access_rlc & ~fifo_full_rlc;
   always @ (posedge rxi_lclk)
     if (wr_write_rlc)
       fifo_mem[wr_addr_rlc[FAD-1:0]] <= rxi_assembled_tran_rlc[14*LW-1:0];
   assign fifo_tran_out[14*LW-1:0] = fifo_mem[rd_addr[FAD-1:0]];
   always @(posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       begin
	  wr_binary_pointer_rlc[FAD:0] <= {(FAD+1){1'b0}};
	  wr_gray_pointer_rlc[FAD:0]   <= {(FAD+1){1'b0}};
       end
     else if(wr_write_rlc)
       begin
	  wr_binary_pointer_rlc[FAD:0] <= wr_binary_next_rlc[FAD:0];	  
	  wr_gray_pointer_rlc[FAD:0]   <= wr_gray_next_rlc[FAD:0];	  
       end	  
   assign wr_addr_rlc[FAD-1:0]       = wr_binary_pointer_rlc[FAD-1:0];
   assign wr_binary_next_rlc[FAD:0]  = wr_binary_pointer_rlc[FAD:0] + 
				       {{(FAD){1'b0}},wr_write_rlc};
   assign wr_gray_next_rlc[FAD:0] = {1'b0,wr_binary_next_rlc[FAD:1]} ^ 
				    wr_binary_next_rlc[FAD:0];
   assign fifo_full_next_rlc = 
			   (wr_gray_next_rlc[FAD-2:0] == rd_gray_pointer_rlc[FAD-2:0]) &
                           (wr_gray_next_rlc[FAD]     ^  rd_gray_pointer_rlc[FAD])     &
                           (wr_gray_next_rlc[FAD-1]   ^  rd_gray_pointer_rlc[FAD-1]);
   always @ (posedge rxi_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       fifo_full_rlc <= 1'b0;
     else 
       fifo_full_rlc <= fifo_full_next_rlc;
   always @(posedge cclk or posedge reset_sync_1)
     if(reset_sync_1)
       begin
	  rd_binary_pointer[FAD:0]  <= {(FAD+1){1'b0}};
	  rd_gray_pointer[FAD:0]    <= {(FAD+1){1'b0}};
       end
     else if(cclk_en)
       if(fifo_read)
	 begin
	    rd_binary_pointer[FAD:0]  <= rd_binary_next[FAD:0];	  
	    rd_gray_pointer[FAD:0]    <= rd_gray_next[FAD:0];	  
	 end
   assign rd_addr[FAD-1:0]       = rd_binary_pointer[FAD-1:0];
   assign rd_binary_next[FAD:0]  = rd_binary_pointer[FAD:0] + {{(FAD){1'b0}},fifo_read};
   assign rd_gray_next[FAD:0]  = {1'b0,rd_binary_next[FAD:1]} ^ rd_binary_next[FAD:0];
   assign fifo_empty_next = (rd_gray_next[FAD:0]==wr_gray_pointer[FAD:0]);
   always @ (posedge cclk or posedge reset_sync_1)
     if(reset_sync_1)
       fifo_empty <= 1'b1;
     else if(cclk_en)
       fifo_empty <= fifo_empty_next;
   e16_synchronizer #(.DW(FAD+1)) sync_rd2wr (.out	 (rd_gray_pointer_rlc[FAD:0]), 
                                          .in	 (rd_gray_pointer[FAD:0]), 
					  .clk	 (rxi_lclk),
					  .reset (reset_sync_1));
   e16_synchronizer #(.DW(FAD+1)) sync_wr2rd (.out	 (wr_gray_pointer[FAD:0]), 
                                          .in	 (wr_gray_pointer_rlc[FAD:0]), 
					  .clk	 (cclk),
					  .reset (reset_sync_1));
endmodule 
module link_rxi_launcher (
   fifo_read, emesh_tran, emesh_frame,
   reset_sync_1, cclk, cclk_en, fifo_tran_out, fifo_empty, emesh_wait_in
   );
   parameter LW   = `CFG_LW;
   input             reset_sync_1;   
   input 	     cclk;    
   input 	     cclk_en; 
   input [14*LW-1:0] fifo_tran_out; 
   input 	     fifo_empty;    
   input 	     emesh_wait_in; 
   output 	     fifo_read; 
   output [2*LW-1:0] emesh_tran;  
   output 	     emesh_frame; 
   reg [2:0]  launch_pointer;
   wire       last_tran;
   wire [2:0] launch_pointer_incr;
   wire [6:0] launch_sel;
   assign fifo_read = last_tran & ~emesh_wait_in;
   assign last_tran = (launch_pointer[2:0] == 3'b110);
   assign launch_pointer_incr[2:0] = last_tran ? 3'b000 : (launch_pointer[2:0] + 3'b001);
   always @ (posedge cclk or posedge reset_sync_1)
     if(reset_sync_1)
       launch_pointer[2:0] <= 3'b000;
     else if(cclk_en)
       if (~(fifo_empty | emesh_wait_in))
	 launch_pointer[2:0] <= launch_pointer_incr[2:0];
   assign launch_sel[0] = (launch_pointer[2:0] == 3'b000);
   assign launch_sel[1] = (launch_pointer[2:0] == 3'b001);
   assign launch_sel[2] = (launch_pointer[2:0] == 3'b010);
   assign launch_sel[3] = (launch_pointer[2:0] == 3'b011);
   assign launch_sel[4] = (launch_pointer[2:0] == 3'b100);
   assign launch_sel[5] = (launch_pointer[2:0] == 3'b101);
   assign launch_sel[6] = (launch_pointer[2:0] == 3'b110);
   assign emesh_frame  =  ~(fifo_empty | last_tran);
   e16_mux7 #(2*LW) mux7(
		     .out (emesh_tran[2*LW-1:0]),
		     .in0 (fifo_tran_out[2*LW-1:0]),      .sel0 (launch_sel[0]),
		     .in1 (fifo_tran_out[4*LW-1:2*LW]),   .sel1 (launch_sel[1]),
		     .in2 (fifo_tran_out[6*LW-1:4*LW]),   .sel2 (launch_sel[2]),
		     .in3 (fifo_tran_out[8*LW-1:6*LW]),   .sel3 (launch_sel[3]),
		     .in4 (fifo_tran_out[10*LW-1:8*LW]),  .sel4 (launch_sel[4]),
		     .in5 (fifo_tran_out[12*LW-1:10*LW]), .sel5 (launch_sel[5]),
		     .in6 (fifo_tran_out[14*LW-1:12*LW]), .sel6 (launch_sel[6]));
endmodule 
module link_rxi_mesh_launcher (
   mesh_fifo_read, emesh_tran_dis, access, write, datamode, ctrlmode,
   data, dstaddr, srcaddr,
   ext_yid_k, ext_xid_k, who_am_i, cfg_extcomp_dis, fifo_tran_out,
   fifo_empty, mesh_wait_in
   );
   parameter AW   = `CFG_AW  ;
   parameter DW   = `CFG_DW  ;
   parameter LW   = `CFG_LW  ;
   input [3:0] 	     ext_yid_k;
   input [3:0] 	     ext_xid_k;
   input [3:0] 	     who_am_i;
   input 	     cfg_extcomp_dis;
   input [14*LW-1:0] fifo_tran_out; 
   input 	     fifo_empty;    
   input 	     mesh_wait_in; 
   output 	     mesh_fifo_read; 
   output 	     emesh_tran_dis;
   output 	     access;
   output 	     write;
   output [1:0]      datamode;
   output [3:0]      ctrlmode;   		    
   output [DW-1:0]   data;
   output [AW-1:0]   dstaddr;
   output [AW-1:0]   srcaddr;   
   wire [AW-1:0] srcaddr_int;
   wire [AW-1:0] srcaddr_multicast;
   wire 	 access_int;
   wire 	 multicast_match;
   wire [1:0] 	 srcaddr_int_ycoord;
   wire [1:0] 	 srcaddr_int_xcoord;
   wire [1:0] 	 north_srcaddr_int_ycoord;
   wire [1:0] 	 north_srcaddr_int_xcoord;
   wire [1:0] 	 east_srcaddr_int_ycoord;
   wire [1:0] 	 east_srcaddr_int_xcoord;
   wire [1:0] 	 south_srcaddr_int_ycoord;
   wire [1:0] 	 south_srcaddr_int_xcoord;
   wire [1:0] 	 west_srcaddr_int_ycoord;
   wire [1:0] 	 west_srcaddr_int_xcoord;
   wire [3:0] 	 dst_y_k;
   wire [3:0] 	 dst_x_k;
   wire 	 west_east_corner_tran;
   wire 	 north_south_corner_tran;
   wire [3:0] 	 corner_tran;
   wire 	 corner_tran_match;
   wire 	 mesh_tran_match;
   assign emesh_tran_dis = access;
   assign access = ~fifo_empty & access_int & 
		   (corner_tran_match | multicast_match | mesh_tran_match);
   assign mesh_fifo_read = access & ~mesh_wait_in;
   assign ctrlmode[3:0]   =  fifo_tran_out[2*LW-1:2*LW-4];
   assign dstaddr[AW-1:0] = {fifo_tran_out[2*LW-5:0],
                             fifo_tran_out[4*LW-1:2*LW],
                             fifo_tran_out[6*LW-1:6*LW-4]};
   assign datamode[1:0]   =  fifo_tran_out[6*LW-5:6*LW-6];
   assign write           =  fifo_tran_out[6*LW-7]; 
   assign access_int      =  fifo_tran_out[5*LW]; 
   assign data[DW-1:0]    = {fifo_tran_out[5*LW-1:4*LW],
                             fifo_tran_out[8*LW-1:6*LW],
                             fifo_tran_out[10*LW-1:9*LW]};
   assign srcaddr_int[AW-1:0] = {fifo_tran_out[9*LW-1:8*LW],
                                 fifo_tran_out[12*LW-1:10*LW],
                                 fifo_tran_out[14*LW-1:13*LW]};
   assign multicast_match = write & ~cfg_extcomp_dis &
			    (ctrlmode[1:0]==2'b11) & ~(datamode[1:0] == 2'b11);
   assign north_srcaddr_int_ycoord[1:0] = 2'b00;
   assign east_srcaddr_int_ycoord[1:0]  = 2'b00;
   assign south_srcaddr_int_ycoord[1:0] = 2'b11;
   assign west_srcaddr_int_ycoord[1:0]  = 2'b00;
   assign north_srcaddr_int_xcoord[1:0] = 2'b00;
   assign east_srcaddr_int_xcoord[1:0]  = 2'b11;
   assign south_srcaddr_int_xcoord[1:0] = 2'b00;
   assign west_srcaddr_int_xcoord[1:0]  = 2'b00;
   assign srcaddr_int_ycoord[1:0] = {(2){who_am_i[3]}} & north_srcaddr_int_ycoord[1:0]|
				    {(2){who_am_i[2]}} & east_srcaddr_int_ycoord[1:0] |
				    {(2){who_am_i[1]}} & south_srcaddr_int_ycoord[1:0]|
				    {(2){who_am_i[0]}} & west_srcaddr_int_ycoord[1:0];
   assign srcaddr_int_xcoord[1:0] = {(2){who_am_i[3]}} & north_srcaddr_int_xcoord[1:0]|
				    {(2){who_am_i[2]}} & east_srcaddr_int_xcoord[1:0] |
				    {(2){who_am_i[1]}} & south_srcaddr_int_xcoord[1:0]|
				    {(2){who_am_i[0]}} & west_srcaddr_int_xcoord[1:0];
   assign srcaddr_multicast[AW-1:0] = {srcaddr_int[31:28],srcaddr_int_ycoord[1:0],
             		               srcaddr_int[25:22],srcaddr_int_xcoord[1:0],
                                       srcaddr_int[19:0]};
   assign srcaddr[AW-1:0] = multicast_match ? srcaddr_multicast[AW-1:0] : 
			                      srcaddr_int[AW-1:0];
   assign dst_y_k[3:0] = dstaddr[31:28];
   assign dst_x_k[3:0] = dstaddr[25:22];
   assign west_east_corner_tran = ((dst_x_k[3:0] == ext_xid_k[3:0]) &
				  ~(dst_y_k[3:0] == ext_yid_k[3:0]));
   assign north_south_corner_tran = (~(dst_x_k[3:0] == ext_xid_k[3:0]) &
				      (dst_y_k[3:0] == ext_yid_k[3:0]));
   assign corner_tran[3:0] = {north_south_corner_tran, west_east_corner_tran,
                              north_south_corner_tran, west_east_corner_tran};
   assign corner_tran_match = ~cfg_extcomp_dis & (|(corner_tran[3:0] & who_am_i[3:0]));
   assign mesh_tran_match = cfg_extcomp_dis | 
			    (~multicast_match & ((dst_x_k[3:0] == ext_xid_k[3:0]) &
			                         (dst_y_k[3:0] == ext_yid_k[3:0])));
endmodule 
module link_rxi_rd (
   rxi_rd_wait, c0_rdmesh_frame_out, c0_rdmesh_tran_out,
   c1_rdmesh_frame_out, c1_rdmesh_tran_out, c2_rdmesh_frame_out,
   c2_rdmesh_tran_out, c3_rdmesh_frame_out, c3_rdmesh_tran_out,
   reset_sync_1, ext_yid_k, ext_xid_k, vertical_k, who_am_i, cfg_extcomp_dis,
   rxi_data, rxi_lclk, rxi_frame, c0_clk_in, c1_clk_in, c2_clk_in,
   c3_clk_in, c0_rdmesh_wait_in, c1_rdmesh_wait_in, c2_rdmesh_wait_in,
   c3_rdmesh_wait_in
   );
   parameter LW   = `CFG_LW;
   input             reset_sync_1;     
   input [3:0] 	     ext_yid_k; 
   input [3:0] 	     ext_xid_k; 
   input             vertical_k;
   input [3:0] 	     who_am_i;  
   input 	     cfg_extcomp_dis;
   input [LW-1:0]    rxi_data;  
   input             rxi_lclk;  
   input             rxi_frame; 
   input             c0_clk_in; 
   input             c1_clk_in; 
   input             c2_clk_in; 
   input             c3_clk_in; 
   input             c0_rdmesh_wait_in; 
   input             c1_rdmesh_wait_in; 
   input             c2_rdmesh_wait_in; 
   input             c3_rdmesh_wait_in; 
   output 	     rxi_rd_wait;  
   output            c0_rdmesh_frame_out; 
   output [2*LW-1:0] c0_rdmesh_tran_out;  
   output            c1_rdmesh_frame_out; 
   output [2*LW-1:0] c1_rdmesh_tran_out;  
   output            c2_rdmesh_frame_out; 
   output [2*LW-1:0] c2_rdmesh_tran_out;  
   output            c3_rdmesh_frame_out; 
   output [2*LW-1:0] c3_rdmesh_tran_out;  
   wire			c0_fifo_access_rlc;	
   wire			c0_fifo_full_rlc;	
   wire			c1_fifo_access_rlc;	
   wire			c1_fifo_full_rlc;	
   wire			c2_fifo_access_rlc;	
   wire			c2_fifo_full_rlc;	
   wire			c3_fifo_access_rlc;	
   wire			c3_fifo_full_rlc;	
   wire [14*LW-1:0]	rxi_assembled_tran_rlc;	
   link_rxi_buffer link_rxi_buffer(
				   .rxi_wait		(rxi_rd_wait),	 
				   .rxi_assembled_tran	(rxi_assembled_tran_rlc[14*LW-1:0]), 
				   .rxi_c0_access	(c0_fifo_access_rlc), 
				   .rxi_c1_access	(c1_fifo_access_rlc), 
				   .rxi_c2_access	(c2_fifo_access_rlc), 
				   .rxi_c3_access	(c3_fifo_access_rlc), 
				   .reset		(reset_sync_1),	 
				   .vertical_k		(vertical_k),	 
				   .ext_yid_k		(ext_yid_k[3:0]), 
				   .ext_xid_k		(ext_xid_k[3:0]), 
				   .rxi_data		(rxi_data[LW-1:0]), 
				   .rxi_lclk		(rxi_lclk),	 
				   .rxi_frame		(rxi_frame),	 
				   .rxi_rd		(1'b1),		 
				   .cfg_extcomp_dis	(cfg_extcomp_dis), 
				   .c0_fifo_full	(c0_fifo_full_rlc), 
				   .c1_fifo_full	(c1_fifo_full_rlc), 
				   .c2_fifo_full	(c2_fifo_full_rlc), 
				   .c3_fifo_full	(c3_fifo_full_rlc)); 
endmodule 
module link_rxi_router (
   fifo_read_cvre, read_out, write_out, dst_addr_out, src_addr_out,
   data_out, datamode_out, ctrlmode_out,
   fifo_data_out_cvre, fifo_empty_cvre, wait_in
   );
   parameter AW  = 32;
   parameter MDW = 32;
   parameter FW  = 112;
   parameter XW  = 6;
   parameter YW  = 6;
   parameter ZW  = 6;
   parameter IAW = 20;
   input [FW-1:0]   fifo_data_out_cvre;
   input            fifo_empty_cvre;
   output           fifo_read_cvre;     
   input             wait_in;
   output            read_out;
   output            write_out;
   output [AW-1:0]   dst_addr_out;
   output [AW-1:0]   src_addr_out;
   output [MDW-1:0]  data_out;    
   output [1:0]      datamode_out;
   output [3:0]      ctrlmode_out;
   wire           mesh_write_cvre;
   wire           mesh_read_cvre;
   wire [1:0]     mesh_datamode_cvre;
   wire [3:0]     mesh_ctrlmode_cvre;
   wire [7:0]     mesh_reserved_cvre;
   wire [MDW-1:0] mesh_data_cvre;
   wire [AW-1:0]  mesh_src_addr_cvre;
   wire [AW-1:0]  mesh_dst_addr_cvre;
   wire [1:0]     compare_addr;
   wire           request_cvre;
   assign mesh_write_cvre           = fifo_data_out_cvre[0];
   assign mesh_read_cvre            = fifo_data_out_cvre[1];
   assign mesh_datamode_cvre[1:0]   = fifo_data_out_cvre[3:2];
   assign mesh_ctrlmode_cvre[3:0]   = fifo_data_out_cvre[7:4];
   assign mesh_reserved_cvre[7:0]   = fifo_data_out_cvre[15:8];
   assign mesh_data_cvre[MDW-1:0]   = fifo_data_out_cvre[47:16];
   assign mesh_dst_addr_cvre[AW-1:0]= fifo_data_out_cvre[79:48];
   assign mesh_src_addr_cvre[AW-1:0]= fifo_data_out_cvre[111:80];
   assign request_cvre         = ~fifo_empty_cvre;
   assign fifo_read_cvre       = (request_cvre  & ~wait_in);
   assign read_out             = request_cvre & mesh_read_cvre;
   assign write_out            = request_cvre & mesh_write_cvre;
   assign dst_addr_out[AW-1:0] = mesh_dst_addr_cvre[AW-1:0];
   assign src_addr_out[AW-1:0] = mesh_src_addr_cvre[AW-1:0];
   assign data_out[MDW-1:0]    = mesh_data_cvre[MDW-1:0];   
   assign datamode_out[1:0]    = mesh_datamode_cvre[1:0];
   assign ctrlmode_out[3:0]    = mesh_ctrlmode_cvre[3:0];
endmodule 
module link_rxi_wr(
   rxi_wr_wait, c0_emesh_frame_out, c0_emesh_tran_out,
   c3_emesh_frame_out, c3_emesh_tran_out, c0_mesh_access_out,
   c0_mesh_write_out, c0_mesh_dstaddr_out, c0_mesh_srcaddr_out,
   c0_mesh_data_out, c0_mesh_datamode_out, c0_mesh_ctrlmode_out,
   c3_mesh_access_out, c3_mesh_write_out, c3_mesh_dstaddr_out,
   c3_mesh_srcaddr_out, c3_mesh_data_out, c3_mesh_datamode_out,
   c3_mesh_ctrlmode_out,
   reset_sync_1, ext_yid_k, ext_xid_k, vertical_k, who_am_i, cfg_extcomp_dis,
   rxi_data, rxi_lclk, rxi_frame, c0_clk_in, c3_clk_in,
   c0_emesh_wait_in, c3_emesh_wait_in, c0_mesh_wait_in,
   c3_mesh_wait_in
   );
   parameter LW   = `CFG_LW;
   parameter DW   = `CFG_DW;
   parameter AW   = `CFG_AW;
   input             reset_sync_1;     
   input [3:0] 	     ext_yid_k; 
   input [3:0] 	     ext_xid_k; 
   input             vertical_k;
   input [3:0] 	     who_am_i;  
   input 	     cfg_extcomp_dis;
   input [LW-1:0]    rxi_data;  
   input             rxi_lclk;  
   input             rxi_frame; 
   input             c0_clk_in; 
   input             c3_clk_in; 
   input             c0_emesh_wait_in;  
   input             c3_emesh_wait_in;  
   input 	     c0_mesh_wait_in;   
   input 	     c3_mesh_wait_in;   
   output 	     rxi_wr_wait;  
   output            c0_emesh_frame_out; 
   output [2*LW-1:0] c0_emesh_tran_out;  
   output            c3_emesh_frame_out; 
   output [2*LW-1:0] c3_emesh_tran_out;  
   output 	     c0_mesh_access_out;  
   output 	     c0_mesh_write_out;   
   output [AW-1:0]   c0_mesh_dstaddr_out; 
   output [AW-1:0]   c0_mesh_srcaddr_out; 
   output [DW-1:0]   c0_mesh_data_out;    
   output [1:0]      c0_mesh_datamode_out;
   output [3:0]      c0_mesh_ctrlmode_out;
   output 	     c3_mesh_access_out;  
   output 	     c3_mesh_write_out;   
   output [AW-1:0]   c3_mesh_dstaddr_out; 
   output [AW-1:0]   c3_mesh_srcaddr_out; 
   output [DW-1:0]   c3_mesh_data_out;    
   output [1:0]      c3_mesh_datamode_out;
   output [3:0]      c3_mesh_ctrlmode_out;
   wire			c0_fifo_access;		
   wire			c0_fifo_full_rlc;	
   wire			c1_fifo_access;		
   wire			c2_fifo_access;		
   wire			c3_fifo_access;		
   wire			c3_fifo_full_rlc;	
   wire [14*LW-1:0]	rxi_assembled_tran_rlc;	
   wire    c0_fifo_access_rlc;
   wire    c3_fifo_access_rlc;
   link_rxi_buffer link_rxi_buffer(
				   .rxi_wait		(rxi_wr_wait),	 
				   .rxi_assembled_tran	(rxi_assembled_tran_rlc[14*LW-1:0]), 
				   .rxi_c0_access	(c0_fifo_access), 
				   .rxi_c1_access	(c1_fifo_access), 
				   .rxi_c2_access	(c2_fifo_access), 
				   .rxi_c3_access	(c3_fifo_access), 
				   .reset		(reset_sync_1),	 
				   .vertical_k		(vertical_k),	 
				   .ext_yid_k		(ext_yid_k[3:0]), 
				   .ext_xid_k		(ext_xid_k[3:0]), 
				   .rxi_data		(rxi_data[LW-1:0]), 
				   .rxi_lclk		(rxi_lclk),	 
				   .rxi_frame		(rxi_frame),	 
				   .rxi_rd		(1'b0),		 
				   .cfg_extcomp_dis	(cfg_extcomp_dis), 
				   .c0_fifo_full	(c0_fifo_full_rlc), 
				   .c1_fifo_full	(1'b0),		 
				   .c2_fifo_full	(1'b0),		 
				   .c3_fifo_full	(c3_fifo_full_rlc)); 
   assign c0_fifo_access_rlc = c0_fifo_access | c1_fifo_access;
   assign c3_fifo_access_rlc = c2_fifo_access | c3_fifo_access;
   link_rxi_double_channel c0_link_rxi_double_channel(
						      .fifo_full_rlc	(c0_fifo_full_rlc), 
						      .emesh_tran_out	(c0_emesh_tran_out[2*LW-1:0]), 
						      .emesh_frame_out	(c0_emesh_frame_out), 
						      .mesh_access_out	(c0_mesh_access_out), 
						      .mesh_write_out	(c0_mesh_write_out), 
						      .mesh_dstaddr_out	(c0_mesh_dstaddr_out[AW-1:0]), 
						      .mesh_srcaddr_out	(c0_mesh_srcaddr_out[AW-1:0]), 
						      .mesh_data_out	(c0_mesh_data_out[DW-1:0]), 
						      .mesh_datamode_out(c0_mesh_datamode_out[1:0]), 
						      .mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]), 
						      .reset		(reset_sync_1),
						      .cclk		(c0_clk_in),	 
						      .cclk_en		(1'b1),		 
						      .ext_yid_k	(ext_yid_k[3:0]),
						      .ext_xid_k	(ext_xid_k[3:0]),
						      .rxi_lclk		(rxi_lclk),
						      .who_am_i		(who_am_i[3:0]),
						      .cfg_extcomp_dis	(cfg_extcomp_dis),
						      .rxi_assembled_tran_rlc(rxi_assembled_tran_rlc[14*LW-1:0]),
						      .fifo_access_rlc	(c0_fifo_access_rlc), 
						      .emesh_wait_in	(c0_emesh_wait_in), 
						      .mesh_wait_in	(c0_mesh_wait_in)); 
   link_rxi_double_channel c3_link_rxi_double_channel(
						      .fifo_full_rlc	(c3_fifo_full_rlc), 
						      .emesh_tran_out	(c3_emesh_tran_out[2*LW-1:0]), 
						      .emesh_frame_out	(c3_emesh_frame_out), 
						      .mesh_access_out	(c3_mesh_access_out), 
						      .mesh_write_out	(c3_mesh_write_out), 
						      .mesh_dstaddr_out	(c3_mesh_dstaddr_out[AW-1:0]), 
						      .mesh_srcaddr_out	(c3_mesh_srcaddr_out[AW-1:0]), 
						      .mesh_data_out	(c3_mesh_data_out[DW-1:0]), 
						      .mesh_datamode_out(c3_mesh_datamode_out[1:0]), 
						      .mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]), 
						      .reset		(reset_sync_1),
						      .cclk		(c3_clk_in),	 
						      .cclk_en		(1'b1),		 
						      .ext_yid_k	(ext_yid_k[3:0]),
						      .ext_xid_k	(ext_xid_k[3:0]),
						      .rxi_lclk		(rxi_lclk),
						      .who_am_i		(who_am_i[3:0]),
						      .cfg_extcomp_dis	(cfg_extcomp_dis),
						      .rxi_assembled_tran_rlc(rxi_assembled_tran_rlc[14*LW-1:0]),
						      .fifo_access_rlc	(c3_fifo_access_rlc), 
						      .emesh_wait_in	(c3_emesh_wait_in), 
						      .mesh_wait_in	(c3_mesh_wait_in)); 
endmodule 
module link_transmitter (
   txo_data, txo_lclk90, txo_frame, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_rdmesh_wait_out, c1_rdmesh_wait_out, c2_rdmesh_wait_out,
   c3_rdmesh_wait_out, c0_mesh_wait_out, c3_mesh_wait_out,
   c3_emesh_tran_in, c3_emesh_frame_in, c2_emesh_tran_in,
   c2_emesh_frame_in, c1_emesh_tran_in, c1_emesh_frame_in,
   c0_emesh_tran_in, c0_emesh_frame_in, reset_sync_1, ext_yid_k, ext_xid_k,
   who_am_i, txo_cfg_reg, txo_wr_wait, txo_rd_wait, c0_clk_in,
   c1_clk_in, c2_clk_in, c3_clk_in, c0_mesh_access_in,
   c0_mesh_write_in, c0_mesh_dstaddr_in, c0_mesh_srcaddr_in,
   c0_mesh_data_in, c0_mesh_datamode_in, c0_mesh_ctrlmode_in,
   c3_mesh_access_in, c3_mesh_write_in, c3_mesh_dstaddr_in,
   c3_mesh_srcaddr_in, c3_mesh_data_in, c3_mesh_datamode_in,
   c3_mesh_ctrlmode_in
   );
   parameter LW   = `CFG_LW  ;
   parameter AW   = `CFG_AW  ;
   parameter DW   = `CFG_DW  ;
   input            reset_sync_1;
   input [3:0] 	    ext_yid_k; 
   input [3:0] 	    ext_xid_k; 
   input [3:0] 	    who_am_i;  
   input [5:0] 	    txo_cfg_reg; 
   input 	    txo_wr_wait; 
   input 	    txo_rd_wait; 
   input 	    c0_clk_in;         
   input 	    c1_clk_in;         
   input 	    c2_clk_in;         
   input 	    c3_clk_in;         
   input 	    c0_mesh_access_in;  
   input 	    c0_mesh_write_in;   
   input [AW-1:0]   c0_mesh_dstaddr_in; 
   input [AW-1:0]   c0_mesh_srcaddr_in; 
   input [DW-1:0]   c0_mesh_data_in;    
   input [1:0] 	    c0_mesh_datamode_in;
   input [3:0] 	    c0_mesh_ctrlmode_in;
   input 	    c3_mesh_access_in;  
   input 	    c3_mesh_write_in;   
   input [AW-1:0]   c3_mesh_dstaddr_in; 
   input [AW-1:0]   c3_mesh_srcaddr_in; 
   input [DW-1:0]   c3_mesh_data_in;    
   input [1:0] 	    c3_mesh_datamode_in;
   input [3:0] 	    c3_mesh_ctrlmode_in;
   output  [LW-1:0]  txo_data;      
   output            txo_lclk90;    
   output            txo_frame;     
   output 	     c0_emesh_wait_out; 
   output 	     c1_emesh_wait_out; 
   output 	     c2_emesh_wait_out; 
   output 	     c3_emesh_wait_out; 
   output 	     c0_rdmesh_wait_out; 
   output 	     c1_rdmesh_wait_out; 
   output 	     c2_rdmesh_wait_out; 
   output 	     c3_rdmesh_wait_out; 
   output 	     c0_mesh_wait_out;  
   output 	     c3_mesh_wait_out;  
   wire 	     txo_lclk;  
   wire 	     txo_lclk90;
   input		c0_emesh_frame_in;	
   input [2*LW-1:0]	c0_emesh_tran_in;	
   input		c1_emesh_frame_in;	
   input [2*LW-1:0]	c1_emesh_tran_in;	
   input		c2_emesh_frame_in;	
   input [2*LW-1:0]	c2_emesh_tran_in;	
   input		c3_emesh_frame_in;	
   input [2*LW-1:0]	c3_emesh_tran_in;	
   wire [LW-1:0]	txo_wr_data_even;	
   wire [LW-1:0]	txo_wr_data_odd;	
   wire			txo_wr_frame;		
   wire			txo_wr_launch_req_tlc;	
   wire			txo_wr_rotate_dis;	
   e16_clock_divider clock_divider (.clk_out	(txo_lclk),
				.clk_out90      (txo_lclk90),
				.clk_in		(c1_clk_in),
				.reset		(reset_sync_1),
				.div_cfg	(4'b0)
				);
   link_txo_interface link_txo_interface(
					 .txo_data		(txo_data[LW-1:0]),
					 .txo_frame		(txo_frame),
					 .txo_wr_wait_int	(txo_wr_wait_int),
					 .txo_rd_wait_int	(txo_rd_wait_int),
					 .txo_lclk		(txo_lclk),
					 .reset			(reset_sync_1),
					 .txo_wr_data_even	(txo_wr_data_even[LW-1:0]),
					 .txo_wr_data_odd	(txo_wr_data_odd[LW-1:0]),
					 .txo_wr_frame		(txo_wr_frame),
					 .txo_wr_launch_req_tlc	(txo_wr_launch_req_tlc),
					 .txo_wr_rotate_dis	(txo_wr_rotate_dis),
					 .txo_rd_data_even	(8'd0),
					 .txo_rd_data_odd	(8'd0),
					 .txo_rd_frame		(1'd0),
					 .txo_rd_launch_req_tlc	(1'd0),
					 .txo_rd_rotate_dis	(1'd0)
					 ); 
   link_txo_wr link_txo_wr(.cfg_burst_dis	(txo_cfg_reg[4]),
			   .cfg_multicast_dis	(txo_cfg_reg[5]),
			   .txo_wr_wait_int	(txo_wr_wait_int),
			   .txo_wr_data_even	(txo_wr_data_even[LW-1:0]),
			   .txo_wr_data_odd	(txo_wr_data_odd[LW-1:0]),
			   .txo_wr_frame	(txo_wr_frame),
			   .txo_wr_launch_req_tlc(txo_wr_launch_req_tlc),
			   .txo_wr_rotate_dis	(txo_wr_rotate_dis),
			   .c0_emesh_wait_out	(c0_emesh_wait_out),
			   .c1_emesh_wait_out	(c1_emesh_wait_out),
			   .c2_emesh_wait_out	(c2_emesh_wait_out),
			   .c3_emesh_wait_out	(c3_emesh_wait_out),
			   .c0_mesh_wait_out	(c0_mesh_wait_out),
			   .c3_mesh_wait_out	(c3_mesh_wait_out),
			   .txo_lclk		(txo_lclk),
			   .reset		(reset_sync_1),
			   .ext_yid_k		(ext_yid_k[3:0]),
			   .ext_xid_k		(ext_xid_k[3:0]),
			   .who_am_i		(who_am_i[3:0]),
			   .txo_wr_wait		(txo_wr_wait),
			   .c0_clk_in		(c0_clk_in),
			   .c1_clk_in		(c1_clk_in),
			   .c2_clk_in		(c2_clk_in),
			   .c3_clk_in		(c3_clk_in),
			   .c0_emesh_tran_in	(c0_emesh_tran_in[2*LW-1:0]),
			   .c0_emesh_frame_in	(c0_emesh_frame_in),
			   .c1_emesh_tran_in	(c1_emesh_tran_in[2*LW-1:0]),
			   .c1_emesh_frame_in	(c1_emesh_frame_in),
			   .c2_emesh_tran_in	(c2_emesh_tran_in[2*LW-1:0]),
			   .c2_emesh_frame_in	(c2_emesh_frame_in),
			   .c3_emesh_tran_in	(c3_emesh_tran_in[2*LW-1:0]),
			   .c3_emesh_frame_in	(c3_emesh_frame_in),
			   .c0_mesh_access_in	(c0_mesh_access_in),
			   .c0_mesh_write_in	(c0_mesh_write_in),
			   .c0_mesh_dstaddr_in	(c0_mesh_dstaddr_in[AW-1:0]),
			   .c0_mesh_srcaddr_in	(c0_mesh_srcaddr_in[AW-1:0]),
			   .c0_mesh_data_in	(c0_mesh_data_in[DW-1:0]),
			   .c0_mesh_datamode_in	(c0_mesh_datamode_in[1:0]),
			   .c0_mesh_ctrlmode_in	(c0_mesh_ctrlmode_in[3:0]),
			   .c3_mesh_access_in	(c3_mesh_access_in),
			   .c3_mesh_write_in	(c3_mesh_write_in),
			   .c3_mesh_dstaddr_in	(c3_mesh_dstaddr_in[AW-1:0]),
			   .c3_mesh_srcaddr_in	(c3_mesh_srcaddr_in[AW-1:0]),
			   .c3_mesh_data_in	(c3_mesh_data_in[DW-1:0]),
			   .c3_mesh_datamode_in	(c3_mesh_datamode_in[1:0]),
			   .c3_mesh_ctrlmode_in	(c3_mesh_ctrlmode_in[3:0]));
endmodule 
module link_txo_arbiter(
   txo_launch_req_tlc, txo_rotate_dis_tlc, c0_txo_launch_ack_tlc,
   c1_txo_launch_ack_tlc, c2_txo_launch_ack_tlc,
   c3_txo_launch_ack_tlc,
   txo_lclk, reset_sync_1, txo_wait, txo_wait_int, c0_txo_launch_req_tlc,
   c0_txo_rotate_dis, c1_txo_launch_req_tlc, c1_txo_rotate_dis,
   c2_txo_launch_req_tlc, c2_txo_rotate_dis, c3_txo_launch_req_tlc,
   c3_txo_rotate_dis
   );
   input       txo_lclk;   
   input       reset_sync_1;
   input       txo_wait; 
   input       txo_wait_int; 
   input       c0_txo_launch_req_tlc; 
   input       c0_txo_rotate_dis;     
   input       c1_txo_launch_req_tlc; 
   input       c1_txo_rotate_dis;     
   input       c2_txo_launch_req_tlc; 
   input       c2_txo_rotate_dis;     
   input       c3_txo_launch_req_tlc; 
   input       c3_txo_rotate_dis;     
   output      txo_launch_req_tlc;
   output      txo_rotate_dis_tlc;
   output      c0_txo_launch_ack_tlc;
   output      c1_txo_launch_ack_tlc;
   output      c2_txo_launch_ack_tlc;
   output      c3_txo_launch_ack_tlc;
   reg [3:0]   grants_reg;
   wire [3:0]  txo_rotate_dis;
   wire        en_arbitration;
   wire        en_rotate;
   wire [3:0]   grants;             
   wire [3:0] 	requests_unmasked;  
   wire [3:0]   requests;           
   wire 	txo_wait_tlc;
   e16_synchronizer #(.DW(1)) synchronizer(.out	(txo_wait_tlc),
			               .in	(txo_wait),
				       .clk	(txo_lclk),
				       .reset	(reset_sync_1));
   assign txo_launch_req_tlc = c0_txo_launch_req_tlc | c1_txo_launch_req_tlc |
			       c2_txo_launch_req_tlc | c3_txo_launch_req_tlc;
   assign txo_rotate_dis_tlc = c0_txo_rotate_dis | c1_txo_rotate_dis |
			       c2_txo_rotate_dis | c3_txo_rotate_dis;
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       grants_reg[3:0] <= 4'b0000;
     else
       grants_reg[3:0] <= grants[3:0];
   assign txo_rotate_dis[3:0] = {c3_txo_rotate_dis,
				 c2_txo_rotate_dis,
				 c1_txo_rotate_dis,
				 c0_txo_rotate_dis};
   assign en_rotate = ~(|(grants_reg[3:0] & txo_rotate_dis[3:0]));
   assign en_arbitration = ~txo_wait_tlc | (|(txo_rotate_dis[3:0]));
   assign requests_unmasked[3:0] = {c3_txo_launch_req_tlc,
                                    c2_txo_launch_req_tlc,
                                    c1_txo_launch_req_tlc,
                                    c0_txo_launch_req_tlc};
   assign requests[3:0] = {(4){en_arbitration}} & 
			  requests_unmasked[3:0] & (grants_reg[3:0] | {(4){en_rotate}});
   assign c3_txo_launch_ack_tlc   = grants[3] & ~txo_wait_int;
   assign c2_txo_launch_ack_tlc   = grants[2] & ~txo_wait_int;
   assign c1_txo_launch_ack_tlc   = grants[1] & ~txo_wait_int;
   assign c0_txo_launch_ack_tlc   = grants[0] & ~txo_wait_int;
   e16_arbiter_roundrobin #(.ARW(4)) arbiter_roundrobin(
						    .grants		(grants[3:0]),	 
						    .clk		(txo_lclk),	 
						    .clk_en		(1'b1),		 
						    .reset		(reset_sync_1),
						    .en_rotate		(en_rotate),
						    .requests		(requests[3:0])); 
endmodule 
module link_txo_buffer(
   txo_data_even, txo_data_odd, txo_frame,
   c0_tran_frame_tlc, c0_tran_byte_even_tlc, c0_tran_byte_odd_tlc,
   c1_tran_frame_tlc, c1_tran_byte_even_tlc, c1_tran_byte_odd_tlc,
   c2_tran_frame_tlc, c2_tran_byte_even_tlc, c2_tran_byte_odd_tlc,
   c3_tran_frame_tlc, c3_tran_byte_even_tlc, c3_tran_byte_odd_tlc
   );
   parameter LW  = `CFG_LW;
   input          c0_tran_frame_tlc;      
   input [LW-1:0] c0_tran_byte_even_tlc;  
   input [LW-1:0] c0_tran_byte_odd_tlc;   
   input          c1_tran_frame_tlc;      
   input [LW-1:0] c1_tran_byte_even_tlc;  
   input [LW-1:0] c1_tran_byte_odd_tlc;   
   input          c2_tran_frame_tlc;      
   input [LW-1:0] c2_tran_byte_even_tlc;  
   input [LW-1:0] c2_tran_byte_odd_tlc;   
   input          c3_tran_frame_tlc;      
   input [LW-1:0] c3_tran_byte_even_tlc;  
   input [LW-1:0] c3_tran_byte_odd_tlc;   
   output [LW-1:0]  txo_data_even; 
   output [LW-1:0]  txo_data_odd;  
   output 	    txo_frame;     
   wire 	 txo_frame;     
   wire [LW-1:0] txo_data_even; 
   wire [LW-1:0] txo_data_odd;  
   assign txo_frame = c0_tran_frame_tlc;
   assign txo_data_even[LW-1:0] = c0_tran_byte_even_tlc[LW-1:0];
   assign txo_data_odd[LW-1:0] = c0_tran_byte_odd_tlc[LW-1:0];
endmodule 
module link_txo_channel (
   emesh_wait_out, txo_launch_req_tlc, txo_rotate_dis, tran_frame_tlc,
   tran_byte_even_tlc, tran_byte_odd_tlc,
   cclk, cclk_en, txo_lclk, reset_sync_1, txo_rd, txo_cid, cfg_burst_dis,
   emesh_tran_in, emesh_frame_in, txo_launch_ack_tlc
   );
   parameter AW   = `CFG_AW  ;
   parameter DW   = `CFG_DW  ;
   parameter LW   = `CFG_LW  ;
   parameter FW   = `CFG_NW*`CFG_LW;
   parameter FAD  = 5; 
   input 	  cclk;     
   input 	  cclk_en;  
   input 	  txo_lclk; 
   input          reset_sync_1;
   input 	  txo_rd;  
   input [1:0] 	  txo_cid; 
   input 	  cfg_burst_dis; 
   input [2*LW-1:0] emesh_tran_in;  
   input 	    emesh_frame_in; 
   input 	    txo_launch_ack_tlc;
   output 	    emesh_wait_out; 
   output 	    txo_launch_req_tlc; 
   output 	    txo_rotate_dis; 
   output 	    tran_frame_tlc;       
   output [LW-1:0]  tran_byte_even_tlc;  
   output [LW-1:0]  tran_byte_odd_tlc;   
   wire			check_next_dstaddr_tlc;	
   wire [2*LW-1:0]	fifo_out_tlc;		
   wire			frame_in;		
   wire			next_access_tlc;	
   wire [3:0]		next_ctrlmode_tlc;	
   wire [1:0]		next_datamode_tlc;	
   wire [AW-1:0]	next_dstaddr_tlc;	
   wire			next_write_tlc;		
   wire [FAD:0]		rd_read_tlc;		
   wire [2*LW-1:0]	tran_in;		
   wire			tran_written_tlc;	
   wire			wr_fifo_full;		
endmodule 
module link_txo_fifo (
   wr_fifo_full, fifo_out_tlc, tran_written_tlc, next_ctrlmode_tlc,
   next_dstaddr_tlc, next_datamode_tlc, next_write_tlc,
   next_access_tlc,
   reset_sync_1, cclk, cclk_en, txo_lclk, tran_in, frame_in, rd_read_tlc,
   check_next_dstaddr_tlc
   );
   parameter AW   = `CFG_AW  ;
   parameter LW   = `CFG_LW  ;
   parameter AE   = 4; 
   parameter PE   = 7; 
   parameter FAD  = 5; 
   localparam MD = 1<<FAD;
   input          reset_sync_1;
   input 	  cclk;      
   input 	  cclk_en;   
   input 	  txo_lclk;  
   input [2*LW-1:0] tran_in;  
   input 	    frame_in; 
   input [FAD:0]    rd_read_tlc; 
   input 	    check_next_dstaddr_tlc; 
   output 	   wr_fifo_full;    
   output [2*LW-1:0] fifo_out_tlc;      
   output 	   tran_written_tlc;
   output [3:0]    next_ctrlmode_tlc;
   output [AW-1:0] next_dstaddr_tlc;
   output [1:0]    next_datamode_tlc;
   output 	   next_write_tlc;
   output 	   next_access_tlc;
   reg [LW-1:0]    even_byte;
   reg [2*LW-1:0] fifo_mem[MD-1:0];
   reg [FAD:0]   rd_gray_pointer_tlc;
   reg [FAD:0]   rd_binary_pointer_tlc;
   reg [FAD:0]   rd_addr_traninfo0_tlc;
   reg 		 frame_del;
   reg [FAD:0] 	 wr_binary_pointer;
   reg 		 wr_fifo_full;
   wire [FAD-1:0]  rd_addr_tlc;
   wire [FAD:0]    rd_binary_next_tlc;
   wire [FAD:0]    rd_gray_next_tlc;
   wire [FAD:0]    rd_addr_traninfo0_next_tlc;
   wire [FAD-1:0]  rd_addr_traninfo1_tlc;
   wire [FAD-1:0]  rd_addr_traninfo2_tlc;
   wire [2*LW-1:0] traninfo0_tlc;
   wire [2*LW-1:0] traninfo1_tlc;
   wire [2*LW-1:0] traninfo2_tlc;
   wire [FAD-1:0] wr_addr;	
   wire 	  wr_write;
   wire 	  tran_written;
   wire [FAD:0]   rd_gray_pointer;	
   wire 	  wr_fifo_full_next;
   wire [FAD:0]   wr_gray_next;
   wire [FAD:0]   wr_binary_next;
   always @ (posedge cclk or posedge reset_sync_1)
     if(reset_sync_1)
       frame_del <= 1'b0;
     else if(cclk_en)
       if(!wr_fifo_full)
	 frame_del <= frame_in;
   assign wr_write = (frame_in | frame_del) & ~wr_fifo_full;
   assign tran_written = ~frame_in & frame_del & ~wr_fifo_full;
   always @ (posedge cclk)
     if (cclk_en)
       if(!wr_fifo_full)
	 even_byte[LW-1:0] <= tran_in[LW-1:0];
   always @ (posedge cclk)
     if (cclk_en)
       if (wr_write)
	 fifo_mem[wr_addr[FAD-1:0]] <= {even_byte[LW-1:0],tran_in[2*LW-1:LW]};
   assign fifo_out_tlc[2*LW-1:0] = fifo_mem[rd_addr_tlc[FAD-1:0]];
   assign traninfo0_tlc[2*LW-1:0] = fifo_mem[rd_addr_traninfo0_tlc[FAD-1:0]];
   assign traninfo1_tlc[2*LW-1:0] = fifo_mem[rd_addr_traninfo1_tlc[FAD-1:0]];
   assign traninfo2_tlc[2*LW-1:0] = fifo_mem[rd_addr_traninfo2_tlc[FAD-1:0]];
   assign next_ctrlmode_tlc[3:0]   = traninfo0_tlc[LW-1:LW-4];
   assign next_dstaddr_tlc[AW-1:0] = {traninfo0_tlc[3:0],
                                      traninfo1_tlc[2*LW-1:0],
                                      traninfo2_tlc[2*LW-1:4]};
   assign next_datamode_tlc[1:0] = traninfo2_tlc[3:2];
   assign next_write_tlc  = traninfo2_tlc[1];
   assign next_access_tlc = traninfo2_tlc[0];
   always @(posedge cclk or posedge reset_sync_1)
     if(reset_sync_1)
       wr_binary_pointer[FAD:0]     <= {(FAD+1){1'b0}};
     else if(cclk_en)
       if(wr_write)
	 wr_binary_pointer[FAD:0]     <= wr_binary_next[FAD:0];	  
   assign wr_addr[FAD-1:0]       = wr_binary_pointer[FAD-1:0];
   assign wr_binary_next[FAD:0]  = wr_binary_pointer[FAD:0] + {{(FAD){1'b0}},wr_write};
   assign wr_gray_next[FAD:0] = {1'b0,wr_binary_next[FAD:1]} ^ wr_binary_next[FAD:0];
   assign wr_fifo_full_next = (wr_gray_next[FAD-2:0] == rd_gray_pointer[FAD-2:0]) &
                              (wr_gray_next[FAD]     ^  rd_gray_pointer[FAD])     &
                              (wr_gray_next[FAD-1]   ^  rd_gray_pointer[FAD-1]);
   always @ (posedge cclk or posedge reset_sync_1)
     if(reset_sync_1)
       wr_fifo_full <= 1'b0;
     else if(cclk_en)
       wr_fifo_full <=wr_fifo_full_next;
   always @(posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       begin
	  rd_binary_pointer_tlc[FAD:0]  <= {(FAD+1){1'b0}};
	  rd_gray_pointer_tlc[FAD:0]    <= {(FAD+1){1'b0}};
       end
     else if(|(rd_read_tlc[FAD:0]))
       begin	  rd_binary_pointer_tlc[FAD:0]  <= rd_binary_next_tlc[FAD:0];	  
	  rd_gray_pointer_tlc[FAD:0]    <= rd_gray_next_tlc[FAD:0];	  
       end
   assign rd_addr_tlc[FAD-1:0]       = rd_binary_pointer_tlc[FAD-1:0];
   assign rd_binary_next_tlc[FAD:0]  = rd_binary_pointer_tlc[FAD:0] + rd_read_tlc[FAD:0];
   assign rd_gray_next_tlc[FAD:0]  = {1'b0,rd_binary_next_tlc[FAD:1]} ^ 
                                           rd_binary_next_tlc[FAD:0];
   assign rd_addr_traninfo0_next_tlc[FAD:0] = rd_addr_traninfo0_tlc[FAD:0] + 
                                                {{(FAD-2){1'b0}},3'b111};
   always @(posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       rd_addr_traninfo0_tlc[FAD:0]   <= {(FAD){1'b0}};
     else if(check_next_dstaddr_tlc)
       rd_addr_traninfo0_tlc[FAD-1:0] <= rd_addr_traninfo0_next_tlc[FAD-1:0];
   assign rd_addr_traninfo1_tlc[FAD-1:0] = rd_addr_traninfo0_tlc[FAD-1:0] +
                                           {{(FAD-2){1'b0}},2'b01};
   assign rd_addr_traninfo2_tlc[FAD-1:0] = rd_addr_traninfo0_tlc[FAD-1:0] +
                                           {{(FAD-2){1'b0}},2'b10};
   e16_pulse2pulse pulse_wr2rd  (.out         (tran_written_tlc),
                             .outclk      (txo_lclk),
                             .in          (tran_written),
                             .inclk       (cclk),
                             .reset       (reset_sync_1));
   e16_synchronizer #(.DW(FAD+1)) sync_rd2wr (.out	 (rd_gray_pointer[FAD:0]), 
                                          .in	 (rd_gray_pointer_tlc[FAD:0]), 
					  .clk	 (cclk),
					  .reset (reset_sync_1));
endmodule 
module link_txo_interface (
   txo_data, txo_frame, txo_wr_wait_int, txo_rd_wait_int,
   txo_lclk, reset_sync_1, txo_wr_data_even, txo_wr_data_odd, txo_wr_frame,
   txo_wr_launch_req_tlc, txo_wr_rotate_dis, txo_rd_data_even,
   txo_rd_data_odd, txo_rd_frame, txo_rd_launch_req_tlc,
   txo_rd_rotate_dis
   );
   parameter LW  = `CFG_LW;
   input          txo_lclk;
   input 	  reset_sync_1;
   input [LW-1:0]  txo_wr_data_even; 
   input [LW-1:0]  txo_wr_data_odd;  
   input 	   txo_wr_frame;     
   input 	   txo_wr_launch_req_tlc;
   input 	   txo_wr_rotate_dis;
   input [LW-1:0]  txo_rd_data_even; 
   input [LW-1:0]  txo_rd_data_odd;  
   input 	   txo_rd_frame;     
   input 	   txo_rd_launch_req_tlc;
   input 	   txo_rd_rotate_dis;
   output [LW-1:0]  txo_data;      
   output 	    txo_frame;     
   output 	    txo_wr_wait_int; 
   output 	    txo_rd_wait_int; 
   reg [LW-1:0]   data_even_lsl;
   reg [LW-1:0]   data_even_lsh;
   reg [LW-1:0]   data_odd_lsl; 
   reg 		  txo_frame; 
   wire 	 txo_frame_in;   
   wire [LW-1:0] data_even_in;   
   wire [LW-1:0] data_odd_in;    
   wire [LW-1:0] txo_data;       
   assign txo_wr_wait_int = txo_rd_rotate_dis;
   assign txo_rd_wait_int = txo_wr_launch_req_tlc & ~txo_rd_rotate_dis;
   assign txo_frame_in = txo_wr_frame | txo_rd_frame;
   assign data_even_in[LW-1:0] = txo_wr_data_even[LW-1:0] |
				 txo_rd_data_even[LW-1:0];
   assign data_odd_in[LW-1:0] = txo_wr_data_odd[LW-1:0] |
				txo_rd_data_odd[LW-1:0];
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if (reset_sync_1)
       begin
	  txo_frame             <= 1'b0;
	  data_even_lsl[LW-1:0] <= {(LW){1'b0}};
	  data_odd_lsl[LW-1:0]  <= {(LW){1'b0}};
       end
     else 
       begin
	  txo_frame              <= txo_frame_in;
 	  data_even_lsl[LW-1:0]  <= data_even_in[LW-1:0];
	  data_odd_lsl[LW-1:0]   <= data_odd_in[LW-1:0];
       end
   always @ (negedge txo_lclk or posedge reset_sync_1)
     if (reset_sync_1)
       data_even_lsh[LW-1:0] <= {(LW){1'b0}};
     else
       data_even_lsh[LW-1:0]  <= data_even_lsl[LW-1:0];
   assign txo_data[LW-1:0] = txo_lclk ? data_even_lsh[LW-1:0]:
                                        data_odd_lsl[LW-1:0]; 
endmodule 
module link_txo_launcher (
   rd_read, check_next_dstaddr, txo_launch_req, txo_rotate_dis,
   tran_frame, tran_byte_even, tran_byte_odd,
   reset_sync_1, txo_lclk, txo_rd, txo_cid, cfg_burst_dis, fifo_out,
   tran_written, next_ctrlmode, next_dstaddr, next_datamode,
   next_write, next_access, txo_launch_ack
   );
   parameter LW   = `CFG_LW  ;
   parameter AW   = `CFG_AW  ;
   parameter AE   = 4; 
   parameter PE   = 7; 
   parameter FAD  = 5; 
   input          reset_sync_1;
   input 	  txo_lclk;  
   input 	  txo_rd;  
   input [1:0] 	  txo_cid; 
   input 	  cfg_burst_dis; 
   input [2*LW-1:0] fifo_out;      
   input 	  tran_written;
   input [3:0] 	  next_ctrlmode;
   input [AW-1:0] next_dstaddr;
   input [1:0] 	  next_datamode;
   input 	  next_write;
   input 	  next_access;
   input 	  txo_launch_ack;
   output [FAD:0] rd_read; 
   output 	  check_next_dstaddr; 
   output 	  txo_launch_req; 
   output 	  txo_rotate_dis; 
   output 	  tran_frame;       
   output [LW-1:0] tran_byte_even;  
   output [LW-1:0] tran_byte_odd;   
   reg [AE+1:0]   fifo_trans;
   reg [3:0] 	  ref_ctrlmode;
   reg [AW-1:0]   ref_dstaddr;
   reg [1:0] 	  ref_datamode;
   reg 		  ref_write;
   reg 		  ref_access;
   reg 		  byte0_inc0;
   reg 		  txo_launch_init_req; 
   reg 		  txo_launch_ack_del1;
   reg 		  txo_launch_ack_del2;
   reg 		  tran_frame;
   reg [LW-1:0]   byte_odd_del;
   reg [LW-1:0]   tran_byte_even;
   reg [LW-1:0]   tran_byte_odd;
   reg [2:0] 	  txo_launch_cnt;
   reg 		  burst_req;
   reg [1:0] 	  burst_backup_cnt;
   wire 	  start_new_read;
   wire [AW-1:0]  ref_dstaddr_inc8; 
   wire 	  next_inc8_match; 
   wire 	  next_inc0_match; 
   wire [7:0] 	  ref_ctrl; 
   wire [7:0] 	  next_ctrl;
   wire 	  type_match; 
   wire [7:0]	  tran_byte0; 
   wire 	  burst_tran; 
   wire [2:0] 	  txo_launch_cnt_inc; 
   wire [2:0]	  txo_launch_cnt_next;
   wire 	  txo_launch_cnt_max; 
   wire 	  tran_read;  
   wire 	  jump_4entries;  
   wire 	  jump_3entries;  
   wire 	  jump_3entries_write; 
   wire 	  jump_3entries_read;  
   wire 	  jump_1entry; 
   wire [2:0] 	  jump_value;  
   wire 	  txo_op_ack;       
   wire 	  txo_op_ack_first; 
   wire [LW-1:0]  byte_even_mux;
   wire [LW-1:0]  byte_odd_mux;
   wire [LW-1:0]  byte_even;
   wire [LW-1:0]  byte_odd;
   wire 	  make_gap;     
   wire 	  single_write; 
   wire 	  double_write; 
   wire 	  burst_req_denied; 
   wire 	  burst_backup_inc; 
   wire [1:0] 	  burst_backup_inc_cnt;  
   wire [1:0] 	  burst_backup_next_cnt; 
   wire 	  freeze_fifo;           
   wire sel_ref_byte0; 
   wire sel_ref_byte1; 
   wire sel_ref_byte2; 
   wire sel_ref_byte3; 
   wire sel_ref_byte4; 
   wire sel_ref_byte5; 
   assign make_gap = tran_read & ~burst_tran;
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       begin
	  txo_launch_ack_del1 <= 1'b0;
	  txo_launch_ack_del2 <= 1'b0;
       end
     else
       begin
	  txo_launch_ack_del1 <= txo_launch_ack      & ~make_gap;
	  txo_launch_ack_del2 <= txo_launch_ack_del1 & ~burst_req_denied;
       end
   assign txo_op_ack       = txo_launch_ack      &  txo_launch_ack_del1;
   assign txo_op_ack_first = txo_launch_ack_del1 & ~txo_launch_ack_del2;
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if (reset_sync_1)
       txo_launch_init_req <= 1'b0;
     else if(start_new_read)
       txo_launch_init_req <= 1'b1;
     else if(txo_launch_ack)
       txo_launch_init_req <= 1'b0;
   assign txo_launch_req = txo_launch_init_req | 
			    txo_op_ack_first | (|(txo_launch_cnt[2:0]));
   assign txo_rotate_dis = ~txo_launch_init_req & 
			   (txo_op_ack_first | (|(txo_launch_cnt[2:0])));
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       fifo_trans[AE+1:0] <= {{(AE+1){1'b0}},1'b1};
     else if(tran_written & ~tran_read)
       fifo_trans[AE+1:0] <= {fifo_trans[AE:0],1'b0};
     else if(tran_read & ~tran_written)
       fifo_trans[AE+1:0] <= {1'b0,fifo_trans[AE+1:1]};
   assign start_new_read = (fifo_trans[0]           & tran_written) |
			   (tran_read               & tran_written) |
			   ((|(fifo_trans[AE+1:2])) & tran_read );
   assign check_next_dstaddr = start_new_read;
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       byte0_inc0     <= 1'b0;
     else if(start_new_read)
       byte0_inc0     <= next_inc0_match;
   always @(posedge txo_lclk)
     if(start_new_read)
       begin
	  ref_ctrlmode[3:0]   <= next_ctrlmode[3:0];
	  ref_dstaddr[AW-1:0] <= next_dstaddr[AW-1:0];
	  ref_datamode[1:0]   <= next_datamode[1:0];
	  ref_write           <= next_write;
	  ref_access          <= next_access;
       end
   assign single_write = 1'b0; 
   assign double_write = next_access & next_write &  (&(next_datamode[1:0]));
   assign ref_dstaddr_inc8[AW-1:0] = ref_dstaddr[AW-1:0]+{{(AW-4){1'b0}},4'b1000};
   assign next_inc8_match = (ref_dstaddr_inc8[AW-1:0] == next_dstaddr[AW-1:0]);
   assign next_inc0_match = (ref_dstaddr[AW-1:0]      == next_dstaddr[AW-1:0]);
   assign ref_ctrl[7:0]  = {ref_ctrlmode[3:0], ref_datamode[1:0], ref_write, ref_access};
   assign next_ctrl[7:0] = {next_ctrlmode[3:0],next_datamode[1:0],next_write,next_access};
   assign type_match = (ref_ctrl[7:0] == next_ctrl[7:0]);
   assign burst_tran = ~cfg_burst_dis  & 
		        start_new_read & 
		        tran_read      & 
		        type_match     & 
		        double_write   & 
		        ((next_inc8_match  & ~byte0_inc0) |  
			 (next_inc0_match  &  byte0_inc0));
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if (reset_sync_1)
       burst_req    <= 1'b0;
     else
       burst_req    <= burst_tran;
   assign tran_byte0[7:0] = {txo_rd,4'b0000, byte0_inc0, txo_cid[1:0]};
   assign jump_4entries = burst_tran & (txo_launch_cnt[2:0] == 3'b110);
   assign jump_3entries = jump_3entries_write | 
			  jump_3entries_read;
   assign jump_3entries_write = single_write & (txo_launch_cnt[2:0] == 3'b100); 
   assign jump_3entries_read = 1'b0;
   assign jump_1entry = ~(jump_4entries | jump_3entries | freeze_fifo) & txo_op_ack;
   assign burst_req_denied = burst_req   & ~txo_op_ack;
   assign burst_backup_inc = freeze_fifo &  txo_op_ack;
   assign burst_backup_inc_cnt[1:0]  = burst_backup_cnt[1:0] + 2'b01;
   assign burst_backup_next_cnt[1:0] = burst_req_denied ? 2'b01 :
				       burst_backup_inc ? burst_backup_inc_cnt[1:0] :
				                          burst_backup_cnt[1:0];
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       burst_backup_cnt[1:0] <= 2'b00;
     else
       burst_backup_cnt[1:0] <= burst_backup_next_cnt[1:0];
   assign freeze_fifo = |(burst_backup_cnt[1:0]);
   assign jump_value[2:0] = ({(3){jump_4entries}} & 3'b100) |
			    ({(3){jump_3entries}} & 3'b011) |
			    ({(3){jump_1entry}}   & 3'b001);
   assign rd_read[FAD:0] = {{(FAD-2){1'b0}},jump_value[2:0]};
   assign txo_launch_cnt_max = (txo_launch_cnt[2:0] == 3'b110);
   assign txo_launch_cnt_inc[2:0] = txo_launch_cnt[2:0] + {2'b00,jump_1entry};
   assign txo_launch_cnt_next[2:0] =  jump_4entries ? 3'b011 :
	 (jump_3entries_write | txo_launch_cnt_max) ? 3'b000 :
			         jump_3entries_read ? 3'b101 : txo_launch_cnt_inc[2:0];
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if (reset_sync_1)
       txo_launch_cnt[2:0] <= 3'b000;
     else if(txo_op_ack)
       txo_launch_cnt[2:0] <= txo_launch_cnt_next[2:0];
   assign tran_read = (~single_write & (txo_launch_cnt[2:0] == 3'b110)) |
		      ( single_write & (txo_launch_cnt[2:0] == 3'b100));
   assign sel_ref_byte0 = txo_op_ack_first;
   assign sel_ref_byte2 = (burst_backup_cnt[1:0] == 2'b10);
   assign sel_ref_byte4 = (burst_backup_cnt[1:0] == 2'b11);
   assign sel_ref_byte1 = (burst_backup_cnt[1:0] == 2'b01);
   assign sel_ref_byte3 = (burst_backup_cnt[1:0] == 2'b10);
   assign sel_ref_byte5 = (burst_backup_cnt[1:0] == 2'b11);
   assign byte_even_mux[LW-1:0] = sel_ref_byte0 ? tran_byte0[7:0]    :
				  sel_ref_byte2 ? ref_dstaddr[27:20] :
				  sel_ref_byte4 ? ref_dstaddr[11:4]  :
				                  fifo_out[2*LW-1:LW];
   assign byte_odd_mux[LW-1:0] = sel_ref_byte1 ? {ref_ctrlmode[3:0],ref_dstaddr[31:28]} :
				 sel_ref_byte3 ? ref_dstaddr[19:12] :
	      sel_ref_byte5 ? {ref_dstaddr[3:0],ref_datamode[1:0],ref_write,ref_access} :
				                 fifo_out[LW-1:0];
   assign byte_even[LW-1:0] = {(LW){txo_op_ack}} & byte_even_mux[LW-1:0];
   assign byte_odd[LW-1:0]  = {(LW){txo_op_ack}} & byte_odd_mux[LW-1:0];
   always @ (posedge txo_lclk or posedge reset_sync_1)
     if(reset_sync_1)
       tran_frame <= 1'b0;
     else
       tran_frame <= txo_launch_ack_del2;
   always @ (posedge txo_lclk)
     begin
	byte_odd_del[LW-1:0]   <= byte_odd[LW-1:0];
	tran_byte_odd[LW-1:0]  <= byte_odd_del[LW-1:0];
	tran_byte_even[LW-1:0] <= byte_even[LW-1:0];
     end
   always @*
     if(~(|(fifo_trans[AE+1:0])) & $time>0)
       $display("ERROR>>link launcher mechanism is broken in cell %m");
   always @*
     if(((jump_4entries       & (jump_3entries_read | jump_3entries_write | jump_1entry))|
	 (jump_3entries_read  & (                     jump_3entries_write | jump_1entry))|
	 (jump_3entries_write & (                                           jump_1entry)))
	& $time>0)
       $display("ERROR>>detected more than one jump for launcher mechanism in cell %m");
endmodule 
module link_txo_mesh_channel (
   emesh_wait_out, mesh_wait_out, txo_launch_req_tlc,
   txo_rotate_dis_tlc, tran_frame_tlc, tran_byte_even_tlc,
   tran_byte_odd_tlc,
   cclk, cclk_en, txo_lclk, reset_sync_1, ext_yid_k, ext_xid_k, who_am_i,
   txo_rd, txo_cid, cfg_multicast_dis, cfg_burst_dis, emesh_tran_in,
   emesh_frame_in, mesh_access_in, mesh_write_in, mesh_dstaddr_in,
   mesh_srcaddr_in, mesh_data_in, mesh_datamode_in, mesh_ctrlmode_in,
   txo_launch_ack_tlc
   );
   parameter AW   = `CFG_AW  ;
   parameter DW   = `CFG_DW  ;
   parameter LW   = `CFG_LW  ;
   parameter FW   = `CFG_NW*`CFG_LW;
   parameter FAD  = 5; 
   input 	  cclk;     
   input 	  cclk_en;  
   input 	  txo_lclk; 
   input          reset_sync_1;
   input [3:0] 	  ext_yid_k; 
   input [3:0] 	  ext_xid_k; 
   input [3:0]	  who_am_i;  
   input 	  txo_rd;  
   input [1:0] 	  txo_cid; 
   input 	  cfg_multicast_dis; 
   input 	  cfg_burst_dis; 
   input [2*LW-1:0] emesh_tran_in;  
   input 	    emesh_frame_in; 
   input 	  mesh_access_in;  
   input 	  mesh_write_in;   
   input [AW-1:0] mesh_dstaddr_in; 
   input [AW-1:0] mesh_srcaddr_in; 
   input [DW-1:0] mesh_data_in;    
   input [1:0] 	  mesh_datamode_in;
   input [3:0] 	  mesh_ctrlmode_in;
   input 	  txo_launch_ack_tlc;
   output 	  emesh_wait_out; 
   output 	  mesh_wait_out; 
   output 	  txo_launch_req_tlc; 
   output 	  txo_rotate_dis_tlc; 
   output 	   tran_frame_tlc;      
   output [LW-1:0] tran_byte_even_tlc;  
   output [LW-1:0] tran_byte_odd_tlc;   
   wire			access_reg;		
   wire			check_next_dstaddr_tlc;	
   wire [3:0]		ctrlmode_reg;		
   wire [DW-1:0]	data_reg;		
   wire [1:0]		datamode_reg;		
   wire [AW-1:0]	dstaddr_reg;		
   wire [2*LW-1:0]	fifo_out_tlc;		
   wire			mesh_frame;		
   wire			mesh_req;		
   wire			mesh_rotate_dis;	
   wire [2*LW-1:0]	mesh_tran;		
   wire			mesh_wait_int;		
   wire			next_access_tlc;	
   wire [3:0]		next_ctrlmode_tlc;	
   wire [1:0]		next_datamode_tlc;	
   wire [AW-1:0]	next_dstaddr_tlc;	
   wire			next_write_tlc;		
   wire [FAD:0]		rd_read_tlc;		
   wire [AW-1:0]	srcaddr_reg;		
   wire			tran_written_tlc;	
   wire			wr_fifo_full;		
   wire			write_reg;		
   link_txo_launcher #(.FAD(FAD)) link_txo_launcher(
						    .rd_read		(rd_read_tlc[FAD:0]), 
						    .check_next_dstaddr	(check_next_dstaddr_tlc), 
						    .txo_launch_req	(txo_launch_req_tlc), 
						    .txo_rotate_dis	(txo_rotate_dis_tlc), 
						    .tran_frame		(tran_frame_tlc), 
						    .tran_byte_even	(tran_byte_even_tlc[LW-1:0]), 
						    .tran_byte_odd	(tran_byte_odd_tlc[LW-1:0]), 
						    .reset		(reset_sync_1),	 
						    .txo_lclk		(txo_lclk),	 
						    .txo_rd		(txo_rd),	 
						    .txo_cid		(txo_cid[1:0]),	 
						    .cfg_burst_dis	(cfg_burst_dis), 
						    .fifo_out		(fifo_out_tlc[2*LW-1:0]), 
						    .tran_written	(tran_written_tlc), 
						    .next_ctrlmode	(next_ctrlmode_tlc[3:0]), 
						    .next_dstaddr	(next_dstaddr_tlc[AW-1:0]), 
						    .next_datamode	(next_datamode_tlc[1:0]), 
						    .next_write		(next_write_tlc), 
						    .next_access	(next_access_tlc), 
						    .txo_launch_ack	(txo_launch_ack_tlc)); 
   link_txo_fifo #(.FAD(FAD)) link_txo_fifo(.tran_in		(mesh_tran[2*LW-1:0]),
					    .frame_in		(mesh_frame),
					    .wr_fifo_full	(wr_fifo_full),
					    .fifo_out_tlc	(fifo_out_tlc[2*LW-1:0]),
					    .tran_written_tlc	(tran_written_tlc),
					    .next_ctrlmode_tlc	(next_ctrlmode_tlc[3:0]),
					    .next_dstaddr_tlc	(next_dstaddr_tlc[AW-1:0]),
					    .next_datamode_tlc	(next_datamode_tlc[1:0]),
					    .next_write_tlc	(next_write_tlc),
					    .next_access_tlc	(next_access_tlc),
					    .reset		(reset_sync_1),
					    .cclk		(cclk),
					    .cclk_en		(cclk_en),
					    .txo_lclk		(txo_lclk),
					    .rd_read_tlc	(rd_read_tlc[FAD:0]),
					    .check_next_dstaddr_tlc(check_next_dstaddr_tlc));
   e16_mesh_interface mesh_interface(
				     .wait_out		(mesh_wait_out), 
				     .access_out	(),		 
				     .write_out		(),		 
				     .datamode_out	(),		 
				     .ctrlmode_out	(),		 
				     .data_out		(),		 
				     .dstaddr_out	(),		 
				     .srcaddr_out	(),		 
				     .access_reg	(access_reg),
				     .write_reg		(write_reg),
				     .datamode_reg	(datamode_reg[1:0]),
				     .ctrlmode_reg	(ctrlmode_reg[3:0]),
				     .data_reg		(data_reg[DW-1:0]),
				     .dstaddr_reg	(dstaddr_reg[AW-1:0]),
				     .srcaddr_reg	(srcaddr_reg[AW-1:0]),
				     .clk		(cclk),		 
				     .clk_en		(cclk_en),	 
				     .reset		(reset_sync_1),
				     .wait_in		(1'b0),		 
				     .access_in		(mesh_access_in), 
				     .write_in		(mesh_write_in), 
				     .datamode_in	(mesh_datamode_in[1:0]), 
				     .ctrlmode_in	(mesh_ctrlmode_in[3:0]), 
				     .data_in		(mesh_data_in[DW-1:0]), 
				     .dstaddr_in	(mesh_dstaddr_in[AW-1:0]), 
				     .srcaddr_in	(mesh_srcaddr_in[AW-1:0]), 
				     .wait_int		(mesh_wait_int), 
				     .access		(1'b0),		 
				     .write		(1'b0),		 
				     .datamode		(2'b00),	 
				     .ctrlmode		(4'b0000),	 
				     .data		({(DW){1'b0}}),	 
				     .dstaddr		({(AW){1'b0}}),	 
				     .srcaddr		({(AW){1'b0}}));	 
   link_txo_mesh_launcher link_txo_mesh_launcher(.mesh_grant		(~wr_fifo_full),
						 .mesh_wait_int		(mesh_wait_int),
						 .mesh_req		(mesh_req),
						 .mesh_rotate_dis	(mesh_rotate_dis),
						 .mesh_tran		(mesh_tran[2*LW-1:0]),
						 .mesh_frame		(mesh_frame),
						 .cclk			(cclk),
						 .cclk_en		(cclk_en),
						 .reset			(reset_sync_1),
						 .ext_yid_k		(ext_yid_k[3:0]),
						 .ext_xid_k		(ext_xid_k[3:0]),
						 .who_am_i		(who_am_i[3:0]),
						 .cfg_multicast_dis	(cfg_multicast_dis),
						 .access_reg		(access_reg),
						 .write_reg		(write_reg),
						 .datamode_reg		(datamode_reg[1:0]),
						 .ctrlmode_reg		(ctrlmode_reg[3:0]),
						 .data_reg		(data_reg[DW-1:0]),
						 .dstaddr_reg		(dstaddr_reg[AW-1:0]),
						 .srcaddr_reg		(srcaddr_reg[AW-1:0]));
endmodule 
module link_txo_mesh_launcher(
   mesh_wait_int, mesh_req, mesh_rotate_dis, mesh_tran, mesh_frame,
   cclk, cclk_en, reset_sync_1, ext_yid_k, ext_xid_k, who_am_i,
   cfg_multicast_dis, access_reg, write_reg, datamode_reg,
   ctrlmode_reg, data_reg, dstaddr_reg, srcaddr_reg, mesh_grant
   );
   parameter AW   = `CFG_AW  ;
   parameter DW   = `CFG_DW  ;
   parameter LW   = `CFG_LW  ;
   input 	  cclk;      
   input 	  cclk_en;   
   input          reset_sync_1;
   input [3:0] 	  ext_yid_k; 
   input [3:0] 	  ext_xid_k; 
   input [3:0]	  who_am_i;  
   input 	  cfg_multicast_dis; 
   input 	  access_reg;
   input 	  write_reg;
   input [1:0] 	  datamode_reg;
   input [3:0] 	  ctrlmode_reg;   		    
   input [DW-1:0] data_reg;
   input [AW-1:0] dstaddr_reg;
   input [AW-1:0] srcaddr_reg;  
   input 	  mesh_grant;
   output 	  mesh_wait_int; 
   output 	  mesh_req; 
   output 	  mesh_rotate_dis; 
   output [2*LW-1:0] mesh_tran;  
   output 	     mesh_frame; 
   reg [2:0]   mesh_pointer;
   wire        multicast_tran_valid; 
   wire        multicast_tran; 
   wire [3:0]  ycoord_k_n; 
   wire [3:0]  xcoord_k_n; 
   wire [3:0]  addr_y; 
   wire [3:0]  addr_x; 
   wire        ext_yzero;
   wire        ext_xzero;
   wire [4:0]  ext_xdiff;
   wire [4:0]  ext_ydiff;
   wire        ext_xcarry;   
   wire        ext_ycarry;   
   wire        ext_xgt;   
   wire        ext_xlt;   
   wire        ext_ygt;   
   wire        ext_ylt;   
   wire        route_east;   
   wire        route_west;   
   wire        route_north;   
   wire        route_south;   
   wire        route_east_normal;   
   wire        route_west_normal;   
   wire        route_north_normal;   
   wire        route_south_normal;   
   wire        route_east_multicast;   
   wire        route_west_multicast;   
   wire        route_north_multicast;   
   wire        route_south_multicast;   
   wire [3:0]  route_sides; 
   wire        route_out;   
   wire        mesh_ack;
   wire        mesh_ack_n;
   wire        mesh_last_tran;
   wire [2:0]  mesh_pointer_incr;
   wire [6:0]  launcher_sel;
   wire [14*LW-1:0] mesh_tran_in;
   assign multicast_tran = write_reg & 
			   (ctrlmode_reg[1:0]==2'b11) & ~(datamode_reg[1:0] == 2'b11);
   assign addr_y[3:0] = multicast_tran ? srcaddr_reg[31:28] : dstaddr_reg[31:28];
   assign addr_x[3:0] = multicast_tran ? srcaddr_reg[25:22] : dstaddr_reg[25:22];
   assign ycoord_k_n[3:0] = ~ext_yid_k[3:0];
   assign xcoord_k_n[3:0] = ~ext_xid_k[3:0];
   assign ext_yzero      = addr_y[3:0]==ext_yid_k[3:0];
   assign ext_xzero      = addr_x[3:0]==ext_xid_k[3:0];   
   assign ext_ydiff[4:0] = addr_y[3:0] + ycoord_k_n[3:0] + 1'b1 ; 
   assign ext_xdiff[4:0] = addr_x[3:0] + xcoord_k_n[3:0] + 1'b1 ;
   assign ext_xcarry     = ext_xdiff[4]; 
   assign ext_ycarry     = ext_ydiff[4]; 
   assign ext_xgt        = ext_xcarry & ~ext_xzero;
   assign ext_xlt        = ~ext_xcarry;  
   assign ext_ygt        = ext_ycarry & ~ext_yzero;
   assign ext_ylt        = ~ext_ycarry;  
   assign route_east_normal   =  ext_xgt;   
   assign route_west_normal   =  ext_xlt;
   assign route_south_normal  =  ext_ygt & ext_xzero;
   assign route_north_normal  =  ext_ylt & ext_xzero;
   assign route_east_multicast  = (ext_xlt | ext_xzero) & ext_yzero;
   assign route_west_multicast  = (ext_xgt | ext_xzero) & ext_yzero;
   assign route_south_multicast =  ext_ylt | ext_yzero;
   assign route_north_multicast =  ext_ygt | ext_yzero;
   assign route_east  = multicast_tran ? route_east_multicast  : route_east_normal;
   assign route_west  = multicast_tran ? route_west_multicast  : route_west_normal;
   assign route_south = multicast_tran ? route_south_multicast : route_south_normal;
   assign route_north = multicast_tran ? route_north_multicast : route_north_normal;
   assign route_sides[3:0] = 4'b1111;
   assign route_out = |(who_am_i[3:0] & route_sides[3:0]);
   assign mesh_req = access_reg & route_out & ((multicast_tran & ~cfg_multicast_dis) |
					       ~multicast_tran);
   assign mesh_ack_n    = mesh_req & ~mesh_grant;
   assign mesh_ack      = mesh_req &  mesh_grant;
   assign mesh_wait_int = mesh_req & ~mesh_last_tran | mesh_ack_n;
   assign mesh_last_tran = mesh_pointer[2] & mesh_pointer[1] & ~mesh_pointer[0];
   assign mesh_pointer_incr[2:0] = mesh_last_tran ? 3'b000 :
				   (mesh_pointer[2:0] + 3'b001);
   always @ (posedge cclk or posedge reset_sync_1)
     if(reset_sync_1)
       mesh_pointer[2:0] <= 3'b000;
     else if(cclk_en)
       if (mesh_ack)
	 mesh_pointer[2:0] <= mesh_pointer_incr[2:0];
   assign launcher_sel[0] = (mesh_pointer[2:0] == 3'b000);
   assign launcher_sel[1] = (mesh_pointer[2:0] == 3'b001);
   assign launcher_sel[2] = (mesh_pointer[2:0] == 3'b010);
   assign launcher_sel[3] = (mesh_pointer[2:0] == 3'b011);
   assign launcher_sel[4] = (mesh_pointer[2:0] == 3'b100);
   assign launcher_sel[5] = (mesh_pointer[2:0] == 3'b101);
   assign launcher_sel[6] = (mesh_pointer[2:0] == 3'b110);
   assign mesh_frame      =   mesh_req & ~mesh_last_tran;
   assign mesh_rotate_dis = |(mesh_pointer[2:0]);
   assign mesh_tran_in[14*LW-1:0]={
                                srcaddr_reg[7:0],{(LW){1'b0}},
				   srcaddr_reg[23:8],
			    data_reg[7:0],srcaddr_reg[31:24],
				   data_reg[23:8],
	 dstaddr_reg[3:0],datamode_reg[1:0],write_reg,access_reg,data_reg[31:24],
				   dstaddr_reg[19:4],
			  ctrlmode_reg[3:0],dstaddr_reg[31:20]
                                   };
   e16_mux7 #(2*LW) mux7(
		     .out (mesh_tran[2*LW-1:0]),
		     .in0 (mesh_tran_in[2*LW-1:0]),      .sel0 (launcher_sel[0]),
		     .in1 (mesh_tran_in[4*LW-1:2*LW]),   .sel1 (launcher_sel[1]),
		     .in2 (mesh_tran_in[6*LW-1:4*LW]),   .sel2 (launcher_sel[2]),
		     .in3 (mesh_tran_in[8*LW-1:6*LW]),   .sel3 (launcher_sel[3]),
		     .in4 (mesh_tran_in[10*LW-1:8*LW]),  .sel4 (launcher_sel[4]),
		     .in5 (mesh_tran_in[12*LW-1:10*LW]), .sel5 (launcher_sel[5]),
		     .in6 (mesh_tran_in[14*LW-1:12*LW]), .sel6 (launcher_sel[6]));
endmodule 
module link_txo_rd (
   txo_rd_data_even, txo_rd_data_odd, txo_rd_frame,
   txo_rd_launch_req_tlc, txo_rd_rotate_dis, c0_rdmesh_wait_out,
   c1_rdmesh_wait_out, c2_rdmesh_wait_out, c3_rdmesh_wait_out,
   txo_lclk, reset_sync_1, txo_rd_wait, txo_rd_wait_int, c0_clk_in,
   c1_clk_in, c2_clk_in, c3_clk_in, c0_rdmesh_tran_in,
   c0_rdmesh_frame_in, c1_rdmesh_tran_in, c1_rdmesh_frame_in,
   c2_rdmesh_tran_in, c2_rdmesh_frame_in, c3_rdmesh_tran_in,
   c3_rdmesh_frame_in
   );
   parameter LW   = `CFG_LW  ;
   input 	txo_lclk;  
   input        reset_sync_1;
   input 	txo_rd_wait; 
   input 	txo_rd_wait_int;  
   input 	c0_clk_in;   
   input 	c1_clk_in;   
   input 	c2_clk_in;   
   input 	c3_clk_in;   
   input [2*LW-1:0] c0_rdmesh_tran_in;  
   input 	    c0_rdmesh_frame_in; 
   input [2*LW-1:0] c1_rdmesh_tran_in;  
   input 	    c1_rdmesh_frame_in; 
   input [2*LW-1:0] c2_rdmesh_tran_in;  
   input 	    c2_rdmesh_frame_in; 
   input [2*LW-1:0] c3_rdmesh_tran_in;  
   input 	    c3_rdmesh_frame_in; 
   output [LW-1:0] txo_rd_data_even; 
   output [LW-1:0] txo_rd_data_odd;  
   output 	   txo_rd_frame; 
   output 	   txo_rd_launch_req_tlc;
   output 	   txo_rd_rotate_dis;
   output 	   c0_rdmesh_wait_out; 
   output 	   c1_rdmesh_wait_out; 
   output 	   c2_rdmesh_wait_out; 
   output 	   c3_rdmesh_wait_out; 
   wire [LW-1:0]	c0_tran_byte_even_tlc;	
   wire [LW-1:0]	c0_tran_byte_odd_tlc;	
   wire			c0_tran_frame_tlc;	
   wire			c0_txo_launch_ack_tlc;	
   wire			c0_txo_launch_req_tlc;	
   wire			c0_txo_rotate_dis;	
   wire [LW-1:0]	c1_tran_byte_even_tlc;	
   wire [LW-1:0]	c1_tran_byte_odd_tlc;	
   wire			c1_tran_frame_tlc;	
   wire			c1_txo_launch_ack_tlc;	
   wire			c1_txo_launch_req_tlc;	
   wire			c1_txo_rotate_dis;	
   wire [LW-1:0]	c2_tran_byte_even_tlc;	
   wire [LW-1:0]	c2_tran_byte_odd_tlc;	
   wire			c2_tran_frame_tlc;	
   wire			c2_txo_launch_ack_tlc;	
   wire			c2_txo_launch_req_tlc;	
   wire			c2_txo_rotate_dis;	
   wire [LW-1:0]	c3_tran_byte_even_tlc;	
   wire [LW-1:0]	c3_tran_byte_odd_tlc;	
   wire			c3_tran_frame_tlc;	
   wire			c3_txo_launch_ack_tlc;	
   wire			c3_txo_launch_req_tlc;	
   wire			c3_txo_rotate_dis;	
   wire [1:0] 	     c0_txo_cid;
   wire [1:0] 	     c1_txo_cid;
   wire [1:0] 	     c2_txo_cid;
   wire [1:0] 	     c3_txo_cid;
   link_txo_buffer link_txo_buffer(
				   .txo_data_even	(txo_rd_data_even[LW-1:0]), 
				   .txo_data_odd	(txo_rd_data_odd[LW-1:0]), 
				   .txo_frame		(txo_rd_frame),	 
				   .c0_tran_frame_tlc	(c0_tran_frame_tlc),
				   .c0_tran_byte_even_tlc(c0_tran_byte_even_tlc[LW-1:0]),
				   .c0_tran_byte_odd_tlc(c0_tran_byte_odd_tlc[LW-1:0]),
				   .c1_tran_frame_tlc	(c1_tran_frame_tlc),
				   .c1_tran_byte_even_tlc(c1_tran_byte_even_tlc[LW-1:0]),
				   .c1_tran_byte_odd_tlc(c1_tran_byte_odd_tlc[LW-1:0]),
				   .c2_tran_frame_tlc	(c2_tran_frame_tlc),
				   .c2_tran_byte_even_tlc(c2_tran_byte_even_tlc[LW-1:0]),
				   .c2_tran_byte_odd_tlc(c2_tran_byte_odd_tlc[LW-1:0]),
				   .c3_tran_frame_tlc	(c3_tran_frame_tlc),
				   .c3_tran_byte_even_tlc(c3_tran_byte_even_tlc[LW-1:0]),
				   .c3_tran_byte_odd_tlc(c3_tran_byte_odd_tlc[LW-1:0]));
   link_txo_arbiter link_txo_arbiter (
				      .txo_launch_req_tlc(txo_rd_launch_req_tlc), 
				      .txo_rotate_dis_tlc(txo_rd_rotate_dis), 
				      .c0_txo_launch_ack_tlc(c0_txo_launch_ack_tlc),
				      .c1_txo_launch_ack_tlc(c1_txo_launch_ack_tlc),
				      .c2_txo_launch_ack_tlc(c2_txo_launch_ack_tlc),
				      .c3_txo_launch_ack_tlc(c3_txo_launch_ack_tlc),
				      .txo_lclk		(txo_lclk),
				      .reset		(reset_sync_1),
				      .txo_wait		(txo_rd_wait),	 
				      .txo_wait_int	(txo_rd_wait_int), 
				      .c0_txo_launch_req_tlc(c0_txo_launch_req_tlc),
				      .c0_txo_rotate_dis(c0_txo_rotate_dis),
				      .c1_txo_launch_req_tlc(c1_txo_launch_req_tlc),
				      .c1_txo_rotate_dis(c1_txo_rotate_dis),
				      .c2_txo_launch_req_tlc(c2_txo_launch_req_tlc),
				      .c2_txo_rotate_dis(c2_txo_rotate_dis),
				      .c3_txo_launch_req_tlc(c3_txo_launch_req_tlc),
				      .c3_txo_rotate_dis(c3_txo_rotate_dis));
   link_txo_channel #(.FAD(3)) c0_link_txo_channel (
						    .emesh_wait_out	(c0_rdmesh_wait_out), 
						    .txo_launch_req_tlc	(c0_txo_launch_req_tlc), 
						    .txo_rotate_dis	(c0_txo_rotate_dis), 
						    .tran_frame_tlc	(c0_tran_frame_tlc), 
						    .tran_byte_even_tlc	(c0_tran_byte_even_tlc[LW-1:0]), 
						    .tran_byte_odd_tlc	(c0_tran_byte_odd_tlc[LW-1:0]), 
						    .cclk		(c0_clk_in),	 
						    .cclk_en		(1'b1),		 
						    .txo_lclk		(txo_lclk),	 
						    .reset		(reset_sync_1),	 
						    .txo_rd		(1'b1),		 
						    .txo_cid		(c0_txo_cid[1:0]), 
						    .cfg_burst_dis	(1'b1),		 
						    .emesh_tran_in	(c0_rdmesh_tran_in[2*LW-1:0]), 
						    .emesh_frame_in	(c0_rdmesh_frame_in), 
						    .txo_launch_ack_tlc	(c0_txo_launch_ack_tlc)); 
   link_txo_channel #(.FAD(3)) c1_link_txo_channel (
						    .emesh_wait_out	(c1_rdmesh_wait_out), 
						    .txo_launch_req_tlc	(c1_txo_launch_req_tlc), 
						    .txo_rotate_dis	(c1_txo_rotate_dis), 
						    .tran_frame_tlc	(c1_tran_frame_tlc), 
						    .tran_byte_even_tlc	(c1_tran_byte_even_tlc[LW-1:0]), 
						    .tran_byte_odd_tlc	(c1_tran_byte_odd_tlc[LW-1:0]), 
						    .cclk		(c1_clk_in),	 
						    .cclk_en		(1'b1),		 
						    .txo_lclk		(txo_lclk),	 
						    .reset		(reset_sync_1),	 
						    .txo_rd		(1'b1),		 
						    .txo_cid		(c1_txo_cid[1:0]), 
						    .cfg_burst_dis	(1'b1),		 
						    .emesh_tran_in	(c1_rdmesh_tran_in[2*LW-1:0]), 
						    .emesh_frame_in	(c1_rdmesh_frame_in), 
						    .txo_launch_ack_tlc	(c1_txo_launch_ack_tlc)); 
   link_txo_channel #(.FAD(3)) c2_link_txo_channel (
						    .emesh_wait_out	(c2_rdmesh_wait_out), 
						    .txo_launch_req_tlc	(c2_txo_launch_req_tlc), 
						    .txo_rotate_dis	(c2_txo_rotate_dis), 
						    .tran_frame_tlc	(c2_tran_frame_tlc), 
						    .tran_byte_even_tlc	(c2_tran_byte_even_tlc[LW-1:0]), 
						    .tran_byte_odd_tlc	(c2_tran_byte_odd_tlc[LW-1:0]), 
						    .cclk		(c2_clk_in),	 
						    .cclk_en		(1'b1),		 
						    .txo_lclk		(txo_lclk),	 
						    .reset		(reset_sync_1),	 
						    .txo_rd		(1'b1),		 
						    .txo_cid		(c2_txo_cid[1:0]), 
						    .cfg_burst_dis	(1'b1),		 
						    .emesh_tran_in	(c2_rdmesh_tran_in[2*LW-1:0]), 
						    .emesh_frame_in	(c2_rdmesh_frame_in), 
						    .txo_launch_ack_tlc	(c2_txo_launch_ack_tlc)); 
   link_txo_channel #(.FAD(3)) c3_link_txo_channel (
						    .emesh_wait_out	(c3_rdmesh_wait_out), 
						    .txo_launch_req_tlc	(c3_txo_launch_req_tlc), 
						    .txo_rotate_dis	(c3_txo_rotate_dis), 
						    .tran_frame_tlc	(c3_tran_frame_tlc), 
						    .tran_byte_even_tlc	(c3_tran_byte_even_tlc[LW-1:0]), 
						    .tran_byte_odd_tlc	(c3_tran_byte_odd_tlc[LW-1:0]), 
						    .cclk		(c3_clk_in),	 
						    .cclk_en		(1'b1),		 
						    .txo_lclk		(txo_lclk),	 
						    .reset		(reset_sync_1),	 
						    .txo_rd		(1'b1),		 
						    .txo_cid		(c3_txo_cid[1:0]), 
						    .cfg_burst_dis	(1'b1),		 
						    .emesh_tran_in	(c3_rdmesh_tran_in[2*LW-1:0]), 
						    .emesh_frame_in	(c3_rdmesh_frame_in), 
						    .txo_launch_ack_tlc	(c3_txo_launch_ack_tlc)); 
endmodule 
module link_txo_wr (
   txo_wr_data_even, txo_wr_data_odd, txo_wr_frame,
   txo_wr_launch_req_tlc, txo_wr_rotate_dis, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_mesh_wait_out, c3_mesh_wait_out,
   c2_tran_frame_tlc, c2_tran_byte_odd_tlc, c2_tran_byte_even_tlc,
   c1_tran_frame_tlc, c1_tran_byte_odd_tlc, c1_tran_byte_even_tlc,
   txo_lclk, reset_sync_1, ext_yid_k, ext_xid_k, who_am_i, cfg_burst_dis,
   cfg_multicast_dis, txo_wr_wait, txo_wr_wait_int, c0_clk_in,
   c1_clk_in, c2_clk_in, c3_clk_in, c0_emesh_tran_in,
   c0_emesh_frame_in, c1_emesh_tran_in, c1_emesh_frame_in,
   c2_emesh_tran_in, c2_emesh_frame_in, c3_emesh_tran_in,
   c3_emesh_frame_in, c0_mesh_access_in, c0_mesh_write_in,
   c0_mesh_dstaddr_in, c0_mesh_srcaddr_in, c0_mesh_data_in,
   c0_mesh_datamode_in, c0_mesh_ctrlmode_in, c3_mesh_access_in,
   c3_mesh_write_in, c3_mesh_dstaddr_in, c3_mesh_srcaddr_in,
   c3_mesh_data_in, c3_mesh_datamode_in, c3_mesh_ctrlmode_in
   );
   parameter LW   = `CFG_LW  ;
   parameter AW   = `CFG_AW  ;
   parameter DW   = `CFG_DW  ;
   input 	txo_lclk;  
   input        reset_sync_1;
   input [3:0] 	ext_yid_k; 
   input [3:0] 	ext_xid_k; 
   input [3:0] 	who_am_i;  
   input 	cfg_burst_dis; 
   input 	cfg_multicast_dis;
   input 	txo_wr_wait; 
   input 	txo_wr_wait_int; 
   input 	c0_clk_in;   
   input 	c1_clk_in;   
   input 	c2_clk_in;   
   input 	c3_clk_in;   
   input [2*LW-1:0] c0_emesh_tran_in;  
   input 	    c0_emesh_frame_in; 
   input [2*LW-1:0] c1_emesh_tran_in;  
   input 	    c1_emesh_frame_in; 
   input [2*LW-1:0] c2_emesh_tran_in;  
   input 	    c2_emesh_frame_in; 
   input [2*LW-1:0] c3_emesh_tran_in;  
   input 	    c3_emesh_frame_in; 
   input 	    c0_mesh_access_in;  
   input 	    c0_mesh_write_in;   
   input [AW-1:0]   c0_mesh_dstaddr_in; 
   input [AW-1:0]   c0_mesh_srcaddr_in; 
   input [DW-1:0]   c0_mesh_data_in;    
   input [1:0] 	    c0_mesh_datamode_in;
   input [3:0] 	    c0_mesh_ctrlmode_in;
   input 	    c3_mesh_access_in;  
   input 	    c3_mesh_write_in;   
   input [AW-1:0]   c3_mesh_dstaddr_in; 
   input [AW-1:0]   c3_mesh_srcaddr_in; 
   input [DW-1:0]   c3_mesh_data_in;    
   input [1:0] 	    c3_mesh_datamode_in;
   input [3:0] 	    c3_mesh_ctrlmode_in;
   output [LW-1:0] txo_wr_data_even; 
   output [LW-1:0] txo_wr_data_odd;  
   output 	   txo_wr_frame; 
   output 	   txo_wr_launch_req_tlc;
   output 	   txo_wr_rotate_dis;
   output 	   c0_emesh_wait_out; 
   output 	   c1_emesh_wait_out; 
   output 	   c2_emesh_wait_out; 
   output 	   c3_emesh_wait_out; 
   output 	   c0_mesh_wait_out;  
   output 	   c3_mesh_wait_out;  
   input [LW-1:0]	c1_tran_byte_even_tlc;	
   input [LW-1:0]	c1_tran_byte_odd_tlc;	
   input		c1_tran_frame_tlc;	
   input [LW-1:0]	c2_tran_byte_even_tlc;	
   input [LW-1:0]	c2_tran_byte_odd_tlc;	
   input		c2_tran_frame_tlc;	
   wire [LW-1:0]	c0_tran_byte_even_tlc;	
   wire [LW-1:0]	c0_tran_byte_odd_tlc;	
   wire			c0_tran_frame_tlc;	
   wire			c0_txo_launch_ack_tlc;	
   wire			c0_txo_launch_req_tlc;	
   wire			c0_txo_rotate_dis;	
   wire			c1_txo_launch_ack_tlc;	
   wire			c2_txo_launch_ack_tlc;	
   wire [LW-1:0]	c3_tran_byte_even_tlc;	
   wire [LW-1:0]	c3_tran_byte_odd_tlc;	
   wire			c3_tran_frame_tlc;	
   wire			c3_txo_launch_ack_tlc;	
   wire			c3_txo_launch_req_tlc;	
   wire			c3_txo_rotate_dis;	
   wire [1:0] 	     c0_txo_cid;
   wire [1:0] 	     c1_txo_cid;
   wire [1:0] 	     c2_txo_cid;
   wire [1:0] 	     c3_txo_cid;
   assign c0_txo_cid[1:0] = 2'b00;
   assign c1_txo_cid[1:0] = 2'b01;
   assign c2_txo_cid[1:0] = 2'b10;
   assign c3_txo_cid[1:0] = 2'b11;
   link_txo_buffer link_txo_buffer(
				   .txo_data_even	(txo_wr_data_even[LW-1:0]), 
				   .txo_data_odd	(txo_wr_data_odd[LW-1:0]), 
				   .txo_frame		(txo_wr_frame),	 
				   .c0_tran_frame_tlc	(c0_tran_frame_tlc),
				   .c0_tran_byte_even_tlc(c0_tran_byte_even_tlc[LW-1:0]),
				   .c0_tran_byte_odd_tlc(c0_tran_byte_odd_tlc[LW-1:0]),
				   .c1_tran_frame_tlc	(c1_tran_frame_tlc),
				   .c1_tran_byte_even_tlc(c1_tran_byte_even_tlc[LW-1:0]),
				   .c1_tran_byte_odd_tlc(c1_tran_byte_odd_tlc[LW-1:0]),
				   .c2_tran_frame_tlc	(c2_tran_frame_tlc),
				   .c2_tran_byte_even_tlc(c2_tran_byte_even_tlc[LW-1:0]),
				   .c2_tran_byte_odd_tlc(c2_tran_byte_odd_tlc[LW-1:0]),
				   .c3_tran_frame_tlc	(c3_tran_frame_tlc),
				   .c3_tran_byte_even_tlc(c3_tran_byte_even_tlc[LW-1:0]),
				   .c3_tran_byte_odd_tlc(c3_tran_byte_odd_tlc[LW-1:0])); 
   link_txo_arbiter link_txo_arbiter (.c1_txo_launch_req_tlc(1'b0),
				      .c1_txo_rotate_dis(1'b0),
				      .c2_txo_launch_req_tlc(1'b0),
				      .c2_txo_rotate_dis(1'b0),
				      .c3_txo_launch_req_tlc(1'b0),
				      .c3_txo_rotate_dis(1'b0),
				      .txo_launch_req_tlc(txo_wr_launch_req_tlc), 
				      .txo_rotate_dis_tlc(txo_wr_rotate_dis), 
				      .c0_txo_launch_ack_tlc(c0_txo_launch_ack_tlc),
				      .c1_txo_launch_ack_tlc(c1_txo_launch_ack_tlc),
				      .c2_txo_launch_ack_tlc(c2_txo_launch_ack_tlc),
				      .c3_txo_launch_ack_tlc(c3_txo_launch_ack_tlc),
				      .txo_lclk		(txo_lclk),
				      .reset		(reset_sync_1),
				      .txo_wait		(txo_wr_wait),	 
				      .txo_wait_int	(txo_wr_wait_int), 
				      .c0_txo_launch_req_tlc(c0_txo_launch_req_tlc),
				      .c0_txo_rotate_dis(c0_txo_rotate_dis));
   link_txo_mesh_channel c0_link_txo_mesh_channel(.cfg_multicast_dis (cfg_multicast_dis),
						  .emesh_wait_out	(c0_emesh_wait_out), 
						  .mesh_wait_out	(c0_mesh_wait_out), 
						  .txo_launch_req_tlc	(c0_txo_launch_req_tlc), 
						  .txo_rotate_dis_tlc	(c0_txo_rotate_dis), 
						  .tran_frame_tlc	(c0_tran_frame_tlc), 
						  .tran_byte_even_tlc	(c0_tran_byte_even_tlc[LW-1:0]), 
						  .tran_byte_odd_tlc	(c0_tran_byte_odd_tlc[LW-1:0]), 
						  .cclk			(c0_clk_in),	 
						  .cclk_en		(1'b1),		 
						  .txo_lclk		(txo_lclk),	 
						  .reset		(reset_sync_1),	 
						  .ext_yid_k		(ext_yid_k[3:0]), 
						  .ext_xid_k		(ext_xid_k[3:0]), 
						  .who_am_i		(who_am_i[3:0]), 
						  .txo_rd		(1'b0),		 
						  .txo_cid		(c0_txo_cid[1:0]), 
						  .cfg_burst_dis	(cfg_burst_dis), 
						  .emesh_tran_in	(c0_emesh_tran_in[2*LW-1:0]), 
						  .emesh_frame_in	(c0_emesh_frame_in), 
						  .mesh_access_in	(c0_mesh_access_in), 
						  .mesh_write_in	(c0_mesh_write_in), 
						  .mesh_dstaddr_in	(c0_mesh_dstaddr_in[AW-1:0]), 
						  .mesh_srcaddr_in	(c0_mesh_srcaddr_in[AW-1:0]), 
						  .mesh_data_in		(c0_mesh_data_in[DW-1:0]), 
						  .mesh_datamode_in	(c0_mesh_datamode_in[1:0]), 
						  .mesh_ctrlmode_in	(c0_mesh_ctrlmode_in[3:0]), 
						  .txo_launch_ack_tlc	(c0_txo_launch_ack_tlc)); 
   link_txo_mesh_channel c3_link_txo_mesh_channel(.cfg_multicast_dis (1'b1),
						  .emesh_wait_out	(c3_emesh_wait_out), 
						  .mesh_wait_out	(c3_mesh_wait_out), 
						  .txo_launch_req_tlc	(c3_txo_launch_req_tlc), 
						  .txo_rotate_dis_tlc	(c3_txo_rotate_dis), 
						  .tran_frame_tlc	(c3_tran_frame_tlc), 
						  .tran_byte_even_tlc	(c3_tran_byte_even_tlc[LW-1:0]), 
						  .tran_byte_odd_tlc	(c3_tran_byte_odd_tlc[LW-1:0]), 
						  .cclk			(c3_clk_in),	 
						  .cclk_en		(1'b1),		 
						  .txo_lclk		(txo_lclk),	 
						  .reset		(reset_sync_1),	 
						  .ext_yid_k		(ext_yid_k[3:0]), 
						  .ext_xid_k		(ext_xid_k[3:0]), 
						  .who_am_i		(who_am_i[3:0]), 
						  .txo_rd		(1'b0),		 
						  .txo_cid		(c3_txo_cid[1:0]), 
						  .cfg_burst_dis	(cfg_burst_dis), 
						  .emesh_tran_in	(c3_emesh_tran_in[2*LW-1:0]), 
						  .emesh_frame_in	(c3_emesh_frame_in), 
						  .mesh_access_in	(c3_mesh_access_in), 
						  .mesh_write_in	(c3_mesh_write_in), 
						  .mesh_dstaddr_in	(c3_mesh_dstaddr_in[AW-1:0]), 
						  .mesh_srcaddr_in	(c3_mesh_srcaddr_in[AW-1:0]), 
						  .mesh_data_in		(c3_mesh_data_in[DW-1:0]), 
						  .mesh_datamode_in	(c3_mesh_datamode_in[1:0]), 
						  .mesh_ctrlmode_in	(c3_mesh_ctrlmode_in[3:0]), 
						  .txo_launch_ack_tlc	(c3_txo_launch_ack_tlc)); 
endmodule 
module _MAGMA_CELL_FF_ (DATA, CLOCK, CLEAR, PRESET, SLAVE_CLOCK, OUT);
   input DATA;
   input CLOCK;
   input CLEAR;
   input PRESET;
   input SLAVE_CLOCK;
   output OUT;
   reg    OUT;
   always @(posedge CLOCK or posedge PRESET or posedge CLEAR)
   if (CLEAR)
     OUT <= 1'b0;
   else
     if (PRESET)
       OUT <= 1'b1;
     else
       OUT <= DATA;
endmodule
module DFFNQX3A12TR (CKN, D, Q);
  input CKN, D;
  output Q;
  supply0 N7;
  _MAGMA_CELL_FF_ C1 (.DATA(D), .CLOCK(CKN__br_in_not), .CLEAR(N7), .PRESET(N7), .SLAVE_CLOCK(N7), .OUT(Q));
  not (CKN__br_in_not, CKN);
endmodule 
module DFFQX4A12TR (CK, D, Q);
  input CK, D;
  output Q;
  supply0 N6;
  _MAGMA_CELL_FF_ C1 (.DATA(D), .CLOCK(CK), .CLEAR(N6), .PRESET(N6), .SLAVE_CLOCK(N6), .OUT(Q));
endmodule
module MX2X4A12TR (A, B, S0, Y);
  input A, B, S0;
  output Y;
  wire N3, N6;
  and C1 (N3, S0, B);
  and C3 (N6, S0__br_in_not, A);
  not (S0__br_in_not, S0);
  or C4 (Y, N3, N6);
endmodule
`define CFG_FAKECLK   1      
`define CFG_MDW       32     
`define CFG_DW        32     
`define CFG_AW        32     
`define CFG_LW        8      
`define CFG_NW        13     
module e16_arbiter_priority(
   grant, arb_wait,
   clk, clk_en, reset_sync_1, hold, request
   );
   parameter ARW=99;
   input            clk;
   input            clk_en;
   input            reset_sync_1;
   input            hold;      
   input  [ARW-1:0] request;
   output [ARW-1:0] grant;
   output [ARW-1:0] arb_wait;
   wire [ARW-1:0] grant_mask;
   wire [ARW-1:0] request_mask;
   reg [ARW-1:0]  grant_hold;
   always @ (posedge clk or posedge reset_sync_1)
     if(reset_sync_1)
       grant_hold[ARW-1:0] <= {(ARW){1'b0}};
     else if(clk_en)       
       grant_hold[ARW-1:0] <= grant[ARW-1:0] & {(ARW){hold}};
   genvar i;
   generate              
      for(i=0;i<ARW-1;i=i+1) begin : gen_block
         assign request_mask[i]=request[i] & ~(|grant_hold[ARW-1:i+1]);	 
      end
      assign request_mask[ARW-1]=request[ARW-1];
   endgenerate
   genvar j;
   assign grant_mask[0]   = 1'b0;   
   generate for (j=ARW-1; j>=1; j=j-1) begin : gen_arbiter     
      assign grant_mask[j] = |request_mask[j-1:0];
   end
   endgenerate
   assign grant[ARW-1:0] = request_mask[ARW-1:0] & ~grant_mask[ARW-1:0];
   assign arb_wait[ARW-1:0] = request[ARW-1:0] & ({(ARW){hold}} | ~grant[ARW-1:0]);
   always @*
     if((|(grant_hold[ARW-1:0] & ~request[ARW-1:0])) & ~reset_sync_1  & $time> 0)
       begin
	  $display("ERROR>>Request not held steady in cell %m at time %0d", $time);
       end
endmodule 
module e16_arbiter_roundrobin(
   grants,
   clk, clk_en, reset_sync_1, en_rotate, requests
   );
   parameter ARW  = 5;
   input            clk;
   input            clk_en;  
   input            reset_sync_1;
   input            en_rotate;
   input  [ARW-1:0] requests; 
   output [ARW-1:0] grants;   
   integer m;    
   reg  [ARW-1:0]   request_mask; 
   reg [2*ARW-1:0]  grants_rotate_buffer;   
   reg [ARW-1:0]    grants;         
   wire [ARW-1:0]   shifted_requests[ARW-1:0];
   wire [ARW-1:0]   shifted_grants[ARW-1:0];
   wire [2*ARW-1:0] requests_rotate_buffer;
   always @ ( posedge clk or posedge reset_sync_1)
     if(reset_sync_1)
       request_mask[ARW-1:0] <= {{(ARW-1){1'b0}},1'b1};   
     else if(clk_en)
       if(en_rotate)
	 request_mask[ARW-1:0] <= {request_mask[ARW-2:0],request_mask[ARW-1]};
   assign requests_rotate_buffer[2*ARW-1:0]={requests[ARW-1:0],requests[ARW-1:0]};
   genvar i;
   generate
      for (i=0;i<ARW;i=i+1) begin: gen_requests	
	 assign shifted_requests[i]=requests_rotate_buffer[ARW-1+i:i];      
      end
   endgenerate
   genvar k;   
   generate
      for (k=0;k<ARW;k=k+1) begin: gen_arbiter
	   e16_arbiter_priority #(.ARW(ARW)) simple_arbiter(
                                                        .clk       (clk),
					                .clk_en    (clk_en),
					                .reset     (reset_sync_1),                                     
					                .hold      (1'b0),				 
					                .request   (shifted_requests[k]),                         
                                                        .arb_wait  (),
					                .grant     (shifted_grants[k])
					                );      
      end
   endgenerate   
   always @*
     begin	
	grants[ARW-1:0]      = {(ARW){1'b0}};
	for(m=0;m<ARW;m=m+1)
	  begin
	     grants_rotate_buffer[2*ARW-1:0]={shifted_grants[m],shifted_grants[m]};	
	     grants[ARW-1:0]                =grants[ARW-1:0] |
	                                     ({(ARW){request_mask[m]}} & 
					      grants_rotate_buffer[2*ARW-1-m-:ARW]
					      );
	  end
     end
endmodule 
