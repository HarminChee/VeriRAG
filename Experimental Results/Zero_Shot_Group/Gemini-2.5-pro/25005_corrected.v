module step_motor_driver(
// Qsys bus interface
    input                   rsi_MRST_reset,
    input                   csi_MCLK_clk,
    input       [31:0]  avs_ctrl_writedata,
    output reg  [31:0]  avs_ctrl_readdata, // Made reg for assignment in always block
    input       [3:0]       avs_ctrl_byteenable,
    input       [2:0]       avs_ctrl_address,
    input                   avs_ctrl_write,
    input                   avs_ctrl_read,
    output                  avs_ctrl_waitrequest,

    input                   rsi_PWMRST_reset,
    input                   csi_PWMCLK_clk,
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
    reg        forward_back;
    reg        on_off;
    reg [31:0] PWM_width_A;
    reg [31:0] PWM_width_B;
    reg [31:0] PWM_frequent;
    reg        step_prev; // Previous state of step for edge detection

    // Assign waitrequest - assuming slave is always ready
    assign avs_ctrl_waitrequest = 1'b0;

    always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
    begin
        if(rsi_MRST_reset) begin
            avs_ctrl_readdata <= 32'b0; // Reset read data output
            on_off            <= 1'b0;
            PWM_frequent      <= 32'b0;
            PWM_width_A       <= 32'b0;
            PWM_width_B       <= 32'b0;
            step              <= 1'b0;
            forward_back      <= 1'b0;
            step_prev         <= 1'b0; // Reset previous step state
        end
        else begin
            // Capture previous step state
            step_prev <= step;

            // Handle write operations
            if(avs_ctrl_write)
            begin
                case(avs_ctrl_address)
                    3'd0: begin // PWM Frequency
                        if(avs_ctrl_byteenable[3]) PWM_frequent[31:24] <= avs_ctrl_writedata[31:24];
                        if(avs_ctrl_byteenable[2]) PWM_frequent[23:16] <= avs_ctrl_writedata[23:16];
                        if(avs_ctrl_byteenable[1]) PWM_frequent[15:8]  <= avs_ctrl_writedata[15:8];
                        if(avs_ctrl_byteenable[0]) PWM_frequent[7:0]   <= avs_ctrl_writedata[7:0];
                    end
                    3'd1: begin // PWM Width A
                        if(avs_ctrl_byteenable[3]) PWM_width_A[31:24] <= avs_ctrl_writedata[31:24];
                        if(avs_ctrl_byteenable[2]) PWM_width_A[23:16] <= avs_ctrl_writedata[23:16];
                        if(avs_ctrl_byteenable[1]) PWM_width_A[15:8]  <= avs_ctrl_writedata[15:8];
                        if(avs_ctrl_byteenable[0]) PWM_width_A[7:0]   <= avs_ctrl_writedata[7:0];
                    end
                    3'd2: begin // PWM Width B
                        if(avs_ctrl_byteenable[3]) PWM_width_B[31:24] <= avs_ctrl_writedata[31:24];
                        if(avs_ctrl_byteenable[2]) PWM_width_B[23:16] <= avs_ctrl_writedata[23:16];
                        if(avs_ctrl_byteenable[1]) PWM_width_B[15:8]  <= avs_ctrl_writedata[15:8];
                        if(avs_ctrl_byteenable[0]) PWM_width_B[7:0]   <= avs_ctrl_writedata[7:0];
                    end
                    3'd3: step         <= avs_ctrl_writedata[0]; // Step command
                    3'd4: forward_back <= avs_ctrl_writedata[0]; // Direction
                    3'd5: on_off       <= avs_ctrl_writedata[0]; // Enable
                    default: ; // Do nothing for unmapped addresses
                endcase
            end

            // Handle read operations - done combinatorially based on registered values
            // Read data muxing logic moved outside this block for clarity,
            // but could be kept here if preferred.
            // If kept here, use non-blocking assignments for read data register.
            // Example:
            // else if (avs_ctrl_read) begin
            //     case(avs_ctrl_address)
            //         3'd0: avs_ctrl_readdata <= PWM_frequent;
            //         ...
            //     endcase
            // end
            // else begin
            //     avs_ctrl_readdata <= avs_ctrl_readdata; // Hold value if no read/write
            // end
        end
    end

    // Combinational logic for Read Data based on current address
    // This ensures read data is available immediately when avs_ctrl_read is high.
    // Alternatively, register read data in the clocked block above for pipelined access.
    always @* begin // Use always @* for combinational logic
        case(avs_ctrl_address)
            3'd0: avs_ctrl_readdata = PWM_frequent;
            3'd1: avs_ctrl_readdata = PWM_width_A;
            3'd2: avs_ctrl_readdata = PWM_width_B;
            3'd3: avs_ctrl_readdata = {31'b0, step};
            3'd4: avs_ctrl_readdata = {31'b0, forward_back};
            3'd5: avs_ctrl_readdata = {29'b0, otw, fault, on_off}; // Include status inputs
            default: avs_ctrl_readdata = 32'b0; // Default for unmapped addresses
        endcase
    end


