`timescale 1ns/1ps
module SPI_MASTER_ADC #(parameter outBits = 16)(
    input               sys_clk,
    input               scan_clk,
    input               test_i,
    input               ENA,
    input  [15:0]       DATA_MOSI,
    input               MISO,
    output              MOSI,
    output reg          CSbar,
    output              SCK,
    output reg          FIN,
    output [15:0]       DATA_MISO
);

reg  [1:0]               clk_div       = 2'b0;
wire                     sck_raw;
wire                     dft_sck;
reg  [5:0]               icounter      = 6'b0;
reg  [5:0]               ocounter      = 6'b0;
reg  [(outBits-1):0]     data_in       = {outBits{1'b0}};
reg  [(outBits-1):0]     data_in_final = {outBits{1'b0}};
reg  [(outBits-1):0]     data_out      = {outBits{1'b0}};

always @(posedge sys_clk)
    clk_div <= clk_div + 1'b1;

assign sck_raw = clk_div[1];
assign dft_sck = test_i ? scan_clk : sck_raw;
assign DATA_MISO = data_in_final;

always @(posedge dft_sck)
    CSbar <= ~ENA;

always @(posedge dft_sck)
    FIN <= (ocounter > (outBits-1)) & (icounter > (outBits-1));

always @(posedge dft_sck) begin
    case(CSbar)
        1'b1: begin
            icounter <= 0;
            data_in  <= 0;
        end
        1'b0: begin
            if(icounter > (outBits-1))
                data_in_final <= data_in;
            else begin
                data_in <= {data_in[(outBits-2):0], MISO};
                icounter <= icounter + 1;
            end
        end
    endcase
end

assign MOSI = data_out[(outBits-1)];

always @(posedge dft_sck) begin
    case(CSbar)
        1'b1: begin
            ocounter <= 0;
            data_out <= DATA_MOSI;
        end
        1'b0: begin
            if(ocounter > (outBits-1))
                data_out <= 1;
            else begin
                data_out <= {data_out[(outBits-2):0], 1'b0};
                ocounter <= ocounter + 1;
            end
        end
    endcase
end

assign SCK = sck_raw;

endmodule