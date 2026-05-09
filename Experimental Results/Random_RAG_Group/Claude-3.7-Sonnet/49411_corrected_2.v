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
wire reset_n;

assign clk_pclk = test_i ? PIPE_CLK : PIPE_PCLK_IN;
assign reset_n = test_i ? PIPE_CLK : PIPE_RESET_N;

always @(posedge clk_pclk or negedge reset_n) 
begin
    if (!reset_n)
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