`timescale 1ns / 1ps
module LCD_dis_corrected_ffc (
	input clk,
	input[127:0] num,
	input reset,
	output reg lcd_rs,
	output lcd_rw,
	output reg lcd_e,
	output reg[3:0] lcd_d,
	output flash_ce
);

	assign flash_ce = 1;
	assign lcd_rw = 0;

	reg [19:0] delay_count;
	reg [19:0] num_count;
	wire[7:0] ascii;
	wire[3:0] hex;
	reg[4:0] dis_count;
	reg [5:0] state;
	// Removed state_change reg

	assign ascii = (hex[3] & (hex[2] | hex[1])) ? (8'h37 + {4'h0, hex}) : {4'h3, hex};
	assign hex =
	    {4{(dis_count == 5'h1F)}} & num[3:0] |
	    {4{(dis_count == 5'h1E)}} & num[7:4] |
	    {4{(dis_count == 5'h1D)}} & num[11:8] |
	    {4{(dis_count == 5'h1C)}} & num[15:12] |
	    {4{(dis_count == 5'h1B)}} & num[19:16] |
	    {4{(dis_count == 5'h1A)}} & num[23:20] |
	    {4{(dis_count == 5'h19)}} & num[27:24] |
	    {4{(dis_count == 5'h18)}} & num[31:28] |
	    {4{(dis_count == 5'h17)}} & num[35:32] |
	    {4{(dis_count == 5'h16)}} & num[39:36] |
	    {4{(dis_count == 5'h15)}} & num[43:40] |
	    {4{(dis_count == 5'h14)}} & num[47:44] |
	    {4{(dis_count == 5'h13)}} & num[51:48] |
	    {4{(dis_count == 5'h12)}} & num[55:52] |
	    {4{(dis_count == 5'h11)}} & num[59:56] |
	    {4{(dis_count == 5'h10)}} & num[63:60] |
	    {4{(dis_count == 5'hF)}} & num[67:64] |
	    {4{(dis_count == 5'hE)}} & num[71:68] |
	    {4{(dis_count == 5'hD)}} & num[75:72] |
	    {4{(dis_count == 5'hC)}} & num[79:76] |
	    {4{(dis_count == 5'hB)}} & num[83:80] |
	    {4{(dis_count == 5'hA)}} & num[87:84] |
	    {4{(dis_count == 5'h9)}} & num[91:88] |
	    {4{(dis_count == 5'h8)}} & num[95:92] |
	    {4{(dis_count == 5'h7)}} & num[99:96] |
	    {4{(dis_count == 5'h6)}} & num[103:100] |
	    {4{(dis_count == 5'h5)}} & num[107:104] |
	    {4{(dis_count == 5'h4)}} & num[111:108] |
	    {4{(dis_count == 5'h3)}} & num[115:112] |
	    {4{(dis_count == 5'h2)}} & num[119:116] |
	    {4{(dis_count == 5'h1)}} & num[123:120] |
	    {4{(dis_count == 5'h0)}} & num[127:124] ;

	parameter state1 = 6'b000001;
	parameter state2 = 6'b000010;
	parameter state3 = 6'b000011;
	parameter state4 = 6'b000100;
	parameter state5 = 6'b000101;
	parameter state6 = 6'b000110;
	parameter state7 = 6'b000111;
	parameter state8 = 6'b001000;
	parameter state9 = 6'b001001;
	parameter state10 = 6'b001010;
	parameter state11 = 6'b001011;
	parameter state12 = 6'b001100;
	parameter state13 = 6'b001101;
	parameter state14 = 6'b001110;
	parameter state15 = 6'b001111;
	parameter state16 = 6'b010000;
	parameter state17 = 6'b010001;
	parameter state18 = 6'b010010;
	parameter state19 = 6'b010011;
	parameter state20 = 6'b010100;
	parameter state21 = 6'b010101;
	parameter state22 = 6'b010110;
	parameter state23 = 6'b010111;
	parameter state24 = 6'b011000;
	parameter state25 = 6'b011001;
	parameter state26 = 6'b011010;
	parameter state27 = 6'b011011;
	parameter state28 = 6'b011100;
	parameter state29 = 6'b011101;
	parameter state30 = 6'b011110;
	parameter state31 = 6'b011111;
	parameter state32 = 6'b100000;
	parameter state33 = 6'b100001;
	parameter state34 = 6'b100010;
	parameter state35 = 6'b100011;
	parameter state36 = 6'b100100;
	parameter state37 = 6'b100101;
	parameter state38 = 6'b100110;
	parameter state39 = 6'b100111;
	parameter state40 = 6'b101000;
	parameter state41 = 6'b101001;
	parameter state42 = 6'b101010;
	parameter state43 = 6'b101011;
	parameter state44 = 6'b101100;
	parameter state45 = 6'b101101;
	parameter state46 = 6'b101110;
	// Removed state47 to state59 as they were unused duplicates in the original state machine logic

	// Combined state machine and delay logic into a single always block clocked by primary clk
	always @(posedge clk or posedge reset) begin
	    if (reset) begin
	        // Reset values for all registers
	        delay_count <= 20'd1;
	        state <= state1;
	        num_count <= 20'd750000; // Initial delay
	        lcd_rs <= 1'b0;
	        lcd_e <= 1'b0;
	        lcd_d <= 4'h0;
	        dis_count <= 5'h0;
	    end else begin
	        // Increment delay counter by default
	        delay_count <= delay_count + 1'b1;

	        // Check if the delay for the current state is complete
	        // Use num_count directly (avoiding potential issues with num_count-1 comparison at 0)
	        // Check if delay_count has reached the target count for the current state
	        if (delay_count == num_count) begin // Changed comparison from num_count-1 to num_count
	            // Reset delay counter for the next state
	            delay_count <= 20'd1; // Start count from 1 for next delay

	            // State transition and output logic
	            case(state)
	                state1:begin
	                    state <= state2;
	                    num_count <= 20'd4;
	                    lcd_rs <= 1'b0; // Set at transition
	                    lcd_e <= 1'b0;  // Set at transition
	                    lcd_d <= 4'h3;  // Set at transition
	                end
	                state2:begin
	                    state <= state3;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state3:begin
	                    state <= state4;
	                    num_count <= 20'd205000;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state4:begin
	                    state <= state5;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h3;  // Update D
	                end
	                state5:begin
	                    state <= state6;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state6:begin
	                    state <= state7;
	                    num_count <= 20'd5000;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state7:begin
	                    state <= state8;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h2;  // Update D
	                end
	                state8:begin
	                    state <= state9;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state9:begin
	                    state <= state10;
	                    num_count <= 20'd4000;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state10:begin
	                    state <= state11;
	                    num_count <= 20'd4;
	                    lcd_rs <= 0;    // Update RS
	                    lcd_d <= 4'h2;  // Update D
	                end
	                state11:begin
	                    state <= state12;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state12:begin
	                    state <= state13;
	                    num_count <= 20'd80;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state13:begin
	                    state <= state14;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h8;  // Update D
	                end
	                state14:begin
	                    state <= state15;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state15:begin
	                    state <= state16;
	                    num_count <= 20'd4000;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state16:begin
	                    state <= state17;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h0;  // Update D
	                end
	                state17:begin
	                    state <= state18;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state18:begin
	                    state <= state19;
	                    num_count <= 20'd80;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state19:begin
	                    state <= state20;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h6;  // Update D
	                end
	                state20:begin
	                    state <= state21;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state21:begin
	                    state <= state22;
	                    num_count <= 20'd4000;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state22:begin
	                    state <= state23;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h0;  // Update D
	                end
	                state23:begin
	                    state <= state24;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state24:begin
	                    state <= state25;
	                    num_count <= 20'd80;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state25:begin
	                    state <= state26;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'hc;  // Update D
	                end
	                state26:begin
	                    state <= state27;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state27:begin
	                    state <= state28;
	                    num_count <= 20'd4000;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state28:begin
	                    state <= state29;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h0;  // Update D
	                end
	                state29:begin
	                    state <= state30;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state30:begin
	                    state <= state31;
	                    num_count <= 20'd80;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state31:begin
	                    state <= state32;
	                    num_count <= 20'd4;
	                    lcd_d <= 4'h1;  // Update D
	                end
	                state32:begin
	                    state <= state33;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1;  // Update E
	                end
	                state33:begin
	                    state <= state34;
	                    num_count <= 20'd2000;
	                    lcd_e <= 1'b0;  // Update E
	                end
	                state34:begin // This state seems to be just a delay
	                    state <= state35;
	                    num_count <= 20'd82000;
	                    // Outputs remain unchanged
	                end
	                state35:begin // Set DDRAM address
	                    state <= state36;
	                    num_count <= 20'd4;
	                    lcd_rs <= 1'b0; // Command mode
	                    lcd_e <= 1'b0;
	                    if (dis_count[4]) begin // Check if second line (0x40 offset)
	                        lcd_d <= 4'hC; // 0xC0 command high nibble
	                    end
	                    else begin
	                        lcd_d <= 4'h8; // 0x80 command high nibble
	                    end
	                end
	                state36:begin
	                    state <= state37;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1; // Pulse E
	                end
	                state37:begin
	                    state <= state38;
	                    num_count <= 20'd80;
	                    lcd_e <= 1'b0; // End E pulse
	                end
	                state38:begin
	                    state <= state39;
	                    num_count <= 20'd4;
	                    lcd_d <= dis_count[3:0]; // Low nibble of address (0x00-0x0F or 0x40-0x4F)
	                end
	                state39:begin
	                    state <= state40;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1; // Pulse E
	                end
	                state40:begin
	                    state <= state41;
	                    num_count <= 20'd4000;
	                    lcd_e <= 1'b0; // End E pulse
	                end
	                state41:begin // Write character data - High nibble
	                    state <= state42;
	                    num_count <= 20'd4;
	                    lcd_rs <= 1'b1; // Data mode
	                    lcd_d <= ascii[7:4];
	                    // lcd_e remains low
	                end
	                state42:begin
	                    state <= state43;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1; // Pulse E
	                end
	                state43:begin
	                    state <= state44;
	                    num_count <= 20'd80;
	                    lcd_e <= 1'b0; // End E pulse
	                end
	                state44:begin // Write character data - Low nibble
	                    state <= state45;
	                    num_count <= 20'd4;
	                    lcd_d <= ascii[3:0];
	                    // lcd_rs remains high, lcd_e remains low
	                end
	                state45:begin
	                    state <= state46;
	                    num_count <= 20'd12;
	                    lcd_e <= 1'b1; // Pulse E
	                end
	                state46:begin // Finish write, update counter, loop back
	                    state <= state35; // Go back to set address for next char
	                    num_count <= 20'd2000;
	                    lcd_e <= 1'b0; // End E pulse
	                    dis_count <= dis_count + 1; // Increment character counter
	                    // lcd_rs remains high, but will be set low in state35
	                end
	                default:begin // Should not happen, but reset if it does
	                    state <= state1;
	                    num_count <= 20'd750000; // Reset to initial delay
	                    lcd_rs <= 1'b0;
	                    lcd_e <= 1'b0;
	                    lcd_d <= 4'h0;
	                    dis_count <= 5'h0;
	                end
	            endcase
	        end
	        // If delay is not complete, registers hold their values from the previous clock cycle
	        // unless explicitly assigned within the 'else' part of the 'if (delay_count == num_count)'
	        // (which is only delay_count <= delay_count + 1'b1; in this structure).
	    end
	end

endmodule