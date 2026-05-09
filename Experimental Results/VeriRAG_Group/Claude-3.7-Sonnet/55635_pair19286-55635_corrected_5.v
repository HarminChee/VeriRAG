module pcie_7x_v1_3_pipe_wrapper #
(
    // ... existing code ...
)
(                                                           
    input                           PIPE_CLK,               
    input                           PIPE_RESET_N,
    input                           scan_clk,
    input                           test_i,           
    // ... existing code ...
);

// ... existing code ...

generate
    if (PCIE_EXT_CLK == "FALSE") begin : internal_clocking
        wire clk_pclk_unbuf, clk_rxusrclk_unbuf, clk_dclk_unbuf;
        wire [PCIE_LANE-1:0] clk_rxoutclk_unbuf;
        
        assign clk_pclk = test_i ? scan_clk : clk_pclk_unbuf;
        assign clk_rxusrclk = test_i ? scan_clk : clk_rxusrclk_unbuf;
        assign clk_dclk = test_i ? scan_clk : clk_dclk_unbuf;
        
        genvar i;
        for (i=0; i<PCIE_LANE; i=i+1) begin : gen_rxoutclk
            assign clk_rxoutclk[i] = test_i ? scan_clk : clk_rxoutclk_unbuf[i];
        end
    end else begin : external_clocking
        assign clk_pclk = PIPE_PCLK_IN;
        assign clk_rxusrclk = PIPE_RXUSRCLK_IN;
        assign clk_dclk = PIPE_DCLK_IN;
        assign clk_rxoutclk = PIPE_RXOUTCLK_IN;
    end
endgenerate

reg reset_n_reg1, reset_n_reg2;

always @(posedge PIPE_CLK or negedge PIPE_RESET_N) begin
    if (!PIPE_RESET_N)
        begin
        reset_n_reg1 <= 1'b0;
        reset_n_reg2 <= 1'b0;
        end
    else
        begin
        reset_n_reg1 <= 1'b1;
        reset_n_reg2 <= reset_n_reg1;
        end
end

// ... existing code ...

endmodule