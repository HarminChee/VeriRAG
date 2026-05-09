`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PCIEBus_qpll_reset #
(
    parameter PCIE_PLL_SEL       = "CPLL",                  
    parameter PCIE_POWER_SAVING  = "TRUE",                  
    parameter PCIE_LANE          = 1,                       
    parameter BYPASS_COARSE_OVRD = 1                        
)
(
    input                           QRST_CLK,
    input                           QRST_RST_N,
    input                           QRST_MMCM_LOCK,
    input       [PCIE_LANE-1:0]     QRST_CPLLLOCK,
    input       [(PCIE_LANE-1)>>2:0]QRST_DRP_DONE,
    input       [(PCIE_LANE-1)>>2:0]QRST_QPLLLOCK,
    input       [ 1:0]              QRST_RATE,
    input       [PCIE_LANE-1:0]     QRST_QPLLRESET_IN,
    input       [PCIE_LANE-1:0]     QRST_QPLLPD_IN,
    output                          QRST_OVRD,
    output                          QRST_DRP_START,
    output                          QRST_QPLLRESET_OUT,
    output                          QRST_QPLLPD_OUT,
    output                          QRST_IDLE,
    output      [ 3:0]              QRST_FSM
);
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             mmcm_lock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     cplllock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [(PCIE_LANE-1)>>2:0]drp_done_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [(PCIE_LANE-1)>>2:0]qplllock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]              rate_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     qpllreset_in_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     qpllpd_in_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             mmcm_lock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     cplllock_reg2;  
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [(PCIE_LANE-1)>>2:0]drp_done_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [(PCIE_LANE-1)>>2:0]qplllock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]              rate_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     qpllreset_in_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0]     qpllpd_in_reg2;
    reg                             ovrd              =  1'd0;
    reg                             qpllreset         =  1'd1;
    reg                             qpllpd            =  1'd0;
    reg         [ 3:0]              fsm               =  2;                 
    localparam                      FSM_IDLE          = 1; 
    localparam                      FSM_WAIT_LOCK     = 2;
    localparam                      FSM_MMCM_LOCK     = 3;   
    localparam                      FSM_DRP_START_NOM = 4;
    localparam                      FSM_DRP_DONE_NOM  = 5;
    localparam                      FSM_QPLLLOCK      = 6;
    localparam                      FSM_DRP_START_OPT = 7;                            
    localparam                      FSM_DRP_DONE_OPT  = 8;
    localparam                      FSM_QPLL_RESET    = 9;                                                         
    localparam                      FSM_QPLLLOCK2     = 10;
    localparam                      FSM_QPLL_PDRESET  = 11;
    localparam                      FSM_QPLL_PD       = 12;                                         
always @ (posedge QRST_CLK)
begin
    if (!QRST_RST_N)
        begin    
        mmcm_lock_reg1    <=  1'd0;
        cplllock_reg1     <= {PCIE_LANE{1'd1}}; 
        drp_done_reg1     <= {(((PCIE_LANE-1)>>2)+1){1'd0}};     
        qplllock_reg1     <= {(((PCIE_LANE-1)>>2)+1){1'd0}}; 
        rate_reg1         <=  2'd0; 
        qpllreset_in_reg1 <= {PCIE_LANE{1'd1}}; 
        qpllpd_in_reg1    <= {PCIE_LANE{1'd0}}; 
        mmcm_lock_reg2    <=  1'd0;
        cplllock_reg2     <= {PCIE_LANE{1'd1}};
        drp_done_reg2     <= {(((PCIE_LANE-1)>>2)+1){1'd0}}; 
        qplllock_reg2     <= {(((PCIE_LANE-1)>>2)+1){1'd0}}; 
        rate_reg2         <=  2'd0;
        qpllreset_in_reg2 <= {PCIE_LANE{1'd1}}; 
        qpllpd_in_reg2    <= {PCIE_LANE{1'd0}};  
        end
    else
        begin  
        mmcm_lock_reg1    <= QRST_MMCM_LOCK;   
        cplllock_reg1     <= QRST_CPLLLOCK; 
        drp_done_reg1     <= QRST_DRP_DONE; 
        qplllock_reg1     <= QRST_QPLLLOCK;
        rate_reg1         <= QRST_RATE; 
        qpllreset_in_reg1 <= QRST_QPLLRESET_IN;
        qpllpd_in_reg1    <= QRST_QPLLPD_IN;
        mmcm_lock_reg2    <= mmcm_lock_reg1;
        cplllock_reg2     <= cplllock_reg1;
        drp_done_reg2     <= drp_done_reg1; 
        qplllock_reg2     <= qplllock_reg1;
        rate_reg2         <= rate_reg1;
        qpllreset_in_reg2 <= qpllreset_in_reg1;
        qpllpd_in_reg2    <= qpllpd_in_reg1;
        end
end    
always @ (posedge QRST_CLK)
begin
    if (!QRST_RST_N)
        begin
        fsm       <= FSM_WAIT_LOCK;
        ovrd      <= 1'd0;
        qpllreset <= 1'd1;
        qpllpd    <= 1'd0;
        end
    else
        begin
        case (fsm)
        FSM_IDLE :
            begin
            if (!QRST_RST_N)
                begin
                fsm       <= FSM_WAIT_LOCK;
                ovrd      <= 1'd0;
                qpllreset <= 1'd1;
                qpllpd    <= 1'd0;
                end
            else
                begin
                fsm       <= FSM_IDLE;
                ovrd      <= ovrd;
                qpllreset <= &qpllreset_in_reg2;
                qpllpd    <= &qpllpd_in_reg2;
                end
            end  
        FSM_WAIT_LOCK :
            begin
            fsm       <= ((&(~cplllock_reg2)) && (&(~qplllock_reg2)) ? FSM_MMCM_LOCK : FSM_WAIT_LOCK);
            ovrd      <= ovrd;
            qpllreset <= qpllreset;
            qpllpd    <= qpllpd;
            end      
        FSM_MMCM_LOCK :
            begin
            fsm       <= ((mmcm_lock_reg2 && (&cplllock_reg2)) ? FSM_DRP_START_NOM : FSM_MMCM_LOCK);
            ovrd      <= ovrd;
            qpllreset <= qpllreset;
            qpllpd    <= qpllpd;
            end      
        FSM_DRP_START_NOM:
            begin
            fsm       <= (&(~drp_done_reg2) ? FSM_DRP_DONE_NOM : FSM_DRP_START_NOM);
            ovrd      <= ovrd;
            qpllreset <= qpllreset;
            qpllpd    <= qpllpd;
            end
        FSM_DRP_DONE_NOM :
            begin
            fsm       <= (&drp_done_reg2 ? FSM_QPLLLOCK : FSM_DRP_DONE_NOM);
            ovrd      <= ovrd;
            qpllreset <= qpllreset;
            qpllpd    <= qpllpd;
            end 
        FSM_QPLLLOCK :
            begin
            fsm       <= (&qplllock_reg2 ? ((BYPASS_COARSE_OVRD == 1) ? FSM_QPLL_PDRESET : FSM_DRP_START_OPT) : FSM_QPLLLOCK);
            ovrd      <= ovrd;
            qpllreset <= 1'd0;
            qpllpd    <= qpllpd;
            end
        FSM_DRP_START_OPT:
            begin
            fsm       <= (&(~drp_done_reg2) ? FSM_DRP_DONE_OPT : FSM_DRP_START_OPT);
            ovrd      <= 1'd1;
            qpllreset <= qpllreset;
            qpllpd    <= qpllpd;
            end
        FSM_DRP_DONE_OPT :
            begin
            if (&drp_done_reg2)
                begin
                fsm       <= ((PCIE_PLL_SEL == "QPLL") ? FSM_QPLL_RESET : FSM_QPLL_PDRESET);
                ovrd      <= ovrd;
                qpllreset <= (PCIE_PLL_SEL == "QPLL");
                qpllpd    <= qpllpd;
                end
            else
                begin
                fsm       <= FSM_DRP_DONE_OPT;
                ovrd      <= ovrd;
                qpllreset <= qpllreset;
                qpllpd    <= qpllpd;
                end
            end 
        FSM_QPLL_RESET :
            begin
            fsm       <= (&(~qplllock_reg2) ? FSM_QPLLLOCK2 : FSM_QPLL_RESET);  
            ovrd      <= ovrd;
            qpllreset <= 1'd1;
            qpllpd    <= 1'd0;
            end     
        FSM_QPLLLOCK2 :
            begin
            fsm       <= (&qplllock_reg2 ? FSM_IDLE : FSM_QPLLLOCK2);
            ovrd      <= ovrd;
            qpllreset <= 1'd0;
            qpllpd    <= 1'd0;
            end
        FSM_QPLL_PDRESET :
            begin
            fsm       <= FSM_QPLL_PD;
            ovrd      <= ovrd;
            qpllreset <= (PCIE_PLL_SEL == "CPLL") ? (rate_reg2 != 2'd2) : 1'd0; 
            qpllpd    <= qpllpd;
            end
        FSM_QPLL_PD :
            begin
            fsm       <= FSM_IDLE;
            ovrd      <= ovrd;
            qpllreset <= qpllreset;
            qpllpd    <= (PCIE_PLL_SEL == "CPLL") ? (rate_reg2 != 2'd2) : 1'd0; 
            end 
        default :
            begin
            fsm       <= FSM_WAIT_LOCK;
            ovrd      <= 1'd0;
            qpllreset <= 1'd0;
            qpllpd    <= 1'd0;
            end
        endcase
        end
end
assign QRST_OVRD          = ovrd;
assign QRST_DRP_START     = (fsm == FSM_DRP_START_NOM) || (fsm == FSM_DRP_START_OPT); 
assign QRST_QPLLRESET_OUT = qpllreset;
assign QRST_QPLLPD_OUT    = ((PCIE_POWER_SAVING == "FALSE") ? 1'd0 : qpllpd);  
assign QRST_IDLE          = (fsm == FSM_IDLE);
assign QRST_FSM           = fsm;                   
endmodule
