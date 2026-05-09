`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module gmii_if (
    input            scan_clk,
    input            test_i,
    input            tx_clk,
    input            tx_reset,
    input            rx_reset,
    input            speed_is_10_100,
    output reg [7:0] gmii_txd,
    output reg       gmii_tx_en,
    output reg       gmii_tx_er,
    output           gmii_tx_clk,
    input            gmii_crs,
    input            gmii_col,
    input      [7:0] gmii_rxd,
    input            gmii_rx_dv,
    input            gmii_rx_er,
    input            gmii_rx_clk,
    input      [7:0] txd_from_mac,
    input            tx_en_from_mac,
    input            tx_er_from_mac,
    output           crs_to_mac,
    output           col_to_mac,
    output reg [7:0] rxd_to_mac,
    output reg       rx_dv_to_mac,
    output reg       rx_er_to_mac,
    output           rx_clk
    );

wire dft_tx_clk = test_i ? scan_clk : tx_clk;
wire dft_rx_clk = test_i ? scan_clk : gmii_rx_clk;

ODDR gmii_tx_clk_ddr_iob (
   .Q    (gmii_tx_clk),
   .C    (dft_tx_clk),
   .CE   (1'b1),
   .D1   (1'b0),
   .D2   (1'b1),
   .R    (1'b0),
   .S    (1'b0)
);

reg gmii_col_reg;
reg gmii_col_reg_reg;

always @(posedge dft_tx_clk) begin
   gmii_tx_en <= tx_en_from_mac;
   gmii_tx_er <= tx_er_from_mac;
   gmii_txd   <= txd_from_mac;
end

assign crs_to_mac = gmii_crs;

always @(posedge dft_tx_clk) begin
   if (tx_reset == 1'b1) begin
      gmii_col_reg     <= 1'b0;
      gmii_col_reg_reg <= 1'b0;
   end
   else begin
      gmii_col_reg     <= gmii_col;
      gmii_col_reg_reg <= gmii_col_reg;
   end
end

assign col_to_mac = gmii_col_reg_reg | gmii_col_reg | gmii_col;

wire gmii_rx_clk_bufio;
BUFIO bufio_gmii_rx_clk (
   .I (gmii_rx_clk),
   .O (gmii_rx_clk_bufio)
);

wire rx_clk_int;
BUFR bufr_gmii_rx_clk (
   .I   (gmii_rx_clk),
   .CE  (1'b1),
   .CLR (1'b0),
   .O   (rx_clk_int)
);

assign rx_clk = test_i ? scan_clk : rx_clk_int;

wire gmii_rx_clk_bufio_dft = test_i ? scan_clk : gmii_rx_clk_bufio;

wire gmii_rx_dv_delay;
wire gmii_rx_er_delay;
wire [7:0] gmii_rxd_delay;

IODELAYE1 #(
   .IDELAY_TYPE ("FIXED"),
   .DELAY_SRC   ("I"),
   .IDELAY_VALUE(23)
)
delay_gmii_rx_dv (
   .IDATAIN   (gmii_rx_dv),
   .ODATAIN   (1'b0),
   .DATAOUT   (gmii_rx_dv_delay),
   .DATAIN    (1'b0),
   .C         (1'b0),
   .T         (1'b1),
   .CE        (1'b0),
   .CINVCTRL  (1'b0),
   .CLKIN     (1'b0),
   .CNTVALUEIN(5'h0),
   .INC       (1'b0),
   .RST       (1'b0)
);

IODELAYE1 #(
   .IDELAY_TYPE ("FIXED"),
   .DELAY_SRC   ("I"),
   .IDELAY_VALUE(23)
)
delay_gmii_rx_er (
   .IDATAIN   (gmii_rx_er),
   .ODATAIN   (1'b0),
   .DATAOUT   (gmii_rx_er_delay),
   .DATAIN    (1'b0),
   .C         (1'b0),
   .T         (1'b1),
   .CE        (1'b0),
   .CINVCTRL  (1'b0),
   .CLKIN     (1'b0),
   .CNTVALUEIN(5'h0),
   .INC       (1'b0),
   .RST       (1'b0)
);

genvar i;
generate
  for (i=0; i<8; i=i+1) begin : gmii_data_bus0
    IODELAYE1 #(
       .IDELAY_TYPE("FIXED"),
       .DELAY_SRC  ("I"),
       .IDELAY_VALUE(23)
    )
    delay_gmii_rxd (
       .IDATAIN   (gmii_rxd[i]),
       .ODATAIN   (1'b0),
       .DATAOUT   (gmii_rxd_delay[i]),
       .DATAIN    (1'b0),
       .C         (1'b0),
       .T         (1'b1),
       .CE        (1'b0),
       .CINVCTRL  (1'b0),
       .CLKIN     (1'b0),
       .CNTVALUEIN(5'h0),
       .INC       (1'b0),
       .RST       (1'b0)
    );
  end
endgenerate

always @(posedge gmii_rx_clk_bufio_dft) begin
   rx_dv_to_mac <= gmii_rx_dv_delay;
   rx_er_to_mac <= gmii_rx_er_delay;
   rxd_to_mac   <= gmii_rxd_delay;
end

endmodule