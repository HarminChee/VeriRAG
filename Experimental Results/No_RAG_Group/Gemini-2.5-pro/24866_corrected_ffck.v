module keyboard_corrected_ffc (
    // Primary Inputs
    input         keyboard_clk,
    input         keyboard_data,
    input         clock50,
    input         reset, // Use active high reset for consistency
    input         read,
    // Outputs
    output reg    scan_ready,
    output reg [7:0] scan_code
);

    // Internal Registers and Wires
    reg        ready_set;            // Internal flag indicating scan code is ready
    reg        read_char;            // Flag indicating character reception is in progress
    reg [3:0]  incnt;                // Bit counter for incoming data
    reg [8:0]  shiftin;              // Shift register for incoming bits (start, data, parity)
    reg [7:0]  filter;               // Filter register for keyboard_clk
    reg        keyboard_clk_filtered; // Filtered keyboard clock signal
    reg        keyboard_clk_filtered_dly; // Delayed version for edge detection

    // Derived Signals
    wire       falling_edge_kclk;    // Signal indicating falling edge of filtered kbd clock

    // Filter logic for keyboard_clk - Clocked by primary clock clock50
    // Debounces the keyboard clock signal
    always @(posedge clock50 or posedge reset) begin
        if (reset) begin
            filter <= 8'b0;
            keyboard_clk_filtered <= 1'b1; // Assume idle high for PS/2 clock
        end else begin
            filter <= {keyboard_clk, filter[7:1]}; // Shift in current keyboard_clk
            // Set filtered clock high only if filter is all 1s
            if (&filter) begin // Equivalent to filter == 8'b1111_1111
                keyboard_clk_filtered <= 1'b1;
            // Set filtered clock low only if filter is all 0s
            end else if (~|filter) begin // Equivalent to filter == 8'b0000_0000
                keyboard_clk_filtered <= 1'b0;
            end
            // Otherwise, keyboard_clk_filtered retains its value (hysteresis)
        end
    end

    // Generate delayed version for edge detection - Clocked by primary clock clock50
    always @(posedge clock50 or posedge reset) begin
        if (reset) begin
            keyboard_clk_filtered_dly <= 1'b1; // Match assumed initial state
        end else begin
            keyboard_clk_filtered_dly <= keyboard_clk_filtered;
        end
    end

    // Detect falling edge of the filtered keyboard clock (synchronously to clock50)
    // Falling edge occurs when current value is 0 and previous value (dly) was 1
    assign falling_edge_kclk = keyboard_clk_filtered_dly & ~keyboard_clk_filtered;

    // Main state machine and data capture logic - Clocked by primary clock clock50
    // Actions are triggered by the falling edge of the filtered keyboard clock
    always @(posedge clock50 or posedge reset) begin
        if (reset) begin
            incnt <= 4'b0000;
            read_char <= 1'b0;
            ready_set <= 1'b0;
            shiftin <= 9'b0;
            scan_code <= 8'b0; // Reset scan_code output
        end else begin
            // Default assignments to retain values if enable condition isn't met
            ready_set <= ready_set;

            // Only update state on the detected falling edge of the keyboard clock
            if (falling_edge_kclk) begin
                // Detect PS/2 Start Bit (data line low) when not already reading
                if (keyboard_data == 1'b0 && read_char == 1'b0) begin
                    read_char <= 1'b1;  // Start reading character
                    ready_set <= 1'b0;  // Clear ready flag
                    incnt <= 4'b0000;  // Reset bit counter
                    shiftin <= 9'b0;   // Clear shift register
                end
                // Process subsequent bits if already reading a character
                else if (read_char == 1'b1) begin
                    // Shift in Data (8 bits) and Parity (1 bit) = 9 bits total
                    if (incnt < 9) begin
                        incnt <= incnt + 1'b1;
                        // Shift in LSB first as per PS/2 standard
                        shiftin <= {keyboard_data, shiftin[8:1]};
                        ready_set <= 1'b0; // Keep ready low while receiving
                    end
                    // After 9 bits (Data + Parity), expect Stop Bit (data line high)
                    // The 10th falling edge corresponds to the Stop Bit
                    else begin // incnt == 9 (received 1 start + 8 data + 1 parity)
                        // Check Stop bit? PS/2 requires data to be high. Original code didn't check.
                        // We capture the data regardless here, following original logic structure.
                        incnt <= 4'b0000; // Reset counter for next character
                        // Data bits are shiftin[8:1] (LSB came first)
                        scan_code <= shiftin[8:1];
                        read_char <= 1'b0; // Finished reading character, wait for next start bit
                        ready_set <= 1'b1; // Signal data is ready
                    end
                end
                // else: Spurious falling edge (e.g., during idle high), do nothing
            end
            // else: No falling edge detected on this clock50 cycle, hold state
        end
    end

    // Scan Ready Signal Logic - Clocked by primary clock clock50
    // Controls the external scan_ready flag based on internal ready_set and external read signal
    always @(posedge clock50 or posedge reset) begin
        if (reset) begin
            scan_ready <= 1'b0;
        end else begin
            // Clear scan_ready when the host performs a read operation
            if (read) begin
                scan_ready <= 1'b0;
            // Set scan_ready when new data has been processed and flagged by ready_set
            end else if (ready_set) begin
                scan_ready <= 1'b1;
            end
            // Otherwise, scan_ready retains its current value
        end
    end

endmodule