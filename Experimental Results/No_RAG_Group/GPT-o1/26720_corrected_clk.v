`timescale 1ns / 1ps
module ControllerReadTempI2C_corrected_clk(
    input Clock,
    input ClockI2C,
    input Reset,
    input SDA,
    input Start,
    output BaudEnable,
    output Done,
    output ReadOrWrite,
    output Select,
    output ShiftOrHold,
    output StartStopAck,
    output WriteLoad
);
    reg [3:0] DataCounter;
    reg [2:0] State;
    reg [2:0] NextState;
    parameter InitialState = 3'd0;
    parameter LoadState = 3'd1;
    parameter WriteState = 3'd2;
    parameter ReadState = 3'd3;

    wire OneShotNegative, OneShotPositive;

    ClockedNegativeOneShot OneShotNegativeUnit (
        .clk     (ClockI2C),
        .pulse   (OneShotNegative),
        .rst     (Reset)
    );

    ClockedPositiveOneShot OneShotPositiveUnit (
        .clk     (ClockI2C),
        .pulse   (OneShotPositive),
        .rst     (Reset)
    );

    reg ACKbit;

    always @(posedge ClockI2C) begin
        if (Reset == 1) begin
            State <= InitialState;
            ACKbit <= 1;
        end
        else begin
            State <= NextState;
            if (OneShotPositive == 1) ACKbit <= SDA; 
            else ACKbit <= ACKbit;
        end
    end

    always @(posedge ClockI2C) begin
        if (Reset == 1) begin
            DataCounter <= 4'd9;
        end
        else begin
            case (State)
                LoadState: 
                    if (OneShotNegative == 0) DataCounter <= DataCounter - 1'b1;
                    else DataCounter <= DataCounter;
                WriteState:
                    if (OneShotNegative == 0) DataCounter <= DataCounter - 1'b1;
                    else DataCounter <= DataCounter;
                ReadState:
                    if (OneShotPositive == 1) DataCounter <= DataCounter - 1'b1;
                    else DataCounter <= DataCounter;
                default: 
                    DataCounter <= 4'd9;
            endcase
        end
    end

endmodule