`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_11_0_pipe_user #
(
    parameter PCIE_SIM_MODE    = "FALSE",                   
    parameter PCIE_USE_MODE    = "3.0",                     
    parameter PCIE_OOBCLK_MODE = 1,                         
    parameter RXCDRLOCK_MAX    = 4'd15,                     
    parameter RXVALID_MAX      = 4'd15,                     
    parameter CONVERGE_MAX     = 22'd3125000                
)
(
    input               USER_TXUSRCLK,
    input               USER_RXUSRCLK,
    input               USER_OOBCLK_IN,
    input               USER_RST_N,
    input               USER_RXUSRCLK_RST_N,
    input               USER_PCLK_SEL,
    input               USER_RESETOVRD_START,
    input               USER_TXRESETDONE,
    input               USER_RXRESETDONE,
    input               USER_TXELECIDLE,
    input               USER_TXCOMPLIANCE,
    input               USER_RXCDRLOCK_IN,
    input               USER_RXVALID_IN,
    input               USER_RXSTATUS_IN,
    input               USER_PHYSTATUS_IN,
    input               USER_RATE_DONE, 
    input               USER_RST_IDLE,
    input               USER_RATE_RXSYNC,
    input               USER_RATE_IDLE,
    input               USER_RATE_GEN3,
    input               USER_RXEQ_ADAPT_DONE,
    output              USER_OOBCLK,
    output              USER_RESETOVRD,
    output              USER_TXPMARESET,                            
    output              USER_RXPMARESET,                           
    output              USER_RXCDRRESET,               
    output              USER_RXCDRFREQRESET,           
    output              USER_RXDFELPMRESET,            
    output              USER_EYESCANRESET,             
    output              USER_TXPCSRESET,                              
    output              USER_RXPCSRESET,                            
    output              USER_RXBUFRESET,   
    output              USER_RESETOVRD_DONE,            
    output              USER_RESETDONE,
    output              USER_ACTIVE_LANE,
    output              USER_RXCDRLOCK_OUT,
    output              USER_RXVALID_OUT,
    output              USER_PHYSTATUS_OUT,
    output              USER_PHYSTATUS_RST,
    output              USER_GEN3_RDY,
    output              USER_RX_CONVERGE 
);
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 pclk_sel_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 resetovrd_start_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txresetdone_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxresetdone_reg1; 
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txelecidle_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txcompliance_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxcdrlock_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxvalid_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxstatus_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_done_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rst_idle_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_rxsync_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_idle_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_gen3_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxeq_adapt_done_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 pclk_sel_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 resetovrd_start_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txresetdone_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxresetdone_reg2; 
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txelecidle_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 txcompliance_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)	  reg	                rxcdrlock_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxvalid_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxstatus_reg2; 
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_done_reg2;   
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rst_idle_reg2; 
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_rxsync_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_idle_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rate_gen3_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxeq_adapt_done_reg2;
    reg         [ 1:0]  oobclk_cnt    =  2'd0;
    reg         [ 7:0]  reset_cnt     =  8'd127;
    reg         [ 3:0]  rxcdrlock_cnt =  4'd0;
    reg         [ 3:0]  rxvalid_cnt   =  4'd0;
    reg         [21:0]  converge_cnt  = 22'd0;
    reg                 converge_gen3 =  1'd0;
    reg                 oobclk   = 1'd0;
    reg         [ 7:0]  reset    = 8'h00;
    reg                 gen3_rdy = 1'd0;
    reg         [ 1:0]  fsm      = 2'd0;
    localparam          FSM_IDLE       = 2'd0; 
    localparam          FSM_RESETOVRD  = 2'd1;
    localparam          FSM_RESET_INIT = 2'd2;
    localparam          FSM_RESET      = 2'd3;    
    localparam converge_max_cnt = (PCIE_SIM_MODE == "TRUE") ? 22'd100 : CONVERGE_MAX;                                                              
always @ (posedge USER_TXUSRCLK)
begin
    if (!USER_RST_N)
        begin    
        pclk_sel_reg1        <= 1'd0; 
        resetovrd_start_reg1 <= 1'd0;
        txresetdone_reg1     <= 1'd0;
        rxresetdone_reg1     <= 1'd0; 
        txelecidle_reg1      <= 1'd0;
        txcompliance_reg1    <= 1'd0;
        rxcdrlock_reg1 	     <= 1'd0;
        rxeq_adapt_done_reg1 <= 1'd0;
        pclk_sel_reg2        <= 1'd0;
        resetovrd_start_reg2 <= 1'd0;
        txresetdone_reg2     <= 1'd0;
        rxresetdone_reg2     <= 1'd0; 
        txelecidle_reg2      <= 1'd0;
        txcompliance_reg2    <= 1'd0;
        rxcdrlock_reg2 	     <= 1'd0;
        rxeq_adapt_done_reg2 <= 1'd0;
        end
    else
        begin  
        pclk_sel_reg1        <= USER_PCLK_SEL;
        resetovrd_start_reg1 <= USER_RESETOVRD_START;
        txresetdone_reg1     <= USER_TXRESETDONE;
        rxresetdone_reg1     <= USER_RXRESETDONE;
        txelecidle_reg1      <= USER_TXELECIDLE;
        txcompliance_reg1    <= USER_TXCOMPLIANCE;
        rxcdrlock_reg1 	     <= USER_RXCDRLOCK_IN;
        rxeq_adapt_done_reg1 <= USER_RXEQ_ADAPT_DONE;
        pclk_sel_reg2        <= pclk_sel_reg1;
        resetovrd_start_reg2 <= resetovrd_start_reg1;
        txresetdone_reg2     <= txresetdone_reg1;      
        rxresetdone_reg2     <= rxresetdone_reg1;      
        txelecidle_reg2      <= txelecidle_reg1;       
        txcompliance_reg2    <= txcompliance_reg1;  
        rxcdrlock_reg2 	     <= rxcdrlock_reg1;  
        rxeq_adapt_done_reg2 <= rxeq_adapt_done_reg1;
        end
end 
always @ (posedge USER_RXUSRCLK)
begin
    if (!USER_RXUSRCLK_RST_N)
        begin    
        rxvalid_reg1     <= 1'd0;
        rxstatus_reg1    <= 1'd0;
        rst_idle_reg1    <= 1'd0; 
        rate_done_reg1   <= 1'd0;
        rate_rxsync_reg1 <= 1'd0;
        rate_idle_reg1   <= 1'd0;
        rate_gen3_reg1   <= 1'd0;
        rxvalid_reg2     <= 1'd0;
        rxstatus_reg2    <= 1'd0;
        rst_idle_reg2    <= 1'd0; 
        rate_done_reg2   <= 1'd0;
        rate_rxsync_reg2 <= 1'd0;
        rate_idle_reg2   <= 1'd0;
        rate_gen3_reg2   <= 1'd0;
        end
    else
        begin  
        rxvalid_reg1     <= USER_RXVALID_IN;
        rxstatus_reg1    <= USER_RXSTATUS_IN;
        rst_idle_reg1    <= USER_RST_IDLE; 
        rate_done_reg1   <= USER_RATE_DONE;
        rate_rxsync_reg1 <= USER_RATE_RXSYNC;
        rate_idle_reg1   <= USER_RATE_IDLE;
        rate_gen3_reg1   <= USER_RATE_GEN3;
        rxvalid_reg2     <= rxvalid_reg1;            
        rxstatus_reg2    <= rxstatus_reg1; 
        rst_idle_reg2    <= rst_idle_reg1;
        rate_done_reg2   <= rate_done_reg1;  
        rate_rxsync_reg2 <= rate_rxsync_reg1;
        rate_idle_reg2   <= rate_idle_reg1;
        rate_gen3_reg2   <= rate_gen3_reg1;      
        end
end 
generate if (PCIE_USE_MODE == "1.0") 
    begin : resetovrd
    always @ (posedge USER_TXUSRCLK)
    begin
        if (!USER_RST_N)
            reset_cnt <= 8'd127;
        else
            if (((fsm == FSM_RESETOVRD) || (fsm == FSM_RESET)) && (reset_cnt != 8'd0))
                reset_cnt <= reset_cnt - 8'd1;
            else 
                case (reset) 
                8'b00000000 : reset_cnt <= 8'd127;              
                8'b11111111 : reset_cnt <= 8'd127;              
                8'b11111110 : reset_cnt <= 8'd127;              
                8'b11111100 : reset_cnt <= 8'd127;              
                8'b11111000 : reset_cnt <= 8'd127;              
                8'b11110000 : reset_cnt <= 8'd127;              
                8'b11100000 : reset_cnt <= 8'd127;              
                8'b11000000 : reset_cnt <= 8'd127;              
                8'b10000000 : reset_cnt <= 8'd127;
                default     : reset_cnt <= 8'd127; 
                endcase
    end 
    always @ (posedge USER_TXUSRCLK)
    begin
        if (!USER_RST_N)
            reset <= 8'h00;
        else
            if (fsm == FSM_RESET_INIT)
                reset <= 8'hFF;   
            else if ((fsm == FSM_RESET) && (reset_cnt == 8'd0))
                reset <= {reset[6:0], 1'd0};        
            else
                reset <= reset;
    end
    always @ (posedge USER_TXUSRCLK)
    begin
        if (!USER_RST_N)
            fsm <= FSM_IDLE;     
        else
            begin
            case (fsm)
            FSM_IDLE       : fsm <= resetovrd_start_reg2 ? FSM_RESETOVRD : FSM_IDLE;
            FSM_RESETOVRD  : fsm <= (reset_cnt == 8'd0) ? FSM_RESET_INIT : FSM_RESETOVRD;
            FSM_RESET_INIT : fsm <= FSM_RESET;
            FSM_RESET      : fsm <= ((reset == 8'd0) && rxresetdone_reg2) ? FSM_IDLE : FSM_RESET;  
            default        : fsm <= FSM_IDLE;
        	  endcase
            end
    end
    end 
else 
    begin : resetovrd_disble
    always @ (posedge USER_TXUSRCLK)
    begin    
       if (!USER_RST_N)
           begin   
           reset_cnt <= 8'hFF;
           reset     <= 8'd0;
           fsm       <= 2'd0; 
           end
       else
           begin   
           reset_cnt <= 8'hFF;
           reset     <= 8'd0;
           fsm       <= 2'd0; 
           end
    end
    end
endgenerate
generate if (PCIE_OOBCLK_MODE == 1) 
    begin : oobclk_div
    always @ (posedge USER_OOBCLK_IN)
    begin
        if (!USER_RST_N)
            begin
            oobclk_cnt <= 2'd0;
            oobclk     <= 1'd0;
            end
        else
            begin
            oobclk_cnt <= oobclk_cnt + 2'd1;
            oobclk     <= pclk_sel_reg2 ? oobclk_cnt[1] : oobclk_cnt[0];
            end
    end 
    end
else
    begin : oobclk_div_disable
    always @ (posedge USER_OOBCLK_IN)
    begin
        if (!USER_RST_N)
            begin
            oobclk_cnt <= 2'd0;
            oobclk     <= 1'd0;
            end
        else
            begin
            oobclk_cnt <= 2'd0;
            oobclk     <= 1'd0;
            end
    end 
    end   
endgenerate
always @ (posedge USER_TXUSRCLK)
begin
    if (!USER_RST_N)
        rxcdrlock_cnt <= 4'd0;
    else
        if (rxcdrlock_reg2 && (rxcdrlock_cnt != RXCDRLOCK_MAX))
            rxcdrlock_cnt <= rxcdrlock_cnt + 4'd1;
        else if (rxcdrlock_reg2 && (rxcdrlock_cnt == RXCDRLOCK_MAX))
            rxcdrlock_cnt <= rxcdrlock_cnt;
        else
            rxcdrlock_cnt <= 4'd0;
end 
always @ (posedge USER_RXUSRCLK)
begin
    if (!USER_RXUSRCLK_RST_N)
        rxvalid_cnt <= 4'd0;
    else
        if (rxvalid_reg2 && (rxvalid_cnt != RXVALID_MAX) && (!rxstatus_reg2))
            rxvalid_cnt <= rxvalid_cnt + 4'd1;
        else if (rxvalid_reg2 && (rxvalid_cnt == RXVALID_MAX))
            rxvalid_cnt <= rxvalid_cnt;
        else
            rxvalid_cnt <= 4'd0;
end 
always @ (posedge USER_TXUSRCLK)
begin
    if (!USER_RST_N)
        converge_cnt <= 22'd0;
    else
        if (rst_idle_reg2 && rate_idle_reg2 && !rate_gen3_reg2)
            begin
            if (converge_cnt < converge_max_cnt) 
                converge_cnt <= converge_cnt + 22'd1;
            else 
                converge_cnt <= converge_cnt;
            end
        else
            converge_cnt <= 22'd0;
end 
always @ (posedge USER_TXUSRCLK)
begin
    if (!USER_RST_N)
        converge_gen3 <= 1'd0;
    else
        if (rate_gen3_reg2)
            if (rxeq_adapt_done_reg2)
                converge_gen3 <= 1'd1;
            else
                converge_gen3 <= converge_gen3;
        else
            converge_gen3 <= 1'd0;
end 
always @ (posedge USER_RXUSRCLK)
begin
    if (!USER_RXUSRCLK_RST_N)
        gen3_rdy <= 1'd0;
    else   
        gen3_rdy <= rate_idle_reg2 && rate_gen3_reg2;    
end 
assign USER_RESETOVRD      = (fsm != FSM_IDLE);
assign USER_TXPMARESET     = 1'd0; 
assign USER_RXPMARESET     = reset[0];  
assign USER_RXCDRRESET     = reset[1];
assign USER_RXCDRFREQRESET = reset[2];
assign USER_RXDFELPMRESET  = reset[3];
assign USER_EYESCANRESET   = reset[4];
assign USER_TXPCSRESET     = 1'd0;  
assign USER_RXPCSRESET     = reset[5];  
assign USER_RXBUFRESET     = reset[6];  
assign USER_RESETOVRD_DONE = (fsm == FSM_IDLE);
assign USER_OOBCLK         = oobclk; 
assign USER_RESETDONE      = (txresetdone_reg2 && rxresetdone_reg2);
assign USER_ACTIVE_LANE    = !(txelecidle_reg2 && txcompliance_reg2);
assign USER_RXCDRLOCK_OUT  = (USER_RXCDRLOCK_IN && (rxcdrlock_cnt == RXCDRLOCK_MAX));        
assign USER_RXVALID_OUT    = ((USER_RXVALID_IN  && (rxvalid_cnt == RXVALID_MAX)) &&          
                              rst_idle_reg2                                      &&          
                              rate_idle_reg2);                                               
assign USER_PHYSTATUS_OUT  = (!rst_idle_reg2                                              || 
                              ((rate_idle_reg2 || rate_rxsync_reg2) && USER_PHYSTATUS_IN) || 
                              rate_done_reg2);                                               
assign USER_PHYSTATUS_RST  = !rst_idle_reg2;                                                 
assign USER_GEN3_RDY       = 0;
assign USER_RX_CONVERGE    = (converge_cnt == converge_max_cnt) || converge_gen3;   
endmodule
