`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPCG_Toggle_MNC_readST
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock        ,
    iReset              ,
    iOpcode             ,
    iTargetID           ,
    iSourceID           ,
    iCMDValid           ,
    oCMDReady           ,
    oReadData           ,
    oReadLast           ,
    oReadValid          ,
    iReadReady          ,
    iWaySelect          ,
    oStart              ,
    oLastStep           ,
    iPM_Ready           ,
    iPM_LastStep        ,
    oPM_PCommand        ,
    oPM_PCommandOption  ,
    oPM_TargetWay       ,
    oPM_NumOfData       ,
    oPM_CASelect        ,
    oPM_CAData          ,
    iPM_ReadData        ,
    iPM_ReadLast        ,
    iPM_ReadValid       ,
    oPM_ReadReady
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    input   [5:0]                   iOpcode                 ;
    input   [4:0]                   iTargetID               ;
    input   [4:0]                   iSourceID               ;
    input                           iCMDValid               ;
    output                          oCMDReady               ;
    output  [31:0]                  oReadData               ;
    output                          oReadLast               ;
    output                          oReadValid              ;
    input                           iReadReady              ;
    input   [NumberOfWays - 1:0]    iWaySelect              ;
    output                          oStart                  ;
    output                          oLastStep               ;
    input   [7:0]                   iPM_Ready               ;
    input   [7:0]                   iPM_LastStep            ;
    output  [7:0]                   oPM_PCommand            ;
    output  [2:0]                   oPM_PCommandOption      ;
    output  [NumberOfWays - 1:0]    oPM_TargetWay           ;
    output  [15:0]                  oPM_NumOfData           ;
    output                          oPM_CASelect            ;
    output  [7:0]                   oPM_CAData              ;
    input   [31:0]                  iPM_ReadData            ;
    input                           iPM_ReadLast            ;
    input                           iPM_ReadValid           ;
    output                          oPM_ReadReady           ;
    localparam rST_FSM_BIT = 9; 
    localparam rST_RESET         = 9'b000000001;
    localparam rST_READY         = 9'b000000010;
    localparam rST_PBRIssue      = 9'b000000100; 
    localparam rST_CALIssue      = 9'b000001000; 
    localparam rST_CALData0      = 9'b000010000; 
    localparam rST_Timer1Issue   = 9'b000100000; 
    localparam rST_DataInIssue   = 9'b001000000; 
    localparam rST_Timer2Issue   = 9'b010000000; 
    localparam rST_WAITDone      = 9'b100000000; 
    reg     [rST_FSM_BIT-1:0]       r_rST_cur_state         ;
    reg     [rST_FSM_BIT-1:0]       r_rST_nxt_state         ;
    reg     [4:0]                   rSourceID               ;
    reg                             rCMDReady               ;
    reg     [NumberOfWays - 1:0]    rWaySelect              ;
    wire                            wLastStep               ;
    reg     [7:0]                   rPM_PCommand            ;
    reg     [2:0]                   rPM_PCommandOption      ;
    reg     [15:0]                  rPM_NumOfData           ;
    reg                             rPM_CASelect            ;
    reg     [7:0]                   rPM_CAData              ;
    wire                            wPCGStart               ;
    wire                            wCapture                ;
    wire                            wPMReady                ;
    wire                            wPBRReady               ;
    wire                            wPBRStart               ;
    wire                            wPBRDone                ;
    wire                            wCALReady               ;
    wire                            wCALStart               ;
    wire                            wCALDone                ;
    wire                            wTMReady                ;
    wire                            wTMStart                ;
    wire                            wTMDone                 ;
    wire                            wDIReady                ;
    wire                            wDIStart                ;
    wire                            wDIDone                 ;    
    assign wPCGStart = (iOpcode[5:0] == 6'b101001) & (iTargetID[4:0] == 5'b00101) & iCMDValid;
    assign wCapture = (r_rST_cur_state[rST_FSM_BIT-1:0] == rST_READY);
    assign wPMReady = (iPM_Ready[6:0] == 7'b1111111);
    assign wPBRReady = wPMReady;
    assign wPBRStart = wPBRReady & rPM_PCommand[6];
    assign wPBRDone = iPM_LastStep[6];
    assign wCALReady = wPMReady;
    assign wCALStart = wCALReady & rPM_PCommand[3];
    assign wCALDone = iPM_LastStep[3];
    assign wTMReady = wPMReady;
    assign wTMStart = wTMReady & rPM_PCommand[0];
    assign wTMDone = iPM_LastStep[0];
    assign wDIReady = wPMReady;
    assign wDIStart = wDIReady & rPM_PCommand[1];
    assign wDIDone = iPM_LastStep[1];
    wire iCEHold;
    assign iCEHold = 1'b1;
    assign wLastStep =    ((r_rST_cur_state[rST_FSM_BIT-1:0] == rST_WAITDone) & wTMDone & iCEHold);
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            r_rST_cur_state <= rST_RESET;
        end else begin
            r_rST_cur_state <= r_rST_nxt_state;
        end
    end
    always @ ( * ) begin
        case (r_rST_cur_state)
        rST_RESET: begin
            r_rST_nxt_state <= rST_READY;
        end
        rST_READY: begin
            r_rST_nxt_state <= (wPCGStart)? rST_PBRIssue:rST_READY;
        end
        rST_PBRIssue: begin
            r_rST_nxt_state <= (wPBRStart)? rST_CALIssue:rST_PBRIssue;
        end
        rST_CALIssue: begin
            r_rST_nxt_state <= (wPBRDone & wCALStart)? rST_CALData0:rST_CALIssue;
        end
        rST_CALData0: begin
            r_rST_nxt_state <= rST_Timer1Issue;
        end
        rST_Timer1Issue: begin
            r_rST_nxt_state <= (wCALDone & wTMStart)? rST_DataInIssue:rST_Timer1Issue;
        end
        rST_DataInIssue: begin
            r_rST_nxt_state <= (wTMDone & wDIStart)? rST_Timer2Issue:rST_DataInIssue;
        end
        rST_Timer2Issue: begin
            r_rST_nxt_state <= (wDIDone & wTMStart)? rST_WAITDone:rST_Timer2Issue;
        end
        rST_WAITDone: begin
            r_rST_nxt_state <= (wTMDone)? rST_READY:rST_WAITDone;
        end
        default:
            r_rST_nxt_state <= rST_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rSourceID[4:0]                  <= 0;
            rCMDReady                       <= 0;
            rWaySelect[NumberOfWays - 1:0]  <= 0;
            rPM_PCommand[7:0]               <= 0;
            rPM_PCommandOption[2:0]         <= 0;
            rPM_NumOfData[15:0]             <= 0;
            rPM_CASelect                    <= 0;
            rPM_CAData[7:0]                 <= 0;
        end else begin
            case (r_rST_nxt_state)
                rST_RESET: begin
                    rSourceID[4:0]                  <= 0;
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= 0;
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                rST_READY: begin
                    rSourceID[4:0]                  <= 0;
                    rCMDReady                       <= 1;
                    rWaySelect[NumberOfWays - 1:0]  <= 0;
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                rST_PBRIssue: begin
                    rSourceID[4:0]                  <= (wCapture)? iSourceID[4:0]:rSourceID[4:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= (wCapture)? iWaySelect[NumberOfWays - 1:0]:rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0100_0000;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                rST_CALIssue: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_1000;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 1'b0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                rST_CALData0: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 1'b0;
                    rPM_CAData[7:0]                 <= 8'h70;
                end
                rST_Timer1Issue: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_0001;
                    rPM_PCommandOption[2:0]         <= 3'b001; 
                    rPM_NumOfData[15:0]             <= 16'h0009; 
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                rST_DataInIssue: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_0010;
                    rPM_PCommandOption[2:0]         <= 3'b000; 
                    rPM_NumOfData[15:0]             <= 16'h0000; 
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                rST_Timer2Issue: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_0001;
                    rPM_PCommandOption[2:0]         <= 3'b100;
                    rPM_NumOfData[15:0]             <= 16'd3; 
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                rST_WAITDone: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[0:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
            endcase
        end
    end
    assign oCMDReady            = rCMDReady;
    assign oStart               = wPCGStart;
    assign oLastStep            = wLastStep;
    assign oPM_PCommand[7:0]    = { 1'b0, wPBRStart, 2'b00, wCALStart, 1'b0, wDIStart, wTMStart };
    assign oPM_PCommandOption[2:0] = rPM_PCommandOption[2:0];
    assign oPM_TargetWay[NumberOfWays - 1:0] = rWaySelect[NumberOfWays - 1:0];
    assign oPM_NumOfData[15:0]  = rPM_NumOfData[15:0];
    assign oPM_CASelect         = rPM_CASelect;
    assign oPM_CAData[7:0]      = rPM_CAData[7:0];
    assign oReadData[31:0]      = { iPM_ReadData[30:0], 1'b1 };
    assign oReadLast            = iPM_ReadLast;
    assign oReadValid           = iPM_ReadValid;
    assign oPM_ReadReady        = iReadReady;
endmodule
