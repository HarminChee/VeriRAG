`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_wrapper #
(
    // ... existing code ...
)
(                                                           
    // ... existing code ...
    input                           PIPE_CLK,               
    input                           PIPE_RESET_N,           
    output                          PIPE_PCLK,              
    // ... existing code ...
);

    // ... existing code ...

    // Clock signals driven directly from primary inputs
    wire                            pipe_clk_int;
    wire                            pipe_reset_n_int;
    
    // Register clock and reset inputs
    reg                             reset_n_reg1;
    reg                             reset_n_reg2;
    
    // Use primary input clock
    assign pipe_clk_int = PIPE_CLK;
    assign pipe_reset_n_int = PIPE_RESET_N;

    // Clock synchronization logic
    always @(posedge pipe_clk_int) begin
        if (!pipe_reset_n_int) begin
            reset_n_reg1 <= 1'd0;
            reset_n_reg2 <= 1'd0;
        end else begin
            reset_n_reg1 <= 1'd1;
            reset_n_reg2 <= reset_n_reg1;
        end
    end

    // Use primary input clock for all clock domains
    assign clk_pclk = pipe_clk_int;
    assign clk_rxusrclk = pipe_clk_int;
    assign clk_dclk = pipe_clk_int;

    // ... existing code ...

    generate
        if (PCIE_EXT_CLK == "FALSE") begin : pipe_clock_int
            // Remove internally generated clocks
            assign PIPE_USERCLK1 = pipe_clk_int;
            assign PIPE_USERCLK2 = pipe_clk_int;
            assign clk_mmcm_lock = pipe_reset_n_int;
        end else begin : pipe_clock_int_disable
            assign clk_pclk = PIPE_PCLK_IN;
            assign clk_rxusrclk = PIPE_RXUSRCLK_IN;
            assign clk_rxoutclk = PIPE_RXOUTCLK_IN;
            assign clk_dclk = PIPE_DCLK_IN;
            assign PIPE_USERCLK1 = PIPE_USERCLK1_IN;
            assign PIPE_USERCLK2 = PIPE_USERCLK2_IN;
            assign clk_mmcm_lock = PIPE_MMCM_LOCK_IN;
        end
    endgenerate

    // ... rest of existing code ...

endmodule