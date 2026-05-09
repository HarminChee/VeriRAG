// 1_corrected_ffc.v
module top_with_timer
(
		input wire clk,
		input wire VPulse_eI,
		output wire VPace_eO,
		output wire VRefractory_eO,
		input wire reset // Use wire for input reset
);

// Internal signals for timer logic
reg VRP_Timer_Timeout = 0;
reg LRI_Timer_Timeout = 0;
wire VRP_Start_Timer;
wire LRI_Timer_Start;
wire LRI_Timer_Stop;
wire [15:0] VRP_Timeout_Value;
wire [15:0] LRI_Timeout_Value;
reg VRP_Timer_Counting = 0;
reg LRI_Timer_Counting = 0;
reg [15:0] VRP_Timer_Value = 0;
reg [15:0] LRI_Timer_Value = 0;

// Clock divider logic - generate enable instead of divided clock
reg [15:0] clk_div_counter = 0;
wire clk_div_enable;

// Counter to generate enable pulse every 2000 cycles
always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_div_counter <= 16'b0;
    end else begin
        if (clk_div_counter == 16'd1999) begin // Terminal count for 2000 cycles
            clk_div_counter <= 16'b0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end
end
// Generate enable pulse when counter reaches terminal count
assign clk_div_enable = (clk_div_counter == 16'd1999);

// VRP Timer logic clocked by primary clock 'clk' and enabled by 'clk_div_enable'
always @(posedge clk or posedge reset) begin
    if (reset) begin
        VRP_Timer_Counting <= 1'b0;
        VRP_Timer_Value <= 16'b0;
        VRP_Timer_Timeout <= 1'b0;
    end else begin
        if (VRP_Start_Timer) begin // Start condition takes priority
            VRP_Timer_Counting <= 1'b1;
            VRP_Timer_Value <= 16'b0;
            VRP_Timer_Timeout <= 1'b0; // Reset timeout on start
        end else if (VRP_Timer_Counting) begin // Only process if counting
            if (clk_div_enable) begin // Increment/check only on enable pulse
                if (VRP_Timer_Value >= VRP_Timeout_Value) begin
                    VRP_Timer_Timeout <= 1'b1;
                    VRP_Timer_Counting <= 1'b0; // Stop counting on timeout
                    // Timer value holds the timeout value
                end else begin
                    VRP_Timer_Value <= VRP_Timer_Value + 1;
                    // VRP_Timer_Timeout remains 0 while counting and not timed out
                    // VRP_Timer_Counting remains 1
                end
            end
        end
        // If not starting and not counting, registers hold their state.
        // Timeout remains asserted once set, until cleared by VRP_Start_Timer or reset.
    end
end

// LRI Timer logic clocked by primary clock 'clk' and enabled by 'clk_div_enable'
always @(posedge clk or posedge reset) begin
    if (reset) begin
        LRI_Timer_Counting <= 1'b0;
        LRI_Timer_Value <= 16'b0;
        LRI_Timer_Timeout <= 1'b0;
    end else begin
        if (LRI_Timer_Start) begin // Start condition takes priority
            LRI_Timer_Counting <= 1'b1;
            LRI_Timer_Value <= 16'b0;
            LRI_Timer_Timeout <= 1'b0; // Reset timeout on start
        end else if (LRI_Timer_Stop && LRI_Timer_Counting) begin // Stop condition only processed if counting
            LRI_Timer_Counting <= 1'b0;
            LRI_Timer_Value <= 16'b0; // Reset value on stop
            LRI_Timer_Timeout <= 1'b0; // Reset timeout on stop
        end else if (LRI_Timer_Counting) begin // Only process if counting and not stopped/restarted
            if (clk_div_enable) begin // Increment/check only on enable pulse
                if (LRI_Timer_Value >= LRI_Timeout_Value) begin
                    LRI_Timer_Timeout <= 1'b1;
                    LRI_Timer_Counting <= 1'b0; // Stop counting on timeout
                    // Timer value holds the timeout value
                end else begin
                    LRI_Timer_Value <= LRI_Timer_Value + 1;
                    // LRI_Timer_Timeout remains 0 while counting and not timed out
                    // LRI_Timer_Counting remains 1
                end
            end
        end
        // If not starting, not stopping, and not counting, registers hold their state.
        // Timeout remains asserted once set, until cleared by LRI_Timer_Start, LRI_Timer_Stop or reset.
    end
end

// Instantiate the core logic module
FB_VVI_Pacemaker iec61499_network_top (
	.clk(clk), // Connect primary clock
    .VPulse_eI(VPulse_eI),
    .VRP_Timer_Timeout_eI(VRP_Timer_Timeout), // Connect internal timer output
    .LRI_Timer_Timeout_eI(LRI_Timer_Timeout), // Connect internal timer output
    .VPace_eO(VPace_eO),
    .VRefractory_eO(VRefractory_eO),
    .VRP_Start_Timer_eO(VRP_Start_Timer),     // Connect to internal control signal
    .LRI_Timer_Start_eO(LRI_Timer_Start),     // Connect to internal control signal
    .LRI_Timer_Stop_eO(LRI_Timer_Stop),       // Connect to internal control signal
    .VRP_Timeout_Value_O(VRP_Timeout_Value),  // Connect to internal control signal
    .LRI_Timeout_Value_O(LRI_Timeout_Value),  // Connect to internal control signal
	.reset(reset)                             // Connect primary reset
);

endmodule