`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_eq
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
    output              EQ_TXEQ_DEEMPH,
    output      [ 4:0]  EQ_TXEQ_PRECURSOR,
    output      [ 6:0]  EQ_TXEQ_MAINCURSOR,
    output      [ 4:0]  EQ_TXEQ_POSTCURSOR,
    output      [17:0]  EQ_TXEQ_DEEMPH_OUT,
    output              EQ_TXEQ_DONE,
    output      [ 4:0]  EQ_TXEQ_FSM,
    output      [17:0]  EQ_RXEQ_NEW_TXCOEFF,
    output              EQ_RXEQ_LFFS_SEL,
    output              EQ_RXEQ_ADAPT_DONE,
    output              EQ_RXEQ_DONE,
    output      [ 5:0]  EQ_RXEQ_FSM
);
    reg                 gen3_reg1;
    reg                 gen3_reg2;
    reg         [ 1:0]  txeq_control_reg1;
    reg         [ 3:0]  txeq_preset_reg1;
    reg         [ 5:0]  txeq_deemph_reg1;
    reg         [ 1:0]  txeq_control_reg2;
    reg			      [ 3:0]  txeq_preset_reg2;
    reg         [ 5:0]  txeq_deemph_reg2;
    reg         [ 1:0]  rxeq_control_reg1;
    reg			      [ 2:0]  rxeq_preset_reg1;
    reg         [ 5:0]  rxeq_lffs_reg1;
    reg         [ 3:0]  rxeq_txpreset_reg1;
    reg         [ 1:0]  rxeq_control_reg2;
    reg			      [ 2:0]  rxeq_preset_reg2;
    reg         [ 5:0]  rxeq_lffs_reg2;
    reg         [ 3:0]  rxeq_txpreset_reg2;
    reg         [17:0]  txeq_preset          = 18'd0;
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
    reg         [17:0]  txeq_txcoeff        = 18'd0;
    reg                 txeq_done           =  1'd0;
    reg         [ 4:0]  fsm_tx              =  5'd0;
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
    localparam          FSM_TXEQ_IDLE            = 5'b00001;
    localparam          FSM_TXEQ_PRESET          = 5'b00010;
    localparam          FSM_TXEQ_TXCOEFF         = 5'b00100;
    localparam          FSM_TXEQ_QUERY           = 5'b01000;
    localparam          FSM_TXEQ_DONE            = 5'b10000;
    localparam          FSM_RXEQ_IDLE            = 6'b000001;
    localparam          FSM_RXEQ_PRESET          = 6'b000010;
    localparam          FSM_RXEQ_TXCOEFF         = 6'b000100;
    localparam          FSM_RXEQ_LF              = 6'b001000;
    localparam          FSM_RXEQ_NEW_TXCOEFF_REQ = 6'b010000;
    localparam          FSM_RXEQ_DONE            = 6'b100000;
    localparam          TXPRECURSOR_00  = 6'd0;
    localparam          TXMAINCURSOR_00 = 6'd0;
    localparam          TXPOSTCURSOR_00 = 6'd0;
    localparam          TXPRECURSOR_01  = 6'd1;
    localparam          TXMAINCURSOR_01 = 6'd1;
    localparam          TXPOSTCURSOR_01 = 6'd1;
    localparam          TXPRECURSOR_02  = 6'd2;
    localparam          TXMAINCURSOR_02 = 6'd2;
    localparam          TXPOSTCURSOR_02 = 6'd2;
    localparam          TXPRECURSOR_03  = 6'd3;
    localparam          TXMAINCURSOR_03 = 6'd3;
    localparam          TXPOSTCURSOR_03 = 6'd3;
    localparam          TXPRECURSOR_04  = 6'd4;
    localparam          TXMAINCURSOR_04 = 6'd4;
    localparam          TXPOSTCURSOR_04 = 6'd4;
    localparam          TXPRECURSOR_05  = 6'd5;
    localparam          TXMAINCURSOR_05 = 6'd5;
    localparam          TXPOSTCURSOR_05 = 6'd5;
    localparam          TXPRECURSOR_06  = 6'd6;
    localparam          TXMAINCURSOR_06 = 6'd6;
    localparam          TXPOSTCURSOR_06 = 6'd6;
    localparam          TXPRECURSOR_07  = 6'd7;
    localparam          TXMAINCURSOR_07 = 6'd7;
    localparam          TXPOSTCURSOR_07 = 6'd7;
    localparam          TXPRECURSOR_08  = 6'd8;
    localparam          TXMAINCURSOR_08 = 6'd8;
    localparam          TXPOSTCURSOR_08 = 6'd8;
    localparam          TXPRECURSOR_09  = 6'd9;
    localparam          TXMAINCURSOR_09 = 6'd9;
    localparam          TXPOSTCURSOR_09 = 6'd9;
always @ (posedge EQ_CLK)
begin
    if (!EQ_RST_N)
        begin
        gen3_reg1          <= 1'd0;
        txeq_control_reg1  <= 2'd0;
        txeq_preset_reg1   <= 4'd0;
        txeq_deemph_reg1   <= 6'd1;
        rxeq_control_reg1  <= 2'd0;
        rxeq_preset_reg1   <= 3'd0;
        rxeq_lffs_reg1     <= 6'd0;
        rxeq_txpreset_reg1 <= 4'd0;
        gen3_reg2          <= 1'd0;
        txeq_control_reg2  <= 2'd0;
        txeq_preset_reg2   <= 4'd0;
        txeq_deemph_reg2   <= 6'd1;
        rxeq_control_reg2  <= 2'd0;
        rxeq_preset_reg2   <= 3'd0;
        rxeq_lffs_reg2     <= 6'd0;
        rxeq_txpreset_reg2 <= 4'd0;
        end
    else
        begin
        gen3_reg1          <= EQ_GEN3;
        txeq_control_reg1  <= EQ_TXEQ_CONTROL;
        txeq_preset_reg1   <= EQ_TXEQ_PRESET;
        txeq_deemph_reg1   <= EQ_TXEQ_DEEMPH_IN;
        rxeq_control_reg1  <= EQ_RXEQ_CONTROL;
        rxeq_preset_reg1   <= EQ_RXEQ_PRESET;
        rxeq_lffs_reg1     <= EQ_RXEQ_LFFS;
        rxeq_txpreset_reg1 <= EQ_RXEQ_TXPRESET;
        gen3_reg2          <= gen3_reg1;
        txeq_control_reg2  <= txeq_control_reg1;
        txeq_preset_reg2   <= txeq_preset_reg1;
        txeq_deemph_reg2   <= txeq_deemph_reg1;
        rxeq_control_reg2  <= rxeq_control_reg1;
        rxeq_preset_reg2   <= rxeq_preset_reg1;
        rxeq_lffs_reg2     <= rxeq_lffs_reg1;
        rxeq_txpreset_reg2 <= rxeq_txpreset_reg1;
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
        default : txeq_preset <= 18'd0;
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
            default : txeq_preset <= 18'd0;
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
        txeq_txcoeff     <= 18'd0;
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
                txeq_txcoeff     <= {txeq_deemph_reg2, txeq_txcoeff[17:6]};
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
            fsm_tx           <= ((txeq_txcoeff_cnt == 2'd2) ? FSM_TXEQ_DONE : FSM_TXEQ_TXCOEFF);
            txeq_txcoeff     <= {txeq_deemph_reg2, txeq_txcoeff[17:6]};
            txeq_txcoeff_cnt <= txeq_txcoeff_cnt + 2'd1;
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
            txeq_txcoeff     <= 18'd0;
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
pcie_7x_v1_3_rxeq_scan rxeq_scan_i
(
    .RXEQSCAN_CLK                       (EQ_CLK),
    .RXEQSCAN_RST_N                     (EQ_RST_N),
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
assign EQ_TXEQ_PRECURSOR   = gen3_reg2 ?        txeq_txcoeff[ 4: 0]  : 5'h00;
assign EQ_TXEQ_MAINCURSOR  = gen3_reg2 ? {1'd0, txeq_txcoeff[11: 6]} : 7'h00;
assign EQ_TXEQ_POSTCURSOR  = gen3_reg2 ?        txeq_txcoeff[16:12]  : 5'h00;
assign EQ_TXEQ_DEEMPH_OUT  = txeq_txcoeff;
assign EQ_TXEQ_DONE        = txeq_done;
assign EQ_TXEQ_FSM         = fsm_tx;
assign EQ_RXEQ_NEW_TXCOEFF = rxeq_new_txcoeff;
assign EQ_RXEQ_LFFS_SEL    = rxeq_lffs_sel;
assign EQ_RXEQ_ADAPT_DONE  = rxeq_adapt_done;
assign EQ_RXEQ_DONE        = rxeq_done;
assign EQ_RXEQ_FSM         = fsm_rx;
endmodule
