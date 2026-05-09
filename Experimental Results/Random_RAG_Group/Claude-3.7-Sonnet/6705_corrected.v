`timescale 1ns / 1ps
module shift_reg_32 (
	clk, 
	p_load,  
	p_data, 
	s_in,
	s_out,
	shift_en,
	test_i,
	rst_n
);
input  		 clk;
input			 s_in;
input			 p_load;
input [31:0] p_data;
input			 shift_en;
input        test_i;
input        rst_n;
output 		 s_out;
reg   [31:0] shreg;
wire         dft_clk;
assign dft_clk = test_i ? clk : clk;
always @(posedge dft_clk or negedge rst_n) begin
	if (!rst_n) begin
		shreg <= 32'b0;
	end else if (p_load) begin
		shreg <= p_data;
	end else begin
		if (shift_en) begin
			shreg <= {shreg[30:0], s_in};
		end
	end
end
assign s_out  = shreg[31];
endmodule

`timescale 1ns / 1ps
module trim_dac_ctrl (
	input clk40,
	input rst_n,
	input [6:0] lut_in,
	input [4:0] lut_addr,
	input lut_we,
	input load_dacs,
	output serial_out,
	output clk_out,
	output enable_out,
	input test_i
);
wire [13:0] lut_out;
reg  [3:0]	lut_out_addr;
wire        dft_clk40;
assign dft_clk40 = test_i ? clk40 : clk40;

dp_lut_7x5_14x4 trim_lut (
	.clk(dft_clk40),
	.din_a(lut_in),
	.we_a(lut_we),
	.addr_a(lut_addr),
	.dout_b(lut_out),
	.addr_b(lut_out_addr)
);

reg clk20A, clk20B;
reg  [3:0]	dac_addr;
reg			shift_en;
reg 			shreg1_ld_en, shreg2_ld_en, shreg3_ld_en;
wire [31:0] shreg_pin;
wire 			shreg1_out, shreg2_out;

