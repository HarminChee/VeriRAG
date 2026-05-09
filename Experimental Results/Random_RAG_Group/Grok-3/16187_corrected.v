`timescale 1ns / 1ps
module nes_controller(
    input master_clock,
    input test_i,
    output data_clock,
    output data_latch,
    input serial_data,
    output reg [7:0] button_state,
    output update_clock
);
    parameter Hz  = 1;
    parameter KHz = 1000*Hz;
    parameter MHz = 1000*KHz;
    parameter MASTER_CLOCK_FREQUENCY = 100*MHz; 
    parameter OUTPUT_UPDATE_FREQUENCY = 120*Hz; 
    parameter DIVIDER_EXPONENT = log2( (MASTER_CLOCK_FREQUENCY / OUTPUT_UPDATE_FREQUENCY) / 10 ) - 2;
    reg [DIVIDER_EXPONENT:0] sample_count;
    wire dft_master_clock = test_i ? master_clock : master_clock;
    wire sample_clock = sample_count[DIVIDER_EXPONENT];
    always @(posedge dft_master_clock) sample_count <= sample_count + 1;
    reg [3:0] cycle_stage;
    reg [7:0] data;
    wire latch_phase = cycle_stage == 0;
    wire data_phase = cycle_stage >= 1 & cycle_stage <= 8;
    wire end_phase = cycle_stage == 9;
    always @(posedge sample_clock) begin
        if (latch_phase) data <= 4'h0;
        else if (data_phase) data <= {data[6:0], serial_data};
        else if (end_phase) begin
            cycle_stage <= 4'h0;
            button_state[7:0] <= data;
        end
        cycle_stage <= cycle_stage + 1;
    end
    assign data_latch = latch_phase;
    assign data_clock = data_phase & sample_clock;
    assign update_clock = sample_clock;
    function integer log2;
        input [31:0] value;
        begin
            value = value - 1;
            for (log2 = 0; value > 0; log2 = log2 + 1) begin
                value = value >> 1;
            end
        end
    endfunction
endmodule