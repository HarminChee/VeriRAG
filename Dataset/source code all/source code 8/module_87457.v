`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NPM_Toggle_PHY_B_Reset
(
    iSystemClock            ,
    iReset                  ,
    oReady                  ,
    oLastStep               ,
    iStart                  ,
    oPI_BUFF_Reset          ,
    oPI_BUFF_RE             ,
    oPI_BUFF_WE             ,
    oPO_DQStrobe            ,
    oDQSOutEnable            
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    output                          oReady                  ;
    output                          oLastStep               ;
    input                           iStart                  ;
    output                          oPI_BUFF_Reset          ;
    output                          oPI_BUFF_RE             ;
    output                          oPI_BUFF_WE             ;
    output  [7:0]                   oPO_DQStrobe            ;
    output                          oDQSOutEnable           ;
    parameter PBR_FSM_BIT = 4;
    parameter PBR_RESET = 4'b0001;
    parameter PBR_READY = 4'b0010;
    parameter PBR_RFRST = 4'b0100; 
    parameter PBR_RLOOP = 4'b1000; 
    reg     [PBR_FSM_BIT-1:0]       rPBR_cur_state          ;
    reg     [PBR_FSM_BIT-1:0]       rPBR_nxt_state          ;
    reg                             rReady                  ;
    reg     [3:0]                   rTimer                  ;
    wire                            wJOBDone                ;
    reg                             rPI_BUFF_Reset          ;
    reg                             rPI_BUFF_RE             ;
    reg                             rPI_BUFF_WE             ;
    reg     [7:0]                   rPO_DQStrobe            ;
    reg                             rDQSOutEnable           ;
    assign wJOBDone = (4'b1010 == rTimer[3:0]);
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rPBR_cur_state <= PBR_RESET;
        end else begin
            rPBR_cur_state <= rPBR_nxt_state;
        end
    end
    always @ ( * ) begin
        case (rPBR_cur_state)
            PBR_RESET: begin
                rPBR_nxt_state <= PBR_READY;
            end
            PBR_READY: begin
                rPBR_nxt_state <= (iStart)? PBR_RFRST:PBR_READY;
            end
            PBR_RFRST: begin
                rPBR_nxt_state <= PBR_RLOOP;
            end
            PBR_RLOOP: begin
                rPBR_nxt_state <= (wJOBDone)? ((iStart)? PBR_RFRST:PBR_READY):PBR_RLOOP;
            end
            default:
                rPBR_nxt_state <= PBR_READY;
        endcase
    end
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rReady              <= 0;
            rTimer[3:0]         <= 0;
            rPI_BUFF_Reset      <= 0;
            rPI_BUFF_RE         <= 0;
            rPI_BUFF_WE         <= 0;
            rPO_DQStrobe[7:0]   <= 0;
            rDQSOutEnable       <= 0;
        end else begin
            case (rPBR_nxt_state)
                PBR_RESET: begin
                    rReady              <= 0;
                    rTimer[3:0]         <= 0;
                    rPI_BUFF_Reset      <= 0;
                    rPI_BUFF_RE         <= 0;
                    rPI_BUFF_WE         <= 0;
                    rPO_DQStrobe[7:0]   <= 0;
                    rDQSOutEnable       <= 0;
                end
                PBR_READY: begin
                    rReady              <= 1;
                    rTimer[3:0]         <= 0;
                    rPI_BUFF_Reset      <= 0;
                    rPI_BUFF_RE         <= 0;
                    rPI_BUFF_WE         <= 0;
                    rPO_DQStrobe[7:0]   <= 0;
                    rDQSOutEnable       <= 0;
                end
                PBR_RFRST: begin
                    rReady              <= 0;
                    rTimer[3:0]         <= 4'b0000;
                    rPI_BUFF_Reset      <= 1'b1;
                    rPI_BUFF_RE         <= 1'b0;
                    rPI_BUFF_WE         <= 1'b0;
                    rPO_DQStrobe[7:0]   <= 8'b0101_0101;
                    rDQSOutEnable       <= 1'b1;
                end
                PBR_RLOOP: begin
                    rReady              <= 0;
                    rTimer[3:0]         <= rTimer[3:0] + 1'b1;
                    rPI_BUFF_Reset      <= 1'b1;
                    rPI_BUFF_RE         <= 1'b0;
                    rPI_BUFF_WE         <= 1'b0;
                    rPO_DQStrobe[7:0]   <= 8'b0101_0101;
                    rDQSOutEnable       <= 1'b1;
                end
            endcase
        end
    end
    assign oReady           = rReady | wJOBDone ;
    assign oLastStep        = wJOBDone         ;
    assign oPI_BUFF_Reset   = rPI_BUFF_Reset    ;
    assign oPI_BUFF_RE      = rPI_BUFF_RE       ;
    assign oPI_BUFF_WE      = rPI_BUFF_WE       ;
    assign oPO_DQStrobe     = rPO_DQStrobe      ;
    assign oDQSOutEnable    = rDQSOutEnable     ;
endmodule
