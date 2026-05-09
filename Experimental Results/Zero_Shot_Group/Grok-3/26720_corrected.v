`timescale 1ns / 1ps
module ControllerReadTempI2C(Clock, ClockI2C, Reset, SDA, Start, BaudEnable, Done, ReadOrWrite, Select, ShiftOrHold, StartStopAck, WriteLoad);
    input Clock;
    input ClockI2C;
    input Reset;
    input SDA;
    input Start;
    output BaudEnable;
    output Done;
    output ReadOrWrite;
    output Select;
    output ShiftOrHold;
    output StartStopAck;
    output WriteLoad;

    reg [3:0] DataCounter;
    reg [2:0] State;
    reg [2:0] NextState;

    parameter InitialState = 3'd0;
    parameter LoadState = 3'd1;
    parameter WriteState = 3'd2;
    parameter ReadState = 3'd3;

    wire OneShotNegative, OneShotPositive;

    ClockedNegativeOneShot OneShotNegativeUnit(ClockI2C, OneShotNegative, Reset, Clock);
    ClockedPositiveOneShot OneShotPositiveUnit(ClockI2C, OneShotPositive, Reset, Clock);

    reg ACKbit;

    assign BaudEnable = (State == WriteState || State == ReadState);
    assign Done = (State == InitialState && DataCounter == 4'd0);
    assign ReadOrWrite = (State == ReadState);
    assign Select = (State == LoadState);
    assign ShiftOrHold = (State == WriteState || State == ReadState) && OneShotNegative;
    assign StartStopAck = (State == InitialState && Start) || (State == WriteState && DataCounter == 4'd0);
    assign WriteLoad = (State == LoadState);

    always @(posedge Clock)
        if (Reset == 1) begin 
            State <= InitialState; 
            ACKbit <= 1; 
        end
        else begin
            State <= NextState;
            if (OneShotPositive == 1) 
                ACKbit <= SDA; 
            else 
                ACKbit <= ACKbit;
        end

    always @(posedge Clock)
        if (Reset == 1) begin 
            DataCounter <= 4'd9; 
        end
        else case (State)
            LoadState:
                if (OneShotNegative == 0) 
                    DataCounter <= DataCounter - 1'b1;
                else 
                    DataCounter <= DataCounter;
            WriteState:
                if (OneShotNegative == 0) 
                    DataCounter <= DataCounter - 1'b1;
                else 
                    DataCounter <= DataCounter;
            ReadState:
                if (OneShotPositive == 1) 
                    DataCounter <= DataCounter - 1'b1;
                else 
                    DataCounter <= DataCounter;
            default: 
                DataCounter <= 4'd9;
        endcase

    always @(State, Start, DataCounter, ACKbit)
        case (State)
            InitialState:
                if (Start == 1)
                    NextState = LoadState;
                else
                    NextState = InitialState;
            LoadState:
                if (DataCounter == 4'd0)
                    NextState = WriteState;
                else
                    NextState = LoadState;
            WriteState:
                if (DataCounter == 4'd0 && ACKbit == 0)
                    NextState = ReadState;
                else if (DataCounter == 4'd0 && ACKbit == 1)
                    NextState = InitialState;
                else
                    NextState = WriteState;
            ReadState:
                if (DataCounter == 4'd0)
                    NextState = InitialState;
                else
                    NextState = ReadState;
            default:
                NextState = InitialState;
        endcase

endmodule