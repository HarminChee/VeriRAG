`timescale 1ns / 1ps
module ControllerReadTempI2C(
    input  wire       Clock,
    input  wire       ClockI2C,
    input  wire       Reset,
    input  wire       SDA,
    input  wire       Start,
    input  wire       test_i,
    output wire       BaudEnable,
    output wire       Done,
    output wire       ReadOrWrite,
    output wire       Select,
    output wire       ShiftOrHold,
    output wire       StartStopAck,
    output wire       WriteLoad
);
    reg [3:0] DataCounter;
    reg [2:0] State;
    reg [2:0] NextState;
    parameter InitialState = 3'd0;
    parameter LoadState = 3'd1;
    parameter WriteState = 3'd2;
    parameter ReadState = 3'd3;
    wire OneShotNegative, OneShotPositive;
    wire dft_Clock, dft_Reset;

    assign dft_Clock = test_i ? Clock : ClockI2C;
    assign dft_Reset = test_i ? Reset : Reset;

    ClockedNegativeOneShot OneShotNegativeUnit(dft_Clock, OneShotNegative, dft_Reset, Clock);
    ClockedPositiveOneShot OneShotPositiveUnit(dft_Clock, OneShotPositive, dft_Reset, Clock);

    reg ACKbit;

    always @(posedge Clock)
        if (dft_Reset == 1) begin 
            State <= InitialState; 
            ACKbit <= 1; 
        end
        else begin
            State <= NextState;
            if (OneShotPositive == 1) ACKbit <= SDA; 
            else ACKbit <= ACKbit;
        end

    always @(posedge Clock)
        if (dft_Reset == 1) begin 
            DataCounter <= 4'd9; 
        end
        else case (State)
            LoadState:
                if (OneShotNegative == 0) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            WriteState:
                if (OneShotNegative == 0) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            ReadState:
                if (OneShotPositive == 1) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            default: DataCounter <= 4'd9;
        endcase

endmodule