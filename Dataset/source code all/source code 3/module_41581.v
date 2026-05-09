 module avalon_st_traffic_controller (
	input 	wire		avl_mm_read      ,
	input 	wire		avl_mm_write     ,
	output 	wire		avl_mm_waitrequest,
	input 	wire[23:0]	avl_mm_baddress   ,
	output 	wire[31:0]	avl_mm_readdata  ,
	input 	wire[31:0]	avl_mm_writedata ,
	input 	wire 		clk_in	,
	input 	wire 		reset_n	,
	input 	wire[39:0] 	mac_rx_status_data	,
	input 	wire		mac_rx_status_valid	,
	input 	wire		mac_rx_status_error	,
	input   wire	        stop_mon	,
	output  wire	        mon_active	,
	output  wire	        mon_done	,
	output  wire	        mon_error	,
	output 	wire[63:0] 	avl_st_tx_data	,
	output 	wire[2:0]  	avl_st_tx_empty	,
	output 	wire 		avl_st_tx_eop	,
	output 	wire 		avl_st_tx_error	,
	input 	wire 		avl_st_tx_rdy	,
	output 	wire 		avl_st_tx_sop	,
	output 	wire 		avl_st_tx_val	,             
	input 	wire[63:0] 	avl_st_rx_data	,
	input 	wire[2:0]  	avl_st_rx_empty	,
	input 	wire 		avl_st_rx_eop	,
	input 	wire [5:0]	avl_st_rx_error	,
	output 	wire 		avl_st_rx_rdy	,
	input 	wire 		avl_st_rx_sop	,
	input 	wire 		avl_st_rx_val
    );
	wire  avl_st_rx_lpmx_mon_eop;
	wire[5:0]  avl_st_rx_lpmx_mon_error;
	wire  avl_st_rx_mon_lpmx_rdy;
	wire  avl_st_rx_lpmx_mon_sop;
	wire  avl_st_rx_lpmx_mon_val; 
	wire[63:0] avl_st_rx_lpmx_mon_data;
	wire[2:0]  avl_st_rx_lpmx_mon_empty;
	wire[23:0] avl_mm_address = {2'b00, avl_mm_baddress[23:2]}; 
	wire[31:0] avl_mm_readdata_gen, avl_mm_readdata_mon;
	wire  blk_sel_gen = (avl_mm_address[23:16] == 8'd0);
	wire  blk_sel_mon = (avl_mm_address[23:16] == 8'd1);
 	wire waitrequest_gen, waitrequest_mon;
   	assign avl_mm_waitrequest = blk_sel_gen?waitrequest_gen:blk_sel_mon? waitrequest_mon:1'b0;
	assign avl_mm_readdata = blk_sel_gen? avl_mm_readdata_gen:blk_sel_mon? avl_mm_readdata_mon:32'd0;
	wire gen_lpbk;
        wire sync_reset;
   traffic_reset_sync reset_sync
    ( .clk      (clk_in),
      .data_in  (1'b0),
      .reset    (~reset_n),
      .data_out (sync_reset)
    );
 	avalon_st_gen  GEN (
	.clk         (clk_in), 	 			
	.reset       (sync_reset), 			
	.address     (avl_mm_address[7:0]), 		
	.write       (avl_mm_write & blk_sel_gen), 	
	.writedata   (avl_mm_writedata), 		
	.read        (avl_mm_read & blk_sel_gen), 	
	.readdata    (avl_mm_readdata_gen), 		
	.waitrequest (waitrequest_gen),   		
	.tx_data     (avl_st_tx_data), 			
	.tx_valid    (avl_st_tx_val), 			
	.tx_sop      (avl_st_tx_sop), 			
	.tx_eop      (avl_st_tx_eop), 			
	.tx_empty    (avl_st_tx_empty), 		
	.tx_error    (avl_st_tx_error), 		
	.tx_ready    (avl_st_tx_rdy) 
	);
 	avalon_st_mon  	MON (
	.clk       		(clk_in ),     			
	.reset     		(sync_reset ),     		
	.avalon_mm_address   	(avl_mm_address[7:0]),     	
	.avalon_mm_write     	(avl_mm_write & blk_sel_mon),  	
	.avalon_mm_writedata 	(avl_mm_writedata),     	
	.avalon_mm_read    	(avl_mm_read & blk_sel_mon),   	
	.avalon_mm_waitrequest 	(waitrequest_mon),   		
	.avalon_mm_readdata  	(avl_mm_readdata_mon),     	
	.mac_rx_status_valid	(mac_rx_status_valid),     		
	.mac_rx_status_error	(mac_rx_status_error),     		
	.mac_rx_status_data 	(mac_rx_status_data),     		
	.stop_mon 		(stop_mon),     		
	.mon_active 		(mon_active),     		
	.mon_done 		(mon_done),     		
	.mon_error 		(mon_error),     		
	.gen_lpbk 		(gen_lpbk),     		
	.avalon_st_rx_data   	(avl_st_rx_data),    	
	.avalon_st_rx_valid  	(avl_st_rx_val),     	
	.avalon_st_rx_sop    	(avl_st_rx_sop),     	
	.avalon_st_rx_eop    	(avl_st_rx_eop),     	
	.avalon_st_rx_empty  	(avl_st_rx_empty),   	
	.avalon_st_rx_error  	(avl_st_rx_error),   	
	.avalon_st_rx_ready  	(avl_st_rx_rdy)    	
	);
 endmodule
 module avalon_st_traffic_controller (
	input 	wire		avl_mm_read      ,
	input 	wire		avl_mm_write     ,
	output 	wire		avl_mm_waitrequest,
	input 	wire[23:0]	avl_mm_baddress   ,
	output 	wire[31:0]	avl_mm_readdata  ,
	input 	wire[31:0]	avl_mm_writedata ,
	input 	wire 		clk_in	,
	input 	wire 		reset_n	,
	input 	wire[39:0] 	mac_rx_status_data	,
	input 	wire		mac_rx_status_valid	,
	input 	wire		mac_rx_status_error	,
	input   wire	        stop_mon	,
	output  wire	        mon_active	,
	output  wire	        mon_done	,
	output  wire	        mon_error	,
	output 	wire[63:0] 	avl_st_tx_data	,
	output 	wire[2:0]  	avl_st_tx_empty	,
	output 	wire 		avl_st_tx_eop	,
	output 	wire 		avl_st_tx_error	,
	input 	wire 		avl_st_tx_rdy	,
	output 	wire 		avl_st_tx_sop	,
	output 	wire 		avl_st_tx_val	,             
	input 	wire[63:0] 	avl_st_rx_data	,
	input 	wire[2:0]  	avl_st_rx_empty	,
	input 	wire 		avl_st_rx_eop	,
	input 	wire [5:0]	avl_st_rx_error	,
	output 	wire 		avl_st_rx_rdy	,
	input 	wire 		avl_st_rx_sop	,
	input 	wire 		avl_st_rx_val
    );
	wire  avl_st_rx_lpmx_mon_eop;
	wire[5:0]  avl_st_rx_lpmx_mon_error;
	wire  avl_st_rx_mon_lpmx_rdy;
	wire  avl_st_rx_lpmx_mon_sop;
	wire  avl_st_rx_lpmx_mon_val; 
	wire[63:0] avl_st_rx_lpmx_mon_data;
	wire[2:0]  avl_st_rx_lpmx_mon_empty;
	wire[23:0] avl_mm_address = {2'b00, avl_mm_baddress[23:2]}; 
	wire[31:0] avl_mm_readdata_gen, avl_mm_readdata_mon;
	wire  blk_sel_gen = (avl_mm_address[23:16] == 8'd0);
	wire  blk_sel_mon = (avl_mm_address[23:16] == 8'd1);
 	wire waitrequest_gen, waitrequest_mon;
   	assign avl_mm_waitrequest = blk_sel_gen?waitrequest_gen:blk_sel_mon? waitrequest_mon:1'b0;
	assign avl_mm_readdata = blk_sel_gen? avl_mm_readdata_gen:blk_sel_mon? avl_mm_readdata_mon:32'd0;
	wire gen_lpbk;
        wire sync_reset;
   traffic_reset_sync reset_sync
    ( .clk      (clk_in),
      .data_in  (1'b0),
      .reset    (~reset_n),
      .data_out (sync_reset)
    );
 	avalon_st_gen  GEN (
	.clk         (clk_in), 	 			
	.reset       (sync_reset), 			
	.address     (avl_mm_address[7:0]), 		
	.write       (avl_mm_write & blk_sel_gen), 	
	.writedata   (avl_mm_writedata), 		
	.read        (avl_mm_read & blk_sel_gen), 	
	.readdata    (avl_mm_readdata_gen), 		
	.waitrequest (waitrequest_gen),   		
	.tx_data     (avl_st_tx_data), 			
	.tx_valid    (avl_st_tx_val), 			
	.tx_sop      (avl_st_tx_sop), 			
	.tx_eop      (avl_st_tx_eop), 			
	.tx_empty    (avl_st_tx_empty), 		
	.tx_error    (avl_st_tx_error), 		
	.tx_ready    (avl_st_tx_rdy) 
	);
 	avalon_st_mon  	MON (
	.clk       		(clk_in ),     			
	.reset     		(sync_reset ),     		
	.avalon_mm_address   	(avl_mm_address[7:0]),     	
	.avalon_mm_write     	(avl_mm_write & blk_sel_mon),  	
	.avalon_mm_writedata 	(avl_mm_writedata),     	
	.avalon_mm_read    	(avl_mm_read & blk_sel_mon),   	
	.avalon_mm_waitrequest 	(waitrequest_mon),   		
	.avalon_mm_readdata  	(avl_mm_readdata_mon),     	
	.mac_rx_status_valid	(mac_rx_status_valid),     		
	.mac_rx_status_error	(mac_rx_status_error),     		
	.mac_rx_status_data 	(mac_rx_status_data),     		
	.stop_mon 		(stop_mon),     		
	.mon_active 		(mon_active),     		
	.mon_done 		(mon_done),     		
	.mon_error 		(mon_error),     		
	.gen_lpbk 		(gen_lpbk),     		
	.avalon_st_rx_data   	(avl_st_rx_data),    	
	.avalon_st_rx_valid  	(avl_st_rx_val),     	
	.avalon_st_rx_sop    	(avl_st_rx_sop),     	
	.avalon_st_rx_eop    	(avl_st_rx_eop),     	
	.avalon_st_rx_empty  	(avl_st_rx_empty),   	
	.avalon_st_rx_error  	(avl_st_rx_error),   	
	.avalon_st_rx_ready  	(avl_st_rx_rdy)    	
	);
 endmodule
module traffic_reset_sync ( clk, data_in, reset, data_out) ;
  output data_out;
  input  clk;
  input  data_in;
  input  reset;
  reg   data_in_d1 ;
  reg   data_out ;
  always @(posedge clk or posedge reset)
    begin
      if (reset == 1) data_in_d1 <= 1;
      else data_in_d1 <= data_in;
    end
  always @(posedge clk or posedge reset)
    begin
      if (reset == 1) data_out <= 1;
      else data_out <= data_in_d1;
    end
endmodule
