`timescale 1ns / 1ps
module pcie_7x_v1_8_pipe_wrapper #
(
    // ... existing parameters ...
)                                                     
(                                                           
    // ... existing ports ...
);

    // ... existing wire/reg declarations ...

    // Primary input clock for all flip-flops
    input wire pipe_clk_primary;

    // Clock generation
    generate 
        if (PCIE_EXT_CLK == "FALSE")
            begin : pipe_clock_int
            pcie_7x_v1_8_pipe_clock #
            (
                // ... existing parameters ...
            )
            pipe_clock_i
            (
                .CLK_CLK                        (pipe_clk_primary), // Use primary input clock
                .CLK_TXOUTCLK                   (gt_txoutclk[0]),       
                // ... rest of clock module ports ...
            );
            end
        else
            begin : pipe_clock_int_disable
            assign clk_pclk      = pipe_clk_primary; // Use primary input clock
            assign clk_rxusrclk  = PIPE_RXUSRCLK_IN;
            // ... rest of clock assignments ...
            end
    endgenerate

    // Reset synchronization using primary clock
    always @(posedge pipe_clk_primary)
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

    // ... rest of module implementation ...

endmodule