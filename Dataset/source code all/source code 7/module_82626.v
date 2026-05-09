`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPCG_Toggle_bCMDMux
#
(
    parameter NumofbCMD = 12, 
    parameter NumberOfWays    =   4
)
(
    ibCMDReadySet                       ,
    iIDLE_WriteReady                    ,
    iIDLE_ReadData                      ,
    iIDLE_ReadLast                      ,
    iIDLE_ReadValid                     ,
    iIDLE_PM_PCommand                   ,
    iIDLE_PM_PCommandOption             ,
    iIDLE_PM_TargetWay                  ,
    iIDLE_PM_NumOfData                  ,
    iIDLE_PM_CASelect                   ,
    iIDLE_PM_CAData                     ,
    iIDLE_PM_WriteData                  ,
    iIDLE_PM_WriteLast                  ,
    iIDLE_PM_WriteValid                 ,
    iIDLE_PM_ReadReady                  ,
    iMNC_getFT_ReadData                 ,
    iMNC_getFT_ReadLast                 ,
    iMNC_getFT_ReadValid                ,
    iMNC_getFT_PM_PCommand              ,
    iMNC_getFT_PM_PCommandOption        ,
    iMNC_getFT_PM_TargetWay             ,
    iMNC_getFT_PM_NumOfData             ,
    iMNC_getFT_PM_CASelect              ,
    iMNC_getFT_PM_CAData                ,
    iMNC_getFT_PM_ReadReady             ,
    iSCC_N_poe_PM_PCommand              ,
    iSCC_N_poe_PM_PCommandOption        ,
    iSCC_N_poe_PM_NumOfData             ,
    iSCC_PI_reset_PM_PCommand           ,
    iSCC_PO_reset_PM_PCommand           ,
    iMNC_N_init_PM_PCommand             ,
    iMNC_N_init_PM_PCommandOption       ,
    iMNC_N_init_PM_TargetWay            ,
    iMNC_N_init_PM_NumOfData            ,
    iMNC_N_init_PM_CASelect             ,
    iMNC_N_init_PM_CAData               ,
    iMNC_readST_ReadData                ,
    iMNC_readST_ReadLast                ,
    iMNC_readST_ReadValid               ,
    iMNC_readST_PM_PCommand             ,
    iMNC_readST_PM_PCommandOption       ,
    iMNC_readST_PM_TargetWay            ,
    iMNC_readST_PM_NumOfData            ,
    iMNC_readST_PM_CASelect             ,
    iMNC_readST_PM_CAData               ,
    iMNC_readST_PM_ReadReady            ,
    iMNC_setFT_WriteReady               ,
    iMNC_setFT_PM_PCommand              ,
    iMNC_setFT_PM_PCommandOption        ,
    iMNC_setFT_PM_TargetWay             ,
    iMNC_setFT_PM_NumOfData             ,
    iMNC_setFT_PM_CASelect              ,
    iMNC_setFT_PM_CAData                ,
    iMNC_setFT_PM_WriteData             ,
    iMNC_setFT_PM_WriteLast             ,
    iMNC_setFT_PM_WriteValid            ,
    iBNC_B_erase_PM_PCommand            ,
    iBNC_B_erase_PM_PCommandOption      ,
    iBNC_B_erase_PM_TargetWay           ,
    iBNC_B_erase_PM_NumOfData           ,
    iBNC_B_erase_PM_CASelect            ,
    iBNC_B_erase_PM_CAData              ,
    iBNC_P_prog_WriteReady              ,
    iBNC_P_prog_PM_PCommand             ,
    iBNC_P_prog_PM_PCommandOption       ,
    iBNC_P_prog_PM_TargetWay            ,
    iBNC_P_prog_PM_NumOfData            ,
    iBNC_P_prog_PM_CASelect             ,
    iBNC_P_prog_PM_CAData               ,
    iBNC_P_prog_PM_WriteData            ,
    iBNC_P_prog_PM_WriteLast            ,
    iBNC_P_prog_PM_WriteValid           ,
    iBNC_P_read_DT00h_ReadData          ,
    iBNC_P_read_DT00h_ReadLast          ,
    iBNC_P_read_DT00h_ReadValid         ,
    iBNC_P_read_DT00h_PM_PCommand       ,
    iBNC_P_read_DT00h_PM_PCommandOption ,
    iBNC_P_read_DT00h_PM_TargetWay      ,
    iBNC_P_read_DT00h_PM_NumOfData      ,
    iBNC_P_read_DT00h_PM_CASelect       ,
    iBNC_P_read_DT00h_PM_CAData         ,
    iBNC_P_read_DT00h_PM_ReadReady      ,
    iBNC_P_read_AW30h_PM_PCommand       ,
    iBNC_P_read_AW30h_PM_PCommandOption ,
    iBNC_P_read_AW30h_PM_TargetWay      ,
    iBNC_P_read_AW30h_PM_NumOfData      ,
    iBNC_P_read_AW30h_PM_CASelect       ,
    iBNC_P_read_AW30h_PM_CAData         ,
    oWriteReady                         ,
    oReadData                           ,
    oReadLast                           ,
    oReadValid                          ,
    oPM_PCommand                        ,
    oPM_PCommandOption                  ,
    oPM_TargetWay                       ,
    oPM_NumOfData                       ,
    oPM_CASelect                        ,
    oPM_CAData                          ,
    oPM_WriteData                       ,
    oPM_WriteLast                       ,
    oPM_WriteValid                      ,
    oPM_ReadReady
);
    input   [NumofbCMD-1:0]             ibCMDReadySet                       ;
    input                               iIDLE_WriteReady                    ;
    input   [31:0]                      iIDLE_ReadData                      ;
    input                               iIDLE_ReadLast                      ;
    input                               iIDLE_ReadValid                     ;
    input   [7:0]                       iIDLE_PM_PCommand                   ;
    input   [2:0]                       iIDLE_PM_PCommandOption             ;
    input   [NumberOfWays - 1:0]        iIDLE_PM_TargetWay                  ;
    input   [15:0]                      iIDLE_PM_NumOfData                  ;
    input                               iIDLE_PM_CASelect                   ;
    input   [7:0]                       iIDLE_PM_CAData                     ;
    input   [31:0]                      iIDLE_PM_WriteData                  ;
    input                               iIDLE_PM_WriteLast                  ;
    input                               iIDLE_PM_WriteValid                 ;
    input                               iIDLE_PM_ReadReady                  ;
    input   [31:0]                      iMNC_getFT_ReadData                 ;
    input                               iMNC_getFT_ReadLast                 ;
    input                               iMNC_getFT_ReadValid                ;
    input   [7:0]                       iMNC_getFT_PM_PCommand              ;
    input   [2:0]                       iMNC_getFT_PM_PCommandOption        ;
    input   [NumberOfWays - 1:0]        iMNC_getFT_PM_TargetWay             ;
    input   [15:0]                      iMNC_getFT_PM_NumOfData             ;
    input                               iMNC_getFT_PM_CASelect              ;
    input   [7:0]                       iMNC_getFT_PM_CAData                ;
    input                               iMNC_getFT_PM_ReadReady             ;
    input   [7:0]                       iSCC_N_poe_PM_PCommand              ;
    input   [2:0]                       iSCC_N_poe_PM_PCommandOption        ;
    input   [15:0]                      iSCC_N_poe_PM_NumOfData             ;
    input   [7:0]                       iSCC_PI_reset_PM_PCommand           ;
    input   [7:0]                       iSCC_PO_reset_PM_PCommand           ;
    input   [7:0]                       iMNC_N_init_PM_PCommand             ;
    input   [2:0]                       iMNC_N_init_PM_PCommandOption       ;
    input   [NumberOfWays - 1:0]        iMNC_N_init_PM_TargetWay            ;
    input   [15:0]                      iMNC_N_init_PM_NumOfData            ;
    input                               iMNC_N_init_PM_CASelect             ;
    input   [7:0]                       iMNC_N_init_PM_CAData               ;
    input   [31:0]                      iMNC_readST_ReadData                ;
    input                               iMNC_readST_ReadLast                ;
    input                               iMNC_readST_ReadValid               ;
    input   [7:0]                       iMNC_readST_PM_PCommand             ;
    input   [2:0]                       iMNC_readST_PM_PCommandOption       ;
    input   [NumberOfWays - 1:0]        iMNC_readST_PM_TargetWay            ;
    input   [15:0]                      iMNC_readST_PM_NumOfData            ;
    input                               iMNC_readST_PM_CASelect             ;
    input   [7:0]                       iMNC_readST_PM_CAData               ;
    input                               iMNC_readST_PM_ReadReady            ;
    input                               iMNC_setFT_WriteReady               ;
    input   [7:0]                       iMNC_setFT_PM_PCommand              ;
    input   [2:0]                       iMNC_setFT_PM_PCommandOption        ;
    input   [NumberOfWays - 1:0]        iMNC_setFT_PM_TargetWay             ;
    input   [15:0]                      iMNC_setFT_PM_NumOfData             ;
    input                               iMNC_setFT_PM_CASelect              ;
    input   [7:0]                       iMNC_setFT_PM_CAData                ;
    input   [31:0]                      iMNC_setFT_PM_WriteData             ;
    input                               iMNC_setFT_PM_WriteLast             ;
    input                               iMNC_setFT_PM_WriteValid            ;
    input   [7:0]                       iBNC_B_erase_PM_PCommand            ;
    input   [2:0]                       iBNC_B_erase_PM_PCommandOption      ;
    input   [NumberOfWays - 1:0]        iBNC_B_erase_PM_TargetWay           ;
    input   [15:0]                      iBNC_B_erase_PM_NumOfData           ;
    input                               iBNC_B_erase_PM_CASelect            ;
    input   [7:0]                       iBNC_B_erase_PM_CAData              ;
    input                               iBNC_P_prog_WriteReady              ;
    input   [7:0]                       iBNC_P_prog_PM_PCommand             ;
    input   [2:0]                       iBNC_P_prog_PM_PCommandOption       ;
    input   [NumberOfWays - 1:0]        iBNC_P_prog_PM_TargetWay            ;
    input   [15:0]                      iBNC_P_prog_PM_NumOfData            ;
    input                               iBNC_P_prog_PM_CASelect             ;
    input   [7:0]                       iBNC_P_prog_PM_CAData               ;
    input   [31:0]                      iBNC_P_prog_PM_WriteData            ;
    input                               iBNC_P_prog_PM_WriteLast            ;
    input                               iBNC_P_prog_PM_WriteValid           ;
    input   [31:0]                      iBNC_P_read_DT00h_ReadData          ;
    input                               iBNC_P_read_DT00h_ReadLast          ;
    input                               iBNC_P_read_DT00h_ReadValid         ;
    input   [7:0]                       iBNC_P_read_DT00h_PM_PCommand       ;
    input   [2:0]                       iBNC_P_read_DT00h_PM_PCommandOption ;
    input   [NumberOfWays - 1:0]        iBNC_P_read_DT00h_PM_TargetWay      ;
    input   [15:0]                      iBNC_P_read_DT00h_PM_NumOfData      ;
    input                               iBNC_P_read_DT00h_PM_CASelect       ;
    input   [7:0]                       iBNC_P_read_DT00h_PM_CAData         ;
    input                               iBNC_P_read_DT00h_PM_ReadReady      ;
    input   [7:0]                       iBNC_P_read_AW30h_PM_PCommand       ;
    input   [2:0]                       iBNC_P_read_AW30h_PM_PCommandOption ;
    input   [NumberOfWays - 1:0]        iBNC_P_read_AW30h_PM_TargetWay      ;
    input   [15:0]                      iBNC_P_read_AW30h_PM_NumOfData      ;
    input                               iBNC_P_read_AW30h_PM_CASelect       ;
    input   [7:0]                       iBNC_P_read_AW30h_PM_CAData         ;
    output                              oWriteReady                         ;
    output  [31:0]                      oReadData                           ;
    output                              oReadLast                           ;
    output                              oReadValid                          ;
    output  [7:0]                       oPM_PCommand                        ;
    output  [2:0]                       oPM_PCommandOption                  ;
    output  [NumberOfWays - 1:0]        oPM_TargetWay                       ;
    output  [15:0]                      oPM_NumOfData                       ;
    output                              oPM_CASelect                        ;
    output  [7:0]                       oPM_CAData                          ;
    output  [31:0]                      oPM_WriteData                       ;
    output                              oPM_WriteLast                       ;
    output                              oPM_WriteValid                      ;
    output                              oPM_ReadReady                       ;
    wire    [NumofbCMD-1:0]         ibCMDActive             ;
    reg                             rWriteReady             ;
    reg     [31:0]                  rReadData               ;
    reg                             rReadLast               ;
    reg                             rReadValid              ;
    reg     [7:0]                   rPM_PCommand            ;
    reg     [2:0]                   rPM_PCommandOption      ;
    reg     [NumberOfWays - 1:0]    rPM_TargetWay           ;
    reg     [15:0]                  rPM_NumOfData           ;
    reg                             rPM_CASelect            ;
    reg     [7:0]                   rPM_CAData              ;
    reg     [31:0]                  rPM_WriteData           ;
    reg                             rPM_WriteLast           ;
    reg                             rPM_WriteValid          ;
    reg                             rPM_ReadReady           ;
    assign ibCMDActive[NumofbCMD-1:0] = ~ibCMDReadySet[NumofbCMD-1:0];
    always @ (*) begin
        if (ibCMDActive[ 4]) begin 
            rWriteReady <= iMNC_setFT_WriteReady;
        end else if (ibCMDActive[ 2]) begin 
            rWriteReady <= iBNC_P_prog_WriteReady;
        end else begin 
            rWriteReady <= iIDLE_WriteReady;
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rReadData[31:0] <= iMNC_getFT_ReadData[31:0];
        end else if (ibCMDActive[ 6]) begin 
            rReadData[31:0] <= iMNC_readST_ReadData[31:0];
        end else if (ibCMDActive[ 1]) begin 
            rReadData[31:0] <= iBNC_P_read_DT00h_ReadData[31:0];
        end else begin 
            rReadData[31:0] <= iIDLE_ReadData[31:0];
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rReadLast <= iMNC_getFT_ReadLast;
        end else if (ibCMDActive[ 6]) begin 
            rReadLast <= iMNC_readST_ReadLast;
        end else if (ibCMDActive[ 1]) begin 
            rReadLast <= iBNC_P_read_DT00h_ReadLast;
        end else begin 
            rReadLast <= iIDLE_ReadLast;
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rReadValid <= iMNC_getFT_ReadValid;
        end else if (ibCMDActive[ 6]) begin 
            rReadValid <= iMNC_readST_ReadValid;
        end else if (ibCMDActive[ 1]) begin 
            rReadValid <= iBNC_P_read_DT00h_ReadValid;
        end else begin 
            rReadValid <= iIDLE_ReadValid;
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rPM_PCommand[7:0] <= iMNC_getFT_PM_PCommand[7:0];
        end else if (ibCMDActive[10]) begin 
            rPM_PCommand[7:0] <= iSCC_N_poe_PM_PCommand[7:0];
        end else if (ibCMDActive[ 9]) begin 
            rPM_PCommand[7:0] <= iSCC_PI_reset_PM_PCommand[7:0];
        end else if (ibCMDActive[ 8]) begin 
            rPM_PCommand[7:0] <= iSCC_PO_reset_PM_PCommand[7:0];
        end else if (ibCMDActive[ 7]) begin 
            rPM_PCommand[7:0] <= iMNC_N_init_PM_PCommand[7:0];
        end else if (ibCMDActive[ 6]) begin 
            rPM_PCommand[7:0] <= iMNC_readST_PM_PCommand[7:0];
        end else if (ibCMDActive[ 4]) begin 
            rPM_PCommand[7:0] <= iMNC_setFT_PM_PCommand[7:0];
        end else if (ibCMDActive[ 3]) begin 
            rPM_PCommand[7:0] <= iBNC_B_erase_PM_PCommand[7:0];
        end else if (ibCMDActive[ 2]) begin 
            rPM_PCommand[7:0] <= iBNC_P_prog_PM_PCommand[7:0];
        end else if (ibCMDActive[ 1]) begin 
            rPM_PCommand[7:0] <= iBNC_P_read_DT00h_PM_PCommand[7:0];
        end else if (ibCMDActive[ 0]) begin 
            rPM_PCommand[7:0] <= iBNC_P_read_AW30h_PM_PCommand[7:0];
        end else begin 
            rPM_PCommand[7:0] <= iIDLE_PM_PCommand[7:0];
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rPM_PCommandOption[2:0] <= iMNC_getFT_PM_PCommandOption[2:0];
        end else if (ibCMDActive[10]) begin 
            rPM_PCommandOption[2:0] <= iSCC_N_poe_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 7]) begin 
            rPM_PCommandOption[2:0] <= iMNC_N_init_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 6]) begin 
            rPM_PCommandOption[2:0] <= iMNC_readST_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 4]) begin 
            rPM_PCommandOption[2:0] <= iMNC_setFT_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 3]) begin 
            rPM_PCommandOption[2:0] <= iBNC_B_erase_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 2]) begin 
            rPM_PCommandOption[2:0] <= iBNC_P_prog_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 1]) begin 
            rPM_PCommandOption[2:0] <= iBNC_P_read_DT00h_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 0]) begin 
            rPM_PCommandOption[2:0] <= iBNC_P_read_AW30h_PM_PCommandOption[2:0];
        end else begin 
            rPM_PCommandOption[2:0] <= iIDLE_PM_PCommandOption[2:0];
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_getFT_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 7]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_N_init_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 6]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_readST_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 4]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_setFT_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 3]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_B_erase_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 2]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_P_prog_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 1]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_P_read_DT00h_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 0]) begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_P_read_AW30h_PM_TargetWay[NumberOfWays - 1:0];
        end else begin 
            rPM_TargetWay[NumberOfWays - 1:0] <= iIDLE_PM_TargetWay[NumberOfWays - 1:0];
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rPM_NumOfData[15:0] <= iMNC_getFT_PM_NumOfData[15:0];
        end else if (ibCMDActive[10]) begin 
            rPM_NumOfData[15:0] <= iSCC_N_poe_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 7]) begin 
            rPM_NumOfData[15:0] <= iMNC_N_init_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 6]) begin 
            rPM_NumOfData[15:0] <= iMNC_readST_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 4]) begin 
            rPM_NumOfData[15:0] <= iMNC_setFT_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 3]) begin 
            rPM_NumOfData[15:0] <= iBNC_B_erase_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 2]) begin 
            rPM_NumOfData[15:0] <= iBNC_P_prog_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 1]) begin 
            rPM_NumOfData[15:0] <= iBNC_P_read_DT00h_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 0]) begin 
            rPM_NumOfData[15:0] <= iBNC_P_read_AW30h_PM_NumOfData[15:0];
        end else begin 
            rPM_NumOfData[15:0] <= iIDLE_PM_NumOfData[15:0];
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rPM_CASelect <= iMNC_getFT_PM_CASelect;
        end else if (ibCMDActive[ 7]) begin 
            rPM_CASelect <= iMNC_N_init_PM_CASelect;
        end else if (ibCMDActive[ 6]) begin 
            rPM_CASelect <= iMNC_readST_PM_CASelect;
        end else if (ibCMDActive[ 4]) begin 
            rPM_CASelect <= iMNC_setFT_PM_CASelect;
        end else if (ibCMDActive[ 3]) begin 
            rPM_CASelect <= iBNC_B_erase_PM_CASelect;
        end else if (ibCMDActive[ 2]) begin 
            rPM_CASelect <= iBNC_P_prog_PM_CASelect;
        end else if (ibCMDActive[ 1]) begin 
            rPM_CASelect <= iBNC_P_read_DT00h_PM_CASelect;
        end else if (ibCMDActive[ 0]) begin 
            rPM_CASelect <= iBNC_P_read_AW30h_PM_CASelect;
        end else begin 
            rPM_CASelect <= iIDLE_PM_CASelect;
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rPM_CAData[7:0] <= iMNC_getFT_PM_CAData[7:0];
        end else if (ibCMDActive[ 7]) begin 
            rPM_CAData[7:0] <= iMNC_N_init_PM_CAData[7:0];
        end else if (ibCMDActive[ 6]) begin 
            rPM_CAData[7:0] <= iMNC_readST_PM_CAData[7:0];
        end else if (ibCMDActive[ 4]) begin 
            rPM_CAData[7:0] <= iMNC_setFT_PM_CAData[7:0];
        end else if (ibCMDActive[ 3]) begin 
            rPM_CAData[7:0] <= iBNC_B_erase_PM_CAData[7:0];
        end else if (ibCMDActive[ 2]) begin 
            rPM_CAData[7:0] <= iBNC_P_prog_PM_CAData[7:0];
        end else if (ibCMDActive[ 1]) begin 
            rPM_CAData[7:0] <= iBNC_P_read_DT00h_PM_CAData[7:0];
        end else if (ibCMDActive[ 0]) begin 
            rPM_CAData[7:0] <= iBNC_P_read_AW30h_PM_CAData[7:0];
        end else begin 
            rPM_CAData[7:0] <= iIDLE_PM_CAData[7:0];
        end
    end
    always @ (*) begin
        if (ibCMDActive[ 4]) begin 
            rPM_WriteData[31:0] <= iMNC_setFT_PM_WriteData[31:0];
        end else if (ibCMDActive[ 2]) begin 
            rPM_WriteData[31:0] <= iBNC_P_prog_PM_WriteData[31:0];
        end else begin 
            rPM_WriteData[31:0] <= iIDLE_PM_WriteData[31:0];
        end
    end
    always @ (*) begin
        if (ibCMDActive[ 4]) begin 
            rPM_WriteLast <= iMNC_setFT_PM_WriteLast;
        end else if (ibCMDActive[ 2]) begin 
            rPM_WriteLast <= iBNC_P_prog_PM_WriteLast;
        end else begin 
            rPM_WriteLast <= iIDLE_PM_WriteLast;
        end
    end
    always @ (*) begin
        if (ibCMDActive[ 4]) begin 
            rPM_WriteValid <= iMNC_setFT_PM_WriteValid;
        end else if (ibCMDActive[ 2]) begin 
            rPM_WriteValid <= iBNC_P_prog_PM_WriteValid;
        end else begin 
            rPM_WriteValid <= iIDLE_PM_WriteValid;
        end
    end
    always @ (*) begin
        if (ibCMDActive[11]) begin 
            rPM_ReadReady <= iMNC_getFT_PM_ReadReady;
        end else if (ibCMDActive[ 6]) begin 
            rPM_ReadReady <= iMNC_readST_PM_ReadReady;
        end else if (ibCMDActive[ 1]) begin 
            rPM_ReadReady <= iBNC_P_read_DT00h_PM_ReadReady;
        end else begin 
            rPM_ReadReady <= iIDLE_PM_ReadReady;
        end
    end
    assign oWriteReady = rWriteReady;
    assign oReadData[31:0] = rReadData[31:0];
    assign oReadLast = rReadLast;
    assign oReadValid = rReadValid;
    assign oPM_PCommand[7:0] = rPM_PCommand[7:0];
    assign oPM_PCommandOption[2:0] = rPM_PCommandOption[2:0];
    assign oPM_TargetWay[NumberOfWays - 1:0] = rPM_TargetWay[NumberOfWays - 1:0];
    assign oPM_NumOfData[15:0] = rPM_NumOfData[15:0];
    assign oPM_CASelect = rPM_CASelect;
    assign oPM_CAData[7:0] = rPM_CAData[7:0];
    assign oPM_WriteData[31:0] = rPM_WriteData[31:0];
    assign oPM_WriteLast = rPM_WriteLast;
    assign oPM_WriteValid = rPM_WriteValid;
    assign oPM_ReadReady = rPM_ReadReady;
endmodule
