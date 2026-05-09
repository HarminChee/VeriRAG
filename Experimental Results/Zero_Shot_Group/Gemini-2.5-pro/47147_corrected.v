`timescale 1 ps / 1 ps

module gmii_if (
    input            tx_reset,
    input            rx_reset,
    input            speed_is_10_100, // Note: This input is unused in the provided logic
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
    input            tx_clk,
    output           crs_to_mac,
    output           col_to_mac,
    output reg [7:0] rxd_to_mac,
    output reg       rx_dv_to_mac,
    output reg       rx_er_to_mac,
    output           rx_clk
    );

  reg             gmii_col_reg;
  reg             gmii_col_reg_reg ;
  wire            gmii_rx_dv_delay;
  wire            gmii_rx_er_delay;
  wire   [7:0]    gmii_rxd_delay;
  wire            gmii_rx_clk_bufio;
  wire            rx_clk_int;

   // Generate GMII TX Clock using ODDR
   ODDR gmii_tx_clk_ddr_iob (
      .Q                (gmii_tx_clk),
      .C                (tx_clk),
      .CE               (1'b1),
      .D1               (1'b0), // Data on rising edge
      .D2               (1'b1), // Data on falling edge (inverted clock)
      .R                (1'b0), // Async reset (unused)
      .S                (1'b0)  // Async set (unused)
   );

   // Register TX signals from MAC on tx_clk
   always @(posedge tx_clk or posedge tx_reset)
   begin
      if (tx_reset) begin
          gmii_tx_en <= 1'b0;
          gmii_tx_er <= 1'b0;
          gmii_txd   <= 8'd0;
      end else begin
          gmii_tx_en <= tx_en_from_mac;
          gmii_tx_er <= tx_er_from_mac;
          gmii_txd   <= txd_from_mac;
      end
   end

   // Pass CRS directly to MAC
   assign crs_to_mac = gmii_crs;

   // Synchronize COL signal to tx_clk domain (2-flop synchronizer)
   always @(posedge tx_clk or posedge tx_reset)
   begin
      if (tx_reset) begin
         gmii_col_reg     <= 1'b0;
         gmii_col_reg_reg <= 1'b0;
      end
      else begin
         gmii_col_reg     <= gmii_col;
         gmii_col_reg_reg <= gmii_col_reg;
      end
   end

   // Assign synchronized COL signal to MAC
   assign col_to_mac = gmii_col_reg_reg; // Use only the synchronized version

   // Buffer RX clock for I/O logic
   BUFIO bufio_gmii_rx_clk (
      .I                (gmii_rx_clk),
      .O                (gmii_rx_clk_bufio)
   );

   // Buffer RX clock for regional clock network (fabric logic)
   BUFR bufr_gmii_rx_clk (
      .I                (gmii_rx_clk),
      .CE               (1'b1),
      .CLR              (rx_reset), // Use rx_reset for BUFR clear if needed
      .O                (rx_clk_int)
   );

   // Output RX clock to MAC
   assign rx_clk = rx_clk_int;

   // Input delay for RX_DV
   IODELAYE1 #(
      .IDELAY_TYPE      ("FIXED"),
      .DELAY_SRC        ("IDATAIN"), // Use IDATAIN for input delay
      .IDELAY_VALUE     (23)         // Example delay value - adjust based on timing
   )
   delay_gmii_rx_dv (
      .IDATAIN          (gmii_rx_dv),
      .ODATAIN          (),           // Not used for input delay
      .DATAOUT          (gmii_rx_dv_delay),
      .DATAIN           (1'b0),       // Not used for input delay
      .C                (1'b0),       // Clock input (not used in FIXED mode)
      .T                (1'b0),       // Tristate control (disabled)
      .CE               (1'b0),       // Clock Enable (not used in FIXED mode)
      .CINVCTRL         (1'b0),       // Clock Invert Control (not used)
      .CLKIN            (1'b0),       // Calibration Clock Input (not used)
      .CNTVALUEIN       (5'h0),       // Counter Value Input (not used in FIXED mode)
      .INC              (1'b0),       // Increment Signal (not used in FIXED mode)
      .RST              (rx_reset)    // Reset for the delay element
   );

   // Input delay for RX_ER
   IODELAYE1 #(
      .IDELAY_TYPE      ("FIXED"),
      .DELAY_SRC        ("IDATAIN"), // Use IDATAIN for input delay
      .IDELAY_VALUE     (23)         // Example delay value - adjust based on timing
   )
   delay_gmii_rx_er (
      .IDATAIN          (gmii_rx_er),
      .ODATAIN          (),           // Not used for input delay
      .DATAOUT          (gmii_rx_er_delay),
      .DATAIN           (1'b0),       // Not used for input delay
      .C                (1'b0),       // Clock input (not used in FIXED mode)
      .T                (1'b0),       // Tristate control (disabled)
      .CE               (1'b0),       // Clock Enable (not used in FIXED mode)
      .CINVCTRL         (1'b0),       // Clock Invert Control (not used)
      .CLKIN            (1'b0),       // Calibration Clock Input (not used)
      .CNTVALUEIN       (5'h0),       // Counter Value Input (not used in FIXED mode)
      .INC              (1'b0),       // Increment Signal (not used in FIXED mode)
      .RST              (rx_reset)    // Reset for the delay element
   );

   // Generate input delays for RXD bus
   genvar i;
   generate for (i=0; i<8; i=i+1)
     begin : gmii_rxd_delay_gen
      IODELAYE1 #(
         .IDELAY_TYPE   ("FIXED"),
         .DELAY_SRC     ("IDATAIN"), // Use IDATAIN for input delay
         .IDELAY_VALUE  (23)         // Example delay value - adjust based on timing
      )
      delay_gmii_rxd (
         .IDATAIN       (gmii_rxd[i]),
         .ODATAIN       (),           // Not used for input delay
         .DATAOUT       (gmii_rxd_delay[i]),
         .DATAIN        (1'b0),       // Not used for input delay
         .C             (1'b0),       // Clock input (not used in FIXED mode)
         .T             (1'b0),       // Tristate control (disabled)
         .CE            (1'b0),       // Clock Enable (not used in FIXED mode)
         .CINVCTRL      (1'b0),       // Clock Invert Control (not used)
         .CLKIN         (1'b0),       // Calibration Clock Input (not used)
         .CNTVALUEIN    (5'h0),       // Counter Value Input (not used in FIXED mode)
         .INC           (1'b0),       // Increment Signal (not used in FIXED mode)
         .RST           (rx_reset)    // Reset for the delay element
      );
     end
   endgenerate

   // Register delayed RX signals on the buffered RX clock
   always @(posedge gmii_rx_clk_bufio or posedge rx_reset)
   begin
      if (rx_reset) begin
          rx_dv_to_mac <= 1'b0;
          rx_er_to_mac <= 1'b0;
          rxd_to_mac   <= 8'd0;
      end else begin
          // Capture the delayed signals
          rx_dv_to_mac <= gmii_rx_dv_delay;
          rx_er_to_mac <= gmii_rx_er_delay;
          rxd_to_mac   <= gmii_rxd_delay;
      end
   end

endmodule