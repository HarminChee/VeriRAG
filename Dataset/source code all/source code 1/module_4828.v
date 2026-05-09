`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PCIEBus_pipe_eq #
(
    parameter PCIE_SIM_MODE       = "FALSE",
    parameter PCIE_GT_DEVICE      = "GTX",
    parameter PCIE_RXEQ_MODE_GEN3 = 1
)
(
    input               EQ_CLK,                            
    input               EQ_RST_N,
    input               EQ_GEN3,
    input       [ 1:0]  EQ_TXEQ_CONTROL,    
    input       [ 3:0]  EQ_TXEQ_PRESET,
    input       [ 3:0]  EQ_TXEQ_PRESET_DEFAULT,
    input       [ 5:0]  EQ_TXEQ_DEEMPH_IN,
    input       [ 1:0]  EQ_RXEQ_CONTROL,  
    input       [ 2:0]  EQ_RXEQ_PRESET,
    input       [ 5:0]  EQ_RXEQ_LFFS,  
    input       [ 3:0]  EQ_RXEQ_TXPRESET,
    input               EQ_RXEQ_USER_EN,
    input       [17:0]  EQ_RXEQ_USER_TXCOEFF,
    input               EQ_RXEQ_USER_MODE, 
    output              EQ_TXEQ_DEEMPH,
    output      [ 4:0]  EQ_TXEQ_PRECURSOR,
    output      [ 6:0]  EQ_TXEQ_MAINCURSOR,
    output      [ 4:0]  EQ_TXEQ_POSTCURSOR,
    output      [17:0]  EQ_TXEQ_DEEMPH_OUT,
    output              EQ_TXEQ_DONE,
    output      [ 5:0]  EQ_TXEQ_FSM,
    output      [17:0]  EQ_RXEQ_NEW_TXCOEFF,
    output              EQ_RXEQ_LFFS_SEL,
    output              EQ_RXEQ_ADAPT_DONE,
    output              EQ_RXEQ_DONE, 
    output      [ 5:0]  EQ_RXEQ_FSM
);          
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 gen3_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 gen3_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  txeq_control_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 3:0]  txeq_preset_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 5:0]  txeq_deemph_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  txeq_control_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg	      [ 3:0]  txeq_preset_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 5:0]  txeq_deemph_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  rxeq_control_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg	      [ 2:0]  rxeq_preset_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 5:0]  rxeq_lffs_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 3:0]  rxeq_txpreset_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxeq_user_en_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [17:0]  rxeq_user_txcoeff_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxeq_user_mode_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 1:0]  rxeq_control_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg	      [ 2:0]  rxeq_preset_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 5:0]  rxeq_lffs_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [ 3:0]  rxeq_txpreset_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxeq_user_en_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [17:0]  rxeq_user_txcoeff_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rxeq_user_mode_reg2;
    reg         [18:0]  txeq_preset          = 19'd0;          
    reg                 txeq_preset_done     =  1'd0;
    reg         [ 1:0]  txeq_txcoeff_cnt     =  2'd0;
    reg         [ 2:0]  rxeq_preset          =  3'd0;
    reg                 rxeq_preset_valid    =  1'd0;
    reg         [ 3:0]  rxeq_txpreset        =  4'd0;
    reg         [17:0]  rxeq_txcoeff         = 18'd0; 
    reg         [ 2:0]  rxeq_cnt             =  3'd0;
    reg         [ 5:0]  rxeq_fs              =  6'd0;
    reg         [ 5:0]  rxeq_lf              =  6'd0;
    reg                 rxeq_new_txcoeff_req =  1'd0;
    reg         [18:0]  txeq_txcoeff        = 19'd0;
    reg                 txeq_done           =  1'd0;
    reg         [ 5:0]  fsm_tx              =  6'd0;
    reg         [17:0]  rxeq_new_txcoeff    = 18'd0;
    reg                 rxeq_lffs_sel       =  1'd0;
    reg                 rxeq_adapt_done_reg =  1'd0;
    reg                 rxeq_adapt_done     =  1'd0;
    reg                 rxeq_done           =  1'd0; 
    reg         [ 5:0]  fsm_rx              =  6'd0;    
    wire                rxeqscan_lffs_sel;
    wire                rxeqscan_preset_done;
    wire        [17:0]  rxeqscan_new_txcoeff;
    wire                rxeqscan_new_txcoeff_done;
    wire                rxeqscan_adapt_done;
    localparam          FSM_TXEQ_IDLE            = 6'b000001; 
    localparam          FSM_TXEQ_PRESET          = 6'b000010;                                     
    localparam          FSM_TXEQ_TXCOEFF         = 6'b000100;
    localparam          FSM_TXEQ_REMAP           = 6'b001000;
    localparam          FSM_TXEQ_QUERY           = 6'b010000;                                     
    localparam          FSM_TXEQ_DONE            = 6'b100000;
    localparam          FSM_RXEQ_IDLE            = 6'b000001; 
    localparam          FSM_RXEQ_PRESET          = 6'b000010;                                     
    localparam          FSM_RXEQ_TXCOEFF         = 6'b000100;
    localparam          FSM_RXEQ_LF              = 6'b001000;
    localparam          FSM_RXEQ_NEW_TXCOEFF_REQ = 6'b010000;                                  
    localparam          FSM_RXEQ_DONE            = 6'b100000;
    localparam          TXPRECURSOR_00  = 6'd0;             
    localparam          TXMAINCURSOR_00 = 7'd60;                                
    localparam          TXPOSTCURSOR_00 = 6'd20;            
    localparam          TXPRECURSOR_01  = 6'd0;             
    localparam          TXMAINCURSOR_01 = 7'd68;            
    localparam          TXPOSTCURSOR_01 = 6'd13;            
    localparam          TXPRECURSOR_02  = 6'd0;             
    localparam          TXMAINCURSOR_02 = 7'd64;                                
    localparam          TXPOSTCURSOR_02 = 6'd16;            
    localparam          TXPRECURSOR_03  = 6'd0;             
    localparam          TXMAINCURSOR_03 = 7'd70;                                
    localparam          TXPOSTCURSOR_03 = 6'd10;            
    localparam          TXPRECURSOR_04  = 6'd0;             
    localparam          TXMAINCURSOR_04 = 7'd80;                                
    localparam          TXPOSTCURSOR_04 = 6'd0;             
    localparam          TXPRECURSOR_05  = 6'd8;             
    localparam          TXMAINCURSOR_05 = 7'd72;                                
    localparam          TXPOSTCURSOR_05 = 6'd0;             
    localparam          TXPRECURSOR_06  = 6'd10;            
    localparam          TXMAINCURSOR_06 = 7'd70;                                
    localparam          TXPOSTCURSOR_06 = 6'd0;             
    localparam          TXPRECURSOR_07  = 6'd8;             
    localparam          TXMAINCURSOR_07 = 7'd56;                                
    localparam          TXPOSTCURSOR_07 = 6'd16;            
    localparam          TXPRECURSOR_08  = 6'd10;            
    localparam          TXMAINCURSOR_08 = 7'd60;                                
    localparam          TXPOSTCURSOR_08 = 6'd10;            
    localparam          TXPRECURSOR_09  = 6'd13;            
    localparam          TXMAINCURSOR_09 = 7'd68;            
    localparam          TXPOSTCURSOR_09 = 6'd0;             
    localparam          TXPRECURSOR_10  = 6'd0;             
    localparam          TXMAINCURSOR_10 = 7'd56;            
    localparam          TXPOSTCURSOR_10 = 6'd25;            
always @ (posedge EQ_CLK)
begin
    if (!EQ_RST_N)
        begin   
        gen3_reg1              <=  1'd0;
        txeq_control_reg1      <=  2'd0;
        txeq_preset_reg1       <=  4'd0;
        txeq_deemph_reg1       <=  6'd1;
        rxeq_control_reg1      <=  2'd0;
        rxeq_preset_reg1       <=  3'd0;
        rxeq_lffs_reg1         <=  6'd0;
        rxeq_txpreset_reg1     <=  4'd0;
        rxeq_user_en_reg1      <=  1'd0;
        rxeq_user_txcoeff_reg1 <= 18'd0;
        rxeq_user_mode_reg1    <=  1'd0;
        gen3_reg2              <=  1'd0;
        txeq_control_reg2      <=  2'd0;
        txeq_preset_reg2       <=  4'd0;
        txeq_deemph_reg2       <=  6'd1;
        rxeq_control_reg2      <=  2'd0;
        rxeq_preset_reg2       <=  3'd0;
        rxeq_lffs_reg2         <=  6'd0;
        rxeq_txpreset_reg2     <=  4'd0;
        rxeq_user_en_reg2      <=  1'd0;
        rxeq_user_txcoeff_reg2 <= 18'd0;
        rxeq_user_mode_reg2    <=  1'd0;
        end
    else
        begin  
        gen3_reg1              <= EQ_GEN3;
        txeq_control_reg1      <= EQ_TXEQ_CONTROL;
        txeq_preset_reg1       <= EQ_TXEQ_PRESET;
        txeq_deemph_reg1       <= EQ_TXEQ_DEEMPH_IN;
        rxeq_control_reg1      <= EQ_RXEQ_CONTROL;
        rxeq_preset_reg1       <= EQ_RXEQ_PRESET;
        rxeq_lffs_reg1         <= EQ_RXEQ_LFFS;
        rxeq_txpreset_reg1     <= EQ_RXEQ_TXPRESET;
        rxeq_user_en_reg1      <= EQ_RXEQ_USER_EN;
        rxeq_user_txcoeff_reg1 <= EQ_RXEQ_USER_TXCOEFF;
        rxeq_user_mode_reg1    <= EQ_RXEQ_USER_MODE;
        gen3_reg2              <= gen3_reg1;
        txeq_control_reg2      <= txeq_control_reg1;
        txeq_preset_reg2       <= txeq_preset_reg1;
        txeq_deemph_reg2       <= txeq_deemph_reg1;
        rxeq_control_reg2      <= rxeq_control_reg1;
        rxeq_preset_reg2       <= rxeq_preset_reg1;
        rxeq_lffs_reg2         <= rxeq_lffs_reg1;
        rxeq_txpreset_reg2     <= rxeq_txpreset_reg1;
        rxeq_user_en_reg2      <= rxeq_user_en_reg1;
        rxeq_user_txcoeff_reg2 <= rxeq_user_txcoeff_reg1;
        rxeq_user_mode_reg2    <= rxeq_user_mode_reg1;
        end
end       
always @ (posedge EQ_CLK)
begin
    if (!EQ_RST_N)
        begin
        case (EQ_TXEQ_PRESET_DEFAULT)
        4'd0    : txeq_preset <= {TXPOSTCURSOR_00, TXMAINCURSOR_00, TXPRECURSOR_00};
        4'd1    : txeq_preset <= {TXPOSTCURSOR_01, TXMAINCURSOR_01, TXPRECURSOR_01};
        4'd2    : txeq_preset <= {TXPOSTCURSOR_02, TXMAINCURSOR_02, TXPRECURSOR_02};
        4'd3    : txeq_preset <= {TXPOSTCURSOR_03, TXMAINCURSOR_03, TXPRECURSOR_03};
        4'd4    : txeq_preset <= {TXPOSTCURSOR_04, TXMAINCURSOR_04, TXPRECURSOR_04};
        4'd5    : txeq_preset <= {TXPOSTCURSOR_05, TXMAINCURSOR_05, TXPRECURSOR_05};
        4'd6    : txeq_preset <= {TXPOSTCURSOR_06, TXMAINCURSOR_06, TXPRECURSOR_06};
        4'd7    : txeq_preset <= {TXPOSTCURSOR_07, TXMAINCURSOR_07, TXPRECURSOR_07};
        4'd8    : txeq_preset <= {TXPOSTCURSOR_08, TXMAINCURSOR_08, TXPRECURSOR_08};      
        4'd9    : txeq_preset <= {TXPOSTCURSOR_09, TXMAINCURSOR_09, TXPRECURSOR_09};   
        4'd10   : txeq_preset <= {TXPOSTCURSOR_10, TXMAINCURSOR_10, TXPRECURSOR_10};                 
        default : txeq_preset <= 19'd4;     
        endcase
        txeq_preset_done <=  1'd0;
        end                    
    else
        begin   
        if (fsm_tx == FSM_TXEQ_PRESET)
            begin
            case (txeq_preset_reg2)
            4'd0    : txeq_preset <= {TXPOSTCURSOR_00, TXMAINCURSOR_00, TXPRECURSOR_00};
            4'd1    : txeq_preset <= {TXPOSTCURSOR_01, TXMAINCURSOR_01, TXPRECURSOR_01};
            4'd2    : txeq_preset <= {TXPOSTCURSOR_02, TXMAINCURSOR_02, TXPRECURSOR_02};
            4'd3    : txeq_preset <= {TXPOSTCURSOR_03, TXMAINCURSOR_03, TXPRECURSOR_03};
            4'd4    : txeq_preset <= {TXPOSTCURSOR_04, TXMAINCURSOR_04, TXPRECURSOR_04};
            4'd5    : txeq_preset <= {TXPOSTCURSOR_05, TXMAINCURSOR_05, TXPRECURSOR_05};
            4'd6    : txeq_preset <= {TXPOSTCURSOR_06, TXMAINCURSOR_06, TXPRECURSOR_06};
            4'd7    : txeq_preset <= {TXPOSTCURSOR_07, TXMAINCURSOR_07, TXPRECURSOR_07};
            4'd8    : txeq_preset <= {TXPOSTCURSOR_08, TXMAINCURSOR_08, TXPRECURSOR_08};      
            4'd9    : txeq_preset <= {TXPOSTCURSOR_09, TXMAINCURSOR_09, TXPRECURSOR_09}; 
            4'd10   : txeq_preset <= {TXPOSTCURSOR_10, TXMAINCURSOR_10, TXPRECURSOR_10};                   
            default : txeq_preset <= 19'd4;     
        	   endcase
            txeq_preset_done <= 1'd1;
            end
        else
            begin
            txeq_preset      <= txeq_preset;
            txeq_preset_done <= 1'd0;
            end
        end
end     
always @ (posedge EQ_CLK)
begin
    if (!EQ_RST_N)
        begin
        fsm_tx           <=  FSM_TXEQ_IDLE; 
        txeq_txcoeff     <= 19'd0;
        txeq_txcoeff_cnt <=  2'd0;
        txeq_done        <=  1'd0;
        end                    
    else
        begin
        case (fsm_tx)
        FSM_TXEQ_IDLE :
            begin
            case (txeq_control_reg2)
            2'd0    :
                begin
                fsm_tx           <= FSM_TXEQ_IDLE; 
                txeq_txcoeff     <= txeq_txcoeff;
                txeq_txcoeff_cnt <= 2'd0;
                txeq_done        <= 1'd0;
                end 
            2'd1    :
                begin
                fsm_tx           <= FSM_TXEQ_PRESET; 
                txeq_txcoeff     <= txeq_txcoeff;
                txeq_txcoeff_cnt <= 2'd0;
                txeq_done        <= 1'd0;
                end  
            2'd2    :
                begin
                fsm_tx           <= FSM_TXEQ_TXCOEFF; 
                txeq_txcoeff     <= {txeq_deemph_reg2, txeq_txcoeff[18:6]};
                txeq_txcoeff_cnt <= 2'd1;
                txeq_done        <= 1'd0;
                end
            2'd3    :
                begin
                fsm_tx           <= FSM_TXEQ_QUERY; 
                txeq_txcoeff     <= txeq_txcoeff;
                txeq_txcoeff_cnt <= 2'd0;
                txeq_done        <= 1'd0;
                end
            default :
                begin
                fsm_tx           <= FSM_TXEQ_IDLE; 
                txeq_txcoeff     <= txeq_txcoeff;
                txeq_txcoeff_cnt <= 2'd0;
                txeq_done        <= 1'd0;
                end
            endcase
            end
        FSM_TXEQ_PRESET :
            begin
            fsm_tx           <= (txeq_preset_done ? FSM_TXEQ_DONE : FSM_TXEQ_PRESET);
            txeq_txcoeff     <= txeq_preset;
            txeq_txcoeff_cnt <= 2'd0;
            txeq_done        <= 1'd0;
            end    
        FSM_TXEQ_TXCOEFF :
            begin
            fsm_tx <= ((txeq_txcoeff_cnt == 2'd2) ? FSM_TXEQ_REMAP : FSM_TXEQ_TXCOEFF);
            if (txeq_txcoeff_cnt == 2'd1)
                txeq_txcoeff <= {1'd0, txeq_deemph_reg2, txeq_txcoeff[18:7]};
            else
                txeq_txcoeff <= {txeq_deemph_reg2, txeq_txcoeff[18:6]};
            txeq_txcoeff_cnt <= txeq_txcoeff_cnt + 2'd1;
            txeq_done        <= 1'd0; 
            end
        FSM_TXEQ_REMAP :
            begin
            fsm_tx           <= FSM_TXEQ_DONE;
            txeq_txcoeff     <= txeq_txcoeff << 1;          
            txeq_txcoeff_cnt <= 2'd0;
            txeq_done        <= 1'd0; 
            end
        FSM_TXEQ_QUERY:
            begin
            fsm_tx           <= FSM_TXEQ_DONE;
            txeq_txcoeff     <= txeq_txcoeff; 
            txeq_txcoeff_cnt <= 2'd0;
            txeq_done        <= 1'd0;
            end     
        FSM_TXEQ_DONE :
            begin
            fsm_tx           <= ((txeq_control_reg2 == 2'd0) ? FSM_TXEQ_IDLE : FSM_TXEQ_DONE);
            txeq_txcoeff     <= txeq_txcoeff;          
            txeq_txcoeff_cnt <= 2'd0;
            txeq_done        <= 1'd1;
            end        
        default : 
            begin
            fsm_tx           <=  FSM_TXEQ_IDLE;
            txeq_txcoeff     <= 19'd0;
            txeq_txcoeff_cnt <=  2'd0;
            txeq_done        <=  1'd0;
            end    
        endcase
        end
end  
always @ (posedge EQ_CLK)
begin
    if (!EQ_RST_N)
        begin
        fsm_rx               <= FSM_RXEQ_IDLE; 
        rxeq_preset          <=  3'd0;
        rxeq_preset_valid    <=  1'd0;
        rxeq_txpreset        <=  4'd0;
        rxeq_txcoeff         <= 18'd0; 
        rxeq_cnt             <=  3'd0;
        rxeq_fs              <=  6'd0;
        rxeq_lf              <=  6'd0;
        rxeq_new_txcoeff_req <=  1'd0; 
        rxeq_new_txcoeff     <= 18'd0;
        rxeq_lffs_sel        <=  1'd0;
        rxeq_adapt_done_reg  <=  1'd0;
        rxeq_adapt_done      <=  1'd0;   
        rxeq_done            <=  1'd0; 
        end                    
    else
        begin
        case (fsm_rx)
        FSM_RXEQ_IDLE :
            begin
            case (rxeq_control_reg2)
            2'd1 :
                begin
                fsm_rx               <= FSM_RXEQ_PRESET; 
                rxeq_preset          <= rxeq_preset_reg2;
                rxeq_preset_valid    <= 1'd0;
                rxeq_txpreset        <= rxeq_txpreset;
                rxeq_txcoeff         <= rxeq_txcoeff;
                rxeq_cnt             <= 3'd0;
                rxeq_fs              <= rxeq_fs;
                rxeq_lf              <= rxeq_lf;
                rxeq_new_txcoeff_req <= 1'd0;
                rxeq_new_txcoeff     <= rxeq_new_txcoeff;
                rxeq_lffs_sel        <= 1'd0;
                rxeq_adapt_done_reg  <= 1'd0;
                rxeq_adapt_done      <= 1'd0;
                rxeq_done            <= 1'd0; 
                end  
            2'd2 :
                begin
                fsm_rx               <= FSM_RXEQ_TXCOEFF; 
                rxeq_preset          <= rxeq_preset;
                rxeq_preset_valid    <= 1'd0;
                rxeq_txpreset        <= rxeq_txpreset_reg2;
                rxeq_txcoeff         <= {txeq_deemph_reg2, rxeq_txcoeff[17:6]};
                rxeq_cnt             <= 3'd1;
                rxeq_fs              <= rxeq_lffs_reg2;
                rxeq_lf              <= rxeq_lf;
                rxeq_new_txcoeff_req <= 1'd0;
                rxeq_new_txcoeff     <= rxeq_new_txcoeff;
                rxeq_lffs_sel        <= 1'd0;
                rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
                rxeq_adapt_done      <= 1'd0;
                rxeq_done            <= 1'd0; 
                end
            2'd3 :
                begin
                fsm_rx               <= FSM_RXEQ_TXCOEFF; 
                rxeq_preset          <= rxeq_preset;
                rxeq_preset_valid    <= 1'd0;
                rxeq_txpreset        <= rxeq_txpreset_reg2;
                rxeq_txcoeff         <= {txeq_deemph_reg2, rxeq_txcoeff[17:6]};
                rxeq_cnt             <= 3'd1;
                rxeq_fs              <= rxeq_lffs_reg2;
                rxeq_lf              <= rxeq_lf;
                rxeq_new_txcoeff_req <= 1'd0;
                rxeq_new_txcoeff     <= rxeq_new_txcoeff;
                rxeq_lffs_sel        <= 1'd0;
                rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
                rxeq_adapt_done      <= 1'd0;
                rxeq_done            <= 1'd0; 
                end
            default :
                begin
                fsm_rx               <= FSM_RXEQ_IDLE; 
                rxeq_preset          <= rxeq_preset;
                rxeq_preset_valid    <= 1'd0;
                rxeq_txpreset        <= rxeq_txpreset;
                rxeq_txcoeff         <= rxeq_txcoeff;
                rxeq_cnt             <= 3'd0;
                rxeq_fs              <= rxeq_fs;
                rxeq_lf              <= rxeq_lf;
                rxeq_new_txcoeff_req <= 1'd0;
                rxeq_new_txcoeff     <= rxeq_new_txcoeff;
                rxeq_lffs_sel        <= 1'd0;
                rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
                rxeq_adapt_done      <= 1'd0;
                rxeq_done            <= 1'd0; 
                end
            endcase
            end
        FSM_RXEQ_PRESET :
            begin
            fsm_rx               <= (rxeqscan_preset_done ? FSM_RXEQ_DONE : FSM_RXEQ_PRESET);
            rxeq_preset          <= rxeq_preset_reg2;
            rxeq_preset_valid    <= 1'd1; 
            rxeq_txpreset        <= rxeq_txpreset;
            rxeq_txcoeff         <= rxeq_txcoeff; 
            rxeq_cnt             <= 3'd0;
            rxeq_fs              <= rxeq_fs;
            rxeq_lf              <= rxeq_lf;
            rxeq_new_txcoeff_req <= 1'd0;
            rxeq_new_txcoeff     <= rxeq_new_txcoeff;
            rxeq_lffs_sel        <= 1'd0;
            rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
            rxeq_adapt_done      <= 1'd0;
            rxeq_done            <= 1'd0; 
            end    
        FSM_RXEQ_TXCOEFF :
            begin
            fsm_rx               <= ((rxeq_cnt == 3'd2) ? FSM_RXEQ_LF : FSM_RXEQ_TXCOEFF);
            rxeq_preset          <= rxeq_preset;
            rxeq_preset_valid    <= 1'd0; 
            rxeq_txpreset        <= rxeq_txpreset_reg2;
            rxeq_txcoeff         <= {txeq_deemph_reg2, rxeq_txcoeff[17:6]}; 
            rxeq_cnt             <= rxeq_cnt + 2'd1;
            rxeq_fs              <= rxeq_fs;
            rxeq_lf              <= rxeq_lf;
            rxeq_new_txcoeff_req <= 1'd0;
            rxeq_new_txcoeff     <= rxeq_new_txcoeff;
            rxeq_lffs_sel        <= 1'd1;
            rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
            rxeq_adapt_done      <= 1'd0;
            rxeq_done            <= 1'd0; 
            end
        FSM_RXEQ_LF :
            begin
            fsm_rx               <= ((rxeq_cnt == 3'd7) ? FSM_RXEQ_NEW_TXCOEFF_REQ : FSM_RXEQ_LF);
            rxeq_preset          <= rxeq_preset;
            rxeq_preset_valid    <= 1'd0; 
            rxeq_txpreset        <= rxeq_txpreset;
            rxeq_txcoeff         <= rxeq_txcoeff; 
            rxeq_cnt             <= rxeq_cnt + 2'd1;
            rxeq_fs              <= rxeq_fs;
            rxeq_lf              <= ((rxeq_cnt == 3'd7) ? rxeq_lffs_reg2 : rxeq_lf);
            rxeq_new_txcoeff_req <= 1'd0;
            rxeq_new_txcoeff     <= rxeq_new_txcoeff;
            rxeq_lffs_sel        <= 1'd1;
            rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
            rxeq_adapt_done      <= 1'd0;
            rxeq_done            <= 1'd0; 
            end
        FSM_RXEQ_NEW_TXCOEFF_REQ :
            begin            
            rxeq_preset          <= rxeq_preset;
            rxeq_preset_valid    <= 1'd0; 
            rxeq_txpreset        <= rxeq_txpreset;
            rxeq_txcoeff         <= rxeq_txcoeff; 
            rxeq_cnt             <= 3'd0;
            rxeq_fs              <= rxeq_fs;
            rxeq_lf              <= rxeq_lf;
            if (rxeqscan_new_txcoeff_done)
                begin
                fsm_rx               <= FSM_RXEQ_DONE;
                rxeq_new_txcoeff_req <= 1'd0;
                rxeq_new_txcoeff     <= rxeqscan_lffs_sel ? {14'd0, rxeqscan_new_txcoeff[3:0]} : rxeqscan_new_txcoeff;
                rxeq_lffs_sel        <= rxeqscan_lffs_sel;
                rxeq_adapt_done_reg  <= rxeqscan_adapt_done || rxeq_adapt_done_reg;
                rxeq_adapt_done      <= rxeqscan_adapt_done || rxeq_adapt_done_reg;
                rxeq_done            <= 1'd1; 
                end
            else
                begin
                fsm_rx               <= FSM_RXEQ_NEW_TXCOEFF_REQ;
                rxeq_new_txcoeff_req <= 1'd1;
                rxeq_new_txcoeff     <= rxeq_new_txcoeff;
                rxeq_lffs_sel        <= 1'd0;
                rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
                rxeq_adapt_done      <= 1'd0;
                rxeq_done            <= 1'd0; 
                end
            end     
        FSM_RXEQ_DONE :
            begin
            fsm_rx               <= ((rxeq_control_reg2 == 2'd0) ? FSM_RXEQ_IDLE : FSM_RXEQ_DONE);
            rxeq_preset          <= rxeq_preset;
            rxeq_preset_valid    <= 1'd0;
            rxeq_txpreset        <= rxeq_txpreset; 
            rxeq_txcoeff         <= rxeq_txcoeff;
            rxeq_cnt             <= 3'd0;
            rxeq_fs              <= rxeq_fs;
            rxeq_lf              <= rxeq_lf;
            rxeq_new_txcoeff_req <= 1'd0;
            rxeq_new_txcoeff     <= rxeq_new_txcoeff;
            rxeq_lffs_sel        <= rxeq_lffs_sel;
            rxeq_adapt_done_reg  <= rxeq_adapt_done_reg;
            rxeq_adapt_done      <= rxeq_adapt_done;  
            rxeq_done            <= 1'd1; 
            end        
        default : 
            begin
            fsm_rx               <= FSM_RXEQ_IDLE;
            rxeq_preset          <=  3'd0;
            rxeq_preset_valid    <=  1'd0;
            rxeq_txpreset        <=  4'd0;
            rxeq_txcoeff         <= 18'd0;
            rxeq_cnt             <=  3'd0;
            rxeq_fs              <=  6'd0;
            rxeq_lf              <=  6'd0;
            rxeq_new_txcoeff_req <=  1'd0;
            rxeq_new_txcoeff     <= 18'd0;
            rxeq_lffs_sel        <=  1'd0;
            rxeq_adapt_done_reg  <=  1'd0;
            rxeq_adapt_done      <=  1'd0;
            rxeq_done            <=  1'd0;   
            end    
    	   endcase
        end
end      
PCIEBus_rxeq_scan #
(
    .PCIE_SIM_MODE                      (PCIE_SIM_MODE),
    .PCIE_GT_DEVICE                     (PCIE_GT_DEVICE),
    .PCIE_RXEQ_MODE_GEN3                (PCIE_RXEQ_MODE_GEN3)
)
rxeq_scan_i
(
    .RXEQSCAN_CLK                       (EQ_CLK),
    .RXEQSCAN_RST_N                     (EQ_RST_N),
    .RXEQSCAN_CONTROL                   (rxeq_control_reg2),
    .RXEQSCAN_FS                        (rxeq_fs),      
    .RXEQSCAN_LF                        (rxeq_lf), 
    .RXEQSCAN_PRESET                    (rxeq_preset),
    .RXEQSCAN_PRESET_VALID              (rxeq_preset_valid),   
    .RXEQSCAN_TXPRESET                  (rxeq_txpreset),
    .RXEQSCAN_TXCOEFF                   (rxeq_txcoeff),    
    .RXEQSCAN_NEW_TXCOEFF_REQ           (rxeq_new_txcoeff_req),                
    .RXEQSCAN_PRESET_DONE               (rxeqscan_preset_done),
    .RXEQSCAN_NEW_TXCOEFF               (rxeqscan_new_txcoeff),
    .RXEQSCAN_NEW_TXCOEFF_DONE          (rxeqscan_new_txcoeff_done),
    .RXEQSCAN_LFFS_SEL                  (rxeqscan_lffs_sel),
    .RXEQSCAN_ADAPT_DONE                (rxeqscan_adapt_done)
); 
assign EQ_TXEQ_DEEMPH      = txeq_txcoeff[0];       
assign EQ_TXEQ_PRECURSOR   = gen3_reg2 ? txeq_txcoeff[ 4: 0] : 5'h00;
assign EQ_TXEQ_MAINCURSOR  = gen3_reg2 ? txeq_txcoeff[12: 6] : 7'h00; 
assign EQ_TXEQ_POSTCURSOR  = gen3_reg2 ? txeq_txcoeff[17:13] : 5'h00;
assign EQ_TXEQ_DEEMPH_OUT  = {1'd0, txeq_txcoeff[18:14], txeq_txcoeff[12:7], 1'd0, txeq_txcoeff[5:1]}; 
assign EQ_TXEQ_DONE        = txeq_done;
assign EQ_TXEQ_FSM         = fsm_tx;
assign EQ_RXEQ_NEW_TXCOEFF = rxeq_user_en_reg2 ? rxeq_user_txcoeff_reg2 : rxeq_new_txcoeff;
assign EQ_RXEQ_LFFS_SEL    = rxeq_user_en_reg2 ? rxeq_user_mode_reg2    : rxeq_lffs_sel;
assign EQ_RXEQ_ADAPT_DONE  = rxeq_adapt_done;
assign EQ_RXEQ_DONE        = rxeq_done;
assign EQ_RXEQ_FSM         = fsm_rx;
endmodule
