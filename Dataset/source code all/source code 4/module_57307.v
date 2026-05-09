`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_8_pipe_reset #
(
    parameter PCIE_PLL_SEL      = "CPLL",                   
    parameter PCIE_POWER_SAVING = "TRUE",                   
    parameter PCIE_TXBUF_EN     = "FALSE",                  
    parameter PCIE_LANE         = 1,                        
    parameter CFG_WAIT_MAX      = 6'd63,                    
    parameter BYPASS_RXCDRLOCK  = 1                         
)
(
    input                           RST_CLK,
    input                           RST_RXUSRCLK,
    input                           RST_DCLK,
    input                           RST_RST_N,
    input       [PCIE_LANE-1:0]     RST_CPLLLOCK,
    input                           RST_QPLL_IDLE,
    input       [PCIE_LANE-1:0]     RST_RATE_IDLE,
    input       [PCIE_LANE-1:0]     RST_RXCDRLOCK,
    input                           RST_MMCM_LOCK,
    input       [PCIE_LANE-1:0]     RST_RESETDONE,
    input       [PCIE_LANE-1:0]     RST_PHYSTATUS,
    input       [PCIE_LANE-1:0]     RST_TXSYNC_DONE,
    output                          RST_CPLLRESET,
    output                          RST_CPLLPD,
    output                          RST_RXUSRCLK_RESET,
    output                          RST_DCLK_RESET,
    output                          RST_GTRESET,
    output                          RST_USERRDY,
    output                          RST_TXSYNC_START,
    output                          RST_IDLE,
    output      [10:0]              RST_FSM
);
    reg         [PCIE_LANE-1:0]     cplllock_reg1;
    reg                             qpll_idle_reg1;
    reg         [PCIE_LANE-1:0]     rate_idle_reg1;
    reg         [PCIE_LANE-1:0]     rxcdrlock_reg1;
    reg                             mmcm_lock_reg1;
    reg         [PCIE_LANE-1:0]     resetdone_reg1;
    reg         [PCIE_LANE-1:0]     phystatus_reg1;
    reg         [PCIE_LANE-1:0]     txsync_done_reg1;  
    reg         [PCIE_LANE-1:0]     cplllock_reg2;
    reg                             qpll_idle_reg2;
    reg         [PCIE_LANE-1:0]     rate_idle_reg2;
    reg         [PCIE_LANE-1:0]     rxcdrlock_reg2;
    reg                             mmcm_lock_reg2;
    reg         [PCIE_LANE-1:0]     resetdone_reg2;
    reg         [PCIE_LANE-1:0]     phystatus_reg2;
    reg         [PCIE_LANE-1:0]     txsync_done_reg2;
    reg         [ 5:0]              cfg_wait_cnt      =  6'd0;
    reg                             cpllreset         =  1'd0;
    reg                             cpllpd            =  1'd0;
    reg                             rxusrclk_rst_reg1 =  1'd0;
    reg                             rxusrclk_rst_reg2 =  1'd0;
    reg                             dclk_rst_reg1     =  1'd0;
    reg                             dclk_rst_reg2     =  1'd0;
    reg                             gtreset           =  1'd0;
    reg                             userrdy           =  1'd0;
    reg         [10:0]              fsm               = 11'd2;                 
    localparam                      FSM_IDLE          = 11'b00000000001; 
    localparam                      FSM_CFG_WAIT      = 11'b00000000010;
    localparam                      FSM_CPLLRESET     = 11'b00000000100;     
    localparam                      FSM_CPLLLOCK      = 11'b00000001000;
    localparam                      FSM_DRP           = 11'b00000010000;                            
    localparam                      FSM_GTRESET       = 11'b00000100000;                      
    localparam                      FSM_MMCM_LOCK     = 11'b00001000000;  
    localparam                      FSM_RESETDONE     = 11'b00010000000;  
    localparam                      FSM_CPLL_PD       = 11'b00100000000;  
    localparam                      FSM_TXSYNC_START  = 11'b01000000000;
    localparam                      FSM_TXSYNC_DONE   = 11'b10000000000;                                 
always @ (posedge RST_CLK)
begin
    if (!RST_RST_N)
        begin    
        cplllock_reg1    <= {PCIE_LANE{1'd0}}; 
        qpll_idle_reg1   <= 1'd0;
        rate_idle_reg1   <= {PCIE_LANE{1'd0}}; 
        rxcdrlock_reg1   <= {PCIE_LANE{1'd0}}; 
        mmcm_lock_reg1   <= 1'd0; 
        resetdone_reg1   <= {PCIE_LANE{1'd0}}; 
        phystatus_reg1   <= {PCIE_LANE{1'd0}}; 
        txsync_done_reg1 <= {PCIE_LANE{1'd0}}; 
        cplllock_reg2    <= {PCIE_LANE{1'd0}}; 
        qpll_idle_reg2   <= 1'd0;
        rate_idle_reg2   <= {PCIE_LANE{1'd0}}; 
        rxcdrlock_reg2   <= {PCIE_LANE{1'd0}}; 
        mmcm_lock_reg2   <= 1'd0;
        resetdone_reg2   <= {PCIE_LANE{1'd0}}; 
        phystatus_reg2   <= {PCIE_LANE{1'd0}}; 
        txsync_done_reg2 <= {PCIE_LANE{1'd0}}; 
        end
    else
        begin  
        cplllock_reg1    <= RST_CPLLLOCK;
        qpll_idle_reg1   <= RST_QPLL_IDLE;
        rate_idle_reg1   <= RST_RATE_IDLE;
        rxcdrlock_reg1   <= RST_RXCDRLOCK;
        mmcm_lock_reg1   <= RST_MMCM_LOCK;
        resetdone_reg1   <= RST_RESETDONE;
        phystatus_reg1   <= RST_PHYSTATUS;
        txsync_done_reg1 <= RST_TXSYNC_DONE;
        cplllock_reg2    <= cplllock_reg1;
        qpll_idle_reg2   <= qpll_idle_reg1;
        rate_idle_reg2   <= rate_idle_reg1;
        rxcdrlock_reg2   <= rxcdrlock_reg1;
        mmcm_lock_reg2   <= mmcm_lock_reg1;
        resetdone_reg2   <= resetdone_reg1;
        phystatus_reg2   <= phystatus_reg1;
        txsync_done_reg2 <= txsync_done_reg1;   
        end
end    
always @ (posedge RST_CLK)
begin
    if (!RST_RST_N)
        cfg_wait_cnt <= 6'd0;
    else
        if ((fsm == FSM_CFG_WAIT) && (cfg_wait_cnt < CFG_WAIT_MAX))
            cfg_wait_cnt <= cfg_wait_cnt + 6'd1;
        else if ((fsm == FSM_CFG_WAIT) && (cfg_wait_cnt == CFG_WAIT_MAX))
            cfg_wait_cnt <= cfg_wait_cnt;
        else
            cfg_wait_cnt <= 6'd0;
end 
always @ (posedge RST_CLK)
begin
    if (!RST_RST_N)
        begin
        fsm       <= FSM_CFG_WAIT;
        cpllreset <= 1'd0;
        cpllpd    <= 1'd0;
        gtreset   <= 1'd0;
        userrdy   <= 1'd0;
        end
    else
        begin
        case (fsm)
        FSM_IDLE :
            begin
            if (!RST_RST_N)
                begin
                fsm       <= FSM_CFG_WAIT;
                cpllreset <= 1'd0;
                cpllpd    <= 1'd0;
                gtreset   <= 1'd0;
                userrdy   <= 1'd0;
                end
            else
                begin
                fsm       <= FSM_IDLE;
                cpllreset <= cpllreset;
                cpllpd    <= cpllpd;
                gtreset   <= gtreset;
                userrdy   <= userrdy;
                end
            end  
        FSM_CFG_WAIT :
            begin
            fsm       <= ((cfg_wait_cnt == CFG_WAIT_MAX) ? FSM_CPLLRESET : FSM_CFG_WAIT);
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end 
        FSM_CPLLRESET :
            begin
            fsm       <= ((&(~cplllock_reg2) && (&(~resetdone_reg2))) ? FSM_CPLLLOCK : FSM_CPLLRESET);
            cpllreset <= 1'd1;
            cpllpd    <= cpllpd;
            gtreset   <= 1'd1;
            userrdy   <= userrdy;
            end  
        FSM_CPLLLOCK :
            begin
            fsm       <= (&cplllock_reg2 ? FSM_DRP : FSM_CPLLLOCK);
            cpllreset <= 1'd0;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_DRP :
            begin
            fsm       <= (&rate_idle_reg2 ? FSM_GTRESET : FSM_DRP);
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_GTRESET :
            begin
            fsm       <= FSM_MMCM_LOCK;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= 1'b0;
            userrdy   <= userrdy;
            end
        FSM_MMCM_LOCK :
            begin  
            if (mmcm_lock_reg2 && (&rxcdrlock_reg2 || (BYPASS_RXCDRLOCK == 1)) && (qpll_idle_reg2 || (PCIE_PLL_SEL == "CPLL")))
                begin
                fsm       <= FSM_RESETDONE;
                cpllreset <= cpllreset;
                cpllpd    <= cpllpd;
                gtreset   <= gtreset;
                userrdy   <= 1'd1;
                end
            else
                begin
                fsm       <= FSM_MMCM_LOCK;
                cpllreset <= cpllreset;
                cpllpd    <= cpllpd;
                gtreset   <= gtreset;
                userrdy   <= 1'd0;
                end
            end
        FSM_RESETDONE :
            begin
            fsm       <= (&resetdone_reg2 && (&(~phystatus_reg2)) ? FSM_CPLL_PD : FSM_RESETDONE);  
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_CPLL_PD :
            begin
            fsm       <= ((PCIE_TXBUF_EN == "TRUE") ? FSM_IDLE : FSM_TXSYNC_START);
            cpllreset <= cpllreset;
            cpllpd    <= (PCIE_PLL_SEL == "QPLL");
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_TXSYNC_START :
            begin
            fsm       <= (&(~txsync_done_reg2) ? FSM_TXSYNC_DONE : FSM_TXSYNC_START);
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_TXSYNC_DONE :
            begin
            fsm       <= (&txsync_done_reg2 ? FSM_IDLE : FSM_TXSYNC_DONE);
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end     
        default :
            begin
            fsm       <= FSM_CFG_WAIT;
            cpllreset <= 1'd0;
            cpllpd    <= 1'd0;
            gtreset   <= 1'd0;
            userrdy   <= 1'd0;
            end
        endcase
        end
end
always @ (posedge RST_RXUSRCLK)
begin
    if (cpllreset) 
        begin
        rxusrclk_rst_reg1 <= 1'd1;
        rxusrclk_rst_reg2 <= 1'd1;
        end
    else
        begin
        rxusrclk_rst_reg1 <= 1'd0;
        rxusrclk_rst_reg2 <= rxusrclk_rst_reg1;
        end   
end  
always @ (posedge RST_DCLK)
begin
    if (cpllreset) 
        begin
        dclk_rst_reg1 <= 1'd1;
        dclk_rst_reg2 <= 1'd1;
        end
    else
        begin
        dclk_rst_reg1 <= 1'd0;
        dclk_rst_reg2 <= dclk_rst_reg1;
        end   
end  
assign RST_CPLLRESET      = cpllreset; 
assign RST_CPLLPD         = ((PCIE_POWER_SAVING == "FALSE") ? 1'd0 : cpllpd);
assign RST_RXUSRCLK_RESET = rxusrclk_rst_reg2;
assign RST_DCLK_RESET     = dclk_rst_reg2;
assign RST_GTRESET        = gtreset;  
assign RST_USERRDY        = userrdy;
assign RST_TXSYNC_START   = (fsm == FSM_TXSYNC_START);
assign RST_IDLE           = (fsm == FSM_IDLE);
assign RST_FSM            = fsm;                   
endmodule
