module step_motor_driver(
// Qsys bus interface	
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
// step motor interface
		output AX,
		output AY,
		output BX,
		output BY,
		output AE,
		output BE,
		input  fault,
		input  otw
	);
	// Qsys bus controller
	reg        step;
	reg        step_d; // Added for edge detection
	wire       step_posedge; // Added for edge detection
	reg        forward_back;
	reg        on_off;
	reg [31:0] PWM_width_A;
	reg [31:0] PWM_width_B;
	reg [31:0] PWM_frequent;
	reg [31:0] read_data;
	assign	avs_ctrl_readdata = read_data;
	assign  step_posedge = step & ~step_d; // Added for edge detection

	always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
		if(rsi_MRST_reset) begin
			read_data <= 0;
			on_off <= 0;
			step <= 1'b0; // Initialize step
			forward_back <= 1'b0; // Initialize forward_back
			PWM_frequent <= 32'b0; // Initialize PWM_frequent
			PWM_width_A <= 32'b0; // Initialize PWM_width_A
			PWM_width_B <= 32'b0; // Initialize PWM_width_B
			step_d <= 1'b0; // Initialize step_d
		end
		else begin // Capture step_d synchronously
		    step_d <= step; 
		    if(avs_ctrl_write) 
		    begin
			    case(avs_ctrl_address)
				    0: begin
					    if(avs_ctrl_byteenable[3]) PWM_frequent[31:24] <= avs_ctrl_writedata[31:24];
					    if(avs_ctrl_byteenable[2]) PWM_frequent[23:16] <= avs_ctrl_writedata[23:16];
					    if(avs_ctrl_byteenable[1]) PWM_frequent[15:8] <= avs_ctrl_writedata[15:8];
					    if(avs_ctrl_byteenable[0]) PWM_frequent[7:0] <= avs_ctrl_writedata[7:0];
				    end
				    1: begin
					    if(avs_ctrl_byteenable[3]) PWM_width_A[31:24] <= avs_ctrl_writedata[31:24];
					    if(avs_ctrl_byteenable[2]) PWM_width_A[23:16] <= avs_ctrl_writedata[23:16];
					    if(avs_ctrl_byteenable[1]) PWM_width_A[15:8] <= avs_ctrl_writedata[15:8];
					    if(avs_ctrl_byteenable[0]) PWM_width_A[7:0] <= avs_ctrl_writedata[7:0];
				    end
				    2: begin
					    if(avs_ctrl_byteenable[3]) PWM_width_B[31:24] <= avs_ctrl_writedata[31:24];
					    if(avs_ctrl_byteenable[2]) PWM_width_B[23:16] <= avs_ctrl_writedata[23:16];
					    if(avs_ctrl_byteenable[1]) PWM_width_B[15:8] <= avs_ctrl_writedata[15:8];
					    if(avs_ctrl_byteenable[0]) PWM_width_B[7:0] <= avs_ctrl_writedata[7:0];
				    end
				    3: step <= avs_ctrl_writedata[0];
				    4: forward_back <= avs_ctrl_writedata[0];
				    5: on_off <= avs_ctrl_writedata[0];
				    default:;
			    endcase
	       end
		    else if(avs_ctrl_read)
		    begin
			    case(avs_ctrl_address)
				    0: read_data <= PWM_frequent;
				    1: read_data <= PWM_width_A;
				    2: read_data <= PWM_width_B;
				    3: read_data <= {31'b0,step};
				    4: read_data <= {31'b0,forward_back};
				    5: read_data <= {29'b0,otw,fault,on_off};
				    default: read_data <= 32'b0;
			    endcase
		    end
            else begin // Ensure step returns low if not actively written
                step <= 1'b0; 
            end
		end
	end
	
//PWM controller
	reg [31:0] PWM_A;
	reg [31:0] PWM_B;
	reg PWM_out_A;
	reg PWM_out_B;
	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if(rsi_PWMRST_reset) begin
			PWM_A <= 32'b0;
            PWM_out_A <= 1'b0; // Initialize output
        end
		else
		begin
			PWM_A <= PWM_A + PWM_frequent;
			PWM_out_A <=(PWM_A > PWM_width_A) ? 0:1;   
		end
	end
	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if(rsi_PWMRST_reset) begin
			PWM_B <= 32'b0;
            PWM_out_B <= 1'b0; // Initialize output
        end
		else
		begin
			PWM_B <= PWM_B + PWM_frequent;
			PWM_out_B <=(PWM_B > PWM_width_B) ? 0:1;   
		end
	end

	// step motor state
	reg [0:3] motor_state;
	// Changed sensitivity list from (posedge step or posedge rsi_MRST_reset)
	// to (posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	// Added enable condition 'if (step_posedge)'
	always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset) 
	begin
		if(rsi_MRST_reset)
			motor_state	<= 4'b 1000;
		else if (step_posedge) // Update only on the detected rising edge of step
		begin
			if(forward_back)
			case(motor_state)
				4'b1000: motor_state<= 4'b1010;
				4'b1010: motor_state<= 4'b0010;
				4'b0010: motor_state<= 4'b0110;
				4'b0110: motor_state<= 4'b0100;
				4'b0100: motor_state<= 4'b0101;
				4'b0101: motor_state<= 4'b0001;
				4'b0001: motor_state<= 4'b1001;
				4'b1001: motor_state<= 4'b1000;
                default: motor_state <= 4'b1000; // Ensure defined state
			endcase
			else
			case(motor_state)
                4'b1000: motor_state<= 4'b1001; // Corrected reverse sequence start
				4'b1001: motor_state<= 4'b0001;
				4'b0001: motor_state<= 4'b0101;
				4'b0101: motor_state<= 4'b0100;
				4'b0100: motor_state<= 4'b0110;
				4'b0110: motor_state<= 4'b0010;
				4'b0010: motor_state<= 4'b1010;
				4'b1010: motor_state<= 4'b1000;
                default: motor_state <= 4'b1000; // Ensure defined state
			endcase
		end
	end
	
	//output signal
	assign AE = !on_off;
	assign BE = !on_off;
	// Corrected output assignments to use PWM_out_B for B phase
	assign AX = !(motor_state[3] & PWM_out_A & on_off); 
	assign AY = !(motor_state[2] & PWM_out_A & on_off);
	assign BX = !(motor_state[1] & PWM_out_B & on_off); // Changed PWM_out_A to PWM_out_B
	assign BY = !(motor_state[0] & PWM_out_B & on_off); // Changed PWM_out_A to PWM_out_B
	
	// Assign default value to waitrequest (can be refined based on actual logic)
	assign avs_ctrl_waitrequest = 1'b0; 

endmodule