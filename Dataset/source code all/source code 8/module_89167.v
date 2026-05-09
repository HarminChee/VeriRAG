`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPM_Toggle_PHYOutMux
#
(
    parameter NumberOfWays    =   4
)
(
    iPCommand                   ,
    iCEHold                     ,
    iCEHold_ChipEnable          ,
    iPBR_PI_BUFF_Reset          ,
    iPBR_PI_BUFF_RE             ,
    iPBR_PI_BUFF_WE             ,
    iPBR_PO_DQStrobe            ,
    iPBR_DQSOutEnable           ,
    iPOR_PO_Reset               ,
    iPIR_PI_Reset               ,
    iIDLE_PI_Reset              ,
    iIDLE_PI_BUFF_Reset         ,
    iIDLE_PO_Reset              ,
    iIDLE_PI_BUFF_RE            ,
    iIDLE_PI_BUFF_WE            ,
    iIDLE_PI_BUFF_OutSel        ,
    iIDLE_PIDelayTapLoad        ,
    iIDLE_PIDelayTap            ,
    iIDLE_PO_DQStrobe           ,
    iIDLE_PO_DQ                 ,
    iIDLE_PO_ChipEnable         ,
    iIDLE_PO_ReadEnable         ,
    iIDLE_PO_WriteEnable        ,
    iIDLE_PO_AddressLatchEnable ,
    iIDLE_PO_CommandLatchEnable ,
    iIDLE_DQSOutEnable          ,
    iIDLE_DQOutEnable           ,
    iCAL_PO_DQStrobe            ,
    iCAL_PO_DQ                  ,
    iCAL_PO_ChipEnable          ,
    iCAL_PO_WriteEnable         ,
    iCAL_PO_AddressLatchEnable  ,
    iCAL_PO_CommandLatchEnable  ,
    iCAL_DQSOutEnable           ,
    iCAL_DQOutEnable            ,
    iDO_PO_DQStrobe             ,
    iDO_PO_DQ                   ,
    iDO_PO_ChipEnable           ,
    iDO_PO_WriteEnable          ,
    iDO_PO_AddressLatchEnable   ,
    iDO_PO_CommandLatchEnable   ,
    iDO_DQSOutEnable            ,
    iDO_DQOutEnable             ,
    iDI_PI_BUFF_RE              ,
    iDI_PI_BUFF_WE              ,
    iDI_PI_BUFF_OutSel          ,
    iDI_PO_ChipEnable           ,
    iDI_PO_ReadEnable           ,
    iDI_PO_WriteEnable          ,
    iDI_PO_AddressLatchEnable   ,
    iDI_PO_CommandLatchEnable   ,
    iDI_DQSOutEnable            ,
    iDI_DQOutEnable             ,
    iTM_PO_DQStrobe             ,
    iTM_PO_ChipEnable           ,
    iTM_PO_ReadEnable           ,
    iTM_PO_WriteEnable          ,
    iTM_PO_AddressLatchEnable   ,
    iTM_PO_CommandLatchEnable   ,
    iTM_DQSOutEnable            ,
    oPI_Reset                   ,
    oPI_BUFF_Reset              ,
    oPO_Reset                   ,
    oPI_BUFF_RE                 ,
    oPI_BUFF_WE                 ,
    oPI_BUFF_OutSel             ,
    oPIDelayTapLoad             ,
    oPIDelayTap                 ,
    oPO_DQStrobe                ,
    oPO_DQ                      ,
    oPO_ChipEnable              ,
    oPO_ReadEnable              ,
    oPO_WriteEnable             ,
    oPO_AddressLatchEnable      ,
    oPO_CommandLatchEnable      ,
    oDQSOutEnable               ,
    oDQOutEnable            
);
    input   [7:0]                   iPCommand                   ;
    input                           iCEHold                     ;
    input   [2*NumberOfWays - 1:0]  iCEHold_ChipEnable          ;
    input                           iPBR_PI_BUFF_Reset          ;
    input                           iPBR_PI_BUFF_RE             ;
    input                           iPBR_PI_BUFF_WE             ;
    input   [7:0]                   iPBR_PO_DQStrobe            ;
    input                           iPBR_DQSOutEnable           ;
    input                           iPOR_PO_Reset               ;
    input                           iPIR_PI_Reset               ;
    input                           iIDLE_PI_Reset              ;
    input                           iIDLE_PI_BUFF_Reset         ;
    input                           iIDLE_PO_Reset              ;
    input                           iIDLE_PI_BUFF_RE            ;
    input                           iIDLE_PI_BUFF_WE            ;
    input   [2:0]                   iIDLE_PI_BUFF_OutSel        ;
    input                           iIDLE_PIDelayTapLoad        ;
    input   [4:0]                   iIDLE_PIDelayTap            ;
    input   [7:0]                   iIDLE_PO_DQStrobe           ;
    input   [31:0]                  iIDLE_PO_DQ                 ;
    input   [2*NumberOfWays - 1:0]  iIDLE_PO_ChipEnable         ;
    input   [3:0]                   iIDLE_PO_ReadEnable         ;
    input   [3:0]                   iIDLE_PO_WriteEnable        ;
    input   [3:0]                   iIDLE_PO_AddressLatchEnable ;
    input   [3:0]                   iIDLE_PO_CommandLatchEnable ;
    input                           iIDLE_DQSOutEnable          ;
    input                           iIDLE_DQOutEnable           ;
    input   [7:0]                   iCAL_PO_DQStrobe            ;
    input   [31:0]                  iCAL_PO_DQ                  ;
    input   [2*NumberOfWays - 1:0]  iCAL_PO_ChipEnable          ;
    input   [3:0]                   iCAL_PO_WriteEnable         ;
    input   [3:0]                   iCAL_PO_AddressLatchEnable  ;
    input   [3:0]                   iCAL_PO_CommandLatchEnable  ;
    input                           iCAL_DQSOutEnable           ;
    input                           iCAL_DQOutEnable            ;
    input   [7:0]                   iDO_PO_DQStrobe             ;
    input   [31:0]                  iDO_PO_DQ                   ;
    input   [2*NumberOfWays - 1:0]  iDO_PO_ChipEnable           ;
    input   [3:0]                   iDO_PO_WriteEnable          ;
    input   [3:0]                   iDO_PO_AddressLatchEnable   ;
    input   [3:0]                   iDO_PO_CommandLatchEnable   ;
    input                           iDO_DQSOutEnable            ;
    input                           iDO_DQOutEnable             ;
    input                           iDI_PI_BUFF_RE              ;
    input                           iDI_PI_BUFF_WE              ;
    input   [2:0]                   iDI_PI_BUFF_OutSel          ;
    input   [2*NumberOfWays - 1:0]  iDI_PO_ChipEnable           ;
    input   [3:0]                   iDI_PO_ReadEnable           ;
    input   [3:0]                   iDI_PO_WriteEnable          ;
    input   [3:0]                   iDI_PO_AddressLatchEnable   ;
    input   [3:0]                   iDI_PO_CommandLatchEnable   ;
    input                           iDI_DQSOutEnable            ;
    input                           iDI_DQOutEnable             ;
    input   [7:0]                   iTM_PO_DQStrobe             ;
    input   [2*NumberOfWays - 1:0]  iTM_PO_ChipEnable           ;
    input   [3:0]                   iTM_PO_ReadEnable           ;
    input   [3:0]                   iTM_PO_WriteEnable          ;
    input   [3:0]                   iTM_PO_AddressLatchEnable   ;
    input   [3:0]                   iTM_PO_CommandLatchEnable   ;
    input                           iTM_DQSOutEnable            ;
    output                          oPI_Reset                   ;
    output                          oPI_BUFF_Reset              ;
    output                          oPO_Reset                   ;
    output                          oPI_BUFF_RE                 ;
    output                          oPI_BUFF_WE                 ;
    output  [2:0]                   oPI_BUFF_OutSel             ;
    output                          oPIDelayTapLoad             ;
    output  [4:0]                   oPIDelayTap                 ;
    output  [7:0]                   oPO_DQStrobe                ;
    output  [31:0]                  oPO_DQ                      ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable              ;
    output  [3:0]                   oPO_ReadEnable              ;
    output  [3:0]                   oPO_WriteEnable             ;
    output  [3:0]                   oPO_AddressLatchEnable      ;
    output  [3:0]                   oPO_CommandLatchEnable      ;
    output                          oDQSOutEnable               ;
    output                          oDQOutEnable                ;
    wire                            wPM_idle                ;
    reg                             rPI_Reset               ;
    reg                             rPI_BUFF_Reset          ;
    reg                             rPO_Reset               ;
    reg                             rPI_BUFF_RE             ;
    reg                             rPI_BUFF_WE             ;
    reg     [2:0]                   rPI_BUFF_OutSel         ;
    reg                             rPIDelayTapLoad         ;
    reg     [4:0]                   rPIDelayTap             ;
    reg     [7:0]                   rPO_DQStrobe            ;
    reg     [31:0]                  rPO_DQ                  ;
    reg     [2*NumberOfWays - 1:0]  rPO_ChipEnable          ;
    reg     [3:0]                   rPO_ReadEnable          ;
    reg     [3:0]                   rPO_WriteEnable         ;
    reg     [3:0]                   rPO_AddressLatchEnable  ;
    reg     [3:0]                   rPO_CommandLatchEnable  ;
    reg                             rDQSOutEnable           ;
    reg                             rDQOutEnable            ;
    assign wPM_idle = ~( |(iPCommand[7:0]) );
    always @ (*) begin
        if (iPCommand[4]) begin 
            rPI_Reset <= iPIR_PI_Reset;
        end else begin 
            rPI_Reset <= iIDLE_PI_Reset;
        end
    end
    always @ (*) begin
        if (iPCommand[6]) begin 
            rPI_BUFF_Reset <= iPBR_PI_BUFF_Reset;
        end else begin 
            rPI_BUFF_Reset <= iIDLE_PI_BUFF_Reset;
        end
    end
    always @ (*) begin
        if (iPCommand[5]) begin 
            rPO_Reset <= iPOR_PO_Reset;
        end else begin 
            rPO_Reset <= iIDLE_PO_Reset;
        end
    end
    always @ (*) begin
        if (iPCommand[6]) begin 
            rPI_BUFF_RE <= iPBR_PI_BUFF_RE;
        end else if (iPCommand[1]) begin 
            rPI_BUFF_RE <= iDI_PI_BUFF_RE;
        end else begin 
            rPI_BUFF_RE <= iIDLE_PI_BUFF_RE;
        end
    end
    always @ (*) begin
        if (iPCommand[6]) begin 
            rPI_BUFF_WE <= iPBR_PI_BUFF_WE;
        end else if (iPCommand[1]) begin 
            rPI_BUFF_WE <= iDI_PI_BUFF_WE;
        end else begin 
            rPI_BUFF_WE <= iIDLE_PI_BUFF_WE;
        end
    end
    always @ (*) begin
        if (iPCommand[1]) begin 
            rPI_BUFF_OutSel[2:0] <= iDI_PI_BUFF_OutSel[2:0];
        end else begin 
            rPI_BUFF_OutSel[2:0] <= iIDLE_PI_BUFF_OutSel[2:0];
        end
    end
    always @ (*) begin
            rPIDelayTapLoad <= iIDLE_PIDelayTapLoad;
    end
    always @ (*) begin
            rPIDelayTap[4:0] <= iIDLE_PIDelayTap[4:0];
    end
    always @ (*) begin
        if (iPCommand[6]) begin 
            rPO_DQStrobe[7:0] <= iPBR_PO_DQStrobe[7:0];
        end else if (iPCommand[3]) begin 
            rPO_DQStrobe[7:0] <= iCAL_PO_DQStrobe[7:0];
        end else if (iPCommand[2]) begin 
            rPO_DQStrobe[7:0] <= iDO_PO_DQStrobe[7:0];
        end else if (iPCommand[0]) begin 
            rPO_DQStrobe[7:0] <= iTM_PO_DQStrobe[7:0];
        end else begin 
            rPO_DQStrobe[7:0] <= iIDLE_PO_DQStrobe[7:0];
        end
    end
    always @ (*) begin
        if (iPCommand[3]) begin 
            rPO_DQ[31:0] <= iCAL_PO_DQ[31:0];
        end else if (iPCommand[2]) begin 
            rPO_DQ[31:0] <= iDO_PO_DQ[31:0];
        end else begin 
            rPO_DQ[31:0] <= iIDLE_PO_DQ[31:0];
        end
    end
    always @ (*) begin
        if (wPM_idle) begin 
            rPO_ChipEnable <= (iCEHold)? iCEHold_ChipEnable:iIDLE_PO_ChipEnable;
        end else if (iPCommand[3]) begin 
            rPO_ChipEnable <= iCAL_PO_ChipEnable;
        end else if (iPCommand[2]) begin 
            rPO_ChipEnable <= iDO_PO_ChipEnable;
        end else if (iPCommand[1]) begin 
            rPO_ChipEnable <= iDI_PO_ChipEnable;
        end else if (iPCommand[0]) begin 
            rPO_ChipEnable <= iTM_PO_ChipEnable;
        end else begin 
            rPO_ChipEnable <= iIDLE_PO_ChipEnable;
        end
    end
    always @ (*) begin
        if (iPCommand[1]) begin 
            rPO_ReadEnable[3:0] <= iDI_PO_ReadEnable[3:0];
        end else if (iPCommand[0]) begin 
            rPO_ReadEnable[3:0] <= iTM_PO_ReadEnable[3:0];
        end else begin 
            rPO_ReadEnable[3:0] <= iIDLE_PO_ReadEnable[3:0];
        end
    end
    always @ (*) begin
        if (iPCommand[3]) begin 
            rPO_WriteEnable[3:0] <= iCAL_PO_WriteEnable[3:0];
        end else if (iPCommand[2]) begin 
            rPO_WriteEnable[3:0] <= iDO_PO_WriteEnable[3:0];
        end else if (iPCommand[1]) begin 
            rPO_WriteEnable[3:0] <= iDI_PO_WriteEnable[3:0];
        end else if (iPCommand[0]) begin 
            rPO_WriteEnable[3:0] <= iTM_PO_WriteEnable[3:0];
        end else begin 
            rPO_WriteEnable[3:0] <= iIDLE_PO_WriteEnable[3:0];
        end
    end
    always @ (*) begin
        if (iPCommand[3]) begin 
            rPO_AddressLatchEnable[3:0] <= iCAL_PO_AddressLatchEnable[3:0];
        end else if (iPCommand[2]) begin 
            rPO_AddressLatchEnable[3:0] <= iDO_PO_AddressLatchEnable[3:0];
        end else if (iPCommand[1]) begin 
            rPO_AddressLatchEnable[3:0] <= iDI_PO_AddressLatchEnable[3:0];
        end else if (iPCommand[0]) begin 
            rPO_AddressLatchEnable[3:0] <= iTM_PO_AddressLatchEnable[3:0];
        end else begin 
            rPO_AddressLatchEnable[3:0] <= iIDLE_PO_AddressLatchEnable[3:0];
        end
    end
    always @ (*) begin
        if (iPCommand[3]) begin 
            rPO_CommandLatchEnable[3:0] <= iCAL_PO_CommandLatchEnable[3:0];
        end else if (iPCommand[2]) begin 
            rPO_CommandLatchEnable[3:0] <= iDO_PO_CommandLatchEnable[3:0];
        end else if (iPCommand[1]) begin 
            rPO_CommandLatchEnable[3:0] <= iDI_PO_CommandLatchEnable[3:0];
        end else if (iPCommand[0]) begin 
            rPO_CommandLatchEnable[3:0] <= iTM_PO_CommandLatchEnable[3:0];
        end else begin 
            rPO_CommandLatchEnable[3:0] <= iIDLE_PO_CommandLatchEnable[3:0];
        end
    end
    always @ (*) begin
        if (iPCommand[6]) begin 
            rDQSOutEnable <= iPBR_DQSOutEnable;
        end else if (iPCommand[3]) begin 
            rDQSOutEnable <= iCAL_DQSOutEnable;
        end else if (iPCommand[2]) begin 
            rDQSOutEnable <= iDO_DQSOutEnable;
        end else if (iPCommand[1]) begin 
            rDQSOutEnable <= iDI_DQSOutEnable;
        end else if (iPCommand[0]) begin 
            rDQSOutEnable <= iTM_DQSOutEnable;
        end else begin 
            rDQSOutEnable <= iIDLE_DQSOutEnable;
        end
    end
    always @ (*) begin
        if (iPCommand[3]) begin 
            rDQOutEnable <= iCAL_DQOutEnable;
        end else if (iPCommand[2]) begin 
            rDQOutEnable <= iDO_DQOutEnable;
        end else if (iPCommand[1]) begin 
            rDQOutEnable <= iDI_DQOutEnable;
        end else begin 
            rDQOutEnable <= iIDLE_DQOutEnable;
        end
    end
    assign oPI_Reset = rPI_Reset;
    assign oPI_BUFF_Reset = rPI_BUFF_Reset;
    assign oPO_Reset = rPO_Reset;
    assign oPI_BUFF_RE = rPI_BUFF_RE;
    assign oPI_BUFF_WE = rPI_BUFF_WE;
    assign oPI_BUFF_OutSel[2:0] = rPI_BUFF_OutSel[2:0];
    assign oPIDelayTapLoad = rPIDelayTapLoad;
    assign oPIDelayTap[4:0] = rPIDelayTap[4:0];
    assign oPO_DQStrobe[7:0] = rPO_DQStrobe[7:0];
    assign oPO_DQ[31:0] = rPO_DQ[31:0];
    assign oPO_ChipEnable = rPO_ChipEnable;
    assign oPO_ReadEnable[3:0] = rPO_ReadEnable[3:0];
    assign oPO_WriteEnable[3:0] = rPO_WriteEnable[3:0];
    assign oPO_AddressLatchEnable[3:0] = rPO_AddressLatchEnable[3:0];
    assign oPO_CommandLatchEnable[3:0] = rPO_CommandLatchEnable[3:0];
    assign oDQSOutEnable = rDQSOutEnable;
    assign oDQOutEnable = rDQOutEnable;
endmodule
