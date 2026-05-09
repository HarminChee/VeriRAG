`timescale 1ns/1ns
`timescale 1ns/1ns
module clocks(
	input CLK_24M,
	input nRESETP,
	output CLK_12M,
	output reg CLK_68KCLK = 1'b0,	
	output CLK_68KCLKB,
	output CLK_6MB,
	output reg CLK_1MB
);
	reg [2:0] CLK_DIV;
	wire CLK_3M;

	// CLK_68KCLK: Clocked by primary input CLK_24M. Add primary input reset nRESETP.
	always @(posedge CLK_24M or negedge nRESETP) begin
		if (!nRESETP) begin
			CLK_68KCLK <= 1'b0; // Define reset state
		end else begin
			CLK_68KCLK <= ~CLK_68KCLK;
		end
	end

	assign CLK_68KCLKB = ~CLK_68KCLK;

	// CLK_DIV: Clocked by primary input CLK_24M, reset by primary input nRESETP. OK.
	always @(negedge CLK_24M or negedge nRESETP)
	begin
		if (!nRESETP)
			CLK_DIV <= 3'b100;
		else
			CLK_DIV <= CLK_DIV + 1'b1;
	end

	assign CLK_12M = CLK_DIV[0];
	assign CLK_6MB = ~CLK_DIV[1];
	assign CLK_3M = CLK_DIV[2];

	// CLK_1MB: Original was clocked by CLK_12M (derived from CLK_DIV FF). FFCKNP/CLKNPI violation.
	// Corrected: Clock by CLK_24M, reset by nRESETP. Implement equivalent logic.

	// Intermediate registers to sample CLK_DIV outputs synchronously with posedge CLK_24M
	reg CLK_12M_ff;
	reg CLK_3M_ff;
	reg CLK_12M_prev;

	always @(posedge CLK_24M or negedge nRESETP) begin
		if (!nRESETP) begin
			// Values corresponding to CLK_DIV reset state (100)
			CLK_12M_ff <= 1'b0; // CLK_DIV[0] is 0
			CLK_3M_ff  <= 1'b1; // CLK_DIV[2] is 1
			CLK_12M_prev <= 1'b0; // Previous value also reset
		end else begin
			// Sample current values from CLK_DIV (which changes on negedge)
			CLK_12M_ff <= CLK_DIV[0];
			CLK_3M_ff  <= CLK_DIV[2];
			// Store previous sampled value of CLK_12M
			CLK_12M_prev <= CLK_12M_ff; 
		end
	end

	// Update CLK_1MB based on detected rising edge of CLK_12M, clocked by CLK_24M
	always @(posedge CLK_24M or negedge nRESETP) begin
		 if (!nRESETP) begin
			 CLK_1MB <= 1'b0; // Define reset state for CLK_1MB
		 end else begin
			 // Detect rising edge: current CLK_12M_ff is high, previous CLK_12M_prev was low
			 if (CLK_12M_ff && !CLK_12M_prev) begin
				 // Capture the inverse of the current CLK_3M value
				 CLK_1MB <= ~CLK_3M_ff;
			 end
			 // else: CLK_1MB holds its value (implicit in reg type)
		 end
	end

endmodule