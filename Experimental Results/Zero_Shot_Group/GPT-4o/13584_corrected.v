`timescale 1ns / 1ps

module spi_bonus(clk, reset, din, dout, wren, rden, addr, mosi, miso, sclk);
input clk, reset, wren, rden;
input [7:0] din;
output reg [7:0] dout;
input [1:0] addr;
output mosi;       
input miso;       
output sclk;     

`define TXreg       2'b00
`define RXreg       2'b01
`define control     2'b10 
`define TXFULL      control[0]
`define DATARDY     control[1]
`define WAIT        2'b00
`define SHIFT       2'b01
`define SHIFT1      2'b10
`define WRITE       2'b11

reg [7:0] control, shiftin, shiftout;
reg wr_tx, wr_rx, rd_tx, sout, sin, spi, wr_control, enspi, clr_count, rd_rx;
reg [6:0] spiclk;
reg [1:0] pstate, nstate;
reg [3:0] counter;
wire rx_empty, tx_full, tx_empty;
wire [7:0] txout, dout_rx;
assign mosi = shiftout[7];
assign sclk = spi;

txreg txfifo(
  .clk    (clk),
  .rst    (reset),
  .din    (din),
  .wr_en  (wr_tx),
  .rd_en  (rd_tx),
  .dout   (txout),
  .full   (tx_full),
  .empty  (tx_empty)
);

txreg rxfifo(
  .clk    (clk),
  .rst    (reset),
  .din    (shiftin),
  .wr_en  (wr_rx),
  .rd_en  (rd_rx),
  .dout   (dout_rx),
  .full   (rx_full),
  .empty  (rx_empty)
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        spiclk <= 7'b0000000;
        spi <= 0;
    end
    else begin
        if(enspi) begin
            if(spiclk <= 24) begin
                spi <= 1;
                spiclk <= spiclk + 1;
            end
            else if(spiclk <= 49) begin
                spi <= 0;
                spiclk <= spiclk + 1;
            end
            if(spiclk == 50) begin
                spiclk <= 7'b0000000;
            end
        end
        else begin
            spiclk <= 7'b0000000;
            spi <= 0;
        end
    end
end

always @* begin
    dout = 8'b00000000;
    rd_rx = 0;
    case(addr)
        `RXreg: begin
            if(rden) begin
                rd_rx = 1;
                dout = dout_rx;
            end
        end
        `control: begin
            if(rden) begin
                dout = control;
            end
        end
    endcase
end

always @* begin
    wr_tx = 0;
    case(addr)
        `TXreg: begin
            if(wren) begin
                wr_tx = 1;
            end
        end
    endcase
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        control <= 8'b00000000;
    end
    else begin
        control[1] <= ~rx_empty;  // `DATARDY
        control[0] <= tx_full;    // `TXFULL
        if(wr_control) begin
            control <= din;
        end
    end
end

always @(posedge spi or posedge reset) begin
    if(reset) begin
        counter <= 4'b0000;
    end
    else begin
        if(enspi) counter <= counter + 1;
        if(counter >= 8) counter <= 4'b0000;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        shiftout <= 8'b00000000;
    end
    else begin
        if(sout) begin
            shiftout <= {shiftout[6:0], 1'b0};
        end
        if(rd_tx) begin
            shiftout <= txout;
        end
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        shiftin <= 8'b00000000;
    end
    else begin
        if(sin) begin
            shiftin <= {shiftin[6:0], miso};
        end
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        pstate <= `WAIT;
    end
    else begin
        pstate <= nstate;
    end
end

always @* begin
    rd_tx = 0; sout = 0;
    enspi = 0; clr_count = 0;
    wr_rx = 0; sin = 0;
    nstate = pstate;
    case(pstate)
        `WAIT: begin
            if(~tx_empty) begin
                rd_tx = 1;
                enspi = 1;
                nstate = `SHIFT;
            end
        end
        `SHIFT: begin
            enspi = 1;
            if(~spi) begin
                nstate = `SHIFT1;
                sin = 1;
                if(counter == 4'b1000) begin
                    nstate = `WRITE;
                end
            end
        end
        `SHIFT1: begin
            enspi = 1;
            if(spi) begin
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