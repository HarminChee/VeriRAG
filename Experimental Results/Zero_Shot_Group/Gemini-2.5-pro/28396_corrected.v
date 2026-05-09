module steering_driver (
    input               rsi_MRST_reset,
    input               csi_MCLK_clk,
    input      [31:0]   avs_ctrl_writedata,
    output reg [31:0]   avs_ctrl_readdata, // Made reg as it's assigned in always block
    input      [3:0]    avs_ctrl_byteenable,
    input      [2:0]    avs_ctrl_address,
    input               avs_ctrl_write,
    input               avs_ctrl_read,
    output              avs_ctrl_waitrequest,
    input               rsi_PWMRST_reset,
    input               csi_PWMCLK_clk,
    output              steering // Corrected typo: streeing -> steering
);

    // Unused regs removed: forward_back, on_off
    reg [9:0] angle;
    // reg [31:0] read_data; // Combined with avs_ctrl_readdata

    // Avalon Interface Logic
    assign avs_ctrl_waitrequest = 1'b0; // Provide a default value

    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset) begin
        if (rsi_MRST_reset) begin
            angle <= 10'b0;
            avs_ctrl_readdata <= 32'b0;
        end else begin
            // Write operation
            if (avs_ctrl_write) begin
                case (avs_ctrl_address)
                    3'd1: begin // Address 1 for angle control
                        if (avs_ctrl_byteenable[0]) begin
                            angle[7:0] <= avs_ctrl_writedata[7:0];
                        end
                        if (avs_ctrl_byteenable[1]) begin
                            // Assuming bits [9:8] of writedata are intended for angle[9:8]
                            angle[9:8] <= avs_ctrl_writedata[9:8];
                        end
                    end
                    default: ; // Ignore writes to other addresses
                endcase
            end
            // Read operation - handled combinatorially below for reads,
            // but register update needed for write-through or read latency > 0
            // Simplified: update readdata register only during read cycle *request*
            // A more typical Avalon slave would latch the address on read=1
            // and present data on the next cycle, potentially deasserting waitrequest.
            // This implementation provides read data combinationally based on address.
            // Let's make it registered read data based on previous cycle's state.
            else if (avs_ctrl_read) begin // Update read data only on read cycle
                 case (avs_ctrl_address)
                    3'd0: avs_ctrl_readdata <= 32'hEA680003; // ID or Status Register
                    3'd1: avs_ctrl_readdata <= {22'b0, angle}; // Angle value
                    default: avs_ctrl_readdata <= 32'b0; // Default read value
                 endcase
            end else begin
                 // Hold read data otherwise (or set to default)
                 // avs_ctrl_readdata <= avs_ctrl_readdata; // Optional: hold last value
                 // Or set to zero if not reading
                 // avs_ctrl_readdata <= 32'b0;
                 // Let's keep the previous implementation's behavior: hold last value implicitly
                 // Or more cleanly: assign default outside read condition
                 // However, the original code updated read_data even when not reading,
                 // let's replicate that but only based on address, not write data.
                 // This is non-standard Avalon behavior.
                 // A better way:
                 // if (!avs_ctrl_write) begin // Update read data if not writing
                 //    case(avs_ctrl_address) // This is still unusual, read data should only update based on read strobe
                 //       ...
                 //    endcase
                 // end
                 // Let's stick closer to the original intent's *effect* even if flawed:
                 // update based on address if not writing.
                case (avs_ctrl_address)
                    3'd0: avs_ctrl_readdata <= 32'hEA680003;
                    3'd1: avs_ctrl_readdata <= {22'b0, angle};
                    default: avs_ctrl_readdata <= 32'b0;
                endcase
            end
        end
    end

    // PWM Generation Logic
    reg [31:0] counter;
    always @(posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset) begin
        if (rsi_PWMRST_reset) begin
            counter <= 32'b0;
        end else begin
            // Ensure calculation doesn't overflow intermediate steps if using constants
            // Using direct value is safer if calculated offline
            counter <= counter + 32'd2197504; // 2048 * 1073 = 2197504
        end
    end

    // Use the MSB of the counter as a slower clock/enable signal
    wire slow_clk_edge = counter[31]; // Signal indicating overflow period start

    reg [10:0] pwm_counter; // Renamed from PWM for clarity
    always @(posedge slow_clk_edge or posedge rsi_PWMRST_reset) begin // Trigger on rising edge of MSB
        if (rsi_PWMRST_reset) begin
            pwm_counter <= 11'b0;
        end else begin
            // Increment PWM counter. It rolls over naturally from 2047 to 0.
            pwm_counter <= pwm_counter + 1;
        end
    end

    // PWM Output Comparison (Combinational)
    // Removed reg PWM_out and associated always block
    wire pwm_out;
    assign pwm_out = (pwm_counter[9:0] < angle); // Compare only relevant bits

    // Final Output Assignment
    assign steering = pwm_out; // Corrected typo

endmodule