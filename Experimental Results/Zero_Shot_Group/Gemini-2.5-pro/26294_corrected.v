module digits(
	mclk,
	enable,
	values,
	seg,
	digit
);
input wire mclk;
input wire[3:0] enable;
input wire[15:0] values;
output reg[6:0] seg = 7'b1111111; // Corrected width
output reg[3:0] digit = 4'b1111;

reg[14:0] counter = 15'd0;
reg clk1khz_src = 1'b0;
reg[1:0] index = 2'b00; // Initialized index
wire clk1khz;
wire[3:0] number;

// Note: Using BUFG on internally generated clock might be suboptimal for FPGA implementation.
// Consider using a clock enable signal instead if targeting FPGAs.
BUFG clk1khz_bufg(
	.I(clk1khz_src),
	.O(clk1khz)
);

assign number =
	(index == 2'b00) ? values[3:0] :
	(index == 2'b01) ? values[7:4] :
	(index == 2'b10) ? values[11:8] :
	values[15:12]; // Default case for index == 2'b11

always @ (posedge mclk) begin: khz_counter
	if(counter == 15'd24999) begin // Using decimal literal for clarity
		counter <= 15'd0;
		clk1khz_src <= ~clk1khz_src;
	end else begin
		counter <= counter + 1'b1;
	end
end

always @ (posedge clk1khz) begin: seg_display
	index <= index + 1'b1; // Increment index

	// Update digit select based on the *next* index value (which becomes current after clock edge)
	// Or more commonly, based on the *current* index value before incrementing.
	// The original logic used the index *before* incrementing, which is standard for muxed displays.
	// Let's stick to the original logic structure but ensure correct assignments.
	case(index) // Use index value *before* it gets incremented in this cycle
		2'b00 : digit <= {3'b111, ~enable[0]};
		2'b01 : digit <= {2'b11, ~enable[1], 1'b1};
		2'b10 : digit <= {1'b1, ~enable[2], 2'b11};
		2'b11 : digit <= {~enable[3], 3'b111};
		default: digit <= 4'b1111; // Should not happen with 2-bit index
	endcase

	// Update segment display based on the number corresponding to the *current* index
	case(number) // number is combinatorially derived from the current index
		4'h0 : seg <= ~(7'b0111111); // 0
		4'h1 : seg <= ~(7'b0000110); // 1
		4'h2 : seg <= ~(7'b1011011); // 2
		4'h3 : seg <= ~(7'b1001111); // 3
		4'h4 : seg <= ~(7'b1100110); // 4
		4'h5 : seg <= ~(7'b1101101); // 5
		4'h6 : seg <= ~(7'b1111101); // 6
		4'h7 : seg <= ~(7'b0000111); // 7
		4'h8 : seg <= ~(7'b1111111); // 8
		4'h9 : seg <= ~(7'b1101111); // 9
		4'hA : seg <= ~(7'b1110111); // A
		4'hB : seg <= ~(7'b1111100); // b
		4'hC : seg <= ~(7'b0111001); // C
		4'hD : seg <= ~(7'b1011110); // d
		4'hE : seg <= ~(7'b1111001); // E
		4'hF : seg <= ~(7'b1110001); // F
		default : seg <= ~(7'b0000000); // Blank or error indicator
	endcase
end

endmodule