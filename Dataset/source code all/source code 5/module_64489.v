module emmu (
   reg_rdata, emesh_access_out, emesh_packet_out,
   wr_clk, rd_clk, nreset, mmu_en, reg_access, reg_packet,
   emesh_access_in, emesh_packet_in, emesh_wait_in
   );
   parameter  AW     = 32;            
   parameter  MW     = 48;            
   parameter  MAW    = 12;            
   localparam PW     = 2*AW+40;       
   input 	     nreset;          
   input 	     mmu_en;          
   input 	     wr_clk;          
   input 	     reg_access;      
   input [PW-1:0]    reg_packet;      
   output [31:0]     reg_rdata;       
   input 	     rd_clk;          
   input 	     emesh_access_in; 
   input [PW-1:0]    emesh_packet_in; 
   input 	     emesh_wait_in;   
   output 	     emesh_access_out;
   output [PW-1:0]   emesh_packet_out;
   reg 		      emesh_access_out;
   reg [PW-1:0]       emesh_packet_reg;
   wire [63:0] 	      emesh_dstaddr_out;   
   wire [MW-1:0]      emmu_lookup_data;
   wire [MW-1:0]      mem_wem;
   wire [MW-1:0]      mem_data;   
   wire [AW-1:0]      emesh_dstaddr_in;
   wire [4:0]		reg_ctrlmode;		
   wire [AW-1:0]	reg_data;		
   wire [1:0]		reg_datamode;		
   wire [AW-1:0]	reg_dstaddr;		
   wire [AW-1:0]	reg_srcaddr;		
   wire			reg_write;		
   packet2emesh #(.AW(AW))
   pe2 (
	.write_in			(reg_write),		 
	.datamode_in			(reg_datamode[1:0]),	 
	.ctrlmode_in			(reg_ctrlmode[4:0]),	 
	.dstaddr_in			(reg_dstaddr[AW-1:0]),	 
	.srcaddr_in			(reg_srcaddr[AW-1:0]),	 
	.data_in			(reg_data[AW-1:0]),	 
	.packet_in			(reg_packet[PW-1:0]));	 
   assign mem_wem[MW-1:0] = ~reg_dstaddr[2] ? {{(MW-32){1'b0}},32'hFFFFFFFF} :
                                              {{(MW-32){1'b1}},32'h00000000};
   assign mem_write       = reg_access & 
			    reg_write;
   assign mem_data[MW-1:0] = {reg_data[31:0], reg_data[31:0]};
   packet2emesh  #(.AW(32))
   p2e (
	.write_in	(),
	.datamode_in	(),
	.ctrlmode_in	(),
	.dstaddr_in	(emesh_dstaddr_in[AW-1:0]),
	.srcaddr_in	(),
	.data_in	(),
	.packet_in	(emesh_packet_in[PW-1:0]));
   oh_memory_dp #(.DW(MW),
		  .DEPTH(4096))
   memory_dp (
	      .rd_dout       (emmu_lookup_data[MW-1:0]),
	      .rd_en	     (emesh_access_in),
	      .rd_addr	     (emesh_dstaddr_in[31:20]),
	      .rd_clk	     (rd_clk),
	      .wr_en	     (mem_write),
	      .wr_wem	     (mem_wem[MW-1:0]),
	      .wr_addr	     (reg_dstaddr[14:3]),
 	      .wr_din	     (mem_data[MW-1:0]),
	      .wr_clk	     (wr_clk)
	      );
   always @ (posedge  rd_clk)
     if (!nreset)
       emesh_access_out         <=  1'b0;   
     else if(~emesh_wait_in)
       emesh_access_out         <=  emesh_access_in;
   always @ (posedge  rd_clk)
     if(~emesh_wait_in)
       emesh_packet_reg[PW-1:0] <=  emesh_packet_in[PW-1:0];	  
   assign emesh_dstaddr_out[63:0] = mmu_en ? {emmu_lookup_data[43:0], 
					      emesh_packet_reg[27:8]} :
				             {32'b0,emesh_packet_reg[39:8]}; 
   assign emesh_packet_out[PW-1:0] = {emesh_packet_reg[PW-1:40],
                                      emesh_dstaddr_out[31:0],
                                      emesh_packet_reg[7:0]
				     };
endmodule 
