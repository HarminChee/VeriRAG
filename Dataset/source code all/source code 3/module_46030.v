`timescale 1ns / 1ps
`timescale 1ns / 1ps
module SPI_SLAVE#
    (
    parameter integer m = 15 
    )
    (
    input wire RST,
    input wire GCLK,
    input wire SCLK,
    output wire MISO,
    input wire MOSI,
    input wire SS,
    input wire [m-1:0] DIN,
    output reg [m-1:0] DOUT
    );
    reg [m-1:0] RXSHIFT = 0;
    reg [m-1:0] TXSHIFT = 0;
    reg in_progress = 1'b0;
    assign MISO = TXSHIFT[m-1];
    wire foo;
    assign foo = SCLK | SS;    
    always @(negedge foo) begin
        if (in_progress == 1'b1) begin
            TXSHIFT <= TXSHIFT<<1;
        end
        else begin
            TXSHIFT <= DIN;
        end
    end
    always @(posedge GCLK) begin
        in_progress <= (SS == 1'b1) ? 1'b0 : 1'b1;
    end
    always @(posedge SS) begin
        DOUT <= (RST == 1'b1) ? 0 : RXSHIFT;
    end
    always @(posedge SCLK) begin
        RXSHIFT <= (SS == 1'b1) ? 0 : RXSHIFT<<1 | MOSI;
    end
endmodule
