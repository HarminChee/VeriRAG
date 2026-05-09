`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ChannelArbiter
(
    iClock          ,
    iReset          ,
    iRequestChannel ,
    iLastChunk      ,
    oKESAvail       ,
    oChannelNumber  ,
    iKESAvail
);
    input           iClock          ;
    input           iReset          ;
    input   [3:0]   iRequestChannel ;
    input   [3:0]   iLastChunk      ;
    output  [3:0]   oKESAvail       ;
    output  [1:0]   oChannelNumber  ;
    input           iKESAvail       ;
    reg     [3:0]   rPriorityQ0     ;
    reg     [3:0]   rPriorityQ1     ;
    reg     [3:0]   rPriorityQ2     ;
    reg     [3:0]   rPriorityQ3     ;
    reg     [3:0]   rKESAvail       ;
    reg     [1:0]   rChannelNumber  ;
    localparam  State_Idle          = 5'b00001;
    localparam  State_Select        = 5'b00010;
    localparam  State_Out           = 5'b00100;
    localparam  State_Dummy         = 5'b01000;
    localparam  State_Standby       = 5'b10000;
    reg     [4:0]   rCurState   ;
    reg     [4:0]   rNextState  ;
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    always @ (*)
        case (rCurState)
        State_Idle:
            if (|iRequestChannel && iKESAvail)
                rNextState <= State_Select;
            else
                rNextState <= State_Idle;
        State_Select:
            rNextState <= State_Out;
        State_Out:
            rNextState <= State_Dummy;
        State_Dummy:
            rNextState <= (iLastChunk[rChannelNumber]) ? State_Idle : State_Standby;
        State_Standby:
            if (iKESAvail)
                rNextState <= State_Out;
            else
                rNextState <= State_Standby;
        default:
            rNextState <= State_Idle;
        endcase
    always @ (posedge iClock)
        if (iReset)
        begin
            rKESAvail <= 4'b0;
            rChannelNumber <= 2'b0;
        end
        else
            case (rNextState)
            State_Idle:
            begin
                rKESAvail <= 4'b0;
                rChannelNumber <= rChannelNumber;
            end
            State_Select:
            if (iRequestChannel & rPriorityQ0)
                begin
                    rKESAvail <= rPriorityQ0;
                    case (rPriorityQ0)
                    4'b0001:
                        rChannelNumber <= 2'b00;
                    4'b0010:
                        rChannelNumber <= 2'b01;
                    4'b0100:
                        rChannelNumber <= 2'b10;
                    4'b1000:
                        rChannelNumber <= 2'b11;
                    default:
                        rChannelNumber <= rChannelNumber;
                    endcase
                end
            else if (iRequestChannel & rPriorityQ1)
                begin
                    rKESAvail <= rPriorityQ1;
                    case (rPriorityQ1)
                    4'b0001:
                        rChannelNumber <= 2'b00;
                    4'b0010:
                        rChannelNumber <= 2'b01;
                    4'b0100:
                        rChannelNumber <= 2'b10;
                    4'b1000:
                        rChannelNumber <= 2'b11;
                    default:
                        rChannelNumber <= rChannelNumber;
                    endcase
                end
            else if (iRequestChannel & rPriorityQ2)
                begin
                    rKESAvail <= rPriorityQ2;
                    case (rPriorityQ2)
                    4'b0001:
                        rChannelNumber <= 2'b00;
                    4'b0010:
                        rChannelNumber <= 2'b01;
                    4'b0100:
                        rChannelNumber <= 2'b10;
                    4'b1000:
                        rChannelNumber <= 2'b11;
                    default:
                        rChannelNumber <= rChannelNumber;
                    endcase
                end
            else if (iRequestChannel & rPriorityQ3)
                begin
                    rKESAvail <= rPriorityQ3;
                    case (rPriorityQ3)
                    4'b0001:
                        rChannelNumber <= 2'b00;
                    4'b0010:
                        rChannelNumber <= 2'b01;
                    4'b0100:
                        rChannelNumber <= 2'b10;
                    4'b1000:
                        rChannelNumber <= 2'b11;
                    default:
                        rChannelNumber <= rChannelNumber;
                    endcase
                end
            default:
            begin
                rKESAvail <= rKESAvail;
                rChannelNumber <= rChannelNumber;
            end
            endcase
    always @ (posedge iClock)
        if (iReset)
            begin
                rPriorityQ0 <= 4'b0001;
                rPriorityQ1 <= 4'b0010;
                rPriorityQ2 <= 4'b0100;
                rPriorityQ3 <= 4'b1000;
            end
        else 
            case (rNextState)
            State_Select:
            if (iRequestChannel & rPriorityQ0)
                begin
                    rPriorityQ0 <= rPriorityQ1;
                    rPriorityQ1 <= rPriorityQ2;
                    rPriorityQ2 <= rPriorityQ3;
                    rPriorityQ3 <= rPriorityQ0;
                end
            else if (iRequestChannel & rPriorityQ1)
                begin
                    rPriorityQ1 <= rPriorityQ2;
                    rPriorityQ2 <= rPriorityQ3;
                    rPriorityQ3 <= rPriorityQ1;
                end
            else if (iRequestChannel & rPriorityQ2)
                begin
                    rPriorityQ2 <= rPriorityQ3;
                    rPriorityQ3 <= rPriorityQ2;
                end
            default:
            begin
                rPriorityQ0 <= rPriorityQ0;
                rPriorityQ1 <= rPriorityQ1;
                rPriorityQ2 <= rPriorityQ2;
                rPriorityQ3 <= rPriorityQ3;
            end
            endcase
    assign oKESAvail = (rCurState == State_Out) ? rKESAvail : 4'b0;
    assign oChannelNumber = rChannelNumber;
endmodule
