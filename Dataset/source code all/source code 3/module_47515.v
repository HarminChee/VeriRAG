module pipeline_buffer (in,out,clock,reset);
	output out;			
	input in;			
	input clock;		
	input reset;		
	reg out;
	reg o1;						
	reg o2;						
	reg o3;						
	reg o4;						
	reg o5;						
	reg o6;						
	reg o7;						
	reg o8;						
	reg o9;						
	reg o10;					
	reg o11;					
	reg o12;					
	reg o13;					
	reg o14;					
	reg o15;					
	reg o16;					
	reg o17;					
	reg o18;					
	reg o19;					
	reg o20;					
	reg o21;					
	reg o22;					
	reg o23;					
	reg o24;					
	reg o25;					
	reg o26;					
	reg o27;					
	reg o28;					
	reg o29;					
	reg o30;					
	reg o31;					
	always @(posedge clock)
	begin
		if(reset)
			o1 = 1'd0;
		else
			o1 = in;
	end
	always @(posedge clock)
	begin
		if(reset)
			o2 = 1'd0;
		else
			o2 = o1;
	end
	always @(posedge clock)
	begin
		if(reset)
			o3 = 1'd0;
		else
			o3 = o2;
	end
	always @(posedge clock)
	begin
		if(reset)
			o4 = 1'd0;
		else
			o4 = o3;
	end
	always @(posedge clock)
	begin
		if(reset)
			o5 = 1'd0;
		else
			o5 = o4;
	end
	always @(posedge clock)
	begin
		if(reset)
			o6 = 1'd0;
		else
			o6 = o5;
	end
	always @(posedge clock)
	begin
		if(reset)
			o7 = 1'd0;
		else
			o7 = o6;
	end
	always @(posedge clock)
	begin
		if(reset)
			o8 = 1'd0;
		else
			o8 = o7;
	end
	always @(posedge clock)
	begin
		if(reset)
			o9 = 1'd0;
		else
			o9 = o8;
	end
	always @(posedge clock)
	begin
		if(reset)
			o10 = 1'd0;
		else
			o10 = o9;
	end
	always @(posedge clock)
	begin
		if(reset)
			o11 = 1'd0;
		else
			o11 = o10;
	end
	always @(posedge clock)
	begin
		if(reset)
			o12 = 1'd0;
		else
			o12 = o11;
	end
	always @(posedge clock)
	begin
		if(reset)
			o13 = 1'd0;
		else
			o13 = o12;
	end
	always @(posedge clock)
	begin
		if(reset)
			o14 = 1'd0;
		else
			o14 = o13;
	end
	always @(posedge clock)
	begin
		if(reset)
			o15 = 1'd0;
		else
			o15 = o14;
	end
	always @(posedge clock)
	begin
		if(reset)
			o16 = 1'd0;
		else
			o16 = o15;
	end
	always @(posedge clock)
	begin
		if(reset)
			o17 = 1'd0;
		else
			o17 = o16;
	end
	always @(posedge clock)
	begin
		if(reset)
			o18 = 1'd0;
		else
			o18 = o17;
	end
	always @(posedge clock)
	begin
		if(reset)
			o19 = 1'd0;
		else
			o19 = o18;
	end
	always @(posedge clock)
	begin
		if(reset)
			o20 = 1'd0;
		else
			o20 = o19;
	end
	always @(posedge clock)
	begin
		if(reset)
			o21 = 1'd0;
		else
			o21 = o20;
	end
	always @(posedge clock)
	begin
		if(reset)
			o22 = 1'd0;
		else
			o22 = o21;
	end
	always @(posedge clock)
	begin
		if(reset)
			o23 = 1'd0;
		else
			o23 = o22;
	end
	always @(posedge clock)
	begin
		if(reset)
			o24 = 1'd0;
		else
			o24 = o23;
	end
	always @(posedge clock)
	begin
		if(reset)
			o25 = 1'd0;
		else
			o25 = o24;
	end
	always @(posedge clock)
	begin
		if(reset)
			o26 = 1'd0;
		else
			o26 = o25;
	end
	always @(posedge clock)
	begin
		if(reset)
			o27 = 1'd0;
		else
			o27 = o26;
	end
	always @(posedge clock)
	begin
		if(reset)
			o28 = 1'd0;
		else
			o28 = o27;
	end
	always @(posedge clock)
	begin
		if(reset)
			o29 = 1'd0;
		else
			o29 = o28;
	end
	always @(posedge clock)
	begin
		if(reset)
			o30 = 1'd0;
		else
			o30 = o29;
	end
	always @(posedge clock)
	begin
		if(reset)
			o31 = 1'd0;
		else
			o31 = o30;
	end
	always @(posedge clock)
	begin
		if(reset)
			out = 1'd0;
		else
			out = o31;
	end
endmodule
