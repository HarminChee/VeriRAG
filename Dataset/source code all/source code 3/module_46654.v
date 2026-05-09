module conv_encoder (output [1:0] c, input b, input clk, input reset);
	reg [1:0] c;
	reg D_0, D_1;
	always @ (posedge clk)
	begin
		if (reset)
		begin
			D_0 <= 1'b0;
		end
		else
		begin
			D_0 <= b;
		end
	end
	always @ (posedge clk)
	begin
		if (reset)
		begin
			D_1 <= 1'b0;
		end
		else
		begin
			D_1 <= D_0;
		end
	end
	always @ (D_0 or D_1 or b)
	begin
		c[0]  <= b^D_0^D_1;
		c[1]  <= b^D_1;
	end 
endmodule
