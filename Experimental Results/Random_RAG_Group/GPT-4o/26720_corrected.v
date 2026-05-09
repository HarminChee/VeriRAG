`timescale 1ns / 1ps
module ControllerReadTempI2C(
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
    output WriteLoad,
    input test_i,
    input scan_clock
);
    reg [3:0] DataCounter;
    reg [2:0] State;
    reg [2:0] NextState;
    parameter InitialState = 3'd0;
    parameter LoadState = 3'd1;
    parameter WriteState = 3'd2;
    parameter ReadState = 3'd3;
    wire OneShotNegative, OneShotPositive;
    reg ack_bit;
    wire dft_clock;
    
    assign dft_clock = test_i ? scan_clock : ClockI2C;
    
    ClockedNegativeOneShot OneShotNegativeUnit(dft_clock, OneShotNegative, Reset, Clock);
    ClockedPositiveOneShot OneShotPositiveUnit(dft_clock, OneShotPositive, Reset, Clock);
    
    always @(posedge dft_clock or posedge Reset)
        if (Reset) begin
            State <= InitialState;
            ack_bit <= 1;
        end else begin
            State <= NextState;
            if (OneShotPositive)
                ack_bit <= SDA;
            else
                ack_bit <= ack_bit;
        end
    
    always @(posedge dft_clock or posedge Reset)
        if (Reset) begin
            DataCounter <= 4'd9;
        end else case (State)
            LoadState:
                if (!OneShotNegative) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            WriteState:
                if (!OneShotNegative) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            ReadState:
                if (OneShotPositive) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            default: DataCounter <= 4'd9;
        endcase
endmodule