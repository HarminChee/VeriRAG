// 1_corrected_ffc.v
module subdivision_step_motor_driver (
		input					rsi_MRST_reset,
		input					csi_MCLK_clk,
		input		[31:0]	avs_ctrl_writedata,
		output	[31:0]	avs_ctrl_readdata,
		input		[3:0]		avs_ctrl_byteenable,
		input		[2:0]		avs_ctrl_address,
		input					avs_ctrl_write,
		input					avs_ctrl_read,
		output				avs_ctrl_waitrequest, // Note: waitrequest logic is missing, assuming tied low for now
		input					rsi_PWMRST_reset,
		input					csi_PWMCLK_clk,
		output AX,
		output AY,
		output BX,
		output BY,
		output AE,
		output BE
	);

	reg        step;
	reg        step_d; // Previous value of step for edge detection
	reg        forward_back;
	reg        on_off;
	reg [31:0] PWM_width_A;
	reg [31:0] PWM_width_B;
	reg [31:0] PWM_frequent;
	reg [31:0] read_data;

	// Avalon Interface Logic
	assign	avs_ctrl_readdata = read_data;
	assign  avs_ctrl_waitrequest = 1'b0; // Example: Tie waitrequest low

	always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
		if(rsi_MRST_reset) begin
			read_data <= 32'b0;
			on_off <= 1'b0;
			step <= 1'b0;
			step_d <= 1'b0; // Reset previous step
			forward_back <= 1'b0;
			PWM_frequent <= 32'b0;
			PWM_width_A <= 32'b0;
			PWM_width_B <= 32'b0;
		end
		else begin
		   // Capture previous step value
		   step_d <= step;

			if(avs_ctrl_write)
			begin
				case(avs_ctrl_address)
					3'd0: begin
						if(avs_ctrl_byteenable[3]) PWM_frequent[31:24] <= avs_ctrl_writedata[31:24];
						if(avs_ctrl_byteenable[2]) PWM_frequent[23:16] <= avs_ctrl_writedata[23:16];
						if(avs_ctrl_byteenable[1]) PWM_frequent[15:8]  <= avs_ctrl_writedata[15:8];
						if(avs_ctrl_byteenable[0]) PWM_frequent[7:0]   <= avs_ctrl_writedata[7:0];
					end
					3'd1: begin
						if(avs_ctrl_byteenable[3]) PWM_width_A[31:24] <= avs_ctrl_writedata[31:24];
						if(avs_ctrl_byteenable[2]) PWM_width_A[23:16] <= avs_ctrl_writedata[23:16];
						if(avs_ctrl_byteenable[1]) PWM_width_A[15:8]  <= avs_ctrl_writedata[15:8];
						if(avs_ctrl_byteenable[0]) PWM_width_A[7:0]   <= avs_ctrl_writedata[7:0];
					end
					3'd2: begin
						if(avs_ctrl_byteenable[3]) PWM_width_B[31:24] <= avs_ctrl_writedata[31:24];
						if(avs_ctrl_byteenable[2]) PWM_width_B[23:16] <= avs_ctrl_writedata[23:16];
						if(avs_ctrl_byteenable[1]) PWM_width_B[15:8]  <= avs_ctrl_writedata[15:8];
						if(avs_ctrl_byteenable[0]) PWM_width_B[7:0]   <= avs_ctrl_writedata[7:0];
					end
					3'd3: step <= avs_ctrl_writedata[0];
					3'd4: forward_back <= avs_ctrl_writedata[0];
					3'd5: on_off <= avs_ctrl_writedata[0];
					default: ;
				endcase
			end
			else if(avs_ctrl_read)
			begin
				case(avs_ctrl_address)
					3'd0: read_data <= PWM_frequent;
					3'd1: read_data <= PWM_width_A;
					3'd2: read_data <= PWM_width_B;
					3'd3: read_data <= {31'b0, step};
					3'd4: read_data <= {31'b0, forward_back};
               3'd5: read_data <= {31'b0, on_off}; // Readback for on_off
					default: read_data <= 32'b0;
				endcase
			end
		end
	end

	// PWM Generation Logic
	reg [31:0] PWM_A;
	reg [31:0] PWM_B;
	reg PWM_out_A;
	reg PWM_out_B;

	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if(rsi_PWMRST_reset) begin
			PWM_A <= 32'b0;
			PWM_out_A <= 1'b0;
		end
		else begin
			PWM_A <= PWM_A + PWM_frequent; // Potential overflow ignored as in original
			PWM_out_A <= (PWM_A > PWM_width_A) ? 1'b0 : 1'b1; // Corrected logic? Check original intent. Assumes 1=on when below width.
		end
	end

	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if(rsi_PWMRST_reset) begin
			PWM_B <= 32'b0;
			PWM_out_B <= 1'b0;
		end
		else begin
			PWM_B <= PWM_B + PWM_frequent; // Potential overflow ignored as in original
			PWM_out_B <= (PWM_B > PWM_width_B) ? 1'b0 : 1'b1; // Corrected logic? Check original intent. Assumes 1=on when below width.
		end
	end

	// Motor State Machine Logic
	reg [3:0] motor_state; // State register: AX+, AX-, AY+, AY- (example encoding)

	// *** FFCKNP FIX: Clock motor_state with primary clock csi_MCLK_clk ***
	// *** Use rising edge of 'step' as an enable signal ***
	always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
		if(rsi_MRST_reset)
			motor_state	<= 4'b1001; // Initial state
		else begin
			// Update motor_state only on the detected rising edge of step
			if (step == 1'b1 && step_d == 1'b0) begin
				if(forward_back) begin // Forward direction
					case(motor_state)
						4'b1001: motor_state <= 4'b1010; // AX+, BY+ -> AX+, BX+
						4'b1010: motor_state <= 4'b0110; // AX+, BX+ -> AY+, BX+
						4'b0110: motor_state <= 4'b0101; // AY+, BX+ -> AY+, BY+
						4'b0101: motor_state <= 4'b1001; // AY+, BY+ -> AX+, BY+
						default: motor_state <= 4'b1001; // Default to initial state
					endcase
				end
				else begin // Backward direction
					case(motor_state)
						4'b1001: motor_state <= 4'b0101; // AX+, BY+ -> AY+, BY+
						4'b0101: motor_state <= 4'b0110; // AY+, BY+ -> AY+, BX+
						4'b0110: motor_state <= 4'b1010; // AY+, BX+ -> AX+, BX+
						4'b1010: motor_state <= 4'b1001; // AX+, BX+ -> AX+, BY+
						default: motor_state <= 4'b1001; // Default to initial state
					endcase
				end
			end
			// else: motor_state holds its value if no step rising edge detected
		end
	end

	// Output Driver Logic (Combinational)
	// Corrected sensitivity list and assignment type
	reg ax, ay, bx, by;
	always @ (*) // Sensitive to all inputs used within the block
	begin
		// Default assignments to avoid latches
		ax = 1'b0;
		ay = 1'b0;
		bx = 1'b0;
		by = 1'b0;
		case(motor_state)
			4'b1001: begin ax = PWM_out_A; ay = 1'b0;      bx = 1'b0;      by = PWM_out_B; end // AX+, BY+
			4'b1010: begin ax = PWM_out_A; ay = 1'b0;      bx = PWM_out_B; by = 1'b0;      end // AX+, BX+
			4'b0110: begin ax = 1'b0;      ay = PWM_out_A; bx = PWM_out_B; by = 1'b0;      end // AY+, BX+
			4'b0101: begin ax = 1'b0;      ay = PWM_out_A; bx = 1'b0;      by = PWM_out_B; end // AY+, BY+
			default: ; // Keep default assignments
		endcase
	end

	// Output Assignments
	assign AE = !on_off; // Enable A (active low?)
	assign BE = !on_off; // Enable B (active low?)

	// Assuming output drivers invert the signal
	assign AX = !ax;
	assign AY = !ay;
	assign BX = !bx;
	assign BY = !by;

endmodule