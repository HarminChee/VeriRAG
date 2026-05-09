module dis_controller (
   dis_controller_start_alloc, dis_controller_alloc_ack,
   dis_controller_wg_alloc_valid, dis_controller_wg_dealloc_valid,
   dis_controller_wg_rejected_valid, dis_controller_cu_busy,
   clk, rst, inflight_wg_buffer_alloc_valid,
   inflight_wg_buffer_alloc_available, allocator_cu_valid,
   allocator_cu_rejected, allocator_cu_id_out, grt_wg_alloc_done,
   grt_wg_dealloc_done, grt_wg_alloc_wgid, grt_wg_dealloc_wgid,
   grt_wg_alloc_cu_id, grt_wg_dealloc_cu_id,
   gpu_interface_alloc_available, gpu_interface_dealloc_available,
   gpu_interface_cu_id
   ) ;
   parameter NUMBER_CU = 64;
   parameter CU_ID_WIDTH = 6;
   parameter RES_TABLE_ADDR_WIDTH = 1;
   localparam NUMBER_RES_TABLE = 2**RES_TABLE_ADDR_WIDTH;
   localparam CU_PER_RES_TABLE = NUMBER_CU/NUMBER_RES_TABLE;
   input clk,rst;
   input inflight_wg_buffer_alloc_valid, inflight_wg_buffer_alloc_available;
   input allocator_cu_valid, allocator_cu_rejected;
   input [CU_ID_WIDTH-1 :0] allocator_cu_id_out;
   input 		    grt_wg_alloc_done, grt_wg_dealloc_done;
   input [CU_ID_WIDTH-1:0]  grt_wg_alloc_wgid, grt_wg_dealloc_wgid;
   input [CU_ID_WIDTH-1 :0] grt_wg_alloc_cu_id, grt_wg_dealloc_cu_id;
   input 		    gpu_interface_alloc_available, 
			    gpu_interface_dealloc_available;
   input [CU_ID_WIDTH-1:0]  gpu_interface_cu_id;
   output 		       dis_controller_start_alloc;
   output 		       dis_controller_alloc_ack;
   output 		       dis_controller_wg_alloc_valid;
   output 		       dis_controller_wg_dealloc_valid;
   output 		       dis_controller_wg_rejected_valid;
   output [NUMBER_CU-1:0] dis_controller_cu_busy;
   reg [NUMBER_CU-1:0]   cus_allocating;
   reg [NUMBER_RES_TABLE-1:0] cu_groups_allocating;
   reg [CU_ID_WIDTH-1 :0] alloc_waiting_cu_id;
   reg 			  alloc_waiting;
   reg 		       dis_controller_start_alloc_i;
   reg 		       dis_controller_alloc_ack_i;
   reg 		       dis_controller_wg_alloc_valid_i;
   reg 		       dis_controller_wg_dealloc_valid_i;
   reg 		       dis_controller_wg_rejected_valid_i;
   localparam ALLOC_NUM_STATES = 4;
   localparam ST_AL_IDLE = 0;
   localparam ST_AL_ALLOC = 2;
   localparam ST_AL_HANDLE_RESULT = 4;
   localparam ST_AL_ACK_PROPAGATION = 8;
   reg [ALLOC_NUM_STATES-1:0] alloc_st;
   function [RES_TABLE_ADDR_WIDTH-1:0] get_res_tbl_addr;
     input[CU_ID_WIDTH-1 :0] cu_id;
      begin
	 get_res_tbl_addr = cu_id[CU_ID_WIDTH-1 -: RES_TABLE_ADDR_WIDTH];
      end
   endfunction 
   always @ (  posedge clk or posedge rst ) begin
      if(rst) begin
	 alloc_st <= ST_AL_IDLE;
	 alloc_waiting <= 1'h0;
	 alloc_waiting_cu_id <= {CU_ID_WIDTH{1'b0}};
	 cu_groups_allocating <= {NUMBER_RES_TABLE{1'b0}};
	 dis_controller_alloc_ack_i <= 1'h0;
	 dis_controller_start_alloc_i <= 1'h0;
	 dis_controller_wg_alloc_valid_i <= 1'h0;
	 dis_controller_wg_dealloc_valid_i <= 1'h0;
	 dis_controller_wg_rejected_valid_i <= 1'h0;
      end
      else begin
	 dis_controller_start_alloc_i <= 1'b0;
	 dis_controller_alloc_ack_i <= 1'b0;
	 case(alloc_st)
	    ST_AL_IDLE: begin
	       if(inflight_wg_buffer_alloc_valid && !(&cu_groups_allocating) ) begin
		  dis_controller_start_alloc_i <= 1'b1;
		  alloc_st <= ST_AL_ALLOC;
	       end
	    end
	   ST_AL_ALLOC: begin
	      if(allocator_cu_valid) begin
		 alloc_waiting <= 1'b1;
		 alloc_waiting_cu_id <= allocator_cu_id_out;
		 alloc_st <= ST_AL_HANDLE_RESULT;
	      end 
	   end
	   ST_AL_HANDLE_RESULT: begin
	      if(!alloc_waiting) begin
		 dis_controller_alloc_ack_i <= 1'b1;
		 alloc_st <= ST_AL_ACK_PROPAGATION;
	      end
	   end 
	   ST_AL_ACK_PROPAGATION: begin
	      alloc_st <= ST_AL_IDLE;
	   end
	 endcase 
	 dis_controller_wg_dealloc_valid_i <= 1'b0;
	 dis_controller_wg_alloc_valid_i <= 1'b0;
	 dis_controller_wg_rejected_valid_i <= 1'b0;
	 if(gpu_interface_dealloc_available && 
	    !cu_groups_allocating[get_res_tbl_addr(gpu_interface_cu_id)]) begin
	    dis_controller_wg_dealloc_valid_i <= 1'b1;
	    cu_groups_allocating[get_res_tbl_addr(gpu_interface_cu_id)] <= 1'b1;
	 end
	 else if(alloc_waiting && 
		 !cu_groups_allocating[get_res_tbl_addr(alloc_waiting_cu_id)]) begin
	    if(allocator_cu_rejected) begin
	       alloc_waiting <= 1'b0;
	       dis_controller_wg_rejected_valid_i <= 1'b1;
	    end
	    else if(gpu_interface_alloc_available && 
		    inflight_wg_buffer_alloc_available) begin
	       alloc_waiting <= 1'b0;
	       dis_controller_wg_alloc_valid_i <= 1'b1;
	       cu_groups_allocating[get_res_tbl_addr(alloc_waiting_cu_id)] <= 1'b1;
	    end
	 end 
	 if(grt_wg_alloc_done) begin
	    cu_groups_allocating[get_res_tbl_addr(grt_wg_alloc_cu_id)] <= 1'b0;
	 end
	 else if(grt_wg_dealloc_done) begin
	    cu_groups_allocating[get_res_tbl_addr(grt_wg_dealloc_cu_id)] <= 1'b0;
	 end
      end 
   end 
   always @ ( cu_groups_allocating) begin : EXPAND_CU_GROUPS
      reg[CU_ID_WIDTH :0] i;
      for (i=0; i < NUMBER_CU; i=i+1) begin
	 cus_allocating[i] = cu_groups_allocating[get_res_tbl_addr(i[CU_ID_WIDTH-1:0])];
      end
   end
   assign dis_controller_start_alloc = dis_controller_start_alloc_i;
   assign dis_controller_alloc_ack = dis_controller_alloc_ack_i;
   assign dis_controller_wg_alloc_valid = dis_controller_wg_alloc_valid_i;
   assign dis_controller_wg_dealloc_valid = dis_controller_wg_dealloc_valid_i;
   assign dis_controller_wg_rejected_valid = dis_controller_wg_rejected_valid_i;
   assign dis_controller_cu_busy = cus_allocating;
endmodule 
