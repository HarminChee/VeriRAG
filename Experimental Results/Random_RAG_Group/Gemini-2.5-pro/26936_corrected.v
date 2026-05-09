`timescale 1ns/1ns
`timescale 1ns/1ns
module ym2i2s(
    input test_i, // Added test input for DFT
	input nRESET,
	input CLK_I2S,
	input [5:0] ANA,
	input SH1, SH2, OP0, PHI_M, // Unused inputs retained
	output I2S_MCLK, I2S_BICK, I2S_SDTI, I2S_LRCK
);
	wire [23:0] I2S_SAMPLE;
	reg [23:0] I2S_SR;
	reg [3:0] SR_CNT;
	reg [7:0] CLKDIV;

	// Assignments based on primary inputs or registers clocked by primary inputs
	assign I2S_SAMPLE = {18'b0, ANA}; // Corrected concatenation
	assign I2S_MCLK = CLK_I2S;
	assign I2S_LRCK = CLKDIV[7]; // Derived from FF clocked by primary clock
	assign I2S_BICK = CLKDIV[4]; // Derived from FF clocked by primary clock
	assign I2S_SDTI = I2S_SR[23]; // Derived from FF clocked by primary clock

    // Generate enable signal corresponding to the original negedge I2S_BICK condition
    // negedge I2S_BICK happens when CLKDIV[4] goes 1->0.
    // Since CLKDIV increments, this happens when CLKDIV[4:0] is 5'b11111.
    wire sr_enable = (CLKDIV[4:0] == 5'b11111);

	// Clock divider logic - synchronous to CLK_I2S, reset by nRESET
	always @(posedge CLK_I2S or negedge nRESET)
	begin
        if (!nRESET) begin
            CLKDIV <= 8'b0;
        end else begin
		    CLKDIV <= CLKDIV + 1'b1;
        end
	end

    // Shift register logic - synchronous to CLK_I2S, enabled by sr_enable, reset by nRESET
    // Replicates original logic using synchronous enable instead of gated clock
	always @(posedge CLK_I2S or negedge nRESET)
	begin
		if (!nRESET) begin
			SR_CNT <= 4'b0;
            I2S_SR <= 24'b0;
        end else begin
            if (sr_enable) begin // Only update on the cycle corresponding to original negedge I2S_BICK
			    // Original logic: load when SR_CNT is 0, shift and increment otherwise.
                // This interpretation increments SR_CNT only when shifting.
                if (SR_CNT == 4'b0)
			    begin
				    I2S_SR <= I2S_SAMPLE; // Load sample when counter is 0
                    // SR_CNT remains 0 based on literal interpretation of original code
			    end
			    else // If SR_CNT != 0
			    begin
				    I2S_SR <= {I2S_SR[22:0], 1'b0}; // Shift
				    SR_CNT <= SR_CNT + 1'b1;       // Increment counter (will wrap around)
			    end
		    end // end if(sr_enable)
            // If sr_enable is low, registers hold their values (implicit)
        end // end else (!nRESET)
	end // end always

endmodule