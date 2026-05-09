`default_nettype none

module Ethernet (
    output wire txd,
    output wire lcw,
    output reg burst_start = 1'b0,
    output reg link_up = 1'b0
);

    wire por_done;
    GP_POR #(.POR_TIME(500)) por (.RST_DONE(por_done)); // Assuming GP_POR exists

    wire clk_hardip;
    wire clk_fabric;
    GP_RCOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OSC_FREQ("2M"),
        .HARDIP_DIV(1),
        .FABRIC_DIV(1)
    ) rcosc (
        .PWRDN(1'b0),
        .CLKOUT_HARDIP(clk_hardip),
        .CLKOUT_FABRIC(clk_fabric)
    ); // Assuming GP_RCOSC exists

    reg pulse_en = 1'b0;
    GP_EDGEDET #(
        .DELAY_STEPS(1),
        .EDGE_DIRECTION("RISING"),
        .GLITCH_FILTER(0)
    ) delay (
        .IN(pulse_en),
        .OUT(txd)
    ); // Assuming GP_EDGEDET exists

    localparam PULSE_INTERVAL = 124;
    reg [7:0] pulse_count = PULSE_INTERVAL;
    wire pulse_start = (pulse_count == 0);

    // Counter for pulse interval generation (clk_hardip domain)
    always @(posedge clk_hardip) begin
        if (!por_done) begin // Reset counter during POR
            pulse_count <= PULSE_INTERVAL;
        end else begin
            if (pulse_count == 0) begin
                pulse_count <= PULSE_INTERVAL;
            end else begin
                pulse_count <= pulse_count - 1'd1;
            end
        end
    end

    localparam BURST_INTERVAL = 15999;
    reg [13:0] interval_count = BURST_INTERVAL;
    wire burst_start_raw = (interval_count == 0);

    // Counter for burst interval generation (clk_hardip domain)
    always @(posedge clk_hardip) begin
         if (!por_done) begin // Reset counter during POR
             interval_count <= BURST_INTERVAL;
         end else begin
            if (interval_count == 0) begin
                interval_count <= BURST_INTERVAL;
            end else begin
                interval_count <= interval_count - 1'd1;
            end
        end
    end

    // Burst start pulse generation (clk_fabric domain)
    // Generates a single cycle pulse on burst_start based on burst_start_raw
    // Note: burst_start_raw is from clk_hardip domain - needs synchronization for robust hardware.
    reg burst_start_t = 1'b0;
    always @(posedge clk_fabric) begin
        if (!por_done) begin // Reset during POR
             burst_start_t <= 1'b0;
             burst_start   <= 1'b0;
        end else begin
            // Default value for burst_start for the *next* cycle
            burst_start <= 1'b0;

            if (burst_start_raw) begin // Check the (unsynchronized) signal
                // Schedule toggle for burst_start_t for the next cycle
                burst_start_t <= !burst_start_t;

                // Check the *current* value of burst_start_t and burst_start_raw
                // If burst_start_t is currently high and burst_start_raw is high,
                // schedule burst_start to be high in the next cycle.
                if (burst_start_t) begin
                    burst_start <= 1'b1; // Assert burst_start for one cycle
                end
            end
         end
    end

    wire linkup_en;
    GP_COUNT14_ADV #(
        .CLKIN_DIVIDE(1),
        .COUNT_TO(128),
        .RESET_MODE("RISING"), // Reset occurs on rising edge of RST
        .RESET_VALUE("COUNT_TO") // Resets counter *to* COUNT_TO value
    ) linkup_count (
        .CLK(clk_hardip),
        .RST(!por_done), // Reset counter during POR
        .UP(1'b0), // Count down implicitly
        .KEEP(!burst_start), // Hold counter when not bursting (Note: burst_start is clk_fabric signal)
        .OUT(linkup_en) // Asserted when count reaches 0? Or COUNT_TO? Check module spec. Assuming asserted when count finishes/reaches limit.
    ); // Assuming GP_COUNT14_ADV exists

    reg pgen_reset  = 1'b1;
    reg lcw_advance = 1'b0;
    GP_PGEN #(
        .PATTERN_DATA(16'h8602),
        .PATTERN_LEN(5'd16)
    ) pgen (
        .nRST(pgen_reset), // Active low reset? Assuming active high based on usage. If active low, connect !pgen_reset. Let's assume active high.
        .CLK(lcw_advance),
        .OUT(lcw)
    ); // Assuming GP_PGEN exists

    wire burst_done;
    GP_COUNT8_ADV #(
        .CLKIN_DIVIDE(1),
        .COUNT_TO(33),
        .RESET_MODE("RISING"), // Reset on rising edge of RST
        .RESET_VALUE("COUNT_TO") // Reset counter *to* COUNT_TO value
    ) burst_count (
        .CLK(clk_hardip),
        .RST(burst_start || !por_done), // Reset on burst_start (clk_fabric signal!) or POR
        .UP(1'b0), // Count down implicitly
        .KEEP(!pulse_start), // Hold counter when pulse_start is low
        .OUT(burst_done) // Asserted when count reaches 0? Or COUNT_TO? Check module spec. Assuming asserted when count finishes.
    ); // Assuming GP_COUNT8_ADV exists

    reg next_pulse_is_lcw = 1'b0;
    reg burst_active      = 1'b0;

    // Combinational assignment for pulse_start_gated based on current state
    // Note: pulse_start is from clk_hardip domain - needs synchronization for robust hardware.
    wire pulse_start_gated = burst_active && pulse_start;

    // Main state logic (clk_fabric domain)
    always @(posedge clk_fabric) begin
        if (!por_done) begin // Reset state during POR
            lcw_advance       <= 1'b0;
            pulse_en          <= 1'b0;
            pgen_reset        <= 1'b1; // Keep PGEN in reset
            link_up           <= 1'b0;
            burst_active      <= 1'b0;
            next_pulse_is_lcw <= 1'b0;
        end else begin
            // Default assignments for next cycle (can be overridden below)
            lcw_advance <= 1'b0;
            pulse_en    <= 1'b0;
            // pgen_reset default depends on burst_active state (handled below)

            // Update link_up status (latching)
            // Note: linkup_en is from clk_hardip domain - needs synchronization for robust hardware.
            if (linkup_en) begin
                link_up <= 1'b1;
            end

            // Burst start handling
            if (burst_start) begin // burst_start is a single cycle pulse in this domain
                burst_active      <= 1'b1;
                next_pulse_is_lcw <= 1'b0; // First pulse after burst_start is not LSB
                lcw_advance       <= 1'b1; // Advance PGEN on burst start
                pgen_reset        <= 1'b1; // Ensure PGEN is reset at burst start
            end
            // Burst end handling
            // Note: burst_done is from clk_hardip domain - needs synchronization for robust hardware.
            else if (burst_done && burst_active) begin // Check burst_active to avoid acting on spurious burst_done
                burst_active <= 1'b0;
                pgen_reset   <= 1'b0; // Release PGEN reset after burst completes
            end
            // Condition to stop burst if link goes up during a pulse? (Original logic kept)
            // Note: pulse_start is from clk_hardip domain - needs synchronization for robust hardware.
            else if (link_up && pulse_start) begin
                 burst_active <= 1'b0;
                 // Should PGEN be reset here too? Original logic didn't.
                 pgen_reset   <= 1'b1; // Keep PGEN reset if burst aborted by link_up? Or 1'b0? Assuming reset.
            end
            // Maintain PGEN reset state if not actively starting or finishing burst
            else if (!burst_active) begin
                 // If burst isn't active (either finished or never started), keep PGEN reset released (if burst_done occurred) or asserted (if not yet started/aborted)
                 // pgen_reset state is maintained from previous cycle unless changed by burst_start/burst_done.
            end


            // Pulse generation during active burst
            // Note: pulse_start_gated uses pulse_start from clk_hardip domain.
            if (pulse_start_gated) begin // Only generate pulses if burst is active and pulse interval is met
                if (next_pulse_is_lcw) begin
                    pulse_en          <= lcw;    // Send LSB pattern bit
                    lcw_advance       <= 1'b1;   // Advance PGEN for next LSB bit
                end else begin
                    pulse_en          <= 1'b1;   // Send standard pulse
                    // lcw_advance remains 0 (default)
                end
                next_pulse_is_lcw <= ~next_pulse_is_lcw; // Toggle for next pulse
            end
        end // end else !por_done
    end // end always

endmodule
`default_nettype wire // Restore default net type