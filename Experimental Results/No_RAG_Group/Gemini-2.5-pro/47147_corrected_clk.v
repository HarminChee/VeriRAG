`timescale 1 ps / 1 ps
module gmii_if_corrected_clk (
    input            tx_reset,
    input            rx_reset, // Note: rx_reset is declared but not used. Consider removing or using it.
    input            speed_is_10_100, // Note: speed_is_10_100 is declared but not used. Consider removing or using it.
    output reg [7:0] gmii_txd,
    output reg       gmii_tx_en,
    output reg       gmii_tx_er,
    output           gmii_tx_clk,
    input            gmii_crs,
    input            gmii_col,
    input      [7:0] gmii_rxd,
    input            gmii_rx_dv,
    input            gmii_rx_er,
    input            gmii_rx_clk, // Primary input clock for RX path
    input      [7:0] txd_from_mac,
    input            tx_en_from_mac,
    input            tx_er_from_mac,
    input            tx_clk, // Primary input clock for TX path
    output           crs_to_mac,
    output           col_to_mac,
    output reg [7:0] rxd_to_mac,
    output reg       rx_dv_to_mac,
    output reg       rx_er_to_mac,
    output           rx_clk // Output clock derived from gmii_rx_clk via BUFR
    );

  reg             gmii_col_reg;
  reg             gmii_col_reg_reg ;
  wire            gmii_rx_dv_delay;
  wire            gmii_rx_er_delay;
  wire   [7:0]    gmii_rxd_delay;
  // wire            gmii_rx_clk_bufio; // Removed as its output is not used to clock FFs directly
  wire            rx_clk_int; // Internal clock derived from gmii_rx_clk via BUFR

   // TX Path - Clocked by primary input tx_clk
   ODDR gmii_tx_clk_ddr_iob (
      .Q                (gmii_tx_clk),
      .C                (tx_clk),
      .CE               (1'b1),
      .D1               (1'b0),
      .D2               (1'b1),
      .R                (1'b0),
      .S                (1'b0)
   );

   always @(posedge tx_clk)
   begin
      gmii_tx_en           <= tx_en_from_mac;
      gmii_tx_er           <= tx_er_from_mac;
      gmii_txd             <= txd_from_mac;
   end

   assign crs_to_mac = gmii_crs;

   always @(posedge tx_clk)
   begin
      if (tx_reset == 1'b1) begin
         gmii_col_reg         <= 1'b0;
         gmii_col_reg_reg     <= 1'b0;
      end
      else begin
         gmii_col_reg         <= gmii_col;
         gmii_col_reg_reg     <= gmii_col_reg;
      end
   end
   assign col_to_mac = gmii_col_reg_reg | gmii_col_reg | gmii_col;

   // RX Path - Clock Management
   // BUFIO might still be needed for I/O timing, but its output should not clock scan FFs.
   // If BUFIO is needed for pin interface, keep it but don't use its output for the always block below.
   /*BUFIO bufio_gmii_rx_clk (
      .I                (gmii_rx_clk),
      .O                (gmii_rx_clk_bufio) // This output is problematic for DFT if used to clock FFs
   );*/

   // Use BUFR for internal clock distribution if needed, driven by primary input gmii_rx_clk
   BUFR bufr_gmii_rx_clk (
      .I                (gmii_rx_clk),
      .CE               (1'b1),
      .CLR              (1'b0), // Consider connecting CLR to rx_reset if needed
      .O                (rx_clk_int)
   );

   // Assign the BUFR output to the module output rx_clk
   assign rx_clk = rx_clk_int;

   // Input delay elements (clocked asynchronously or using dedicated clock)
   // These are typically handled specially by DFT tools if they are part of I/O structures.
   // The clock connection (.C) is often left unconnected or tied low for fixed delays.
   IODELAYE1 #(
      .IDELAY_TYPE      ("FIXED"),
      .DELAY_SRC        ("I"),
      .IDELAY_VALUE     (23)
   )
   delay_gmii_rx_dv (
      .IDATAIN          (gmii_rx_dv),
      .ODATAIN          (1'b0),
      .DATAOUT          (gmii_rx_dv_delay),
      .DATAIN           (1'b0),
      .C                (1'b0),
      .T                (1'b1),
      .CE               (1'b0),
      .CINVCTRL         (1'b0),
      .CLKIN            (1'b0),
      .CNTVALUEIN       (5'h0),
      .INC              (1'b0),
      .RST              (1'b0) // Consider connecting RST to rx_reset if needed
   );

   IODELAYE1 #(
      .IDELAY_TYPE      ("FIXED"),
      .DELAY_SRC        ("I"),
	  .IDELAY_VALUE     (23)
   )
   delay_gmii_rx_er (
      .IDATAIN          (gmii_rx_er),
      .ODATAIN          (1'b0),
      .DATAOUT          (gmii_rx_er_delay),
      .DATAIN           (1'b0),
      .C                (1'b0),
      .T                (1'b1),
      .CE               (1'b0),
      .CINVCTRL         (1'b0),
      .CLKIN            (1'b0),
      .CNTVALUEIN       (5'h0),
      .INC              (1'b0),
      .RST              (1'b0) // Consider connecting RST to rx_reset if needed
   );

   genvar i;
   generate for (i=0; i<8; i=i+1)
     begin : gmii_data_bus0
      IODELAYE1 #(
         .IDELAY_TYPE   ("FIXED"),
         .DELAY_SRC     ("I"),
		 .IDELAY_VALUE  (23)
      )
      delay_gmii_rxd (
         .IDATAIN       (gmii_rxd[i]),
         .ODATAIN       (1'b0),
         .DATAOUT       (gmii_rxd_delay[i]),
         .DATAIN        (1'b0),
         .C             (1'b0),
         .T             (1'b1),
         .CE            (1'b0),
         .CINVCTRL      (1'b0),
         .CLKIN         (1'b0),
         .CNTVALUEIN    (5'h0),
         .INC           (1'b0),
         .RST           (1'b0) // Consider connecting RST to rx_reset if needed
      );
     end
   endgenerate

   // RX Path Logic - Clocked by rx_clk_int (derived from primary input gmii_rx_clk via BUFR)
   // Using rx_clk_int (output of BUFR) is generally more DFT-friendly for internal FFs
   // than using the output of BUFIO (gmii_rx_clk_bufio).
   // Alternatively, clock directly with gmii_rx_clk if BUFR output is also flagged by DFT tools.
   always @(posedge rx_clk_int) // Changed clock from gmii_rx_clk_bufio to rx_clk_int
   begin
      // Consider adding reset logic using rx_reset if needed for these FFs
      rx_dv_to_mac <= gmii_rx_dv_delay;
      rx_er_to_mac <= gmii_rx_er_delay;
      rxd_to_mac   <= gmii_rxd_delay;
   end

endmodule