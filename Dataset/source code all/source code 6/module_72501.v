module write_master (
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
	input [ADDRESSWIDTH-1:0] control_write_base;
	input [ADDRESSWIDTH-1:0] control_write_length;
	input control_go;
	output wire control_done;
	input user_write_buffer;
	input [DATAWIDTH-1:0] user_buffer_data;
	output wire user_buffer_full;
	input master_waitrequest;
	output wire [ADDRESSWIDTH-1:0] master_address;
	output wire master_write;
	output wire [BYTEENABLEWIDTH-1:0] master_byteenable;
	output wire [DATAWIDTH-1:0] master_writedata;
	reg control_fixed_location_d1;
	reg [ADDRESSWIDTH-1:0] address;  
	reg [ADDRESSWIDTH-1:0] length;
	wire increment_address;  
	wire read_fifo;
    wire user_buffer_empty;
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
			if (control_go == 1)
			begin
				address <= control_write_base;
			end
			else if ((increment_address == 1) & (control_fixed_location_d1 == 0))
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
	assign master_address = address;
	assign master_byteenable = -1;  
	assign control_done = (length == 0);
	assign master_write = (user_buffer_empty == 0) & (control_done == 0);
	assign increment_address = (user_buffer_empty == 0) & (master_waitrequest == 0) & (control_done == 0);
	assign read_fifo = increment_address;
	scfifo the_user_to_master_fifo (
		.aclr (reset),
		.clock (clk),
		.data (user_buffer_data),
		.full (user_buffer_full),
		.empty (user_buffer_empty),
		.q (master_writedata),
		.rdreq (read_fifo),
		.wrreq (user_write_buffer)
	);
	defparam the_user_to_master_fifo.lpm_width = DATAWIDTH;
	defparam the_user_to_master_fifo.lpm_numwords = FIFODEPTH;
	defparam the_user_to_master_fifo.lpm_showahead = "ON";
	defparam the_user_to_master_fifo.use_eab = (FIFOUSEMEMORY == 1)? "ON" : "OFF";
	defparam the_user_to_master_fifo.add_ram_output_register = "OFF";
	defparam the_user_to_master_fifo.underflow_checking = "OFF";
	defparam the_user_to_master_fifo.overflow_checking = "OFF";
endmodule
