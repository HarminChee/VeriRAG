`timescale 1ns / 1ps
`define POP				2'b01
`define PUSH			2'b10
`define DO_NOTHING	2'b00
`define INVALID		2'b11
`define DATA_VALID	1'b1
`define DATA_INVALID	1'b0
`define LIFO_FULL			1'b1
`define LIFO_NOT_FULL	1'b0
`define LIFO_EMPTY		1'b1
`define LIFO_NOT_EMPTY	1'b0
`define LOG2(width) 	(width<=2)?1:\
							(width<=4)?2:\
							(width<=8)?3:\
							(width<=16)?4:\
							(width<=32)?5:\
							(width<=64)?6:\
							(width<=128)?7:\
							(width<=256)?8:\
							-1				
`timescale 1ns / 1ps
`define POP				2'b01
`define PUSH			2'b10
`define DO_NOTHING	2'b00
`define INVALID		2'b11
`define DATA_VALID	1'b1
`define DATA_INVALID	1'b0
`define LIFO_FULL			1'b1
`define LIFO_NOT_FULL	1'b0
`define LIFO_EMPTY		1'b1
`define LIFO_NOT_EMPTY	1'b0
`define LOG2(width) 	(width<=2)?1:\
							(width<=4)?2:\
							(width<=8)?3:\
							(width<=16)?4:\
							(width<=32)?5:\
							(width<=64)?6:\
							(width<=128)?7:\
							(width<=256)?8:\
							-1				
module lifo_top(
	data_out, empty_flag, full_flag,
	vector_in, reset,
	clk
   );
parameter DATA_WIDTH = 4;
parameter NUM_ENTRIES = 4;
parameter OPCODE_WIDTH = 2;
parameter LINE_WIDTH = DATA_WIDTH+OPCODE_WIDTH; 
parameter INITIAL_VALUE = 'b0; 
parameter NUM_ENTRIES_BIT = `LOG2(NUM_ENTRIES); 
output reg [DATA_WIDTH-1:0]data_out;
output reg empty_flag;
output reg full_flag;
input [OPCODE_WIDTH+DATA_WIDTH-1:0]vector_in;
input reset;
input clk;
reg [DATA_WIDTH-1:0]lifo_data[NUM_ENTRIES-1:0];
reg [NUM_ENTRIES-1:0]lifo_valid_invalid_bit;
reg [OPCODE_WIDTH-1:0]control_in;	
reg [DATA_WIDTH-1:0]data_in;			
reg [NUM_ENTRIES_BIT-1:0]lifo_head_pos;
reg [NUM_ENTRIES_BIT-1:0]lifo_tail_pos;
reg [NUM_ENTRIES_BIT-1:0]loop_variable;
always@(posedge clk)
begin	
	if(reset)
	begin
		data_out = INITIAL_VALUE;
		lifo_head_pos = INITIAL_VALUE;
		lifo_tail_pos = INITIAL_VALUE;
		loop_variable = INITIAL_VALUE;
		control_in = INITIAL_VALUE;
		data_in = INITIAL_VALUE;
		lifo_valid_invalid_bit = INITIAL_VALUE;
		empty_flag = `LIFO_NOT_EMPTY;
		full_flag = `LIFO_NOT_FULL;
	end else
		begin
			if(lifo_head_pos == INITIAL_VALUE && lifo_tail_pos == INITIAL_VALUE)
			begin				
				empty_flag = `LIFO_EMPTY;
				full_flag = `LIFO_NOT_FULL;
			end else
				begin
					if(lifo_head_pos == NUM_ENTRIES-1 && lifo_tail_pos == NUM_ENTRIES-1)
					begin
						empty_flag = `LIFO_NOT_EMPTY;
						full_flag = `LIFO_FULL;					
					end else
						begin
							empty_flag = `LIFO_EMPTY;
							full_flag = `LIFO_NOT_FULL;
						end
				end
		control_in = vector_in[LINE_WIDTH-1:LINE_WIDTH-OPCODE_WIDTH];	
		data_in = vector_in[LINE_WIDTH-OPCODE_WIDTH-1:LINE_WIDTH-OPCODE_WIDTH-DATA_WIDTH];
		case(control_in)			
			`POP: 
				begin
					if(lifo_valid_invalid_bit[lifo_tail_pos] == `DATA_VALID)
					begin
						data_out = lifo_data[lifo_tail_pos];
						lifo_valid_invalid_bit[lifo_tail_pos] = `DATA_INVALID;
						if(lifo_tail_pos == INITIAL_VALUE)
						begin
							lifo_tail_pos = INITIAL_VALUE;
							lifo_head_pos = lifo_head_pos - 1'b1;							
						end else 
							begin
								if(empty_flag == `LIFO_NOT_EMPTY && full_flag == `LIFO_FULL)
									lifo_tail_pos = lifo_tail_pos - 1'b1;
								else begin	
									lifo_tail_pos = lifo_tail_pos - 1'b1;
									lifo_head_pos = lifo_head_pos - 1'b1;
								end
							end		
					end else
						begin
							data_out = 'bx;
						end
				end
			`PUSH: 
				begin
					if(empty_flag == `LIFO_EMPTY && full_flag == `LIFO_NOT_FULL)
					begin
						lifo_data[lifo_head_pos] = data_in;
						lifo_valid_invalid_bit[lifo_head_pos] = `DATA_VALID;
						if(lifo_head_pos == NUM_ENTRIES-1)
						begin
							lifo_tail_pos = lifo_tail_pos + 1'b1;;
							lifo_head_pos = NUM_ENTRIES-1;
						end else begin
							lifo_tail_pos = lifo_head_pos;
							lifo_head_pos = lifo_head_pos + 1'b1;
						end 
					end 
				end
			default: data_out = 'bx;
		endcase				
	end
end		
endmodule
