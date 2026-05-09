module burst_write_master (
	clk,
	reset,
	control_fixed_location,
	control_write_base,
	control_write_length,
	control_go,
	control_done,
	user_write_buffer,
	user_buffer_data,
	user_buffer_full,
	master_address,
	master_write,
	master_byteenable,
	master_writedata,
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
	input [ADDRESSWIDTH-1:0] control_write_base;
	input [ADDRESSWIDTH-1:0] control_write_length;
	input control_go;
	output wire control_done;
	input user_write_buffer;
	input [DATAWIDTH-1:0] user_buffer_data;
	output wire user_buffer_full;
	input master_waitrequest;
	output reg [ADDRESSWIDTH-1:0] master_address;
	output wire master_write;
	output wire [BYTEENABLEWIDTH-1:0] master_byteenable;
	output wire [DATAWIDTH-1:0] master_writedata;
	output reg [BURSTCOUNTWIDTH-1:0] master_burstcount;
	reg control_fixed_location_d1;
	reg [ADDRESSWIDTH-1:0] length;
	wire final_short_burst_enable;  
	wire final_short_burst_ready;  
	wire [BURSTCOUNTWIDTH-1:0] burst_boundary_word_address;  
	wire [BURSTCOUNTWIDTH-1:0] first_short_burst_count;
	wire [BURSTCOUNTWIDTH-1:0] final_short_burst_count;
	wire first_short_burst_enable;  
	wire first_short_burst_ready;  
	wire full_burst_ready;  
	wire increment_address;  
	wire burst_begin;  
	wire read_fifo;
	wire [FIFODEPTH_LOG2-1:0] fifo_used;  
	wire [BURSTCOUNTWIDTH-1:0] burst_count;  
	reg [BURSTCOUNTWIDTH-1:0] burst_counter;
	reg first_transfer;  
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
			first_transfer <= 0;
		end
		else
		begin
			if (control_go == 1)
			begin
				first_transfer <= 1;
			end
			else if (burst_begin == 1)
			begin
				first_transfer <= 0;
			end
		end
	end
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
		begin
			master_address <= 0;
		end
		else
		begin
			if (control_go == 1)
			begin
				master_address <= control_write_base;
			end
			else if ((first_transfer == 0) & (burst_begin == 1) & (control_fixed_location_d1 == 0))
			begin
				master_address <= master_address + (master_burstcount * BYTEENABLEWIDTH);  
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
			if (control_go == 1)
			begin
				length <= control_write_length;
			end
			else if (increment_address == 1)
			begin
				length <= length - BYTEENABLEWIDTH;  
			end
		end
	end
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
		begin
			master_burstcount <= 0;
		end
		else
		begin
			if (burst_begin == 1)
			begin
				master_burstcount <= burst_count;
			end
		end
	end
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
		begin
			burst_counter <= 0;
		end
		else
		begin
			if (control_go == 1)
			begin
				burst_counter <= 0;
			end
			else if (burst_begin == 1)
			begin
				burst_counter <= burst_count;
			end
			else if (increment_address == 1)  
			begin
				burst_counter <= burst_counter - 1;
			end
		end
	end
	assign burst_boundary_word_address = ((master_address / BYTEENABLEWIDTH) & (MAXBURSTCOUNT - 1));	
	assign first_short_burst_enable = (burst_boundary_word_address != 0) & (first_transfer == 1);
	assign first_short_burst_count = ((burst_boundary_word_address & 1'b1) == 1'b1)? 1 :  
									(((MAXBURSTCOUNT - burst_boundary_word_address) < (length / BYTEENABLEWIDTH))?
									(MAXBURSTCOUNT - burst_boundary_word_address) : final_short_burst_count);
	assign first_short_burst_ready = (fifo_used > first_short_burst_count) | ((fifo_used == first_short_burst_count) & (burst_counter == 0));
	assign final_short_burst_enable = (length < (MAXBURSTCOUNT * BYTEENABLEWIDTH));
	assign final_short_burst_count = (length/BYTEENABLEWIDTH);
	assign final_short_burst_ready = (fifo_used > final_short_burst_count) | ((fifo_used == final_short_burst_count) & (burst_counter == 0));  
	assign full_burst_ready = (fifo_used > MAXBURSTCOUNT) |	((fifo_used == MAXBURSTCOUNT) & (burst_counter == 0));  
	assign master_byteenable = -1;  
	assign control_done = (length == 0);
	assign master_write = (control_done == 0) & (burst_counter != 0);  
	assign burst_begin = (((first_short_burst_enable == 1) & (first_short_burst_ready == 1))
						| ((final_short_burst_enable == 1) & (final_short_burst_ready == 1))
						| (full_burst_ready == 1))
						& (control_done == 0)  
						& ((burst_counter == 0) | ((burst_counter == 1) & (master_waitrequest == 0) & (length > (MAXBURSTCOUNT * BYTEENABLEWIDTH))));  
	assign burst_count = (first_short_burst_enable == 1)? first_short_burst_count :  
						(final_short_burst_enable == 1)? final_short_burst_count : MAXBURSTCOUNT; 
	assign increment_address = (master_write == 1) & (master_waitrequest == 0);  
	assign read_fifo = increment_address;
	scfifo the_user_to_master_fifo (
		.aclr (reset),
		.usedw (fifo_used),
		.clock (clk),
		.data (user_buffer_data),
		.almost_full (user_buffer_full),
		.q (master_writedata),
		.rdreq (read_fifo),
		.wrreq (user_write_buffer)
	);
	defparam the_user_to_master_fifo.lpm_width = DATAWIDTH;
	defparam the_user_to_master_fifo.lpm_numwords = FIFODEPTH;
	defparam the_user_to_master_fifo.lpm_showahead = "ON";
	defparam the_user_to_master_fifo.almost_full_value = (FIFODEPTH - 2);
	defparam the_user_to_master_fifo.use_eab = (FIFOUSEMEMORY == 1)? "ON" : "OFF";
	defparam the_user_to_master_fifo.add_ram_output_register = "OFF";  
	defparam the_user_to_master_fifo.underflow_checking = "OFF";
	defparam the_user_to_master_fifo.overflow_checking = "OFF";
endmodule
