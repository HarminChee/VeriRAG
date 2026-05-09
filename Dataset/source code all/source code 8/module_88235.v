`timescale 1 ps / 1 ps
module intermediate_data_fifo (
	clock,
	data,
	rdreq,
	sclr,
	wrreq,
	empty,
	full,
	q,
	usedw);
	parameter DATA_WIDTH = 32;
	parameter NUM_WORDS = 1024;
	parameter LOG_NUM_WORDS = 10;
	input	  clock;
	input	[DATA_WIDTH-1:0]  data;
	input	  rdreq;
	input	  sclr;
	input	  wrreq;
	output	  empty;
	output	  full;
	output	[DATA_WIDTH-1:0]  q;
	output	[LOG_NUM_WORDS-1:0]  usedw;
	wire [LOG_NUM_WORDS-1:0] sub_wire0;
	wire  sub_wire1;
	wire [DATA_WIDTH-1:0] sub_wire2;
	wire  sub_wire3;
	wire [LOG_NUM_WORDS-1:0] usedw = sub_wire0[LOG_NUM_WORDS-1:0];
	wire  empty = sub_wire1;
	wire [DATA_WIDTH-1:0] q = sub_wire2[DATA_WIDTH-1:0];
	wire  full = sub_wire3;
	scfifo	scfifo_component (
				.rdreq (rdreq),
				.sclr (sclr),
				.clock (clock),
				.wrreq (wrreq),
				.data (data),
				.usedw (sub_wire0),
				.empty (sub_wire1),
				.q (sub_wire2),
				.full (sub_wire3)
				,
				.aclr (),
				.almost_empty (),
				.almost_full ()
				);
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.intended_device_family = "Cyclone II",
		scfifo_component.lpm_numwords = NUM_WORDS,
		scfifo_component.lpm_showahead = "ON",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = DATA_WIDTH,
		scfifo_component.lpm_widthu = LOG_NUM_WORDS,
		scfifo_component.overflow_checking = "OFF",
		scfifo_component.underflow_checking = "OFF",
		scfifo_component.use_eab = "ON";
endmodule
module barrier_fifo(
		clock,
		resetn,	
		pull,
		push,
		in_data,
		out_data,
		valid,
		fifo_ready,
		work_group_size);
    parameter DATA_WIDTH = 32;
    parameter MAXIMUM_WORK_GROUP_SIZE = 1024;
    input clock;
    input resetn;
    input pull;
    input push;
    input [DATA_WIDTH-1:0] in_data;
    output [DATA_WIDTH-1:0] out_data;
    output valid;
    output fifo_ready;
    input [15:0] work_group_size;
	function integer my_local_log;
	input [31:0] value;
		for (my_local_log=0; value>1; my_local_log=my_local_log+1)
			value = value>>1;
	endfunction		
	localparam LOG_MAX_WORK_GROUP_SIZE = my_local_log(MAXIMUM_WORK_GROUP_SIZE);
	wire empty_signal, full_signal;
	wire [LOG_MAX_WORK_GROUP_SIZE:0] used_words;
	wire reset;
	reg [LOG_MAX_WORK_GROUP_SIZE:0] elements_left_in_current_workgroup;
	intermediate_data_fifo my_local_fifo(
		.clock(clock),
		.data(in_data),
		.rdreq(pull & ~empty_signal & (|elements_left_in_current_workgroup)),
		.sclr(reset),
		.wrreq(push & ~full_signal),
		.empty(empty_signal),
		.full(full_signal),
		.q(out_data),
		.usedw(used_words[LOG_MAX_WORK_GROUP_SIZE-1:0]));
	defparam my_local_fifo.DATA_WIDTH = DATA_WIDTH;
	defparam my_local_fifo.NUM_WORDS = MAXIMUM_WORK_GROUP_SIZE;
	defparam my_local_fifo.LOG_NUM_WORDS = LOG_MAX_WORK_GROUP_SIZE;
	assign valid = ~empty_signal;
	assign used_words[LOG_MAX_WORK_GROUP_SIZE] = full_signal;
	always@(posedge clock)
	begin
		if (reset)
		begin
			elements_left_in_current_workgroup <= 'd0;
		end
		else
			if ((~(|elements_left_in_current_workgroup)) && (
				({1'b0, used_words} + {1'b0, push}) >= {1'b0, work_group_size}))
			begin
				elements_left_in_current_workgroup <= work_group_size[LOG_MAX_WORK_GROUP_SIZE:0];
			end
			if (pull & (|elements_left_in_current_workgroup))
			begin				
				if ((~(|elements_left_in_current_workgroup[LOG_MAX_WORK_GROUP_SIZE:1])) && (elements_left_in_current_workgroup[0] == 1'b1) && (
					({1'b0, used_words} + {1'b0, push} - {1'b0, pull}) >= {1'b0, work_group_size}))
				begin
					elements_left_in_current_workgroup <= work_group_size[LOG_MAX_WORK_GROUP_SIZE:0];
				end
				else		
				begin
					elements_left_in_current_workgroup <= elements_left_in_current_workgroup - 1'b1;
				end				
			end
	end
	assign fifo_ready = |elements_left_in_current_workgroup;
	reg [3:0] synched_reset_n;
	always@(posedge clock or negedge resetn)
	begin
		if (~resetn)
			synched_reset_n[0] <= 1'b0;
		else
			synched_reset_n[0] <= 1'b1;
	end 
	always@(posedge clock)
		synched_reset_n[3:1] <= synched_reset_n[2:0];
	assign reset = ~synched_reset_n[3];
endmodule
`timescale 1 ps / 1 ps
module intermediate_data_fifo (
	clock,
	data,
	rdreq,
	sclr,
	wrreq,
	empty,
	full,
	q,
	usedw);
	parameter DATA_WIDTH = 32;
	parameter NUM_WORDS = 1024;
	parameter LOG_NUM_WORDS = 10;
	input	  clock;
	input	[DATA_WIDTH-1:0]  data;
	input	  rdreq;
	input	  sclr;
	input	  wrreq;
	output	  empty;
	output	  full;
	output	[DATA_WIDTH-1:0]  q;
	output	[LOG_NUM_WORDS-1:0]  usedw;
	wire [LOG_NUM_WORDS-1:0] sub_wire0;
	wire  sub_wire1;
	wire [DATA_WIDTH-1:0] sub_wire2;
	wire  sub_wire3;
	wire [LOG_NUM_WORDS-1:0] usedw = sub_wire0[LOG_NUM_WORDS-1:0];
	wire  empty = sub_wire1;
	wire [DATA_WIDTH-1:0] q = sub_wire2[DATA_WIDTH-1:0];
	wire  full = sub_wire3;
	scfifo	scfifo_component (
				.rdreq (rdreq),
				.sclr (sclr),
				.clock (clock),
				.wrreq (wrreq),
				.data (data),
				.usedw (sub_wire0),
				.empty (sub_wire1),
				.q (sub_wire2),
				.full (sub_wire3)
				,
				.aclr (),
				.almost_empty (),
				.almost_full ()
				);
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.intended_device_family = "Cyclone II",
		scfifo_component.lpm_numwords = NUM_WORDS,
		scfifo_component.lpm_showahead = "ON",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = DATA_WIDTH,
		scfifo_component.lpm_widthu = LOG_NUM_WORDS,
		scfifo_component.overflow_checking = "OFF",
		scfifo_component.underflow_checking = "OFF",
		scfifo_component.use_eab = "ON";
endmodule
