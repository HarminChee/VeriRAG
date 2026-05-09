`timescale 1ns / 1ps
module UART_loop(
    input UartRx,
    output UartTx,
    input clk100,
    input test_mode,
    input test_clk,
    output [7:0]LED
);

wire [7:0]Rx_D;
reg [7:0]Tx_D;
reg WR = 1'b0;
reg RD = 1'b0;
reg RST = 1'b0;
wire RXNE;
wire TXE;
wire sys_clk;

assign sys_clk = test_mode ? test_clk : clk100;

UART_Rx # (
    .CLOCK(100_000_000),
    .BAUD_RATE(115200)
)rx_module (
    .CLK(sys_clk), 
    .D(Rx_D), 
    .RD(RD), 
    .RST(RST), 
    .RX(UartRx), 
    .RXNE(RXNE)
);

UART_Tx # (
    .CLOCK(100_000_000),
    .BAUD_RATE(115200)
) tx_module (
    .CLK(sys_clk), 
    .D(Tx_D), 
    .WR(WR), 
    .RST(RST), 
    .TX(UartTx), 
    .TXE(TXE)
);

assign LED = Rx_D;
reg tog = 1'b0;
reg prevRXNE = 1'b0;
reg rxne_sync1, rxne_sync2;

always @(posedge sys_clk) begin
    rxne_sync1 <= RXNE;
    rxne_sync2 <= rxne_sync1;
    prevRXNE <= rxne_sync2;
    
    if (prevRXNE == 1'b0 && rxne_sync2 == 1'b1) begin
        RD <= 1'b1;
        Tx_D <= Rx_D;
        WR <= 1'b1;
        tog <= !tog;
    end else begin
        RD <= 1'b0;
        WR <= 1'b0;
    end
end

endmodule