Here is the modified Verilog code addressing the FFCKNP issue:


`timescale 1ns / 1ps
module nes_controller(
    input master_clock,
    input scan_enable,
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
    wire sample_clock;
    reg [3:0] cycle_stage;
    reg [7:0] data;

    assign sample_clock = master_clock;
    assign update_clock = master_clock;

    wire latch_phase = cycle_stage == 0;
    wire data_phase = cycle_stage >= 1 & cycle_stage <= 8;
    wire end_phase = cycle_stage == 9;

    always @(posedge master_clock or posedge scan_enable) begin
        if (scan_enable) begin
            sample_count <= 0;
            cycle_stage <= 0;
            data <= 8'h0;
            button_state <= 8'h0;
        end else begin
            sample_count <= sample_count + 1;
            if (sample_count == {(DIVIDER_EXPONENT+1){1'b1}}) begin
                if (latch_phase) data <= 8'h0;
                else if (data_phase) data <= {data[6:0], serial_data};
                else if (end_phase) begin
                    cycle_stage <= 4'h0;
                    button_state <= data;
                end else begin
                    cycle_stage <= cycle_stage + 1;
                end
                sample_count <= 0;
            end
        end
    end

    assign data_latch = latch_phase;
    assign data_clock = data_phase & (sample_count == 0);

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