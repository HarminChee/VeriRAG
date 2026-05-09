module resource_update_buffer 
  (
   res_table_waiting, serviced_cam_biggest_space_size,
   serviced_cam_biggest_space_addr,
   clk, rst, res_table_done, res_tbl_cam_biggest_space_size,
   res_tbl_cam_biggest_space_addr, serviced_table
   ) ;
   parameter RES_ID_WIDTH = 10;
   parameter RES_TABLE_ADDR_WIDTH = 3;
   parameter NUMBER_RES_TABLES = 8;
   input clk, rst;
   input [NUMBER_RES_TABLES-1:0] res_table_done;
   input [NUMBER_RES_TABLES*(RES_ID_WIDTH+1)-1 :0] res_tbl_cam_biggest_space_size;
   input [NUMBER_RES_TABLES*(RES_ID_WIDTH)-1 :0]   res_tbl_cam_biggest_space_addr;
   output [NUMBER_RES_TABLES-1:0] res_table_waiting;
   input [NUMBER_RES_TABLES-1:0]  serviced_table;
   output [RES_ID_WIDTH :0] 	  serviced_cam_biggest_space_size;
   output [RES_ID_WIDTH-1 :0] 	  serviced_cam_biggest_space_addr;
   wire [NUMBER_RES_TABLES-1:0] res_table_waiting;
   reg [NUMBER_RES_TABLES-1:0] res_table_waiting_comb, res_table_waiting_i;
   reg [NUMBER_RES_TABLES-1:0] 		      res_table_done_comb,
					      res_table_done_array;
   reg [(RES_ID_WIDTH+1)*NUMBER_RES_TABLES-1:0]  biggest_space_size_comb,
					      biggest_space_size_buf;
   reg [RES_ID_WIDTH*NUMBER_RES_TABLES-1:0]  biggest_space_addr_comb,
					      biggest_space_addr_buf;
   reg [(RES_ID_WIDTH+1)*NUMBER_RES_TABLES-1:0]  mux_biggest_space_size_comb,
					      mux_biggest_space_size;
   reg [RES_ID_WIDTH*NUMBER_RES_TABLES-1:0]  mux_biggest_space_addr_comb,
					      mux_biggest_space_addr;
   always @ ( posedge clk or posedge rst ) begin
      if (rst) begin
	 biggest_space_addr_buf <= {(1+(RES_ID_WIDTH*NUMBER_RES_TABLES-1)){1'b0}};
	 biggest_space_size_buf <= {(1+((RES_ID_WIDTH+1)*NUMBER_RES_TABLES-1)){1'b0}};
	 mux_biggest_space_addr <= {(1+(RES_ID_WIDTH*NUMBER_RES_TABLES-1)){1'b0}};
	 mux_biggest_space_size <= {(1+((RES_ID_WIDTH+1)*NUMBER_RES_TABLES-1)){1'b0}};
	 res_table_waiting_i <= {NUMBER_RES_TABLES{1'b0}};
      end 
      else begin
	 res_table_waiting_i <= res_table_waiting_comb;
	 biggest_space_size_buf <= biggest_space_size_comb;
	 biggest_space_addr_buf <= biggest_space_addr_comb;
	 mux_biggest_space_size <= mux_biggest_space_size_comb;
	 mux_biggest_space_addr <= mux_biggest_space_addr_comb;
      end
   end
   assign serviced_cam_biggest_space_size = mux_biggest_space_size;
   assign serviced_cam_biggest_space_addr = mux_biggest_space_addr;
   assign res_table_waiting = res_table_waiting_i;
   always @ ( biggest_space_addr_buf
	     or biggest_space_size_buf or res_table_done
	     or res_table_waiting_i or res_tbl_cam_biggest_space_addr
	     or res_tbl_cam_biggest_space_size or serviced_table) begin : BUFFER_UPDATE_LOGIC
      integer res_table_i;
      res_table_waiting_comb = (res_table_waiting_i |
			       res_table_done) &
			      (~serviced_table);
      biggest_space_size_comb = biggest_space_size_buf;
      biggest_space_addr_comb = biggest_space_addr_buf;
      for(res_table_i =0; res_table_i <NUMBER_RES_TABLES; 
	  res_table_i = res_table_i+1) begin
	 if(res_table_done[res_table_i]) begin
	    biggest_space_size_comb
	      [res_table_i*(RES_ID_WIDTH+1)+:RES_ID_WIDTH+1] = res_tbl_cam_biggest_space_size[res_table_i*(RES_ID_WIDTH+1)+:RES_ID_WIDTH+1];
	    biggest_space_addr_comb[res_table_i*RES_ID_WIDTH+:RES_ID_WIDTH] = res_tbl_cam_biggest_space_addr[res_table_i*RES_ID_WIDTH+:RES_ID_WIDTH];
	 end
      end 
   end 
   always @ ( biggest_space_addr_buf
	     or biggest_space_size_buf or serviced_table) begin : OUTPUT_MUX
      integer mux_res_tbl_i;
      mux_biggest_space_size_comb = 0;
      mux_biggest_space_addr_comb = 0;
      for (mux_res_tbl_i=0; mux_res_tbl_i<NUMBER_RES_TABLES; 
	   mux_res_tbl_i=mux_res_tbl_i+1) begin
	 if(serviced_table[mux_res_tbl_i]) begin
	    mux_biggest_space_size_comb
	      = biggest_space_size_buf[mux_res_tbl_i*(RES_ID_WIDTH+1)
					    +:(RES_ID_WIDTH+1)];
	    mux_biggest_space_addr_comb 
	      = biggest_space_addr_buf[mux_res_tbl_i*RES_ID_WIDTH
					    +:RES_ID_WIDTH];
	 end
      end 
   end 
endmodule 
