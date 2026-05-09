`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPCG_Toggle_MNC_setFT
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
    iLength             ,
    iCMDValid           ,
    oCMDReady           ,
    iWriteData          ,
    iWriteLast          ,
    iWriteValid         ,
    oWriteReady         ,
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
    oPM_WriteData       ,
    oPM_WriteLast       ,
    oPM_WriteValid      ,
    iPM_WriteReady
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    input   [5:0]                   iOpcode                 ;
    input   [4:0]                   iTargetID               ;
    input   [4:0]                   iSourceID               ;
    input   [7:0]                   iLength                 ;
    input                           iCMDValid               ;
    output                          oCMDReady               ;
    input   [31:0]                  iWriteData              ;
    input                           iWriteLast              ;
    input                           iWriteValid             ;
    output                          oWriteReady             ;
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
    output  [31:0]                  oPM_WriteData           ;
    output                          oPM_WriteLast           ;
    output                          oPM_WriteValid          ;
    input                           iPM_WriteReady          ;
    localparam sFT_FSM_BIT = 9; 
    localparam sFT_RESET = 9'b000000001;
    localparam sFT_READY = 9'b000000010;
    localparam sFT_CALST = 9'b000000100; 
    localparam sFT_CALD0 = 9'b000001000; 
    localparam sFT_CALD1 = 9'b000010000; 
    localparam sFT_DO_ST = 9'b000100000; 
    localparam sFT_TM1ST = 9'b001000000; 
    localparam sFT_TM2ST = 9'b010000000; 
    localparam sFT_WAITD = 9'b100000000; 
    reg     [sFT_FSM_BIT-1:0]       r_sFT_cur_state         ;
    reg     [sFT_FSM_BIT-1:0]       r_sFT_nxt_state         ;
    localparam pTF_FSM_BIT = 11; 
    localparam pTF_RESET = 11'b000_0000_0001;
    localparam pTF_READY = 11'b000_0000_0010;
    localparam pTF_STADB = 11'b000_0000_0100; 
    localparam pTF_CAPTP = 11'b000_0000_1000; 
    localparam pTF_PTSD0 = 11'b000_0001_0000; 
    localparam pTF_PTSD1 = 11'b000_0010_0000; 
    localparam pTF_PTSD2 = 11'b000_0100_0000; 
    localparam pTF_PTSD3 = 11'b000_1000_0000; 
    localparam pTF_PTDD0 = 11'b001_0000_0000; 
    localparam pTF_PTDD1 = 11'b010_0000_0000; 
    localparam pTF_WAITD = 11'b100_0000_0000; 
    reg     [pTF_FSM_BIT-1:0]       r_pTF_cur_state         ;
    reg     [pTF_FSM_BIT-1:0]       r_pTF_nxt_state         ;
    reg                             rOperationMode          ;
    reg     [4:0]                   rSourceID               ;
    reg     [7:0]                   rLength                 ;
    reg                             rCMDReady               ;
    reg     [NumberOfWays - 1:0]    rWaySelect              ;
    wire                            wLastStep               ;
    reg     [7:0]                   rPM_PCommand            ;
    reg     [2:0]                   rPM_PCommandOption      ;
    reg     [15:0]                  rPM_NumOfData           ;
    reg                             rPM_CASelect            ;
    reg     [7:0]                   rPM_CAData              ;
    reg                             rWriteReady             ;
    reg     [31:0]                  rParameter              ;
    reg     [31:0]                  rPM_WriteData           ;
    reg                             rPM_WriteLast           ;
    reg                             rPM_WriteValid          ;
    wire                            wPCGStart               ;
    wire                            wCapture                ;
    wire                            wPMReady                ;
    wire                            wCALReady               ;
    wire                            wCALStart               ;
    wire                            wCALDone                ;
    wire                            wDOReady                ;
    wire                            wDOStart                ;
    wire                            wDODone                 ;
    wire                            wTMReady                ;
    wire                            wTMStart                ;
    wire                            wTMDone                 ;
    assign wPCGStart = (iOpcode[5:1] == 5'b10000) & (iTargetID[4:0] == 5'b00101) & iCMDValid;
    assign wCapture = (r_sFT_cur_state[sFT_FSM_BIT-1:0] == sFT_READY);
    assign wPMReady = (iPM_Ready[6:0] == 7'b1111111);
    assign wCALReady = wPMReady;
    assign wCALStart = wCALReady & rPM_PCommand[3];
    assign wCALDone = iPM_LastStep[3];
    assign wDOReady = wPMReady;
    assign wDOStart = wDOReady & rPM_PCommand[2];
    assign wDODone = iPM_LastStep[2];
    assign wTMReady = wPMReady;
    assign wTMStart = wTMReady & rPM_PCommand[0];
    assign wTMDone = iPM_LastStep[0];
    assign wLastStep = wTMDone & (r_sFT_cur_state[sFT_FSM_BIT-1:0] == sFT_WAITD);
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            r_sFT_cur_state <= sFT_RESET;
        end else begin
            r_sFT_cur_state <= r_sFT_nxt_state;
        end
    end
    always @ ( * ) begin
        case (r_sFT_cur_state)
        sFT_RESET: begin
            r_sFT_nxt_state <= sFT_READY;
        end
        sFT_READY: begin
            r_sFT_nxt_state <= (wPCGStart)? sFT_CALST:sFT_READY;
        end
        sFT_CALST: begin
            r_sFT_nxt_state <= (wCALStart)? sFT_CALD0:sFT_CALST;
        end
        sFT_CALD0: begin
            r_sFT_nxt_state <= sFT_CALD1;
        end
        sFT_CALD1: begin
            r_sFT_nxt_state <= sFT_DO_ST;
        end
        sFT_DO_ST: begin
            r_sFT_nxt_state <= (wDOStart)? sFT_TM1ST:sFT_DO_ST;
        end
        sFT_TM1ST: begin
            r_sFT_nxt_state <= (wTMStart)? sFT_TM2ST:sFT_TM1ST;
        end
        sFT_TM2ST: begin
            r_sFT_nxt_state <= (wTMStart)? sFT_WAITD:sFT_TM2ST;
        end
        sFT_WAITD: begin
            r_sFT_nxt_state <= (wLastStep)? sFT_READY:sFT_WAITD;
        end
        default:
            r_sFT_nxt_state <= sFT_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rOperationMode                  <= 0;
            rSourceID[4:0]                  <= 0;
            rLength[7:0]                    <= 0;
            rCMDReady                       <= 0;
            rWaySelect[NumberOfWays - 1:0]  <= 0;
            rPM_PCommand[7:0]               <= 0;
            rPM_PCommandOption[2:0]         <= 0;
            rPM_NumOfData[15:0]             <= 0;
            rPM_CASelect                    <= 0;
            rPM_CAData[7:0]                 <= 0;
        end else begin
            case (r_sFT_nxt_state)
                sFT_RESET: begin
                    rOperationMode                  <= 0;
                    rSourceID[4:0]                  <= 0;
                    rLength[7:0]                    <= 0;
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= 0;
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                sFT_READY: begin
                    rOperationMode                  <= 0;
                    rSourceID[4:0]                  <= 0;
                    rLength[7:0]                    <= 0;
                    rCMDReady                       <= 1;
                    rWaySelect[NumberOfWays - 1:0]  <= 0;
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                sFT_CALST: begin
                    rOperationMode                  <= (wCapture)? iOpcode[0]:rOperationMode;
                    rSourceID[4:0]                  <= (wCapture)? iSourceID[4:0]:rSourceID[4:0];
                    rLength[7:0]                    <= (wCapture)? iLength[7:0]:rLength[7:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= (wCapture)? iWaySelect[NumberOfWays - 1:0]:rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_1000;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 15'h0001;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                sFT_CALD0: begin
                    rOperationMode                  <= rOperationMode;
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rLength[7:0]                    <= rLength[7:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 1'b0; 
                    rPM_CAData[7:0]                 <= 8'hEF;
                end
                sFT_CALD1: begin
                    rOperationMode                  <= rOperationMode;
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rLength[7:0]                    <= rLength[7:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 1'b1; 
                    rPM_CAData[7:0]                 <= rLength[7:0];
                end
                sFT_DO_ST: begin
                    rOperationMode                  <= rOperationMode;
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rLength[7:0]                    <= rLength[7:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_0100;
                    rPM_PCommandOption[2:0]         <= { 2'b00, rOperationMode }; 
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                sFT_TM1ST: begin
                    rOperationMode                  <= rOperationMode;
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rLength[7:0]                    <= rLength[7:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_0001;
                    rPM_PCommandOption[2:0]         <= 3'b001; 
                    rPM_NumOfData[15:0]             <= 16'd119; 
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                sFT_TM2ST: begin
                    rOperationMode                  <= rOperationMode;
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rLength[7:0]                    <= rLength[7:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 8'b0000_0001;
                    rPM_PCommandOption[2:0]         <= { 1'b1, rOperationMode, 1'b0 };
                    rPM_NumOfData[15:0]             <= 16'd3; 
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
                sFT_WAITD: begin
                    rOperationMode                  <= rOperationMode;
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    rLength[7:0]                    <= rLength[7:0];
                    rCMDReady                       <= 0;
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                end
            endcase
        end
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            r_pTF_cur_state <= pTF_RESET;
        end else begin
            r_pTF_cur_state <= r_pTF_nxt_state;
        end
    end
    always @ ( * ) begin
        case (r_pTF_cur_state)
        pTF_RESET: begin
            r_pTF_nxt_state <= pTF_READY;
        end
        pTF_READY: begin
            r_pTF_nxt_state <= (wPCGStart)? pTF_STADB:pTF_READY;
        end
        pTF_STADB: begin
            r_pTF_nxt_state <= (iWriteValid)? pTF_CAPTP:pTF_STADB;
        end
        pTF_CAPTP: begin
            r_pTF_nxt_state <= (rOperationMode)? pTF_PTDD0:pTF_PTSD0;
        end
        pTF_PTSD0: begin
            r_pTF_nxt_state <= (iPM_WriteReady)? pTF_PTSD1:pTF_PTSD0;
        end
        pTF_PTSD1: begin
            r_pTF_nxt_state <= (iPM_WriteReady)? pTF_PTSD2:pTF_PTSD1;
        end
        pTF_PTSD2: begin
            r_pTF_nxt_state <= (iPM_WriteReady)? pTF_PTSD3:pTF_PTSD2;
        end
        pTF_PTSD3: begin
            r_pTF_nxt_state <= (iPM_WriteReady)? pTF_WAITD:pTF_PTSD3;
        end
        pTF_PTDD0: begin
            r_pTF_nxt_state <= (iPM_WriteReady)? pTF_PTDD1:pTF_PTDD0;
        end
        pTF_PTDD1: begin
            r_pTF_nxt_state <= (iPM_WriteReady)? pTF_WAITD:pTF_PTDD1;
        end
        pTF_WAITD: begin
            r_pTF_nxt_state <= (wLastStep)? pTF_READY:pTF_WAITD;
        end
        default:
            r_pTF_nxt_state <= pTF_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rWriteReady         <= 0;
            rParameter[31:0]    <= 0;
            rPM_WriteData[31:0] <= 0;
            rPM_WriteLast       <= 0;
            rPM_WriteValid      <= 0;
        end else begin
            case (r_pTF_nxt_state)
                pTF_RESET: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= 0;
                    rPM_WriteData[31:0] <= 0;
                    rPM_WriteLast       <= 0;
                    rPM_WriteValid      <= 0;
                end
                pTF_READY: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= 0;
                    rPM_WriteData[31:0] <= 0;
                    rPM_WriteLast       <= 0;
                    rPM_WriteValid      <= 0;
                end
                pTF_STADB: begin
                    rWriteReady         <= 1'b1;
                    rParameter[31:0]    <= 0;
                    rPM_WriteData[31:0] <= 0;
                    rPM_WriteLast       <= 0;
                    rPM_WriteValid      <= 0;
                end
                pTF_CAPTP: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= iWriteData[31:0];
                    rPM_WriteData[31:0] <= 0;
                    rPM_WriteLast       <= 0;
                    rPM_WriteValid      <= 0;
                end
                pTF_PTSD0: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= rParameter[31:0];
                    rPM_WriteData[31:0] <= { rParameter[7:0], rParameter[7:0], rParameter[7:0], rParameter[7:0] };
                    rPM_WriteLast       <= 1'b0;
                    rPM_WriteValid      <= 1'b1;
                end
                pTF_PTSD1: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= rParameter[31:0];
                    rPM_WriteData[31:0] <= { rParameter[15:8], rParameter[15:8], rParameter[15:8], rParameter[15:8] };
                    rPM_WriteLast       <= 1'b0;
                    rPM_WriteValid      <= 1'b1;
                end
                pTF_PTSD2: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= rParameter[31:0];
                    rPM_WriteData[31:0] <= { rParameter[23:16], rParameter[23:16], rParameter[23:16], rParameter[23:16] };
                    rPM_WriteLast       <= 1'b0;
                    rPM_WriteValid      <= 1'b1;
                end
                pTF_PTSD3: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= rParameter[31:0];
                    rPM_WriteData[31:0] <= { rParameter[31:24], rParameter[31:24], rParameter[31:24], rParameter[31:24] };
                    rPM_WriteLast       <= 1'b1;
                    rPM_WriteValid      <= 1'b1;
                end
                pTF_PTDD0: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= rParameter[31:0];
                    rPM_WriteData[31:0] <= { rParameter[15:8], rParameter[15:8], rParameter[7:0], rParameter[7:0] };
                    rPM_WriteLast       <= 1'b0;
                    rPM_WriteValid      <= 1'b1;
                end
                pTF_PTDD1: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= rParameter[31:0];
                    rPM_WriteData[31:0] <= { rParameter[31:24], rParameter[31:24], rParameter[23:16], rParameter[23:16] };
                    rPM_WriteLast       <= 1'b1;
                    rPM_WriteValid      <= 1'b1;
                end
                pTF_WAITD: begin
                    rWriteReady         <= 0;
                    rParameter[31:0]    <= rParameter[31:0];
                    rPM_WriteData[31:0] <= 0;
                    rPM_WriteLast       <= 0;
                    rPM_WriteValid      <= 0;
                end
            endcase
        end
    end
    assign oCMDReady = rCMDReady;
    assign oStart = wPCGStart;
    assign oLastStep = wLastStep;
    assign oPM_PCommand[7:0] = rPM_PCommand[7:0];
    assign oPM_PCommandOption[2:0] = rPM_PCommandOption[2:0];
    assign oPM_TargetWay[NumberOfWays - 1:0] = rWaySelect[NumberOfWays - 1:0];
    assign oPM_NumOfData[15:0] = rPM_NumOfData[15:0];
    assign oPM_CASelect = rPM_CASelect;
    assign oPM_CAData[7:0] = rPM_CAData[7:0]; 
    assign oWriteReady = rWriteReady;
    assign oPM_WriteData[31:0] = rPM_WriteData[31:0];
    assign oPM_WriteLast = rPM_WriteLast;
    assign oPM_WriteValid = rPM_WriteValid;
endmodule
