module top_with_timer
(
		input wire clk,
		input wire test_i, // Added test mode input
		input wire VPulse_eI,
		output wire VPace_eO,
		output wire VRefractory_eO,
		input wire reset // Changed from input reset to input wire reset for clarity
);
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
reg [15:0] clk_div_value = 0;
reg clk_divd = 0;

// DFT Fix: Mux for generated clock
wire dft_clk_divd;
assign dft_clk_divd = test_i ? clk : clk_divd;

// Clock divider logic with asynchronous reset
always@(posedge clk or posedge reset) begin
  if (reset) begin
    clk_div_value <= 16'b0;
    clk_divd <= 1'b0;
  end else begin
    if(clk_div_value >= 2000 - 1) begin // Check before incrementing for correct period
      clk_divd <= ~clk_divd;
      clk_div_value <= 16'b0;
    end else begin
      clk_div_value <= clk_div_value + 1;
      // clk_divd <= clk_divd; // Maintain value if not toggling
    end
  end
end

// VRP Timer logic with DFT clock mux and asynchronous reset
always@(posedge dft_clk_divd or posedge reset) begin
    if (reset) begin
        VRP_Timer_Value <= 16'b0;
        VRP_Timer_Counting <= 1'b0;
        VRP_Timer_Timeout <= 1'b0;
    end else begin
        if(VRP_Timer_Counting == 0) begin
            if(VRP_Start_Timer) begin
                VRP_Timer_Value <= 16'b0;
                VRP_Timer_Counting <= 1'b1;
                VRP_Timer_Timeout <= 1'b0;
            end
            // Registers hold value if VRP_Start_Timer is low
        end else begin // VRP_Timer_Counting == 1
            VRP_Timer_Value <= VRP_Timer_Value + 1;
            if(VRP_Timer_Value >= VRP_Timeout_Value) begin
                VRP_Timer_Timeout <= 1'b1;
                VRP_Timer_Counting <= 1'b0;
            end else begin
                // Original logic: stop counting if not timeout on next cycle
                VRP_Timer_Timeout <= 1'b0;
                VRP_Timer_Counting <= 1'b0;
            end
        end
    end
end

// LRI Timer logic with DFT clock mux and asynchronous reset
always@(posedge dft_clk_divd or posedge reset) begin
    if (reset) begin
        LRI_Timer_Value <= 16'b0;
        LRI_Timer_Counting <= 1'b0;
        LRI_Timer_Timeout <= 1'b0;
    end else begin
        if(LRI_Timer_Counting == 0) begin
            if(LRI_Timer_Start) begin
                LRI_Timer_Value <= 16'b0;
                LRI_Timer_Counting <= 1'b1;
                LRI_Timer_Timeout <= 1'b0;
            end
            // Registers hold value if LRI_Timer_Start is low
        end else begin // LRI_Timer_Counting == 1
            if(LRI_Timer_Stop) begin
                LRI_Timer_Value <= 16'b0;
                LRI_Timer_Counting <= 1'b1; // Original logic: stays 1 on stop?
                LRI_Timer_Timeout <= 1'b0;
            end else begin
                LRI_Timer_Value <= LRI_Timer_Value + 1;
                if(LRI_Timer_Value >= LRI_Timeout_Value) begin
                    LRI_Timer_Timeout <= 1'b1;
                    LRI_Timer_Counting <= 1'b0;
                end else begin
                    // Original logic: stop counting if not timeout on next cycle
                    LRI_Timer_Timeout <= 1'b0;
                    LRI_Timer_Counting <= 1'b0;
                end
            end
        end
    end
end

// Instantiation - Assuming FB_VVI_Pacemaker is DFT compliant internally
// Its clock and reset are connected to primary inputs clk and reset.
FB_VVI_Pacemaker iec61499_network_top (
	.clk(clk), // Primary clock
    .VPulse_eI(VPulse_eI),
    .VRP_Timer_Timeout_eI(VRP_Timer_Timeout),
    .LRI_Timer_Timeout_eI(LRI_Timer_Timeout),
    .VPace_eO(VPace_eO),
    .VRefractory_eO(VRefractory_eO),
    .VRP_Start_Timer_eO(VRP_Start_Timer),
    .LRI_Timer_Start_eO(LRI_Timer_Start),
    .LRI_Timer_Stop_eO(LRI_Timer_Stop),
    .VRP_Timeout_Value_O(VRP_Timeout_Value),
    .LRI_Timeout_Value_O(LRI_Timeout_Value),
	.reset(reset) // Primary reset
);
endmodule