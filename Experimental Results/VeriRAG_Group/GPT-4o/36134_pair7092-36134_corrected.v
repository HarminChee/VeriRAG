module i2c_bus_controller(
	iCLK,  
	iRST_n, 
	iStart,  
	iSlave_addr, 
	iWord_addr,   
	iSequential_read, 
	iRead_length, 
	i2c_clk, 
	i2c_data, 
	read_data_tmp, 
	wr_data,
	wr_cmd,
	oSYSTEM_STATE,
	oCONFIG_DONE,
	i2c_clk_cnt,
    i2c_state,
	i2c_bit_cnt,
	shift_out,
	slave_addr1_shift_en,
    slave_addr2_shift_en,
    word_addr1_shift_en,
    data_shift_en,
	system_clk,
	i2c_clk_src,
	falling_edge,
    rising_edge,
    process_en,
	start_data_control,
    stop_data_control,
	start_clk_control,
	stop_clk_control,
	i2c_master_out,
	i2c_slave_out,
	i2c_read_done,
	i2c_read_data,
	read_length,
	i2c_read_data_rdy,
	test_start,
	test_cnt,
	wr_data_en,
	i2c_stop_ctrl_cnt,
    test_i
				);
input			iCLK;
input			iRST_n;
input			iStart;
input	[2:0]	iSlave_addr;
input	[7:0]	iWord_addr;
input	[7:0]	iRead_length;
input	[7:0]   wr_data;
input			wr_cmd;
input			iSequential_read;
inout			i2c_data;
output 		oSYSTEM_STATE;
output		oCONFIG_DONE;
output	reg	[1:0]	i2c_clk_cnt;
output	reg	[5:0]	i2c_state;
output	reg	[2:0]	i2c_bit_cnt;
output	reg			system_clk;
output	reg			i2c_clk_src;
output	wire			process_en;
output	wire			falling_edge;
output	wire	    	rising_edge ;
output	wire			start_data_control;
output	wire        stop_data_control; 
output	wire			i2c_clk;        
output	wire			start_clk_control;
output	wire        stop_clk_control; 
output	reg			i2c_master_out;                    
output	reg			shift_out;	
output	reg	[7:0]	read_data_tmp;	
output	wire			i2c_slave_out;
output	wire			i2c_read_done;
output	reg	[7:0]	i2c_read_data;
output	reg	[7:0]	read_length;
output	wire			i2c_read_data_rdy;
output 	reg	[1:0] test_cnt;
output 	wire 			test_start ;
output 	wire			slave_addr1_shift_en;
output 	wire			slave_addr2_shift_en;
output 	wire			word_addr1_shift_en;
output 	wire			data_shift_en;
output 	wire			wr_data_en;
output 	reg	[2:0] i2c_stop_ctrl_cnt;
input           test_i;
parameter	state_idle	 			= 6'd0;
parameter	state_start1 			= 6'd1;
parameter	state_slave_addr1	 	= 6'd2;
parameter	state_slave_addr_ack1 	= 6'd3;
parameter	state_word_addr1	 	= 6'd4;
parameter	state_word_addr_ack  	= 6'd5;
parameter	state_start2 			= 6'd6;
parameter	state_slave_addr2		= 6'd7;
parameter	state_slave_addr_ack2 	= 6'd8;
parameter	state_data1	 			= 6'd9; 
parameter	state_non_ack		 	= 6'd10;
parameter	state_master_ack		= 6'd11;
parameter	state_stop			 	= 6'd12;                  
parameter	state_ack_error		 	= 6'd13;  
parameter	state_wr_data			= 6'd14;
parameter   state_wr_ack            = 6'd15;
wire	[7:0]	slave_addr_1, slave_addr_2;
wire			shift_enable ;
reg	[1:0]	test_start_d;
assign process_en = (i2c_state > 0) ? 1'b1 : 1'b0;
assign falling_edge = ((i2c_clk_cnt == 0)&&(process_en)) ? 1'b1 : 1'b0;
assign rising_edge = ((i2c_clk_cnt == 3)&&(process_en)) ? 1'b1 : 1'b0;
assign start_data_control 	= (((i2c_state == state_start1)||(i2c_state == state_start2))&&(i2c_clk_cnt >1)) ? 1'b1: 1'b0;
assign stop_data_control 	= ((i2c_state == state_stop)&&(i2c_stop_ctrl_cnt >1)) ? 1'b1: 1'b0;  
assign start_clk_control 	= ((i2c_state == state_start1)&&(i2c_clk_cnt == 1)) ? 1'b0: 1'b1;
assign stop_clk_control 	= ((i2c_state == state_stop)&&(i2c_clk_cnt ==2)) ? 1'b0: 1'b1;  
assign i2c_clk = (i2c_state == state_start1) ? start_clk_control :
				 (i2c_state == state_stop)  ? stop_clk_control :
				  process_en ? i2c_clk_src : 1'b1;
