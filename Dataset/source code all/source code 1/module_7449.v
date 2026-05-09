`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcieCore_pipe_reset #
(
    parameter PCIE_SIM_SPEEDUP  = "FALSE",                  
    parameter PCIE_GT_DEVICE    = "GTX",
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
    input       [PCIE_LANE-1:0]     RST_DRP_DONE,
    input       [PCIE_LANE-1:0]     RST_RXPMARESETDONE,
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
    output reg                      RST_DRP_START,
    output reg                      RST_DRP_X16X20_MODE,
    output reg                      RST_DRP_X16,
    output                          RST_RXUSRCLK_RESET,
    output                          RST_DCLK_RESET,
    output                          RST_GTRESET,
    output                          RST_USERRDY,
    output                          RST_TXSYNC_START,
    output                          RST_IDLE,
    output      [4:0]               RST_FSM
);
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     drp_done_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     rxpmaresetdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     cplllock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             qpll_idle_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     rate_idle_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     rxcdrlock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             mmcm_lock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     resetdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     phystatus_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     txsync_done_reg1;  
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     drp_done_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     rxpmaresetdone_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     cplllock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             qpll_idle_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     rate_idle_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     rxcdrlock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             mmcm_lock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     resetdone_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     phystatus_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     txsync_done_reg2;
    reg         [ 5:0]              cfg_wait_cnt      =  6'd0;
    reg                             cpllreset         =  1'd0;
    reg                             cpllpd            =  1'd0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             rxusrclk_rst_reg1 =  1'd0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             rxusrclk_rst_reg2 =  1'd0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             dclk_rst_reg1     =  1'd0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             dclk_rst_reg2     =  1'd0;
    reg                             gtreset           =  1'd0;
    reg                             userrdy           =  1'd0;
    reg         [4:0]               fsm               =  5'h2;
    localparam                      FSM_IDLE             = 5'h0;
    localparam                      FSM_CFG_WAIT         = 5'h1;
    localparam                      FSM_CPLLRESET        = 5'h2;
    localparam                      FSM_DRP_X16_START    = 5'h3;
    localparam                      FSM_DRP_X16_DONE     = 5'h4;
    localparam                      FSM_CPLLLOCK         = 5'h5;
    localparam                      FSM_DRP              = 5'h6;
    localparam                      FSM_GTRESET          = 5'h7;
    localparam                      FSM_RXPMARESETDONE_1 = 5'h8;
    localparam                      FSM_RXPMARESETDONE_2 = 5'h9;
    localparam                      FSM_DRP_X20_START    = 5'hA;
    localparam                      FSM_DRP_X20_DONE     = 5'hB;
    localparam                      FSM_MMCM_LOCK        = 5'hC;
    localparam                      FSM_RESETDONE        = 5'hD;
    localparam                      FSM_CPLL_PD          = 5'hE;
    localparam                      FSM_TXSYNC_START     = 5'hF;
    localparam                      FSM_TXSYNC_DONE      = 5'h10;
always @ (posedge RST_CLK)
begin
    if (!RST_RST_N)
        begin    
        drp_done_reg1       <= {PCIE_LANE{1'd0}};   
        rxpmaresetdone_reg1 <= {PCIE_LANE{1'd0}}; 
        cplllock_reg1       <= {PCIE_LANE{1'd0}}; 
        qpll_idle_reg1      <= 1'd0;
        rate_idle_reg1      <= {PCIE_LANE{1'd0}}; 
        rxcdrlock_reg1      <= {PCIE_LANE{1'd0}}; 
        mmcm_lock_reg1      <= 1'd0; 
        resetdone_reg1      <= {PCIE_LANE{1'd0}}; 
        phystatus_reg1      <= {PCIE_LANE{1'd0}}; 
        txsync_done_reg1    <= {PCIE_LANE{1'd0}}; 
        drp_done_reg2       <= {PCIE_LANE{1'd0}};
        rxpmaresetdone_reg2 <= {PCIE_LANE{1'd0}}; 
        cplllock_reg2       <= {PCIE_LANE{1'd0}}; 
        qpll_idle_reg2      <= 1'd0;
        rate_idle_reg2      <= {PCIE_LANE{1'd0}}; 
        rxcdrlock_reg2      <= {PCIE_LANE{1'd0}}; 
        mmcm_lock_reg2      <= 1'd0;
        resetdone_reg2      <= {PCIE_LANE{1'd0}}; 
        phystatus_reg2      <= {PCIE_LANE{1'd0}}; 
        txsync_done_reg2    <= {PCIE_LANE{1'd0}}; 
        end
    else
        begin  
        drp_done_reg1       <= RST_DRP_DONE; 
        rxpmaresetdone_reg1 <= RST_RXPMARESETDONE;   
        cplllock_reg1       <= RST_CPLLLOCK;
        qpll_idle_reg1      <= RST_QPLL_IDLE;
        rate_idle_reg1      <= RST_RATE_IDLE;
        rxcdrlock_reg1      <= RST_RXCDRLOCK;
        mmcm_lock_reg1      <= RST_MMCM_LOCK;
        resetdone_reg1      <= RST_RESETDONE;
        phystatus_reg1      <= RST_PHYSTATUS;
        txsync_done_reg1    <= RST_TXSYNC_DONE;
        drp_done_reg2       <= drp_done_reg1;
        rxpmaresetdone_reg2 <= rxpmaresetdone_reg1;
        cplllock_reg2       <= cplllock_reg1;
        qpll_idle_reg2      <= qpll_idle_reg1;
        rate_idle_reg2      <= rate_idle_reg1;
        rxcdrlock_reg2      <= rxcdrlock_reg1;
        mmcm_lock_reg2      <= mmcm_lock_reg1;
        resetdone_reg2      <= resetdone_reg1;
        phystatus_reg2      <= phystatus_reg1;
        txsync_done_reg2    <= txsync_done_reg1;   
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
            fsm       <= ((&(~cplllock_reg2) && (&(~resetdone_reg2))) ?  FSM_CPLLLOCK : FSM_CPLLRESET);
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
            fsm       <= (&rate_idle_reg2 ? ((PCIE_GT_DEVICE == "GTX") ? FSM_GTRESET : FSM_DRP_X16_START) : FSM_DRP);
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_DRP_X16_START :
            begin
            fsm       <= &(~drp_done_reg2) ? FSM_DRP_X16_DONE : FSM_DRP_X16_START;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_DRP_X16_DONE :
            begin  
            fsm       <= (&drp_done_reg2) ? FSM_GTRESET : FSM_DRP_X16_DONE;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end  
        FSM_GTRESET :
            begin
            fsm       <= (PCIE_GT_DEVICE == "GTX") ? FSM_MMCM_LOCK : FSM_RXPMARESETDONE_1;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= 1'b0;
            userrdy   <= userrdy;
            end
        FSM_RXPMARESETDONE_1 :
            begin
            fsm       <= (&rxpmaresetdone_reg2 || (PCIE_SIM_SPEEDUP == "TRUE")) ? FSM_RXPMARESETDONE_2 : FSM_RXPMARESETDONE_1;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end  
        FSM_RXPMARESETDONE_2 :
            begin
            fsm       <= (&(~rxpmaresetdone_reg2) || (PCIE_SIM_SPEEDUP == "TRUE")) ? FSM_DRP_X20_START : FSM_RXPMARESETDONE_2;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end  
        FSM_DRP_X20_START :
            begin
            fsm       <= &(~drp_done_reg2) ? FSM_DRP_X20_DONE : FSM_DRP_X20_START;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
            userrdy   <= userrdy;
            end
        FSM_DRP_X20_DONE :
            begin  
            fsm       <= (&drp_done_reg2) ? FSM_MMCM_LOCK : FSM_DRP_X20_DONE;
            cpllreset <= cpllreset;
            cpllpd    <= cpllpd;
            gtreset   <= gtreset;
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
    if (fsm == FSM_CFG_WAIT)
        begin
        dclk_rst_reg1 <= 1'd1;
        dclk_rst_reg2 <= dclk_rst_reg1;
        end
    else
        begin
        dclk_rst_reg1 <= 1'd0;
        dclk_rst_reg2 <= dclk_rst_reg1;
        end   
end  
assign RST_CPLLRESET       = cpllreset; 
assign RST_CPLLPD          = ((PCIE_POWER_SAVING == "FALSE") ? 1'd0 : cpllpd);
assign RST_RXUSRCLK_RESET  = rxusrclk_rst_reg2;
assign RST_DCLK_RESET      = dclk_rst_reg2;
assign RST_GTRESET         = gtreset;  
assign RST_USERRDY         = userrdy;
assign RST_TXSYNC_START    = (fsm == FSM_TXSYNC_START);
assign RST_IDLE            = (fsm == FSM_IDLE);
assign RST_FSM             = fsm;                   
always @ (posedge RST_CLK)
begin
    if (!RST_RST_N) 
        begin
        RST_DRP_START       <= 1'd0;
        RST_DRP_X16X20_MODE <= 1'd0; 
        RST_DRP_X16         <= 1'd0;
        end
    else
        begin
        RST_DRP_START       <= (fsm == FSM_DRP_X16_START) || (fsm == FSM_DRP_X20_START); 
        RST_DRP_X16X20_MODE <= (fsm == FSM_DRP_X16_START) || (fsm == FSM_DRP_X16_DONE) || (fsm == FSM_DRP_X20_START) || (fsm == FSM_DRP_X20_DONE);
        RST_DRP_X16         <= (fsm == FSM_DRP_X16_START) || (fsm == FSM_DRP_X16_DONE);
        end
end  
endmodule
