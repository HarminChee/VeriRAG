module kvs_vs_RegexTop_FastClockInside 
(
	input clk,
	input fast_clk,
	input rst,
	input fast_rst,
	input [511:0] input_data,
	input 		  input_valid,
	input 		  input_last,
	output		  input_ready,
	input [511:0] config_data,
	input 		  config_valid,
	output  	  config_ready,
	output 		  found_loc,
	output 		  found_valid,
	input		  found_ready
);
parameter REGEX_COUNT_BITS = 4;
parameter MAX_REGEX_ENGINES = 16;
wire [511:0] regex_input_data [MAX_REGEX_ENGINES-1:0];
reg [511:0] regex_input_prebuf [MAX_REGEX_ENGINES-1:0];
wire [MAX_REGEX_ENGINES-1:0] regex_input_hasdata;
wire [MAX_REGEX_ENGINES-1:0] regex_input_almfull;
wire [MAX_REGEX_ENGINES-1:0] regex_input_notfull;
wire [MAX_REGEX_ENGINES-1:0] regex_input_ready;
reg [MAX_REGEX_ENGINES-1:0] regex_input_enable;	 
reg [MAX_REGEX_ENGINES-1:0] regex_input_type;	
reg softReset; 
reg softResetInt; 
wire [MAX_REGEX_ENGINES*16-1:0] regex_output_index ;
wire [MAX_REGEX_ENGINES-1:0] regex_output_match;
wire [MAX_REGEX_ENGINES-1:0] regex_output_valid;
wire [MAX_REGEX_ENGINES-1:0] outfifo_valid;
wire [MAX_REGEX_ENGINES-1:0] outfifo_ready;
wire [MAX_REGEX_ENGINES-1:0]  outfifo_data;
reg [REGEX_COUNT_BITS-1:0] outfifo_pos;
reg [REGEX_COUNT_BITS-1:0] current_regex_engine;
reg [REGEX_COUNT_BITS-1:0] config_regex_engine;
reg [REGEX_COUNT_BITS-1:0] output_regex_engine;
reg config_wait;
reg regex_inputbuffer_ok;
reg regex_inputbuffer_pre;
reg [7:0] config_ahead;
reg in_scan_mode;
assign input_ready = (regex_inputbuffer_ok); 
assign config_ready = in_scan_mode==0 ? (~regex_input_enable[config_regex_engine] && (regex_inputbuffer_ok) && (config_ahead<MAX_REGEX_ENGINES-1)) : 0; 
reg rstBuf;
integer x;
always @(posedge clk) begin
	rstBuf <= rst;	
	if (rst) begin
		current_regex_engine <= 0;
		config_regex_engine <= 0;
		regex_input_enable <= 0;		
		output_regex_engine <= 0;
		config_wait <= 0;
		regex_inputbuffer_ok <= 0;
		regex_inputbuffer_pre <= 0;
		config_ahead <= 0;
		in_scan_mode <= 0;		
	end
	else begin
		regex_input_enable <= 0;			
		regex_inputbuffer_pre <= (regex_input_notfull == {MAX_REGEX_ENGINES{1'b1}} ? 1 : 0) && (regex_input_almfull == 0 ? 1 : 0);
		regex_inputbuffer_ok <= regex_inputbuffer_pre;
		if (config_ready==1 && config_valid==1) begin
			regex_input_prebuf[config_regex_engine] <= config_data;
			regex_input_enable[config_regex_engine] <= 1;
			regex_input_type[config_regex_engine] <= 1;
			config_ahead <= config_ahead+1;
			if (config_data[511]==1) begin
			  in_scan_mode <= 1;
			end
			if (config_regex_engine==MAX_REGEX_ENGINES-1) begin
				config_regex_engine <= 0;
			end else begin
				config_regex_engine <= config_regex_engine +1;			
			end
			if (config_data[511]==1) begin
				for (x=0; x<MAX_REGEX_ENGINES; x=x+1) begin
				    regex_input_prebuf[x] <= config_data;
				end
				regex_input_enable <= {MAX_REGEX_ENGINES{1'b1}};
				regex_input_type <= {MAX_REGEX_ENGINES{1'b1}};
			end
		end 
		if (input_ready==1 && input_valid==1) begin
			if (config_ready==1 && config_valid==1 && input_last==1) begin
				config_ahead <= config_ahead;
			end else if (input_last==1) begin
				config_ahead <= config_ahead-1;
			end
			regex_input_prebuf[current_regex_engine] <= input_data;
			regex_input_enable[current_regex_engine] <= 1;
			regex_input_type[current_regex_engine] <= 0;
			if (input_last==1) begin
				if (current_regex_engine==MAX_REGEX_ENGINES-1) begin
					current_regex_engine <= 0;
				end else begin
					current_regex_engine <= current_regex_engine +1;
				end
			end
		end
		if (found_valid==1 && found_ready==1) begin
			if (output_regex_engine==MAX_REGEX_ENGINES-1) begin
				output_regex_engine <= 0;
			end else begin
				output_regex_engine <= output_regex_engine+1;
			end
		end
	end
end
assign found_valid = outfifo_valid[output_regex_engine];
assign found_loc = outfifo_data[output_regex_engine];
reg rstBufForFast;
always @(posedge fast_clk) begin
	rstBufForFast <= rstBuf;
	softResetInt <= rstBufForFast;
	softReset <= softResetInt;
end
genvar X;
generate  
    for (X=0; X < MAX_REGEX_ENGINES; X=X+1)  
	begin: generateloop		
			fifo_generator_512_shallow_async 
			fifo_values (
			    .s_aclk(clk),
    			.m_aclk(fast_clk),
    			.s_aresetn(~rst),
			    .s_axis_tdata(regex_input_prebuf[X]),
			    .s_axis_tvalid(regex_input_enable[X]),
			    .s_axis_tready(regex_input_notfull[X]),
			    .axis_prog_full(regex_input_almfull[X]),
			    .m_axis_tdata(regex_input_data[X][511:0]),
			    .m_axis_tvalid(regex_input_hasdata[X]),
			    .m_axis_tready(regex_input_ready[X])
			);
		rem_top_ff rem_top_instance (
			    .clk(fast_clk),
	  			.rst(fast_rst),   			
	  			.softRst(softReset),
	    		.input_valid(regex_input_hasdata[X]),
	    		.input_data(regex_input_data[X][511:0]),
	    		.input_ready(regex_input_ready[X]),
	    		.output_valid(regex_output_valid[X]),
	    		.output_match(regex_output_match[X]),
	    		.output_index(regex_output_index[(X+1)*16-1:X*16])
			);
				fifo_generator_1byte_async 
				 fifo_decision_from_regex (
				    .s_aclk(fast_clk),
    				.m_aclk(clk),
    				.s_aresetn(~fast_rst),
				    .s_axis_tdata(regex_output_match[X]),
				    .s_axis_tvalid(regex_output_valid[X]),
				    .s_axis_tready(),
				    .m_axis_tdata(outfifo_data[X]),
				    .m_axis_tvalid(outfifo_valid[X]),
				    .m_axis_tready(outfifo_ready[X])
				);
	 	assign outfifo_ready[X] = output_regex_engine==X ? found_ready : 0;
	end  
	endgenerate  
endmodule
