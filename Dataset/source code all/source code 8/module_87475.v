`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPCG_Toggle_Top
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock            ,
    iReset                  ,
    iOpcode                 ,
    iTargetID               ,
    iSourceID               ,
    iAddress                ,
    iLength                 ,
    iCMDValid               ,
    oCMDReady               ,
    iWriteData              ,
    iWriteLast              ,
    iWriteValid             ,
    oWriteReady             ,
    oReadData               ,
    oReadLast               ,
    oReadValid              ,
    iReadReady              ,
    oReadyBusy              ,
    iPM_Ready               ,
    iPM_LastStep            ,
    oPM_PCommand            ,
    oPM_PCommandOption      ,
    oPM_TargetWay           ,
    oPM_NumOfData           ,
    oPM_CEHold              ,
    oPM_NANDPowerOnEvent    ,
    oPM_CASelect            ,
    oPM_CAData              ,
    oPM_WriteData           ,
    oPM_WriteLast           ,
    oPM_WriteValid          ,
    iPM_WriteReady          ,
    iPM_ReadData            ,
    iPM_ReadLast            ,
    iPM_ReadValid           ,
    oPM_ReadReady           ,
    iReadyBusy
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    input   [5:0]                   iOpcode                 ;
    input   [4:0]                   iTargetID               ;
    input   [4:0]                   iSourceID               ;
    input   [31:0]                  iAddress                ;
    input   [15:0]                  iLength                 ;
    input                           iCMDValid               ;
    output                          oCMDReady               ;
    input   [31:0]                  iWriteData              ;
    input                           iWriteLast              ;
    input                           iWriteValid             ;
    output                          oWriteReady             ;
    output  [31:0]                  oReadData               ;
    output                          oReadLast               ;
    output                          oReadValid              ;
    input                           iReadReady              ;
    output  [NumberOfWays - 1:0]    oReadyBusy              ;
    input   [7:0]                   iPM_Ready               ;
    input   [7:0]                   iPM_LastStep            ;
    output  [7:0]                   oPM_PCommand            ;
    output  [2:0]                   oPM_PCommandOption      ;
    output  [NumberOfWays - 1:0]    oPM_TargetWay           ;
    output  [15:0]                  oPM_NumOfData           ;
    output                          oPM_CEHold              ;
    output                          oPM_NANDPowerOnEvent    ;
    output                          oPM_CASelect            ;
    output  [7:0]                   oPM_CAData              ;
    output  [31:0]                  oPM_WriteData           ;
    output                          oPM_WriteLast           ;
    output                          oPM_WriteValid          ;
    input                           iPM_WriteReady          ;
    input   [31:0]                  iPM_ReadData            ;
    input                           iPM_ReadLast            ;
    input                           iPM_ReadValid           ;
    output                          oPM_ReadReady           ;
    input   [NumberOfWays - 1:0]    iReadyBusy              ;
    localparam NumofbCMD = 12;
    reg                             rNANDPOE                ;
    reg     [3:0]                   rNANDPOECounter         ;
    wire                            wNANDPOECounterDone     ;
    reg                             rPM_NANDPowerOnEvent    ;
    reg     [7:0]                   rTargetWay1B            ;
    reg     [15:0]                  rColAddr2B              ;
    reg     [23:0]                  rRowAddr3B              ;
    wire    [15:0]                  wLength_m1              ;
    wire                            wTGC_waySELECT          ;
    wire                            wTGC_colADDR            ;
    wire                            wTGC_rowADDR            ;
    wire                            isNonbCMD               ;
    wire    [5:0]                   wOpcode_bCMD            ;
    wire    [4:0]                   wTargetID_bCMD          ;
    wire    [4:0]                   wSourceID_bCMD          ;
    wire                            wCMDValid_NPOE          ;
    wire                            wCMDValid_bCMD          ;
    wire                            wCMDReady_bCMD          ;
    wire    [NumberOfWays - 1:0]    wTargetWay              ;
    wire    [15:0]                  wTargetCol              ;
    wire    [23:0]                  wTargetRow              ;
    wire    [NumofbCMD - 1:0]       wbCMDReadySet           ;
    wire    [NumofbCMD - 1:0]       wbCMDStartSet           ;
    wire    [NumofbCMD - 1:0]       wbCMDLastSet            ;
    wire                            wbCMDReady              ; 
    wire                            wbCMDStart              ; 
    wire                            wbCMDLast               ; 
    wire                            wbCMDLast_SCC           ; 
    wire    [NumberOfWays - 1:0]    wWorkingWay             ;
    wire                            wCMDHold                ;
    wire                            wIDLE_WriteReady        ;
    wire    [31:0]                  wIDLE_ReadData          ;
    wire                            wIDLE_ReadLast          ;
    wire                            wIDLE_ReadValid         ;
    wire    [7:0]                   wIDLE_PM_PCommand       ;
    wire    [2:0]                   wIDLE_PM_PCommandOption ;
    wire    [NumberOfWays - 1:0]    wIDLE_PM_TargetWay      ;
    wire    [15:0]                  wIDLE_PM_NumOfData      ;
    wire                            wIDLE_PM_CASelect       ;
    wire    [7:0]                   wIDLE_PM_CAData         ;
    wire    [31:0]                  wIDLE_PM_WriteData      ;
    wire                            wIDLE_PM_WriteLast      ;
    wire                            wIDLE_PM_WriteValid     ;
    wire                            wIDLE_PM_ReadReady      ;
    wire                            wMNC_getFT_Ready        ;
    wire                            wMNC_getFT_Start        ;
    wire                            wMNC_getFT_Last         ;
    wire    [31:0]                  wMNC_getFT_ReadData     ;
    wire                            wMNC_getFT_ReadLast     ;
    wire                            wMNC_getFT_ReadValid    ;
    wire    [7:0]                   wMNC_getFT_PM_PCommand  ;
    wire    [2:0]                   wMNC_getFT_PM_PCommandOption;
    wire    [NumberOfWays - 1:0]    wMNC_getFT_PM_TargetWay ;
    wire    [15:0]                  wMNC_getFT_PM_NumOfData ;
    wire                            wMNC_getFT_PM_CASelect  ;
    wire    [7:0]                   wMNC_getFT_PM_CAData    ;
    wire                            wMNC_getFT_PM_ReadReady ;
    wire                            wSCC_N_poe_Ready       ;
    wire                            wSCC_N_poe_Start       ;
    wire                            wSCC_N_poe_Last        ;
    wire    [7:0]                   wSCC_N_poe_PM_PCommand ;
    wire    [2:0]                   wSCC_N_poe_PM_PCommandOption;
    wire    [15:0]                  wSCC_N_poe_PM_NumOfData;
    wire                            wSCC_PI_reset_Ready       ;
    wire                            wSCC_PI_reset_Start       ;
    wire                            wSCC_PI_reset_Last        ;
    wire    [7:0]                   wSCC_PI_reset_PM_PCommand ;
    wire                            wSCC_PO_reset_Ready       ;
    wire                            wSCC_PO_reset_Start       ;
    wire                            wSCC_PO_reset_Last        ;
    wire    [7:0]                   wSCC_PO_reset_PM_PCommand ;
    wire                            wMNC_N_init_Ready       ;
    wire                            wMNC_N_init_Start       ;
    wire                            wMNC_N_init_Last        ;
    wire    [7:0]                   wMNC_N_init_PM_PCommand ;
    wire    [2:0]                   wMNC_N_init_PM_PCommandOption;
    wire    [NumberOfWays - 1:0]    wMNC_N_init_PM_TargetWay;
    wire    [15:0]                  wMNC_N_init_PM_NumOfData;
    wire                            wMNC_N_init_PM_CASelect ;
    wire    [7:0]                   wMNC_N_init_PM_CAData   ;
    wire                            wMNC_readST_Ready       ;
    wire                            wMNC_readST_Start       ;
    wire                            wMNC_readST_Last        ;
    wire    [31:0]                  wMNC_readST_ReadData    ;
    wire                            wMNC_readST_ReadLast    ;
    wire                            wMNC_readST_ReadValid   ;
    wire    [7:0]                   wMNC_readST_PM_PCommand ;
    wire    [2:0]                   wMNC_readST_PM_PCommandOption;
    wire    [NumberOfWays - 1:0]    wMNC_readST_PM_TargetWay;
    wire    [15:0]                  wMNC_readST_PM_NumOfData;
    wire                            wMNC_readST_PM_CASelect ;
    wire    [7:0]                   wMNC_readST_PM_CAData   ;
    wire                            wMNC_readST_PM_ReadReady;
    wire                            wMNC_setFT_Ready       ;
    wire                            wMNC_setFT_Start       ;
    wire                            wMNC_setFT_Last        ;
    wire                            wMNC_setFT_WriteReady        ;
    wire    [7:0]                   wMNC_setFT_PM_PCommand       ;
    wire    [2:0]                   wMNC_setFT_PM_PCommandOption ;
    wire    [NumberOfWays - 1:0]    wMNC_setFT_PM_TargetWay      ;
    wire    [15:0]                  wMNC_setFT_PM_NumOfData      ;
    wire                            wMNC_setFT_PM_CASelect       ;
    wire    [7:0]                   wMNC_setFT_PM_CAData         ;
    wire    [31:0]                  wMNC_setFT_PM_WriteData      ;
    wire                            wMNC_setFT_PM_WriteLast      ;
    wire                            wMNC_setFT_PM_WriteValid     ;
    wire                            wBNC_B_erase_Ready       ;
    wire                            wBNC_B_erase_Start       ;
    wire                            wBNC_B_erase_Last        ;
    wire    [7:0]                   wBNC_B_erase_PM_PCommand ;
    wire    [2:0]                   wBNC_B_erase_PM_PCommandOption;
    wire    [NumberOfWays - 1:0]    wBNC_B_erase_PM_TargetWay;
    wire    [15:0]                  wBNC_B_erase_PM_NumOfData;
    wire                            wBNC_B_erase_PM_CASelect ;
    wire    [7:0]                   wBNC_B_erase_PM_CAData   ;
    wire                            wBNC_P_prog_Ready       ;
    wire                            wBNC_P_prog_Start       ;
    wire                            wBNC_P_prog_Last        ;
    wire                            wBNC_P_prog_WriteReady        ;
    wire    [7:0]                   wBNC_P_prog_PM_PCommand       ;
    wire    [2:0]                   wBNC_P_prog_PM_PCommandOption ;
    wire    [NumberOfWays - 1:0]    wBNC_P_prog_PM_TargetWay      ;
    wire    [15:0]                  wBNC_P_prog_PM_NumOfData      ;
    wire                            wBNC_P_prog_PM_CASelect       ;
    wire    [7:0]                   wBNC_P_prog_PM_CAData         ;
    wire    [31:0]                  wBNC_P_prog_PM_WriteData      ;
    wire                            wBNC_P_prog_PM_WriteLast      ;
    wire                            wBNC_P_prog_PM_WriteValid     ;
    wire                            wBNC_P_read_DT00h_Ready       ;
    wire                            wBNC_P_read_DT00h_Start       ;
    wire                            wBNC_P_read_DT00h_Last        ;
    wire    [31:0]                  wBNC_P_read_DT00h_ReadData    ;
    wire                            wBNC_P_read_DT00h_ReadLast    ;
    wire                            wBNC_P_read_DT00h_ReadValid   ;
    wire    [7:0]                   wBNC_P_read_DT00h_PM_PCommand ;
    wire    [2:0]                   wBNC_P_read_DT00h_PM_PCommandOption;
    wire    [NumberOfWays - 1:0]    wBNC_P_read_DT00h_PM_TargetWay;
    wire    [15:0]                  wBNC_P_read_DT00h_PM_NumOfData;
    wire                            wBNC_P_read_DT00h_PM_CASelect ;
    wire    [7:0]                   wBNC_P_read_DT00h_PM_CAData   ;
    wire                            wBNC_P_read_DT00h_PM_ReadReady;
    wire                            wBNC_P_read_AW30h_Ready       ;
    wire                            wBNC_P_read_AW30h_Start       ;
    wire                            wBNC_P_read_AW30h_Last        ;
    wire    [7:0]                   wBNC_P_read_AW30h_PM_PCommand ;
    wire    [2:0]                   wBNC_P_read_AW30h_PM_PCommandOption;
    wire    [NumberOfWays - 1:0]    wBNC_P_read_AW30h_PM_TargetWay;
    wire    [15:0]                  wBNC_P_read_AW30h_PM_NumOfData;
    wire                            wBNC_P_read_AW30h_PM_CASelect ;
    wire    [7:0]                   wBNC_P_read_AW30h_PM_CAData   ;
    assign wTGC_waySELECT = (iTargetID[4:0] == 5'b00100) & (iOpcode[5:0] == 6'b000000) & (iCMDValid);
    assign wTGC_colADDR   = (iTargetID[4:0] == 5'b00100) & (iOpcode[5:0] == 6'b000010) & (iCMDValid);
    assign wTGC_rowADDR   = (iTargetID[4:0] == 5'b00100) & (iOpcode[5:0] == 6'b000100) & (iCMDValid);
    assign isNonbCMD =   wTGC_waySELECT     
                       | wTGC_colADDR       
                       | wTGC_rowADDR   ;   
    assign oCMDReady = (isNonbCMD)? (1'b1):(wCMDReady_bCMD);
    assign wTargetWay[NumberOfWays - 1:0] = rTargetWay1B[NumberOfWays - 1:0];
    assign wTargetCol[15:0] = rColAddr2B[15:0];
    assign wTargetRow[23:0] = rRowAddr3B[23:0];
    assign wNANDPOECounterDone = &(rNANDPOECounter[3:0]);
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rNANDPOE                <= 1'b1;
            rNANDPOECounter[3:0]    <= 4'b0000;
            rPM_NANDPowerOnEvent    <= 1'b1;
        end else begin
            rNANDPOE                <= (rNANDPOE)? ((wbCMDLastSet[10])? 1'b0:1'b1):1'b0;
            rNANDPOECounter[3:0]    <= (wNANDPOECounterDone)? (rNANDPOECounter[3:0]):(rNANDPOECounter[3:0] + 1'b1);
            rPM_NANDPowerOnEvent    <= (wNANDPOECounterDone)? 1'b0:1'b1;
        end
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rTargetWay1B[7:0]   <= 0;
            rColAddr2B[15:0]    <= 0;
            rRowAddr3B[23:0]    <= 0;
        end else begin
            if (wTGC_waySELECT) begin
                rTargetWay1B[7:0]   <= iAddress[7:0];
                rColAddr2B[15:0]    <= rColAddr2B[15:0];
                rRowAddr3B[23:0]    <= rRowAddr3B[23:0];
            end else if (wTGC_colADDR) begin
                rTargetWay1B[7:0]   <= rTargetWay1B[7:0];
                rColAddr2B[15:0]    <= iAddress[15:0];
                rRowAddr3B[23:0]    <= rRowAddr3B[23:0];
            end else if (wTGC_rowADDR) begin
                rTargetWay1B[7:0]   <= rTargetWay1B[7:0];
                rColAddr2B[15:0]    <= rColAddr2B[15:0];
                rRowAddr3B[23:0]    <= iAddress[23:0];
            end else begin
                rTargetWay1B[7:0]   <= rTargetWay1B[7:0];
                rColAddr2B[15:0]    <= rColAddr2B[15:0];
                rRowAddr3B[23:0]    <= rRowAddr3B[23:0];
            end
        end
    end
    assign wLength_m1[15:0] = iLength[15:0] - 1'b1;
    NPCG_Toggle_way_CE_timer
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    way_CE_condition_timer
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iWorkingWay            (wWorkingWay            ),
        .ibCMDLast              (wbCMDLast              ),
        .ibCMDLast_SCC          (wbCMDLast_SCC          ),
        .iTargetWay             (wTargetWay             ),
        .oCMDHold               (wCMDHold               )
    );
    NPCG_Toggle_bCMD_manager
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    blocking_CMD_manager
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iTargetWay             (wTargetWay             ),
        .ibCMDStart             (wbCMDStart             ),
        .ibCMDLast              (wbCMDLast              ),
        .ibCMDLast_SCC          (wbCMDLast_SCC          ),
        .iNANDPOE               (rNANDPOE               ),
        .iCMDHold               (wCMDHold               ),
        .iOpcode                (iOpcode                ),
        .iTargetID              (iTargetID              ),
        .iSourceID              (iSourceID              ),
        .oOpcode_out            (wOpcode_bCMD           ),
        .oTargetID_out          (wTargetID_bCMD         ),
        .oSourceID_out          (wSourceID_bCMD         ),
        .iCMDValid_in           (iCMDValid              ),
        .oCMDValid_out_NPOE     (wCMDValid_NPOE         ),
        .oCMDValid_out          (wCMDValid_bCMD         ),
        .oCMDReady_out          (wCMDReady_bCMD         ),
        .iCMDReady_in           (wbCMDReady             ),
        .oWorkingWay            (wWorkingWay            )
    );
    assign wbCMDReadySet[NumofbCMD-1:0] = { wMNC_getFT_Ready, wSCC_N_poe_Ready, wSCC_PI_reset_Ready, wSCC_PO_reset_Ready, wMNC_N_init_Ready, wMNC_readST_Ready, 1'b1, wMNC_setFT_Ready, wBNC_B_erase_Ready, wBNC_P_prog_Ready, wBNC_P_read_DT00h_Ready, wBNC_P_read_AW30h_Ready };
    assign wbCMDStartSet[NumofbCMD-1:0] = { wMNC_getFT_Start, wSCC_N_poe_Start, wSCC_PI_reset_Start, wSCC_PO_reset_Start, wMNC_N_init_Start, wMNC_readST_Start, 1'b0, wMNC_setFT_Start, wBNC_B_erase_Start, wBNC_P_prog_Start, wBNC_P_read_DT00h_Start, wBNC_P_read_AW30h_Start };
    assign wbCMDLastSet[NumofbCMD-1:0]  = { wMNC_getFT_Last, wSCC_N_poe_Last, wSCC_PI_reset_Last, wSCC_PO_reset_Last, wMNC_N_init_Last, wMNC_readST_Last, 1'b0, wMNC_setFT_Last, wBNC_B_erase_Last, wBNC_P_prog_Last, wBNC_P_read_DT00h_Last, wBNC_P_read_AW30h_Last };
    assign wbCMDReady = &(wbCMDReadySet); 
    assign wbCMDStart = |(wbCMDStartSet); 
    assign wbCMDLast  = |(wbCMDLastSet); 
    assign wbCMDLast_SCC = |({ wSCC_N_poe_Last, wSCC_PI_reset_Last, wSCC_PO_reset_Last });
    NPCG_Toggle_bCMD_IDLE
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_IDLE
    (
        .oWriteReady            (wIDLE_WriteReady       ),
        .oReadData              (wIDLE_ReadData         ),
        .oReadLast              (wIDLE_ReadLast         ),
        .oReadValid             (wIDLE_ReadValid        ),
        .oPM_PCommand           (wIDLE_PM_PCommand      ),
        .oPM_PCommandOption     (wIDLE_PM_PCommandOption),
        .oPM_TargetWay          (wIDLE_PM_TargetWay     ),
        .oPM_NumOfData          (wIDLE_PM_NumOfData     ),
        .oPM_CASelect           (wIDLE_PM_CASelect      ),
        .oPM_CAData             (wIDLE_PM_CAData        ),
        .oPM_WriteData          (wIDLE_PM_WriteData     ),
        .oPM_WriteLast          (wIDLE_PM_WriteLast     ),
        .oPM_WriteValid         (wIDLE_PM_WriteValid    ),
        .oPM_ReadReady          (wIDLE_PM_ReadReady     )
    );
    NPCG_Toggle_MNC_getFT
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_MNC_getFT
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iLength                (iLength[7:0]           ), 
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wMNC_getFT_Ready       ),
        .oReadData              (wMNC_getFT_ReadData    ),
        .oReadLast              (wMNC_getFT_ReadLast    ),
        .oReadValid             (wMNC_getFT_ReadValid   ),
        .iReadReady             (iReadReady             ),
        .iWaySelect             (wTargetWay             ),
        .oStart                 (wMNC_getFT_Start       ),
        .oLastStep              (wMNC_getFT_Last        ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wMNC_getFT_PM_PCommand ),
        .oPM_PCommandOption     (wMNC_getFT_PM_PCommandOption),
        .oPM_TargetWay          (wMNC_getFT_PM_TargetWay),
        .oPM_NumOfData          (wMNC_getFT_PM_NumOfData),
        .oPM_CASelect           (wMNC_getFT_PM_CASelect ),
        .oPM_CAData             (wMNC_getFT_PM_CAData   ),
        .iPM_ReadData           (iPM_ReadData           ),
        .iPM_ReadLast           (iPM_ReadLast           ),
        .iPM_ReadValid          (iPM_ReadValid          ),
        .oPM_ReadReady          (wMNC_getFT_PM_ReadReady)
    );
    NPCG_Toggle_SCC_N_poe
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_SCC_N_poe
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iCMDValid              (wCMDValid_NPOE         ),
        .oCMDReady              (wSCC_N_poe_Ready       ),
        .oStart                 (wSCC_N_poe_Start       ),
        .oLastStep              (wSCC_N_poe_Last        ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wSCC_N_poe_PM_PCommand ),
        .oPM_PCommandOption     (wSCC_N_poe_PM_PCommandOption),
        .oPM_NumOfData          (wSCC_N_poe_PM_NumOfData)
    );
    NPCG_Toggle_SCC_PI_reset
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_SCC_PI_reset
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wSCC_PI_reset_Ready    ),
        .oStart                 (wSCC_PI_reset_Start    ),
        .oLastStep              (wSCC_PI_reset_Last     ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wSCC_PI_reset_PM_PCommand)
    );
    NPCG_Toggle_SCC_PO_reset
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_SCC_PO_reset
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wSCC_PO_reset_Ready    ),
        .oStart                 (wSCC_PO_reset_Start    ),
        .oLastStep              (wSCC_PO_reset_Last     ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wSCC_PO_reset_PM_PCommand)
    );
    NPCG_Toggle_MNC_N_init
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_MNC_N_init
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wMNC_N_init_Ready      ),
        .iWaySelect             (wTargetWay             ),
        .oStart                 (wMNC_N_init_Start      ),
        .oLastStep              (wMNC_N_init_Last       ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wMNC_N_init_PM_PCommand),
        .oPM_PCommandOption     (wMNC_N_init_PM_PCommandOption),
        .oPM_TargetWay          (wMNC_N_init_PM_TargetWay),
        .oPM_NumOfData          (wMNC_N_init_PM_NumOfData),
        .oPM_CASelect           (wMNC_N_init_PM_CASelect),
        .oPM_CAData             (wMNC_N_init_PM_CAData  )
    );
    NPCG_Toggle_MNC_readST
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_MNC_readST
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wMNC_readST_Ready      ),
        .oReadData              (wMNC_readST_ReadData   ),
        .oReadLast              (wMNC_readST_ReadLast   ),
        .oReadValid             (wMNC_readST_ReadValid  ),
        .iReadReady             (iReadReady             ),
        .iWaySelect             (wTargetWay             ),
        .oStart                 (wMNC_readST_Start      ),
        .oLastStep              (wMNC_readST_Last       ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wMNC_readST_PM_PCommand),
        .oPM_PCommandOption     (wMNC_readST_PM_PCommandOption),
        .oPM_TargetWay          (wMNC_readST_PM_TargetWay),
        .oPM_NumOfData          (wMNC_readST_PM_NumOfData),
        .oPM_CASelect           (wMNC_readST_PM_CASelect),
        .oPM_CAData             (wMNC_readST_PM_CAData  ),
        .iPM_ReadData           (iPM_ReadData           ),
        .iPM_ReadLast           (iPM_ReadLast           ),
        .iPM_ReadValid          (iPM_ReadValid          ),
        .oPM_ReadReady          (wMNC_readST_PM_ReadReady)
    );
    NPCG_Toggle_MNC_setFT
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_MNC_setFT
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iLength                (iLength[7:0]           ), 
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wMNC_setFT_Ready       ),
        .iWriteData             (iWriteData             ),
        .iWriteLast             (iWriteLast             ),
        .iWriteValid            (iWriteValid            ),
        .oWriteReady            (wMNC_setFT_WriteReady  ),
        .iWaySelect             (wTargetWay             ),
        .oStart                 (wMNC_setFT_Start       ),
        .oLastStep              (wMNC_setFT_Last        ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wMNC_setFT_PM_PCommand ),
        .oPM_PCommandOption     (wMNC_setFT_PM_PCommandOption),
        .oPM_TargetWay          (wMNC_setFT_PM_TargetWay),
        .oPM_NumOfData          (wMNC_setFT_PM_NumOfData),
        .oPM_CASelect           (wMNC_setFT_PM_CASelect ),
        .oPM_CAData             (wMNC_setFT_PM_CAData   ),
        .oPM_WriteData          (wMNC_setFT_PM_WriteData),
        .oPM_WriteLast          (wMNC_setFT_PM_WriteLast),
        .oPM_WriteValid         (wMNC_setFT_PM_WriteValid),
        .iPM_WriteReady         (iPM_WriteReady         )
    );
    NPCG_Toggle_BNC_B_erase
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_BNC_B_erase
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wBNC_B_erase_Ready      ),
        .iWaySelect             (wTargetWay             ),
        .iColAddress            (wTargetCol             ),
        .iRowAddress            (wTargetRow             ),
        .oStart                 (wBNC_B_erase_Start      ),
        .oLastStep              (wBNC_B_erase_Last       ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wBNC_B_erase_PM_PCommand),
        .oPM_PCommandOption     (wBNC_B_erase_PM_PCommandOption),
        .oPM_TargetWay          (wBNC_B_erase_PM_TargetWay),
        .oPM_NumOfData          (wBNC_B_erase_PM_NumOfData),
        .oPM_CASelect           (wBNC_B_erase_PM_CASelect),
        .oPM_CAData             (wBNC_B_erase_PM_CAData  )
    );
    NPCG_Toggle_BNC_P_program
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_BNC_P_program
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iLength                (wLength_m1             ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wBNC_P_prog_Ready      ),
        .iWriteData             (iWriteData             ),
        .iWriteLast             (iWriteLast             ),
        .iWriteValid            (iWriteValid            ),
        .oWriteReady            (wBNC_P_prog_WriteReady ),
        .iWaySelect             (wTargetWay             ),
        .iColAddress            (wTargetCol             ),
        .iRowAddress            (wTargetRow             ),
        .oStart                 (wBNC_P_prog_Start      ),
        .oLastStep              (wBNC_P_prog_Last       ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wBNC_P_prog_PM_PCommand),
        .oPM_PCommandOption     (wBNC_P_prog_PM_PCommandOption),
        .oPM_TargetWay          (wBNC_P_prog_PM_TargetWay),
        .oPM_NumOfData          (wBNC_P_prog_PM_NumOfData),
        .oPM_CASelect           (wBNC_P_prog_PM_CASelect),
        .oPM_CAData             (wBNC_P_prog_PM_CAData  ),
        .oPM_WriteData          (wBNC_P_prog_PM_WriteData),
        .oPM_WriteLast          (wBNC_P_prog_PM_WriteLast),
        .oPM_WriteValid         (wBNC_P_prog_PM_WriteValid),
        .iPM_WriteReady         (iPM_WriteReady         )
    );
    NPCG_Toggle_BNC_P_read_DT00h
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_BNC_P_read_DT00h
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iLength                (wLength_m1             ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wBNC_P_read_DT00h_Ready),
        .oReadData              (wBNC_P_read_DT00h_ReadData),
        .oReadLast              (wBNC_P_read_DT00h_ReadLast),
        .oReadValid             (wBNC_P_read_DT00h_ReadValid),
        .iReadReady             (iReadReady             ),
        .iWaySelect             (wTargetWay             ),
        .iColAddress            (wTargetCol             ),
        .iRowAddress            (wTargetRow             ),
        .oStart                 (wBNC_P_read_DT00h_Start),
        .oLastStep              (wBNC_P_read_DT00h_Last),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wBNC_P_read_DT00h_PM_PCommand),
        .oPM_PCommandOption     (wBNC_P_read_DT00h_PM_PCommandOption),
        .oPM_TargetWay          (wBNC_P_read_DT00h_PM_TargetWay),
        .oPM_NumOfData          (wBNC_P_read_DT00h_PM_NumOfData),
        .oPM_CASelect           (wBNC_P_read_DT00h_PM_CASelect),
        .oPM_CAData             (wBNC_P_read_DT00h_PM_CAData),
        .iPM_ReadData           (iPM_ReadData           ),
        .iPM_ReadLast           (iPM_ReadLast           ),
        .iPM_ReadValid          (iPM_ReadValid          ),
        .oPM_ReadReady          (wBNC_P_read_DT00h_PM_ReadReady)
    );
    NPCG_Toggle_BNC_P_read_AW30h
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_BNC_P_read_AW30h
    (
        .iSystemClock           (iSystemClock           ),
        .iReset                 (iReset                 ),
        .iOpcode                (wOpcode_bCMD           ),
        .iTargetID              (wTargetID_bCMD         ),
        .iSourceID              (wSourceID_bCMD         ),
        .iCMDValid              (wCMDValid_bCMD         ),
        .oCMDReady              (wBNC_P_read_AW30h_Ready),
        .iWaySelect             (wTargetWay             ),
        .iColAddress            (wTargetCol             ),
        .iRowAddress            (wTargetRow             ),
        .oStart                 (wBNC_P_read_AW30h_Start),
        .oLastStep              (wBNC_P_read_AW30h_Last ),
        .iPM_Ready              (iPM_Ready              ),
        .iPM_LastStep           (iPM_LastStep           ),
        .oPM_PCommand           (wBNC_P_read_AW30h_PM_PCommand),
        .oPM_PCommandOption     (wBNC_P_read_AW30h_PM_PCommandOption),
        .oPM_TargetWay          (wBNC_P_read_AW30h_PM_TargetWay),
        .oPM_NumOfData          (wBNC_P_read_AW30h_PM_NumOfData),
        .oPM_CASelect           (wBNC_P_read_AW30h_PM_CASelect),
        .oPM_CAData             (wBNC_P_read_AW30h_PM_CAData)
    );
    NPCG_Toggle_bCMDMux
    #
    (
        .NumofbCMD              (NumofbCMD              ),
        .NumberOfWays           (NumberOfWays           )
    )
    bCMD_Mux
    (
        .ibCMDReadySet          (wbCMDReadySet          ),
        .iIDLE_WriteReady       (wIDLE_WriteReady       ),
        .iIDLE_ReadData         (wIDLE_ReadData         ),
        .iIDLE_ReadLast         (wIDLE_ReadLast         ),
        .iIDLE_ReadValid        (wIDLE_ReadValid        ),
        .iIDLE_PM_PCommand      (wIDLE_PM_PCommand      ),
        .iIDLE_PM_PCommandOption(wIDLE_PM_PCommandOption),
        .iIDLE_PM_TargetWay     (wIDLE_PM_TargetWay     ),
        .iIDLE_PM_NumOfData     (wIDLE_PM_NumOfData     ),
        .iIDLE_PM_CASelect      (wIDLE_PM_CASelect      ),
        .iIDLE_PM_CAData        (wIDLE_PM_CAData        ),
        .iIDLE_PM_WriteData     (wIDLE_PM_WriteData     ),
        .iIDLE_PM_WriteLast     (wIDLE_PM_WriteLast     ),
        .iIDLE_PM_WriteValid    (wIDLE_PM_WriteValid    ),
        .iIDLE_PM_ReadReady     (wIDLE_PM_ReadReady     ),
        .iMNC_getFT_ReadData    (wMNC_getFT_ReadData    ),
        .iMNC_getFT_ReadLast    (wMNC_getFT_ReadLast    ),
        .iMNC_getFT_ReadValid   (wMNC_getFT_ReadValid   ),
        .iMNC_getFT_PM_PCommand (wMNC_getFT_PM_PCommand ),
        .iMNC_getFT_PM_PCommandOption(wMNC_getFT_PM_PCommandOption),
        .iMNC_getFT_PM_TargetWay(wMNC_getFT_PM_TargetWay),
        .iMNC_getFT_PM_NumOfData(wMNC_getFT_PM_NumOfData),
        .iMNC_getFT_PM_CASelect (wMNC_getFT_PM_CASelect ),
        .iMNC_getFT_PM_CAData   (wMNC_getFT_PM_CAData   ),
        .iMNC_getFT_PM_ReadReady(wMNC_getFT_PM_ReadReady),
        .iSCC_N_poe_PM_PCommand (wSCC_N_poe_PM_PCommand ),
        .iSCC_N_poe_PM_PCommandOption(wSCC_N_poe_PM_PCommandOption),
        .iSCC_N_poe_PM_NumOfData(wSCC_N_poe_PM_NumOfData),
        .iSCC_PI_reset_PM_PCommand(wSCC_PI_reset_PM_PCommand),
        .iSCC_PO_reset_PM_PCommand(wSCC_PO_reset_PM_PCommand),
        .iMNC_N_init_PM_PCommand(wMNC_N_init_PM_PCommand),
        .iMNC_N_init_PM_PCommandOption(wMNC_N_init_PM_PCommandOption),
        .iMNC_N_init_PM_TargetWay(wMNC_N_init_PM_TargetWay),
        .iMNC_N_init_PM_NumOfData(wMNC_N_init_PM_NumOfData),
        .iMNC_N_init_PM_CASelect(wMNC_N_init_PM_CASelect),
        .iMNC_N_init_PM_CAData(wMNC_N_init_PM_CAData),
        .iMNC_readST_ReadData   (wMNC_readST_ReadData   ),
        .iMNC_readST_ReadLast   (wMNC_readST_ReadLast   ),
        .iMNC_readST_ReadValid  (wMNC_readST_ReadValid  ),
        .iMNC_readST_PM_PCommand(wMNC_readST_PM_PCommand),
        .iMNC_readST_PM_PCommandOption(wMNC_readST_PM_PCommandOption),
        .iMNC_readST_PM_TargetWay(wMNC_readST_PM_TargetWay),
        .iMNC_readST_PM_NumOfData(wMNC_readST_PM_NumOfData),
        .iMNC_readST_PM_CASelect(wMNC_readST_PM_CASelect),
        .iMNC_readST_PM_CAData  (wMNC_readST_PM_CAData  ),
        .iMNC_readST_PM_ReadReady(wMNC_readST_PM_ReadReady),
        .iMNC_setFT_WriteReady (wMNC_setFT_WriteReady),
        .iMNC_setFT_PM_PCommand(wMNC_setFT_PM_PCommand),
        .iMNC_setFT_PM_PCommandOption(wMNC_setFT_PM_PCommandOption),
        .iMNC_setFT_PM_TargetWay(wMNC_setFT_PM_TargetWay),
        .iMNC_setFT_PM_NumOfData(wMNC_setFT_PM_NumOfData),
        .iMNC_setFT_PM_CASelect(wMNC_setFT_PM_CASelect),
        .iMNC_setFT_PM_CAData  (wMNC_setFT_PM_CAData  ),
        .iMNC_setFT_PM_WriteData(wMNC_setFT_PM_WriteData),
        .iMNC_setFT_PM_WriteLast(wMNC_setFT_PM_WriteLast),
        .iMNC_setFT_PM_WriteValid(wMNC_setFT_PM_WriteValid),
        .iBNC_B_erase_PM_PCommand(wBNC_B_erase_PM_PCommand),
        .iBNC_B_erase_PM_PCommandOption(wBNC_B_erase_PM_PCommandOption),
        .iBNC_B_erase_PM_TargetWay(wBNC_B_erase_PM_TargetWay),
        .iBNC_B_erase_PM_NumOfData(wBNC_B_erase_PM_NumOfData),
        .iBNC_B_erase_PM_CASelect(wBNC_B_erase_PM_CASelect),
        .iBNC_B_erase_PM_CAData (wBNC_B_erase_PM_CAData),
        .iBNC_P_prog_WriteReady (wBNC_P_prog_WriteReady),
        .iBNC_P_prog_PM_PCommand(wBNC_P_prog_PM_PCommand),
        .iBNC_P_prog_PM_PCommandOption(wBNC_P_prog_PM_PCommandOption),
        .iBNC_P_prog_PM_TargetWay(wBNC_P_prog_PM_TargetWay),
        .iBNC_P_prog_PM_NumOfData(wBNC_P_prog_PM_NumOfData),
        .iBNC_P_prog_PM_CASelect(wBNC_P_prog_PM_CASelect),
        .iBNC_P_prog_PM_CAData  (wBNC_P_prog_PM_CAData  ),
        .iBNC_P_prog_PM_WriteData(wBNC_P_prog_PM_WriteData),
        .iBNC_P_prog_PM_WriteLast(wBNC_P_prog_PM_WriteLast),
        .iBNC_P_prog_PM_WriteValid(wBNC_P_prog_PM_WriteValid),
        .iBNC_P_read_DT00h_ReadData   (wBNC_P_read_DT00h_ReadData   ),
        .iBNC_P_read_DT00h_ReadLast   (wBNC_P_read_DT00h_ReadLast   ),
        .iBNC_P_read_DT00h_ReadValid  (wBNC_P_read_DT00h_ReadValid  ),
        .iBNC_P_read_DT00h_PM_PCommand(wBNC_P_read_DT00h_PM_PCommand),
        .iBNC_P_read_DT00h_PM_PCommandOption(wBNC_P_read_DT00h_PM_PCommandOption),
        .iBNC_P_read_DT00h_PM_TargetWay(wBNC_P_read_DT00h_PM_TargetWay),
        .iBNC_P_read_DT00h_PM_NumOfData(wBNC_P_read_DT00h_PM_NumOfData),
        .iBNC_P_read_DT00h_PM_CASelect(wBNC_P_read_DT00h_PM_CASelect),
        .iBNC_P_read_DT00h_PM_CAData  (wBNC_P_read_DT00h_PM_CAData  ),
        .iBNC_P_read_DT00h_PM_ReadReady(wBNC_P_read_DT00h_PM_ReadReady),
        .iBNC_P_read_AW30h_PM_PCommand(wBNC_P_read_AW30h_PM_PCommand),
        .iBNC_P_read_AW30h_PM_PCommandOption(wBNC_P_read_AW30h_PM_PCommandOption),
        .iBNC_P_read_AW30h_PM_TargetWay(wBNC_P_read_AW30h_PM_TargetWay),
        .iBNC_P_read_AW30h_PM_NumOfData(wBNC_P_read_AW30h_PM_NumOfData),
        .iBNC_P_read_AW30h_PM_CASelect(wBNC_P_read_AW30h_PM_CASelect),
        .iBNC_P_read_AW30h_PM_CAData(wBNC_P_read_AW30h_PM_CAData),
        .oWriteReady            (oWriteReady),
        .oReadData              (oReadData),
        .oReadLast              (oReadLast),
        .oReadValid             (oReadValid),
        .oPM_PCommand           (oPM_PCommand),
        .oPM_PCommandOption     (oPM_PCommandOption),
        .oPM_TargetWay          (oPM_TargetWay),
        .oPM_NumOfData          (oPM_NumOfData),
        .oPM_CASelect           (oPM_CASelect),
        .oPM_CAData             (oPM_CAData),
        .oPM_WriteData          (oPM_WriteData),
        .oPM_WriteLast          (oPM_WriteLast),
        .oPM_WriteValid         (oPM_WriteValid),
        .oPM_ReadReady          (oPM_ReadReady)
    );
    assign oPM_CEHold = 1'b0;
    assign oPM_NANDPowerOnEvent = rPM_NANDPowerOnEvent;
    assign oReadyBusy = iReadyBusy;
endmodule
