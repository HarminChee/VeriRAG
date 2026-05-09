module latency_aware_read_master (
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
	master_waitrequest
);
	parameter DATAWIDTH = 32;
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
	reg control_fixed_location_d1;
	wire fifo_empty;
	reg [ADDRESSWIDTH-1:0] address;
	reg [ADDRESSWIDTH-1:0] length;
	reg [FIFODEPTH_LOG2-1:0] reads_pending;
	wire increment_address;
	wire too_many_pending_reads;
	reg too_many_pending_reads_d1;
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
	assign master_address = address;
	assign master_byteenable = -1;  
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
				address <= address + BYTEENABLEWIDTH;  
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
				length <= length - BYTEENABLEWIDTH;  
			end
		end
	end	
	assign too_many_pending_reads = (fifo_used + reads_pending) >= (FIFODEPTH - 4);
	assign master_read = (length != 0) & (too_many_pending_reads_d1 == 0);
	assign increment_address = (length != 0) & (too_many_pending_reads_d1 == 0) & (master_waitrequest == 0);
	assign control_done = (reads_pending == 0) & (length == 0);  
	assign control_early_done = (length == 0);  
	always @ (posedge clk)
	begin
		if (reset == 1)
		begin
			too_many_pending_reads_d1 <= 0;
		end
		else
		begin
			too_many_pending_reads_d1 <= too_many_pending_reads;
		end
	end
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
					reads_pending <= reads_pending + 1;
				end
				else
				begin
					reads_pending <= reads_pending;  
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
	defparam the_master_to_user_fifo.lpm_showahead = "ON";
	defparam the_master_to_user_fifo.use_eab = (FIFOUSEMEMORY == 1)? "ON" : "OFF";
	defparam the_master_to_user_fifo.add_ram_output_register = "OFF";
	defparam the_master_to_user_fifo.underflow_checking = "OFF";
	defparam the_master_to_user_fifo.overflow_checking = "OFF";
endmodule
