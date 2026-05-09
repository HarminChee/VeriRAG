`timescale 1ns/1ns

module clocks(
	input CLK_24M,
	input nRESETP,
	output wire CLK_12M,
	output reg CLK_68KCLK = 1'b0,
	output wire CLK_68KCLKB,
	output wire CLK_6MB,
	output reg CLK_1MB = 1'b0
);
	reg [2:0] CLK_DIV;
	wire CLK_3M; // Internal signal
	reg [3:0] cnt_1m; // Counter for 1MHz generation

	// Generates 12MHz clock (name CLK_68KCLK is misleading based on logic)
	// Added asynchronous reset
	always @(posedge CLK_24M or negedge nRESETP)
	begin
		if (!nRESETP)
			CLK_68KCLK <= 1'b0;
		else
			CLK_68KCLK <= ~CLK_68KCLK;
	end

	assign CLK_68KCLKB = ~CLK_68KCLK;

	// Counter clocked by negedge CLK_24M to generate divided clocks
	always @(negedge CLK_24M or negedge nRESETP)
	begin
		if (!nRESETP)
			CLK_DIV <= 3'b0; // Reset counter, starting point can be adjusted
		else
			CLK_DIV <= CLK_DIV + 1'b1;
	end

	// Clock assignments based on the counter
	assign CLK_12M = CLK_DIV[0]; // 24MHz / 2 = 12MHz
	assign CLK_6MB = ~CLK_DIV[1]; // Inverted 24MHz / 4 = 6MHz
	assign CLK_3M = CLK_DIV[2];  // 24MHz / 8 = 3MHz

	// Generate 1MHz clock from CLK_12M (Divide by 12)
	// Uses a counter that toggles CLK_1MB every 6 cycles of CLK_12M
	always @(posedge CLK_12M or negedge nRESETP) begin
	    if (!nRESETP) begin
	        cnt_1m <= 4'd0;
	        CLK_1MB <= 1'b0; // Reset CLK_1MB
	    end else begin
	        if (cnt_1m == 4'd5) begin // Counts 0..5 (6 cycles)
	            cnt_1m <= 4'd0;
	            CLK_1MB <= ~CLK_1MB; // Toggle every 6 cycles of 12MHz -> 1MHz
	        end else begin
	            cnt_1m <= cnt_1m + 1'b1;
	        end
	    end
	end

endmodule