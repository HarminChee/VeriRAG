module osc2
	(
		input wire iClock,
		input wire iReset,
		output wire oOut131k,
		output wire oOut262k
	);
	reg [4:0] 	rOscCounter; 
	always @ (posedge iClock) begin
		if (iReset) begin
			rOscCounter <= 0;
		end
		else begin
			rOscCounter <= rOscCounter+1;
		end
	end
	assign oOut131k = rOscCounter[4];
	assign oOut262k = rOscCounter[3];
endmodule
