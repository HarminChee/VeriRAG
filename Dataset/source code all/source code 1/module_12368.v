`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie3_7x_0_pipe_sync #
(
    parameter PCIE_GT_DEVICE       = "GTX",                 
    parameter PCIE_TXBUF_EN        = "FALSE",               
    parameter PCIE_RXBUF_EN        = "TRUE",                
    parameter PCIE_TXSYNC_MODE     = 0,                     
    parameter PCIE_RXSYNC_MODE     = 0,                     
    parameter PCIE_LANE            = 1,                     
    parameter PCIE_LINK_SPEED      = 3,                     
    parameter BYPASS_TXDELAY_ALIGN = 0,                     
    parameter BYPASS_RXDELAY_ALIGN = 0                      
)
(
    input               SYNC_CLK,
    input               SYNC_RST_N,
    input               SYNC_SLAVE,
    input               SYNC_GEN3,
    input               SYNC_RATE_IDLE,
    input               SYNC_MMCM_LOCK,
    input               SYNC_RXELECIDLE,
    input               SYNC_RXCDRLOCK,
    input               SYNC_ACTIVE_LANE,
    input               SYNC_TXSYNC_START,
    input               SYNC_TXPHINITDONE,   
    input               SYNC_TXDLYSRESETDONE,
    input               SYNC_TXPHALIGNDONE,
    input               SYNC_TXSYNCDONE,
    input               SYNC_RXSYNC_START,
    input               SYNC_RXDLYSRESETDONE,
    input               SYNC_RXPHALIGNDONE_M,
    input               SYNC_RXPHALIGNDONE_S,
    input               SYNC_RXSYNC_DONEM_IN,
    input               SYNC_RXSYNCDONE,
    output              SYNC_TXPHDLYRESET,
    output              SYNC_TXPHALIGN,     
    output              SYNC_TXPHALIGNEN,  
    output              SYNC_TXPHINIT,       
    output              SYNC_TXDLYBYPASS,  
    output              SYNC_TXDLYSRESET,
    output              SYNC_TXDLYEN,   
    output              SYNC_TXSYNC_DONE,
    output    [ 5:0]    SYNC_FSM_TX,
    output              SYNC_RXPHALIGN,
    output              SYNC_RXPHALIGNEN,
    output              SYNC_RXDLYBYPASS,
    output              SYNC_RXDLYSRESET,
    output              SYNC_RXDLYEN,
    output              SYNC_RXDDIEN,
    output              SYNC_RXSYNC_DONEM_OUT,
    output              SYNC_RXSYNC_DONE,
    output    [ 6:0]    SYNC_FSM_RX
);          
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 gen3_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_idle_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg		      mmcm_lock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxelecidle_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxcdrlock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 gen3_reg2;     
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_idle_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg		      mmcm_lock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxelecidle_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxcdrlock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg		      txsync_start_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txphinitdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txdlysresetdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txphaligndone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txsyncdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txsync_start_reg2;     
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txphinitdone_reg2;     
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txdlysresetdone_reg2;    
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txphaligndone_reg2;   
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txsyncdone_reg2; 
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txsync_start_reg3;     
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txphinitdone_reg3;     
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txdlysresetdone_reg3;    
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txphaligndone_reg3;   
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txsyncdone_reg3;     
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg		      rxsync_start_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxdlysresetdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxphaligndone_m_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxphaligndone_s_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxsync_donem_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxsyncdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg		      rxsync_start_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxdlysresetdone_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxphaligndone_m_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxphaligndone_s_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxsync_donem_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxsyncdone_reg2;
    reg                 txdlyen     = 1'd0;
    reg                 txsync_done = 1'd0;
    reg         [ 5:0]  fsm_tx      = 6'd0;     
    reg                 rxdlyen     = 1'd0;
    reg                 rxsync_done = 1'd0;         
    reg	        [ 6:0]  fsm_rx      = 7'd0;   
    localparam          FSM_TXSYNC_IDLE  = 6'b000001; 
    localparam          FSM_MMCM_LOCK    = 6'b000010;                                     
    localparam          FSM_TXSYNC_START = 6'b000100;
    localparam          FSM_TXPHINITDONE = 6'b001000;       
    localparam          FSM_TXSYNC_DONE1 = 6'b010000;   
    localparam          FSM_TXSYNC_DONE2 = 6'b100000;             
    localparam          FSM_RXSYNC_IDLE  = 7'b0000001; 
    localparam          FSM_RXCDRLOCK    = 7'b0000010;                                     
    localparam          FSM_RXSYNC_START = 7'b0000100;
    localparam          FSM_RXSYNC_DONE1 = 7'b0001000;                                     
    localparam          FSM_RXSYNC_DONE2 = 7'b0010000;
    localparam          FSM_RXSYNC_DONES = 7'b0100000;
    localparam          FSM_RXSYNC_DONEM = 7'b1000000;
always @ (posedge SYNC_CLK)
begin
    if (!SYNC_RST_N)
        begin    
        gen3_reg1            <= 1'd0;
        rate_idle_reg1       <= 1'd0;
        mmcm_lock_reg1       <= 1'd0;
        rxelecidle_reg1      <= 1'd0;
        rxcdrlock_reg1 	     <= 1'd0;
        txsync_start_reg1	   <= 1'd0;
        txphinitdone_reg1    <= 1'd0;
        txdlysresetdone_reg1 <= 1'd0;
        txphaligndone_reg1   <= 1'd0;
        txsyncdone_reg1      <= 1'd0;
        rxsync_start_reg1	   <= 1'd0; 
        rxdlysresetdone_reg1 <= 1'd0;
        rxphaligndone_m_reg1 <= 1'd0;
        rxphaligndone_s_reg1 <= 1'd0;
        rxsync_donem_reg1    <= 1'd0;    
        rxsyncdone_reg1      <= 1'd0;
        gen3_reg2            <= 1'd0;
        rate_idle_reg2       <= 1'd0;
        mmcm_lock_reg2       <= 1'd0;
        rxelecidle_reg2      <= 1'd0;
        rxcdrlock_reg2 	     <= 1'd0;
        txsync_start_reg2	   <= 1'd0;
        txphinitdone_reg2    <= 1'd0;
        txdlysresetdone_reg2 <= 1'd0;
        txphaligndone_reg2   <= 1'd0;
        txsyncdone_reg2      <= 1'd0;
        rxsync_start_reg2	   <= 1'd0; 
        rxdlysresetdone_reg2 <= 1'd0;
        rxphaligndone_m_reg2 <= 1'd0;
        rxphaligndone_s_reg2 <= 1'd0;
        rxsync_donem_reg2    <= 1'd0;
        rxsyncdone_reg2      <= 1'd0;
        txsync_start_reg3	   <= 1'd0;
        txphinitdone_reg3    <= 1'd0;
        txdlysresetdone_reg3 <= 1'd0;
        txphaligndone_reg3   <= 1'd0;
        txsyncdone_reg3      <= 1'd0;
        end
    else
        begin  
        gen3_reg1            <= SYNC_GEN3;
        rate_idle_reg1       <= SYNC_RATE_IDLE;
        mmcm_lock_reg1       <= SYNC_MMCM_LOCK;
        rxelecidle_reg1      <= SYNC_RXELECIDLE; 
        rxcdrlock_reg1       <= SYNC_RXCDRLOCK;
        txsync_start_reg1    <= SYNC_TXSYNC_START;
        txphinitdone_reg1    <= SYNC_TXPHINITDONE;
        txdlysresetdone_reg1 <= SYNC_TXDLYSRESETDONE;
        txphaligndone_reg1   <= SYNC_TXPHALIGNDONE;
        txsyncdone_reg1      <= SYNC_TXSYNCDONE;
        rxsync_start_reg1	   <= SYNC_RXSYNC_START; 
        rxdlysresetdone_reg1 <= SYNC_RXDLYSRESETDONE;
        rxphaligndone_m_reg1 <= SYNC_RXPHALIGNDONE_M;
        rxphaligndone_s_reg1 <= SYNC_RXPHALIGNDONE_S;
        rxsync_donem_reg1    <= SYNC_RXSYNC_DONEM_IN;
        rxsyncdone_reg1      <= SYNC_RXSYNCDONE; 
        gen3_reg2            <= gen3_reg1;
        rate_idle_reg2       <= rate_idle_reg1;
        mmcm_lock_reg2       <= mmcm_lock_reg1;
        rxelecidle_reg2      <= rxelecidle_reg1;
        rxcdrlock_reg2       <= rxcdrlock_reg1;
        txsync_start_reg2    <= txsync_start_reg1;       
        txphinitdone_reg2    <= txphinitdone_reg1; 
        txdlysresetdone_reg2 <= txdlysresetdone_reg1;   
        txphaligndone_reg2   <= txphaligndone_reg1;
        txsyncdone_reg2      <= txsyncdone_reg1;
        rxsync_start_reg2    <= rxsync_start_reg1;
        rxdlysresetdone_reg2 <= rxdlysresetdone_reg1; 
        rxphaligndone_m_reg2 <= rxphaligndone_m_reg1;
        rxphaligndone_s_reg2 <= rxphaligndone_s_reg1;
        rxsync_donem_reg2    <= rxsync_donem_reg1; 
        rxsyncdone_reg2      <= rxsyncdone_reg1;
        txsync_start_reg3    <= txsync_start_reg2;	   
        txphinitdone_reg3    <= txphinitdone_reg2;    
        txdlysresetdone_reg3 <= txdlysresetdone_reg2; 
        txphaligndone_reg3   <= txphaligndone_reg2;   
        txsyncdone_reg3      <= txsyncdone_reg2;      
        end
end       
generate if ((PCIE_LINK_SPEED == 3) || (PCIE_TXBUF_EN == "FALSE")) 
    begin : txsync_fsm
    always @ (posedge SYNC_CLK)
    begin
        if (!SYNC_RST_N)
            begin
            fsm_tx      <= FSM_TXSYNC_IDLE;   
            txdlyen     <= 1'd0; 
            txsync_done <= 1'd0;
            end                    
        else
            begin
            case (fsm_tx)
            FSM_TXSYNC_IDLE :
                begin     
                if (txsync_start_reg2)
                    begin
                    fsm_tx      <= FSM_MMCM_LOCK;
                    txdlyen     <= 1'd0; 
                    txsync_done <= 1'd0;
                    end
                else
                    begin
                    fsm_tx      <= FSM_TXSYNC_IDLE;
                    txdlyen     <= txdlyen; 
                    txsync_done <= txsync_done;
                    end
                end
            FSM_MMCM_LOCK :
                begin
                fsm_tx      <= (mmcm_lock_reg2 ? FSM_TXSYNC_START : FSM_MMCM_LOCK);
                txdlyen     <= 1'd0; 
                txsync_done <= 1'd0;  
                end
            FSM_TXSYNC_START :
                begin
                fsm_tx      <= (((!txdlysresetdone_reg3 && txdlysresetdone_reg2) || (((PCIE_GT_DEVICE == "GTH") || (PCIE_GT_DEVICE == "GTP")) && (PCIE_TXSYNC_MODE == 1) && SYNC_SLAVE)) ? FSM_TXPHINITDONE : FSM_TXSYNC_START);
                txdlyen     <= 1'd0; 
                txsync_done <= 1'd0;
                end
            FSM_TXPHINITDONE :
                begin
                fsm_tx      <= (((!txphinitdone_reg3 && txphinitdone_reg2) || (PCIE_TXSYNC_MODE == 1) || (!SYNC_ACTIVE_LANE)) ? FSM_TXSYNC_DONE1 : FSM_TXPHINITDONE);
                txdlyen     <= 1'd0; 
                txsync_done <= 1'd0;
                end
            FSM_TXSYNC_DONE1 :
                begin
                if (((PCIE_GT_DEVICE == "GTH") || (PCIE_GT_DEVICE == "GTP")) && (PCIE_TXSYNC_MODE == 1) && !SYNC_SLAVE)
                   fsm_tx <= ((!txsyncdone_reg3 && txsyncdone_reg2)       || (!SYNC_ACTIVE_LANE) ? FSM_TXSYNC_DONE2 : FSM_TXSYNC_DONE1); 
                else
                   fsm_tx <= ((!txphaligndone_reg3 && txphaligndone_reg2) || (!SYNC_ACTIVE_LANE) ? FSM_TXSYNC_DONE2 : FSM_TXSYNC_DONE1); 
                txdlyen     <= 1'd0; 
                txsync_done <= 1'd0;
                end  
            FSM_TXSYNC_DONE2 :
                begin
                if ((!txphaligndone_reg3 && txphaligndone_reg2) || (!SYNC_ACTIVE_LANE) || SYNC_SLAVE || (((PCIE_GT_DEVICE == "GTH") || (PCIE_GT_DEVICE == "GTP")) && (PCIE_TXSYNC_MODE == 1)) || (BYPASS_TXDELAY_ALIGN == 1)) 
                    begin
                    fsm_tx      <= FSM_TXSYNC_IDLE;
                    txdlyen     <= !SYNC_SLAVE; 
                    txsync_done <= 1'd1;
                    end
                else
                    begin
                    fsm_tx      <= FSM_TXSYNC_DONE2;
                    txdlyen     <= !SYNC_SLAVE; 
                    txsync_done <= 1'd0;
                    end
                end         
            default :
                begin 
                fsm_tx      <= FSM_TXSYNC_IDLE;
                txdlyen     <= 1'd0; 
                txsync_done <= 1'd0;
                end
            endcase
            end
    end     
    end  
else 
    begin : txsync_fsm_disable
    always @ (posedge SYNC_CLK)
    begin    
        fsm_tx      <= FSM_TXSYNC_IDLE;
        txdlyen     <= 1'd0;
        txsync_done <= 1'd0; 
    end
    end 
endgenerate  
generate if ((PCIE_LINK_SPEED == 3) && (PCIE_RXBUF_EN == "FALSE")) 
    begin : rxsync_fsm
    always @ (posedge SYNC_CLK)
    begin
        if (!SYNC_RST_N)
            begin
            fsm_rx      <= FSM_RXSYNC_IDLE; 
            rxdlyen     <= 1'd0;
            rxsync_done <= 1'd0;   
            end                    
        else
            begin
            case (fsm_rx)
            FSM_RXSYNC_IDLE :
                begin
                if (rxsync_start_reg2)
                    begin
                    fsm_rx      <= FSM_RXCDRLOCK;
                    rxdlyen     <= 1'd0;
                    rxsync_done <= 1'd0;
                    end
                else if (gen3_reg2 && rate_idle_reg2 && ((rxelecidle_reg2 == 1'd1) && (rxelecidle_reg1 == 1'd0)))
                    begin
                    fsm_rx      <= FSM_RXCDRLOCK;
                    rxdlyen     <= 1'd0;
                    rxsync_done <= 1'd0;   
                    end 
                else                    
                    begin
                    fsm_rx      <= FSM_RXSYNC_IDLE;
                    rxdlyen     <= rxelecidle_reg2 ? 1'd0 : rxdlyen;
                    rxsync_done <= rxelecidle_reg2 ? 1'd0 : rxsync_done;
                    end
                end
            FSM_RXCDRLOCK :
                begin
                fsm_rx      <= ((!rxelecidle_reg2 && rxcdrlock_reg2) ? FSM_RXSYNC_START : FSM_RXCDRLOCK);
                rxdlyen     <= 1'd0;
                rxsync_done <= 1'd0;
                end
            FSM_RXSYNC_START :
                begin
                fsm_rx      <= ((!rxdlysresetdone_reg2 && rxdlysresetdone_reg1) ? FSM_RXSYNC_DONE1 : FSM_RXSYNC_START);
                rxdlyen     <= 1'd0;
                rxsync_done <= 1'd0;
                end     
            FSM_RXSYNC_DONE1 :
                begin
                if (SYNC_SLAVE)
                    begin
                    fsm_rx      <= ((!rxphaligndone_s_reg2 && rxphaligndone_s_reg1) ? FSM_RXSYNC_DONE2 : FSM_RXSYNC_DONE1);
                    rxdlyen     <= 1'd0;
                    rxsync_done <= 1'd0;
                    end
                else
                    begin
                    fsm_rx      <= ((!rxphaligndone_m_reg2 && rxphaligndone_m_reg1) ? FSM_RXSYNC_DONE2 : FSM_RXSYNC_DONE1);
                    rxdlyen     <= 1'd0;
                    rxsync_done <= 1'd0;
                    end
                end  
            FSM_RXSYNC_DONE2 :
                begin   
                if (SYNC_SLAVE)
                    begin
                    fsm_rx      <= FSM_RXSYNC_IDLE;
                    rxdlyen     <= 1'd0;
                    rxsync_done <= 1'd1;
                    end
                else if ((!rxphaligndone_m_reg2 && rxphaligndone_m_reg1) || (BYPASS_RXDELAY_ALIGN == 1)) 
                    begin
                    fsm_rx      <= ((PCIE_LANE == 1) ? FSM_RXSYNC_IDLE : FSM_RXSYNC_DONES);
                    rxdlyen     <=  (PCIE_LANE == 1);
                    rxsync_done <=  (PCIE_LANE == 1);
                    end
                else
                    begin
                    fsm_rx      <= FSM_RXSYNC_DONE2;
                    rxdlyen     <= 1'd1;
                    rxsync_done <= 1'd0;
                    end
                end     
            FSM_RXSYNC_DONES :
                begin
                if (!rxphaligndone_s_reg2 && rxphaligndone_s_reg1) 
                    begin
                    fsm_rx      <= FSM_RXSYNC_DONEM;
                    rxdlyen     <= 1'd1;
                    rxsync_done <= 1'd0;
                    end
                else
                    begin
                    fsm_rx      <= FSM_RXSYNC_DONES;
                    rxdlyen     <= 1'd0;
                    rxsync_done <= 1'd0;
                    end
                end           
            FSM_RXSYNC_DONEM :
                begin
                if ((!rxphaligndone_m_reg2 && rxphaligndone_m_reg1) || (BYPASS_RXDELAY_ALIGN == 1)) 
                    begin
                    fsm_rx      <= FSM_RXSYNC_IDLE;
                    rxdlyen     <= 1'd1;
                    rxsync_done <= 1'd1;
                    end
                else
                    begin
                    fsm_rx      <= FSM_RXSYNC_DONEM;
                    rxdlyen     <= 1'd1;
                    rxsync_done <= 1'd0;
                    end
                end         
            default : 
                begin
                fsm_rx      <= FSM_RXSYNC_IDLE;
                rxdlyen     <= 1'd0;
                rxsync_done <= 1'd0;
                end    
        	   endcase
            end
    end            
    end  
else 
    begin : rxsync_fsm_disable
    always @ (posedge SYNC_CLK)
    begin    
        fsm_rx      <= FSM_RXSYNC_IDLE;
        rxdlyen     <= 1'd0;
        rxsync_done <= 1'd0; 
    end
    end 
endgenerate      
assign SYNC_TXPHALIGNEN      = ((PCIE_TXSYNC_MODE == 1) || (!gen3_reg2 && (PCIE_TXBUF_EN == "TRUE"))) ? 1'd0 : 1'd1;   
assign SYNC_TXDLYBYPASS      = 1'd0;                     
assign SYNC_TXDLYSRESET      = (fsm_tx == FSM_TXSYNC_START);
assign SYNC_TXPHDLYRESET     =  (((PCIE_GT_DEVICE == "GTH") || (PCIE_GT_DEVICE == "GTP")) && (PCIE_TXSYNC_MODE == 1) && SYNC_SLAVE) ? (fsm_tx == FSM_TXSYNC_START) : 1'd0;   
assign SYNC_TXPHINIT         = PCIE_TXSYNC_MODE ? 1'd0 : (fsm_tx == FSM_TXPHINITDONE); 
assign SYNC_TXPHALIGN        = PCIE_TXSYNC_MODE ? 1'd0 : (fsm_tx == FSM_TXSYNC_DONE1);
assign SYNC_TXDLYEN          = PCIE_TXSYNC_MODE ? 1'd0 : txdlyen;
assign SYNC_TXSYNC_DONE      = txsync_done;
assign SYNC_FSM_TX           = fsm_tx;
assign SYNC_RXPHALIGNEN      = ((PCIE_RXSYNC_MODE == 1) || (!gen3_reg2) || (PCIE_RXBUF_EN == "TRUE")) ? 1'd0 : 1'd1;  
assign SYNC_RXDLYBYPASS      = !gen3_reg2 || (PCIE_RXBUF_EN == "TRUE");
assign SYNC_RXDLYSRESET      = (fsm_rx == FSM_RXSYNC_START);
assign SYNC_RXPHALIGN        = PCIE_RXSYNC_MODE ? 1'd0 : (!SYNC_SLAVE ? (fsm_rx == FSM_RXSYNC_DONE1) : (rxsync_donem_reg2 && (fsm_rx == FSM_RXSYNC_DONE1)));
assign SYNC_RXDLYEN          = PCIE_RXSYNC_MODE ? 1'd0 : rxdlyen;
assign SYNC_RXDDIEN          = gen3_reg2 && (PCIE_RXBUF_EN == "FALSE"); 
assign SYNC_RXSYNC_DONE      = rxsync_done;
assign SYNC_RXSYNC_DONEM_OUT = (fsm_rx == FSM_RXSYNC_DONES);
assign SYNC_FSM_RX	         = fsm_rx;  
endmodule
