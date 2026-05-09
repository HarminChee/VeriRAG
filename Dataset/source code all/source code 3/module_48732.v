module alt_vipvfr131_prc_core
	(	
	clock,
	reset,
	stall,
	ena,
	read,
	data,
	discard_remaining_data_of_read_word,
	cmd_length_of_burst,
	cmd,
	cmd_addr,
	ready_out,
	valid_out,
	data_out,
	sop_out,
	eop_out,
	enable,
	clear_enable,
	stopped,
	complete,	
	packet_addr,
	packet_type,
	packet_samples,
	packet_words
	);
	parameter BITS_PER_SYMBOL = 8;
	parameter SYMBOLS_PER_BEAT = 3;
	parameter BURST_LENGTH_REQUIREDWIDTH = 7;
	parameter PACKET_SAMPLES_REQUIREDWIDTH = 32;
	localparam ADDR_WIDTH = 32; 
	localparam READ_LATENCY = 3;
	input		clock;
	input		reset;
	output 	stall;
	input		ena;
	output reg	read;
	input		[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] data;
	output 	reg discard_remaining_data_of_read_word;
	output  reg cmd;		
	output  reg [BURST_LENGTH_REQUIREDWIDTH-1:0] cmd_length_of_burst;
	output	reg [ADDR_WIDTH-1:0] cmd_addr;
	input		ready_out;		
	output	valid_out;
	output 	[BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] data_out;
	output	sop_out;				
	output  eop_out;
	input		enable;		
	output	reg clear_enable; 
	output	stopped;	
	output  reg complete;	
	input		[ADDR_WIDTH-1:0] packet_addr;
	input		[3:0] packet_type;
	input		[PACKET_SAMPLES_REQUIREDWIDTH-1:0] packet_samples;
	input		[BURST_LENGTH_REQUIREDWIDTH-1:0] packet_words;
reg [READ_LATENCY-1:0] input_valid_shift_reg;
reg [BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1 : 0] data_out_d1;
reg sop_out_d1;
reg eop_out_d1;
reg [BITS_PER_SYMBOL * SYMBOLS_PER_BEAT - 1:0] pre_data_out;
reg internal_output_is_valid;
reg pre_sop_out;
reg pre_eop_out;
reg [PACKET_SAMPLES_REQUIREDWIDTH-1:0] packet_samples_reg;
reg [PACKET_SAMPLES_REQUIREDWIDTH-1:0] reads_issued;
wire reads_complete;
assign reads_complete = (reads_issued == packet_samples_reg-1);
localparam IDLE = 0;
localparam WAITING = 1;
localparam RUNNING = 2;
localparam ENDING = 3;
reg [1:0] state;
reg status;
integer i;
always @(posedge clock or posedge reset)
	if (reset) begin		
		state <= IDLE;
		status <= 1'b0;
		clear_enable <= 1'b1;
		cmd <= 1'b0;
		internal_output_is_valid <= 1'b0;
		pre_sop_out <= 1'b0;
		pre_eop_out <= 1'b0;
		complete <= 1'b0;
		input_valid_shift_reg <= {READ_LATENCY{1'b0}};
		discard_remaining_data_of_read_word <= 1'b0;
		read <= 1'b0;
		reads_issued <= {PACKET_SAMPLES_REQUIREDWIDTH{1'b0}};
	end
	else begin
		reads_issued <= read & ena & ~reads_complete ? reads_issued + 1'b1 : reads_issued;
		if(ena) begin
			input_valid_shift_reg[READ_LATENCY-1] <= (read);
			for(i=0;i<READ_LATENCY-1;i=i+1) begin
				input_valid_shift_reg[i] <= input_valid_shift_reg[i+1];
			end
		end
		case (state)			
			IDLE :	begin
				reads_issued <= {PACKET_SAMPLES_REQUIREDWIDTH{1'b0}};
				if( ena & discard_remaining_data_of_read_word) begin
					discard_remaining_data_of_read_word <= 0;
				end
				clear_enable <= 1'b0;
				if (pre_eop_out & ena) begin
					pre_eop_out <= 1'b0;			
				end
				complete <= 1'b0;
				if (enable & !discard_remaining_data_of_read_word) begin	
					clear_enable <= 1'b1;
					status <= 1'b1;
					cmd <= 1'b1;
					cmd_addr <= packet_addr;
					cmd_length_of_burst <= packet_words;
					packet_samples_reg <= packet_samples;
					internal_output_is_valid <= 1'b1;
					pre_sop_out <= 1'b1;
					pre_data_out <= packet_type;
					state <= WAITING;
				end else begin
					status <= 1'b0;
					state <= IDLE;
					cmd <= 1'b0;
					internal_output_is_valid <= 1'b0;
					pre_sop_out <= 1'b0;
				end
			end
			WAITING : begin 
				clear_enable <= 1'b0;				
				if (cmd & ena) begin
					cmd <= 1'b0;			
				end
				if(ena) begin
					internal_output_is_valid <= 1'b0;
					pre_sop_out <= 1'b0;
					state <= RUNNING;
				end
			end
			RUNNING : begin
				if(ena) begin
					internal_output_is_valid <= input_valid_shift_reg[0];
				end
				if ((cmd & ena) | !cmd & !reads_complete) begin
					cmd <= 1'b0;
					read <= 1'b1;					
				end			
				if (reads_complete & ena) begin
					read <= 1'b0;
				end
				pre_data_out <= ena ? data : pre_data_out;
				if(input_valid_shift_reg==1 & reads_complete & ena) begin
					discard_remaining_data_of_read_word <= 1;
					pre_eop_out <= 1'b1;
					state <= ENDING;
				end else begin
					state <= RUNNING;
					pre_eop_out <= 1'b0;
				end
			end
			ENDING : begin 
				internal_output_is_valid <= 1'b1;
				if( ena & discard_remaining_data_of_read_word) begin
					discard_remaining_data_of_read_word <= 0;
				end
				if(ena) begin
					status <= 1'b0;
					complete <= 1'b1;
					pre_eop_out <= 1'b0;
					state <= IDLE;
					internal_output_is_valid <= 1'b0;
				end
			end
		endcase
	end			
assign stopped = ~status;
assign stall = !ready_out;
assign valid_out = internal_output_is_valid & ena;
assign data_out = valid_out ? pre_data_out : data_out_d1;
assign eop_out = valid_out ? pre_eop_out : eop_out_d1;
assign sop_out = valid_out ? pre_sop_out : sop_out_d1;
always @(posedge clock or posedge reset)
	if (reset) begin
		data_out_d1 <= {(BITS_PER_SYMBOL * SYMBOLS_PER_BEAT){1'b0}};
		sop_out_d1 <= 1'b0;
		eop_out_d1 <= 1'b0;
	end
	else begin
		data_out_d1 <= data_out;
		sop_out_d1 <= sop_out;
		eop_out_d1 <= eop_out;
	end
endmodule
