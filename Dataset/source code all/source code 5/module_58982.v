`timescale 1ps/1ps
`timescale 1ps/1ps
module pcie_7x_v1_8_pcie_pipe_misc #
(
    parameter        PIPE_PIPELINE_STAGES = 0    
)
(
    input   wire        pipe_tx_rcvr_det_i       ,     
    input   wire        pipe_tx_reset_i          ,     
    input   wire        pipe_tx_rate_i           ,     
    input   wire        pipe_tx_deemph_i         ,     
    input   wire [2:0]  pipe_tx_margin_i         ,     
    input   wire        pipe_tx_swing_i          ,     
    output  wire        pipe_tx_rcvr_det_o       ,     
    output  wire        pipe_tx_reset_o          ,     
    output  wire        pipe_tx_rate_o           ,     
    output  wire        pipe_tx_deemph_o         ,     
    output  wire [2:0]  pipe_tx_margin_o         ,     
    output  wire        pipe_tx_swing_o          ,     
    input   wire        pipe_clk                ,      
    input   wire        rst_n                          
);
    parameter TCQ  = 1;      
    reg                pipe_tx_rcvr_det_q       ;
    reg                pipe_tx_reset_q          ;
    reg                pipe_tx_rate_q           ;
    reg                pipe_tx_deemph_q         ;
    reg [2:0]          pipe_tx_margin_q         ;
    reg                pipe_tx_swing_q          ;
    reg                pipe_tx_rcvr_det_qq      ;
    reg                pipe_tx_reset_qq         ;
    reg                pipe_tx_rate_qq          ;
    reg                pipe_tx_deemph_qq        ;
    reg [2:0]          pipe_tx_margin_qq        ;
    reg                pipe_tx_swing_qq         ;
    generate
    if (PIPE_PIPELINE_STAGES == 0) begin : pipe_stages_0
        assign pipe_tx_rcvr_det_o = pipe_tx_rcvr_det_i;
        assign pipe_tx_reset_o  = pipe_tx_reset_i;
        assign pipe_tx_rate_o = pipe_tx_rate_i;
        assign pipe_tx_deemph_o = pipe_tx_deemph_i;
        assign pipe_tx_margin_o = pipe_tx_margin_i;
        assign pipe_tx_swing_o = pipe_tx_swing_i;
    end 
    else if (PIPE_PIPELINE_STAGES == 1) begin : pipe_stages_1
        always @(posedge pipe_clk) begin
        if (rst_n)
        begin
            pipe_tx_rcvr_det_q <= #TCQ 0;
            pipe_tx_reset_q  <= #TCQ 1'b1;
            pipe_tx_rate_q <= #TCQ 0;
            pipe_tx_deemph_q <= #TCQ 1'b1;
            pipe_tx_margin_q <= #TCQ 0;
            pipe_tx_swing_q <= #TCQ 0;
        end
        else
        begin
            pipe_tx_rcvr_det_q <= #TCQ pipe_tx_rcvr_det_i;
            pipe_tx_reset_q  <= #TCQ pipe_tx_reset_i;
            pipe_tx_rate_q <= #TCQ pipe_tx_rate_i;
            pipe_tx_deemph_q <= #TCQ pipe_tx_deemph_i;
            pipe_tx_margin_q <= #TCQ pipe_tx_margin_i;
            pipe_tx_swing_q <= #TCQ pipe_tx_swing_i;
          end
        end
        assign pipe_tx_rcvr_det_o = pipe_tx_rcvr_det_q;
        assign pipe_tx_reset_o  = pipe_tx_reset_q;
        assign pipe_tx_rate_o = pipe_tx_rate_q;
        assign pipe_tx_deemph_o = pipe_tx_deemph_q;
        assign pipe_tx_margin_o = pipe_tx_margin_q;
        assign pipe_tx_swing_o = pipe_tx_swing_q;
    end 
    else if (PIPE_PIPELINE_STAGES == 2) begin : pipe_stages_2
        always @(posedge pipe_clk) begin
        if (rst_n)
        begin
            pipe_tx_rcvr_det_q <= #TCQ 0;
            pipe_tx_reset_q  <= #TCQ 1'b1;
            pipe_tx_rate_q <= #TCQ 0;
            pipe_tx_deemph_q <= #TCQ 1'b1;
            pipe_tx_margin_q <= #TCQ 0;
            pipe_tx_swing_q <= #TCQ 0;
            pipe_tx_rcvr_det_qq <= #TCQ 0;
            pipe_tx_reset_qq  <= #TCQ 1'b1;
            pipe_tx_rate_qq <= #TCQ 0;
            pipe_tx_deemph_qq <= #TCQ 1'b1;
            pipe_tx_margin_qq <= #TCQ 0;
            pipe_tx_swing_qq <= #TCQ 0;
        end
        else
        begin
            pipe_tx_rcvr_det_q <= #TCQ pipe_tx_rcvr_det_i;
            pipe_tx_reset_q  <= #TCQ pipe_tx_reset_i;
            pipe_tx_rate_q <= #TCQ pipe_tx_rate_i;
            pipe_tx_deemph_q <= #TCQ pipe_tx_deemph_i;
            pipe_tx_margin_q <= #TCQ pipe_tx_margin_i;
            pipe_tx_swing_q <= #TCQ pipe_tx_swing_i;
            pipe_tx_rcvr_det_qq <= #TCQ pipe_tx_rcvr_det_q;
            pipe_tx_reset_qq  <= #TCQ pipe_tx_reset_q;
            pipe_tx_rate_qq <= #TCQ pipe_tx_rate_q;
            pipe_tx_deemph_qq <= #TCQ pipe_tx_deemph_q;
            pipe_tx_margin_qq <= #TCQ pipe_tx_margin_q;
            pipe_tx_swing_qq <= #TCQ pipe_tx_swing_q;
          end
        end
        assign pipe_tx_rcvr_det_o = pipe_tx_rcvr_det_qq;
        assign pipe_tx_reset_o  = pipe_tx_reset_qq;
        assign pipe_tx_rate_o = pipe_tx_rate_qq;
        assign pipe_tx_deemph_o = pipe_tx_deemph_qq;
        assign pipe_tx_margin_o = pipe_tx_margin_qq;
        assign pipe_tx_swing_o = pipe_tx_swing_qq;
    end 
    endgenerate
endmodule
