module pcie_7x_v1_3_pipe_wrapper #
(
    parameter PCIE_LANE = 1
)
(                                                           
    input                           PIPE_CLK,               
    input                           PIPE_RESET_N,           
    output                          PIPE_PCLK,
    input                           test_i,              
    input        [PCIE_LANE-1:0]    clk_rxoutclk
);

    wire                            clk_pclk;
    wire                            clk_rxusrclk;
    wire                            clk_dclk;
    wire                            clk_mmcm_lock;
    wire                            rst_cpllreset;
    wire                            rst_cpllpd;
    wire                            rst_rxusrclk_reset;
    wire                            rst_dclk_reset;
    wire                            rst_gtreset;
    wire                            rst_userrdy;
    wire                            rst_txsync_start;
    wire                            rst_idle;
    wire        [10:0]              rst_fsm;
    wire                            qrst_ovrd;
    wire                            qrst_drp_start;
    wire                            qrst_qpllreset;
    wire                            qrst_qpllpd;
    wire                            qrst_idle;
    wire        [11:0]              qrst_fsm;
    reg                             reset_n_reg1;
    reg                             reset_n_reg2;
    wire                            dft_clk_pclk;

    assign dft_clk_pclk = test_i ? PIPE_CLK : clk_pclk;
    assign PIPE_PCLK = dft_clk_pclk;

    always @(posedge dft_clk_pclk or negedge PIPE_RESET_N)
    begin
        if (!PIPE_RESET_N)
            begin
            reset_n_reg1 <= 1'd0;
            reset_n_reg2 <= 1'd0;
            end
        else
            begin
            reset_n_reg1 <= 1'd1;
            reset_n_reg2 <= reset_n_reg1;
            end
    end

endmodule