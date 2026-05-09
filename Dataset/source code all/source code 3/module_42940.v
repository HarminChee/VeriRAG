module bin2bcd#(
	parameter	BIN_BITS	= 8
)(
	input										clk,
	input										rst,
	input										start,
	input	[BIN_BITS - 1				: 0]	bin_num_in,
	output	[bcd_out_bits(BIN_BITS) - 1	: 0]	bcd_out,
	output	reg									end_of_cnv
);
function integer log2ceil;
input integer val;
integer i;
begin
	i = 1;
	log2ceil = 0;
	while (i < val) begin
		log2ceil = log2ceil + 1;
		i = i << 1;
	end
end
endfunction
function integer bcd_out_bits;
input integer binary_bits;
integer bits_pow_2_local;
integer decimal_bits_local;
begin
	bits_pow_2_local = max_of_input_bits(binary_bits);
	decimal_bits_local = dec_bits(bits_pow_2_local);
	bcd_out_bits = decimal_bits_local * 4;
end
endfunction
function integer dec_bits;
input integer max_uint;
integer t;
begin
	t = max_uint;
	dec_bits = 0;
	while (t > 0) begin
		dec_bits = dec_bits + 1;
		t = t / 10;
	end
end
endfunction
function integer max_of_input_bits;
input integer bits_input;
integer i;
begin
	max_of_input_bits = 0;
	i = 0;
	while (i < bits_input) begin
		max_of_input_bits = (i == 0) ? (2) : (max_of_input_bits * 2);
		i = i + 1;
	end
	max_of_input_bits = max_of_input_bits - 1;
end
endfunction
localparam	BITS_POW_2		= max_of_input_bits(BIN_BITS);
localparam	DECIMAL_BITS	= dec_bits(BITS_POW_2);
localparam	BCD_BITS 		= DECIMAL_BITS * 4;
localparam	COUNT_BITS		= log2ceil(BIN_BITS);
localparam	IDLE			= 3'b1;
localparam	CONVERT			= 3'b10;
localparam	OUTPUT			= 3'b100;
reg		[2				: 0]	cnv_state;
reg		[2				: 0]	next_state;
reg		[COUNT_BITS - 1	: 0]	count;
reg		[BIN_BITS - 1	: 0]	bin_num;
reg		[BCD_BITS - 1	: 0]	shift_reg;
reg		[BCD_BITS - 1	: 0]	result;
wire	[BCD_BITS - 1	: 0]	plus_3_adj;
genvar i;
generate
	for(i = 0; i < DECIMAL_BITS; i = i + 1) begin : plus_3_adj_link
		assign plus_3_adj[i * 4 +: 4] = 
			shift_reg[i * 4 +: 4] + {2'b00, 
			((shift_reg[i * 4 +: 4] < 4'd5) ? 
			(2'b00) :
			(2'b11))};
	end
endgenerate
always @ (posedge clk or negedge rst)
begin
	if (!rst) begin
		cnv_state <= IDLE;
	end
	else begin
		cnv_state <= next_state;
	end
end
always @ (*)
begin
	next_state = IDLE;
	case (cnv_state)
		IDLE	: begin
			if (start) begin
				next_state = CONVERT;
			end
			else begin
				next_state = IDLE;
			end
		end
		CONVERT	: begin
			if (count < BIN_BITS - 1) begin
				next_state = CONVERT;
			end
			else begin
				next_state = OUTPUT;
			end
		end
		OUTPUT	: begin
			next_state = IDLE;
		end
		default	: begin
			next_state = IDLE;
		end
	endcase
end
always @ (posedge clk or negedge rst)
begin
	if (!rst) begin
		end_of_cnv <= 0;
		bin_num <= 0;
		shift_reg <= 0;
		count <= 0;
	end
	else begin
		case(cnv_state) 
			IDLE	: begin
				end_of_cnv <= 1'b0;
				bin_num <= bin_num_in;
				shift_reg <= 0;
				count <= 0;
			end
			CONVERT	: begin
				count <= count + 1;
				{shift_reg, bin_num} <= {plus_3_adj[0 +: BCD_BITS - 1], bin_num, 1'b0};
			end
			OUTPUT	: begin
				end_of_cnv <= 1'b1;
				result <= shift_reg;
			end
		endcase
	end
end
assign bcd_out = result;
endmodule
