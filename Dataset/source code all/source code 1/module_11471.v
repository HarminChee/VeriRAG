`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PCIEBus_gtp_pipe_rate #
(
    parameter PCIE_SIM_SPEEDUP = "FALSE",                   
    parameter TXDATA_WAIT_MAX  = 4'd15                      
)
(
    input               RATE_CLK,
    input               RATE_RST_N,
    input       [ 1:0]  RATE_RATE_IN,
    input               RATE_DRP_DONE,
    input               RATE_RXPMARESETDONE,
    input               RATE_TXRATEDONE,
    input               RATE_RXRATEDONE,
    input               RATE_TXSYNC_DONE,
    input               RATE_PHYSTATUS,
    output              RATE_PCLK_SEL,
    output              RATE_DRP_START,
    output              RATE_DRP_X16,
    output      [ 2:0]  RATE_RATE_OUT,
    output              RATE_TXSYNC_START,
    output              RATE_DONE,
    output              RATE_IDLE,
    output      [ 4:0]  RATE_FSM
);
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  rate_in_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 drp_done_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxpmaresetdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txratedone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxratedone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 phystatus_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txsync_done_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  rate_in_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 drp_done_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxpmaresetdone_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txratedone_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxratedone_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 phystatus_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txsync_done_reg2;
    wire        [ 2:0]  rate;
    reg         [ 3:0]  txdata_wait_cnt = 4'd0;
    reg                 txratedone      = 1'd0;
    reg                 rxratedone      = 1'd0;
    reg                 phystatus       = 1'd0;
    reg                 ratedone        = 1'd0;
    reg                 pclk_sel =  1'd0; 
    reg         [ 2:0]  rate_out =  3'd0; 
    reg         [ 3:0]  fsm      =  0;                 
    localparam          FSM_IDLE           = 0; 
    localparam          FSM_TXDATA_WAIT    = 1;           
    localparam          FSM_PCLK_SEL       = 2; 
    localparam          FSM_DRP_X16_START  = 3;
    localparam          FSM_DRP_X16_DONE   = 4;   
    localparam          FSM_RATE_SEL       = 5;
    localparam          FSM_RXPMARESETDONE = 6; 
    localparam          FSM_DRP_X20_START  = 7;
    localparam          FSM_DRP_X20_DONE   = 8;   
    localparam          FSM_RATE_DONE      = 9;
    localparam          FSM_TXSYNC_START   = 10;
    localparam          FSM_TXSYNC_DONE    = 11;             
    localparam          FSM_DONE           = 12; 
always @ (posedge RATE_CLK)
begin
    if (!RATE_RST_N)
        begin    
        rate_in_reg1        <= 2'd0;
        drp_done_reg1       <= 1'd0;
        rxpmaresetdone_reg1 <= 1'd0;
        txratedone_reg1     <= 1'd0;
        rxratedone_reg1     <= 1'd0;
        phystatus_reg1      <= 1'd0;
        txsync_done_reg1    <= 1'd0;
        rate_in_reg2        <= 2'd0;
        drp_done_reg2       <= 1'd0;
        rxpmaresetdone_reg2 <= 1'd0;
        txratedone_reg2     <= 1'd0;
        rxratedone_reg2     <= 1'd0;
        phystatus_reg2      <= 1'd0;
        txsync_done_reg2    <= 1'd0;
        end
    else
        begin  
        rate_in_reg1        <= RATE_RATE_IN;
        drp_done_reg1       <= RATE_DRP_DONE;
        rxpmaresetdone_reg1 <= RATE_RXPMARESETDONE;
        txratedone_reg1     <= RATE_TXRATEDONE;
        rxratedone_reg1     <= RATE_RXRATEDONE;
        phystatus_reg1      <= RATE_PHYSTATUS;
        txsync_done_reg1    <= RATE_TXSYNC_DONE;
        rate_in_reg2        <= rate_in_reg1;
        drp_done_reg2       <= drp_done_reg1;
        rxpmaresetdone_reg2 <= rxpmaresetdone_reg1;
        txratedone_reg2     <= txratedone_reg1;
        rxratedone_reg2     <= rxratedone_reg1;
        phystatus_reg2      <= phystatus_reg1;
        txsync_done_reg2    <= txsync_done_reg1;   
        end
end    
assign rate = (rate_in_reg2 == 2'd1) ? 3'd1 : 3'd0;
always @ (posedge RATE_CLK)
begin
    if (!RATE_RST_N)
        txdata_wait_cnt <= 4'd0;
    else
        if ((fsm == FSM_TXDATA_WAIT) && (txdata_wait_cnt < TXDATA_WAIT_MAX))
            txdata_wait_cnt <= txdata_wait_cnt + 4'd1;
        else if ((fsm == FSM_TXDATA_WAIT) && (txdata_wait_cnt == TXDATA_WAIT_MAX))
            txdata_wait_cnt <= txdata_wait_cnt;
        else
            txdata_wait_cnt <= 4'd0;
end 
always @ (posedge RATE_CLK)
begin
    if (!RATE_RST_N)
        begin   
        txratedone <= 1'd0;
        rxratedone <= 1'd0; 
        phystatus  <= 1'd0;
        ratedone   <= 1'd0;
        end
    else
        begin  
        if ((fsm == FSM_RATE_DONE) || (fsm == FSM_RXPMARESETDONE) || (fsm == FSM_DRP_X20_START) || (fsm == FSM_DRP_X20_DONE))
            begin
            if (txratedone_reg2)
                txratedone <= 1'd1; 
            else
                txratedone <= txratedone;
            if (rxratedone_reg2)
                rxratedone <= 1'd1; 
            else
                rxratedone <= rxratedone;
            if (phystatus_reg2)
                phystatus <= 1'd1; 
            else
                phystatus <= phystatus;
            if (rxratedone && txratedone && phystatus)
                ratedone <= 1'd1; 
            else
                ratedone <= ratedone;
            end
        else 
            begin
            txratedone <= 1'd0;
            rxratedone <= 1'd0;
            phystatus  <= 1'd0;
            ratedone   <= 1'd0;
            end
        end
end    
always @ (posedge RATE_CLK)
begin
    if (!RATE_RST_N)
        begin
        fsm      <= FSM_IDLE;
        pclk_sel <= 1'd0; 
        rate_out <= 3'd0;                              
        end
    else
        begin
        case (fsm)
        FSM_IDLE :
            begin
            if (rate_in_reg2 != rate_in_reg1)
                begin
                fsm      <= FSM_TXDATA_WAIT;
                pclk_sel <= pclk_sel;
                rate_out <= rate_out;
                end
            else
                begin
                fsm      <= FSM_IDLE;
                pclk_sel <= pclk_sel;
                rate_out <= rate_out;
                end
            end 
        FSM_TXDATA_WAIT :
            begin
            fsm      <= (txdata_wait_cnt == TXDATA_WAIT_MAX) ? FSM_PCLK_SEL : FSM_TXDATA_WAIT;
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end 
        FSM_PCLK_SEL :
            begin
            fsm      <= (PCIE_SIM_SPEEDUP == "TRUE") ? FSM_RATE_SEL : FSM_DRP_X16_START;    
            pclk_sel <= (rate_in_reg2 == 2'd1);
            rate_out <= rate_out;
            end
        FSM_DRP_X16_START :
            begin
            fsm      <= (!drp_done_reg2) ? FSM_DRP_X16_DONE : FSM_DRP_X16_START;
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end
        FSM_DRP_X16_DONE :
            begin  
            fsm      <= drp_done_reg2 ? FSM_RATE_SEL : FSM_DRP_X16_DONE;
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end      
        FSM_RATE_SEL :
            begin
            fsm      <= (PCIE_SIM_SPEEDUP == "TRUE") ? FSM_RATE_DONE : FSM_RXPMARESETDONE;
            pclk_sel <= pclk_sel;
            rate_out <= rate;                               
            end    
        FSM_RXPMARESETDONE :
            begin
            fsm      <= (!rxpmaresetdone_reg2) ? FSM_DRP_X20_START : FSM_RXPMARESETDONE;  
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end  
        FSM_DRP_X20_START :
            begin
            fsm      <= (!drp_done_reg2) ? FSM_DRP_X20_DONE : FSM_DRP_X20_START;
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end
        FSM_DRP_X20_DONE :
            begin  
            fsm      <= drp_done_reg2 ? FSM_RATE_DONE : FSM_DRP_X20_DONE;
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end      
        FSM_RATE_DONE :
            begin
            if (ratedone) 
                fsm <= FSM_TXSYNC_START;
            else      
                fsm <= FSM_RATE_DONE;
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end      
        FSM_TXSYNC_START:
            begin
            fsm      <= (!txsync_done_reg2 ? FSM_TXSYNC_DONE : FSM_TXSYNC_START);
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end
        FSM_TXSYNC_DONE:
            begin
            fsm      <= (txsync_done_reg2 ? FSM_DONE : FSM_TXSYNC_DONE);
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end        
        FSM_DONE :  
            begin  
            fsm      <= FSM_IDLE;
            pclk_sel <= pclk_sel;
            rate_out <= rate_out;
            end
        default :
            begin
            fsm      <= FSM_IDLE;
            pclk_sel <= 1'd0; 
            rate_out <= 3'd0;  
            end
        endcase
        end
end 
assign RATE_PCLK_SEL     = pclk_sel;
assign RATE_DRP_START    = (fsm == FSM_DRP_X16_START) || (fsm == FSM_DRP_X20_START); 
assign RATE_DRP_X16      = (fsm == FSM_DRP_X16_START) || (fsm == FSM_DRP_X16_DONE);
assign RATE_RATE_OUT     = rate_out;
assign RATE_TXSYNC_START = (fsm == FSM_TXSYNC_START);
assign RATE_DONE         = (fsm == FSM_DONE);
assign RATE_IDLE         = (fsm == FSM_IDLE);
assign RATE_FSM          = {1'd0, fsm};   
endmodule
