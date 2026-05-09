module pipeline_buffer_2bit (in,out,clock,reset);
	output [1:0] out;			
	input [1:0] in;				
	input clock;				
	input reset;				
	reg [1:0] out;
	reg [1:0] o1;					
	reg [1:0] o2;					
	reg [1:0] o3;					
	reg [1:0] o4;					
	reg [1:0] o5;					
	reg [1:0] o6;					
	reg [1:0] o7;					
	reg [1:0] o8;					
	reg [1:0] o9;					
	reg [1:0] o10;					
	reg [1:0] o11;					
	reg [1:0] o12;					
	reg [1:0] o13;					
	reg [1:0] o14;					
	reg [1:0] o15;					
	reg [1:0] o16;					
	reg [1:0] o17;					
	reg [1:0] o18;					
	reg [1:0] o19;					
	reg [1:0] o20;					
	reg [1:0] o21;					
	reg [1:0] o22;					
	reg [1:0] o23;					
	reg [1:0] o24;					
	reg [1:0] o25;					
	reg [1:0] o26;					
	reg [1:0] o27;					
	reg [1:0] o28;					
	reg [1:0] o29;					
	reg [1:0] o30;					
	reg [1:0] o31;					
	always @(posedge clock)
	begin
		if(reset)
			o1 = 2'd0;
		else
			o1 = in;
	end
	always @(posedge clock)
	begin
		if(reset)
			o2 = 2'd0;
		else
			o2 = o1;
	end
	always @(posedge clock)
	begin
		if(reset)
			o3 = 2'd0;
		else
			o3 = o2;
	end
	always @(posedge clock)
	begin
		if(reset)
			o4 = 2'd0;
		else
			o4 = o3;
	end
	always @(posedge clock)
	begin
		if(reset)
			o5 = 2'd0;
		else
			o5 = o4;
	end
	always @(posedge clock)
	begin
		if(reset)
			o6 = 2'd0;
		else
			o6 = o5;
	end
	always @(posedge clock)
	begin
		if(reset)
			o7 = 2'd0;
		else
			o7 = o6;
	end
	always @(posedge clock)
	begin
		if(reset)
			o8 = 2'd0;
		else
			o8 = o7;
	end
	always @(posedge clock)
	begin
		if(reset)
			o9 = 2'd0;
		else
			o9 = o8;
	end
	always @(posedge clock)
	begin
		if(reset)
			o10 = 2'd0;
		else
			o10 = o9;
	end
	always @(posedge clock)
	begin
		if(reset)
			o11 = 2'd0;
		else
			o11 = o10;
	end
	always @(posedge clock)
	begin
		if(reset)
			o12 = 2'd0;
		else
			o12 = o11;
	end
	always @(posedge clock)
	begin
		if(reset)
			o13 = 2'd0;
		else
			o13 = o12;
	end
	always @(posedge clock)
	begin
		if(reset)
			o14 = 2'd0;
		else
			o14 = o13;
	end
	always @(posedge clock)
	begin
		if(reset)
			o15 = 2'd0;
		else
			o15 = o14;
	end
	always @(posedge clock)
	begin
		if(reset)
			o16 = 2'd0;
		else
			o16 = o15;
	end
	always @(posedge clock)
	begin
		if(reset)
			o17 = 2'd0;
		else
			o17 = o16;
	end
	always @(posedge clock)
	begin
		if(reset)
			o18 = 2'd0;
		else
			o18 = o17;
	end
	always @(posedge clock)
	begin
		if(reset)
			o19 = 2'd0;
		else
			o19 = o18;
	end
	always @(posedge clock)
	begin
		if(reset)
			o20 = 2'd0;
		else
			o20 = o19;
	end
	always @(posedge clock)
	begin
		if(reset)
			o21 = 2'd0;
		else
			o21 = o20;
	end
	always @(posedge clock)
	begin
		if(reset)
			o22 = 2'd0;
		else
			o22 = o21;
	end
	always @(posedge clock)
	begin
		if(reset)
			o23 = 2'd0;
		else
			o23 = o22;
	end
	always @(posedge clock)
	begin
		if(reset)
			o24 = 2'd0;
		else
			o24 = o23;
	end
	always @(posedge clock)
	begin
		if(reset)
			o25 = 2'd0;
		else
			o25 = o24;
	end
	always @(posedge clock)
	begin
		if(reset)
			o26 = 2'd0;
		else
			o26 = o25;
	end
	always @(posedge clock)
	begin
		if(reset)
			o27 = 2'd0;
		else
			o27 = o26;
	end
	always @(posedge clock)
	begin
		if(reset)
			o28 = 2'd0;
		else
			o28 = o27;
	end
	always @(posedge clock)
	begin
		if(reset)
			o29 = 2'd0;
		else
			o29 = o28;
	end
	always @(posedge clock)
	begin
		if(reset)
			o30 = 2'd0;
		else
			o30 = o29;
	end
	always @(posedge clock)
	begin
		if(reset)
			o31 = 2'd0;
		else
			o31 = o30;
	end
	always @(posedge clock)
	begin
		if(reset)
			out = 2'd0;
		else
			out = o31;
	end
endmodule