assign slave_addr_1 = {iSlave_addr,1'b0}; 
assign slave_addr_2 = {iSlave_addr,1'b1}; 
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			test_cnt <= 0;
		else
			test_cnt <= test_cnt + 1;
	end
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			i2c_clk_cnt <= 0;
		else
			i2c_clk_cnt <= i2c_clk_cnt + 1'b1;
	end
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			i2c_clk_src <= 0;
		else if (i2c_clk_cnt>1)
			i2c_clk_src <= 1;
		else
			i2c_clk_src <= 0;	
	end
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			system_clk <= 0;
		else if ((i2c_clk_cnt>0)&&(i2c_clk_cnt<3))
			system_clk <= 1;
		else
			system_clk <= 0;
	end			
wire dft_system_clk;
assign dft_system_clk = test_i ? iCLK : system_clk;
always@(posedge dft_system_clk or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				i2c_state <= 0;
			end
		else
			begin
				case(i2c_state)
					state_idle:
						begin
							if (iStart)
								i2c_state <= state_start1;
							else
								i2c_state <= i2c_state;	
						end
					state_start1:  
						begin
							i2c_state <= state_slave_addr1;
						end
					state_slave_addr1: 
						begin
							if (i2c_bit_cnt == 7)
								i2c_state <= state_slave_addr_ack1;
							else	
								i2c_state <= state_slave_addr1;
						end
					state_slave_addr_ack1: 
						begin
							i2c_state <= state_word_addr1;
						end
					state_word_addr1:  
						begin
							if (i2c_bit_cnt == 7)
								i2c_state <= state_word_addr_ack;
							else	
								i2c_state <= state_word_addr1;
						end	
					state_word_addr_ack:
						begin	
							if (wr_cmd)
								i2c_state <= state_wr_data;
							else	
								i2c_state <= state_start2;
						end
					state_start2:
						begin	
							i2c_state <= state_slave_addr2;
						end
					state_slave_addr2:
						begin
							if (i2c_bit_cnt == 7)
								i2c_state <= state_slave_addr_ack2;
							else	
								i2c_state <= state_slave_addr2;
						end	
					state_slave_addr_ack2:
						begin
							i2c_state <= state_data1;
						end
					state_data1:
						begin
							if (i2c_bit_cnt == 7)
								begin
									if (iSequential_read)
										begin
											if (read_length == 0)
												i2c_state <= state_non_ack;
											else	
												i2c_state <= state_master_ack;
										end		
									else
										i2c_state <= state_non_ack;
								end		
							else	
								i2c_state <= state_data1;
						end
					state_master_ack:	
						begin
							i2c_state <= state_data1;
						end
					state_non_ack:
						begin
							i2c_state <= state_stop;
						end
					state_wr_data:
						begin
							if (i2c_bit_cnt == 7)
								i2c_state <= state_wr_ack;
							else	
								i2c_state <= state_wr_data;
						end				
					state_wr_ack:
						begin
							i2c_state <= state_stop;
						end						
					state_stop:
						begin
							i2c_state <= state_idle;	
						end
					default : i2c_state <= state_idle;
				endcase
			end
	end		
assign  shift_enable  = 	(i2c_state == state_slave_addr1) ||
							(i2c_state == state_word_addr1)  ||		
							(i2c_state == state_slave_addr2) ||	
							(i2c_state == state_wr_data) 	 ||	
							(i2c_state == state_data1) ;
assign slave_addr1_shift_en = (i2c_state == state_slave_addr1) 	? 1'b1 : 1'b0;
assign word_addr1_shift_en 	= (i2c_state == state_word_addr1) 	? 1'b1 : 1'b0;
assign slave_addr2_shift_en = (i2c_state == state_slave_addr2) 	? 1'b1 : 1'b0;
assign data_shift_en 		= (i2c_state == state_data1) 		? 1'b1 : 1'b0;
assign wr_data_en    		= (i2c_state == state_wr_data) 		? 1'b1 : 1'b0;
always@(posedge dft_system_clk or negedge iRST_n)
	begin
		if (!iRST_n)
			i2c_bit_cnt <=0;
		else if (i2c_bit_cnt == 7)
			i2c_bit_cnt <=0;
		else if (
				  (i2c_state == state_slave_addr1) ||
				  (i2c_state == state_word_addr1)  ||		
				  (i2c_state == state_slave_addr2) ||	
				  (i2c_state == state_wr_data)     ||				  
			      (i2c_state == state_data1)   	   
				)					
			i2c_bit_cnt <= i2c_bit_cnt + 1;
	end
always@(i2c_bit_cnt or slave_addr_1 or slave_addr_2 or iWord_addr or slave_addr1_shift_en or
		slave_addr2_shift_en or word_addr1_shift_en)
	begin
		if (slave_addr1_shift_en)
			shift_out = slave_addr_1[7-i2c_bit_cnt];
		else if (word_addr1_shift_en)
			shift_out = iWord_addr[7-i2c_bit_cnt];
		else if (slave_addr2_shift_en)
		    shift_out = slave_addr_2[7-i2c_bit_cnt];
		else if (wr_data_en)
		    shift_out = wr_data[7-i2c_bit_cnt];		    
		else
			shift_out = 1'b0;	
	end
always@(i2c_state)
	begin
		if (
			(i2c_state == state_start1)||
			(i2c_state == state_start2)
			)	
			i2c_master_out = start_data_control;
		else if (
				(i2c_state == state_slave_addr1)||
				(i2c_state == state_word_addr1) ||
				(i2c_state == state_wr_data)    ||				
				(i2c_state == state_slave_addr2)				
				)
			i2c_master_out = shift_out;
		else if (i2c_state == state_stop)
			i2c_master_out =  stop_data_control;
		else if (		
				(i2c_state == state_slave_addr_ack1)||
				(i2c_state == state_word_addr_ack)  ||
				(i2c_state == state_slave_addr_ack2)||
				(i2c_state == state_wr_ack)||				
				(i2c_state == state_data1)				
				)
			i2c_master_out = 1'b1;
		else if (i2c_state == state_stop)
			i2c_master_out =  stop_data_control;
		else if (i2c_state == state_master_ack)
			i2c_master_out = 1'b0;	
		else if (i2c_state == state_non_ack)	
			i2c_master_out = 1'b1;
		else
			i2c_master_out = 1'b1;
	end			
assign i2c_slave_out = ( data_shift_en ||
						(i2c_state == state_slave_addr_ack1)||
						(i2c_state == state_word_addr_ack)  ||
						(i2c_state == state_wr_ack)||
						(i2c_state == state_slave_addr_ack2)					
						) ? 1'b1 : 1'b0;
assign	i2c_data =  i2c_slave_out ? 1'bz : i2c_master_out ;
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			read_data_tmp <= 0;
		else if ((i2c_state == state_data1)&&(falling_edge))
			read_data_tmp <= {read_data_tmp[6:0],i2c_data};
	end		 	
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			i2c_read_data <= 0;
		else if ((i2c_state == state_non_ack)||(i2c_state == state_master_ack))
			i2c_read_data <= read_data_tmp;
	end	
assign i2c_read_done = (i2c_state == state_stop) ? 1'b1 : 1'b0;
assign i2c_read_data_rdy = ((i2c_state == state_non_ack)||(i2c_state == state_master_ack)) ? 1'b1 : 1'b0;
always@(posedge i2c_clk_src or negedge iRST_n)
	begin 
		if (!iRST_n)
			read_length <= 0;
		else if (i2c_state == state_start1)	
			read_length <= iRead_length;
		else if ((i2c_state == state_data1)&&(i2c_bit_cnt == 1))
			begin
				if (read_length == 0)
					read_length <= 0;	
				else	
					read_length <= read_length - 1;
			end
	end			
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			i2c_stop_ctrl_cnt <=0;
		else if (i2c_state == state_stop)
			i2c_stop_ctrl_cnt <=i2c_stop_ctrl_cnt + 1;	
		else
			i2c_stop_ctrl_cnt <= 0;
	end		
assign oSYSTEM_STATE = (i2c_state == 0) ? 1'b0 : 1'b1; 
assign oCONFIG_DONE = ((i2c_state == state_stop)) ? 1'b1 : 1'b0;	
endmodule