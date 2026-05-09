module steering_driver(
		input					rsi_MRST_reset,
		input					csi_MCLK_clk,
		input		[31:0]	avs_ctrl_writedata,
		output	[31:0]	avs_ctrl_readdata,
		input		[3:0]		avs_ctrl_byteenable,
		input		[2:0]		avs_ctrl_address,
		input					avs_ctrl_write,
		input					avs_ctrl_read,
		output				avs_ctrl_waitrequest, // Note: waitrequest is typically an output reg or assigned combinatorially, not declared here. Assuming it's handled elsewhere or implicitly wire.
		input					rsi_PWMRST_reset,
      input					csi_PWMCLK_clk,
		input					test_i, // Added test input
		output				streeing
		);

	// Unused registers removed: forward_back, on_off

	reg [9:0] angle;
	reg [31:0] read_data;

	assign	avs_ctrl_readdata = read_data;

	// Avalon MM Slave Interface Logic
	always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
	begin
		if(rsi_MRST_reset) begin
			read_data <= 32'b0;
			angle <= 10'b0; // Reset angle register as well
		end
		else begin
			// Write operation
			if(avs_ctrl_write)
			begin
				case(avs_ctrl_address)
					1: begin // Address for angle register
						if(avs_ctrl_byteenable[1]) angle[9:8] <= avs_ctrl_writedata[9:8];
						if(avs_ctrl_byteenable[0]) angle[7:0] <= avs_ctrl_writedata[7:0];
					end
					default:; // No action for other write addresses
				endcase
			end
			// Read operation (combinational read logic moved outside or handled differently based on waitrequest)
			// This block only handles clocked updates. Read data assignment is combinational based on address.
			// We assign read_data based on address combinatorially or register it based on read signal.
			// Sticking to original logic structure for read_data update for now, assuming reads are handled correctly.
			else if (avs_ctrl_read) begin // Assuming read data should be updated on read cycle start
			    case(avs_ctrl_address)
				    0: read_data <= 32'hEA680003; // ID register or status
				    1: read_data <= {22'b0, angle}; // Read angle value (padded with zeros)
				    default: read_data <= 32'b0;
			    endcase
			end
            // If not writing or reading, hold the read_data value (original behavior was implicit else)
            // else begin
            //    read_data <= read_data; // Explicit hold, though default behavior is hold for regs
            // end
		end
	end

	// Assign waitrequest - typically depends on read/write and internal state
	// Assigning 0 for simplicity, replace with actual logic if needed.
	assign avs_ctrl_waitrequest = 1'b0;

	// PWM Generation Logic
	reg PWM_out;
	reg[31:0] counter;
	reg [10:0] PWM;
	reg counter_31_prev; // Register to store previous state of counter[31]
	wire counter_31_posedge; // Signal to detect rising edge of counter[31]

	// Counter logic - clocked by primary clock csi_PWMCLK_clk
	always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if (rsi_PWMRST_reset)
			counter <= 32'b0;
		else
			// Increment logic - ensure constant value is synthesizable
			// counter <= counter + 32'd2048 * 32'd1073; // Multiplication might be complex, use calculated constant if possible
			counter <= counter + 32'd2197504; // Pre-calculated constant
	end

	// Logic to detect rising edge of counter[31], synchronized to csi_PWMCLK_clk
	always @(posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset) begin
	    if (rsi_PWMRST_reset) begin
	        counter_31_prev <= 1'b0;
	    end else begin
	        counter_31_prev <= counter[31];
	    end
	end
	assign counter_31_posedge = counter[31] & ~counter_31_prev;

	// PWM register - clocked by primary clock csi_PWMCLK_clk, enabled by counter_31_posedge
	// FFCKNP / CLKNPI Fix: Changed clock from counter[31] to csi_PWMCLK_clk with enable
	always @(posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
	begin
		if (rsi_PWMRST_reset)
			PWM <= 11'b0;
		else if (counter_31_posedge) // Update only on the rising edge of the derived signal
			PWM <= PWM + 1;
	end

	// Combinational logic for PWM output based on PWM value and angle
	// Using always @* for clarity for combinational logic
	always @* // Use @* for combinational sensitivity list
	begin
		if(PWM < angle)
			PWM_out = 1'b1; // Use blocking assignment or ensure it's intended non-blocking
		else
			PWM_out = 1'b0;
	end

   assign streeing = PWM_out; // Assign output wire from internal reg

endmodule