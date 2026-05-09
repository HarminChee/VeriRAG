`timescale 1ns / 1ps
`timescale 1ns / 1ps
module DecWidthConverter16to32
#
(
    parameter   InputDataWidth  = 16,
    parameter   OutputDataWidth = 32
)
(
    iClock              ,
    iReset              ,
    iSrcDataValid       ,
    iSrcData            ,
    iSrcDataLast        ,
    oConverterReady     ,
    oConvertedDataValid ,
    oConvertedData      ,
    oConvertedDataLast  ,
    iDstReady       
);
    input                           iClock              ;
    input                           iReset              ;
    input                           iSrcDataValid       ;
    input   [InputDataWidth - 1:0]  iSrcData            ;
    input                           iSrcDataLast        ;
    output                          oConverterReady     ;
    output                          oConvertedDataValid ;
    output  [OutputDataWidth - 1:0] oConvertedData      ;
    output                          oConvertedDataLast  ;
    input                           iDstReady           ;
    reg     [InputDataWidth - 1:0]  rShiftRegister      ;
    reg     [InputDataWidth - 1:0]  rInputRegister      ;
    reg                             rConvertedDataValid ;
    reg                             rConvertedDataLast  ;
    localparam  State_Idle  = 4'b0001; 
    localparam  State_Input = 4'b0010;
    localparam  State_Shift = 4'b0100;
    localparam  State_Pause = 4'b1000;
    reg     [3:0]   rCurState;
    reg     [3:0]   rNextState;
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (iSrcDataValid) ? State_Input : State_Idle;
        State_Input:
            rNextState <= State_Shift;
        State_Shift:
            if (iDstReady)
            begin
                if (iSrcDataValid)
                    rNextState <= State_Input;
                else
                    rNextState <= State_Idle;
            end
            else
                rNextState <= State_Pause;
        State_Pause:
            if (iDstReady)
                begin
                    if (iSrcDataValid)
                        rNextState <= State_Input;
                    else
                        rNextState <= State_Idle;
                end
                else
                    rNextState <= State_Pause;
        default:
            rNextState <= State_Idle;
        endcase
    always @ (posedge iClock)
        if (iReset)
            begin
                rInputRegister <= 0;
                rShiftRegister <= 0;
            end
        else
            case (rNextState)
            State_Idle:
                begin
                    rInputRegister <= 0;
                    rShiftRegister <= 0;
                end
            State_Input:
                begin
                    rInputRegister <= iSrcData;
                    rShiftRegister <= 0;
                end
            State_Shift:
                begin
                    rInputRegister <= iSrcData;
                    rShiftRegister <= rInputRegister;
                end
            State_Pause:
                begin
                    rInputRegister <= rInputRegister;
                    rShiftRegister <= rShiftRegister;
                end
            default:
                begin
                    rInputRegister <= 0;
                    rShiftRegister <= 0;
                end
            endcase
    always @ (posedge iClock)
        if (iReset)
            rConvertedDataValid <= 0;
        else
            case (rNextState)
            State_Idle:
                rConvertedDataValid <= 0;
            State_Input:
                rConvertedDataValid <= 0;
            default:
                rConvertedDataValid <= 1'b1;
            endcase            
    always @ (posedge iClock)
        if (iReset)
            rConvertedDataLast <= 0;
        else
            if (iSrcDataLast)
                rConvertedDataLast <= 1'b1;
            else
                if (rConvertedDataValid && iDstReady && rConvertedDataLast)
                    rConvertedDataLast <= 1'b0;
    assign oConvertedData = {rShiftRegister, rInputRegister};
    assign oConvertedDataValid = rConvertedDataValid;
    assign oConvertedDataLast = rConvertedDataLast;
    assign oConverterReady = !(rNextState == State_Pause);
endmodule
