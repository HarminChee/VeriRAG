module jpeg_encoder(
	clk,
	rst_n, // Added reset input
	ena,
	dstrb,
	din,
	qnt_val,
	qnt_cnt,
	size,
	rlen,
	amp,
	douten,
        SE, // Existing Scan Enable, used as test_mode
        SI,
        SO
);
	parameter coef_width = 11;
	parameter di_width = 8; 
input SE;
input SI;
output SO;
	input clk;                      
	input rst_n; // Added reset input
	input ena;                      
	input dstrb;                    
	input [di_width-1:0] din;
	input [7:0]          qnt_val;   
	output [ 5:0] qnt_cnt;          
	output [ 3:0] size;    
	output [ 3:0] rlen;    
	output [11:0] amp;     
	output        douten;  
	// wire rst = 1'b1; // Removed uncontrollable reset
	wire dft_rst; // Added controllable DFT reset signal
	// Assumes submodules use active-high reset.
	// In test mode (SE=1), reset is controlled by primary input rst_n (active-low).
	// In functional mode (SE=0), reset is held inactive (low).
	assign dft_rst = SE ? ~rst_n : 1'b0; 

	wire fdct_doe, qnr_doe;
	wire [11:0] fdct_dout;
	reg  [11:0] dfdct_dout;
	wire [10:0] qnr_dout;
	reg         dqnr_doe;
	fdct #(coef_width, di_width, 12)
	fdct_zigzag(
		.clk(clk),
		.ena(ena),
		.rst(dft_rst), // Use controllable reset
		.dstrb(dstrb),
		.din(din),
		.dout(fdct_dout),
		.douten(fdct_doe)
	);
	always @(posedge clk)
	  if(ena)
	    dfdct_dout <= #1 fdct_dout;
	jpeg_qnr
	qnr(
		.clk(clk),
		.ena(ena),
		.rst(dft_rst), // Use controllable reset
		.dstrb(fdct_doe),
		.din(dfdct_dout),
		.qnt_val(qnt_val),
		.qnt_cnt(qnt_cnt),
		.dout(qnr_dout),
		.douten(qnr_doe)
	);
	always @(posedge clk)
	  if(ena)
	    dqnr_doe <= #1 qnr_doe;
	wire [11:0] dc_diff_dout = {qnr_dout[10], qnr_dout};
	wire        dc_diff_doe = dqnr_doe;
	jpeg_rle
	rle(
		.clk(clk),
		.ena(ena),
		.rst(dft_rst), // Use controllable reset
		.dstrb(dc_diff_doe),
		.din(dc_diff_dout),
		.size(size),
		.rlen(rlen),
		.amp(amp),
		.douten(douten),
		.bstart()
	);
endmodule