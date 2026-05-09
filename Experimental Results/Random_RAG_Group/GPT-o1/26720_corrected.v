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
    
endmodule