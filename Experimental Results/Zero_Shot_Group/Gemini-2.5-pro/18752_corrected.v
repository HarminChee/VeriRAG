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
	assign  avs_ctrl_waitrequest = 1'b0; // Added assignment

	always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
		if(rsi_MRST_reset) begin
			read_data <= 32'b0;
			on_off <= 1'b0;
			step <= 1'b0;             // Added reset
			forward_back <= 1'b0;     // Added reset
			PWM_width_A <= 32'b0;     // Added reset
			PWM_width_B <= 32'b0;     // Added reset
			PWM_frequent <= 32'b0;    // Added reset
		end
		else if(avs_ctrl_write)
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
				3'd3: step         <= avs_ctrl_writedata[0];
				3'd4: forward_back <= avs_ctrl_writedata[0];
				3'd5: on_off       <= avs_ctrl_writedata[0];
				default:;
			endcase
	   end
		else if(avs_ctrl_read)
		begin
			case(avs_ctrl_address)
				3'd0: read_data <= PWM_frequent;
				3'd1: read_data <= PWM_width_A;
				3'd2: read_data <= PWM_width_B;
				3'd3: read_data <= {31'b0,step};
				3'd4: read_data <= {31'b0,forward_back};
				3'd5: read_data <= {31'b0,on_off}; // Added read case for on_off
				default: read_data <= 32'b0;
			endcase
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
			PWM_out_A <= 1'b0; // Ensure output is reset
		end
		else begin
			PWM_A <= PWM_A + PWM_frequent;
			PWM_out_A <= (PWM_A < PWM_width_A); // Corrected comparison for typical PWM
		end
	end

	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if(rsi_PWMRST_reset) begin
			PWM_B <= 32'b0;
			PWM_out_B <= 1'b0; // Ensure output is reset
		end
		else begin
			PWM_B <= PWM_B + PWM_frequent;
			PWM_out_B <= (PWM_B < PWM_width_B); // Corrected comparison for typical PWM
		end
	end

	reg [3:0] motor_state; // Corrected indexing [3:0]

	// Consider changing sensitivity list if 'step' is not a clock
	// always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	// if(step_event) begin ... end
	always @ (posedge step or posedge rsi_MRST_reset) // Kept original sensitivity list per request, but it's risky design
	begin
		if(rsi_MRST_reset)
			motor_state	<= 4'b1001;
		else
		begin
			if(forward_back) begin
				case(motor_state)
					4'b1001: motor_state <= 4'b1010;
					4'b1010: motor_state <= 4'b0110;
					4'b0110: motor_state <= 4'b0101;
					4'b0101: motor_state <= 4'b1001;
					default: motor_state <= 4'b1001; // Added default
				endcase
			end
			else begin
				case(motor_state)
					4'b1010: motor_state <= 4'b1001;
					4'b0110: motor_state <= 4'b1010;
					4'b0101: motor_state <= 4'b0110;
					4'b1001: motor_state <= 4'b0101;
					default: motor_state <= 4'b1001; // Added default
				endcase
			end
		end
	end

	reg ax, ay, bx, by;

	// Changed to combinational block with '*' sensitivity list and blocking assignments '='
	always @ (*)
	begin
		// Default assignments to avoid latches
		ax = 1'b0;
		ay = 1'b0;
		bx = 1'b0;
		by = 1'b0;
		case(motor_state)
			4'b1001: begin ax = PWM_out_A; ay = 1'b0;     bx = 1'b0;     by = PWM_out_B; end
			4'b1010: begin ax = PWM_out_A; ay = 1'b0;     bx = PWM_out_B; by = 1'b0;     end
			4'b0110: begin ax = 1'b0;     ay = PWM_out_A; bx = PWM_out_B; by = 1'b0;     end
			4'b0101: begin ax = 1'b0;     ay = PWM_out_A; bx = 1'b0;     by = PWM_out_B; end
			default: begin ax = 1'b0;     ay = 1'b0;     bx = 1'b0;     by = 1'b0;     end // Explicit default
		endcase
	end

	assign AE = !on_off;
	assign BE = !on_off;
	assign AX = !ax;
	assign AY = !ay;
	assign BX = !bx;
	assign BY =	!by;

endmodule