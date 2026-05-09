`timescale 1ns / 1ps

module spi_bonus(
    input clk,
    input reset,
    input wren,
    input rden,
    input [7:0] din,
    output [7:0] dout,
    input [1:0] addr,
    output mosi,
    input miso,
    output sclk
);

    // Parameters
    `define TXreg   2'b00
    `define RXreg   2'b01
    `define control 2'b10

    // Signals
    reg [7:0] control;
    reg [7:0] shiftin;
    reg [7:0] shiftout;
    reg [7:0] dout;

    reg wr_tx;
    reg wr_rx;
    reg rd_tx;
    reg rd_rx;
    reg sout;
    reg sin;
    reg spi;
    reg wr_control;
    reg enspi;
    reg clr_count;

    reg [5:0] spiclk;
    reg [1:0] pstate;
    reg [1:0] nstate;
    reg [3:0] counter;

    wire rx_empty;
    wire tx_full;
    wire tx_empty;
    wire [7:0] txout;
    wire [7:0] dout_rx;

    // State Machine States
    `define WAIT   2'b00
    `define SHIFT  2'b01
    `define SHIFT1 2'b10
    `define WRITE  2'b11

    // Assign outputs
    assign mosi = shiftout[7];
    assign sclk = spi;

    // FIFO instances
    txreg txfifo (
        .clk   (clk),
        .rst   (reset),
        .din   (din),
        .wr_en (wr_tx),
        .rd_en (rd_tx),
        .dout  (txout),
        .full  (tx_full),
        .empty (tx_empty)
    );

    txreg rxfifo (
        .clk   (clk),
        .rst   (reset),
        .din   (shiftin),
        .wr_en (wr_rx),
        .rd_en (rd_rx),
        .dout  (dout_rx),
        .full  (rx_full),
        .empty (rx_empty)
    );

    // SPI clock generation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            spiclk <= 6'b000000;
            spi <= 0;
        end else begin
            if (enspi) begin
                if (spiclk < 25) begin
                    spi <= 1;
                    spiclk <= spiclk + 1;
                end else if (spiclk < 50) begin
                    spi <= 0;
                    spiclk <= spiclk + 1;
                end else begin
                    spiclk <= 6'b000000;
                end
            end else begin
                spiclk <= 6'b000000;
                spi <= 0;
            end
        end
    end

    // Read data from FIFOs
    always @(*) begin
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
            default:;
        endcase
    end

    // Write data to TX FIFO
    always @(*) begin
        wr_tx = 0;
        wr_control = 0;  // Initialize wr_control
        case (addr)
            `TXreg: begin
                if (wren)
                    wr_tx = 1;
            end
            `control: begin    // Add control register write
                if (wren)
                    wr_control = 1;
            end
            default:;
        endcase
    end

    // Control register update
    always @(posedge clk or posedge reset) begin
        if (reset)
            control <= 8'b00000000;
        else begin
            if (wr_control)  // Modified to use wr_control
                control <= din;
            else begin
                control[0] <= tx_full;
                control[1] <= ~rx_empty;
            end
        end
    end

    // SPI counter
    always @(posedge spi or posedge reset) begin
        if (reset)
            counter <= 4'b0000;
        else begin
            if (enspi)
                counter <= counter + 1;
            if (counter >= 4'b1000)
                counter <= 4'b0000;
        end
    end

    // Shift out register
    always @(posedge clk or posedge reset) begin
        if (reset)
            shiftout <= 8'b00000000;
        else begin
            if (sout)
                shiftout <= {shiftout[6:0], 1'b0};
            if (rd_tx)
                shiftout <= txout;
        end
    end

    // Shift in register
    always @(posedge clk or posedge reset) begin
        if (reset)
            shiftin <= 8'b00000000;
        else begin
            if (sin)
                shiftin <= {shiftin[6:0], miso};
        end
    end

    // State machine register update
    always @(posedge clk or posedge reset) begin
        if (reset)
            pstate <= `WAIT;
        else
            pstate <= nstate;
    end

    // State machine next state logic
    always @(*) begin
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
                    if (counter == 4'b0111) begin
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
            default: nstate = `WAIT;
        endcase
    end

endmodule

// Dummy txreg module to make the code compilable
module txreg(
    input clk,
    input rst,
    input [7:0] din,
    input wr_en,
    input rd_en,
    output [7:0] dout,
    output full,
    output empty
);

    reg [7:0] data;
    assign dout = data;
    assign full = 0;
    assign empty = 0;

    always @(posedge clk) begin
        if (wr_en) begin
            data <= din;
        end
    end

endmodule