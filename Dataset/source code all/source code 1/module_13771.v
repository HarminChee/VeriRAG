module burst_read_master (
	clk,
	reset,
	control_fixed_location,
	control_read_base,
	control_read_length,
	control_go,
	control_done,
	control_early_done,
	user_read_buffer,
	user_buffer_data,
	user_data_available,
	master_address,
	master_read,
	master_byteenable,
	master_readdata,
	master_readdatavalid,
	master_burstcount,
	master_waitrequest
);
	parameter DATAWIDTH = 32;
	parameter MAXBURSTCOUNT = 4;
	parameter BURSTCOUNTWIDTH = 3;
	parameter BYTEENABLEWIDTH = 4;
	parameter ADDRESSWIDTH = 32;
	parameter FIFODEPTH = 32;
	parameter FIFODEPTH_LOG2 = 5;
	parameter FIFOUSEMEMORY = 1;  
	input clk;
	input reset;
	input control_fixed_location;
	input [ADDRESSWIDTH-1:0] control_read_base;
	input [ADDRESSWIDTH-1:0] control_read_length;
	input control_go;
	output wire control_done;
	output wire control_early_done;  
	input user_read_buffer;
	output wire [DATAWIDTH-1:0] user_buffer_data;
	output wire user_data_available;
	input master_waitrequest;
	input master_readdatavalid;
    input [DATAWIDTH-1:0] master_readdata;
	output wire [ADDRESSWIDTH-1:0] master_address;
	output wire master_read;
	output wire [BYTEENABLEWIDTH-1:0] master_byteenable;
	output wire [BURSTCOUNTWIDTH-1:0] master_burstcount;
	reg control_fixed_location_d1;
	wire fifo_empty;
	reg [ADDRESSWIDTH-1:0] address;
	reg [ADDRESSWIDTH-1:0] length;
	reg [FIFODEPTH_LOG2-1:0] reads_pending;
	wire increment_address;
	wire [BURSTCOUNTWIDTH-1:0] burst_count;
	wire [BURSTCOUNTWIDTH-1:0] first_short_burst_count;
	wire first_short_burst_enable;
	wire [BURSTCOUNTWIDTH-1:0] final_short_burst_count;
	wire final_short_burst_enable;
	wire [BURSTCOUNTWIDTH-1:0] burst_boundary_word_address;
	reg burst_begin;
	wire too_many_reads_pending;
	wire [FIFODEPTH_LOG2-1:0] fifo_used;
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
		begin
			control_fixed_location_d1 <= 0;
		end
		else
		begin
			if (control_go == 1)
			begin
				control_fixed_location_d1 <= control_fixed_location;
			end
		end
	end
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
		begin
			address <= 0;
		end
		else
		begin
			if(control_go == 1)
			begin
				address <= control_read_base;
			end
			else if((increment_address == 1) & (control_fixed_location_d1 == 0))
			begin
				address <= address + (burst_count * BYTEENABLEWIDTH);  
			end
		end
	end
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
		begin
			length <= 0;
		end
		else
		begin
			if(control_go == 1)
			begin
				length <= control_read_length;
			end
			else if(increment_address == 1)
			begin
				length <= length - (burst_count * BYTEENABLEWIDTH);  
			end
		end
	end	
	assign master_address = address;
	assign master_byteenable = -1;  
	assign master_burstcount = burst_count;
	assign control_done = (length == 0) & (reads_pending == 0);  
	assign control_early_done = (length == 0);  
	assign master_read = (too_many_reads_pending == 0) & (length != 0);
	assign burst_boundary_word_address = ((address / BYTEENABLEWIDTH) & (MAXBURSTCOUNT - 1));
	assign first_short_burst_enable = (burst_boundary_word_address != 0);
	assign final_short_burst_enable = (length < (MAXBURSTCOUNT * BYTEENABLEWIDTH));
	assign first_short_burst_count = ((burst_boundary_word_address & 1'b1) == 1'b1)? 1 :  
									  (((MAXBURSTCOUNT - burst_boundary_word_address) < (length / BYTEENABLEWIDTH))?
									  (MAXBURSTCOUNT - burst_boundary_word_address) : (length / BYTEENABLEWIDTH));
	assign final_short_burst_count = (length / BYTEENABLEWIDTH);
	assign burst_count = (first_short_burst_enable == 1)? first_short_burst_count :  
						 (final_short_burst_enable == 1)? final_short_burst_count : MAXBURSTCOUNT;
	assign increment_address = (too_many_reads_pending == 0) & (master_waitrequest == 0) & (length != 0);
	assign too_many_reads_pending = (reads_pending + fifo_used) >= (FIFODEPTH - MAXBURSTCOUNT - 4);  
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
		begin
			reads_pending <= 0;
		end
		else
		begin
			if(increment_address == 1)
			begin
				if(master_readdatavalid == 0)
				begin
					reads_pending <= reads_pending + burst_count;
				end
				else
				begin
					reads_pending <= reads_pending + burst_count - 1;  
				end			
			end
			else
			begin
				if(master_readdatavalid == 0)
				begin
					reads_pending <= reads_pending;  
				end
				else
				begin
					reads_pending <= reads_pending - 1;  
				end				
			end
		end
	end
	assign user_data_available = !fifo_empty;
	scfifo the_master_to_user_fifo (
		.aclr (reset),
		.clock (clk),
		.data (master_readdata),
		.empty (fifo_empty),
		.q (user_buffer_data),
		.rdreq (user_read_buffer),
		.usedw (fifo_used),
		.wrreq (master_readdatavalid)
	);
	defparam the_master_to_user_fifo.lpm_width = DATAWIDTH;
	defparam the_master_to_user_fifo.lpm_numwords = FIFODEPTH;
	defparam the_master_to_user_fifo.lpm_widthu = FIFODEPTH_LOG2; 
	defparam the_master_to_user_fifo.lpm_showahead = "ON";
	defparam the_master_to_user_fifo.use_eab = (FIFOUSEMEMORY == 1)? "ON" : "OFF";
	defparam the_master_to_user_fifo.add_ram_output_register = "OFF";
	defparam the_master_to_user_fifo.underflow_checking = "OFF";
	defparam the_master_to_user_fifo.overflow_checking = "OFF";
endmodule
