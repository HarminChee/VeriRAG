module keyboard(keyboard_clk, keyboard_data, clock50, reset, read, scan_ready, scan_code);
    input             keyboard_clk;
    input             keyboard_data;
    input             clock50;
    input             reset; // Use as active-high synchronous reset
    input             read;
    output            scan_ready;
    output reg [7:0]  scan_code;

    // Internal signals
    reg               ready_set;
    reg               read_char;
    reg [3:0]         incnt;
    reg [8:0]         shiftin;
    reg [7:0]         filter;
    reg               keyboard_clk_filtered;
    reg               keyboard_clk_filtered_d1; // For edge detection
    reg               keyboard_data_sync; // Synchronize keyboard_data

    wire              sync_reset;
    assign sync_reset = reset; // Assuming active-high synchronous reset

    // Filter logic (clocked by clock50, synchronous reset)
    always @(posedge clock50 or posedge sync_reset) begin
        if (sync_reset) begin
            filter <= 8'b0;
            keyboard_clk_filtered <= 1'b0; // Initial state
        end else begin
            filter <= {keyboard_clk, filter[7:1]};
            if (filter == 8'b1111_1111) begin
                keyboard_clk_filtered <= 1'b1;
            end else if (filter == 8'b0000_0000) begin
                keyboard_clk_filtered <= 1'b0;
            end
            // No else: keyboard_clk_filtered retains its value if filter is intermediate
        end
    end

    // Edge detection for filtered keyboard clock (in clock50 domain)
    always @(posedge clock50 or posedge sync_reset) begin
        if (sync_reset) begin
            keyboard_clk_filtered_d1 <= 1'b1; // Initialize high to avoid false edge
        end else begin
            keyboard_clk_filtered_d1 <= keyboard_clk_filtered;
        end
    end
    wire keyboard_clk_falling_edge = keyboard_clk_filtered_d1 & ~keyboard_clk_filtered;

    // Synchronize keyboard_data to clock50 domain
    // Simple 1-stage synchronizer; consider 2 stages for better metastability handling if needed
    always @(posedge clock50 or posedge sync_reset) begin
         if (sync_reset) begin
             keyboard_data_sync <= 1'b0;
         end else begin
             keyboard_data_sync <= keyboard_data;
         end
    end

    // Main state logic (clocked by clock50, synchronous reset)
    always @(posedge clock50 or posedge sync_reset) begin
        if (sync_reset) begin
            incnt <= 4'b0000;
            read_char <= 1'b0;
            ready_set <= 1'b0;
            scan_code <= 8'b0;
            shiftin <= 9'b0;
        end else begin
            // If read is asserted, clear ready_set synchronously for next cycle
            // Combinational clear of scan_ready is handled by the assign statement below
            if (read) begin
                ready_set <= 1'b0;
            end
            // Check for falling edge to process keyboard events
            else if (keyboard_clk_falling_edge) begin
                // Start bit detected
                if (keyboard_data_sync == 0 && read_char == 0) begin
                    read_char <= 1'b1;
                    incnt <= 4'b0000; // Reset bit counter for new character
                    ready_set <= 1'b0;
                    shiftin <= 9'b0;   // Clear shift register
                end
                // Shift in data/stop bits
                else if (read_char == 1) begin
                    if (incnt < 9) begin // Shift 9 bits (start, 8 data)
                        incnt <= incnt + 1'b1;
                        shiftin <= {keyboard_data_sync, shiftin[8:1]}; // Shift in synchronized data
                        ready_set <= 1'b0;
                    end else begin // 9th bit shifted in (stop bit ignored here)
                        incnt <= 4'b0000;
                        scan_code <= shiftin[7:0]; // Latch the 8 data bits
                        read_char <= 1'b0;         // Ready for next start bit
                        ready_set <= 1'b1;         // Signal data ready
                    end
                end
            end
            // No falling edge, maintain state unless read clears ready_set
        end
    end

    // scan_ready logic (combinational)
    // scan_ready is high when data is ready (ready_set=1) and not being read (read=0)
    assign scan_ready = ready_set & ~read;

endmodule