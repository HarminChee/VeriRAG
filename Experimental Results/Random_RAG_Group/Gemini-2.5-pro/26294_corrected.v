module digits(
	input wire test_i, // Added DFT input
	input wire mclk,
	input wire[3:0] enable,
	input wire[15:0] values,
	output reg[6:0] seg = 7'b1111111, // Corrected width
	output reg[3:0] digit = 4'b1111
);
reg[14:0] counter = 0;
reg clk1khz_src = 0;
reg[1:0] index;
wire clk1khz;
wire[3:0] number;

// DFT Clock Mux
wire dft_clk;
assign dft_clk = test_i ? mclk : clk1khz;

BUFG clk1khz_bufg(
	.I(clk1khz_src),
	.O(clk1khz)
);
assign number =
	(index == 0) ? values[3:0] :
	(index == 1) ? values[7:4] :
	(index == 2) ? values[11:8] :
	values[15:12];

always @ (posedge mclk) begin: khz_counter
	if(counter == 24999) begin
		counter <= 0;
		clk1khz_src <= ~clk1khz_src;
	end else begin
		counter <= counter + 1;
	end
end

// Changed clock source to dft_clk
always @ (posedge dft_clk) begin: seg_display
	index <= index + 1;
	case(index) // Use current index value to determine next state based on original logic intent
		2'b00 : digit <= {3'b111, ~enable[0]};
		2'b01 : digit <= {2'b11, ~enable[1], 1'b1};
		2'b10 : digit <= {1'b1, ~enable[2], 2'b11};
		2'b11 : digit <= {~enable[3], 3'b111};
		default: digit <= 4'b1111; // Should not be reached for 2-bit index
	endcase
	case(number) // Uses number derived from current index
		'h0 : seg <= ~(7'b0111111);
		'h1 : seg <= ~(7'b0000110);
		'h2 : seg <= ~(7'b1011011);
		'h3 : seg <= ~(7'b1001111);
		'h4 : seg <= ~(7'b1100110);
		'h5 : seg <= ~(7'b1101101);
		'h6 : seg <= ~(7'b1111101);
		'h7 : seg <= ~(7'b0000111);
		'h8 : seg <= ~(7'b1111111);
		'h9 : seg <= ~(7'b1101111);
		'hA : seg <= ~(7'b1110111);
		'hB : seg <= ~(7'b1111100);
		'hC : seg <= ~(7'b0111001);
		'hD : seg <= ~(7'b1011110);
		'hE : seg <= ~(7'b1111001);
		'hF : seg <= ~(7'b1110001);
		default : seg <= ~(7'b0000000);
	endcase
end
endmodule