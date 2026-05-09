module mult8_rollup(
	output reg [7:0] product,
	output done,
	input [7:0] A,
	input [7:0] B,
	input clk,
	input start );
reg [4:0] multcounter;
reg [7:0] shiftA;
reg [7:0] shiftB;
wire adden;
assign adden = shiftB[7] & !done;
assign done = multcounter[3];
always @(posedge clk) begin
	if( start )
		multcounter <= 0;
	else if( !done ) begin
		multcounter <= multcounter + 1;
	end
	if( start )
		shiftB <= B;
	else 
		shiftB[7:0] <= { shiftB[6:0], 1'b0 };
	if( start )
		shiftA <= A;
	else 
		shiftA <= { shiftA[7], shiftA[7:1] };
	if( start )
		product <= 0;
	else  if( adden )
		product <= product + shiftA;
end
endmodule
module lowpassfir(
	output reg [7:0] filtout,
	output reg done,
	input clk,
	input [7:0] datain,
	input datavalid,
	input [7:0] coeffA, coeffB, coeffC);
reg [7:0] X0, X1, X2;
reg multdonedelay;
reg multstart;
reg [7:0] multdat;
reg [7:0] multcoeff;
reg [2:0] state;
reg [7:0] accum;
reg clearaccum;
reg [7:0] accumsum;
wire multdone;
wire [7:0] multout;
mult8x8 mult8x8(.clk(clk), .dat1(multdat),
	.dat2(multcoeff), .start(multstart),
	.done(multdone), .multout(multout));
always @( posedge clk ) begin
	multdonedelay <= multdone;
	accumsum <= accum + multout[7:0];
	if( clearaccum)
		accum <= 0;
	else if ( multdonedelay ) 
		accum <= accumsum;
	case( state )
		0: begin
			if( datavalid ) begin
				X0 <= datain;
				X1 <= X0;
				X2 <= X1;
				multdat <= datain;  
				multcoeff <= coeffA;
				multstart <= 1;
				clearaccum <= 1;
				state <= 1;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		1: begin
			if( multdonedelay ) begin
				multdat <= X1;
				multcoeff <= coeffB;
				multstart <= 1;
				state <= 2;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		2: begin
			if( multdonedelay ) begin
				multdat <= X2;
				multcoeff <= coeffC;
				multstart <= 0;
				state <= 3;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		3: begin
			if( multdonedelay ) begin
				filtout <= accumsum;
				done <= 1;
				state <= 0;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		default 
			state <= 0;
	endcase
end
endmodule
module mult8(
	output [7:0] product,
	input [7:0] A,
	input [7:0] B,
	input clk );
reg [15:0] prod16;
assign product = prod16[15:8];
always @(posedge clk) begin
	prod16 <= A * B;
end
endmodule
module mult8_rollup(
	output reg [7:0] product,
	output done,
	input [7:0] A,
	input [7:0] B,
	input clk,
	input start );
reg [4:0] multcounter;
reg [7:0] shiftA;
reg [7:0] shiftB;
wire adden;
assign adden = shiftB[7] & !done;
assign done = multcounter[3];
always @(posedge clk) begin
	if( start )
		multcounter <= 0;
	else if( !done ) begin
		multcounter <= multcounter + 1;
	end
	if( start )
		shiftB <= B;
	else 
		shiftB[7:0] <= { shiftB[6:0], 1'b0 };
	if( start )
		shiftA <= A;
	else 
		shiftA <= { shiftA[7], shiftA[7:1] };
	if( start )
		product <= 0;
	else  if( adden )
		product <= product + shiftA;
end
endmodule
module lowpassfir(
	output reg [7:0] filtout,
	output reg done,
	input clk,
	input [7:0] datain,
	input datavalid,
	input [7:0] coeffA, coeffB, coeffC);
reg [7:0] X0, X1, X2;
reg multdonedelay;
reg multstart;
reg [7:0] multdat;
reg [7:0] multcoeff;
reg [2:0] state;
reg [7:0] accum;
reg clearaccum;
reg [7:0] accumsum;
wire multdone;
wire [7:0] multout;
mult8x8 mult8x8(.clk(clk), .dat1(multdat),
	.dat2(multcoeff), .start(multstart),
	.done(multdone), .multout(multout));
always @( posedge clk ) begin
	multdonedelay <= multdone;
	accumsum <= accum + multout[7:0];
	if( clearaccum)
		accum <= 0;
	else if ( multdonedelay ) 
		accum <= accumsum;
	case( state )
		0: begin
			if( datavalid ) begin
				X0 <= datain;
				X1 <= X0;
				X2 <= X1;
				multdat <= datain;  
				multcoeff <= coeffA;
				multstart <= 1;
				clearaccum <= 1;
				state <= 1;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		1: begin
			if( multdonedelay ) begin
				multdat <= X1;
				multcoeff <= coeffB;
				multstart <= 1;
				state <= 2;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		2: begin
			if( multdonedelay ) begin
				multdat <= X2;
				multcoeff <= coeffC;
				multstart <= 0;
				state <= 3;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		3: begin
			if( multdonedelay ) begin
				filtout <= accumsum;
				done <= 1;
				state <= 0;
			end
			else begin
				multstart <= 0;
				clearaccum <= 0;
				done <= 0;
			end
		end
		default 
			state <= 0;
	endcase
end
endmodule
