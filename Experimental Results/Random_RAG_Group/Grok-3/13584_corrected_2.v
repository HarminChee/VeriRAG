`timescale 1ns / 1ps
module spi_bonus(
    input wire clk, 
    input wire reset, 
    input wire wren, 
    input wire rden,
    input wire test_i,
    input wire [7:0] din,
    output wire [7:0] dout,
    input wire [1:0] addr,
    output wire mosi,       
    input wire miso,       
    output wire sclk
);
`define TXreg       2'b00
`define RXreg       2'b01
`define control     2'b10 
`define TXFULL      control[0]
`define DATARDY     control[1]
`define WAIT        2'b00
`define SHIFT       2'b01
`define SHIFT1      2'b10
`define WRITE       2'b11

reg [7:0] control, shiftin, shiftout, dout;
reg wr_tx, wr_rx, rd_tx, sout, sin, spi, wr_control, enspi, clr_count, rd_rx;
reg [6:0] spiclk;
reg [1:0] pstate, nstate;
reg [3:0] counter;
wire rx_empty, tx_full, tx_empty;
wire [7:0] txout, dout_rx;
wire dft_clk, dft_reset;

assign mosi = shiftout[7];
assign sclk = spi;
assign dft_clk = test_i ? clk : spiclk[0];
assign dft_reset = test_i ? reset : reset;

txreg txfifo(
    .clk    (clk),
    .rst    (dft_reset),
    .din    (din),
    .wr_en  (wr_tx),
    .rd_en  (rd_tx),
    .dout   (txout),
    .full   (tx_full),
    .empty  (tx_empty)
);

txreg rxfifo(
    .clk    (clk),
    .rst    (dft_reset),
    .din    (shiftin),
    .wr_en  (wr_rx),
    .rd_en  (rd_rx),
    .dout   (dout_rx),
    .full   (rx_full),
    .empty  (rx_empty)
);

always @(posedge clk or posedge dft_reset) begin
    if (dft_reset) begin
        spiclk <= 7'b0000000;
        spi <= 0;
    end else begin
        if (enspi) begin
            spiclk <= spiclk + 1;
            if (spiclk >= 0 && spiclk <= 24)
                spi <= 1;
            else if (spiclk >= 25 && spiclk <= 49)
                spi <= 0;
            else if (spiclk == 50)
                spiclk <= 7'b0000000;
        end else begin
            spiclk <= 7'b0000000;
            spi <= 0;
        end
    end
end

always @* begin
    dout = 8'b00000000;
    rd_rx = 0;
    case (addr)
        `RXreg: begin
            if (rden) begin
                rd_rx = 1;
                dout = dout_rx;
            end
        end
        `control: begin
            if (rden)
                dout = control;
        end
    endcase
end

always @* begin
    wr_tx = 0;
    case (addr)
        `TXreg: begin
            if (wren)
                wr_tx = 1;
        end
    endcase
end

always @(posedge clk or posedge dft_reset) begin
    if (dft_reset)
        control <= 8'b00000000;
    else begin
        control[1] <= ~rx_empty;
        control[0] <= tx_full;
        if (wr_control)
            control <= din;
    end
end

always @(posedge dft_clk or posedge dft_reset) begin
    if (dft_reset)
        counter <= 4'b0000;
    else begin
        if (enspi) counter <= counter + 1;
        if (counter >= 8) counter <= 4'b0001;
    end
end

always @(posedge clk or posedge dft_reset) begin
    if (dft_reset)
        shiftout <= 8'b00000000;
    else begin
        if (sout)
            shiftout <= {shiftout[6:0], 1'b0};
        if (rd_tx)
            shiftout <= txout;
    end
end

always @(posedge clk or posedge dft_reset) begin
    if (dft_reset)
        shiftin <= 8'b00000000;
    else begin
        if (sin)
            shiftin <= {shiftin[6:0], miso};
    end
end

always @(posedge clk or posedge dft_reset) begin
    if (dft_reset) 
        pstate <= `WAIT;
    else 
        pstate <= nstate;
end

always @* begin
    rd_tx = 0; 
    sout = 0;
    enspi = 0; 
    clr_count = 0;
    wr_rx = 0; 
    sin = 0;
    nstate = pstate;
    case (pstate)
        `WAIT: begin
            if (~tx_empty) begin
                rd_tx = 1;
                enspi = 1;
                nstate = `SHIFT;
            end
        end
        `SHIFT: begin
            enspi = 1;
            if (~spi) begin
                nstate = `SHIFT1;
                sin = 1;
                if (counter == 4'b1000) begin
                    nstate = `WRITE;
                end
            end
        end
        `SHIFT1: begin
            enspi = 1;
            if (spi) begin
                sout = 1;
                nstate = `SHIFT;
            end
        end
        `WRITE: begin
            wr_rx = 1;
            nstate = `WAIT;
        end
    endcase
end

endmodule