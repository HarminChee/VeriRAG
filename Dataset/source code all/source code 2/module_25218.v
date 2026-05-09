module phase_detector_filter
(
	input  clk,
	input  reset,
	input  update,
	input  [3:0]phase_in, 
	output [3:0]phase_out 
);
	localparam N = 10;  
	wire [(N-1):0]ph_cnt;
	assign phase_out = ph_cnt[(N-1):(N-4)];
	wire [3:0]diff = ph_cnt[(N-2):(N-5)] - phase_in;
	wire cnt_ena = update && (diff != 4'd0);
	wire up = diff[3];
	wire [(N-2):0]ph_cnt_L; 
	reg ph_cnt_H;           
	wire carry;
	assign ph_cnt = {ph_cnt_H, ph_cnt_L};
	always @(posedge clk or posedge reset)
	begin
		if (reset) ph_cnt_H <= 1'd1;
		else if (cnt_ena && carry) ph_cnt_H <= up;
	end	
	lpm_counter	phase_counter
	(
		.aclr (reset),
		.clk_en (cnt_ena),
		.clock (clk),
		.updown (up),
		.cout (carry),
		.q (ph_cnt_L),
		.aload (1'b0),
		.aset (1'b0),
		.cin (1'b1),
		.cnt_en (1'b1),
		.data ({(N-1){1'b0}}),
		.eq (),
		.sclr (1'b0),
		.sload (1'b0),
		.sset (1'b0)
	);
	defparam
		phase_counter.lpm_direction = "UNUSED",
		phase_counter.lpm_port_updown = "PORT_USED",
		phase_counter.lpm_type = "LPM_COUNTER",
		phase_counter.lpm_width = N-1;
endmodule
