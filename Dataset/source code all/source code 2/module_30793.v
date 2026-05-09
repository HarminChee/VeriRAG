module up3
(
	input wire         clk,
	input wire         rst,
	output reg [7:0]   pc,
	output reg [15:0]  ra,
	output wire [15:0] dr,
	output reg [15:0]  ir
);
	localparam RESET     = 0;
	localparam FETCH     = 1;
	localparam DECODE    = 2;
	localparam OP_ADD    = 3;
	localparam OP_STORE  = 4;
	localparam OP_STORE2 = 5;
	localparam OP_STORE3 = 6;
	localparam OP_LOAD   = 7;
	localparam OP_JUMP   = 8;
	reg [3:0]   state;
	wire [15:0] dr_;
	reg [7:0]   ar_;
	wire [15:0] ar;
	reg         rw_;
	wire        rw;
	assign dr = dr_;
	assign ar = ar_;
	assign rw = rw_;
	always @ (posedge clk or posedge rst) begin
		if (rst)
			state = RESET;
		else
			case (state)
				RESET: begin
					pc <= 0;
					ra <= 0;
					state <= FETCH;
				end
				FETCH: begin
					ir <= dr;
					pc <= pc + 1;
					state <= DECODE;
				end
				DECODE: begin
					case (ir[15:8])
						'b00:
							state <= OP_ADD;
						'b01:
							state <= OP_STORE;
						'b10:
							state <= OP_LOAD;
						'b11:
							state <= OP_JUMP;
						default:
							state <= FETCH;
					endcase
				end
				OP_ADD: begin
					ra <= ra + dr;
					state <= FETCH;
				end
				OP_STORE:
					state <= OP_STORE2;
				OP_STORE2:
					state <= OP_STORE3;
				OP_LOAD: begin
					ra <= dr;
					state <= FETCH;
				end
				OP_JUMP: begin
					pc <= ir[7:0];
					state <= FETCH;
				end
				default:
					state <= FETCH;
			endcase
	end
	always @ (state or pc or ir) begin
		case (state)
			RESET:     ar_ <= 0;
			FETCH:     ar_ <= pc;
			DECODE:    ar_ <= ir[7:0];
			OP_ADD:    ar_ <= pc;
			OP_STORE:  ar_ <= ir[7:0];
			OP_STORE2: ar_ <= pc;
			OP_LOAD:   ar_ <= pc;
			OP_JUMP:   ar_ <= ir[7:0];
			default:   ar_ <= pc;
		endcase
		case (state)
			OP_STORE: rw_ <= 1;
			default:  rw_ <= 0;
		endcase
	end
	altsyncram ram(
		.wren_a(rw),
		.clock0(clk),
		.address_a(ar),
		.data_a(ra),
		.q_a(dr_)
	);
	defparam
		ram.operation_mode = "SINGLE_PORT",
		ram.width_a = 16,
		ram.widthad_a = 8,
		ram.outdata_reg_a = "UNREGISTERED",
		ram.lpm_type = "altsyncram",
		ram.init_file = "program.mif",
		ram.intended_device_family = "Cyclone";
endmodule
