`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_8_gtp_pipe_rate #
(
    parameter TXDATA_WAIT_MAX   = 4'd15                     
)
(
    input               RATE_CLK,
    input               RATE_RST_N,
    input               RATE_RST_IDLE,
    input       [ 1:0]  RATE_RATE_IN,
    input               RATE_TXRATEDONE,
    input               RATE_RXRATEDONE,
    input               RATE_TXSYNC_DONE,
    input               RATE_PHYSTATUS,
    output              RATE_PCLK_SEL,
    output      [ 2:0]  RATE_RATE_OUT,
    output              RATE_TXSYNC_START,
    output              RATE_DONE,
    output              RATE_IDLE,
    output      [23:0]  RATE_FSM
);
    reg                 rst_idle_reg1;
    reg         [ 1:0]  rate_in_reg1;
    reg                 txratedone_reg1;
    reg                 rxratedone_reg1;
    reg                 phystatus_reg1;
    reg                 txsync_done_reg1;
    reg                 rst_idle_reg2;
    reg         [ 1:0]  rate_in_reg2;
    reg                 txratedone_reg2;
    reg                 rxratedone_reg2;
    reg                 phystatus_reg2;
    reg                 txsync_done_reg2;
    wire                pll_lock;
    wire        [ 2:0]  rate;
    reg         [ 3:0]  txdata_wait_cnt = 4'd0;
    reg                 txratedone      = 1'd0;
    reg                 rxratedone      = 1'd0;
    reg                 phystatus       = 1'd0;
    reg                 ratedone        = 1'd0;
    reg                 pclk_sel   =  1'd0; 
    reg         [ 2:0]  rate_out   =  3'd0; 
    reg         [7:0]   fsm        =  8'd0;                 
    localparam          FSM_IDLE             = 8'b00000001; 
    localparam          FSM_TXDATA_WAIT      = 8'b00000010;           
    localparam          FSM_PCLK_SEL         = 8'b00000100;   
    localparam          FSM_RATE_SEL         = 8'b00001000;
    localparam          FSM_RATE_DONE        = 8'b00010000;
    localparam          FSM_TXSYNC_START     = 8'b00100000;
    localparam          FSM_TXSYNC_DONE      = 8'b01000000;             
    localparam          FSM_DONE             = 8'b10000000; 
always @ (posedge RATE_CLK)
begin
    if (!RATE_RST_N)
        begin    
        rst_idle_reg1       <= 1'd0;   
        rate_in_reg1        <= 2'd0;
        txratedone_reg1     <= 1'd0;
        rxratedone_reg1     <= 1'd0;
        phystatus_reg1      <= 1'd0;
        txsync_done_reg1    <= 1'd0;
        rst_idle_reg2       <= 1'd0;
        rate_in_reg2        <= 2'd0;
        txratedone_reg2     <= 1'd0;
        rxratedone_reg2     <= 1'd0;
        phystatus_reg2      <= 1'd0;
        txsync_done_reg2    <= 1'd0;
        end
    else
        begin  
        rst_idle_reg1       <= RATE_RST_IDLE;
        rate_in_reg1        <= RATE_RATE_IN;
        txratedone_reg1     <= RATE_TXRATEDONE;
        rxratedone_reg1     <= RATE_RXRATEDONE;
        phystatus_reg1      <= RATE_PHYSTATUS;
        txsync_done_reg1    <= RATE_TXSYNC_DONE;
        rst_idle_reg2       <= rst_idle_reg1;
        rate_in_reg2        <= rate_in_reg1;
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
        if (fsm == FSM_RATE_DONE)
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
        fsm        <= FSM_IDLE;
        pclk_sel   <= 1'd0; 
        rate_out   <= 3'd0;                              
        end
    else
        begin
        case (fsm)
        FSM_IDLE :
            begin
            if (rate_in_reg2 != rate_in_reg1)
                begin
                fsm        <=  FSM_TXDATA_WAIT;
                pclk_sel   <= pclk_sel;
                rate_out   <= rate_out;
                end
            else
                begin
                fsm        <= FSM_IDLE;
                pclk_sel   <= pclk_sel;
                rate_out   <= rate_out;
                end
            end 
        FSM_TXDATA_WAIT :
            begin
            fsm        <= (txdata_wait_cnt == TXDATA_WAIT_MAX) ? FSM_PCLK_SEL : FSM_TXDATA_WAIT;
            pclk_sel   <= pclk_sel;
            rate_out   <= rate_out;
            end 
        FSM_PCLK_SEL :
            begin
            fsm        <= FSM_RATE_SEL;    
            pclk_sel   <= (rate_in_reg2 == 2'd1);
            rate_out   <= rate_out;
            end
        FSM_RATE_SEL :
            begin
            fsm        <= FSM_RATE_DONE;
            pclk_sel   <= pclk_sel;
            rate_out   <= rate;                             
            end    
        FSM_RATE_DONE :
            begin
            if (ratedone ) 
                    fsm <= FSM_TXSYNC_START;
            else      
                    fsm <= FSM_RATE_DONE;
            pclk_sel   <= pclk_sel;
            rate_out   <= rate_out;
            end      
        FSM_TXSYNC_START:
            begin
            fsm        <= (!txsync_done_reg2 ? FSM_TXSYNC_DONE : FSM_TXSYNC_START);
            pclk_sel   <= pclk_sel;
            rate_out   <= rate_out;
            end
        FSM_TXSYNC_DONE:
            begin
            fsm        <= (txsync_done_reg2 ? FSM_DONE : FSM_TXSYNC_DONE);
            pclk_sel   <= pclk_sel;
            rate_out   <= rate_out;
            end        
        FSM_DONE :  
            begin  
            fsm        <= FSM_IDLE;
            pclk_sel   <= pclk_sel;
            rate_out   <= rate_out;
            end
        default :
            begin
            fsm        <= FSM_IDLE;
            pclk_sel   <= 1'd0; 
            rate_out   <= 3'd0;  
            end
        endcase
        end
end 
assign RATE_PCLK_SEL        = pclk_sel;
assign RATE_RATE_OUT        = rate_out;
assign RATE_TXSYNC_START    = (fsm == FSM_TXSYNC_START);
assign RATE_DONE            = (fsm == FSM_DONE);
assign RATE_IDLE            = (fsm == FSM_IDLE);
assign RATE_FSM             = fsm;   
endmodule
