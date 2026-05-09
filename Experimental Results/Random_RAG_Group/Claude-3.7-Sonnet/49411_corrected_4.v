module pcie_7x_v1_8_pipe_wrapper #
(
    // ... existing code ...
)                                                     
(                                                           
    input test_i,
    // ... existing code ...
);

// ... existing code ...

reg reset_n_reg1;
reg reset_n_reg2;
wire clk_pclk;
wire reset_n_int;
wire dft_clk;
wire dft_reset_n;

assign dft_clk = test_i ? PIPE_CLK : clk_pclk;
assign dft_reset_n = test_i ? PIPE_RESET_N : reset_n_int;
assign clk_pclk = PIPE_PCLK_IN;
assign reset_n_int = PIPE_RESET_N;

always @(posedge dft_clk or negedge dft_reset_n) 
begin
    if (!dft_reset_n)
        begin
        reset_n_reg1 <= 1'd0;
        reset_n_reg2 <= 1'd0;
        end
    else
        begin
        reset_n_reg1 <= test_i;
        reset_n_reg2 <= reset_n_reg1;
        end   
end

// ... existing code ...

endmodule