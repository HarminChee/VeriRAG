`define INTEGER_INPUT_WIDTH ((STAGE_NUMBER+1) * 2)
`define INTEGER_OUTPUT_WIDTH `INTEGER_INPUT_WIDTH-2
`define REMAINDER_INPUT_WIDTH (((RADICAND_WIDTH/2) + 1) - STAGE_NUMBER)
`define RESULT_INPUT_WIDTH ((RADICAND_WIDTH/2) - STAGE_NUMBER - 1)
`define REMAINDER_OUTPUT_WIDTH (`REMAINDER_INPUT_WIDTH+1)
`define RESULT_OUTPUT_WIDTH `RESULT_INPUT_WIDTH+1
`define IS_FIRST_STAGE (STAGE_NUMBER == ((RADICAND_WIDTH/2) - 1))
`define IS_LAST_STAGE (STAGE_NUMBER == 0)
`define INTEGER_INPUT_WIDTH ((STAGE_NUMBER+1) * 2)
`define INTEGER_OUTPUT_WIDTH `INTEGER_INPUT_WIDTH-2
`define REMAINDER_INPUT_WIDTH (((RADICAND_WIDTH/2) + 1) - STAGE_NUMBER)
`define RESULT_INPUT_WIDTH ((RADICAND_WIDTH/2) - STAGE_NUMBER - 1)
`define REMAINDER_OUTPUT_WIDTH (`REMAINDER_INPUT_WIDTH+1)
`define RESULT_OUTPUT_WIDTH `RESULT_INPUT_WIDTH+1
`define IS_FIRST_STAGE (STAGE_NUMBER == ((RADICAND_WIDTH/2) - 1))
`define IS_LAST_STAGE (STAGE_NUMBER == 0)
module sqrt_remainder 
	#(
		parameter RADICAND_WIDTH = 8, 
		parameter STAGE_NUMBER = 3
	)
	( 
		input wire [`INTEGER_INPUT_WIDTH-1:0] integer_input,
		input wire [`REMAINDER_INPUT_WIDTH-1:0] remainder_previous,
		input wire [(`RESULT_INPUT_WIDTH-1 + `IS_FIRST_STAGE):0] result_previous, 
		output reg [`INTEGER_OUTPUT_WIDTH-1:0] integer_output,
		output reg signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder,
		output reg [`RESULT_OUTPUT_WIDTH-1:0] result,
		input wire reset,
		input wire clk
	);
	reg phase; 
	wire signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_new_without_add;
	assign remainder_new_without_add = {
		remainder_previous[`REMAINDER_INPUT_WIDTH-2:0], 
		integer_input[{STAGE_NUMBER, 1'b1}], 
		integer_input[{STAGE_NUMBER, 1'b0}] 
	};
	wire signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_greater_than_or_equal_to_0_subtractor;
	wire signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_less_than_0_addition;
	assign remainder_greater_than_or_equal_to_0_subtractor = {result_previous, 2'b01};
	assign remainder_less_than_0_addition = {result_previous, 2'b11};
	reg signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_delay;
	reg [`INTEGER_INPUT_WIDTH-1:0] integer_output_delay;
	reg [(`RESULT_INPUT_WIDTH-1 + `IS_FIRST_STAGE):0] result_previous_delay;
	always @(posedge clk) begin
				if (remainder_previous[`REMAINDER_INPUT_WIDTH-1] == 1'b0) begin 
					remainder_delay <= remainder_new_without_add - remainder_greater_than_or_equal_to_0_subtractor;
				end else begin
					remainder_delay <= remainder_new_without_add + remainder_less_than_0_addition;
				end
				remainder <= remainder_delay;
				integer_output_delay <= integer_input[(`INTEGER_OUTPUT_WIDTH-1 + `IS_LAST_STAGE):0];
				integer_output <= integer_output_delay;
				result_previous_delay <= result_previous;
				if (remainder_delay[`REMAINDER_OUTPUT_WIDTH-1] != 1'b1) begin 
					result <= {result_previous_delay, 1'b1};
				end else begin
					result <= {result_previous_delay, 1'b0};
					if (`IS_LAST_STAGE) remainder <= remainder_delay + {result_previous_delay, 2'b01};
				end
	end
endmodule
