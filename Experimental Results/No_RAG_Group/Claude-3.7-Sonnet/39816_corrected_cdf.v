module spdr
(
    input clk,
    input clk_50,
    input rst,
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
    input uart_rx,
    input test_mode
);
    parameter SAMPLE_CLK_DIV = 6'd62;
    reg cs;
    wire busy;
    reg wr;
    reg [3:0] mask;
    reg [31:0] addr;
    reg [31:0] wdata_final;
    wire rdone;
    wire wdone;
    wire [31:0] rsp_data;
    wire rsp_is_err = (avm_response != 2'b00);
    assign busy = avm_waitrequest;
    assign avm_address = addr;
    assign avm_read = cs && !wr;
    assign avm_write = cs && wr;
    assign avm_byteenable = mask;
    assign avm_writedata = wdata_final;
    assign avm_burstcount = 1'b1;
    assign rdone = avm_readdatavalid;
    assign rsp_data = avm_readdata;
    assign wdone = avm_writeresponsevalid;
    wire tx_busy;
    wire tx_vld;
    wire [7:0] tx_data;
    wire rx_vld;
    wire [7:0] rx_data;
    
    // Clock gating cell for test mode
    wire gated_clk;
    reg clk_en;
    assign gated_clk = test_mode ? clk_en : clk;

    spdr_uart_framer #(.SAMPLE_CLK_DIV(SAMPLE_CLK_DIV)) uart_framer
    (
        .clk_50(clk_50),
        .rst(rst),
        .tx_busy(tx_busy),
        .tx_vld(tx_vld),
        .tx_data(tx_data),
        .rx_vld(rx_vld),
        .rx_data(rx_data),
        .rx_frame_error(),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx)
    );

    reg [7:0] tx_byte;
    reg tx_push;
    wire tx_full;
    wire tx_empty;
    assign tx_vld = !tx_empty;

    spdr_fifo tx_fifo
    (
        .rst_in(rst),
        .clk_in(gated_clk),
        .clk_out(clk_50),
        .din(tx_byte),
        .push(tx_push),
        .full(tx_full),
        .dout(tx_data),
        .pop(!tx_busy),
        .empty(tx_empty)
    );

    wire [7:0] rx_byte;
    reg rx_pop;
    wire rx_empty;

    spdr_fifo rx_fifo
    (
        .rst_in(rst),
        .clk_in(clk_50),
        .clk_out(gated_clk),
        .din(rx_data),
        .push(rx_vld),
        .full(),
        .dout(rx_byte),
        .pop(rx_pop),
        .empty(rx_empty)
    );

    // Rest of the code remains unchanged
    // ... existing code ...

endmodule