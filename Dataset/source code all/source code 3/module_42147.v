module nukv_Predicate_Eval #(
	parameter MEMORY_WIDTH = 512,
    parameter META_WIDTH = 96,
	parameter GENERATE_COMMANDS = 1,
	parameter SUPPORT_SCANS = 0
	)
    (
	input wire         clk,
	input wire         rst,
	input wire [META_WIDTH+MEMORY_WIDTH-1:0] pred_data,
	input wire pred_valid,
	input wire pred_scan,
	output reg pred_ready,
	input  wire [MEMORY_WIDTH-1:0] value_data,
	input  wire         value_valid,
	input  wire 		value_last,
	input  wire 		value_drop,
	output wire         value_ready,
	output wire [MEMORY_WIDTH-1:0] output_data,
	output wire         output_valid,
	output wire			output_last,
	output wire			output_drop,
	input  wire         output_ready,	
	output reg 	cmd_valid,
	output reg[15:0] cmd_length,
    output reg[META_WIDTH-1:0] cmd_meta,
	input  wire		cmd_ready, 
	input scan_on_outside,
	output reg error_input
);
    localparam[2:0] 
    	ST_IDLE = 0,
    	ST_READING = 1,
    	ST_LAST = 2;
    reg[2:0] state;
    wire[16+31:0] pred_data_config;
    wire[META_WIDTH-1: 0] pred_data_meta;
    assign pred_data_config = pred_data[META_WIDTH +: 48];
    assign pred_data_meta = pred_data[0 +: META_WIDTH];
    reg[11:0] find_offset;
    reg[3:0]  find_function;
    reg[31:0] find_value;
    reg out_valid;
    wire out_ready;
    reg[MEMORY_WIDTH-1:0] out_data;
    reg out_drop;
    reg out_last;
    wire out_b_valid;
    wire out_b_ready;
    wire[MEMORY_WIDTH-1:0] out_b_data;
    wire out_b_drop;
    wire out_b_last;
    reg[META_WIDTH-1: 0] meta_word;
    reg drop;
    reg[15:0] curr_offset;
    reg[15:0] total_length;
    reg[15:0] curr_offset_p128;
    reg scanning;
    reg entered_via_scan;
    wire enter_ifs;
    reg readInValue;
    wire stateBasedReady = (state==ST_IDLE) ? (pred_valid | scanning) : readInValue;
    assign value_ready = (stateBasedReady & out_ready);
    reg[31:0] slice[0:61];
    reg[MEMORY_WIDTH-1:0] slice_full;
    reg slice_valid;
    reg slice_drop;
    reg slice_last;
    integer xx;
    always @(posedge clk) begin
    	if (rst) begin
    		state <= ST_IDLE;
    		out_valid <= 0;
    		pred_ready <= 0;
    		scanning <= 0;    	
    		if (GENERATE_COMMANDS==1) begin
    			cmd_valid <= 0;
    		end
    		entered_via_scan <= 0;
    		error_input <= 0;
            readInValue <= 0;
            slice_valid <= 0;
    	end
    	else begin
    	    error_input <= 0;
    		if (GENERATE_COMMANDS==1 && cmd_valid==1 && cmd_ready==1) begin
    			cmd_valid <= 0;
    		end
    		if (out_valid==1 && out_ready==1) begin
    			out_valid <= 0;
                out_last <= 0;
                out_drop <= 0;
    		end
    		pred_ready <= 0;                        
            if (slice_valid==1 && out_ready==1) begin
                slice_valid <= 0;
            end
            if (value_valid==1 && value_ready==1) begin
                for (xx=0; xx<61; xx=xx+1) begin
                    slice[xx][31:0] <= value_data[xx*8 +: 32];
                end
                slice_full <= value_data;
                slice_drop <= value_drop;
                slice_valid <= 1;
                slice_last <= value_last;
            end 
    		case (state)
    			ST_IDLE: begin
    				if (pred_valid==1 && value_valid==1 && out_ready==1 && (SUPPORT_SCANS==0 || scan_on_outside==0 || (SUPPORT_SCANS==1 && pred_scan==1))) begin
    					scanning <= SUPPORT_SCANS==1 ? pred_scan : 0;
    					entered_via_scan <= pred_scan;
    					pred_ready <= 1;
    					find_offset <= pred_data_config[11:0];
    					find_function <= pred_data_config[15:12];
    					find_value <= pred_data_config[16 +: 32];
                        meta_word <= pred_data_meta;
    					curr_offset <= 0;
                        curr_offset_p128 <= 128;
    					total_length <= value_data[15:0];    					
    					state <= ST_READING;
    					drop <= 0;
                        out_drop <= 0;
                        readInValue <= 1;
    					if (value_data[15:0] <= 64) begin
                            state <= ST_LAST;                                
                            if (value_valid==1 && value_ready==1) begin
                               readInValue <= 0;
                            end
    					end
    				end else if (SUPPORT_SCANS==1 && scanning==1 && value_valid==1 && out_ready==1) begin
    					entered_via_scan <= 1;	
    					curr_offset <= 0;
                        curr_offset_p128 <= 128;
    					total_length <= value_data[15:0];    					
    					state <= ST_READING;
    					drop <= 0;
                        out_drop <= 0;
                        readInValue <= 1;
    					if (value_data[15:0] <= 64) begin
    						if (value_data>0) begin
                                state <= ST_LAST;                               
                            end else begin
                                state <= ST_IDLE;
                            end
                            if (value_valid==1 && value_ready==1) begin
                                readInValue <= 0;
                            end
    					end
    				end else if (SUPPORT_SCANS==1 && pred_valid==1 && pred_scan==1 && pred_ready==0) begin
                        scanning <= 1;   
                        pred_ready <= 1;      
                        find_offset <= pred_data_config[11:0];
                        find_function <= pred_data_config[15:12];
                        find_value <= pred_data_config[16 +: 32];
                        meta_word <= pred_data_meta;                          
                    end
    			end
    			ST_READING: begin
    				if (slice_valid==1 && out_ready==1) begin
    					curr_offset <= curr_offset+64;
                        curr_offset_p128 <= curr_offset+64+128;
    					if (curr_offset_p128>=total_length) begin
    						state <= ST_LAST;    						
                            if (value_valid==1 && value_ready==1) begin
                                readInValue <= 0;
                            end
    					end else begin
    						state <= ST_READING;
    					end
    					if (find_offset!=0 && find_offset<curr_offset+64 && find_offset>=curr_offset) begin    					
    						drop <= 0;
    						case (find_function)
    							4'b0000 : 
    								if (slice[find_offset]!=find_value) begin
    									drop <= 1;
    								end 
    							4'b0001 : 
    								if (slice[find_offset]>find_value) begin
    									drop <= 1;
    								end
    							4'b0010 : 
    								if (slice[find_offset]<find_value) begin
    									drop <= 1;
    								end    								
    							4'b0011 : 
    								if (slice[find_offset]==find_value) begin
    									drop <= 1;
    								end    								
    						endcase
    					end
    					out_valid <= 1;
    					out_drop <= 0;
    					out_last <= 0;
    					out_data <= slice_full;
    				end
    			end
    			ST_LAST: begin
                    if (value_valid==1 && readInValue==0) begin
                        readInValue <= 1;    
                    end else begin
                        readInValue <= 0;
                    end
                    if (value_valid==1 && value_ready==1) begin
                        readInValue <= 0;
                    end
    				if (slice_valid==1 && out_ready==1) begin
	    				out_valid <= 1;
	    				out_drop <= slice_drop | drop;
	    				out_last <= 1;
	    				out_data <= slice_full;
	    				if (GENERATE_COMMANDS==1 && scanning==1 && entered_via_scan==1) begin
	    					cmd_valid <= 1;
	    					cmd_length <= (total_length+7)/8;
                            cmd_meta <= meta_word;
	    					if (total_length==0 || total_length>1024) begin
	    					  error_input <= 1;
	    					  cmd_length <= 4;
                              out_drop <= 1;
	    					end
	    				end
	    				if (find_offset!=0 && find_offset<curr_offset+64 && find_offset>=curr_offset) begin
	    						case (find_function)
	    							4'b0000 : 
	    								if (slice[find_offset]!=find_value) begin
	    									out_drop <= 1;
	    								end
	    							4'b0001 : 
	    								if (slice[find_offset]>find_value) begin
	    									out_drop <= 1;
	    								end
	    							4'b0010 : 
	    								if (slice[find_offset]<find_value) begin
	    									out_drop <= 1;
	    								end    								
	    							4'b0011 : 
	    								if (slice[find_offset]==find_value) begin
	    									out_drop <= 1;
	    								end    								
	    						endcase
	   					end
	   					state <= ST_IDLE;
                        readInValue <= 0;
	   					entered_via_scan <= 0;
    				end
    			end
    		endcase    		
    	end
    end
	kvs_LatchedRelay #(
		.WIDTH(MEMORY_WIDTH+2)
	) relayreg (
	    .clk(clk),
	    .rst(rst),
	    .in_valid(out_valid),
	    .in_ready(out_ready),
	    .in_data({out_drop, out_last, out_data}),
	    .out_valid(output_valid),
	    .out_ready(output_ready),
	    .out_data({output_drop, output_last, output_data})
	);    
endmodule