//PWM controller
    reg [31:0] PWM_A_counter; // Renamed to avoid conflict with output signal name convention
    reg [31:0] PWM_B_counter; // Renamed
    reg PWM_out_A;
    reg PWM_out_B;

    always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
    begin
        if(rsi_PWMRST_reset) begin
            PWM_A_counter <= 32'b0;
            PWM_out_A     <= 1'b0; // Defined reset state for output
        end
        else begin
            // Check for potential overflow if PWM_frequent is large
            if (PWM_A_counter > (32'hFFFFFFFF - PWM_frequent)) begin
                 PWM_A_counter <= PWM_A_counter + PWM_frequent; // Allow wrap around
            end else begin
                 PWM_A_counter <= PWM_A_counter + PWM_frequent;
            end
            // Compare based on registered PWM width
            PWM_out_A <= (PWM_A_counter < PWM_width_A); // Corrected comparison logic (active high PWM)
        end
    end

    always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
    begin
        if(rsi_PWMRST_reset) begin
            PWM_B_counter <= 32'b0;
            PWM_out_B     <= 1'b0; // Defined reset state for output
        end
        else begin
            // Check for potential overflow if PWM_frequent is large
             if (PWM_B_counter > (32'hFFFFFFFF - PWM_frequent)) begin
                 PWM_B_counter <= PWM_B_counter + PWM_frequent; // Allow wrap around
            end else begin
                 PWM_B_counter <= PWM_B_counter + PWM_frequent;
            end
            // Compare based on registered PWM width
            PWM_out_B <= (PWM_B_counter < PWM_width_B); // Corrected comparison logic (active high PWM)
        end
    end

    // step motor state
    reg [3:0] motor_state; // Standard declaration [MSB:LSB]

    // State machine update based on step edge detection, clocked by main clock
    always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset)
    begin
        if(rsi_MRST_reset) begin
            motor_state <= 4'b1000; // Initial state
        end
        else begin
            // Check for rising edge of step signal (synchronized to csi_MCLK_clk)
            if (step == 1'b1 && step_prev == 1'b0) begin
                if(forward_back) begin // Forward direction
                    case(motor_state)
                        4'b1000: motor_state <= 4'b1010;
                        4'b1010: motor_state <= 4'b0010;
                        4'b0010: motor_state <= 4'b0110;
                        4'b0110: motor_state <= 4'b0100;
                        4'b0100: motor_state <= 4'b0101;
                        4'b0101: motor_state <= 4'b0001;
                        4'b0001: motor_state <= 4'b1001;
                        4'b1001: motor_state <= 4'b1000;
                        default: motor_state <= 4'b1000; // Default back to known state
                    endcase
                end
                else begin // Backward direction
                    case(motor_state)
                        // Corrected backward sequence
                        4'b1000: motor_state <= 4'b1001;
                        4'b1001: motor_state <= 4'b0001;
                        4'b0001: motor_state <= 4'b0101;
                        4'b0101: motor_state <= 4'b0100;
                        4'b0100: motor_state <= 4'b0110;
                        4'b0110: motor_state <= 4'b0010;
                        4'b0010: motor_state <= 4'b1010;
                        4'b1010: motor_state <= 4'b1000;
                        default: motor_state <= 4'b1000; // Default back to known state
                    endcase
                end
            end
            // If no step edge, motor_state remains unchanged
        end
    end

    //output signal - Assuming active low outputs for typical drivers
    // Enable signals are often active low
    assign AE = !on_off; // Enable A when on_off is high
    assign BE = !on_off; // Enable B when on_off is high

    // Phase outputs depend on motor state, PWM, and enable
    // Corrected BX/BY to use PWM_out_B
    assign AX = !(motor_state[3] & PWM_out_A & on_off);
    assign AY = !(motor_state[2] & PWM_out_A & on_off);
    assign BX = !(motor_state[1] & PWM_out_B & on_off); // Use PWM_out_B
    assign BY = !(motor_state[0] & PWM_out_B & on_off); // Use PWM_out_B

endmodule