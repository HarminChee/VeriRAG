module dyn_pll_ctrl # (
    parameter SPEED_MHZ = 25,
    parameter SPEED_LIMIT = 100,
    parameter SPEED_MIN = 25,
    parameter OSC_MHZ = 100
) (
    // Functional Ports
    input wire clk,             // NB Assumed to be 12.5MHz uart_clk
    input wire clk_valid,       // Drive from LOCKED output of first dcm (ie uart_clk valid)
    input wire [7:0] speed_in,
    input wire start,
    output reg progclk = 0,
    output reg progdata = 0,
    output reg progen = 0,
    output reg reset = 0,       // Output reset signal generated internally
    input wire locked,
    input wire [2:1] status,
    // DFT Ports
    input wire scan_clk,        // Scan clock input
    input wire test_i           // Test mode enable input
);

    // Internal signals
    reg [23:0] watchdog = 0;
    reg [7:0] state = 0;
    reg [7:0] dval = OSC_MHZ;   // Osc clock speed (hence mval scales in MHz)
    reg [7:0] mval = SPEED_MHZ;
    reg start_d1 = 0;

    // DFT Clock Mux
    wire dft_clk;
    assign dft_clk = test_i ? scan_clk : clk;

    // Main sequential logic block
    always @ (posedge dft_clk)
    begin
        // Default assignments / synchronous reset behavior
        reset <= 1'b0; // Default state for reset output

        // Handle start signal synchronization
        start_d1 <= start;

        // Toggle progclk every cycle (used for DCM programming)
        progclk <= ~progclk;

        // Watchdog Timer logic
        if (locked) begin
            watchdog <= 24'b0; // Use explicit width
        end else begin
            // Increment watchdog only if not locked and not already maxed out
            if (|watchdog != 1'b1) begin // Check if watchdog is not all 1s
                 watchdog <= watchdog + 1'b1;
            end
            // else watchdog remains at max value
        end

        // Watchdog timeout condition
        // If watchdog reaches its maximum value (2^24 - 1), assert reset
        // Original condition was watchdog[23], let's keep that for approx 670ms
        if (watchdog[23]) begin
            watchdog <= 24'b0;      // Reset watchdog counter
            reset <= 1'b1;      // Assert reset output for one cycle
        end

        // State machine logic - only run if clk_valid is high
        if (~clk_valid) begin
            // Hold state and outputs low if input clock is not valid
            progen <= 1'b0;
            progdata <= 1'b0;
            state <= 8'b0; // Use explicit width
            // Reset mval/dval shift registers? Keep them as is, they reload on start.
        end else begin
            // State machine transitions and outputs
            // Check for start condition
            // Use positive edge detection of progclk for triggering state machine start
            if ((start || start_d1) && state == 0 && speed_in >= SPEED_MIN && speed_in <= SPEED_LIMIT && progclk == 1) begin
                progen <= 1'b0;    // Ensure progen is low before starting
                progdata <= 1'b0;  // Ensure progdata is low before starting
                mval <= speed_in; // Load new M value
                dval <= OSC_MHZ;  // Load default D value
                state <= 1;     // Start state machine sequence
            end

            // State machine progression (only if not in idle state 0)
            if (state != 0) begin
                 // Increment state, handle wrap around
                 if (&state == 1'b1) begin // Check if state is all 1s (255)
                     state <= 8'b0; // Go back to idle if state reaches max value
                 end else begin
                     state <= state + 1'd1;
                 end
            end

            // State machine output logic based on state (even states for data changes aligned with progclk)
            case (state)
                // Send D value (serial programming)
                2: begin
                    progen <= 1'b1;    // Enable programming
                    progdata <= 1'b1;  // Start bit for D
                end
                4: begin
                    // progen remains high
                    progdata <= 1'b0;  // Clocking cycle / Data setup time?
                end
                6, 8, 10, 12, 14, 16, 18, 20: begin
                    // progen remains high
                    progdata <= dval[0];        // Send LSB of dval
                    dval <= {1'b0, dval[7:1]}; // Shift dval right (prepare next bit)
                end
                22: begin
                    progen <= 1'b0;    // Disable programming after D is sent
                    progdata <= 1'b0;  // Ensure data is low
                end

                // Send M value (serial programming)
                32: begin
                    progen <= 1'b1;    // Enable programming
                    progdata <= 1'b1;  // Start bit for M
                end
                34: begin // Added for consistency based on D pattern
                     // progen remains high
                     progdata <= 1'b0; // Clocking cycle / Data setup time?
                end
                36, 38, 40, 42, 44, 46, 48, 50: begin
                    // progen remains high
                    progdata <= mval[0];        // Send LSB of mval
                    mval <= {1'b0, mval[7:1]}; // Shift mval right (prepare next bit)
                end
                52: begin
                    progen <= 1'b0;    // Disable programming after M is sent
                    progdata <= 1'b0;  // Ensure data is low
                end

                // Send GO command
                62: begin
                    progen <= 1'b1;    // Assert progen for one cycle (GO command)
                end
                64: begin
                    progen <= 1'b0;    // De-assert progen
                    // Programming sequence complete, state will increment to 65 then 66
                end

                // Explicitly return to idle state after GO command cycle
                66: begin
                   state <= 8'b0; // Return to idle state
                   // Ensure outputs are low in idle state
                   progen <= 1'b0;
                   progdata <= 1'b0;
                end

                // Default case for unused states
                default: begin
                    // If in an unexpected non-zero state, ensure outputs are low
                    // State progression logic above handles returning to 0 eventually
                     if (state != 0) begin
                         progen <= 1'b0;
                         progdata <= 1'b0;
                     end
                end
            endcase
        end // end else (~clk_valid)
    end // end always @ (posedge dft_clk)

endmodule