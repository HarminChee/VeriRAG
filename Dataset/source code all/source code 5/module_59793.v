`timescale 1ns/1ns
`timescale 1ns/1ns
module pcie_pipe_lane_v6 #
(
    parameter        PIPE_PIPELINE_STAGES = 0    
)
(
    output  wire [ 1:0] pipe_rx_char_is_k_o     ,
    output  wire [15:0] pipe_rx_data_o         ,
    output  wire        pipe_rx_valid_o         ,
    output  wire        pipe_rx_chanisaligned_o ,
    output  wire [ 2:0] pipe_rx_status_o        ,
    output  wire        pipe_rx_phy_status_o    ,
    output  wire        pipe_rx_elec_idle_o     ,
    input   wire        pipe_rx_polarity_i      ,
    input   wire        pipe_tx_compliance_i    ,
    input   wire [ 1:0] pipe_tx_char_is_k_i     ,
    input   wire [15:0] pipe_tx_data_i          ,
    input   wire        pipe_tx_elec_idle_i     ,
    input   wire [ 1:0] pipe_tx_powerdown_i     , 
    input  wire [ 1:0]  pipe_rx_char_is_k_i     ,
    input  wire [15:0]  pipe_rx_data_i         ,
    input  wire         pipe_rx_valid_i         ,
    input  wire         pipe_rx_chanisaligned_i ,
    input  wire [ 2:0]  pipe_rx_status_i        ,
    input  wire         pipe_rx_phy_status_i    ,
    input  wire         pipe_rx_elec_idle_i     ,
    output wire         pipe_rx_polarity_o      ,
    output wire         pipe_tx_compliance_o    ,
    output wire [ 1:0]  pipe_tx_char_is_k_o     ,
    output wire [15:0]  pipe_tx_data_o          ,
    output wire         pipe_tx_elec_idle_o     ,
    output wire [ 1:0]  pipe_tx_powerdown_o     , 
    input   wire        pipe_clk                , 
    input   wire        rst_n 
);
    parameter TCQ  = 1;      
    reg [ 1:0]          pipe_rx_char_is_k_q     ;
    reg [15:0]          pipe_rx_data_q          ;
    reg                 pipe_rx_valid_q         ;
    reg                 pipe_rx_chanisaligned_q ;
    reg [ 2:0]          pipe_rx_status_q        ;
    reg                 pipe_rx_phy_status_q    ;
    reg                 pipe_rx_elec_idle_q     ;
    reg                 pipe_rx_polarity_q      ;
    reg                 pipe_tx_compliance_q    ;
    reg [ 1:0]          pipe_tx_char_is_k_q     ;
    reg [15:0]          pipe_tx_data_q          ;
    reg                 pipe_tx_elec_idle_q     ;
    reg [ 1:0]          pipe_tx_powerdown_q     ; 
    reg [ 1:0]          pipe_rx_char_is_k_qq    ;
    reg [15:0]          pipe_rx_data_qq         ;
    reg                 pipe_rx_valid_qq        ;
    reg                 pipe_rx_chanisaligned_qq;
    reg [ 2:0]          pipe_rx_status_qq       ;
    reg                 pipe_rx_phy_status_qq   ;
    reg                 pipe_rx_elec_idle_qq    ;
    reg                 pipe_rx_polarity_qq     ;
    reg                 pipe_tx_compliance_qq   ;
    reg [ 1:0]          pipe_tx_char_is_k_qq    ;
    reg [15:0]          pipe_tx_data_qq         ;
    reg                 pipe_tx_elec_idle_qq    ;
    reg [ 1:0]          pipe_tx_powerdown_qq    ; 
    generate
      if (PIPE_PIPELINE_STAGES == 0) begin
        assign pipe_rx_char_is_k_o = pipe_rx_char_is_k_i;
        assign pipe_rx_data_o = pipe_rx_data_i;
        assign pipe_rx_valid_o = pipe_rx_valid_i;
        assign pipe_rx_chanisaligned_o = pipe_rx_chanisaligned_i;
        assign pipe_rx_status_o = pipe_rx_status_i;
        assign pipe_rx_phy_status_o = pipe_rx_phy_status_i;
        assign pipe_rx_elec_idle_o = pipe_rx_elec_idle_i;
        assign pipe_rx_polarity_o = pipe_rx_polarity_i;
        assign pipe_tx_compliance_o = pipe_tx_compliance_i;
        assign pipe_tx_char_is_k_o = pipe_tx_char_is_k_i;
        assign pipe_tx_data_o = pipe_tx_data_i;
        assign pipe_tx_elec_idle_o = pipe_tx_elec_idle_i;
        assign pipe_tx_powerdown_o = pipe_tx_powerdown_i;
      end else if (PIPE_PIPELINE_STAGES == 1) begin
        always @(posedge pipe_clk) begin
          if (rst_n) begin
            pipe_rx_char_is_k_q <= #TCQ 0;
            pipe_rx_data_q <= #TCQ 0;
            pipe_rx_valid_q <= #TCQ 0;
            pipe_rx_chanisaligned_q <= #TCQ 0;
            pipe_rx_status_q <= #TCQ 0;
            pipe_rx_phy_status_q <= #TCQ 0;
            pipe_rx_elec_idle_q <= #TCQ 0;
            pipe_rx_polarity_q <= #TCQ 0;
            pipe_tx_compliance_q <= #TCQ 0;
            pipe_tx_char_is_k_q <= #TCQ 0;
            pipe_tx_data_q <= #TCQ 0;
            pipe_tx_elec_idle_q <= #TCQ 1'b1;
            pipe_tx_powerdown_q <= #TCQ 2'b10;
          end else begin
            pipe_rx_char_is_k_q <= #TCQ pipe_rx_char_is_k_i;
            pipe_rx_data_q <= #TCQ pipe_rx_data_i;
            pipe_rx_valid_q <= #TCQ pipe_rx_valid_i;
            pipe_rx_chanisaligned_q <= #TCQ pipe_rx_chanisaligned_i;
            pipe_rx_status_q <= #TCQ pipe_rx_status_i;
            pipe_rx_phy_status_q <= #TCQ pipe_rx_phy_status_i;
            pipe_rx_elec_idle_q <= #TCQ pipe_rx_elec_idle_i;
            pipe_rx_polarity_q <= #TCQ pipe_rx_polarity_i;
            pipe_tx_compliance_q <= #TCQ pipe_tx_compliance_i;
            pipe_tx_char_is_k_q <= #TCQ pipe_tx_char_is_k_i;
            pipe_tx_data_q <= #TCQ pipe_tx_data_i;
            pipe_tx_elec_idle_q <= #TCQ pipe_tx_elec_idle_i;
            pipe_tx_powerdown_q <= #TCQ pipe_tx_powerdown_i;
          end
        end
        assign pipe_rx_char_is_k_o = pipe_rx_char_is_k_q;
        assign pipe_rx_data_o = pipe_rx_data_q;
        assign pipe_rx_valid_o = pipe_rx_valid_q;
        assign pipe_rx_chanisaligned_o = pipe_rx_chanisaligned_q;
        assign pipe_rx_status_o = pipe_rx_status_q;
        assign pipe_rx_phy_status_o = pipe_rx_phy_status_q;
        assign pipe_rx_elec_idle_o = pipe_rx_elec_idle_q;
        assign pipe_rx_polarity_o = pipe_rx_polarity_q;
        assign pipe_tx_compliance_o = pipe_tx_compliance_q;
        assign pipe_tx_char_is_k_o = pipe_tx_char_is_k_q;
        assign pipe_tx_data_o = pipe_tx_data_q;
        assign pipe_tx_elec_idle_o = pipe_tx_elec_idle_q;
        assign pipe_tx_powerdown_o = pipe_tx_powerdown_q;
      end else if (PIPE_PIPELINE_STAGES == 2) begin
        always @(posedge pipe_clk) begin
          if (rst_n) begin
            pipe_rx_char_is_k_q <= #TCQ 0;
            pipe_rx_data_q <= #TCQ 0;
            pipe_rx_valid_q <= #TCQ 0;
            pipe_rx_chanisaligned_q <= #TCQ 0;
            pipe_rx_status_q <= #TCQ 0;
            pipe_rx_phy_status_q <= #TCQ 0;
            pipe_rx_elec_idle_q <= #TCQ 0;
            pipe_rx_polarity_q <= #TCQ 0;
            pipe_tx_compliance_q <= #TCQ 0;
            pipe_tx_char_is_k_q <= #TCQ 0;
            pipe_tx_data_q <= #TCQ 0;
            pipe_tx_elec_idle_q <= #TCQ 1'b1;
            pipe_tx_powerdown_q <= #TCQ 2'b10;
            pipe_rx_char_is_k_qq <= #TCQ 0;
            pipe_rx_data_qq <= #TCQ 0;
            pipe_rx_valid_qq <= #TCQ 0;
            pipe_rx_chanisaligned_qq <= #TCQ 0;
            pipe_rx_status_qq <= #TCQ 0;
            pipe_rx_phy_status_qq <= #TCQ 0;
            pipe_rx_elec_idle_qq <= #TCQ 0;
            pipe_rx_polarity_qq <= #TCQ 0;
            pipe_tx_compliance_qq <= #TCQ 0;
            pipe_tx_char_is_k_qq <= #TCQ 0;
            pipe_tx_data_qq <= #TCQ 0;
            pipe_tx_elec_idle_qq <= #TCQ 1'b1;
            pipe_tx_powerdown_qq <= #TCQ 2'b10;
          end else begin
            pipe_rx_char_is_k_q <= #TCQ pipe_rx_char_is_k_i;
            pipe_rx_data_q <= #TCQ pipe_rx_data_i;
            pipe_rx_valid_q <= #TCQ pipe_rx_valid_i;
            pipe_rx_chanisaligned_q <= #TCQ pipe_rx_chanisaligned_i;
            pipe_rx_status_q <= #TCQ pipe_rx_status_i;
            pipe_rx_phy_status_q <= #TCQ pipe_rx_phy_status_i;
            pipe_rx_elec_idle_q <= #TCQ pipe_rx_elec_idle_i;
            pipe_rx_polarity_q <= #TCQ pipe_rx_polarity_i;
            pipe_tx_compliance_q <= #TCQ pipe_tx_compliance_i;
            pipe_tx_char_is_k_q <= #TCQ pipe_tx_char_is_k_i;
            pipe_tx_data_q <= #TCQ pipe_tx_data_i;
            pipe_tx_elec_idle_q <= #TCQ pipe_tx_elec_idle_i;
            pipe_tx_powerdown_q <= #TCQ pipe_tx_powerdown_i;
            pipe_rx_char_is_k_qq <= #TCQ pipe_rx_char_is_k_q;
            pipe_rx_data_qq <= #TCQ pipe_rx_data_q;
            pipe_rx_valid_qq <= #TCQ pipe_rx_valid_q;
            pipe_rx_chanisaligned_qq <= #TCQ pipe_rx_chanisaligned_q;
            pipe_rx_status_qq <= #TCQ pipe_rx_status_q;
            pipe_rx_phy_status_qq <= #TCQ pipe_rx_phy_status_q;
            pipe_rx_elec_idle_qq <= #TCQ pipe_rx_elec_idle_q;
            pipe_rx_polarity_qq <= #TCQ pipe_rx_polarity_q;
            pipe_tx_compliance_qq <= #TCQ pipe_tx_compliance_q;
            pipe_tx_char_is_k_qq <= #TCQ pipe_tx_char_is_k_q;
            pipe_tx_data_qq <= #TCQ pipe_tx_data_q;
            pipe_tx_elec_idle_qq <= #TCQ pipe_tx_elec_idle_q;
            pipe_tx_powerdown_qq <= #TCQ pipe_tx_powerdown_q;
          end
        end
        assign pipe_rx_char_is_k_o = pipe_rx_char_is_k_qq;
        assign pipe_rx_data_o = pipe_rx_data_qq;
        assign pipe_rx_valid_o = pipe_rx_valid_qq;
        assign pipe_rx_chanisaligned_o = pipe_rx_chanisaligned_qq;
        assign pipe_rx_status_o = pipe_rx_status_qq;
        assign pipe_rx_phy_status_o = pipe_rx_phy_status_qq;
        assign pipe_rx_elec_idle_o = pipe_rx_elec_idle_qq;
        assign pipe_rx_polarity_o = pipe_rx_polarity_qq;
        assign pipe_tx_compliance_o = pipe_tx_compliance_qq;
        assign pipe_tx_char_is_k_o = pipe_tx_char_is_k_qq;
        assign pipe_tx_data_o = pipe_tx_data_qq;
        assign pipe_tx_elec_idle_o = pipe_tx_elec_idle_qq;
        assign pipe_tx_powerdown_o = pipe_tx_powerdown_qq;
      end
    endgenerate
endmodule
