module jpeg_encoder(
	clk_i,
	ena,
	dstrb,
	din,
	qnt_val,
	qnt_cnt,
	size,
	rlen,
	amp,
	douten,
        SE,
        SI,
        SO,
        rst_i
);
	parameter coef_width = 11;
	parameter di_width = 8; 
input SE;
input SI;
output SO;
	input clk_i;                      
	input ena;                      
	input dstrb;                    
	input [di_width-1:0] din;
	input [7:0]          qnt_val;   
	output [ 5:0] qnt_cnt;          
	output [ 3:0] size;    
	output [ 3:0] rlen;    
	output [11:0] amp;     
	output        douten;  
	input rst_i;                      
	wire fdct_doe, qnr_doe;
	wire [11:0] fdct_dout;
	reg  [11:0] dfdct_dout;
	wire [10:0] qnr_dout;
	reg         dqnr_doe;
	fdct #(coef_width, di_width, 12)
	fdct_zigzag(
		.clk(clk_i),
		.ena(ena),
		.rst(rst_i),
		.dstrb(dstrb),
		.din(din),
		.dout(fdct_dout),
		.douten(fdct_doe)
	);
	always @(posedge clk_i or negedge rst_i)
	  if(!rst_i)
	    dfdct_dout <= 12'b0;
	  else if(ena)
	    dfdct_dout <= fdct_dout;
	jpeg_qnr
	qnr(
		.clk(clk_i),
		.ena(ena),
		.rst(rst_i),
		.dstrb(fdct_doe),
		.din(dfdct_dout),
		.qnt_val(qnt_val),
		.qnt_cnt(qnt_cnt),
		.dout(qnr_dout),
		.douten(qnr_doe)
	);
	always @(posedge clk_i or negedge rst_i)
	  if(!rst_i)
	    dqnr_doe <= 1'b0;
	  else if(ena)
	    dqnr_doe <= qnr_doe;
	wire [11:0] dc_diff_dout = {qnr_dout[10], qnr_dout};
	wire        dc_diff_doe = dqnr_doe;
	jpeg_rle
	rle(
		.clk(clk_i),
		.ena(ena),
		.rst(rst_i),
		.dstrb(dc_diff_doe),
		.din(dc_diff_dout),
		.size(size),
		.rlen(rlen),
		.amp(amp),
		.douten(douten),
		.bstart()
	);
endmodule