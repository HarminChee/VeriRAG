`timescale 1ns / 1ps

module ControllerReadTempI2C(Clock, ClockI2C, Reset, SDA, Start, BaudEnable, Done, ReadOrWrite, Select, ShiftOrHold, StartStopAck, WriteLoad);
    input Clock;
    input ClockI2C;
    input Reset;
    input SDA;
    input Start;
    output reg BaudEnable;
    output reg Done;
    output reg ReadOrWrite;
    output reg Select;
    output reg ShiftOrHold;
    output reg StartStopAck;
    output reg WriteLoad;

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

    always@(posedge Clock)
        if(Reset==1) begin 
            State <= InitialState; 
            ACKbit <= 1; 
        end
        else begin
            State <= NextState;
            if(OneShotPositive==1) ACKbit <= SDA; 
            else ACKbit <= ACKbit;
        end

    always@(posedge Clock)
        if(Reset==1) begin 
            DataCounter <= 4'd9; 
        end
        else case (State)
            LoadState:
                if(OneShotNegative==0) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            WriteState:
                if(OneShotNegative==0) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            ReadState:
                if(OneShotPositive==1) DataCounter <= DataCounter - 1'b1;
                else DataCounter <= DataCounter;
            default: DataCounter <= 4'd9;
        endcase

    // Additional logic to ensure outputs are driven
    always @(State or Start or OneShotPositive or OneShotNegative) begin
        BaudEnable = 0;
        Done = 0;
        ReadOrWrite = 0;
        Select = 0;
        ShiftOrHold = 0;
        StartStopAck = 0;
        WriteLoad = 0;

        case (State)
            InitialState: begin
                if (Start) begin
                    Select = 1;
                    WriteLoad = 1;
                    NextState = LoadState;
                end
            end
            LoadState: begin
                ShiftOrHold = 1;
                if (OneShotNegative) NextState = WriteState;
            end
            WriteState: begin
                WriteLoad = 1;
                if (OneShotNegative) begin
                    if (DataCounter == 0) NextState = ReadState;
                    else NextState = WriteState;
                end
            end
            ReadState: begin
                ReadOrWrite = 1;
                if (OneShotPositive) begin
                    if (DataCounter == 0) NextState = InitialState;
                    else NextState = ReadState;
                end
            end
            default: NextState = InitialState;
        endcase

        Done = (State == ReadState && DataCounter == 0 && OneShotPositive);
        StartStopAck = ACKbit;
    end

endmodule