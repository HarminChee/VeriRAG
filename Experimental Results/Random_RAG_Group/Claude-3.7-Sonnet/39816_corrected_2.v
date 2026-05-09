module spdr
(
    input clk,
    input clk_50,
    input rst_n,
    input test_mode,
    input avm_waitrequest,
    input [31:0] avm_readdata,
    input avm_readdatavalid,
    input [1:0] avm_response,
    input avm_writeresponsevalid,
    output avm_burstcount,
    output [31:0] avm_writedata,
    output [31:0] avm_address,
    output avm_write,
    output avm_read,
    output [3:0] avm_byteenable,
    input [31:0] gpi,
    output reg gpi_strobe,
    output reg [31:0] gpo,
    output reg gpo_strobe,
    output uart_tx,
    input uart_rx
);

// ... existing code ...

wire rst;
assign rst = !rst_n;

wire dft_clk;
assign dft_clk = test_mode ? clk_50 : clk;

// ... existing code ...

spdr_uart_framer #(.SAMPLE_CLK_DIV(SAMPLE_CLK_DIV)) uart_framer
(
    .clk(clk_50),
    .rst_n(rst_n),
    // ... existing code ...
);

spdr_fifo tx_fifo
(
    .rst_n(rst_n),
    .clk_in(dft_clk),
    .clk_out(clk_50),
    // ... existing code ...
);

spdr_fifo rx_fifo
(
    .rst_n(rst_n),
    .clk_in(clk_50), 
    .clk_out(dft_clk),
    // ... existing code ...
);

// ... rest of existing code ...

endmodule