`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPCG_Toggle_SCC_PI_reset
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock,
    iReset      ,
    iOpcode     ,
    iTargetID   ,
    iSourceID   ,
    iCMDValid   ,
    oCMDReady   ,
    oStart      ,
    oLastStep   ,
    iPM_Ready   ,
    iPM_LastStep,
    oPM_PCommand
);
    input           iSystemClock    ;
    input           iReset          ;
    input   [5:0]   iOpcode         ;
    input   [4:0]   iTargetID       ;
    input   [4:0]   iSourceID       ;
    input           iCMDValid       ;
    output          oCMDReady       ;
    output          oStart          ;
    output          oLastStep       ;
    input   [7:0]   iPM_Ready       ;
    input   [7:0]   iPM_LastStep    ;
    output  [7:0]   oPM_PCommand    ;
    wire            wModuleTriggered;
    localparam  State_Idle          = 3'b000;
    localparam  State_PIResetIssue  = 3'b001;
    localparam  State_PIWait        = 3'b011;
    reg [2:0]   rCurState   ;
    reg [2:0]   rNextState  ;
    wire wPIResetTrig;
    always @ (posedge iSystemClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (wModuleTriggered)?State_PIResetIssue:State_Idle;
        State_PIResetIssue:
            rNextState <= (iPM_Ready)?State_PIWait:State_PIResetIssue;
        State_PIWait:
            rNextState <= (oLastStep)?State_Idle:State_PIWait;
        default:
            rNextState <= State_Idle;
        endcase
    assign wModuleTriggered     = (iCMDValid && iTargetID == 5'b00101 && iOpcode == 6'b110010);
    assign oCMDReady            = (rCurState == State_Idle);
    assign wPIResetTrig         = (rCurState == State_PIResetIssue);
    assign oStart               = wModuleTriggered;
    assign oLastStep            = (rCurState == State_PIWait) & iPM_LastStep[4];
    assign oPM_PCommand[7:0]    = {1'b0, 1'b0, 1'b0, wPIResetTrig, 1'b0, 1'b0, 1'b0, 1'b0};
endmodule
