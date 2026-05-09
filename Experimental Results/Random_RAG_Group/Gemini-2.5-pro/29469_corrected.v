module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk,
	input wire test_i // Added test mode input
    );

    reg [15:0] clk_divider;
    reg [3:0] display_num;
    reg clk_divider_15_dly; // Register to detect rising edge of clk_divider[15]
    wire clk_enable;       // Clock enable signal

    // Clock divider register (clocked by primary clk, async reset by primary rst)
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 16'b0; // Corrected width
    	end else begin
    		clk_divider <= clk_divider + 16'b1; // Corrected width
    	end
    end

    // Register to delay clk_divider[15] for edge detection
    // (clocked by primary clk, async reset by primary rst)
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            clk_divider_15_dly <= 1'b0;
        end else begin
            clk_divider_15_dly <= clk_divider[15];
        end
    end

    // Generate clock enable on the rising edge of clk_divider[15]
    assign clk_enable = !clk_divider_15_dly && clk_divider[15];

    // Display logic registers (clocked by primary clk, async reset by primary rst, enabled by clk_enable or test_i)
    // Replaced posedge clk_divider[15] with posedge clk and enable logic
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1111;
    	// Update only when enabled (functional mode) or in test mode
    	end else if (clk_enable || test_i) begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    			default : begin // Handles initial state (4'b1111) and any unexpected states
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    		endcase
    	end
        // If not enabled and not in test mode, registers hold their values (implicit)
    end

    // Combinational logic for 7-segment display output
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;
			1 : display = 7'b1111001;
			2 : display = 7'b0100100;
			3 : display = 7'b0110000;
			4 : display = 7'b0011001;
			5 : display = 7'b0010010;
			6 : display = 7'b0000010;
			7 : display = 7'b1111000;
			8 : display = 7'b0000000;
			9 : display = 7'b0010000;
			default : display = 7'b1111111; // Off or error indication
    	endcase
    end
endmodule