shift_reg_32 shreg1(
	.clk(clk20A), 
	.p_load(shreg1_ld_en),  
	.p_data(shreg_pin), 
	.s_in(1'b0),
	.s_out(shreg1_out),
	.shift_en(shift_en),
	.test_i(test_i),
	.rst_n(rst_n)
);

shift_reg_32 shreg2(
	.clk(clk20A), 
	.p_load(shreg2_ld_en),  
	.p_data(shreg_pin), 
	.s_in(shreg1_out),
	.s_out(shreg2_out),
	.shift_en(shift_en),
	.test_i(test_i),
	.rst_n(rst_n)
);

shift_reg_32 shreg3(
	.clk(clk20A), 
	.p_load(shreg3_ld_en),  
	.p_data(shreg_pin), 
	.s_in(shreg2_out),
	.s_out(serial_out),
	.shift_en(shift_en),
	.test_i(test_i),
	.rst_n(rst_n)
);

assign shreg_pin = {8'b0, 4'b0011, dac_addr, lut_out[11:0], 4'b0};

reg clk_mask;
assign clk_out = (clk_mask & ~clk20A);

reg early_cycle, late_cycle;
assign enable_out = ~(shift_en | early_cycle | late_cycle);

always @(posedge dft_clk40 or negedge rst_n) begin
	if (!rst_n) begin
		clk20A <= 0;
	end else begin
		clk20A <= ~clk20A;
	end
end

always @(negedge dft_clk40 or negedge rst_n) begin
	if (!rst_n) begin
		clk20B <= 0;
	end else begin
		clk20B <= ~clk20B;
	end
end

always @(posedge clk20A or negedge rst_n) begin
	if (!rst_n) begin
		clk_mask <= 0;
	end else begin
		if (shift_en | early_cycle) begin
			clk_mask <= 1;
		end else begin
			clk_mask <= 0;
		end
	end
end

reg trig_a, trig_b;
wire long_trig;

always @(posedge dft_clk40 or negedge rst_n) begin
	if (!rst_n) begin
		trig_a <= 0;
		trig_b <= 0;
	end else begin
		trig_a <= load_dacs;
		trig_b <= trig_a;
	end
end

assign long_trig = trig_a | trig_b;

reg [8:0] state_count;

always @(negedge clk20B or negedge rst_n) begin
	if (!rst_n) begin
		shift_en 	 <= 0;
		state_count  <= 0;
		shreg1_ld_en <= 0;
		shreg2_ld_en <= 0;
		shreg3_ld_en <= 0;
		early_cycle  <= 0;
		late_cycle   <= 0;
		dac_addr     <= 0;
		lut_out_addr <= 0;
	end else begin
		early_cycle <= 0;
		late_cycle  <= 0;
		if (long_trig) begin
			state_count <= 9'd1;
		end else begin
			state_count <= state_count + 1;
			case (state_count)
				9'd0: state_count <= 0;
				9'd1: begin
					dac_addr <= 4'b0000;
					lut_out_addr <= 4'd0;
					shreg1_ld_en <= 1;
				end
				9'd2: begin
					shreg1_ld_en <= 0;
					lut_out_addr <= 4'd1;
					shreg2_ld_en <= 1;
				end
				9'd3: begin
					shreg2_ld_en <= 0;
					lut_out_addr <= 4'd2;
					shreg3_ld_en <= 1;
				end
				9'd4: begin
					shreg3_ld_en <= 0;
					early_cycle <= 1;
				end
				9'd5: begin
					shift_en <= 1;
				end
				9'd100: begin
					shift_en <= 0;	 
					late_cycle <= 1;
				end
				9'd101: begin
					dac_addr <= 4'b0001;
					lut_out_addr <= 4'd3;
					shreg1_ld_en <= 1;
				end
				9'd102: begin
					shreg1_ld_en <= 0;
					lut_out_addr <= 4'd4;
					shreg2_ld_en <= 1;
				end
				9'd103: begin
					shreg2_ld_en <= 0;
					lut_out_addr <= 4'd5;
					shreg3_ld_en <= 1;
				end
				9'd104: begin
					shreg3_ld_en <= 0;
					early_cycle <= 1;
				end
				9'd105: begin
					shift_en <= 1;
				end
				9'd200: begin
					shift_en <= 0;	 
					late_cycle <= 1;
				end
				9'd201: begin
					dac_addr <= 4'b0010;
					lut_out_addr <= 4'd6;
					shreg1_ld_en <= 1;
				end
				9'd202: begin
					shreg1_ld_en <= 0;
					lut_out_addr <= 4'd7;
					shreg2_ld_en <= 1;
				end
				9'd203: begin
					shreg2_ld_en <= 0;
					lut_out_addr <= 4'd8;
					shreg3_ld_en <= 1;
				end
				9'd204: begin
					shreg3_ld_en <= 0;
					early_cycle <= 1;
				end
				9'd205: begin
					shift_en <= 1;
				end
				9'd300: begin
					shift_en <= 0;	 
					late_cycle <= 1;
					state_count <= 0;
				end
			endcase
		end
	end
end
endmodule

module dp_lut_7x5_14x4 (
	clk,
	din_a,
	we_a,
	addr_a,
	dout_b,
	addr_b,
	rst_n,
	test_i
);
input 		  clk;
input 		  we_a;
input  [4:0]  addr_a;
input  [6:0]  din_a;
input  [3:0]  addr_b;
input         rst_n;
input         test_i;
output [13:0] dout_b;
wire          dft_clk;
assign dft_clk = test_i ? clk : clk;
reg [6:0] lut [0:31];

always @(posedge dft_clk or negedge rst_n) begin
	if (!rst_n) begin
		integer i;
		for (i=0; i<32; i=i+1) begin
			lut[i] <= 0;
		end
	end else if (we_a) begin
		lut[addr_a] <= din_a;
	end
end

assign dout_b = {lut[2*addr_b + 1], lut[2*addr_b]};
endmodule