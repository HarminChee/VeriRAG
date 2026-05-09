module digits_corrected_clk(
	mclk,
	enable,
	values,
	seg,
	digit
);
input wire mclk;
input wire[3:0] enable;
input wire[15:0] values;
output reg[6:0] seg = 8'b1111111;
output reg[3:0] digit = 4'b1111;
reg[14:0] counter = 0;
reg[1:0] index;
wire clk1khz;
wire[3:0] number;

// Remove the internally generated clock and use mclk directly for the scan chain
assign clk1khz = counter[14];

// Use mclk to count and generate a divided clock signal
always @ (posedge mclk) begin: khz_counter
	if(counter == 24999) begin
		counter <= 0;
	end else begin
		counter <= counter + 1;
	end
end

assign number =
	(index == 0) ? values[3:0] :
	(index == 1) ? values[7:4] :
	(index == 2) ? values[11:8] :
	values[15:12];

always @ (posedge mclk) begin: seg_display
	if(counter == 24999) begin
		index <= index + 1;
		case(index)
			0 : digit = {3'b111, ~enable[0]};
			1 : digit = {2'b11, ~enable[1], 1'b1};
			2 : digit = {1'b1, ~enable[2], 2'b11};
			3 : digit = {~enable[3], 3'b111};
			default: digit = 4'b1111;
		endcase
		case(number)
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
end
endmodule