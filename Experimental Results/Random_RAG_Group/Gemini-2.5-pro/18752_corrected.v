module subdivision_step_motor_driver (
		input					rsi_MRST_reset,
		input					csi_MCLK_clk,
		input		[31:0]	avs_ctrl_writedata,
		output	[31:0]	avs_ctrl_readdata,
		input		[3:0]		avs_ctrl_byteenable,
		input		[2:0]		avs_ctrl_address,
		input					avs_ctrl_write,
		input					avs_ctrl_read,
		output				avs_ctrl_waitrequest,
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
	reg        forward_back;
	reg        on_off;
	reg [31:0] PWM_width_A;
	reg [31:0] PWM_width_B;
	reg [31:0] PWM_frequent;
	reg [31:0] read_data;
	assign	avs_ctrl_readdata = read_data;
	assign  avs_ctrl_waitrequest = 1'b0; // Assign default value

	always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
		if(rsi_MRST_reset) begin
			read_data <= 0;
			on_off <= 0;
			PWM_frequent <= 0; // Initialize all registers on reset
			PWM_width_A <= 0;
			PWM_width_B <= 0;
			step <= 0;
			forward_back <= 0;
		end
		else begin // Combine write and read logic for clarity
		    // Default assignments to avoid latch inference for control signals
		    step <= step;
		    forward_back <= forward_back;
		    on_off <= on_off;
		    PWM_frequent <= PWM_frequent;
		    PWM_width_A <= PWM_width_A;
		    PWM_width_B <= PWM_width_B;
		    read_data <= read_data; // Default assignment

			if(avs_ctrl_write)
			begin
				case(avs_ctrl_address)
					3'd0: begin
						if(avs_ctrl_byteenable[3]) PWM_frequent[31:24] <= avs_ctrl_writedata[31:24];
						if(avs_ctrl_byteenable[2]) PWM_frequent[23:16] <= avs_ctrl_writedata[23:16];
						if(avs_ctrl_byteenable[1]) PWM_frequent[15:8] <= avs_ctrl_writedata[15:8];
						if(avs_ctrl_byteenable[0]) PWM_frequent[7:0] <= avs_ctrl_writedata[7:0];
					end
					3'd1: begin
						if(avs_ctrl_byteenable[3]) PWM_width_A[31:24] <= avs_ctrl_writedata[31:24];
						if(avs_ctrl_byteenable[2]) PWM_width_A[23:16] <= avs_ctrl_writedata[23:16];
						if(avs_ctrl_byteenable[1]) PWM_width_A[15:8] <= avs_ctrl_writedata[15:8];
						if(avs_ctrl_byteenable[0]) PWM_width_A[7:0] <= avs_ctrl_writedata[7:0];
					end
					3'd2: begin
						if(avs_ctrl_byteenable[3]) PWM_width_B[31:24] <= avs_ctrl_writedata[31:24];
						if(avs_ctrl_byteenable[2]) PWM_width_B[23:16] <= avs_ctrl_writedata[23:16];
						if(avs_ctrl_byteenable[1]) PWM_width_B[15:8] <= avs_ctrl_writedata[15:8];
						if(avs_ctrl_byteenable[0]) PWM_width_B[7:0] <= avs_ctrl_writedata[7:0];
					end
					3'd3: step <= avs_ctrl_writedata[0];
					3'd4: forward_back <= avs_ctrl_writedata[0];
					3'd5: on_off <= avs_ctrl_writedata[0];
					default:;
				endcase
			end
			else if(avs_ctrl_read) // Read logic should not affect state registers, only read_data
			begin
				case(avs_ctrl_address)
					3'd0: read_data <= PWM_frequent;
					3'd1: read_data <= PWM_width_A;
					3'd2: read_data <= PWM_width_B;
					3'd3: read_data <= {31'b0,step};
					3'd4: read_data <= {31'b0,forward_back};
					3'd5: read_data <= {31'b0,on_off}; // Read on_off state
					default: read_data <= 32'b0;
				endcase
			end
	   end
	end

	reg [31:0] PWM_A;
	reg [31:0] PWM_B;
	reg PWM_out_A;
	reg PWM_out_B;

	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if(rsi_PWMRST_reset) begin
			PWM_A <= 32'b0;
			PWM_out_A <= 1'b0; // Initialize output on reset
		end
		else
		begin
			PWM_A <= PWM_A + PWM_frequent;
			PWM_out_A <= (PWM_A < PWM_width_A); // Correct comparison logic? Assumed active high pulse
		end
	end

	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if(rsi_PWMRST_reset) begin
			PWM_B <= 32'b0;
			PWM_out_B <= 1'b0; // Initialize output on reset
		end
		else
		begin
			PWM_B <= PWM_B + PWM_frequent;
			PWM_out_B <= (PWM_B < PWM_width_B); // Correct comparison logic? Assumed active high pulse
		end
	end

	reg [0:3] motor_state;
	reg step_prev; // Register to detect rising edge of step

	// Edge detection logic for step signal, clocked by csi_MCLK_clk
	always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
	    if(rsi_MRST_reset)
	        step_prev <= 1'b0;
	    else
	        step_prev <= step;
	end

	wire step_posedge = step && !step_prev; // Detect rising edge based on csi_MCLK_clk domain

	// Motor state machine clocked by csi_MCLK_clk, enabled by step edge
	always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
		if(rsi_MRST_reset)
			motor_state	<= 4'b1001;
		else if (step_posedge) // Update motor state only on the rising edge of 'step'
		begin
			if(forward_back) begin
			   case(motor_state)
			   	4'b1001: motor_state <= 4'b1010;
			   	4'b1010: motor_state <= 4'b0110;
			   	4'b0110: motor_state <= 4'b0101;
			   	4'b0101: motor_state <= 4'b1001;
			   	default: motor_state <= 4'b1001; // Define default state transition
			   endcase
			end
			else begin
			   case(motor_state)
			   	4'b1010: motor_state <= 4'b1001;
			   	4'b0110: motor_state <= 4'b1010;
			   	4'b0101: motor_state <= 4'b0110;
			   	4'b1001: motor_state <= 4'b0101;
			   	default: motor_state <= 4'b1001; // Define default state transition
			   endcase
			end
		end
		// else motor_state holds its value
	end

	reg ax_comb, ay_comb, bx_comb, by_comb; // Use intermediate combinational signals

	// Combinational logic for motor outputs based on state and PWM
	always @ (*)
	begin
	    // Default assignments
	    ax_comb = 1'b0;
	    ay_comb = 1'b0;
	    bx_comb = 1'b0;
	    by_comb = 1'b0;
		 case(motor_state)
			  4'b1001: begin ax_comb = PWM_out_A; ay_comb = 1'b0;      bx_comb = 1'b0;      by_comb = PWM_out_B; end
			  4'b1010: begin ax_comb = PWM_out_A; ay_comb = 1'b0;      bx_comb = PWM_out_B; by_comb = 1'b0;      end
			  4'b0110: begin ax_comb = 1'b0;      ay_comb = PWM_out_A; bx_comb = PWM_out_B; by_comb = 1'b0;      end
			  4'b0101: begin ax_comb = 1'b0;      ay_comb = PWM_out_A; bx_comb = 1'b0;      by_comb = PWM_out_B; end
			  default: begin ax_comb = 1'b0;      ay_comb = 1'b0;      bx_comb = 1'b0;      by_comb = 1'b0;      end // Prevent latches
		 endcase
	end

	// Output assignments
	assign AE = !on_off;
	assign BE = !on_off;
	// Assign outputs based on combinational logic
	assign AX = !ax_comb;
	assign AY = !ay_comb;
	assign BX = !bx_comb;
	assign BY =	!by_comb;

endmodule