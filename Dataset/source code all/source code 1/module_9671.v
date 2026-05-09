`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie3_7x_0_pipe_drp #
(
    parameter PCIE_GT_DEVICE       = "GTX",                                     
    parameter PCIE_USE_MODE        = "3.0",                                     
    parameter PCIE_ASYNC_EN        = "FALSE",                                   
    parameter PCIE_PLL_SEL         = "CPLL",                                    
    parameter PCIE_AUX_CDR_GEN3_EN = "TRUE",                                   
    parameter PCIE_TXBUF_EN        = "FALSE",                                   
    parameter PCIE_RXBUF_EN        = "TRUE",                                    
    parameter PCIE_TXSYNC_MODE     = 0,                                         
    parameter PCIE_RXSYNC_MODE     = 0,                                         
    parameter LOAD_CNT_MAX         = 2'd1,                                      
    parameter INDEX_MAX            = 5'd21                                      
)
(
    input               DRP_CLK,
    input               DRP_RST_N,
    input               DRP_GTXRESET,
    input       [ 1:0]  DRP_RATE,
    input               DRP_X16X20_MODE,
    input               DRP_X16,
    input               DRP_START,
    input       [15:0]  DRP_DO,
    input               DRP_RDY,
    output      [ 8:0]  DRP_ADDR,
    output              DRP_EN,  
    output      [15:0]  DRP_DI,   
    output              DRP_WE,
    output              DRP_DONE,
    output      [ 6:0]  DRP_FSM
);
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 gtxreset_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  rate_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 x16x20_mode_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 x16_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 start_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [15:0]  do_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rdy_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 gtxreset_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  rate_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 x16x20_mode_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 x16_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 start_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [15:0]  do_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rdy_reg2;
    reg         [ 1:0]  load_cnt =  2'd0;
    reg         [ 4:0]  index    =  5'd0;
    reg                 mode     =  1'd0;
    reg         [ 8:0]  addr_reg =  9'd0;
    reg         [15:0]  di_reg   = 16'd0;
    reg                 done     =  1'd0;
    reg         [ 6:0]  fsm      =  7'd1;      
    localparam          ADDR_PCS_RSVD_ATTR        = 9'h06F;
    localparam          ADDR_TXOUT_DIV            = 9'h088;
    localparam          ADDR_RXOUT_DIV            = 9'h088;
    localparam          ADDR_TX_DATA_WIDTH        = 9'h06B;            
    localparam          ADDR_TX_INT_DATAWIDTH     = 9'h06B;         
    localparam          ADDR_RX_DATA_WIDTH        = 9'h011;            
    localparam          ADDR_RX_INT_DATAWIDTH     = 9'h011;              
    localparam          ADDR_TXBUF_EN             = 9'h01C;           
    localparam          ADDR_RXBUF_EN             = 9'h09D;
    localparam          ADDR_TX_XCLK_SEL          = 9'h059;
    localparam          ADDR_RX_XCLK_SEL          = 9'h059;                 
    localparam          ADDR_CLK_CORRECT_USE      = 9'h044; 
    localparam          ADDR_TX_DRIVE_MODE        = 9'h019;
    localparam          ADDR_RXCDR_EIDLE          = 9'h0A7;  
    localparam          ADDR_RX_DFE_LPM_EIDLE     = 9'h01E;
    localparam          ADDR_PMA_RSV_A            = 9'h099;
    localparam          ADDR_PMA_RSV_B            = 9'h09A;
    localparam          ADDR_RXCDR_CFG_A          = 9'h0A8;
    localparam          ADDR_RXCDR_CFG_B          = 9'h0A9;
    localparam          ADDR_RXCDR_CFG_C          = 9'h0AA;
    localparam          ADDR_RXCDR_CFG_D          = 9'h0AB;
    localparam          ADDR_RXCDR_CFG_E          = 9'h0AC;
    localparam          ADDR_RXCDR_CFG_F          = 9'h0AD;  
    localparam          MASK_PCS_RSVD_ATTR        = 16'b1111111111111001;  
    localparam          MASK_TXOUT_DIV            = 16'b1111111110001111;  
    localparam          MASK_RXOUT_DIV            = 16'b1111111111111000;  
    localparam          MASK_TX_DATA_WIDTH        = 16'b1111111111111000;  
    localparam          MASK_TX_INT_DATAWIDTH     = 16'b1111111111101111;  
    localparam          MASK_RX_DATA_WIDTH        = 16'b1100011111111111;  
    localparam          MASK_X16X20_RX_DATA_WIDTH = 16'b1111011111111111;  
    localparam          MASK_RX_INT_DATAWIDTH     = 16'b1011111111111111;  
    localparam          MASK_TXBUF_EN             = 16'b1011111111111111;  
    localparam          MASK_RXBUF_EN             = 16'b1111111111111101;  
    localparam          MASK_TX_XCLK_SEL          = 16'b1111111101111111;  
    localparam          MASK_RX_XCLK_SEL          = 16'b1111111110111111;  
    localparam          MASK_CLK_CORRECT_USE      = 16'b1011111111111111;  
    localparam          MASK_TX_DRIVE_MODE        = 16'b1111111111100000;  
    localparam          MASK_RXCDR_EIDLE          = 16'b1111011111111111;  
    localparam          MASK_RX_DFE_LPM_EIDLE     = 16'b1011111111111111;  
    localparam          MASK_PMA_RSV_A            = 16'b0000000000000000;  
    localparam          MASK_PMA_RSV_B            = 16'b0000000000000000;  
    localparam          MASK_RXCDR_CFG_A          = 16'b0000000000000000;  
    localparam          MASK_RXCDR_CFG_B          = 16'b0000000000000000;  
    localparam          MASK_RXCDR_CFG_C          = 16'b0000000000000000;  
    localparam          MASK_RXCDR_CFG_D          = 16'b0000000000000000;  
    localparam          MASK_RXCDR_CFG_E_GTX      = 16'b1111111100000000;  
    localparam          MASK_RXCDR_CFG_E_GTH      = 16'b0000000000000000;  
    localparam          MASK_RXCDR_CFG_F_GTX      = 16'b1111111111111111;  
    localparam          MASK_RXCDR_CFG_F_GTH      = 16'b1111111111111000;  
    localparam          GEN12_TXOUT_DIV           = (PCIE_PLL_SEL == "QPLL") ? 16'b0000000000100000 : 16'b0000000000010000;  
    localparam          GEN12_RXOUT_DIV           = (PCIE_PLL_SEL == "QPLL") ? 16'b0000000000000010 : 16'b0000000000000001;  
    localparam          GEN12_TX_DATA_WIDTH       = 16'b0000000000000011;  
    localparam          GEN12_TX_INT_DATAWIDTH    = 16'b0000000000000000;  
    localparam          GEN12_RX_DATA_WIDTH       = 16'b0001100000000000;  
    localparam          GEN12_RX_INT_DATAWIDTH    = 16'b0000000000000000;  
    localparam          GEN12_TXBUF_EN            = 16'b0100000000000000;  
    localparam          GEN12_RXBUF_EN            = 16'b0000000000000010;  
    localparam          GEN12_TX_XCLK_SEL         = 16'b0000000000000000;  
    localparam          GEN12_RX_XCLK_SEL         = 16'b0000000000000000;  
    localparam          GEN12_CLK_CORRECT_USE     = 16'b0100000000000000;  
    localparam          GEN12_TX_DRIVE_MODE       = 16'b0000000000000001;  
    localparam          GEN12_RXCDR_EIDLE         = 16'b0000100000000000;  
    localparam          GEN12_RX_DFE_LPM_EIDLE    = 16'b0100000000000000;  
    localparam          GEN12_PMA_RSV_A_GTX       = 16'b1000010010000000;  
    localparam          GEN12_PMA_RSV_B_GTX       = 16'b0000000000000001;  
    localparam          GEN12_PMA_RSV_A_GTH       = 16'b0000000000001000;  
    localparam          GEN12_PMA_RSV_B_GTH       = 16'b0000000000000000;  
    localparam          GEN12_RXCDR_CFG_A_GTX     = 16'h0020;              
    localparam          GEN12_RXCDR_CFG_B_GTX     = 16'h1020;              
    localparam          GEN12_RXCDR_CFG_C_GTX     = 16'h23FF;              
    localparam          GEN12_RXCDR_CFG_D_GTX_S   = 16'h0000;              
    localparam          GEN12_RXCDR_CFG_D_GTX_A   = 16'h8000;              
    localparam          GEN12_RXCDR_CFG_E_GTX     = 16'h0003;              
    localparam          GEN12_RXCDR_CFG_F_GTX     = 16'h0000;              
    localparam          GEN12_RXCDR_CFG_A_GTH_S   = 16'h0018;              
    localparam          GEN12_RXCDR_CFG_A_GTH_A   = 16'h8018;              
    localparam          GEN12_RXCDR_CFG_B_GTH     = 16'hC208;              
    localparam          GEN12_RXCDR_CFG_C_GTH     = 16'h2000;              
    localparam          GEN12_RXCDR_CFG_D_GTH     = 16'h07FE;              
    localparam          GEN12_RXCDR_CFG_E_GTH     = 16'h0020;              
    localparam          GEN12_RXCDR_CFG_F_GTH     = 16'h0000;              
    localparam          GEN3_TXOUT_DIV            = 16'b0000000000000000;  
    localparam          GEN3_RXOUT_DIV            = 16'b0000000000000000;  
    localparam          GEN3_TX_DATA_WIDTH        = 16'b0000000000000100;  
    localparam          GEN3_TX_INT_DATAWIDTH     = 16'b0000000000010000;  
    localparam          GEN3_RX_DATA_WIDTH        = 16'b0010000000000000;  
    localparam          GEN3_RX_INT_DATAWIDTH     = 16'b0100000000000000;  
    localparam          GEN3_TXBUF_EN             = 16'b0000000000000000;  
    localparam          GEN3_RXBUF_EN             = 16'b0000000000000000;  
    localparam          GEN3_TX_XCLK_SEL          = 16'b0000000010000000;  
    localparam          GEN3_RX_XCLK_SEL          = 16'b0000000001000000;  
    localparam          GEN3_CLK_CORRECT_USE      = 16'b0000000000000000;  
    localparam          GEN3_TX_DRIVE_MODE        = 16'b0000000000000010;  
    localparam          GEN3_RXCDR_EIDLE          = 16'b0000000000000000;  
    localparam          GEN3_RX_DFE_LPM_EIDLE     = 16'b0000000000000000;  
    localparam          GEN3_PMA_RSV_A_GTX        = 16'b0111000010000000;  
    localparam          GEN3_PMA_RSV_B_GTX        = 16'b0000000000011110;  
    localparam          GEN3_PMA_RSV_A_GTH        = 16'b0000000000001000;  
    localparam          GEN3_PMA_RSV_B_GTH        = 16'b0000000000000000;  
    localparam          GEN3_RXCDR_CFG_A_GTX      = 16'h0080;              
    localparam          GEN3_RXCDR_CFG_B_GTX      = 16'h1010;              
    localparam          GEN3_RXCDR_CFG_C_GTX      = 16'h0BFF;              
    localparam          GEN3_RXCDR_CFG_D_GTX_S    = 16'h0000;              
    localparam          GEN3_RXCDR_CFG_D_GTX_A    = 16'h8000;              
    localparam          GEN3_RXCDR_CFG_E_GTX      = 16'h000B;              
    localparam          GEN3_RXCDR_CFG_F_GTX      = 16'h0000;              
    localparam          GEN3_RXCDR_CFG_A_GTH_S    = 16'h0018;              
    localparam          GEN3_RXCDR_CFG_A_GTH_A    = 16'h8018;              
    localparam          GEN3_RXCDR_CFG_B_GTH      = 16'hC848;              
    localparam          GEN3_RXCDR_CFG_C_GTH      = 16'h1000;              
    localparam          GEN3_RXCDR_CFG_D_GTH      = 16'h07FE;              
    localparam          GEN3_RXCDR_CFG_D_GTH_AUX  = 16'h0FFE;              
    localparam          GEN3_RXCDR_CFG_E_GTH      = 16'h0010;              
    localparam          GEN3_RXCDR_CFG_F_GTH      = 16'h0000;              
    localparam          GEN3_RXCDR_CFG_F_GTH_AUX  = 16'h0002;              
    localparam          GEN123_PCS_RSVD_ATTR_A    = 16'b0000000000000000;  
    localparam          GEN123_PCS_RSVD_ATTR_M_TX = 16'b0000000000000010;  
    localparam          GEN123_PCS_RSVD_ATTR_M_RX = 16'b0000000000000100;  
    localparam          X16_RX_DATAWIDTH   = 16'b0000000000000000;  
    localparam          X20_RX_DATAWIDTH   = 16'b0000100000000000;  
    wire        [15:0]  data_txout_div;
    wire        [15:0]  data_rxout_div;
    wire        [15:0]  data_tx_data_width;               
    wire        [15:0]  data_tx_int_datawidth;            
    wire        [15:0]  data_rx_data_width;               
    wire        [15:0]  data_rx_int_datawidth;                
    wire        [15:0]  data_txbuf_en;        
    wire        [15:0]  data_rxbuf_en;        
    wire        [15:0]  data_tx_xclk_sel;
    wire        [15:0]  data_rx_xclk_sel;            
    wire        [15:0]  data_clk_correction_use; 
    wire        [15:0]  data_tx_drive_mode;
    wire        [15:0]  data_rxcdr_eidle;
    wire        [15:0]  data_rx_dfe_lpm_eidle;
    wire        [15:0]  data_pma_rsv_a;
    wire        [15:0]  data_pma_rsv_b;
    wire        [15:0]  data_rxcdr_cfg_a;
    wire        [15:0]  data_rxcdr_cfg_b; 
    wire        [15:0]  data_rxcdr_cfg_c;
    wire        [15:0]  data_rxcdr_cfg_d; 
    wire        [15:0]  data_rxcdr_cfg_e;
    wire        [15:0]  data_rxcdr_cfg_f;
    wire        [15:0]  data_pcs_rsvd_attr_a;  
    wire        [15:0]  data_pcs_rsvd_attr_m_tx; 
    wire        [15:0]  data_pcs_rsvd_attr_m_rx; 
    wire        [15:0]  data_pcs_rsvd_attr_m;   
    wire        [15:0]  data_x16x20_rx_datawidth;    
    localparam          FSM_IDLE  = 7'b0000001;  
    localparam          FSM_LOAD  = 7'b0000010;                           
    localparam          FSM_READ  = 7'b0000100;
    localparam          FSM_RRDY  = 7'b0001000;
    localparam          FSM_WRITE = 7'b0010000;
    localparam          FSM_WRDY  = 7'b0100000;    
    localparam          FSM_DONE  = 7'b1000000;   
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        gtxreset_reg1    <=  1'd0;
        rate_reg1        <=  2'd0;
        x16x20_mode_reg1 <=  1'd0;
        x16_reg1         <=  1'd0;
        do_reg1          <= 16'd0;
        rdy_reg1         <=  1'd0;
        start_reg1       <=  1'd0;
        gtxreset_reg2    <=  1'd0;
        rate_reg2        <=  2'd0;
        x16x20_mode_reg2 <=  1'd0;
        x16_reg2         <=  1'd0;
        do_reg2          <= 16'd0;
        rdy_reg2         <=  1'd0;
        start_reg2       <=  1'd0;
        end
    else
        begin
        gtxreset_reg1    <= DRP_GTXRESET;
        rate_reg1        <= DRP_RATE;
        x16x20_mode_reg1 <= DRP_X16X20_MODE;
        x16_reg1         <= DRP_X16;
        do_reg1          <= DRP_DO;
        rdy_reg1         <= DRP_RDY;
        start_reg1       <= DRP_START;
        gtxreset_reg2    <= gtxreset_reg1;
        rate_reg2        <= rate_reg1;
        x16x20_mode_reg2 <= x16x20_mode_reg1;
        x16_reg2         <= x16_reg1;
        do_reg2          <= do_reg1;
        rdy_reg2         <= rdy_reg1;
        start_reg2       <= start_reg1;
        end
end  
assign data_txout_div          =  (rate_reg2 == 2'd2)                                ? GEN3_TXOUT_DIV        : GEN12_TXOUT_DIV;
assign data_rxout_div          =  (rate_reg2 == 2'd2)                                ? GEN3_RXOUT_DIV        : GEN12_RXOUT_DIV;
assign data_tx_data_width      =  (rate_reg2 == 2'd2)                                ? GEN3_TX_DATA_WIDTH    : GEN12_TX_DATA_WIDTH;
assign data_tx_int_datawidth   =  (rate_reg2 == 2'd2)                                ? GEN3_TX_INT_DATAWIDTH : GEN12_TX_INT_DATAWIDTH;
assign data_rx_data_width      =  (rate_reg2 == 2'd2)                                ? GEN3_RX_DATA_WIDTH    : GEN12_RX_DATA_WIDTH;
assign data_rx_int_datawidth   =  (rate_reg2 == 2'd2)                                ? GEN3_RX_INT_DATAWIDTH : GEN12_RX_INT_DATAWIDTH;
assign data_txbuf_en           = ((rate_reg2 == 2'd2) || (PCIE_TXBUF_EN == "FALSE")) ? GEN3_TXBUF_EN         : GEN12_TXBUF_EN;
assign data_rxbuf_en           = ((rate_reg2 == 2'd2) && (PCIE_RXBUF_EN == "FALSE")) ? GEN3_RXBUF_EN         : GEN12_RXBUF_EN;
assign data_tx_xclk_sel        = ((rate_reg2 == 2'd2) || (PCIE_TXBUF_EN == "FALSE")) ? GEN3_TX_XCLK_SEL      : GEN12_TX_XCLK_SEL;
assign data_rx_xclk_sel        = ((rate_reg2 == 2'd2) && (PCIE_RXBUF_EN == "FALSE")) ? GEN3_RX_XCLK_SEL      : GEN12_RX_XCLK_SEL;
assign data_clk_correction_use =  (rate_reg2 == 2'd2)                                ? GEN3_CLK_CORRECT_USE  : GEN12_CLK_CORRECT_USE;
assign data_tx_drive_mode      =  (rate_reg2 == 2'd2)                                ? GEN3_TX_DRIVE_MODE    : GEN12_TX_DRIVE_MODE;   
assign data_rxcdr_eidle        =  (rate_reg2 == 2'd2)                                ? GEN3_RXCDR_EIDLE      : GEN12_RXCDR_EIDLE;
assign data_rx_dfe_lpm_eidle   =  (rate_reg2 == 2'd2)                                ? GEN3_RX_DFE_LPM_EIDLE : GEN12_RX_DFE_LPM_EIDLE;
assign data_pma_rsv_a          =  (rate_reg2 == 2'd2)                                ? ((PCIE_GT_DEVICE == "GTH") ? GEN3_PMA_RSV_A_GTH  : GEN3_PMA_RSV_A_GTX) :
                                                                                       ((PCIE_GT_DEVICE == "GTH") ? GEN12_PMA_RSV_A_GTH : GEN12_PMA_RSV_A_GTX);
assign data_pma_rsv_b          =  (rate_reg2 == 2'd2)                                ? ((PCIE_GT_DEVICE == "GTH") ? GEN3_PMA_RSV_B_GTH  : GEN3_PMA_RSV_B_GTX) :
                                                                                       ((PCIE_GT_DEVICE == "GTH") ? GEN12_PMA_RSV_B_GTH : GEN12_PMA_RSV_B_GTX);
assign data_rxcdr_cfg_a = (rate_reg2 == 2'd2) ? ((PCIE_GT_DEVICE == "GTH") ? ((PCIE_ASYNC_EN == "TRUE") ? GEN3_RXCDR_CFG_A_GTH_A  : GEN3_RXCDR_CFG_A_GTH_S)  : GEN3_RXCDR_CFG_A_GTX) :
                                                ((PCIE_GT_DEVICE == "GTH") ? ((PCIE_ASYNC_EN == "TRUE") ? GEN12_RXCDR_CFG_A_GTH_A : GEN12_RXCDR_CFG_A_GTH_S) : GEN12_RXCDR_CFG_A_GTX);
assign data_rxcdr_cfg_b = (rate_reg2 == 2'd2) ? ((PCIE_GT_DEVICE == "GTH") ?  GEN3_RXCDR_CFG_B_GTH  : GEN3_RXCDR_CFG_B_GTX) :
                                                ((PCIE_GT_DEVICE == "GTH") ?  GEN12_RXCDR_CFG_B_GTH : GEN12_RXCDR_CFG_B_GTX);
assign data_rxcdr_cfg_c = (rate_reg2 == 2'd2) ? ((PCIE_GT_DEVICE == "GTH") ?  GEN3_RXCDR_CFG_C_GTH  : GEN3_RXCDR_CFG_C_GTX) :
                                                ((PCIE_GT_DEVICE == "GTH") ?  GEN12_RXCDR_CFG_C_GTH : GEN12_RXCDR_CFG_C_GTX);
assign data_rxcdr_cfg_d = (rate_reg2 == 2'd2) ? ((PCIE_GT_DEVICE == "GTH") ?  ((PCIE_AUX_CDR_GEN3_EN == "TRUE") ? GEN3_RXCDR_CFG_D_GTH_AUX : GEN3_RXCDR_CFG_D_GTH) : ((PCIE_ASYNC_EN == "TRUE") ? GEN3_RXCDR_CFG_D_GTX_A : GEN3_RXCDR_CFG_D_GTX_S)) :
                                                ((PCIE_GT_DEVICE == "GTH") ?  GEN12_RXCDR_CFG_D_GTH : ((PCIE_ASYNC_EN == "TRUE") ? GEN3_RXCDR_CFG_D_GTX_A : GEN3_RXCDR_CFG_D_GTX_S));
assign data_rxcdr_cfg_e = (rate_reg2 == 2'd2) ? ((PCIE_GT_DEVICE == "GTH") ?  GEN3_RXCDR_CFG_E_GTH  : GEN3_RXCDR_CFG_E_GTX) :
                                                ((PCIE_GT_DEVICE == "GTH") ?  GEN12_RXCDR_CFG_E_GTH : GEN12_RXCDR_CFG_E_GTX);
assign data_rxcdr_cfg_f = (rate_reg2 == 2'd2) ? ((PCIE_GT_DEVICE == "GTH") ?  ((PCIE_AUX_CDR_GEN3_EN == "TRUE") ? GEN3_RXCDR_CFG_F_GTH_AUX : GEN3_RXCDR_CFG_F_GTH) : GEN3_RXCDR_CFG_F_GTX) :
                                                ((PCIE_GT_DEVICE == "GTH") ?  GEN12_RXCDR_CFG_F_GTH : GEN12_RXCDR_CFG_F_GTX);
assign data_pcs_rsvd_attr_a    = GEN123_PCS_RSVD_ATTR_A;
assign data_pcs_rsvd_attr_m_tx = PCIE_TXSYNC_MODE ? GEN123_PCS_RSVD_ATTR_A : GEN123_PCS_RSVD_ATTR_M_TX;
assign data_pcs_rsvd_attr_m_rx = PCIE_RXSYNC_MODE ? GEN123_PCS_RSVD_ATTR_A : GEN123_PCS_RSVD_ATTR_M_RX;
assign data_pcs_rsvd_attr_m    = data_pcs_rsvd_attr_m_tx | data_pcs_rsvd_attr_m_rx;
assign data_x16x20_rx_datawidth = x16_reg2 ? X16_RX_DATAWIDTH : X20_RX_DATAWIDTH;
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        load_cnt <= 2'd0;
    else
        if ((fsm == FSM_LOAD) && (load_cnt < LOAD_CNT_MAX))
            load_cnt <= load_cnt + 2'd1;
        else if ((fsm == FSM_LOAD) && (load_cnt == LOAD_CNT_MAX))
            load_cnt <= load_cnt;
        else
            load_cnt <= 2'd0;
end 
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        addr_reg <=  9'd0;
        di_reg   <= 16'd0;
        end
    else
        begin
        case (index)
        5'd0:     
            begin
            addr_reg <= mode             ? ADDR_PCS_RSVD_ATTR : 
                        x16x20_mode_reg2 ? ADDR_RX_DATA_WIDTH : ADDR_TXOUT_DIV; 
            di_reg   <= mode             ? ((do_reg2 & MASK_PCS_RSVD_ATTR)        | data_pcs_rsvd_attr_a) : 
                        x16x20_mode_reg2 ? ((do_reg2 & MASK_X16X20_RX_DATA_WIDTH) | data_x16x20_rx_datawidth) : 
                                           ((do_reg2 & MASK_TXOUT_DIV)            | data_txout_div);
            end 
        5'd1:    
            begin
            addr_reg <= mode ? ADDR_PCS_RSVD_ATTR : ADDR_RXOUT_DIV;
            di_reg   <= mode ? ((do_reg2 & MASK_PCS_RSVD_ATTR)  | data_pcs_rsvd_attr_m) : 
                               ((do_reg2 & MASK_RXOUT_DIV)      | data_rxout_div);
            end 
        5'd2 :
            begin        
            addr_reg <= ADDR_TX_DATA_WIDTH;
            di_reg   <= (do_reg2 & MASK_TX_DATA_WIDTH) | data_tx_data_width;
            end
        5'd3 :
            begin        
            addr_reg <= ADDR_TX_INT_DATAWIDTH;
            di_reg   <= (do_reg2 & MASK_TX_INT_DATAWIDTH) | data_tx_int_datawidth;
            end    
        5'd4 :
            begin
            addr_reg <= ADDR_RX_DATA_WIDTH;
            di_reg   <= (do_reg2 & MASK_RX_DATA_WIDTH) | data_rx_data_width;
            end   
        5'd5 :
            begin        
            addr_reg <= ADDR_RX_INT_DATAWIDTH;
            di_reg   <= (do_reg2 & MASK_RX_INT_DATAWIDTH) | data_rx_int_datawidth;
            end  
        5'd6 :
            begin        
            addr_reg <= ADDR_TXBUF_EN;
            di_reg   <= (do_reg2 & MASK_TXBUF_EN) | data_txbuf_en;
            end   
        5'd7 :
            begin        
            addr_reg <= ADDR_RXBUF_EN;
            di_reg   <= (do_reg2 & MASK_RXBUF_EN) | data_rxbuf_en;
            end   
        5'd8 :
            begin        
            addr_reg <= ADDR_TX_XCLK_SEL;
            di_reg   <= (do_reg2 & MASK_TX_XCLK_SEL) | data_tx_xclk_sel;
            end   
        5'd9 :
            begin        
            addr_reg <= ADDR_RX_XCLK_SEL;
            di_reg   <= (do_reg2 & MASK_RX_XCLK_SEL) | data_rx_xclk_sel;
            end   
        5'd10 :
            begin
            addr_reg <= ADDR_CLK_CORRECT_USE;
            di_reg   <= (do_reg2 & MASK_CLK_CORRECT_USE) | data_clk_correction_use;
            end 
        5'd11 :
            begin
            addr_reg <= ADDR_TX_DRIVE_MODE;
            di_reg   <= (do_reg2 & MASK_TX_DRIVE_MODE) | data_tx_drive_mode;
            end 
        5'd12 :
            begin
            addr_reg <= ADDR_RXCDR_EIDLE;
            di_reg   <= (do_reg2 & MASK_RXCDR_EIDLE) | data_rxcdr_eidle;
            end 
        5'd13 :
            begin
            addr_reg <= ADDR_RX_DFE_LPM_EIDLE;
            di_reg   <= (do_reg2 & MASK_RX_DFE_LPM_EIDLE) | data_rx_dfe_lpm_eidle;
            end     
        5'd14 :
            begin
            addr_reg <= ADDR_PMA_RSV_A;
            di_reg   <= (do_reg2 & MASK_PMA_RSV_A) | data_pma_rsv_a;
            end  
        5'd15 :
            begin
            addr_reg <= ADDR_PMA_RSV_B;
            di_reg   <= (do_reg2 & MASK_PMA_RSV_B) | data_pma_rsv_b;
            end 
        5'd16 :
            begin
            addr_reg <= ADDR_RXCDR_CFG_A;
            di_reg   <= (do_reg2 & MASK_RXCDR_CFG_A) | data_rxcdr_cfg_a;
            end 
        5'd17 :
            begin
            addr_reg <= ADDR_RXCDR_CFG_B;
            di_reg   <= (do_reg2 & MASK_RXCDR_CFG_B) | data_rxcdr_cfg_b;
            end 
        5'd18 :
            begin
            addr_reg <= ADDR_RXCDR_CFG_C;
            di_reg   <= (do_reg2 & MASK_RXCDR_CFG_C) | data_rxcdr_cfg_c;
            end                         
        5'd19 :
            begin
            addr_reg <= ADDR_RXCDR_CFG_D;
            di_reg   <= (do_reg2 & MASK_RXCDR_CFG_D) | data_rxcdr_cfg_d;
            end    
        5'd20 :
            begin
            addr_reg <= ADDR_RXCDR_CFG_E;
            di_reg   <= (do_reg2 & ((PCIE_GT_DEVICE == "GTH") ? MASK_RXCDR_CFG_E_GTH : MASK_RXCDR_CFG_E_GTX)) | data_rxcdr_cfg_e;
            end             
        5'd21 :
            begin
            addr_reg <= ADDR_RXCDR_CFG_F;
            di_reg   <= (do_reg2 & ((PCIE_GT_DEVICE == "GTH") ? MASK_RXCDR_CFG_F_GTH : MASK_RXCDR_CFG_F_GTX)) | data_rxcdr_cfg_f;
            end             
        default : 
            begin
            addr_reg <=  9'd0;
            di_reg   <= 16'd0;
            end
        endcase
        end
end  
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        fsm   <= FSM_IDLE;
        index <= 5'd0;
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
                index <= 5'd0;
                mode  <= 1'd0;
                done  <= 1'd0; 
                end
            else if ((gtxreset_reg2 && !gtxreset_reg1) && ((PCIE_TXSYNC_MODE == 0) || (PCIE_RXSYNC_MODE == 0)) && (PCIE_USE_MODE == "1.0"))
                begin
                fsm   <= FSM_LOAD;
                index <= 5'd0;
                mode  <= 1'd1;
                done  <= 1'd0;
                end
            else       
                begin
                fsm   <= FSM_IDLE;
                index <= 5'd0;
                mode  <= 1'd0;
                done  <= 1'd1;
                end 
            end    
        FSM_LOAD :
            begin
            fsm   <= (load_cnt == LOAD_CNT_MAX) ? FSM_READ : FSM_LOAD;
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
            fsm   <= rdy_reg2 ? FSM_WRITE : FSM_RRDY;
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
            fsm   <= rdy_reg2 ? FSM_DONE : FSM_WRDY;
            index <= index;
            mode  <= mode;
            done  <= 1'd0;
            end        
        FSM_DONE :
            begin
            if ((index == INDEX_MAX) || (mode && (index == 5'd1)) || (x16x20_mode_reg2 && (index == 5'd0)))
                begin
                fsm   <= FSM_IDLE;
                index <= 5'd0;
                mode  <= 1'd0;
                done  <= 1'd0;
                end
            else       
                begin
                fsm   <= FSM_LOAD;
                index <= index + 5'd1;
                mode  <= mode;
                done  <= 1'd0;
                end
            end     
        default :
            begin      
            fsm   <= FSM_IDLE;
            index <= 5'd0;
            mode  <= 1'd0;
            done  <= 1'd0;
            end
        endcase
        end
end 
assign DRP_ADDR = addr_reg;
assign DRP_EN   = (fsm == FSM_READ) || (fsm == FSM_WRITE);
assign DRP_DI   = di_reg;
assign DRP_WE   = (fsm == FSM_WRITE);
assign DRP_DONE = done;
assign DRP_FSM  = fsm;
endmodule
