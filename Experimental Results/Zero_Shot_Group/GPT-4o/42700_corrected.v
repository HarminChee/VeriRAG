`timescale 1ns/1ns

module pcie_7x_v1_11_0_gt_top #(
    parameter LINK_CAP_MAX_LINK_WIDTH = 8, 
    parameter REF_CLK_FREQ = 0,            
    parameter USER_CLK2_DIV2 = "FALSE",    
    parameter integer USER_CLK_FREQ = 3,           
    parameter PL_FAST_TRAIN = "FALSE",     
    parameter PCIE_EXT_CLK = "FALSE",      
    parameter PCIE_USE_MODE = "1.0",       
    parameter PCIE_GT_DEVICE = "GTX",      
    parameter PCIE_PLL_SEL = "CPLL",     
    parameter PCIE_ASYNC_EN = "FALSE",    
    parameter PCIE_TXBUF_EN = "FALSE",    
    parameter PCIE_CHAN_BOND = 0
)(
    input wire [5:0] pl_ltssm_state,
    input wire pipe_tx_rcvr_det,
    input wire pipe_tx_reset,
    input wire pipe_tx_rate,
    input wire pipe_tx_deemph,
    input wire [2:0] pipe_tx_margin,
    input wire pipe_tx_swing,
    input PIPE_PCLK_IN,
    input PIPE_RXUSRCLK_IN,
    input [(LINK_CAP_MAX_LINK_WIDTH - 1):0] PIPE_RXOUTCLK_IN,
    input PIPE_DCLK_IN,
    input PIPE_USERCLK1_IN,
    input PIPE_USERCLK2_IN,
    input PIPE_OOBCLK_IN,
    input PIPE_MMCM_LOCK_IN,
    output PIPE_TXOUTCLK_OUT,
    output [(LINK_CAP_MAX_LINK_WIDTH - 1):0] PIPE_RXOUTCLK_OUT,
    output [(LINK_CAP_MAX_LINK_WIDTH - 1):0] PIPE_PCLK_SEL_OUT,
    output PIPE_GEN3_OUT,
    output wire [1:0] pipe_rx0_char_is_k,
    output wire [15:0] pipe_rx0_data,
    output wire pipe_rx0_valid,
    output wire pipe_rx0_chanisaligned,
    output wire [2:0] pipe_rx0_status,
    output wire pipe_rx0_phy_status,
    output wire pipe_rx0_elec_idle,
    input wire pipe_rx0_polarity,
    input wire pipe_tx0_compliance,
    input wire [1:0] pipe_tx0_char_is_k,
    input wire [15:0] pipe_tx0_data,
    input wire pipe_tx0_elec_idle,
    input wire [1:0] pipe_tx0_powerdown,
    output wire [(LINK_CAP_MAX_LINK_WIDTH - 1):0] pci_exp_txn,
    output wire [(LINK_CAP_MAX_LINK_WIDTH - 1):0] pci_exp_txp,
    input wire [(LINK_CAP_MAX_LINK_WIDTH - 1):0] pci_exp_rxn,
    input wire [(LINK_CAP_MAX_LINK_WIDTH - 1):0] pci_exp_rxp,
    input wire sys_clk,
    input wire sys_rst_n,
    input wire PIPE_MMCM_RST_N,
    input wire [3:0] i_tx_diff_ctr,
    output wire pipe_clk,
    output wire user_clk,
    output wire user_clk2,
    output [15:0] o_rx_data,
    output [1:0] o_rx_data_k,
    output [1:0] o_rx_byte_is_comma,
    output o_rx_byte_is_aligned,
    output wire phy_rdy_n
);

    parameter TCQ = 1;
    localparam USERCLK2_FREQ = (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                               (USER_CLK_FREQ == 4) ? 3 :
                               (USER_CLK_FREQ == 3) ? 2 : USER_CLK_FREQ;
    localparam PCIE_LPM_DFE = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
    localparam PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
    localparam PCIE_OOBCLK_MODE_ENABLE = 1;
    localparam PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 3'b100 : 3'b010;

    wire [7:0] gt_rx_phy_status_wire;
    wire [7:0] gt_rxchanisaligned_wire;
    wire [31:0] gt_rx_data_k_wire;
    wire [255:0] gt_rx_data_wire;
    wire [7:0] gt_rx_elec_idle_wire;
    wire [23:0] gt_rx_status_wire;
    wire [7:0] gt_rx_valid_wire;
    wire [7:0] gt_rx_polarity;
    wire [15:0] gt_power_down;
    wire [7:0] gt_tx_char_disp_mode;
    wire [31:0] gt_tx_data_k;
    wire [255:0] gt_tx_data;
    wire gt_tx_detect_rx_loopback;
    wire [7:0] gt_tx_elec_idle;
    wire [7:0] gt_rx_elec_idle_reset;
    wire [LINK_CAP_MAX_LINK_WIDTH-1:0] plllkdet;
    wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst;
    wire clock_locked;
    wire pipe_clk_int;
    reg phy_rdy_n_int;
    reg reg_clock_locked;
    wire all_phystatus_rst;

    reg [5:0] pl_ltssm_state_q;
    always @(posedge pipe_clk_int or negedge clock_locked) begin
        if (!clock_locked)
            pl_ltssm_state_q <= #TCQ 6'b0;
        else
            pl_ltssm_state_q <= #TCQ pl_ltssm_state;
    end

    assign pipe_clk = pipe_clk_int;
    wire plm_in_l0 = (pl_ltssm_state_q == 6'h16);
    wire plm_in_rl = (pl_ltssm_state_q == 6'h1c);
    wire plm_in_dt = (pl_ltssm_state_q == 6'h2d);
    wire plm_in_rs = (pl_ltssm_state_q == 6'h1f);

    always @(posedge pipe_clk_int or negedge clock_locked) begin
        if (!clock_locked)
            reg_clock_locked <= #TCQ 1'b0;
        else
            reg_clock_locked <= #TCQ 1'b1;
    end

    always @(posedge pipe_clk_int) begin
        if (!reg_clock_locked)
            phy_rdy_n_int <= #TCQ 1'b0;
        else
            phy_rdy_n_int <= #TCQ all_phystatus_rst;
    end

    assign all_phystatus_rst = (&phystatus_rst[LINK_CAP_MAX_LINK_WIDTH-1:0]);
    assign phy_rdy_n = phy_rdy_n_int;
    assign o_rx_data = gt_rx_data_wire[15:0];
    assign o_rx_data_k = gt_rx_data_k_wire[1:0];

endmodule