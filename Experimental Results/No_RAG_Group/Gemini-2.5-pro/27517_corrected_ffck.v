`timescale 1ns / 1ps
module project2_corrected_ffc(
input [5:0] switches,
input [3:0] pushbtns,
input clk,
// DFT inputs - Scan enable, Scan input (optional, depends on scan implementation)
input scan_en,
// DFT output - Scan output (optional)

output [3:0] anodes,
output [6:0] cathodes,
output [7:0] led
);
reg [7:0] temp_led=8'b00000000;
reg [3:0] temp_anode = 4'b1111;
reg [6:0] temp_cathode=7'b1111111;
reg [6:0] ssd_1=7'b1111111;
reg [6:0] ssd_2=7'b1111111;
reg [6:0] ssd_3=7'b1111111;
reg [6:0] ssd_4=7'b1111111;
reg [6:0] final_ssd=7'b1111111;
integer firsttry=0;
integer secondtry=0;
integer counter=0;
integer ledcount=0;
integer temp,temp1;
integer pause_timer = 0;
reg [16:0] clk_count = 0; // Use reg with appropriate width
integer status = 0;
integer timer=0;
integer firstpress=0;

wire clk_enable;

// Clock divider logic - Generates a clock enable pulse
always @ (posedge clk)
begin
	if (clk_count == 100000) begin // Check if count reaches the limit
		clk_count <= 0; // Reset counter
	end else begin
		clk_count <= clk_count + 1; // Increment counter
	end
end

// Assign clock enable signal
assign clk_enable = (clk_count == 100000);

// Main logic clocked by primary clock 'clk' and enabled by 'clk_enable'
always @ (posedge clk) begin
	// DFT Scan Mux logic would typically be inserted here by synthesis tools
	// For example:
	// if (scan_en) begin
	//   counter <= scan_in_counter; // Assuming scan inputs for each FF
	//   temp_led <= scan_in_temp_led;
	//   ... etc for all registers ...
	// end else if (clk_enable) begin // Functional logic enabled by clk_enable

	// Functional logic runs only when clk_enable is high
	if (clk_enable) begin
		counter <= (counter+1)%4;
		if(switches[3:0]==4'b0000) begin temp_led <= 8'b00000000; temp_cathode <= 7'b1000000; end
		else if(switches[3:0]==4'b0001) begin temp_led <= 8'b00000001; temp_cathode <= 7'b1111001; end
		else if(switches[3:0]==4'b0010) begin temp_led <= 8'b00000010; temp_cathode <= 7'b0100100; end
		else if(switches[3:0]==4'b0011) begin temp_led <= 8'b00000011; temp_cathode <= 7'b0110000; end
		else if(switches[3:0]==4'b0100) begin temp_led <= 8'b00000100; temp_cathode <= 7'b0011001; end
		else if(switches[3:0]==4'b0101) begin temp_led <= 8'b00000101; temp_cathode <= 7'b0010010; end
		else if(switches[3:0]==4'b0110) begin temp_led <= 8'b00000110; temp_cathode <= 7'b0000010; end
		else if(switches[3:0]== 4'b0111) begin temp_led <= 8'b00000111; temp_cathode <= 7'b1111000; end
		else if(switches[3:0]== 4'b1000) begin temp_led <= 8'b00001000; temp_cathode <= 7'b0000000; end
		else if(switches[3:0]== 4'b1001) begin temp_led <= 8'b00001001; temp_cathode <= 7'b0010000; end
		else if(switches[3:0]== 4'b1010) begin temp_led <= 8'b00001010; temp_cathode <= 7'b0001000; end
		else if(switches[3:0]== 4'b1011) begin temp_led <= 8'b00001011; temp_cathode <= 7'b0000011; end
		else if(switches[3:0]== 4'b1100) begin temp_led <= 8'b00001100; temp_cathode <= 7'b1000110; end
		else if(switches[3:0]== 4'b1101) begin temp_led <= 8'b00001101; temp_cathode <= 7'b0100001; end
		else if(switches[3:0]== 4'b1110) begin temp_led <= 8'b00001110; temp_cathode <= 7'b0000110; end
		else if(switches[3:0]== 4'b1111) begin temp_led <= 8'b00001111; temp_cathode <= 7'b0001110; end
		else begin temp_led <= 8'b00000000; temp_cathode <= 7'b1111111; end

		// Using non-blocking assignments for potentially registered outputs of case
		case(pushbtns)
			4'b0001: begin ssd_1 <= temp_cathode; firstpress <= 1; end
			4'b0010: begin ssd_2 <= temp_cathode; firstpress <= 1; end
			4'b0100: begin ssd_3 <= temp_cathode; firstpress <= 1; end
			4'b1000: begin ssd_4 <= temp_cathode; firstpress <= 1; end
			default: firstpress <= firstpress; // Keep current value if no button pressed
		endcase

		if(firstpress==1)
			timer <= timer+1;
		else
			timer <= 0;

		// Use current value of counter for case selection
		case(counter)
			0: begin temp_anode <= 4'b0111; final_ssd <= ssd_1; end
			1: begin temp_anode <= 4'b1011; final_ssd <= ssd_2; end
			2: begin temp_anode <= 4'b1101; final_ssd <= ssd_3; end
			3: begin temp_anode <= 4'b1110; final_ssd <= ssd_4; end
			default: begin temp_anode <= 4'b1111; final_ssd <= 7'b1111111; end // Default assignment
		endcase

		if(status == 0)
		begin
			if(timer < 7500)
			begin
				// Edge detection logic needs careful implementation with non-blocking assignments
				// Assuming 'temp' is intended to capture the rising edge of switches[4]
				// This logic might need refinement for robust edge detection
				if(switches[4] == 1)
					temp <= 1;
				else if (temp == 1) // If switch was high and now is low
					temp <= 2;
				else
				    temp <= 0; // Reset otherwise

				if(temp==2) // Check if falling edge detected (temp goes 1 -> 2)
				begin
					if(ssd_1 == 7'b0010010 && ssd_2 == 7'b0000000 && ssd_3 == 7'b0100100 && ssd_4 == 7'b0010010)
					begin
						temp_led <= 8'b11111111;
						status <= 1;
						ledcount <= 0;
						pause_timer <= 0;
						firstpress <= 0;
						timer <= 0;
						temp <= 0;
						temp1 <= 0;
						firsttry <= 0;
						secondtry <= 0;
						temp_anode <= 4'b1111;
						temp_cathode <= 7'b1111111;
						ssd_1 <= 7'b1111111;
						ssd_2 <= 7'b1111111;
						ssd_3 <= 7'b1111111;
						ssd_4 <= 7'b1111111;
						final_ssd <= 7'b1111111;
					end
					else
					begin
						firstpress <= 0;
						temp <= 0;
						temp1 <= 0;
						status <= 0;
						pause_timer <= 0;
						timer <= 0;
						temp_anode <= 4'b1111;
						temp_cathode <= 7'b1111111;
						ssd_1 <= 7'b1111111;
						ssd_2 <= 7'b1111111;
						ssd_3 <= 7'b1111111;
						ssd_4 <= 7'b1111111;
						final_ssd <= 7'b1111111;
						if(firsttry==0)
						begin
							firsttry <= 1;
							secondtry <= 0;
						end
						else if(firsttry==1)
						begin
							secondtry <= 1;
							firsttry <= 2; // Assuming firsttry should go beyond 1
						end

						if(secondtry==1)
						begin
							status <= 2;
							firstpress <= 0;
							pause_timer <= 0;
							timer <= 0;
							temp <= 0;
							temp1 <= 0;
							firsttry <= 0;
							secondtry <= 0;
							temp_anode <= 4'b1111;
							temp_cathode <= 7'b1111111;
							ssd_1 <= 7'b1111111;
							ssd_2 <= 7'b1111111;
							ssd_3 <= 7'b1111111;
							ssd_4 <= 7'b1111111;
							final_ssd <= 7'b1111111;
						end
						else // This block seems to override the display based on counter
						begin
							ssd_1 <= 7'b1111111;
							ssd_2 <= 7'b1111111;
							ssd_3 <= 7'b1111111;
							ssd_4 <= 7'b1111111;
							case(counter) // Use current value of counter
								3: begin temp_anode <= 4'b0111; final_ssd <= 7'b1111111; end
								2: begin temp_anode <= 4'b1011; final_ssd <= 7'b1000110; end
								1: begin temp_anode <= 4'b1101; final_ssd <= 7'b1000000; end
								0: begin temp_anode <= 4'b1110; final_ssd <= 7'b1000111; end
								default: begin temp_anode <= 4'b1111; final_ssd <= 7'b1111111; end
							endcase
						end
					end
				end
				else // temp != 2 (falling edge not detected this cycle)
				begin
					if(firstpress==0) // If no button was pressed to update SSDs
					begin
						ssd_1 <= 7'b1111111;
						ssd_2 <= 7'b1111111;
						ssd_3 <= 7'b1111111;
						ssd_4 <= 7'b1111111;
						case(counter) // Use current value of counter
							3: begin temp_anode <= 4'b0111; final_ssd <= 7'b1111111; end
							2: begin temp_anode <= 4'b1011; final_ssd <= 7'b1000110; end
							1: begin temp_anode <= 4'b1101; final_ssd <= 7'b1000000; end
							0: begin temp_anode <= 4'b1110; final_ssd <= 7'b1000111; end
							default: begin temp_anode <= 4'b1111; final_ssd <= 7'b1111111; end
						endcase
					end
					// else: retain SSD values if a button was pressed (handled by pushbtns case)
                    // and update anode/final_ssd based on counter (handled by counter case)
				end
			end
			else // timer >= 7500
			begin
				status <= 2;
				firstpress <= 0;
				timer <= 0;
				temp <= 0;
				temp1 <= 0;
				pause_timer <= 0;
				firsttry <= 0;
				secondtry <= 0;
				temp_anode <= 4'b1111;
				temp_cathode <= 7'b1111111;
				ssd_1 <= 7'b1111111;
				ssd_2 <= 7'b1111111;
				ssd_3 <= 7'b1111111;
				ssd_4 <= 7'b1111111;
				final_ssd <= 7'b1111111;
			end
		end
		else if(status == 1)
		begin
			// Edge detection for switches[5]
			if(switches[5]==1)
					temp1 <= 1;
			else if (temp1 == 1) // If switch was high and now is low
					temp1 <= 2;
			else
				temp1 <= 0; // Reset otherwise

			if(temp1==2) // Falling edge detected
			begin
				timer <= 0;
				pause_timer <= 0;
				status <= 0;
				firstpress <= 0;
				temp <= 0;
				temp1 <= 0;
				firsttry <= 0;
				secondtry <= 0;
				temp_anode <= 4'b1111;
				temp_cathode <= 7'b1111111;
				ssd_1 <= 7'b1111111;
				ssd_2 <= 7'b1111111;
				ssd_3 <= 7'b1111111;
				ssd_4 <= 7'b1111111;
				final_ssd <= 7'b1111111;
			end
			else // No falling edge detected
			begin
				ssd_1 <= 7'b1111111; // Overwrite SSD values regardless of buttons
				ssd_2 <= 7'b1111111;
				ssd_3 <= 7'b1111111;
				ssd_4 <= 7'b1111111;
				case(counter) // Use current value of counter
					3: begin temp_anode <= 4'b0111; final_ssd <= 7'b1000110; end
					2: begin temp_anode <= 4'b1011; final_ssd <= 7'b1000111; end
					1: begin temp_anode <= 4'b1101; final_ssd <= 7'b0101011; end
					0: begin temp_anode <= 4'b1110; final_ssd <= 7'b1000001; end
					default: begin temp_anode <= 4'b1111; final_ssd <= 7'b1111111; end
				endcase
			end
		end
		else if(status == 2)
		begin
			if(pause_timer > 5000)
			begin
				timer <= 0;
				pause_timer <= 0;
				status <= 0;
				temp <= 0;
				temp1 <= 0;
				firstpress <= 0;
				firsttry <= 0;
				secondtry <= 0;
				temp_anode <= 4'b1111;
				temp_cathode <= 7'b1111111;
				ssd_1 <= 7'b1111111;
				ssd_2 <= 7'b1111111;
				ssd_3 <= 7'b1111111;
				ssd_4 <= 7'b1111111;
				final_ssd <= 7'b1111111;
			end
			else
			begin
				pause_timer <= pause_timer + 1;
				ssd_1 <= 7'b1111111; // Overwrite SSD values
				ssd_2 <= 7'b1111111;
				ssd_3 <= 7'b1111111;
				ssd_4 <= 7'b1111111;
				case(counter) // Use current value of counter
					3: begin temp_anode <= 4'b0111; final_ssd <= 7'b0010010;end
					2: begin temp_anode <= 4'b1011; final_ssd <= 7'b1000001;end
					1: begin temp_anode <= 4'b1101; final_ssd <= 7'b0001000;end
					0: begin temp_anode <= 4'b1110; final_ssd <= 7'b0001100;end
					default: begin temp_anode <= 4'b1111; final_ssd <= 7'b1111111; end
				endcase
			end
		end

		// LED count logic - seems independent of status?
		if(ledcount > 50)
		begin
			ledcount <= 0;
		end else begin
		    ledcount <= ledcount+1;
		end

		// Final LED update based on status
		if(status==1) // This overrides the temp_led calculated from switches
			temp_led <= 8'b11111111;
		// else: temp_led retains value set based on switches earlier in the block
	end // end if(clk_enable)
	// end // end else for scan_en
end // end always @ (posedge clk)

// Continuous assignments for outputs
assign led = temp_led;
assign cathodes = final_ssd;
assign anodes = temp_anode;

// DFT Scan Output logic would be assigned here
// assign scan_out = counter[0]; // Example: output LSB of counter

endmodule