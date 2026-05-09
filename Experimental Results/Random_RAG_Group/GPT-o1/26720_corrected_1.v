`timescale 1ns/1ps
module ControllerReadTempI2C(
    input Clock,
    input ClockI2C,
    input Reset,
    input SDA,
    input Start,
    output reg BaudEnable,
    output reg Done,
    output reg ReadOrWrite,
    output reg Select,
    output reg ShiftOrHold,
    output reg StartStopAck,
    output reg WriteLoad
    );
    
    reg [3:0] DataCounter;
    reg [2:0] State;
    reg [2:0] NextState;
    
    parameter InitialState = 3'd0;
    parameter LoadState    = 3'd1;
    parameter WriteState   = 3'd2;
    parameter ReadState    = 3'd3;
    
    wire OneShotNegative;
    wire OneShotPositive;
    
    ClockedNegativeOneShot OneShotNegativeUnit(
        .Clock(ClockI2C),
        .Pulse(OneShotNegative),
        .Reset(Reset)
    );
    
    ClockedPositiveOneShot OneShotPositiveUnit(
        .Clock(ClockI2C),
        .Pulse(OneShotPositive),
        .Reset(Reset)
    );
    
    reg ACKbit;
    
    always @(posedge ClockI2C) begin
        if (Reset) begin
            State  <= InitialState;
            ACKbit <= 1'b1;
        end
        else begin
            State <= NextState;
            if (OneShotPositive == 1'b1)
                ACKbit <= SDA;
            else
                ACKbit <= ACKbit;
        end
    end
    
    always @(posedge ClockI2C) begin
        if (Reset) begin
            DataCounter <= 4'd9;
        end
        else begin
            case (State)
                LoadState:
                    if (OneShotNegative == 1'b0)
                        DataCounter <= DataCounter - 1'b1;
                    else
                        DataCounter <= DataCounter;
                WriteState:
                    if (OneShotNegative == 1'b0)
                        DataCounter <= DataCounter - 1'b1;
                    else
                        DataCounter <= DataCounter;
                ReadState:
                    if (OneShotPositive == 1'b1)
                        DataCounter <= DataCounter - 1'b1;
                    else
                        DataCounter <= DataCounter;
                default:
                    DataCounter <= 4'd9;
            endcase
        end
    end

    always @(*) begin
        NextState = State;
        BaudEnable = 1'b0;
        Done = 1'b0;
        ReadOrWrite = 1'b0;
        Select = 1'b0;
        ShiftOrHold = 1'b0;
        StartStopAck = 1'b0;
        WriteLoad = 1'b0;
        case (State)
            InitialState: begin
                if (Start)
                    NextState = LoadState;
            end
            LoadState: begin
                WriteLoad = 1'b1;
                if (DataCounter == 0)
                    NextState = WriteState;
            end
            WriteState: begin
                BaudEnable = 1'b1;
                if (DataCounter == 0)
                    NextState = ReadState;
            end
            ReadState: begin
                BaudEnable = 1'b1;
                ReadOrWrite = 1'b1;
                if (DataCounter == 0) begin
                    Done = 1'b1;
                    NextState = InitialState;
                end
            end
            default: NextState = InitialState;
        endcase
    end
    
endmodule

module ClockedNegativeOneShot(
    input Clock,
    input Reset,
    output Pulse
);
    assign Pulse = 1'b0;
endmodule

module ClockedPositiveOneShot(
    input Clock,
    input Reset,
    output Pulse
);
    assign Pulse = 1'b0;
endmodule