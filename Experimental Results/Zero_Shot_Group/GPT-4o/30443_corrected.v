module top_with_timer
(
    input wire clk,
    input wire VPulse_eI,
    output wire VPace_eO,
    output wire VRefractory_eO,
    input wire reset
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

always @(posedge clk) begin
  clk_div_value <= clk_div_value + 1;
  if (clk_div_value >= 2000) begin
    clk_divd <= ~clk_divd;
    clk_div_value <= 0;
  end
end

always @(posedge clk_divd) begin
    if (VRP_Timer_Counting == 0) begin
        if (VRP_Start_Timer) begin
            VRP_Timer_Value <= 0;
            VRP_Timer_Counting <= 1;
            VRP_Timer_Timeout <= 0;
        end
    end else begin
        VRP_Timer_Value <= VRP_Timer_Value + 1;
        if (VRP_Timer_Value >= VRP_Timeout_Value) begin
            VRP_Timer_Timeout <= 1;
            VRP_Timer_Counting <= 0;
        end else begin
            VRP_Timer_Timeout <= 0;
        end
    end
end

always @(posedge clk_divd) begin
    if (LRI_Timer_Counting == 0) begin
        if (LRI_Timer_Start) begin
            LRI_Timer_Value <= 0;
            LRI_Timer_Counting <= 1;
            LRI_Timer_Timeout <= 0;
        end
    end else begin
        if (LRI_Timer_Stop) begin
            LRI_Timer_Value <= 0;
            LRI_Timer_Counting <= 0;
            LRI_Timer_Timeout <= 0;
        end else begin
            LRI_Timer_Value <= LRI_Timer_Value + 1;
            if (LRI_Timer_Value >= LRI_Timeout_Value) begin
                LRI_Timer_Timeout <= 1;
                LRI_Timer_Counting <= 0;
            end else begin
                LRI_Timer_Timeout <= 0;
            end
        end
    end
end

FB_VVI_Pacemaker iec61499_network_top (
    .clk(clk),
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
    .reset(reset)
);

endmodule