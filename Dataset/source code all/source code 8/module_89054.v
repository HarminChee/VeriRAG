`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPM_Toggle_TIMER
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock            ,
    iReset                  ,
    oReady                  ,
    oLastStep               ,
    iStart                  ,
    iOption                 ,
    iTargetWay              ,
    iNumOfData              ,
    iPO_DQStrobe            ,
    iPO_ReadEnable          ,
    iPO_WriteEnable         ,
    iPO_AddressLatchEnable  ,
    iPO_CommandLatchEnable  ,
    oPO_DQStrobe            ,
    oPO_ChipEnable          ,
    oPO_ReadEnable          ,
    oPO_WriteEnable         ,
    oPO_AddressLatchEnable  ,
    oPO_CommandLatchEnable  ,
    oDQSOutEnable
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    output                          oReady                  ;
    output                          oLastStep               ;
    input                           iStart                  ;
    input   [2:0]                   iOption                 ;
    input   [NumberOfWays - 1:0]    iTargetWay              ;
    input   [15:0]                  iNumOfData              ;
    input   [7:0]                   iPO_DQStrobe            ;
    input   [3:0]                   iPO_ReadEnable          ;
    input   [3:0]                   iPO_WriteEnable         ;
    input   [3:0]                   iPO_AddressLatchEnable  ;
    input   [3:0]                   iPO_CommandLatchEnable  ;
    output  [7:0]                   oPO_DQStrobe            ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable          ;
    output  [3:0]                   oPO_ReadEnable          ;
    output  [3:0]                   oPO_WriteEnable         ;
    output  [3:0]                   oPO_AddressLatchEnable  ;
    output  [3:0]                   oPO_CommandLatchEnable  ;
    output                          oDQSOutEnable           ;
    localparam TIM_FSM_BIT = 4;
    localparam TIM_RESET = 4'b0001;
    localparam TIM_READY = 4'b0010;
    localparam TIM_T10ns = 4'b0100;
    localparam TIM_TLOOP = 4'b1000;
    reg     [TIM_FSM_BIT-1:0]       rTIM_cur_state          ;
    reg     [TIM_FSM_BIT-1:0]       rTIM_nxt_state          ;
    reg                             rReady                  ;
    reg     [15:0]                  rNumOfCommand           ;
    reg     [15:0]                  rTimer                  ;
    wire    [2*NumberOfWays - 1:0]  wPO_ChipEnable          ;
    wire                            wTimerOn                ;
    wire                            wJOBDone                ;
    reg     [2*NumberOfWays - 1:0]  rPO_ChipEnable          ;
    reg     [7:0]                   rPO_DQStrobe            ;
    reg                             rDQSOutEnable           ;
    reg     [3:0]                   rPO_ReadEnable          ;
    reg     [3:0]                   rPO_WriteEnable         ;
    reg     [3:0]                   rPO_AddressLatchEnable  ;
    reg     [3:0]                   rPO_CommandLatchEnable  ;
    assign wPO_ChipEnable = { iTargetWay[NumberOfWays - 1:0], iTargetWay[NumberOfWays - 1:0] };
    assign wTimerOn = (rTIM_cur_state == TIM_T10ns) | (rTIM_cur_state == TIM_TLOOP);
    assign wJOBDone = wTimerOn & (rNumOfCommand[15:0] == rTimer[15:0]);
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rTIM_cur_state <= TIM_RESET;
        end else begin
            rTIM_cur_state <= rTIM_nxt_state;
        end
    end
    always @ ( * ) begin
        case (rTIM_cur_state)
            TIM_RESET: begin
                rTIM_nxt_state <= TIM_READY;
            end
            TIM_READY: begin
                rTIM_nxt_state <= (iStart)? TIM_T10ns:TIM_READY;
            end
            TIM_T10ns: begin
                rTIM_nxt_state <= (wJOBDone)? ((iStart)? TIM_T10ns:TIM_READY):TIM_TLOOP;
            end
            TIM_TLOOP: begin
                rTIM_nxt_state <= (wJOBDone)? ((iStart)? TIM_T10ns:TIM_READY):TIM_TLOOP;
            end
            default:
                rTIM_nxt_state <= TIM_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rReady                          <= 0;
            rNumOfCommand[15:0]             <= 0;
            rTimer[15:0]                    <= 0;
            rPO_ChipEnable                  <= 0;
            rPO_DQStrobe[7:0]               <= 8'b1111_1111;
            rDQSOutEnable                   <= 0;
            rPO_ReadEnable[3:0]             <= 0;
            rPO_WriteEnable[3:0]            <= 0;
            rPO_AddressLatchEnable[3:0]     <= 0;
            rPO_CommandLatchEnable[3:0]     <= 0;
        end else begin
            case (rTIM_nxt_state)
                TIM_RESET: begin
                    rReady                          <= 0;
                    rNumOfCommand[15:0]             <= 0;
                    rTimer[15:0]                    <= 0;
                    rPO_ChipEnable                  <= 0;
                    rPO_DQStrobe[7:0]               <= 8'b1111_1111;
                    rDQSOutEnable                   <= 0;
                    rPO_ReadEnable[3:0]             <= 0;
                    rPO_WriteEnable[3:0]            <= 0;
                    rPO_AddressLatchEnable[3:0]     <= 0;
                    rPO_CommandLatchEnable[3:0]     <= 0;
                end
                TIM_READY: begin
                    rReady                          <= 1;
                    rNumOfCommand[15:0]             <= 0;
                    rTimer[15:0]                    <= 0;
                    rPO_ChipEnable                  <= 0;
                    rPO_DQStrobe[7:0]               <= 8'b1111_1111;
                    rDQSOutEnable                   <= 0;
                    rPO_ReadEnable[3:0]             <= 0;
                    rPO_WriteEnable[3:0]            <= 0;
                    rPO_AddressLatchEnable[3:0]     <= 0;
                    rPO_CommandLatchEnable[3:0]     <= 0;
                end
                TIM_T10ns: begin
                    rReady                          <= 0;
                    rNumOfCommand[15:0]             <= iNumOfData[15:0];
                    rTimer[15:0]                    <= 16'h0000;
                    rPO_ChipEnable                  <= (iOption[0])? (wPO_ChipEnable):(0);
                    rPO_DQStrobe[7:0]               <= (iOption[1])? ({ 8{iPO_DQStrobe[3]} }):(8'b1111_1111);
                    rDQSOutEnable                   <= (iOption[1])? (1'b1):(1'b0);
                    rPO_ReadEnable[3:0]             <= (iOption[2])? ({ 4{iPO_ReadEnable[1]} }):(4'b0000);
                    rPO_WriteEnable[3:0]            <= (iOption[2])? ({ 4{iPO_WriteEnable[1]} }):(4'b0000);
                    rPO_AddressLatchEnable[3:0]     <= (iOption[2])? ({ 4{iPO_AddressLatchEnable[1]} }):(4'b0000);
                    rPO_CommandLatchEnable[3:0]     <= (iOption[2])? ({ 4{iPO_CommandLatchEnable[1]} }):(4'b0000);
                end
                TIM_TLOOP: begin
                    rReady                          <= 0;
                    rNumOfCommand[15:0]             <= rNumOfCommand[15:0];
                    rTimer[15:0]                    <= rTimer[15:0] + 1'b1;
                    rPO_ChipEnable                  <= rPO_ChipEnable;
                    rPO_DQStrobe[7:0]               <= rPO_DQStrobe[7:0];
                    rDQSOutEnable                   <= rDQSOutEnable;
                    rPO_ReadEnable[3:0]             <= rPO_ReadEnable[3:0];
                    rPO_WriteEnable[3:0]            <= rPO_WriteEnable[3:0];
                    rPO_AddressLatchEnable[3:0]     <= rPO_AddressLatchEnable[3:0];
                    rPO_CommandLatchEnable[3:0]     <= rPO_CommandLatchEnable[3:0];
                end
            endcase
        end
    end
    assign oReady               = rReady | wJOBDone     ;
    assign oLastStep            = wJOBDone              ;
    assign oPO_ChipEnable       = rPO_ChipEnable        ;
    assign oPO_DQStrobe         = rPO_DQStrobe          ;
    assign oDQSOutEnable        = rDQSOutEnable         ;
    assign oPO_ReadEnable       = rPO_ReadEnable        ;
    assign oPO_WriteEnable      = rPO_WriteEnable       ;
    assign oPO_AddressLatchEnable = rPO_AddressLatchEnable;
    assign oPO_CommandLatchEnable = rPO_CommandLatchEnable;
endmodule
