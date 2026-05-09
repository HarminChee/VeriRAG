module alt_mem_ddrx_mm_st_converter # (
	parameter       
        AVL_SIZE_WIDTH   = 3,
        AVL_ADDR_WIDTH   = 25,
        AVL_DATA_WIDTH   = 32,
        LOCAL_ID_WIDTH = 8,
        CFG_DWIDTH_RATIO = 4
	) 
	(
	    ctl_clk, 
        ctl_reset_n, 
        ctl_half_clk, 
        ctl_half_clk_reset_n, 
        avl_ready, 
        avl_read_req, 
        avl_write_req, 
        avl_size, 
        avl_burstbegin, 
        avl_addr, 
        avl_rdata_valid, 
        avl_rdata, 
        avl_wdata, 
        avl_be, 
        local_rdata_error, 
        local_multicast, 
        local_autopch_req, 
        local_priority, 
		itf_cmd_ready,
		itf_cmd_valid,
		itf_cmd,
		itf_cmd_address,
		itf_cmd_burstlen,
		itf_cmd_id,
		itf_cmd_priority,
		itf_cmd_autopercharge,
		itf_cmd_multicast,
		itf_wr_data_ready,
		itf_wr_data_valid,
		itf_wr_data,
		itf_wr_data_byte_en,
		itf_wr_data_begin,
		itf_wr_data_last,
		itf_wr_data_id,
		itf_rd_data_ready,
		itf_rd_data_valid,
		itf_rd_data,
		itf_rd_data_error,
		itf_rd_data_begin,
		itf_rd_data_last,
		itf_rd_data_id	
);
    input ctl_clk;
    input ctl_reset_n;
    input ctl_half_clk;
    input ctl_half_clk_reset_n;
    output avl_ready;
    input avl_read_req;
    input avl_write_req;
    input  [AVL_SIZE_WIDTH-1:0] avl_size;
    input avl_burstbegin;
    input  [AVL_ADDR_WIDTH-1:0] avl_addr;
    output avl_rdata_valid;
    output [3:0] local_rdata_error;
    output [AVL_DATA_WIDTH-1:0] avl_rdata;
    input  [AVL_DATA_WIDTH-1:0] avl_wdata;
    input  [AVL_DATA_WIDTH/8-1:0] avl_be;
    input local_multicast;
    input local_autopch_req;
    input local_priority;
    input itf_cmd_ready;
    output itf_cmd_valid;
    output itf_cmd;
    output [AVL_ADDR_WIDTH-1:0] itf_cmd_address;
    output [AVL_SIZE_WIDTH-1:0] itf_cmd_burstlen;
    output [LOCAL_ID_WIDTH-1:0] itf_cmd_id;
    output itf_cmd_priority;
    output itf_cmd_autopercharge;
    output itf_cmd_multicast;
    input itf_wr_data_ready;
    output itf_wr_data_valid;
    output [AVL_DATA_WIDTH-1:0] itf_wr_data;
    output [AVL_DATA_WIDTH/8-1:0] itf_wr_data_byte_en;
    output itf_wr_data_begin;
    output itf_wr_data_last;
    output [LOCAL_ID_WIDTH-1:0] itf_wr_data_id;
    output itf_rd_data_ready;
    input itf_rd_data_valid;
    input [AVL_DATA_WIDTH-1:0] itf_rd_data;
    input itf_rd_data_error;
    input itf_rd_data_begin;
    input itf_rd_data_last;
    input [LOCAL_ID_WIDTH-1:0] itf_rd_data_id;
    reg [AVL_SIZE_WIDTH-1:0] burst_count;
    wire    int_ready;
    wire    itf_cmd; 
    wire    itf_wr_if_ready;
    reg     data_pass;
    reg     [AVL_SIZE_WIDTH-1:0] burst_counter;
    assign itf_cmd_valid = avl_read_req | itf_wr_if_ready;
    assign itf_wr_if_ready = itf_wr_data_ready & avl_write_req & ~data_pass;
    assign avl_ready = int_ready;
    assign itf_rd_data_ready = 1'b1;
    assign itf_cmd_address = avl_addr ;
    assign itf_cmd_burstlen = avl_size ;
    assign itf_cmd_autopercharge = local_autopch_req ;
    assign itf_cmd_priority = local_priority ;
    assign itf_cmd_multicast = local_multicast ;
    assign itf_cmd = avl_write_req;
    assign itf_wr_data_valid = (data_pass) ? avl_write_req : itf_cmd_ready & avl_write_req;
    assign itf_wr_data = avl_wdata ;
    assign itf_wr_data_byte_en = avl_be ;
    assign avl_rdata_valid = itf_rd_data_valid;
    assign avl_rdata =  itf_rd_data;
    assign local_rdata_error = itf_rd_data_error;
    assign int_ready = (data_pass) ? itf_wr_data_ready : ((itf_cmd) ? (itf_wr_data_ready & itf_cmd_ready) : itf_cmd_ready);
    always @(posedge ctl_clk, negedge ctl_reset_n)
        begin
            if (!ctl_reset_n)
                burst_counter  <=  0;
            else
                begin
                    if (itf_wr_if_ready && avl_size > 1 && itf_cmd_ready)
                        burst_counter   <=  avl_size - 1;
                    else if (avl_write_req && itf_wr_data_ready)
                        burst_counter   <=  burst_counter - 1;
                end
        end                    
    always @(posedge ctl_clk, negedge ctl_reset_n)
        begin
            if (!ctl_reset_n)
                data_pass  <=  0;
            else
                begin
                    if (itf_wr_if_ready && avl_size > 1 && itf_cmd_ready)
                        data_pass  <=  1;
                    else if (burst_counter == 1 && avl_write_req && itf_wr_data_ready)
                        data_pass  <=  0;
                end
        end
endmodule
