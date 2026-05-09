`timescale 1ns / 1ps
module KeyBoard_ctrl_corrected_ffc (
    ROW,
    KEY_IN,
    COLUMN,
    CLK,
    RESET
);
  input  CLK;
  input  RESET;
  input  [3:0]  COLUMN;
  output [3:0]  ROW;
  output [3:0]  KEY_IN;

  reg    [3:0]  ROW;
  reg    [3:0]  DEBOUNCE_COUNT;
  reg    [3:0]  SCAN_CODE;
  reg    [3:0]  SCAN_NUMBER;
  // reg    [3:0]  DECODE_BCD0; // Unused
  // reg    [3:0]  DECODE_BCD1; // Unused
  // reg    [3:0]  KEY_CODE;    // Unused
  reg    [3:0]  KEY_BUFFER;
  reg    [14:0] DIVIDER;
  reg           PRESS;
  wire          PRESS_VALID;

  // Clock enables derived from DIVIDER to replace internally generated clocks
  wire scan_enable;
  wire debounce_clk_posedge_enable;
  wire debounce_clk_negedge_enable;

  // DIVIDER logic - clocked by primary clock CLK
  always @(posedge CLK or negedge RESET) begin
    if (!RESET)
      DIVIDER <= 15'h0;
    else
      DIVIDER <= DIVIDER + 1;
  end

  // Generate clock enables based on DIVIDER reaching specific values
  // Corresponds to rising edge of original DIVIDER[14]
  assign debounce_clk_posedge_enable = (DIVIDER == 15'h3FFF); // DIVIDER about to transition from 011... to 100...
  assign scan_enable                 = debounce_clk_posedge_enable; // Use same enable for scan increment
  // Corresponds to falling edge of original DIVIDER[14]
  assign debounce_clk_negedge_enable = (DIVIDER == 15'h7FFF); // DIVIDER about to transition from 111... to 000...

  // SCAN_CODE logic - clocked by primary clock CLK, enabled by scan_enable
  always @(posedge CLK or negedge RESET) begin
    if (!RESET)
      SCAN_CODE <= 4'h0;
    else if (scan_enable) begin // Increment scan code based on enable
      SCAN_CODE <= SCAN_CODE + 1;
    end
  end

  // Combinational logic for ROW and PRESS based on SCAN_CODE and COLUMN
  // Note: PRESS is registered below based on COLUMN value at scan time.
  // This combinatorial assignment for PRESS might cause glitches.
  // A registered version might be more robust, but sticking to original structure for now.
  always @(*) begin
    case (SCAN_CODE[3:2])
      2'b00 : ROW = 4'b1110;
      2'b01 : ROW = 4'b1101;
      2'b10 : ROW = 4'b1011;
      2'b11 : ROW = 4'b0111;
      default: ROW = 4'b1111; // Default case
    endcase
    case (SCAN_CODE[1:0])
      2'b00 : PRESS = ~COLUMN[0]; // Assuming active low keys
      2'b01 : PRESS = ~COLUMN[1]; // Assuming active low keys
      2'b10 : PRESS = ~COLUMN[2]; // Assuming active low keys
      2'b11 : PRESS = ~COLUMN[3]; // Assuming active low keys
      default: PRESS = 1'b0;    // Default case
    endcase
  end

  // DEBOUNCE_COUNT logic - clocked by primary clock CLK, enabled by debounce_clk_posedge_enable
  always @(posedge CLK or negedge RESET) begin
    if (!RESET)
      DEBOUNCE_COUNT <= 4'h0;
    else if (debounce_clk_posedge_enable) begin // Update only when enabled
      if (PRESS) begin // Reset debounce if key is pressed during this cycle
        DEBOUNCE_COUNT <= 4'h0;
      end else if (DEBOUNCE_COUNT <= 4'hE) begin // Increment if not pressed and not max count
        DEBOUNCE_COUNT <= DEBOUNCE_COUNT + 1;
      end
    end
  end

  // Combinational logic for PRESS_VALID
  assign PRESS_VALID = (DEBOUNCE_COUNT == 4'hD);

  // Combinational logic for SCAN_NUMBER based on SCAN_CODE
  always @(*) begin
    case (SCAN_CODE)
      4'b0000 : SCAN_NUMBER = 4'hF;
      4'b0001 : SCAN_NUMBER = 4'hE;
      4'b0010 : SCAN_NUMBER = 4'hD;
      4'b0011 : SCAN_NUMBER = 4'hC;
      4'b0100 : SCAN_NUMBER = 4'hB;
      4'b0101 : SCAN_NUMBER = 4'h3;
      4'b0110 : SCAN_NUMBER = 4'h6;
      4'b0111 : SCAN_NUMBER = 4'h9;
      4'b1000 : SCAN_NUMBER = 4'hA;
      4'b1001 : SCAN_NUMBER = 4'h2;
      4'b1010 : SCAN_NUMBER = 4'h5;
      4'b1011 : SCAN_NUMBER = 4'h8;
      4'b1100 : SCAN_NUMBER = 4'h0;
      4'b1101 : SCAN_NUMBER = 4'h1;
      4'b1110 : SCAN_NUMBER = 4'h4;
      4'b1111 : SCAN_NUMBER = 4'h7;
      default : SCAN_NUMBER = 4'hX; // Default case
    endcase
  end

  // KEY_BUFFER logic - clocked by primary clock CLK, enabled by debounce_clk_negedge_enable
  always @(posedge CLK or negedge RESET) begin
    if (!RESET)
      KEY_BUFFER <= 4'h0;
    else if (debounce_clk_negedge_enable) begin // Update only when enabled
      if (PRESS_VALID) begin // Capture key code when debounce is valid
        KEY_BUFFER <= SCAN_NUMBER;
      end
    end
  end

  assign KEY_IN = KEY_BUFFER;

endmodule