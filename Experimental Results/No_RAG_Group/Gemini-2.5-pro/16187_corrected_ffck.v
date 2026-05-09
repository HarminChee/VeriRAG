`timescale 1ns / 1ps
module nes_controller_corrected_ffc ( // Renamed module and added reset
    input        master_clock,
    input        reset_n,         // Added synchronous reset input
    output       data_clock,
    output       data_latch,
    input        serial_data,
    output reg [7:0] button_state,
    output       update_clock
);

    parameter Hz = 1;
    parameter KHz = 1000 * Hz;
    parameter MHz = 1000 * KHz;
    parameter MASTER_CLOCK_FREQUENCY = 100 * MHz;
    parameter OUTPUT_UPDATE_FREQUENCY = 120 * Hz;

    // Calculate divider ratio carefully, ensuring it's positive
    localparam DIVIDER_RATIO = (MASTER_CLOCK_FREQUENCY / OUTPUT_UPDATE_FREQUENCY);
    // Ensure the value passed to log2 is at least 1
    localparam LOG2_INPUT = (DIVIDER_RATIO > 0) ? DIVIDER_RATIO : 1;
    // Calculate counter width based on the divider ratio
    parameter COUNTER_WIDTH = log2(LOG2_INPUT); // Width needed to count up to DIVIDER_RATIO-1

    reg [COUNTER_WIDTH-1:0] sample_count;
    wire sample_enable;

    // Sample counter clocked by master_clock with synchronous reset
    always @(posedge master_clock or negedge reset_n) begin
        if (!reset_n) begin
            sample_count <= {COUNTER_WIDTH{1'b0}};
        end else begin
            // Increment counter, roll over at DIVIDER_RATIO-1
            if (sample_count == DIVIDER_RATIO - 1) begin
                sample_count <= {COUNTER_WIDTH{1'b0}};
            end else begin
                sample_count <= sample_count + 1;
            end
        end
    end

    // Generate sample_enable pulse when counter is about to roll over
    // This replaces the problematic internally generated clock edge
    assign sample_enable = (sample_count == DIVIDER_RATIO - 1);

    reg [3:0] cycle_stage;
    reg [7:0] data;

    // Determine phases based on cycle_stage
    wire latch_phase = cycle_stage == 4'd0;
    // Adjusted data phase stages based on typical NES controller timing (1 latch + 8 data bits)
    wire data_phase = cycle_stage >= 4'd1 & cycle_stage <= 4'd8;
    // End phase after reading 8 bits
    wire end_phase = cycle_stage == 4'd9;

    // Main state machine and data capture logic
    // Clocked ONLY by primary master_clock, enabled by sample_enable
    // Added synchronous reset
    always @(posedge master_clock or negedge reset_n) begin
        if (!reset_n) begin
            cycle_stage <= 4'd0;
            data <= 8'd0;
            button_state <= 8'd0; // Reset button state register
        end else begin
            if (sample_enable) begin // Logic updates only when sample_enable is high
                if (latch_phase) begin
                    data <= 8'd0; // Clear data register during latch phase
                    cycle_stage <= cycle_stage + 1;
                end else if (data_phase) begin
                    data <= {data[6:0], serial_data}; // Shift in serial data
                    cycle_stage <= cycle_stage + 1;
                end else if (end_phase) begin
                    button_state <= data; // Latch the captured data into button_state
                    cycle_stage <= 4'd0; // Go back to latch phase
                end else begin
                     // If in an unexpected state (e.g., > 9), reset to 0
                    cycle_stage <= 4'd0;
                end
            end
             // If sample_enable is low, all registers (cycle_stage, data, button_state) hold their values
        end
    end

    // Output assignments based on registered state and enable signal
    // data_latch is high only during stage 0
    assign data_latch = latch_phase;

    // data_clock pulses high synchronous to master_clock when enabled during data phase
    assign data_clock = data_phase & sample_enable;

    // update_clock pulses high synchronous to master_clock when enabled (indicates end of a sample cycle)
    assign update_clock = sample_enable;

    // Log2 function (unchanged, used for parameter calculation)
    // Calculates ceil(log2(value)) essentially for width determination
    function integer log2;
        input [31:0] value;
        integer i; // Temporary variable for loop
        begin
            value = value - 1;
            for (log2 = 0; value > 0; log2 = log2 + 1) begin
                value = value >> 1;
            end
        end
    endfunction

endmodule