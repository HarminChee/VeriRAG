`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_8_qpll_drp #
(
    parameter PCIE_GT_DEVICE   = "GTX",                     
    parameter PCIE_USE_MODE    = "3.0",                     
    parameter PCIE_PLL_SEL     = "CPLL",                    
    parameter PCIE_REFCLK_FREQ = 0,                         
    parameter INDEX_MAX        = 3'd6                       
)
(
    input               DRP_CLK,
    input               DRP_RST_N,
    input               DRP_OVRD,
    input               DRP_GEN3,
    input               DRP_QPLLLOCK,
    input               DRP_START,
    input       [15:0]  DRP_DO,
    input               DRP_RDY,
    output      [ 7:0]  DRP_ADDR,
    output              DRP_EN,  
    output      [15:0]  DRP_DI,   
    output              DRP_WE,
    output              DRP_DONE,
    output              DRP_QPLLRESET,
    output      [ 5:0]  DRP_CRSCODE,
    output      [ 8:0]  DRP_FSM
);
    reg                 ovrd_reg1;
    reg                 gen3_reg1;
    reg                 qplllock_reg1;
    reg                 start_reg1;
    reg         [15:0]  do_reg1;
    reg                 rdy_reg1;
    reg                 ovrd_reg2;
    reg                 gen3_reg2;
    reg                 qplllock_reg2;
    reg                 start_reg2;
    reg         [15:0]  do_reg2;
    reg                 rdy_reg2;
    reg         [ 2:0]  index   =  3'd0;
    reg                 mode    =  1'd0;
    reg         [ 5:0]  crscode =  6'd0;
    reg         [ 7:0]  addr    =  8'd0;
    reg         [15:0]  di      = 16'd0;
    reg                 done    =  1'd0;
    reg         [ 8:0]  fsm     =  7'd1;      
    localparam          ADDR_QPLL_FBDIV               = 8'h36;
    localparam          ADDR_QPLL_CFG                 = 8'h32;
    localparam          ADDR_QPLL_LPF                 = 8'h31;  
    localparam          ADDR_CRSCODE                  = 8'h88;  
    localparam          ADDR_QPLL_COARSE_FREQ_OVRD    = 8'h35;
    localparam          ADDR_QPLL_COARSE_FREQ_OVRD_EN = 8'h36;  
    localparam          ADDR_QPLL_LOCK_CFG            = 8'h34;
    localparam          MASK_QPLL_FBDIV               = 16'b1111110000000000;  
    localparam          MASK_QPLL_CFG                 = 16'b1111111110111111;  
    localparam          MASK_QPLL_LPF                 = 16'b1000011111111111;  
    localparam          MASK_QPLL_COARSE_FREQ_OVRD    = 16'b0000001111111111;  
    localparam          MASK_QPLL_COARSE_FREQ_OVRD_EN = 16'b1111011111111111;  
    localparam          MASK_QPLL_LOCK_CFG            = 16'b1110011111111111;  
    localparam          NORM_QPLL_COARSE_FREQ_OVRD    = 16'b0000000000000000;  
    localparam          NORM_QPLL_COARSE_FREQ_OVRD_EN = 16'b0000000000000000;  
    localparam          NORM_QPLL_LOCK_CFG            = 16'b0000000000000000;  
    localparam          OVRD_QPLL_COARSE_FREQ_OVRD    = 16'b0000000000000000;  
    localparam          OVRD_QPLL_COARSE_FREQ_OVRD_EN = 16'b0000100000000000;  
    localparam          OVRD_QPLL_LOCK_CFG            = 16'b0000000000000000;  
    localparam          QPLL_FBDIV = (PCIE_REFCLK_FREQ == 2) && (PCIE_PLL_SEL == "QPLL") ? 16'b0000000010000000 : 
                                     (PCIE_REFCLK_FREQ == 1) && (PCIE_PLL_SEL == "QPLL") ? 16'b0000000100100000 : 
                                     (PCIE_REFCLK_FREQ == 0) && (PCIE_PLL_SEL == "QPLL") ? 16'b0000000101110000 : 
                                     (PCIE_REFCLK_FREQ == 2) && (PCIE_PLL_SEL == "CPLL") ? 16'b0000000001100000 : 
                                     (PCIE_REFCLK_FREQ == 1) && (PCIE_PLL_SEL == "CPLL") ? 16'b0000000011100000 : 16'b0000000100100000;
    localparam          GEN12_QPLL_FBDIV = (PCIE_REFCLK_FREQ == 2) ? 16'b0000000010000000 : 
                                           (PCIE_REFCLK_FREQ == 1) ? 16'b0000000100100000 : 16'b0000000101110000;
    localparam          GEN3_QPLL_FBDIV  = (PCIE_REFCLK_FREQ == 2) ? 16'b0000000001100000 : 
                                           (PCIE_REFCLK_FREQ == 1) ? 16'b0000000011100000 : 16'b0000000100100000;
    localparam          GEN12_QPLL_CFG = (PCIE_PLL_SEL == "QPLL") ? 16'b0000000000000000 : 16'b0000000001000000;
    localparam          GEN3_QPLL_CFG  = 16'b0000000001000000;  
    localparam          GEN12_QPLL_LPF = (PCIE_PLL_SEL == "QPLL") ? 16'b0_0100_00000000000 : 16'b0_1101_00000000000;
    localparam          GEN3_QPLL_LPF  = 16'b0_1101_00000000000;  
    wire        [15:0]  data_qpll_fbdiv;  
    wire        [15:0]  data_qpll_cfg;  
    wire        [15:0]  data_qpll_lpf;  
    wire        [15:0]  data_qpll_coarse_freq_ovrd;               
    wire        [15:0]  data_qpll_coarse_freq_ovrd_en; 
    wire        [15:0]  data_qpll_lock_cfg;      
    localparam          FSM_IDLE      = 9'b000000001;  
    localparam          FSM_LOAD      = 9'b000000010;                           
    localparam          FSM_READ      = 9'b000000100;
    localparam          FSM_RRDY      = 9'b000001000;
    localparam          FSM_WRITE     = 9'b000010000;
    localparam          FSM_WRDY      = 9'b000100000;    
    localparam          FSM_DONE      = 9'b001000000; 
    localparam          FSM_QPLLRESET = 9'b010000000; 
    localparam          FSM_QPLLLOCK  = 9'b100000000;
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        ovrd_reg1     <=  1'd0;
        gen3_reg1     <=  1'd0;
        qplllock_reg1 <=  1'd0;
        start_reg1    <=  1'd0;
        do_reg1       <= 16'd0;
        rdy_reg1      <=  1'd0;
        ovrd_reg2     <=  1'd0;
        gen3_reg2     <=  1'd0;
        qplllock_reg2 <=  1'd0;
        start_reg2    <=  1'd0;
        do_reg2       <= 16'd0;
        rdy_reg2      <=  1'd0;
        end
    else
        begin
        ovrd_reg1     <= DRP_OVRD;
        gen3_reg1     <= DRP_GEN3;
        qplllock_reg1 <= DRP_QPLLLOCK;
        start_reg1    <= DRP_START;
        do_reg1       <= DRP_DO;
        rdy_reg1      <= DRP_RDY;
        ovrd_reg2     <= ovrd_reg1;
        gen3_reg2     <= gen3_reg1;
        qplllock_reg2 <= qplllock_reg1;
        start_reg2    <= start_reg1;
        do_reg2       <= do_reg1;
        rdy_reg2      <= rdy_reg1;
        end
end  
assign data_qpll_fbdiv               = (gen3_reg2) ? GEN3_QPLL_FBDIV : GEN12_QPLL_FBDIV;
assign data_qpll_cfg                 = (gen3_reg2) ? GEN3_QPLL_CFG   : GEN12_QPLL_CFG;
assign data_qpll_lpf                 = (gen3_reg2) ? GEN3_QPLL_LPF   : GEN12_QPLL_LPF;
assign data_qpll_coarse_freq_ovrd    =  NORM_QPLL_COARSE_FREQ_OVRD;
assign data_qpll_coarse_freq_ovrd_en = (ovrd_reg2) ? OVRD_QPLL_COARSE_FREQ_OVRD_EN : NORM_QPLL_COARSE_FREQ_OVRD_EN;
assign data_qpll_lock_cfg            = (ovrd_reg2) ? OVRD_QPLL_LOCK_CFG            : NORM_QPLL_LOCK_CFG;
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        addr    <=  8'd0;
        di      <= 16'd0;
        crscode <=  6'd0;
        end
    else
        begin
        case (index)
        3'd0 :
            begin        
            addr    <= ADDR_QPLL_FBDIV;
            di      <= (do_reg2 & MASK_QPLL_FBDIV) | (mode ? data_qpll_fbdiv : QPLL_FBDIV);
            crscode <= crscode;
            end   
        3'd1 :
            begin       
            addr    <= ADDR_QPLL_CFG;
            if (PCIE_GT_DEVICE == "GTX") 
                di <= (do_reg2 & MASK_QPLL_CFG) | data_qpll_cfg;
            else
                di <= (do_reg2 & 16'hFFFF) | data_qpll_cfg;
            crscode <= crscode;
            end       
        3'd2 :
            begin        
            addr    <= ADDR_QPLL_LPF;
            if (PCIE_GT_DEVICE == "GTX") 
                di <= (do_reg2 & MASK_QPLL_LPF) | data_qpll_lpf;
            else
                di <= (do_reg2 & 16'hFFFF) | data_qpll_lpf;
            crscode <= crscode;
            end     
        3'd3 :
            begin        
            addr <= ADDR_CRSCODE;
            di   <= do_reg2;
            if (ovrd_reg2)
                crscode <= do_reg2[6:1];                 
            else
                crscode <= crscode;   
            end
        3'd4 :
            begin        
            addr    <= ADDR_QPLL_COARSE_FREQ_OVRD;
            di      <= (do_reg2 & MASK_QPLL_COARSE_FREQ_OVRD) | {(crscode - 6'd1), data_qpll_coarse_freq_ovrd[9:0]};
            crscode <= crscode;
            end    
        3'd5 :
            begin        
            addr    <= ADDR_QPLL_COARSE_FREQ_OVRD_EN;
            di      <= (do_reg2 & MASK_QPLL_COARSE_FREQ_OVRD_EN) | data_qpll_coarse_freq_ovrd_en;
            crscode <= crscode;
            end    
        3'd6 :
            begin        
            addr    <= ADDR_QPLL_LOCK_CFG;
            di      <= (do_reg2 & MASK_QPLL_LOCK_CFG) | data_qpll_lock_cfg;
            crscode <= crscode;
            end       
        default : 
            begin
            addr    <=  8'd0;
            di      <= 16'd0;
            crscode <=  6'd0;
            end
        endcase
        end
end  
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        fsm   <= FSM_IDLE;
        index <= 3'd0;
        mode  <= 1'd0;
        done  <= 1'd0;
        end
    else
        begin
        case (fsm)
        FSM_IDLE :  
            begin
            if (start_reg2)
                begin
                fsm   <= FSM_LOAD;
                index <= 3'd0;
                mode  <= 1'd0;
                done  <= 1'd0;
                end
            else if ((gen3_reg2 != gen3_reg1) && (PCIE_PLL_SEL == "QPLL"))
                begin
                fsm   <= FSM_LOAD;
                index <= 3'd0;
                mode  <= 1'd1;
                done  <= 1'd0;
                end
            else
                begin
                fsm   <= FSM_IDLE;
                index <= 3'd0;
                mode  <= 1'd0;
                done  <= 1'd1;
                end
            end    
        FSM_LOAD :
            begin
            fsm   <= FSM_READ;
            index <= index;
            mode  <= mode;
            done  <= 1'd0;
            end  
        FSM_READ :
            begin
            fsm   <= FSM_RRDY;
            index <= index;
            mode  <= mode;
            done  <= 1'd0;
            end
        FSM_RRDY :    
            begin
            fsm   <= (rdy_reg2 ? FSM_WRITE : FSM_RRDY);
            index <= index;
            mode  <= mode;
            done  <= 1'd0;
            end  
        FSM_WRITE :    
            begin
            fsm   <= FSM_WRDY;
            index <= index;
            mode  <= mode;
            done  <= 1'd0;
            end       
        FSM_WRDY :    
            begin
            fsm   <= (rdy_reg2 ? FSM_DONE : FSM_WRDY);
            index <= index;
            mode  <= mode;
            done  <= 1'd0;
            end        
        FSM_DONE :
            begin
            if ((index == INDEX_MAX) || (mode && (index == 3'd2)))
                begin
                fsm   <= mode ? FSM_QPLLRESET : FSM_IDLE;
                index <= 3'd0;
                mode  <= mode;
                done  <= 1'd0;
                end
            else       
                begin
                fsm   <= FSM_LOAD;
                index <= index + 3'd1;
                mode  <= mode;
                done  <= 1'd0;
                end
            end     
        FSM_QPLLRESET :
            begin
            fsm   <= !qplllock_reg2 ? FSM_QPLLLOCK : FSM_QPLLRESET;
            index <= 3'd0;
            mode  <= mode;
            done  <= 1'd0;
            end
        FSM_QPLLLOCK :
            begin
            fsm   <= qplllock_reg2 ? FSM_IDLE : FSM_QPLLLOCK;
            index <= 3'd0;
            mode  <= mode;
            done  <= 1'd0;
            end
        default :
            begin      
            fsm   <= FSM_IDLE;
            index <= 3'd0;
            mode  <= 1'd0;
            done  <= 1'd0;
            end
        endcase
        end
end 
assign DRP_ADDR      = addr;
assign DRP_EN        = (fsm == FSM_READ) || (fsm == FSM_WRITE);
assign DRP_DI        = di;
assign DRP_WE        = (fsm == FSM_WRITE) || (fsm == FSM_WRDY);
assign DRP_DONE      = done;
assign DRP_QPLLRESET = (fsm == FSM_QPLLRESET);
assign DRP_CRSCODE   = crscode;
assign DRP_FSM       = fsm;
endmodule
