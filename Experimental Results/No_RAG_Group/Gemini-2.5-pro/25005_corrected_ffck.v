module step_motor_driver_corrected_ffc (
// Qsys bus interface
    input                   rsi_MRST_reset,
    input                   csi_MCLK_clk,
    input       [31:0]  avs_ctrl_writedata,
    output reg  [31:0]  avs_ctrl_readdata, // Made reg as it's assigned in always block
    input       [3:0]       avs_ctrl_byteenable,
    input       [2:0]       avs_ctrl_address,
    input                   avs_ctrl_write,
    input                   avs_ctrl_read,
    output                  avs_ctrl_waitrequest, // Note: This output is not driven

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

    // Qsys bus controller Registers
    reg        step_cmd; // Renamed from 'step' to avoid confusion with event signal
    reg        step_cmd_dly; // Delayed version for edge detection
    reg        forward_back;
    reg        on_off;
    reg [31:0] PWM_width_A;
    reg [31:0] PWM_width_B;
    reg [31:0] PWM_frequent;
    reg [31:0] read_data_internal; // Internal register for read data

    // Intermediate signal for step event
    wire       step_event;

    // Assign internal read data to output port
    assign avs_ctrl_readdata = read_data_internal;

    // Qsys bus controller Logic
    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
    begin
        if (rsi_MRST_reset) begin
            read_data_internal <= 32'b0;
            on_off             <= 1'b0;
            step_cmd           <= 1'b0;
            step_cmd_dly       <= 1'b0;
            forward_back       <= 1'b0;
            PWM_width_A        <= 32'b0;
            PWM_width_B        <= 32'b0;
            PWM_frequent       <= 32'b0;
        end
        else begin
            // Capture delayed version of step command for edge detection
            step_cmd_dly <= step_cmd;

            if (avs_ctrl_write) begin
                case (avs_ctrl_address)
                    3'd0: begin
                        if (avs_ctrl_byteenable[3]) PWM_frequent[31:24] <= avs_ctrl_writedata[31:24];
                        if (avs_ctrl_byteenable[2]) PWM_frequent[23:16] <= avs_ctrl_writedata[23:16];
                        if (avs_ctrl_byteenable[1]) PWM_frequent[15:8]  <= avs_ctrl_writedata[15:8];
                        if (avs_ctrl_byteenable[0]) PWM_frequent[7:0]   <= avs_ctrl_writedata[7:0];
                    end
                    3'd1: begin
                        if (avs_ctrl_byteenable[3]) PWM_width_A[31:24] <= avs_ctrl_writedata[31:24];
                        if (avs_ctrl_byteenable[2]) PWM_width_A[23:16] <= avs_ctrl_writedata[23:16];
                        if (avs_ctrl_byteenable[1]) PWM_width_A[15:8]  <= avs_ctrl_writedata[15:8];
                        if (avs_ctrl_byteenable[0]) PWM_width_A[7:0]   <= avs_ctrl_writedata[7:0];
                    end
                    3'd2: begin
                        if (avs_ctrl_byteenable[3]) PWM_width_B[31:24] <= avs_ctrl_writedata[31:24];
                        if (avs_ctrl_byteenable[2]) PWM_width_B[23:16] <= avs_ctrl_writedata[23:16];
                        if (avs_ctrl_byteenable[1]) PWM_width_B[15:8]  <= avs_ctrl_writedata[15:8];
                        if (avs_ctrl_byteenable[0]) PWM_width_B[7:0]   <= avs_ctrl_writedata[7:0];
                    end
                    3'd3: step_cmd       <= avs_ctrl_writedata[0];
                    3'd4: forward_back   <= avs_ctrl_writedata[0];
                    3'd5: on_off         <= avs_ctrl_writedata[0];
                    default: ;
                endcase
                // Reset step_cmd after one cycle if it was set by write?
                // Assuming step_cmd stays high until written low or reset.
                // If it should be a pulse, add: else if (avs_ctrl_address != 3'd3) step_cmd <= 1'b0;
                // Or handle pulse generation differently. Current edge detect handles level change.
            end
            else if (avs_ctrl_read) begin
                case (avs_ctrl_address)
                    3'd0: read_data_internal <= PWM_frequent;
                    3'd1: read_data_internal <= PWM_width_A;
                    3'd2: read_data_internal <= PWM_width_B;
                    3'd3: read_data_internal <= {31'b0, step_cmd};
                    3'd4: read_data_internal <= {31'b0, forward_back};
                    3'd5: read_data_internal <= {29'b0, otw, fault, on_off};
                    default: read_data_internal <= 32'b0;
                endcase
            end
            // If not writing to step_cmd, keep its value (implicit)
            // If not reading, keep read_data_internal value (implicit)
        end
    end

    // Detect rising edge of step_cmd signal (synchronized to csi_MCLK_clk)
    assign step_event = step_cmd & ~step_cmd_dly;

    // PWM controller Registers
    reg [31:0] PWM_A;
    reg [31:0] PWM_B;
    reg PWM_out_A;
    reg PWM_out_B;

    // PWM controller Logic A
    always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
    begin
        if (rsi_PWMRST_reset) begin
            PWM_A     <= 32'b0;
            PWM_out_A <= 1'b0; // Initialize output
        end
        else begin
            PWM_A <= PWM_A + PWM_frequent; // Assumes PWM_frequent is step size, wraps implicitly
            PWM_out_A <= (PWM_A < PWM_width_A); // Corrected PWM logic: High while counter < width
        end
    end

    // PWM controller Logic B
    always @ (posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
    begin
        if (rsi_PWMRST_reset) begin
            PWM_B     <= 32'b0;
            PWM_out_B <= 1'b0; // Initialize output
        end
        else begin
            PWM_B <= PWM_B + PWM_frequent; // Assumes PWM_frequent is step size, wraps implicitly
            PWM_out_B <= (PWM_B < PWM_width_B); // Corrected PWM logic: High while counter < width
        end
    end

    // Step motor state Register
    reg [0:3] motor_state;

    // Step motor state Logic - Clocked by primary clock csi_MCLK_clk, enabled by step_event
    always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset) // Changed clock to primary csi_MCLK_clk
    begin
        if (rsi_MRST_reset)
            motor_state <= 4'b1000; // MSB first index [0]..[3] -> 4'b1000
        else if (step_event) begin // Update only on detected step event
            if (forward_back) begin
                case (motor_state) // Assuming MSB is index 0: [0]=1,[1]=0,[2]=0,[3]=0
                    4'b1000: motor_state <= 4'b1010; // A -> AB
                    4'b1010: motor_state <= 4'b0010; // AB -> B
                    4'b0010: motor_state <= 4'b0110; // B -> BC
                    4'b0110: motor_state <= 4'b0100; // BC -> C
                    4'b0100: motor_state <= 4'b0101; // C -> CD
                    4'b0101: motor_state <= 4'b0001; // CD -> D
                    4'b0001: motor_state <= 4'b1001; // D -> DA
                    4'b1001: motor_state <= 4'b1000; // DA -> A
                    default: motor_state <= 4'b1000; // Default to known state
                endcase
            end
            else begin // backward
                case (motor_state)
                    4'b1000: motor_state <= 4'b1001; // A -> AD
                    4'b1001: motor_state <= 4'b0001; // AD -> D
                    4'b0001: motor_state <= 4'b0101; // D -> DC
                    4'b0101: motor_state <= 4'b0100; // DC -> C
                    4'b0100: motor_state <= 4'b0110; // C -> CB
                    4'b0110: motor_state <= 4'b0010; // CB -> B
                    4'b0010: motor_state <= 4'b1010; // B -> BA
                    4'b1010: motor_state <= 4'b1000; // BA -> A
                    default: motor_state <= 4'b1000; // Default to known state
                endcase
            end
        end
        // else: motor_state holds its value if no reset and no step_event
    end

    // Output signal assignments
    assign AE = !on_off; // Enable A (active low?)
    assign BE = !on_off; // Enable B (active low?)

    // Corrected output assignments using motor_state bits and respective PWM outputs
    // Assuming motor_state[0]..[3] maps to A, B, C, D phases or similar
    // Assuming active low outputs for H-bridge control (common)
    // Mapping based on original: [3]->AX, [2]->AY, [1]->BX, [0]->BY
    // Using state bits: A=motor_state[0], B=motor_state[1], C=motor_state[2], D=motor_state[3] (if MSB is index 0)
    // Or: A=motor_state[3], B=motor_state[2], C=motor_state[1], D=motor_state[0] (if LSB is index 0)
    // Let's assume LSB index 0: motor_state[3]=A, motor_state[2]=C, motor_state[1]=B, motor_state[0]=D

    assign AX = !(motor_state[3] & PWM_out_A & on_off); // Phase A+
    assign AY = !(motor_state[2] & PWM_out_A & on_off); // Phase A- (or C?) - Check motor wiring
    assign BX = !(motor_state[1] & PWM_out_B & on_off); // Phase B+ - Corrected to use PWM_out_B
    assign BY = !(motor_state[0] & PWM_out_B & on_off); // Phase B- (or D?) - Corrected to use PWM_out_B

    // Wait request is not driven, assign constant low if needed for Avalon spec
    assign avs_ctrl_waitrequest = 1'b0;

endmodule