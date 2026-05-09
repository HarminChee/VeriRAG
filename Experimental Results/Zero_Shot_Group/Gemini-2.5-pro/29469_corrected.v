module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk
    );

    reg [15:0] clk_divider;
    reg [3:0] display_num;
    reg clk_divider_15_q; // Previous state of clk_divider[15] for edge detection
    wire refresh_tick;

    // Clock Divider
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 16'b0;
    	end else begin
    		clk_divider <= clk_divider + 16'b1;
    	end
    end

    // Generate a refresh tick on the rising edge of clk_divider[15]
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            clk_divider_15_q <= 1'b0;
        end else begin
            clk_divider_15_q <= clk_divider[15];
        end
    end
    assign refresh_tick = (~clk_divider_15_q & clk_divider[15]); // Detect 0 -> 1 transition

    // Digit scanning and number selection logic
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1110; // Start with the first digit active
    	end else begin
            if (refresh_tick) begin // Update only when refresh_tick pulses
                case (digit)
                    4'b1110 : begin // Display digit 0 (nums[3:0])
                            display_num <= nums[3:0];
                            digit <= 4'b1101; // Activate next digit
                        end
                    4'b1101 : begin // Display digit 1 (nums[7:4])
                            display_num <= nums[7:4];
                            digit <= 4'b1011; // Activate next digit
                        end
                    4'b1011 : begin // Display digit 2 (nums[11:8])
                            display_num <= nums[11:8];
                            digit <= 4'b0111; // Activate next digit
                        end
                    4'b0111 : begin // Display digit 3 (nums[15:12])
                            display_num <= nums[15:12];
                            digit <= 4'b1110; // Activate first digit again
                        end
                    default : begin // Should not happen in normal operation, reset to known state
                            display_num <= nums[3:0];
                            digit <= 4'b1110;
                        end
                endcase
            end
    	end
    end

    // Combinational logic to decode the number to seven-segment display pattern
    always @ (*) begin
    	case (display_num)
            4'd0 : display = 7'b1000000; // 0 (gfedcba) -> Common Anode: 0000001, Common Cathode: 1000000
            4'd1 : display = 7'b1111001; // 1
            4'd2 : display = 7'b0100100; // 2
            4'd3 : display = 7'b0110000; // 3
            4'd4 : display = 7'b0011001; // 4
            4'd5 : display = 7'b0010010; // 5
            4'd6 : display = 7'b0000010; // 6
            4'd7 : display = 7'b1111000; // 7
            4'd8 : display = 7'b0000000; // 8
            4'd9 : display = 7'b0010000; // 9
            // Hex display (optional, can be added if needed)
            // 4'hA : display = 7'b0001000; // A
            // 4'hB : display = 7'b0000011; // b
            // 4'hC : display = 7'b1000110; // C
            // 4'hD : display = 7'b0100001; // d
            // 4'hE : display = 7'b0000110; // E
            // 4'hF : display = 7'b0001110; // F
            default : display = 7'b1111111; // Off or error indicator (all segments off for CA, on for CC)
    	endcase
    end

endmodule