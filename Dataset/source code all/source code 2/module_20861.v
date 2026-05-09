module nukv_Decompress #(	
	parameter POINTER_BITS = 12,
    parameter WINDOW_BITS = 9,
	parameter LENGTH_BITS = 4
)
(
	input wire         clk,
	input wire         rst,
	input  wire [511:0] input_data,
	input  wire         input_valid,
	input  wire			input_last, 
	output reg         input_ready,
	output reg [511:0]  output_data,
	output reg     	  output_valid,
	output reg        output_last,
	input  wire       output_ready
);
	reg[7:0] window_bytes [0:2**WINDOW_BITS-1];
	reg[WINDOW_BITS-1:0] window_head;
    reg[WINDOW_BITS-1:0] window_head_wr;
	reg[WINDOW_BITS-1:0] window_read_addr;
	reg[7:0] window_read_data;
    reg[511:0] cur_data;
	reg[7:0] delay_data;
	reg		 delay_islit;
	reg		 delay_valid;
	reg		 delay_last;
    reg      delay_validD1;
	reg[9:0] cur_pos;
	reg cur_islast;
	reg waiting_first;
	reg waiting_data;
    wire[POINTER_BITS-1:0] headptr;
    wire[LENGTH_BITS-1:0] cntptr;
    reg[LENGTH_BITS-1:0] cntreg;
    reg[5:0] output_idx;
    reg[7:0] output_previously;
    genvar pi;
    for (pi=0; pi<POINTER_BITS; pi=pi+1) begin
        assign headptr[POINTER_BITS-1-pi] = cur_data[1+pi]; 
    end 
    genvar pc;
    for (pc=0; pc<LENGTH_BITS; pc=pc+1) begin
        assign cntptr[LENGTH_BITS-1-pc] = cur_data[13+pc]; 
    end 
    reg waiting_finish;
    integer x;
	always @(posedge clk) begin    	
		window_read_data <=  window_bytes[window_read_addr];
    end
    integer p, q;
    reg rst_buf;
    always @(posedge clk) begin
        rst_buf <= rst;
    	if (rst_buf) begin
    		delay_islit <= 1;
    		delay_valid <= 0;
    		delay_last <= 0;
    		output_valid <= 0;
    		cur_pos <= 0;
    		waiting_first <= 1;
    		waiting_data <= 1;
            waiting_finish <= 0;
            window_head <= 0;
    	end
    	else begin
            delay_valid <= 0;
    		input_ready <= 0;
            if (output_valid==1 && output_ready==1) begin
                output_valid <= 0;
                output_last <= 0;
            end
    		if (output_ready==1 && waiting_first==1 && input_valid==1 && waiting_finish==0) begin
                for (p=0; p<64; p=p+1) begin
                    for (q=0; q<8; q=q+1) begin
                        cur_data[p*8+q] <= input_data[p*8+7-q];
                    end
                end
    			cur_islast <= input_last;
    			waiting_data <= 0;
    			waiting_first <= 0;
    			cur_pos <= 0;
    			input_ready <= 1;
                cntreg <= 0;
                window_head <= 0;
                window_head_wr <=0;
                output_idx <= 0;
    		end
    		if (waiting_data==0 && cur_pos<=511-9) begin
    			if (cur_data[0]==0) begin
    				cur_data <= cur_data[511:9];    				
    				cur_pos <= cur_pos+9;
    				window_head <= window_head+1;
    				delay_valid <= 1;
    				delay_last <= 0;
    				delay_islit <= 1;
                    for (x=0; x<8; x=x+1) begin
    				    delay_data[7-x] <= cur_data[1+x];    				
                    end
                    if (cur_data[8:0]==0 && cur_islast==1 && cur_pos>16) begin
                        waiting_data <= 1;
                        waiting_first <= 1; 
                        waiting_finish <= 1;                       
                        delay_last <= 1;
                    end
                    if (cur_pos+9+9>512 && cur_islast==1) begin
                        delay_last <= 1;
                    end
    			end else begin
                    if (cntreg <= cntptr) begin
					    window_head <= window_head+1;
	    			    delay_valid <= 1;	    				    		
    				    delay_last <= 0;
    				    delay_islit <= 0;
    				    delay_data <= 0;
                        if (headptr>1) begin
                            if (cntreg==0) begin
        				        window_read_addr <= window_head - headptr;    
                            end else begin
                                window_read_addr <= window_read_addr+1;
                            end
                            if (cntreg==0) begin 
                                delay_valid <= 0;		
                                window_head <= window_head;
                            end
                        end else begin
                            delay_islit <= 1;
                            delay_data <= delay_data;
                        end
                        if (cur_pos+POINTER_BITS+LENGTH_BITS+1+9>512 && cur_islast==1) begin
                            delay_last <= 1;
                        end
                    end 
                    cntreg <= cntreg+1;
    				if (cntreg == cntptr || (headptr==1 && cntreg+1 == cntptr)) begin
	    				cur_data <= cur_data[511:POINTER_BITS+LENGTH_BITS+1];
    					cur_pos <= cur_pos+POINTER_BITS+LENGTH_BITS+1;
                        cntreg <= 0;
    				end
    			end
    		end else if (waiting_data==0) begin
    			if (cur_islast==1) begin
    				waiting_data <= 1;
    				waiting_first <= 1;
                    waiting_finish <= 1;
    			end else begin
    				waiting_data <= 1;
    			end
    			if (output_ready==1 && input_valid==1 && cur_islast==0) begin
    				for (p=0; p<64; p=p+1) begin
                        for (q=0; q<7; q=q+1) begin
                            cur_data[p*8+q] <= input_data[p*8+7-q];
                        end
                    end
    				cur_islast <= input_last;    				
    				waiting_data <= 0;
    				cur_pos <= 0;
    				input_ready <= 1;
    			end
    		end
    		output_last <= delay_last;
    		output_data[output_idx*8 +: 8] <= (delay_islit == 1) ? delay_data : window_read_data;
            output_previously <= (delay_islit == 1) ? delay_data : window_read_data;
            delay_validD1 <= delay_valid;
            if (delay_valid==1) begin
                output_idx <= output_idx+1;
                if (output_idx==63 || delay_last==1) begin
                    output_valid <= 1;
                end
                if (output_idx==0) begin
                    output_data[511:8] <= 0;
                end
            end else begin
                output_valid <= 0;
            end
    		if (delay_validD1==1) begin
    			window_bytes[window_head_wr] <= output_previously;    			
                window_head_wr <= window_head_wr+1;
    		end
            if (output_valid==1 && output_last==1) begin
                waiting_finish <= 0;
            end
    	end
    end
endmodule
