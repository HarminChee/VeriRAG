`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPM_Toggle_DI_DDR100
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
    oReadData               ,
    oReadLast               ,
    oReadValid              ,
    iReadReady              ,
    oPI_BUFF_RE             ,
    oPI_BUFF_WE             ,
    oPI_BUFF_OutSel         ,
    iPI_BUFF_Empty          ,
    iPI_DQ                  ,
    iPI_ValidFlag           ,
    oPO_ChipEnable          ,
    oPO_ReadEnable          ,
    oPO_WriteEnable         ,
    oPO_AddressLatchEnable  ,
    oPO_CommandLatchEnable  ,
    oDQSOutEnable           ,
    oDQOutEnable            
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    output                          oReady                  ;
    output                          oLastStep               ;
    input                           iStart                  ;
    input                           iOption                 ;
    input   [NumberOfWays - 1:0]    iTargetWay              ;
    input   [15:0]                  iNumOfData              ;
    output  [31:0]                  oReadData               ;
    output                          oReadLast               ;
    output                          oReadValid              ;
    input                           iReadReady              ;
    output                          oPI_BUFF_RE             ;
    output                          oPI_BUFF_WE             ;
    output  [2:0]                   oPI_BUFF_OutSel         ;
    input                           iPI_BUFF_Empty          ;
    input   [31:0]                  iPI_DQ                  ;
    input   [3:0]                   iPI_ValidFlag           ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable          ;
    output  [3:0]                   oPO_ReadEnable          ;
    output  [3:0]                   oPO_WriteEnable         ;
    output  [3:0]                   oPO_AddressLatchEnable  ;
    output  [3:0]                   oPO_CommandLatchEnable  ;
    output                          oDQSOutEnable           ;
    output                          oDQOutEnable            ;
    localparam REC_FSM_BIT = 8; 
    localparam REC_RESET = 8'b0000_0001;
    localparam REC_READY = 8'b0000_0010;
    localparam REC_RESTU = 8'b0000_0100; 
    localparam REC_RPRAM = 8'b0000_1000; 
    localparam REC_RE808 = 8'b0001_0000; 
    localparam REC_RELST = 8'b0010_0000; 
    localparam REC_RPSAM = 8'b0100_0000; 
    localparam REC_WAITS = 8'b1000_0000; 
    reg     [REC_FSM_BIT-1:0]       rREC_cur_state          ;
    reg     [REC_FSM_BIT-1:0]       rREC_nxt_state          ;
    localparam DQI_FSM_BIT = 9; 
    localparam DQI_RESET = 9'b000_000_001;
    localparam DQI_READY = 9'b000_000_010;
    localparam DQI_WTVIN = 9'b000_000_100; 
    localparam DQI_IFIFO = 9'b000_001_000; 
    localparam DQI_INm43 = 9'b000_010_000; 
    localparam DQI_INm32 = 9'b000_100_000; 
    localparam DQI_INm21 = 9'b001_000_000; 
    localparam DQI_INm1Z = 9'b010_000_000; 
    localparam DQI_WAITS = 9'b100_000_000; 
    reg     [DQI_FSM_BIT-1:0]       rDQI_cur_state          ;
    reg     [DQI_FSM_BIT-1:0]       rDQI_nxt_state          ;
    localparam DQO_FSM_BIT = 7; 
    localparam DQO_RESET = 7'b000_0001;
    localparam DQO_READY = 7'b000_0010;
    localparam DQO_WTVIN = 7'b000_0100; 
    localparam DQO_P_PHY = 7'b000_1000; 
    localparam DQO_OLOOP = 7'b001_0000; 
    localparam DQO_P_BUS = 7'b010_0000; 
    localparam DQO_WAITS = 7'b100_0000; 
    reg     [DQO_FSM_BIT-1:0]       rDQO_cur_state          ;
    reg     [DQO_FSM_BIT-1:0]       rDQO_nxt_state          ;
    reg                             rReady                  ;
    reg                             rOption                 ;
    reg     [15:0]                  rNumOfData              ;
    reg                             rReadValid              ;
    wire    [17:0]                  wTranslatedNum          ;
    reg     [17:1]                  rRECCounter             ;
    reg     [3:0]                   rRECSubCounter          ;
    reg     [17:1]                  rDQICounter             ;
    reg     [17:2]                  rDQOCounter             ;
    wire    [2*NumberOfWays - 1:0]  wPO_ChipEnable          ;
    reg     [3:0]                   rLastRE                 ;
    wire                            wLetsStart              ;
    wire                            wtCRxxDone              ;
    wire                            wtRPREDone              ;
    wire                            wRELoopDone             ;
    wire                            wtRPSTDone              ;
    reg                             rRECDone                ;
    wire                            wPMActive               ;
    wire                            wJOB_1Bto8B             ;
    wire                            wJOB_9BorMore           ;
    wire                            w_S1_01Bto02B           ;
    wire                            w_S2_03Bto04B           ;
    wire                            w_S3_05Bto06B           ;
    wire                            w_S4_07Bto08B           ;
    wire                            w_S5_09o10pWu           ;
    wire                            w_S6_11o12pWu           ;
    wire                            wDQIOStart              ;
    reg                             rDQBufferWenableA       ;
    wire                            wDQBufferWFirst         ;
    reg     [13:0]                  rDQBufferWaddrssA       ;
    wire    [15:0]                  wDQBufferW_DATA_A       ;
    wire    [12:0]                  wDQBufferRaddressB      ;
    reg     [12:0]                  rDQBufferRaddressB_old  ;
    reg     [12:0]                  rDQBufferRaddressB_new  ;
    wire    [31:0]                  wDQBufferR_DATA_B       ;
    wire                            wDQILoopDone            ;
    reg                             rDQIDone                ;
    wire                            wDQOLoopDone            ;
    reg                             rDQODone                ;
    wire                            wJOBDone                ;
    reg                             rPI_BUFF_RE             ;
    reg                             rPI_BUFF_WE             ;
    reg     [2:0]                   rPI_BUFF_OutSel         ;
    reg     [3:0]                   rPI_ValidFlag_b_5       ;
    reg     [3:0]                   rPI_ValidFlag_b_4       ;
    reg     [3:0]                   rPI_ValidFlag_b_3       ;
    reg     [3:0]                   rPI_ValidFlag_b_2       ;
    reg     [3:0]                   rPI_ValidFlag_b_1       ;
    reg     [3:0]                   rPI_ValidFlag           ;
    reg     [2*NumberOfWays - 1:0]  rPO_ChipEnable          ;
    reg     [3:0]                   rPO_ReadEnable          ;
    reg     [3:0]                   rPO_WriteEnable         ;
    reg     [3:0]                   rPO_AddressLatchEnable  ;
    reg     [3:0]                   rPO_CommandLatchEnable  ;
    reg                             rDQSOutEnable           ;
    reg                             rDQOutEnable            ;
    reg                             rUpperPI_DQ             ;
    reg     [13:0]                  rDQBufferDoneAddress    ;
    wire    [14:0]                  wSResult                ;
    wire                            wDQBufferValid          ;
    assign wPO_ChipEnable = { iTargetWay[NumberOfWays - 1:0], iTargetWay[NumberOfWays - 1:0] };
    assign wTranslatedNum[17:0] = (rOption)? ( { rNumOfData[15:0], 2'b11 } )  
                                            :( { 2'b00, rNumOfData[15:0] } ); 
    always @ ( * ) begin
        case ( { 1'b0, wTranslatedNum[0] } )
            2'b00: begin 
                rLastRE[3:0] <= 4'b0000;
            end
            2'b01: begin 
                rLastRE[3:0] <= 4'b1110;
            end
            2'b10: begin 
                rLastRE[3:0] <= 4'b0010;
            end
            2'b11: begin 
                rLastRE[3:0] <= 4'b1010;
            end
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rPI_ValidFlag_b_5[3:0]  <= 0;
            rPI_ValidFlag_b_4[3:0]  <= 0;
            rPI_ValidFlag_b_3[3:0]  <= 0;
            rPI_ValidFlag_b_2[3:0]  <= 0;
            rPI_ValidFlag_b_1[3:0]  <= 0;
            rPI_ValidFlag[3:0]      <= 0;
        end else begin
            rPI_ValidFlag_b_5[3:0]  <= rPI_ValidFlag_b_3[3:0];
            rPI_ValidFlag_b_4[3:0]  <= rPI_ValidFlag_b_2[3:0];
            rPI_ValidFlag_b_3[3:0]  <= rPI_ValidFlag_b_2[3:0];
            rPI_ValidFlag_b_2[3:0]  <= rPI_ValidFlag_b_1[3:0];
            rPI_ValidFlag_b_1[3:0]  <= iPI_ValidFlag[3:0];
            rPI_ValidFlag[3:0]      <=   (rPI_ValidFlag_b_5[3:0])
                                       & (rPI_ValidFlag_b_4[3:0])
                                       & (rPI_ValidFlag_b_3[3:0]);
        end
    end
    assign wLetsStart = (rRECSubCounter[3:0] == 4'b0000);
    assign wtCRxxDone = (rRECSubCounter[3:0] == 4'b0011);
    assign wtRPREDone = (rRECSubCounter[3:0] == 4'b1000);
    assign wRELoopDone = (rRECCounter[17:1] == wTranslatedNum[17:1]);
    assign wtRPSTDone = (rRECSubCounter[3:0] == 4'b1101);
    assign wPMActive = (rREC_cur_state != REC_RESET) & (rREC_cur_state != REC_READY);
    assign wJOB_1Bto8B = ~wJOB_9BorMore;
    assign wJOB_9BorMore = |(wTranslatedNum[17:3]);
    assign w_S1_01Bto02B = (wJOB_1Bto8B) & (wTranslatedNum[2:1] == 2'b00);
    assign w_S2_03Bto04B = (wJOB_1Bto8B) & (wTranslatedNum[2:1] == 2'b01);
    assign w_S3_05Bto06B = (wJOB_1Bto8B) & (wTranslatedNum[2:1] == 2'b10);
    assign w_S4_07Bto08B = (wJOB_1Bto8B) & (wTranslatedNum[2:1] == 2'b11);
    assign w_S5_09o10pWu = (wJOB_9BorMore) & (wTranslatedNum[1] == 1'b0);
    assign w_S6_11o12pWu = (wJOB_9BorMore) & (wTranslatedNum[1] == 1'b1);
    assign wDQIOStart =   (wPMActive)
                        & (   ( (w_S1_01Bto02B) & ( rPI_ValidFlag[3]) )
                            | ( (w_S2_03Bto04B) & ( rPI_ValidFlag[2]) )
                            | ( (w_S3_05Bto06B) & ( rPI_ValidFlag[1]) )
                            | ( (w_S4_07Bto08B) & ( rPI_ValidFlag[0]) )
                            | ( (w_S5_09o10pWu) & ( ~ iPI_BUFF_Empty) )
                            | ( (w_S6_11o12pWu) & ( ~ iPI_BUFF_Empty) ) );
    assign wDQBufferWFirst = (rDQI_cur_state == DQI_WTVIN);
    assign wDQILoopDone = (rDQICounter[17:2] == wTranslatedNum[17:2]);
    assign wDQOLoopDone = (rDQOCounter[17:2] == wTranslatedNum[17:2]);
    assign wJOBDone = (rRECDone) & (rDQIDone) & (rDQODone);
    assign wDQBufferRaddressB[12:0] = ((rDQO_cur_state == DQO_P_PHY) | (iReadReady))? (rDQBufferRaddressB_new[12:0]):(rDQBufferRaddressB_old[12:0]);
    SDPRAM_16A9024X32B4512
    PM_DI_DQ_Buffer_18048B 
    (
        .clka(iSystemClock),    
        .ena(rDQBufferWenableA),      
        .wea(rDQBufferWenableA),      
        .addra(rDQBufferWaddrssA[13:0]),  
        .dina(wDQBufferW_DATA_A[15:0]),    
        .clkb(iSystemClock),    
        .enb(wDQBufferValid),      
        .addrb(wDQBufferRaddressB[12:0]),  
        .doutb(wDQBufferR_DATA_B[31:0])  
    );
    assign wDQBufferW_DATA_A[15:0] = (rUpperPI_DQ)? (iPI_DQ[31:16]):(iPI_DQ[15:0]);
    reg [13:0] rDQBufferDoneAddressReg1;
    reg [13:0] rDQBufferDoneAddressReg2;
    reg [13:0] rDQBufferDoneAddressReg3;
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rDQBufferDoneAddressReg1[13:0] <= 0;
            rDQBufferDoneAddressReg2[13:0] <= 0;
            rDQBufferDoneAddressReg3[13:0] <= 0;
            rDQBufferDoneAddress[13:0]  <= 0;
        end else begin
            rDQBufferDoneAddressReg1[13:0] <= rDQBufferWaddrssA[13:0];
            rDQBufferDoneAddressReg2[13:0]  <= rDQBufferDoneAddressReg1[13:0];
            rDQBufferDoneAddressReg3[13:0]  <= rDQBufferDoneAddressReg2[13:0];
            rDQBufferDoneAddress[13:0]  <= rDQBufferDoneAddressReg3[13:0];
        end
    end
    c_sub
    substracter15
    (
        .A({ 1'b0, rDQBufferDoneAddress[13:0] }),  
        .B({ 1'b0, wDQBufferRaddressB[12:0], 1'b1 }),  
        .S(wSResult[14:0])  
    );
    assign wDQBufferValid = ~wSResult[14];
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rREC_cur_state <= REC_RESET;
        end else begin
            rREC_cur_state <= rREC_nxt_state;
        end
    end
    always @ ( * ) begin
        case (rREC_cur_state)
            REC_RESET: begin
                rREC_nxt_state <= REC_READY;
            end
            REC_READY: begin
                rREC_nxt_state <= (iStart)? REC_RESTU:REC_READY;
            end
            REC_RESTU: begin
                rREC_nxt_state <= (wtCRxxDone)? REC_RPRAM:REC_RESTU;
            end
            REC_RPRAM: begin
                rREC_nxt_state <= (wtRPREDone)? ((wRELoopDone)? REC_RELST:REC_RE808):REC_RPRAM;
            end
            REC_RE808: begin
                rREC_nxt_state <= (wRELoopDone)? REC_RELST:REC_RE808;
            end
            REC_RELST: begin
                rREC_nxt_state <= REC_RPSAM;
            end
            REC_RPSAM: begin
                rREC_nxt_state <= (wtRPSTDone)? REC_WAITS:REC_RPSAM;
            end
            REC_WAITS: begin
                rREC_nxt_state <= (wJOBDone)? REC_READY:REC_WAITS;
            end
            default:
                rREC_nxt_state <= REC_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rReady                              <= 0;
            rOption                             <= 0;
            rNumOfData[15:0]                    <= 0;
            rRECCounter[17:1]                   <= 0;
            rRECSubCounter[3:0]                 <= 0;
            rPO_ChipEnable                      <= 0;
            rPO_ReadEnable[3:0]                 <= 0;
            rPO_WriteEnable[3:0]                <= 0;
            rPO_AddressLatchEnable[3:0]         <= 0;
            rPO_CommandLatchEnable[3:0]         <= 0;
            rDQSOutEnable                       <= 0;
            rDQOutEnable                        <= 0;
            rRECDone                            <= 0;
        end else begin
            case (rREC_nxt_state)
                REC_RESET: begin
                    rReady                              <= 0;
                    rOption                             <= 0;
                    rNumOfData[15:0]                    <= 0;
                    rRECCounter[17:1]                   <= 0;
                    rRECSubCounter[3:0]                 <= 0;
                    rPO_ChipEnable                      <= 0;
                    rPO_ReadEnable[3:0]                 <= 0;
                    rPO_WriteEnable[3:0]                <= 0;
                    rPO_AddressLatchEnable[3:0]         <= 0;
                    rPO_CommandLatchEnable[3:0]         <= 0;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 0;
                end
                REC_READY: begin
                    rReady                              <= 1;
                    rOption                             <= 0;
                    rNumOfData[15:0]                    <= 0;
                    rRECCounter[17:1]                   <= 0;
                    rRECSubCounter[3:0]                 <= 0;
                    rPO_ChipEnable                      <= 0;
                    rPO_ReadEnable[3:0]                 <= 0;
                    rPO_WriteEnable[3:0]                <= 0;
                    rPO_AddressLatchEnable[3:0]         <= 0;
                    rPO_CommandLatchEnable[3:0]         <= 0;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 0;
                end
                REC_RESTU: begin
                    rReady                              <= 0;
                    rOption                             <= (wLetsStart)? iOption:rOption;
                    rNumOfData[15:0]                    <= (wLetsStart)? iNumOfData[15:0]:rNumOfData[15:0];
                    rRECCounter[17:1]                   <= 0;
                    rRECSubCounter[3:0]                 <= rRECSubCounter[3:0] + 1'b1;
                    rPO_ChipEnable                      <= (wLetsStart)? wPO_ChipEnable:rPO_ChipEnable;
                    rPO_ReadEnable[3:0]                 <= 4'b0000;
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 0;
                end
                REC_RPRAM: begin
                    rReady                              <= 0;
                    rOption                             <= rOption;
                    rNumOfData[15:0]                    <= rNumOfData[15:0];
                    rRECCounter[17:1]                   <= 0;
                    rRECSubCounter[3:0]                 <= rRECSubCounter[3:0] + 1'b1;
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_ReadEnable[3:0]                 <= 4'b1111;
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 0;
                end
                REC_RE808: begin
                    rReady                              <= 0;
                    rOption                             <= rOption;
                    rNumOfData[15:0]                    <= rNumOfData[15:0];
                    rRECCounter[17:1]                   <= rRECCounter[17:1] + 1'b1;
                    rRECSubCounter[3:0]                 <= rRECSubCounter[3:0];
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_ReadEnable[3:0]                 <= 4'b1010;
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 0;
                end
                REC_RELST: begin
                    rReady                              <= 0;
                    rOption                             <= rOption;
                    rNumOfData[15:0]                    <= rNumOfData[15:0];
                    rRECCounter[17:1]                   <= rRECCounter[17:1];
                    rRECSubCounter[3:0]                 <= rRECSubCounter[3:0];
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_ReadEnable[3:0]                 <= rLastRE[3:0];
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 0;
                end
                REC_RPSAM: begin
                    rReady                              <= 0;
                    rOption                             <= rOption;
                    rNumOfData[15:0]                    <= rNumOfData[15:0];
                    rRECCounter[17:1]                   <= rRECCounter[17:1];
                    rRECSubCounter[3:0]                 <= rRECSubCounter[3:0] + 1'b1;
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_ReadEnable[3:0]                 <= { 4{ rLastRE[3] } };
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 0;
                end
                REC_WAITS: begin
                    rReady                              <= 0;
                    rOption                             <= rOption;
                    rNumOfData[15:0]                    <= rNumOfData[15:0];
                    rRECCounter[17:1]                   <= rRECCounter[17:1];
                    rRECSubCounter[3:0]                 <= rRECSubCounter[3:0];
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_ReadEnable[3:0]                 <= { 4{ rLastRE[3] } };
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    rRECDone                            <= 1;
                end
            endcase
        end
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rDQI_cur_state <= DQI_RESET;
        end else begin
            rDQI_cur_state <= rDQI_nxt_state;
        end
    end
    always @ ( * ) begin
        case (rDQI_cur_state)
            DQI_RESET: begin
                rDQI_nxt_state <= DQI_READY;
            end
            DQI_READY: begin
                rDQI_nxt_state <= (iStart)? DQI_WTVIN:DQI_READY;
            end
            DQI_WTVIN: begin
                if (wDQIOStart) begin
                    if (wJOB_9BorMore) begin
                        rDQI_nxt_state <= DQI_IFIFO;
                    end else if (w_S4_07Bto08B) begin
                        rDQI_nxt_state <= DQI_INm43;
                    end else if (w_S3_05Bto06B) begin
                        rDQI_nxt_state <= DQI_INm32;
                    end else if (w_S2_03Bto04B) begin
                        rDQI_nxt_state <= DQI_INm21;
                    end else begin 
                        rDQI_nxt_state <= DQI_INm1Z;
                    end
                end else begin
                    rDQI_nxt_state <= DQI_WTVIN;
                end
            end
            DQI_IFIFO: begin
                rDQI_nxt_state <= (wDQILoopDone)? ((w_S6_11o12pWu)? DQI_INm43:DQI_INm32):DQI_IFIFO;
            end
            DQI_INm43: begin
                rDQI_nxt_state <= (rUpperPI_DQ)? DQI_INm21:DQI_INm43;
            end
            DQI_INm32: begin
                rDQI_nxt_state <= (rUpperPI_DQ)? DQI_INm1Z:DQI_INm32;
            end
            DQI_INm21: begin
                rDQI_nxt_state <= (rUpperPI_DQ)? DQI_WAITS:DQI_INm21;
            end
            DQI_INm1Z: begin
                rDQI_nxt_state <= (rUpperPI_DQ)? DQI_WAITS:DQI_INm1Z;
            end
            DQI_WAITS: begin
                rDQI_nxt_state <= (wJOBDone)? DQI_READY:DQI_WAITS;
            end
            default:
                rDQI_nxt_state <= DQI_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rDQICounter[17:2]           <= 16'h0001;
            rDQICounter[1]              <= 1'b0;
            rPI_BUFF_RE                 <= 0;
            rPI_BUFF_WE                 <= 0;
            rPI_BUFF_OutSel[2:0]        <= 0;
            rDQBufferWenableA           <= 0;
            rDQBufferWaddrssA[13:0]     <= 0;
            rDQIDone                    <= 0;
            rUpperPI_DQ                 <= 0;
        end else begin
            case (rDQI_nxt_state)
                DQI_RESET: begin
                    rDQICounter[17:2]           <= 16'h0001;
                    rDQICounter[1]              <= 1'b0;
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= 0;
                    rPI_BUFF_OutSel[2:0]        <= 0;
                    rDQBufferWenableA           <= 0;
                    rDQBufferWaddrssA[13:0]     <= 0;
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= 0;
                end
                DQI_READY: begin
                    rDQICounter[17:2]           <= 16'h0001;
                    rDQICounter[1]              <= 1'b0;
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= 0;
                    rPI_BUFF_OutSel[2:0]        <= 0;
                    rDQBufferWenableA           <= 0;
                    rDQBufferWaddrssA[13:0]     <= 0;
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= 0;
                end
                DQI_WTVIN: begin
                    rDQICounter[17:2]           <= 16'h0001;
                    rDQICounter[1]              <= 1'b0;
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= (wtRPREDone)? 1'b1:rPI_BUFF_WE;
                    rPI_BUFF_OutSel[2:0]        <= 0;
                    rDQBufferWenableA           <= 0;
                    rDQBufferWaddrssA[13:0]     <= 0;
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= 0;
                end
                DQI_IFIFO: begin
                    rDQICounter[17:1]           <= rDQICounter[17:1] + 1'b1;
                    rPI_BUFF_RE                 <= 1;
                    rPI_BUFF_WE                 <= (wtRPSTDone)? 1'b0:rPI_BUFF_WE;
                    rPI_BUFF_OutSel[2:0]        <= 3'b000;
                    rDQBufferWenableA           <= 1;
                    rDQBufferWaddrssA[13:0]     <= (wDQBufferWFirst)? 0:(rDQBufferWaddrssA[13:0] + 1'b1);
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= 1'b0;
                end
                DQI_INm43: begin
                    rDQICounter[17:1]           <= rDQICounter[17:1];
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= (wtRPSTDone)? 1'b0:rPI_BUFF_WE;
                    rPI_BUFF_OutSel[2:0]        <= 3'b100;
                    rDQBufferWenableA           <= 1;
                    rDQBufferWaddrssA[13:0]     <= (wDQBufferWFirst)? 0:(rDQBufferWaddrssA[13:0] + 1'b1);
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= (rDQI_cur_state == DQI_INm43)? 1'b1:1'b0;
                end
                DQI_INm32: begin
                    rDQICounter[17:1]           <= rDQICounter[17:1];
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= (wtRPSTDone)? 1'b0:rPI_BUFF_WE;
                    rPI_BUFF_OutSel[2:0]        <= 3'b101;
                    rDQBufferWenableA           <= 1;
                    rDQBufferWaddrssA[13:0]     <= (wDQBufferWFirst)? 0:(rDQBufferWaddrssA[13:0] + 1'b1);
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= (rDQI_cur_state == DQI_INm32)? 1'b1:1'b0;
                end
                DQI_INm21: begin
                    rDQICounter[17:1]           <= rDQICounter[17:1];
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= (wtRPSTDone)? 1'b0:rPI_BUFF_WE;
                    rPI_BUFF_OutSel[2:0]        <= 3'b110;
                    rDQBufferWenableA           <= 1;
                    rDQBufferWaddrssA[13:0]     <= (wDQBufferWFirst)? 0:(rDQBufferWaddrssA[13:0] + 1'b1);
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= (rDQI_cur_state == DQI_INm21)? 1'b1:1'b0;
                end
                DQI_INm1Z: begin
                    rDQICounter[17:1]           <= rDQICounter[17:1];
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= (wtRPSTDone)? 1'b0:rPI_BUFF_WE;
                    rPI_BUFF_OutSel[2:0]        <= 3'b111;
                    rDQBufferWenableA           <= 1;
                    rDQBufferWaddrssA[13:0]     <= (wDQBufferWFirst)? 0:(rDQBufferWaddrssA[13:0] + 1'b1);
                    rDQIDone                    <= 0;
                    rUpperPI_DQ                 <= (rDQI_cur_state == DQI_INm1Z)? 1'b1:1'b0;
                end
                DQI_WAITS: begin
                    rDQICounter[17:1]           <= rDQICounter[17:1];
                    rPI_BUFF_RE                 <= 0;
                    rPI_BUFF_WE                 <= (wtRPSTDone)? 1'b0:rPI_BUFF_WE;
                    rPI_BUFF_OutSel[2:0]        <= 0;
                    rDQBufferWenableA           <= 0;
                    rDQBufferWaddrssA[13:0]     <= rDQBufferWaddrssA[13:0];
                    rDQIDone                    <= 1;
                    rUpperPI_DQ                 <= 0;
                end
            endcase
        end
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rDQO_cur_state <= DQO_RESET;
        end else begin
            rDQO_cur_state <= rDQO_nxt_state;
        end
    end
    always @ ( * ) begin
        case (rDQO_cur_state)
            DQO_RESET: begin
                rDQO_nxt_state <= DQO_READY;
            end
            DQO_READY: begin
                rDQO_nxt_state <= (iStart)? DQO_WTVIN:DQO_READY;
            end
            DQO_WTVIN: begin
                rDQO_nxt_state <= (wDQIOStart)? DQO_P_PHY:DQO_WTVIN;
            end
            DQO_P_PHY: begin
                case ({ wDQBufferValid, wDQOLoopDone, iReadReady })
                    3'b000: rDQO_nxt_state <= DQO_P_PHY;
                    3'b001: rDQO_nxt_state <= DQO_P_PHY;
                    3'b010: rDQO_nxt_state <= DQO_P_PHY;
                    3'b011: rDQO_nxt_state <= DQO_P_PHY;
                    3'b100: rDQO_nxt_state <= DQO_OLOOP;
                    3'b101: rDQO_nxt_state <= DQO_OLOOP;
                    3'b110: rDQO_nxt_state <= DQO_OLOOP;
                    3'b111: rDQO_nxt_state <= DQO_OLOOP;
                endcase
            end
            DQO_OLOOP: begin
                case ({ wDQBufferValid, wDQOLoopDone, iReadReady })
                    3'b011: rDQO_nxt_state <= DQO_WAITS;
                    3'b111: rDQO_nxt_state <= DQO_WAITS;
                    3'b001: rDQO_nxt_state <= DQO_P_PHY;
                    3'b101: rDQO_nxt_state <= DQO_OLOOP;
                    3'b000: rDQO_nxt_state <= DQO_P_BUS;
                    3'b010: rDQO_nxt_state <= DQO_P_BUS;
                    3'b100: rDQO_nxt_state <= DQO_P_BUS;
                    3'b110: rDQO_nxt_state <= DQO_P_BUS;
                endcase
            end
            DQO_P_BUS: begin
                case ({ wDQBufferValid, wDQOLoopDone, iReadReady })
                    3'b011: rDQO_nxt_state <= DQO_WAITS;
                    3'b111: rDQO_nxt_state <= DQO_WAITS;
                    3'b001: rDQO_nxt_state <= DQO_P_PHY;
                    3'b101: rDQO_nxt_state <= DQO_OLOOP;
                    3'b000: rDQO_nxt_state <= DQO_P_BUS;
                    3'b010: rDQO_nxt_state <= DQO_P_BUS;
                    3'b100: rDQO_nxt_state <= DQO_P_BUS;
                    3'b110: rDQO_nxt_state <= DQO_P_BUS;
                endcase
            end
            DQO_WAITS: begin
                rDQO_nxt_state <= (wJOBDone)? DQO_READY:DQO_WAITS;
            end
            default:
                rDQO_nxt_state <= DQO_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rDQOCounter[17:2]           <= 0;
            rDQBufferRaddressB_old[12:0] <= 0;
            rDQBufferRaddressB_new[12:0] <= 0;
            rReadValid                  <= 0;
            rDQODone                    <= 0;
        end else begin
            case (rDQO_nxt_state)
                DQO_RESET: begin
                    rDQOCounter[17:2]           <= 0;
                    rDQBufferRaddressB_old[12:0] <= 0;
                    rDQBufferRaddressB_new[12:0] <= 0;
                    rReadValid                  <= 0;
                    rDQODone                    <= 0;
                end
                DQO_READY: begin
                    rDQOCounter[17:2]           <= 0;
                    rDQBufferRaddressB_old[12:0] <= 0;
                    rDQBufferRaddressB_new[12:0] <= 0;
                    rReadValid                  <= 0;
                    rDQODone                    <= 0;
                end
                DQO_WTVIN: begin
                    rDQOCounter[17:2]           <= 0;
                    rDQBufferRaddressB_old[12:0] <= 0;
                    rDQBufferRaddressB_new[12:0] <= 0;
                    rReadValid                  <= 1'b0;
                    rDQODone                    <= 0;
                end
                DQO_P_PHY: begin
                    rDQOCounter[17:2]           <= rDQOCounter[17:2];
                    rDQBufferRaddressB_old[12:0] <= rDQBufferRaddressB_old[12:0];
                    rDQBufferRaddressB_new[12:0] <= rDQBufferRaddressB_new[12:0];
                    rReadValid                  <= 1'b0;
                    rDQODone                    <= 0;
                end
                DQO_OLOOP: begin
                    rDQOCounter[17:2]           <= { 3'b000, wDQBufferRaddressB[12:0] };
                    rDQBufferRaddressB_old[12:0] <= rDQBufferRaddressB_new[12:0];
                    rDQBufferRaddressB_new[12:0] <= rDQBufferRaddressB_new[12:0] + 1'b1;
                    rReadValid                  <= 1'b1;
                    rDQODone                    <= 0;
                end
                DQO_P_BUS: begin 
                    rDQOCounter[17:2]           <= rDQOCounter[17:2];
                    rDQBufferRaddressB_old[12:0] <= rDQBufferRaddressB_old[12:0];
                    rDQBufferRaddressB_new[12:0] <= rDQBufferRaddressB_new[12:0];
                    rReadValid                  <= 1'b1;
                    rDQODone                    <= 0;
                end
                DQO_WAITS: begin
                    rDQOCounter[17:2]           <= rDQOCounter[17:2];
                    rDQBufferRaddressB_old[12:0] <= rDQBufferRaddressB_old[12:0];
                    rDQBufferRaddressB_new[12:0] <= rDQBufferRaddressB_new[12:0];
                    rReadValid                  <= 0;
                    rDQODone                    <= 1;
                end
            endcase
        end
    end
    assign oReady               = rReady | wJOBDone     ;
    assign oLastStep            = wJOBDone              ;
    assign oReadData            = wDQBufferR_DATA_B     ;
    assign oReadLast            = wDQOLoopDone & rReadValid;
    assign oReadValid           = rReadValid            ;
    assign oPI_BUFF_RE          = rPI_BUFF_RE           ;
    assign oPI_BUFF_WE          = rPI_BUFF_WE           ;
    assign oPI_BUFF_OutSel      = rPI_BUFF_OutSel       ;
    assign oPO_ChipEnable       = rPO_ChipEnable        ;
    assign oPO_ReadEnable       = rPO_ReadEnable        ;
    assign oPO_WriteEnable      = rPO_WriteEnable       ;
    assign oPO_AddressLatchEnable = rPO_AddressLatchEnable;
    assign oPO_CommandLatchEnable = rPO_CommandLatchEnable;
    assign oDQSOutEnable        = rDQSOutEnable         ;
    assign oDQOutEnable         = rDQOutEnable          ;
endmodule
