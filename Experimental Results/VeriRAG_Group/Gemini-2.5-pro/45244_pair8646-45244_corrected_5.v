module GE_patch
   (
    input wire test_i, // Added test_i input for DFT
    input wire rst_n,  // Added primary input reset
    input wire SYS_CLK,
    input wire GMII_TXCLK,
    output wire GMII_GTXCLK,
    input wire GMII_GE_IND,
    output wire ENET0_GMII_TX_CLK,
    output wire ENET0_MDIO_I,
    input wire ENET0_MDIO_O,
    input wire ENET0_MDIO_T,
    inout wire GMII_MDIO
  );

  wire clk_125M;
  reg GMII_GE_IND_reg;
  reg[27:0] GMII_GE_TIMER;
  wire func_enet0_gmii_tx_clk; // Intermediate wire for functional clock mux

// Assuming clk_wiz_0 module definition is available elsewhere
clk_wiz_0 pll_inst
  (
  .clk_in1(SYS_CLK),
  .clk_out1(clk_125M)
  // Assuming reset/locked ports are handled correctly if they exist
  );

// Assuming IOBUF primitive is available in the target library
IOBUF mdio_buf_inst
  (
  .I(ENET0_MDIO_O),
  .IO(GMII_MDIO),
  .O(ENET0_MDIO_I),
  .T(ENET0_MDIO_T)
  );

// Asynchronous reset logic for internal FFs, clocked by primary input SYS_CLK
always @ (posedge SYS_CLK or negedge rst_n)
begin
  if (!rst_n) begin // Asynchronous reset logic
    GMII_GE_IND_reg <= 1'b0;
    GMII_GE_TIMER   <= 28'h0000000;
  end else begin
    // Synchronous logic uses primary input GMII_GE_IND directly
    if ( GMII_GE_IND == 1'b1 ) begin
      GMII_GE_IND_reg <= 1'b1;
      GMII_GE_TIMER   <= 28'h0000000; // Reset timer when GE indication is active
    end
    else begin // GMII_GE_IND == 1'b0
      // If timer reaches max value while GMII_GE_IND is low
      if ( GMII_GE_TIMER == 28'hFFFFFFF ) begin
         GMII_GE_IND_reg <= 1'b0; // Set indication low
         // Keep timer at max value (prevents rollover)
         GMII_GE_TIMER <= 28'hFFFFFFF;
      end else begin
         // Increment timer if GMII_GE_IND is low and timer hasn't maxed out
         GMII_GE_TIMER <= GMII_GE_TIMER + 1'b1;
         // GMII_GE_IND_reg retains its value (doesn't change until timer maxes out)
      end
    end // End of GMII_GE_IND == 1'b0 case
  end // End of synchronous logic (else !rst_n)
end // End of always block

// Output assignments

// DFT Mux for GMII_GTXCLK output clock
// Ensure controllable clock output during test mode
// Functional clock is the generated clk_125M
assign GMII_GTXCLK = test_i ? SYS_CLK : clk_125M;

// Functional clock selection logic for ENET0_GMII_TX_CLK
// Uses the FF clocked by SYS_CLK
assign func_enet0_gmii_tx_clk = (GMII_GE_IND_reg == 1'b1) ? clk_125M : GMII_TXCLK;

// DFT mux for the output clock ENET0_GMII_TX_CLK
// Ensure controllable clock output during test mode
assign ENET0_GMII_TX_CLK = test_i ? SYS_CLK : func_enet0_gmii_tx_clk;

endmodule