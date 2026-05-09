`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_8_rxeq_scan #
(
    parameter PCIE_SIM_MODE       = "FALSE",                
    parameter PCIE_RXEQ_MODE_GEN3 = 1,                      
    parameter CONVERGE_MAX        = 22'd3125000             
)
(
    input               RXEQSCAN_CLK,                      
    input               RXEQSCAN_RST_N,
    input       [ 1:0]  RXEQSCAN_CONTROL,   
    input       [ 2:0]  RXEQSCAN_PRESET,
    input               RXEQSCAN_PRESET_VALID,
    input       [ 3:0]  RXEQSCAN_TXPRESET,
    input       [17:0]  RXEQSCAN_TXCOEFF,
    input               RXEQSCAN_NEW_TXCOEFF_REQ,
    input       [ 5:0]  RXEQSCAN_FS,
    input       [ 5:0]  RXEQSCAN_LF,
    output              RXEQSCAN_PRESET_DONE,
    output      [17:0]  RXEQSCAN_NEW_TXCOEFF,
    output              RXEQSCAN_NEW_TXCOEFF_DONE,
    output              RXEQSCAN_LFFS_SEL,
    output              RXEQSCAN_ADAPT_DONE
);
    reg         [ 2:0]  preset_reg1;
    reg                 preset_valid_reg1;
    reg         [ 3:0]  txpreset_reg1;
    reg         [17:0]  txcoeff_reg1;
    reg                 new_txcoeff_req_reg1;
    reg         [ 5:0]  fs_reg1;
    reg         [ 5:0]  lf_reg1;
    reg         [ 2:0]  preset_reg2;
    reg                 preset_valid_reg2;
    reg         [ 3:0]  txpreset_reg2;
    reg         [17:0]  txcoeff_reg2;
    reg                 new_txcoeff_req_reg2;
    reg         [ 5:0]  fs_reg2;
    reg         [ 5:0]  lf_reg2;
    reg                 adapt_done_cnt = 1'd0;
    reg                 preset_done      =  1'd0;
    reg         [21:0]  converge_cnt     = 22'd0;
    reg         [17:0]  new_txcoeff      = 18'd0;
    reg                 new_txcoeff_done =  1'd0;
    reg                 lffs_sel         =  1'd0;
    reg                 adapt_done       =  1'd0;
    reg         [ 3:0]  fsm              =  4'd0;
    localparam          FSM_IDLE            = 4'b0001;
    localparam          FSM_PRESET          = 4'b0010;
    localparam          FSM_CONVERGE        = 4'b0100;
    localparam          FSM_NEW_TXCOEFF_REQ = 4'b1000; 
    localparam converge_max_cnt = (PCIE_SIM_MODE == "TRUE") ? 22'd1000 : CONVERGE_MAX;   
always @ (posedge RXEQSCAN_CLK)
begin
    if (!RXEQSCAN_RST_N)
        begin   
        preset_reg1          <=  3'd0;
        preset_valid_reg1    <=  1'd0;
        txpreset_reg1        <=  4'd0;
        txcoeff_reg1         <= 18'd0;
        new_txcoeff_req_reg1 <=  1'd0;
        fs_reg1              <=  6'd0;
        lf_reg1              <=  6'd0;
        preset_reg2          <=  3'd0;
        preset_valid_reg2    <=  1'd0;
        txpreset_reg2        <=  4'd0;
        txcoeff_reg2         <= 18'd0;
        new_txcoeff_req_reg2 <=  1'd0;
        fs_reg2              <=  6'd0;
        lf_reg2              <=  6'd0;
        end
    else
        begin  
        preset_reg1          <= RXEQSCAN_PRESET;
        preset_valid_reg1    <= RXEQSCAN_PRESET_VALID;
        txpreset_reg1        <= RXEQSCAN_TXPRESET;
        txcoeff_reg1         <= RXEQSCAN_TXCOEFF;
        new_txcoeff_req_reg1 <= RXEQSCAN_NEW_TXCOEFF_REQ;
        fs_reg1              <= RXEQSCAN_FS;
        lf_reg1              <= RXEQSCAN_LF;
        preset_reg2          <= preset_reg1;
        preset_valid_reg2    <= preset_valid_reg1;
        txpreset_reg2        <= txpreset_reg1;
        txcoeff_reg2         <= txcoeff_reg1;
        new_txcoeff_req_reg2 <= new_txcoeff_req_reg1;
        fs_reg2              <= fs_reg1;
        lf_reg2              <= lf_reg1;
        end
end     
always @ (posedge RXEQSCAN_CLK)
begin
    if (!RXEQSCAN_RST_N)
        begin
        fsm              <=  FSM_IDLE;
        preset_done      <=  1'd0;
        converge_cnt     <= 22'd0;
        new_txcoeff      <= 18'd0;
        new_txcoeff_done <=  1'd0;
        lffs_sel         <=  1'd0;
        adapt_done       <=  1'd0;
        adapt_done_cnt   <=  1'd0;
        end                   
    else
        begin
        case (fsm)
        FSM_IDLE : 
            begin   
            if (preset_valid_reg2)
                begin
                fsm              <=  FSM_PRESET;
                preset_done      <=  1'd1;
                converge_cnt     <= 22'd0;
                new_txcoeff      <=  new_txcoeff;
                new_txcoeff_done <=  1'd0;
                lffs_sel         <=  1'd0;
                adapt_done       <=  1'd0;
                adapt_done_cnt   <=  adapt_done_cnt;
                end            
            else if (new_txcoeff_req_reg2)
                begin
                fsm              <=  FSM_CONVERGE;
                preset_done      <=  1'd0;
                converge_cnt     <= 22'd0;
                new_txcoeff      <= (PCIE_RXEQ_MODE_GEN3 == 0) ? txcoeff_reg2 : 18'd4;
                new_txcoeff_done <=  1'd0;
                lffs_sel         <= (PCIE_RXEQ_MODE_GEN3 == 0) ? 1'd0 : 1'd1;
                adapt_done       <=  1'd0; 
                adapt_done_cnt   <=  adapt_done_cnt;
                end  
            else
                begin
                fsm              <=  FSM_IDLE;
                preset_done      <=  1'd0;
                converge_cnt     <= 22'd0;
                new_txcoeff      <=  new_txcoeff;
                new_txcoeff_done <=  1'd0;
                lffs_sel         <=  1'd0;
                adapt_done       <=  1'd0;
                adapt_done_cnt   <=  adapt_done_cnt;
                end
            end
        FSM_PRESET :
            begin
            fsm              <= (!preset_valid_reg2) ? FSM_IDLE : FSM_PRESET;
            preset_done      <=  1'd1;
            converge_cnt     <= 22'd0;
            new_txcoeff      <=  new_txcoeff;
            new_txcoeff_done <=  1'd0;
            lffs_sel         <=  1'd0;
            adapt_done       <=  1'd0;
            adapt_done_cnt   <=  adapt_done_cnt;
            end
        FSM_CONVERGE :
            begin
            if ((adapt_done_cnt == 1'd0) && (RXEQSCAN_CONTROL == 2'd2))
                begin
                fsm              <= FSM_NEW_TXCOEFF_REQ;
                preset_done      <=  1'd0;
                converge_cnt     <= 22'd0;
                new_txcoeff      <= new_txcoeff;
                new_txcoeff_done <= 1'd0;
                lffs_sel         <= lffs_sel;
                adapt_done       <= 1'd0;
                adapt_done_cnt   <= adapt_done_cnt;
                end
            else
                begin
                fsm              <= (converge_cnt == converge_max_cnt) ? FSM_NEW_TXCOEFF_REQ : FSM_CONVERGE;
                preset_done      <= 1'd0;
                converge_cnt     <= converge_cnt + 1'd1;
                new_txcoeff      <= new_txcoeff;
                new_txcoeff_done <= 1'd0;
                lffs_sel         <= lffs_sel;
                adapt_done       <= 1'd0;
                adapt_done_cnt   <= adapt_done_cnt;
                end
            end
        FSM_NEW_TXCOEFF_REQ :
            begin 
            if (!new_txcoeff_req_reg2)
                begin
                fsm              <= FSM_IDLE;
                preset_done      <=  1'd0;
                converge_cnt     <= 22'd0;
                new_txcoeff      <= new_txcoeff;
                new_txcoeff_done <= 1'd0;
                lffs_sel         <= lffs_sel;
                adapt_done       <= 1'd0;
                adapt_done_cnt   <= (RXEQSCAN_CONTROL == 2'd3) ? 1'd0 : adapt_done_cnt + 1'd1;
                end
            else
                begin
                fsm              <= FSM_NEW_TXCOEFF_REQ;
                preset_done      <=  1'd0;
                converge_cnt     <= 22'd0;
                new_txcoeff      <= new_txcoeff;
                new_txcoeff_done <= 1'd1;
                lffs_sel         <= lffs_sel;
                adapt_done       <= (adapt_done_cnt == 1'd1) || (RXEQSCAN_CONTROL == 2'd3);
                adapt_done_cnt   <= adapt_done_cnt;
                end
            end
        default :
            begin
            fsm              <=  FSM_IDLE;
            preset_done      <=  1'd0;
            converge_cnt     <= 22'd0;
            new_txcoeff      <= 18'd0;
            new_txcoeff_done <=  1'd0;
            lffs_sel         <=  1'd0;
            adapt_done       <=  1'd0;
            adapt_done_cnt   <=  1'd0;
            end    
        endcase
        end
end
assign RXEQSCAN_PRESET_DONE      = preset_done;     
assign RXEQSCAN_NEW_TXCOEFF      = new_txcoeff;
assign RXEQSCAN_NEW_TXCOEFF_DONE = new_txcoeff_done; 
assign RXEQSCAN_LFFS_SEL         = lffs_sel;  
assign RXEQSCAN_ADAPT_DONE       = adapt_done;
endmodule
