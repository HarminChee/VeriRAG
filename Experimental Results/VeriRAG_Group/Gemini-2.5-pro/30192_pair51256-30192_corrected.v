`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ps2_receiver(
    input wire clk, clr, // Functional clock and reset
    input wire test_i, scan_clk, // DFT inputs
	input wire ps2c, ps2d,
	output wire [15:0] xkey
	);

	wire dft_clk; // Multiplexed clock for DFT

	reg PS2Cf, PS2Df;
	reg PS2Cf_d; // Previous value of PS2Cf for edge detection
	reg [ 7:0] ps2c_filter, ps2d_filter;
	reg [10:0] shift1, shift2;

    assign dft_clk = test_i ? scan_clk : clk;
	assign xkey = {shift2[8:1], shift1[8:1]};

    // Filter logic and generation of PS2Cf/PS2Df
	always @ (posedge dft_clk or posedge clr)
	begin
		if (clr == 1)
		begin
			ps2c_filter <= 8'b0;
			ps2d_filter <= 8'b0;
			PS2Cf       <= 1'b1;
			PS2Df       <= 1'b1;
            PS2Cf_d     <= 1'b1; // Reset previous value too
		end
		else
		begin
			ps2c_filter <= {ps2c, ps2c_filter[7:1]};
			ps2d_filter <= {ps2d, ps2d_filter[7:1]};
            PS2Cf_d     <= PS2Cf; // Store previous value before updating PS2Cf

			if (ps2c_filter == 8'b1111_1111)
				PS2Cf <= 1'b1;
			else if (ps2c_filter == 8'b0000_0000)
				PS2Cf <= 1'b0;
            // else PS2Cf retains its value

			if (ps2d_filter == 8'b1111_1111)
				PS2Df <= 1'b1;
			else if (ps2d_filter == 8'b0000_0000)
				PS2Df <= 1'b0;
            // else PS2Df retains its value
		end
	end

    // Shift register logic, clocked by dft_clk, enabled by falling edge of PS2Cf
	always @ (posedge dft_clk or posedge clr)
	begin
		if (clr == 1)
		begin
			shift1 <= 11'b0;
			shift2 <= 11'b1; // Keep original reset value
		end
        // Enable condition: falling edge detected (PS2Cf_d was high, PS2Cf is low)
		else if (PS2Cf_d == 1'b1 && PS2Cf == 1'b0)
		begin
			shift1 <= {PS2Df, shift1[10:1]};
			shift2 <= {shift1[0], shift2[10:1]};
		end
        // else: registers retain their values
	end
endmodule