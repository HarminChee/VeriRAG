`timescale 1ns / 1ps

module KeyBoard_ctrl(
    input           CLK,
    input           RESET,
    input   [3:0]   COLUMN, // Active low inputs from keyboard matrix columns
    output  reg [3:0]   ROW,    // Active low outputs to keyboard matrix rows
    output  wire [3:0]  KEY_IN  // Debounced key press output
);

    // Internal signals
    reg     [14:0]  DIVIDER;
    reg     [3:0]   SCAN_CODE;      // Current key being scanned (0-15)
    reg             PRESS_STATE;    // Registered state of the scanned key (1=pressed)
    reg     [3:0]   DEBOUNCE_COUNT; // Counter for debouncing
    reg     [3:0]   SCAN_NUMBER;    // Decoded key number based on SCAN_CODE
    reg     [3:0]   KEY_BUFFER;     // Buffer for the debounced key press

    // Wires
    wire    DEBOUNCE_CLK;
    wire    SCAN_CLK;
    wire    selected_col_input; // Input from the currently scanned column
    wire    PRESS_VALID;      // Signal indicating a stable key press

    // Clock Divider for Scan and Debounce Clocks
    // Generates slower clocks from the main CLK
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            DIVIDER <= 15'd0;
        end else begin
            DIVIDER <= DIVIDER + 1;
        end
    end
    // Assign derived clocks (adjust divider bits for desired frequencies)
    // Example: ~1kHz scan clock, ~100Hz debounce clock for 50MHz CLK
    // assign SCAN_CLK = DIVIDER[15]; // ~763 Hz for 50MHz CLK
    // assign DEBOUNCE_CLK = DIVIDER[18]; // ~95 Hz for 50MHz CLK
    // Using the original code's divider bit for simplicity:
    assign SCAN_CLK     = DIVIDER[14]; // Adjust index as needed for frequency
    assign DEBOUNCE_CLK = DIVIDER[14]; // Using same clock for both here

    // Scan Code Generator
    // Cycles through all 16 possible key locations (0 to 15)
    always @(posedge SCAN_CLK or negedge RESET) begin
        if (!RESET) begin
            SCAN_CODE <= 4'h0;
        end else begin
            SCAN_CODE <= SCAN_CODE + 1; // Increment scan code on each scan clock edge
        end
    end

    // Row Driver (Combinatorial)
    // Activates one row at a time (active low) based on the upper bits of SCAN_CODE
    always @(*) begin // Use @(*) for combinatorial logic
        case (SCAN_CODE[3:2])
            2'b00 : ROW = 4'b1110; // Activate ROW 0
            2'b01 : ROW = 4'b1101; // Activate ROW 1
            2'b10 : ROW = 4'b1011; // Activate ROW 2
            2'b11 : ROW = 4'b0111; // Activate ROW 3
            default : ROW = 4'b1111; // Default: No row active
        endcase
    end

    // Column Input Selector (Combinatorial)
    // Selects the column input corresponding to the lower bits of SCAN_CODE
    assign selected_col_input = COLUMN[SCAN_CODE[1:0]];

    // Key Press State Register
    // Registers the state of the currently scanned key (active low input -> active high state)
    always @(posedge SCAN_CLK or negedge RESET) begin
        if (!RESET) begin
            PRESS_STATE <= 1'b0; // Assume not pressed on reset
        end else begin
            // Check the selected column input when the corresponding row is active
            // The ROW logic is combinatorial based on SCAN_CODE, which changes on posedge SCAN_CLK.
            // We sample the column input on the same edge.
            PRESS_STATE <= ~selected_col_input; // Store if the key is pressed (low input)
        end
    end

    // Debounce Logic
    // Counts up when a key press is detected, resets when released
    always @(posedge DEBOUNCE_CLK or negedge RESET) begin
        if (!RESET) begin
            DEBOUNCE_COUNT <= 4'h0;
        end else begin
            if (PRESS_STATE) begin // If the registered key state is pressed
                if (DEBOUNCE_COUNT < 4'hF) begin // Increment counter if not max
                    DEBOUNCE_COUNT <= DEBOUNCE_COUNT + 1;
                end
            end else begin // If key is not pressed (released)
                DEBOUNCE_COUNT <= 4'h0; // Reset counter
            end
        end
    end

    // Valid Press Detection
    // Asserted when the debounce counter reaches a threshold (e.g., D)
    // Requires the key to be held for DEBOUNCE_COUNT cycles
    // Use a value slightly less than max to allow detection before counter saturates
    assign PRESS_VALID = (DEBOUNCE_COUNT == 4'hD);

    // Scan Code to Key Number Mapping (Combinatorial)
    // Maps the internal SCAN_CODE (0-15) to the actual key value/number
    always @(*) begin // Use @(*) for combinatorial logic
        case (SCAN_CODE)
            // This mapping depends on the specific keyboard matrix layout
            // Assuming a standard 4x4 keypad layout:
            // ROW 0: 1 2 3 A
            // ROW 1: 4 5 6 B
            // ROW 2: 7 8 9 C
            // ROW 3: * 0 # D (or E F if hex)
            // SCAN_CODE = {ROW[1:0], COL[1:0]} (e.g., ROW=1110 -> 00, ROW=1101 -> 01, etc.)
            // SCAN_CODE[3:2] = Row Index, SCAN_CODE[1:0] = Col Index
            // Example mapping (adjust based on actual hardware):
            4'b0000: SCAN_NUMBER = 4'h1; // Row 0, Col 0
            4'b0001: SCAN_NUMBER = 4'h2; // Row 0, Col 1
            4'b0010: SCAN_NUMBER = 4'h3; // Row 0, Col 2
            4'b0011: SCAN_NUMBER = 4'hA; // Row 0, Col 3
            4'b0100: SCAN_NUMBER = 4'h4; // Row 1, Col 0
            4'b0101: SCAN_NUMBER = 4'h5; // Row 1, Col 1
            4'b0110: SCAN_NUMBER = 4'h6; // Row 1, Col 2
            4'b0111: SCAN_NUMBER = 4'hB; // Row 1, Col 3
            4'b1000: SCAN_NUMBER = 4'h7; // Row 2, Col 0
            4'b1001: SCAN_NUMBER = 4'h8; // Row 2, Col 1
            4'b1010: SCAN_NUMBER = 4'h9; // Row 2, Col 2
            4'b1011: SCAN_NUMBER = 4'hC; // Row 2, Col 3
            4'b1100: SCAN_NUMBER = 4'hE; // Row 3, Col 0 (*) -> Using E for *
            4'b1101: SCAN_NUMBER = 4'h0; // Row 3, Col 1
            4'b1110: SCAN_NUMBER = 4'hF; // Row 3, Col 2 (#) -> Using F for #
            4'b1111: SCAN_NUMBER = 4'hD; // Row 3, Col 3
            default: SCAN_NUMBER = 4'hX; // Should not happen
        endcase
    end

    // Key Buffer Register
    // Captures the stable key number when PRESS_VALID is asserted
    always @(posedge DEBOUNCE_CLK or negedge RESET) begin
        if (!RESET) begin
            KEY_BUFFER <= 4'hX; // Initialize to invalid state
        end else begin
            if (PRESS_VALID) begin // Latch the key number when debounce count reaches threshold
                KEY_BUFFER <= SCAN_NUMBER;
            end
            // Optional: Clear buffer on key release (when DEBOUNCE_COUNT resets)
            // else if (DEBOUNCE_COUNT == 4'h0) begin
            //    KEY_BUFFER <= 4'hX; // Or some other indicator for no key pressed
            // end
        end
    end

    // Output Assignment
    assign KEY_IN = KEY_BUFFER; // Output the content of the key buffer

endmodule