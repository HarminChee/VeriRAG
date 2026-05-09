`timescale 1ns / 1ps
module UART_loop(
    input UartRx,
    output UartTx,
    input clk100,
    input test_i,
    input rst_i,
    output [7:0]LED
    );
wire [7:0]Rx_D;
reg [7:0]Tx_D;
reg WR = 1'b0;
reg RD = 1'b0;
wire RXNE;
wire TXE;
wire dft_clk;
wire dft_rst;
assign dft_clk = test_i ? clk100 : clk100;
assign dft_rst = test_i ? rst_i : rst_i;
UART_Rx # (
     .CLOCK(100_000_000),
     .BAUD_RATE(115200)
)rx_module (
    .CLK(dft_clk), 
    .D(Rx_D), 
    .RD(RD), 
    .RST(dft_rst), 
    .RX(UartRx), 
    .RXNE(RXNE)
    );
UART_Tx # (
     .CLOCK(100_000_000),
     .BAUD_RATE(115200)
) tx_module (
    .CLK(dft_clk), 
    .D(Tx_D), 
    .WR(WR), 
    .RST(dft_rst), 
    .TX(UartTx), 
    .TXE(TXE)
    );
assign LED = Rx_D;
reg tog = 1'b0;
reg prevRXNE = 1'b0;
always @(posedge dft_clk or posedge dft_rst) begin
    if (dft_rst) begin
        RD <= 1'b0;
        WR <= 1'b0;
        Tx_D <= 8'b0;
        tog <= 1'b0;
        prevRXNE <= 1'b0;
    end else begin
        if (prevRXNE == 1'b0 && RXNE == 1'b1) begin
            RD <= 1'b1;
            Tx_D <= Rx_D;
            WR <= 1'b1;
            tog <= !tog;
        end else begin
            RD <= 1'b0;
            WR <= 1'b0;
        end
        prevRXNE <= RXNE;
    end
end
endmodule