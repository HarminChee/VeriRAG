`timescale 1ns / 1ps
`timescale 1ns / 1ps
module BCHDecoderCommandReception
#
(
    parameter AddressWidth          = 32    ,
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter ThisID                = 2
)
(
    iClock              ,
    iReset              ,
    iSrcOpcode          ,
    iSrcTargetID        ,
    iSrcSourceID        ,
    iSrcAddress         ,
    iSrcLength          ,
    iSrcCmdValid        ,
    oSrcCmdReady        ,
    oQueuedCmdType      ,
    oQueuedCmdSourceID  ,
    oQueuedCmdTargetID  ,
    oQueuedCmdOpcode    ,
    oQueuedCmdAddress   ,
    oQueuedCmdLength    ,
    oQueuedCmdValid     ,
    iQueuedCmdReady
);
    input                               iClock              ;
    input                               iReset              ;
    input   [5:0]                       iSrcOpcode          ;
    input   [4:0]                       iSrcTargetID        ;
    input   [4:0]                       iSrcSourceID        ;
    input   [AddressWidth - 1:0]        iSrcAddress         ;
    input   [InnerIFLengthWidth - 1:0]  iSrcLength          ;
    input                               iSrcCmdValid        ;
    output                              oSrcCmdReady        ;
    output  [1:0]                       oQueuedCmdType      ;
    output  [4:0]                       oQueuedCmdSourceID  ;
    output  [4:0]                       oQueuedCmdTargetID  ;
    output  [5:0]                       oQueuedCmdOpcode    ;
    output  [AddressWidth - 1:0]        oQueuedCmdAddress   ;
    output  [InnerIFLengthWidth - 1:0]  oQueuedCmdLength    ;
    output                              oQueuedCmdValid     ;
    input                               iQueuedCmdReady     ;
    reg     [1:0]                       rCmdType            ;
    reg     [4:0]                       rCmdSourceID        ;
    reg     [4:0]                       rCmdTargetID        ;
    reg     [5:0]                       rCmdOpcode          ;
    reg     [AddressWidth - 1:0]        rCmdAddress         ;
    reg     [InnerIFLengthWidth - 1:0]  rCmdLength          ;
    wire                                wJobQueuePushSignal ;
    wire                                wJobQueuePopSignal  ;
    wire                                wJobQueueFull       ;
    wire                                wJobQueueEmpty      ;
    parameter   DispatchCmd_PageWriteToRAM      = 6'b000001 ;
    parameter   DispatchCmd_SpareWriteToRAM     = 6'b000010 ;
    parameter   ECCCtrlCmdType_Bypass           = 2'b00     ;
    parameter   ECCCtrlCmdType_PageDecode       = 2'b01     ;
    parameter   ECCCtrlCmdType_SpareDecode      = 2'b10     ;
    parameter   ECCCtrlCmdType_ErrcntReport     = 2'b11     ;
    localparam  State_Idle                      = 1'b0      ;
    localparam  State_PushCmdJob                = 1'b1      ;
    reg         rCurState   ;
    reg         rNextState  ;
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    always @ (*)
        case (rCurState)
        State_Idle:
            if (iSrcCmdValid)
                rNextState <= State_PushCmdJob;
            else
                rNextState <= State_Idle;
        State_PushCmdJob:
            rNextState <= (!wJobQueueFull)?State_Idle:State_PushCmdJob;
        default:
            rNextState <= State_Idle;
        endcase
    assign oSrcCmdReady = (rCurState == State_Idle);
    always @ (posedge iClock)
        if (iReset)
            rCmdType <= 2'b0;
        else
            if (iSrcCmdValid && rCurState == State_Idle)
            begin
                if (iSrcTargetID == ThisID)
                    rCmdType <= ECCCtrlCmdType_ErrcntReport;
                else if (iSrcTargetID == 0 && iSrcOpcode == DispatchCmd_PageWriteToRAM)
                    rCmdType <= ECCCtrlCmdType_PageDecode;
                else if (iSrcTargetID == 0 && iSrcOpcode == DispatchCmd_SpareWriteToRAM)
                    rCmdType <= ECCCtrlCmdType_SpareDecode;
                else
                    rCmdType <= ECCCtrlCmdType_Bypass;
            end
    always @ (posedge iClock)
        if (iReset)
        begin
            rCmdSourceID    <= 5'b0;
            rCmdTargetID    <= 5'b0;
            rCmdOpcode      <= 6'b0;
            rCmdAddress     <= {(AddressWidth){1'b0}};
            rCmdLength      <= {(InnerIFLengthWidth){1'b0}};
        end
        else
            if (iSrcCmdValid && rCurState == State_Idle)
            begin
                rCmdSourceID    <= iSrcSourceID     ;
                rCmdTargetID    <= iSrcTargetID     ;
                rCmdOpcode      <= iSrcOpcode       ;
                rCmdAddress     <= iSrcAddress      ;
                rCmdLength      <= iSrcLength       ;
            end
    assign wJobQueuePushSignal = (rCurState == State_PushCmdJob) && !wJobQueueFull;
    AutoFIFOPopControl
    Inst_JobQueueAutoPopControl
    (
        .iClock     (iClock             ),
        .iReset     (iReset             ),
        .oPopSignal (wJobQueuePopSignal ),
        .iEmpty     (wJobQueueEmpty     ),
        .oValid     (oQueuedCmdValid    ),
        .iReady     (iQueuedCmdReady    )
    );
    SCFIFO_128x64_withCount
    Inst_JobQueue
    (
        .iClock         (iClock                                             ),
        .iReset         (iReset                                             ),
        .iPushData      (
                            {
                                rCmdAddress,
                                rCmdLength,
                                rCmdOpcode,
                                rCmdSourceID,
                                rCmdTargetID,
                                rCmdType
                            }
                        ),
        .iPushEnable    (wJobQueuePushSignal                                ),
        .oIsFull        (wJobQueueFull                                      ),
        .oPopData       (
                            {
                                oQueuedCmdAddress,
                                oQueuedCmdLength,
                                oQueuedCmdOpcode,
                                oQueuedCmdSourceID,
                                oQueuedCmdTargetID,
                                oQueuedCmdType
                            } 
                        ),
        .iPopEnable     (wJobQueuePopSignal                                 ),
        .oIsEmpty       (wJobQueueEmpty                                     ),
        .oDataCount     (                                                   )
    );
endmodule
