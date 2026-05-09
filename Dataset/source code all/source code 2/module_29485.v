module jpeg_qnr(clk, ena, rst, dstrb, din, qnt_val, qnt_cnt, dout, douten);
	parameter d_width = 12;
	parameter z_width = 2 * d_width;
	input clk;                    
	input ena;                    
	input rst;                    
	input                dstrb;   
	input  [d_width-1:0] din;     
	input  [ 7:0]        qnt_val; 
	output [ 5:0]        qnt_cnt; 
	output [10:0]        dout;    
	output               douten;
	wire [z_width-1:0] iz; 
	wire [d_width-1:0] id; 
	wire [d_width  :0] iq; 
	reg  [d_width  :0] rq; 
	reg  [d_width+3:0] dep;
	reg  [5:0] qnt_cnt;
	wire       dcnt     = &qnt_cnt;
	always @(posedge clk or negedge rst)
	  if (~rst)
	     qnt_cnt <= #1 6'h0;
	  else if (dstrb)
	     qnt_cnt <= #1 6'h0;
	  else if (ena)
	     qnt_cnt <= #1 qnt_cnt + 6'h1;
	assign id = { {(d_width - 8){1'b0}}, qnt_val};
	assign iz = { {(z_width - d_width){din[d_width-1]}}, din};
	div_su #(z_width)
	divider (
		.clk(clk),
		.ena(ena),
		.z(iz),
		.d(id),
		.q(iq),
		.s(),
		.div0(),
		.ovf()
	);
	always @(posedge clk)
	  if (ena)
	    if (iq[0])
	      if (iq[d_width])
	         rq <= #1 iq - 1'h1;
	      else
	         rq <= #1 iq + 1'h1;
	    else
	       rq <= #1 iq;
	assign dout = rq[d_width -1: d_width-11];
	integer n;
	always @(posedge clk or negedge rst)
	  if (!rst)
	     dep <= #1 0;
	  else if(ena)
	     begin
	         dep[0] <= #1 dstrb;
	         for (n=1; n <= d_width +3; n = n +1)
	             dep[n] <= #1 dep[n-1];
	     end
	assign douten = dep[d_width +3];
endmodule
