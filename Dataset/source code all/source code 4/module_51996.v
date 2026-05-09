module lfsr_counter( clk, reset, out );
  `define W 4
  parameter WIDTH = `W;
  parameter TAP = `W'b1001;
  integer   N;
  output [WIDTH-1:0] out;
  input              clk, reset;
  wire [WIDTH-1:0] gc;
  reg [WIDTH-1:0]  lfsr, next_lfsr;
  reg		   fb_lsb, fb;
  always @(posedge clk or negedge reset )
    begin 
      if( reset == 1'b0 )
	lfsr[WIDTH-1:0] <= `W'b0;
      else
	lfsr[WIDTH-1:0] <= next_lfsr[WIDTH-1:0];
    end 
  always @( lfsr )
    begin 
      fb_lsb = ~| lfsr[WIDTH-2:0];
      fb = lfsr[WIDTH-1] ^ fb_lsb;
      for( N=WIDTH; N>=0; N=N-1 )
	if( TAP[N] == 1 )
	  next_lfsr[N] = lfsr[N-1] ^ fb;
	else
	  next_lfsr[N] = lfsr[N-1];
      next_lfsr[0] = fb;
      end 
  assign out[WIDTH-1:0] = {1'b0, lfsr[WIDTH-1:1]};  
endmodule 
