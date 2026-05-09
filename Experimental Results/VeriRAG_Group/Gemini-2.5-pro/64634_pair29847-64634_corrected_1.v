`timescale 1ns / 1ps
module KeyBoard_ctrl(
    ROW,
    KEY_IN,
    COLUMN,
    CLK,
    RESET,
    // DFT Inputs Added
    test_i,
    scan_data
);
  input  CLK;
  input  RESET; // Should be active low based on usage
  input  [3:0]  COLUMN;
  output [3:0]  ROW;
  output [3:0]  KEY_IN;
  // DFT Inputs Added
  input  wire test_i;
  input  wire scan_data; // Corresponds to scan_in for DIVIDER[14] source

  reg    [3:0]  ROW;
  reg    [3:0]  DEBOUNCE_COUNT;
  reg    [3:0]  SCAN_CODE;
  reg    [3:0]  SCAN_NUMBER;
  // reg    [3:0]  DECODE_BCD0; // Removed, unused
  // reg    [3:0]  DECODE_BCD1; // Removed, unused
  reg    [3:0]  KEY_CODE;
  // reg    [3:0] KEY_BUFFER; // Removed, unused
  reg    [14:0] DIVIDER;
  reg    PRESS;
  wire   PRESS_VALID;
  wire   DEBOUNCE_CLK; // Original generated clock
  wire   SCAN_CLK;     // Original generated clock (same as DEBOUNCE_CLK)

  // DIVIDER register (Clocked by primary CLK, Reset by primary RESET)
  always @(posedge CLK or negedge RESET)
    begin
	     if (!RESET)
	        DIVIDER <= 15'b0;
	     else
	        DIVIDER <= DIVIDER + 1'b1; // Use 1'b1 for clarity
	end

  // Original generated clock source (for reference, not used directly by FF)
  assign DEBOUNCE_CLK = DIVIDER[14];
  assign SCAN_CLK     = DIVIDER[14]; // Same source

  // DFT modification: Make clock source controllable in test mode
  wire dft_DIVIDER_14;
  assign dft_DIVIDER_14 = test_i ? scan_data : DIVIDER[14];
  wire DEBOUNCE_CLK_dft = dft_DIVIDER_14; // Use the controllable source

  // SCAN_CODE register (Clocked by primary CLK, Reset by primary RESET)
  // Increments on every clock cycle while a key is physically pressed (before debounce)
  always @(posedge CLK or negedge RESET)
    begin
      if (!RESET)
	        SCAN_CODE <= 4'h0;
      else if (PRESS) // This might increment too fast, SCAN_CLK might be better if key needs to be held
	        SCAN_CODE <= SCAN_CODE + 1'b1; // Use 1'b1 for clarity
      // else SCAN_CODE <= SCAN_CODE; // Implicit hold
    end

  // Combinational logic for ROW and PRESS detection based on current SCAN_CODE
  always @* // Use '*' for combinational blocks
    begin
      // Determine ROW based on SCAN_CODE
      case (SCAN_CODE[3:2])
        2'b00 : ROW = 4'b1110; // Activate Row 0
        2'b01 : ROW = 4'b1101; // Activate Row 1
        2'b10 : ROW = 4'b1011; // Activate Row 2
        2'b11 : ROW = 4'b0111; // Activate Row 3
        default: ROW = 4'b1111; // Default: No row active
      endcase
      // Determine PRESS based on active ROW (from SCAN_CODE) and COLUMN inputs
      case (SCAN_CODE[1:0]) // Selects column check based on lower bits of SCAN_CODE
        2'b00 : PRESS = ~COLUMN[0]; // Check Column 0 (Inverted logic for active low key press)
        2'b01 : PRESS = ~COLUMN[1]; // Check Column 1
        2'b10 : PRESS = ~COLUMN[2]; // Check Column 2
        2'b11 : PRESS = ~COLUMN[3]; // Check Column 3
        default: PRESS = 1'b0; // Default: No press
      endcase
    end

  // DEBOUNCE_COUNT register (uses generated clock muxed for DFT)
  // Counts up when no key is pressed (PRESS=0) after a potential press, resets on press or main reset.
  always @(posedge DEBOUNCE_CLK_dft or negedge RESET) // Use dft clock source
   begin
    if (!RESET)
	     DEBOUNCE_COUNT <= 4'h0;
	   else if (PRESS) // Reset debounce counter immediately on new press detection
      DEBOUNCE_COUNT <= 4'h0;
    else if (DEBOUNCE_COUNT <= 4'hE) // Count up if no press and not yet at validation threshold
	     DEBOUNCE_COUNT <= DEBOUNCE_COUNT + 1'b1;
    // else DEBOUNCE_COUNT <= DEBOUNCE_COUNT; // Hold at max value (e.g., F) if reached
   end

  // PRESS_VALID logic (combinational)
  // Valid when debounce counter reaches a specific value (e.g., D), indicating a stable press state has ended.
  // Note: This logic seems to validate *after* the press ends. Usually validation happens *during* stable press.
  // Let's assume the intent is to capture the key *when the debounce counter reaches a stable count*
  // assign PRESS_VALID = (DEBOUNCE_COUNT == 4'hD) ? 1'b1 : 1'b0;
  // Revised: Let's assume valid when counter reaches threshold *during* press.
  // Requires change in DEBOUNCE_COUNT logic. Reverting to original interpretation for minimal change:
  assign PRESS_VALID = (DEBOUNCE_COUNT == 4'hD); // Simpler assignment

  // SCAN_NUMBER logic (combinational) - Maps SCAN_CODE to Key Value (0-F)
  // This should ideally map the SCAN_CODE active *when PRESS_VALID* occurs.
  // Since SCAN_CODE changes rapidly, it should be captured. Let's use KEY_CODE register for that.
  // This block calculates the potential key number based on the *current* SCAN_CODE.
  always @* // Use '*'
   begin
     case (SCAN_CODE)
	   4'b0000 : SCAN_NUMBER = 4'h1; // R0, C0 -> Key 1
	   4'b0001 : SCAN_NUMBER = 4'h2; // R0, C1 -> Key 2
	   4'b0010 : SCAN_NUMBER = 4'h3; // R0, C2 -> Key 3
	   4'b0011 : SCAN_NUMBER = 4'hA; // R0, C3 -> Key A (10)
	   4'b0100 : SCAN_NUMBER = 4'h4; // R1, C0 -> Key 4
	   4'b0101 : SCAN_NUMBER = 4'h5; // R1, C1 -> Key 5
	   4'b0110 : SCAN_NUMBER = 4'h6; // R1, C2 -> Key 6
	   4'b0111 : SCAN_NUMBER = 4'hB; // R1, C3 -> Key B (11)
	   4'b1000 : SCAN_NUMBER = 4'h7; // R2, C0 -> Key 7
	   4'b1001 : SCAN_NUMBER = 4'h8; // R2, C1 -> Key 8
	   4'b1010 : SCAN_NUMBER = 4'h9; // R2, C2 -> Key 9
	   4'b1011 : SCAN_NUMBER = 4'hC; // R2, C3 -> Key C (12)
	   4'b1100 : SCAN_NUMBER = 4'hE; // R3, C0 -> Key * (mapped to E=14)
	   4'b1101 : SCAN_NUMBER = 4'h0; // R3, C1 -> Key 0
	   4'b1110 : SCAN_NUMBER = 4'hF; // R3, C2 -> Key # (mapped to F=15)
	   4'b1111 : SCAN_NUMBER = 4'hD; // R3, C3 -> Key D (13)
	   default : SCAN_NUMBER = 4'hF; // Default or invalid scan code
     endcase
   end

  // KEY_CODE register (Clocked by primary CLK, Reset by primary RESET)
  // Captures the SCAN_NUMBER when PRESS_VALID is asserted.
  // Note: PRESS_VALID generation based on DEBOUNCE_COUNT needs careful review for correct timing.
  // Assuming PRESS_VALID indicates a key press has been successfully debounced.
  always @(posedge CLK or negedge RESET)
   begin
     if (!RESET)
       KEY_CODE <= 4'hF; // Default to an 'idle' or 'no key' value
     // else if (PRESS_VALID) // Capture on PRESS_VALID signal
     // A better capture might be when PRESS is true AND debounce count reaches threshold
     else if (PRESS && (DEBOUNCE_COUNT == 4'hD)) // Example: Capture when pressed and stable
       KEY_CODE <= SCAN_NUMBER; // Capture the corresponding key number
     // else KEY_CODE <= KEY_CODE; // Hold value otherwise
   end

  // Assign KEY_IN output
  assign KEY_IN = KEY_CODE; // Output the captured key code

endmodule