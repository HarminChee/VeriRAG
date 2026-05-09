`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_rate #
(
    parameter PCIE_USE_MODE     = "1.1",                    
    parameter PCIE_PLL_SEL      = "CPLL",                   
    parameter PCIE_POWER_SAVING = "TRUE",                   
    parameter PCIE_ASYNC_EN     = "FALSE",                  
    parameter PCIE_TXBUF_EN     = "FALSE",                  
    parameter PCIE_RXBUF_EN     = "TRUE",                   
    parameter TXDATA_WAIT_MAX   = 4'd15                     
)
(
    input               RATE_CLK,
    input               RATE_RST_N,
    input               RATE_RST_IDLE,
    input       [ 1:0]  RATE_RATE_IN,
    input               RATE_CPLLLOCK,
    input               RATE_QPLLLOCK,
    input               RATE_MMCM_LOCK,
    input               RATE_DRP_DONE,
    input               RATE_TXRESETDONE,
    input               RATE_RXRESETDONE,
    input               RATE_TXRATEDONE,
    input               RATE_RXRATEDONE,
    input               RATE_PHYSTATUS,
    input               RATE_RESETOVRD_DONE,
    input               RATE_TXSYNC_DONE,
    input               RATE_RXSYNC_DONE,
    output              RATE_CPLLPD,
    output              RATE_QPLLPD,
    output              RATE_CPLLRESET,
    output              RATE_QPLLRESET,
    output              RATE_TXPMARESET,
    output              RATE_RXPMARESET,
    output              RATE_DRP_START,
    output      [ 1:0]  RATE_SYSCLKSEL,
    output              RATE_PCLK_SEL,
    output              RATE_GEN3,
    output      [ 2:0]  RATE_RATE_OUT,
    output              RATE_RESETOVRD_START,
    output              RATE_TXSYNC_START,
    output              RATE_DONE,
    output              RATE_RXSYNC_START,
    output              RATE_RXSYNC,
    output              RATE_IDLE,
    output      [23:0]  RATE_FSM
);
    reg                 rst_idle_reg1;
    reg         [ 1:0]  rate_in_reg1;
    reg                 cplllock_reg1;
    reg                 qplllock_reg1;
    reg                 mmcm_lock_reg1;
    reg                 drp_done_reg1;
    reg                 txresetdone_reg1;
    reg                 rxresetdone_reg1;
    reg                 txratedone_reg1;
    reg                 rxratedone_reg1;
    reg                 phystatus_reg1;
    reg                 resetovrd_done_reg1;
    reg                 txsync_done_reg1;
    reg                 rxsync_done_reg1;
    reg                 rst_idle_reg2;
    reg         [ 1:0]  rate_in_reg2;
    reg                 cplllock_reg2;
    reg                 qplllock_reg2;
    reg                 mmcm_lock_reg2;
    reg                 drp_done_reg2;
    reg                 txresetdone_reg2;
    reg                 rxresetdone_reg2;
    reg                 txratedone_reg2;
    reg                 rxratedone_reg2;
    reg                 phystatus_reg2;
    reg                 resetovrd_done_reg2;
    reg                 txsync_done_reg2;
    reg                 rxsync_done_reg2;
    wire                pll_lock;
    wire        [ 2:0]  rate;
    reg         [ 3:0]  txdata_wait_cnt = 4'd0;
    reg                 txratedone      = 1'd0;
    reg                 rxratedone      = 1'd0;
    reg                 phystatus       = 1'd0;
    reg                 ratedone        = 1'd0;
    reg                 gen3_exit       = 1'd0;
    reg                 cpllpd     =  1'd0;
    reg                 qpllpd     =  1'd0;
    reg                 cpllreset  =  1'd0;
    reg                 qpllreset  =  1'd0;
    reg                 txpmareset =  1'd0;
    reg                 rxpmareset =  1'd0;
    reg         [ 1:0]  sysclksel  = (PCIE_PLL_SEL == "QPLL") ? 2'd1 : 2'd0;
    reg                 gen3       =  1'd0;
    reg                 pclk_sel   =  1'd0;
    reg         [ 2:0]  rate_out   =  3'd0;
    reg         [23:0]  fsm        = 24'd0;
    localparam          FSM_IDLE             = 24'b000000000000000000000001;
    localparam          FSM_PLL_PU           = 24'b000000000000000000000010; 
    localparam          FSM_PLL_PURESET      = 24'b000000000000000000000100; 
    localparam          FSM_PLL_LOCK         = 24'b000000000000000000001000; 
    localparam          FSM_PMARESET_HOLD    = 24'b000000000000000000010000; 
    localparam          FSM_PLL_SEL          = 24'b000000000000000000100000; 
    localparam          FSM_MMCM_LOCK        = 24'b000000000000000001000000; 
    localparam          FSM_DRP_START        = 24'b000000000000000010000000; 
    localparam          FSM_DRP_DONE         = 24'b000000000000000100000000; 
    localparam          FSM_PMARESET_RELEASE = 24'b000000000000001000000000; 
    localparam          FSM_PMARESET_DONE    = 24'b000000000000010000000000; 
    localparam          FSM_TXDATA_WAIT      = 24'b000000000000100000000000;
    localparam          FSM_PCLK_SEL         = 24'b000000000001000000000000;
    localparam          FSM_RATE_SEL         = 24'b000000000010000000000000;
    localparam          FSM_RATE_DONE        = 24'b000000000100000000000000;
    localparam          FSM_RESETOVRD_START  = 24'b000000001000000000000000; 
    localparam          FSM_RESETOVRD_DONE   = 24'b000000010000000000000000; 
    localparam          FSM_PLL_PDRESET      = 24'b000000100000000000000000;
    localparam          FSM_PLL_PD           = 24'b000001000000000000000000;
    localparam          FSM_TXSYNC_START     = 24'b000010000000000000000000;
    localparam          FSM_TXSYNC_DONE      = 24'b000100000000000000000000;
    localparam          FSM_DONE             = 24'b001000000000000000000000; 
    localparam          FSM_RXSYNC_START     = 24'b010000000000000000000000; 
    localparam          FSM_RXSYNC_DONE      = 24'b100000000000000000000000; 
always @ (posedge RATE_CLK)
begin
    if (!RATE_RST_N)
        begin
        rst_idle_reg1       <= 1'd0;
        rate_in_reg1        <= 2'd0;
        cplllock_reg1       <= 1'd0;
        qplllock_reg1       <= 1'd0;
        mmcm_lock_reg1      <= 1'd0;
        drp_done_reg1       <= 1'd0;
        txresetdone_reg1    <= 1'd0;
        rxresetdone_reg1    <= 1'd0;
        txratedone_reg1     <= 1'd0;
        rxratedone_reg1     <= 1'd0;
        phystatus_reg1      <= 1'd0;
        resetovrd_done_reg1 <= 1'd0;
        txsync_done_reg1    <= 1'd0;
        rxsync_done_reg1    <= 1'd0;
        rst_idle_reg2       <= 1'd0;
        rate_in_reg2        <= 2'd0;
        cplllock_reg2       <= 1'd0;
        qplllock_reg2       <= 1'd0;
        mmcm_lock_reg2      <= 1'd0;
        drp_done_reg2       <= 1'd0;
        txresetdone_reg2    <= 1'd0;
        rxresetdone_reg2    <= 1'd0;
        txratedone_reg2     <= 1'd0;
        rxratedone_reg2     <= 1'd0;
        phystatus_reg2      <= 1'd0;
        resetovrd_done_reg2 <= 1'd0;
        txsync_done_reg2    <= 1'd0;
        rxsync_done_reg2    <= 1'd0;
        end
    else
        begin
        rst_idle_reg1       <= RATE_RST_IDLE;
        rate_in_reg1        <= RATE_RATE_IN;
        cplllock_reg1       <= RATE_CPLLLOCK;
        qplllock_reg1       <= RATE_QPLLLOCK;
        mmcm_lock_reg1      <= RATE_MMCM_LOCK;
        drp_done_reg1       <= RATE_DRP_DONE;
        txresetdone_reg1    <= RATE_TXRESETDONE;
        rxresetdone_reg1    <= RATE_RXRESETDONE;
        txratedone_reg1     <= RATE_TXRATEDONE;
        rxratedone_reg1     <= RATE_RXRATEDONE;
        phystatus_reg1      <= RATE_PHYSTATUS;
        resetovrd_done_reg1 <= RATE_RESETOVRD_DONE;
        txsync_done_reg1    <= RATE_TXSYNC_DONE;
        rxsync_done_reg1    <= RATE_RXSYNC_DONE;
        rst_idle_reg2       <= rst_idle_reg1;
        rate_in_reg2        <= rate_in_reg1;
        cplllock_reg2       <= cplllock_reg1;
        qplllock_reg2       <= qplllock_reg1;
        mmcm_lock_reg2      <= mmcm_lock_reg1;
        drp_done_reg2       <= drp_done_reg1;
        txresetdone_reg2    <= txresetdone_reg1;
        rxresetdone_reg2    <= rxresetdone_reg1;
        txratedone_reg2     <= txratedone_reg1;
        rxratedone_reg2     <= rxratedone_reg1;
        phystatus_reg2      <= phystatus_reg1;
        resetovrd_done_reg2 <= resetovrd_done_reg1;
        txsync_done_reg2    <= txsync_done_reg1;
        rxsync_done_reg2    <= rxsync_done_reg1;
        end
end
assign pll_lock = (rate_in_reg2 == 2'd2) || (PCIE_PLL_SEL == "QPLL") ? qplllock_reg2 : cplllock_reg2;
assign rate = (rate_in_reg2 == 2'd1) && (PCIE_PLL_SEL == "QPLL") ? 3'd2 :
              (rate_in_reg2 == 2'd1) && (PCIE_PLL_SEL == "CPLL") ? 3'd1 : 3'd0;
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
        fsm        <= FSM_PLL_LOCK;
        gen3_exit  <= 1'd0;
        cpllpd     <= 1'd0;
        qpllpd     <= 1'd0;
        cpllreset  <= 1'd0;
        qpllreset  <= 1'd0;
        txpmareset <= 1'd0;
        rxpmareset <= 1'd0;
        sysclksel  <= (PCIE_PLL_SEL == "QPLL") ? 2'd1 : 2'd0;
        pclk_sel   <= 1'd0;
        gen3       <= 1'd0;
        rate_out   <= 3'd0;
        end
    else
        begin
        case (fsm)
        FSM_IDLE :
            begin
            if (rate_in_reg2 != rate_in_reg1)
                begin
                fsm        <= ((rate_in_reg2 == 2'd2) || (rate_in_reg1 == 2'd2)) ? FSM_PLL_PU : FSM_TXDATA_WAIT;
                gen3_exit  <= (rate_in_reg2 == 2'd2);
                cpllpd     <= cpllpd;
                qpllpd     <= qpllpd;
                cpllreset  <= cpllreset;
                qpllreset  <= qpllreset;
                txpmareset <= txpmareset;
                rxpmareset <= rxpmareset;
                sysclksel  <= sysclksel;
                pclk_sel   <= pclk_sel;
                gen3       <= gen3;
                rate_out   <= rate_out;
                end
            else
                begin
                fsm        <= FSM_IDLE;
                gen3_exit  <= gen3_exit;
                cpllpd     <= cpllpd;
                qpllpd     <= qpllpd;
                cpllreset  <= cpllreset;
                qpllreset  <= qpllreset;
                txpmareset <= txpmareset;
                rxpmareset <= rxpmareset;
                sysclksel  <= sysclksel;
                pclk_sel   <= pclk_sel;
                gen3       <= gen3;
                rate_out   <= rate_out;
                end
            end
        FSM_PLL_PU :
            begin
            fsm        <= FSM_PLL_PURESET;
            gen3_exit  <= gen3_exit;
            cpllpd     <= (PCIE_PLL_SEL == "QPLL");
            qpllpd     <= 1'd0;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PLL_PURESET :
            begin
            fsm        <= FSM_PLL_LOCK;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= (PCIE_PLL_SEL == "QPLL");
            qpllreset  <= 1'd0;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PLL_LOCK :
            begin
            fsm        <= (pll_lock ? FSM_PMARESET_HOLD : FSM_PLL_LOCK);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PMARESET_HOLD :
            begin
            fsm        <= FSM_PLL_SEL;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= ((rate_in_reg2 == 2'd2) || gen3_exit);
            rxpmareset <= ((rate_in_reg2 == 2'd2) || gen3_exit);
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PLL_SEL :
            begin
            fsm        <= FSM_MMCM_LOCK;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= ((rate_in_reg2 == 2'd2) || (PCIE_PLL_SEL == "QPLL")) ? 2'd1 : 2'd0;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_MMCM_LOCK :
            begin
            fsm        <= (mmcm_lock_reg2 ? FSM_DRP_START : FSM_MMCM_LOCK);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_DRP_START:
            begin
            fsm        <= (!drp_done_reg2 ? FSM_DRP_DONE : FSM_DRP_START);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= ((rate_in_reg2 == 2'd1) || (rate_in_reg2 == 2'd2));
            gen3       <= (rate_in_reg2 == 2'd2);
            rate_out   <= (((rate_in_reg2 == 2'd2) || gen3_exit) ? rate : rate_out);
            end
        FSM_DRP_DONE :
            begin
            fsm        <= (drp_done_reg2 ? (rst_idle_reg2 ? FSM_PMARESET_RELEASE : FSM_IDLE): FSM_DRP_DONE);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PMARESET_RELEASE :
            begin
            fsm        <= FSM_PMARESET_DONE;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= 1'd0;
            rxpmareset <= 1'd0;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PMARESET_DONE :
            begin
            fsm        <= (((rxresetdone_reg2 && txresetdone_reg2 && !phystatus_reg2)) ? FSM_TXDATA_WAIT : FSM_PMARESET_DONE);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_TXDATA_WAIT :
            begin
            fsm        <= (txdata_wait_cnt == TXDATA_WAIT_MAX) ? FSM_PCLK_SEL : FSM_TXDATA_WAIT;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PCLK_SEL :
            begin
            fsm        <= FSM_RATE_SEL;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= ((rate_in_reg2 == 2'd1) || (rate_in_reg2 == 2'd2));
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_RATE_SEL :
            begin
            fsm        <= FSM_RATE_DONE;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate;                             
            end
        FSM_RATE_DONE :
            begin
            if (ratedone || (rate_in_reg2 == 2'd2) || (gen3_exit))
                if ((PCIE_USE_MODE == "1.0") && (rate_in_reg2 != 2'd2) && (!gen3_exit))
                    fsm <= FSM_RESETOVRD_START;
                else
                    fsm <= FSM_PLL_PDRESET;
            else
                fsm <= FSM_RATE_DONE;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_RESETOVRD_START:
            begin
            fsm        <= (!resetovrd_done_reg2 ? FSM_RESETOVRD_DONE : FSM_RESETOVRD_START);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_RESETOVRD_DONE :
            begin
            fsm        <= (resetovrd_done_reg2 ? FSM_PLL_PDRESET : FSM_RESETOVRD_DONE);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PLL_PDRESET :
            begin
            fsm        <= FSM_PLL_PD;
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= (PCIE_PLL_SEL == "QPLL") ? 1'd1 : (rate_in_reg2 == 2'd2);
            qpllreset  <= (PCIE_PLL_SEL == "QPLL") ? 1'd0 : (rate_in_reg2 != 2'd2);
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_PLL_PD :
            begin
            fsm        <= (((rate_in_reg2 == 2'd2) || (PCIE_TXBUF_EN == "FALSE")) ? FSM_TXSYNC_START : FSM_DONE);
            gen3_exit  <= gen3_exit;
            cpllpd     <= (PCIE_PLL_SEL == "QPLL") ? 1'd1 : (rate_in_reg2 == 2'd2);
            qpllpd     <= (PCIE_PLL_SEL == "QPLL") ? 1'd0 : (rate_in_reg2 != 2'd2);
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_TXSYNC_START:
            begin
            fsm        <= (!txsync_done_reg2 ? FSM_TXSYNC_DONE : FSM_TXSYNC_START);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_TXSYNC_DONE:
            begin
            fsm        <= (txsync_done_reg2 ? FSM_DONE : FSM_TXSYNC_DONE);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_DONE :
            begin
            fsm        <= (((rate_in_reg2 == 2'd2) && (PCIE_RXBUF_EN == "FALSE") && (PCIE_ASYNC_EN == "TRUE")) ? FSM_RXSYNC_START : FSM_IDLE);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_RXSYNC_START:
            begin
            fsm        <= (!rxsync_done_reg2 ? FSM_RXSYNC_DONE : FSM_RXSYNC_START);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        FSM_RXSYNC_DONE:
            begin
            fsm        <= (rxsync_done_reg2 ? FSM_IDLE : FSM_RXSYNC_DONE);
            gen3_exit  <= gen3_exit;
            cpllpd     <= cpllpd;
            qpllpd     <= qpllpd;
            cpllreset  <= cpllreset;
            qpllreset  <= qpllreset;
            txpmareset <= txpmareset;
            rxpmareset <= rxpmareset;
            sysclksel  <= sysclksel;
            pclk_sel   <= pclk_sel;
            gen3       <= gen3;
            rate_out   <= rate_out;
            end
        default :
            begin
            fsm        <= FSM_IDLE;
            gen3_exit  <= 1'd0;
            cpllpd     <= 1'd0;
            qpllpd     <= 1'd0;
            cpllreset  <= 1'd0;
            qpllreset  <= 1'd0;
            txpmareset <= 1'd0;
            rxpmareset <= 1'd0;
            sysclksel  <= (PCIE_PLL_SEL == "QPLL") ? 2'd1 : 2'd0;
            pclk_sel   <= 1'd0;
            gen3       <= 1'd0;
            rate_out   <= 3'd0;
            end
        endcase
        end
end
assign RATE_CPLLPD          = ((PCIE_POWER_SAVING == "FALSE") ? 1'd0 : cpllpd);
assign RATE_QPLLPD          = ((PCIE_POWER_SAVING == "FALSE") ? 1'd0 : qpllpd);
assign RATE_CPLLRESET       = ((PCIE_POWER_SAVING == "FALSE") ? 1'd0 : cpllreset);
assign RATE_QPLLRESET       = ((PCIE_POWER_SAVING == "FALSE") ? 1'd0 : qpllreset);
assign RATE_TXPMARESET      = txpmareset;
assign RATE_RXPMARESET      = rxpmareset;
assign RATE_SYSCLKSEL       = sysclksel;
assign RATE_DRP_START       = (fsm == FSM_DRP_START);
assign RATE_PCLK_SEL        = pclk_sel;
assign RATE_GEN3            = gen3;
assign RATE_RATE_OUT        = rate_out;
assign RATE_RESETOVRD_START = (fsm == FSM_RESETOVRD_START);
assign RATE_TXSYNC_START    = (fsm == FSM_TXSYNC_START);
assign RATE_DONE            = (fsm == FSM_DONE);
assign RATE_RXSYNC_START    = (fsm == FSM_RXSYNC_START);
assign RATE_RXSYNC          = ((fsm == FSM_RXSYNC_START) || (fsm == FSM_RXSYNC_DONE));
assign RATE_IDLE            = (fsm == FSM_IDLE);
assign RATE_FSM             = fsm;
endmodule
