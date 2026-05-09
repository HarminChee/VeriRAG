module ext_fifo
  #(parameter INT_WIDTH=36,EXT_WIDTH=18,RAM_DEPTH=19,FIFO_DEPTH=19)
    (
     input int_clk,
     input ext_clk,
     input rst,
     input [EXT_WIDTH-1:0] RAM_D_pi,
     output [EXT_WIDTH-1:0] RAM_D_po,
     output RAM_D_poe,
     output [RAM_DEPTH-1:0] RAM_A,
     output RAM_WEn,
     output RAM_CENn,
     output RAM_LDn,
     output RAM_OEn,
     output RAM_CE1n,
     input [INT_WIDTH-1:0] datain,
     input src_rdy_i,                
     output dst_rdy_o,               
     output [INT_WIDTH-1:0] dataout,
     output src_rdy_o,               
     input dst_rdy_i,                 
     output reg [31:0] debug,
     output reg [31:0] debug2
     );
   wire [EXT_WIDTH-1:0] write_data;
   wire [EXT_WIDTH-1:0] read_data;
   wire 		full1, empty1;
   wire 		almost_full2, almost_full2_spread, full2, empty2;
   wire [FIFO_DEPTH-1:0] capacity;
   wire 		 space_avail;
   wire 		 data_avail;
   wire 		 read_input_fifo = space_avail & ~empty1;
   wire 		 write_output_fifo = data_avail;
   assign 		 src_rdy_o = ~empty2;
   assign 		 dst_rdy_o = ~full1;
`ifdef NO_EXT_FIFO
   assign 		 space_avail = ~full2;
   assign 		 data_avail = ~empty1;
   assign 		 read_data = write_data;
`else
   nobl_fifo  #(.WIDTH(EXT_WIDTH),.RAM_DEPTH(RAM_DEPTH),.FIFO_DEPTH(FIFO_DEPTH))
     nobl_fifo_i1
       (   
	   .clk(ext_clk),
	   .rst(rst),
	   .RAM_D_pi(RAM_D_pi),
	   .RAM_D_po(RAM_D_po),
	   .RAM_D_poe(RAM_D_poe),
	   .RAM_A(RAM_A),
	   .RAM_WEn(RAM_WEn),
	   .RAM_CENn(RAM_CENn),
	   .RAM_LDn(RAM_LDn),
	   .RAM_OEn(RAM_OEn),
	   .RAM_CE1n(RAM_CE1n),
	   .write_data(write_data),
	   .write_strobe(~empty1 ),
	   .space_avail(space_avail),
	   .read_data(read_data),
	   .read_strobe(~almost_full2_spread),
	   .data_avail(data_avail),
	   .capacity(capacity)
	   );
`endif 
   generate
      if (EXT_WIDTH == 18 && INT_WIDTH == 36) begin: fifo_g1
	 fifo_xlnx_512x36_2clk_36to18 fifo_xlnx_512x36_2clk_36to18_i1 (
								       .rst(rst),
								       .wr_clk(int_clk),
								       .rd_clk(ext_clk),
								       .din(datain), 
								       .wr_en(src_rdy_i), 
								       .rd_en(read_input_fifo),    		
								       .dout(write_data), 
								       .full(full1),			
							               .empty(empty1));
	 fifo_xlnx_512x36_2clk_18to36 fifo_xlnx_512x36_2clk_18to36_i1 (
								       .rst(rst),
								       .wr_clk(ext_clk),
								       .rd_clk(int_clk),
								       .din(read_data), 
								       .wr_en(write_output_fifo),
								       .rd_en(dst_rdy_i),
								       .dout(dataout), 
								       .full(full2),
								       .prog_full(almost_full2),
								       .empty(empty2));
      end 
      else if (EXT_WIDTH == 36 && INT_WIDTH == 36) begin: fifo_g1
	 fifo_xlnx_32x36_2clk fifo_xlnx_32x36_2clk_i1 (
						       .rst(rst),
						       .wr_clk(int_clk),
						       .rd_clk(ext_clk),
						       .din(datain), 
						       .wr_en(src_rdy_i),
						       .rd_en(read_input_fifo),
						       .dout(write_data), 
						       .full(full1),
						       .empty(empty1));
	 fifo_xlnx_512x36_2clk_prog_full fifo_xlnx_32x36_2clk_prog_full_i1 (
									    .rst(rst),
									    .wr_clk(ext_clk),
									    .rd_clk(int_clk),
									    .din(read_data), 
									    .wr_en(write_output_fifo),
									    .rd_en(dst_rdy_i),
									    .dout(dataout), 
									    .full(full2),
									    .empty(empty2),
									    .prog_full(almost_full2));
      end    
   endgenerate
   refill_randomizer #(.BITS(7))
     refill_randomizer_i1 (
			   .clk(ext_clk),
			   .rst(rst),
			   .full_in(almost_full2),
			   .full_out(almost_full2_spread)
			   );
   always @ (posedge ext_clk)
     debug[31:0] <= {7'h0,src_rdy_i,read_input_fifo,write_output_fifo,dst_rdy_i,full2,almost_full2,empty2,full1,empty1,write_data[7:0],read_data[7:0]};
   always@ (posedge ext_clk)
     debug2[31:0] <= 0;
endmodule 
