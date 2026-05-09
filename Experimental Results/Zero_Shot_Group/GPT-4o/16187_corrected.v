`timescale 1ns / 1ps
module nes_controller(
    input master_clock,
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
    wire sample_clock = sample_count[DIVIDER_EXPONENT];
    
    always @(posedge master_clock) sample_count <= sample_count + 1;
    
    reg [3:0] cycle_stage;
    reg [7:0] data;
    wire latch_phase = (cycle_stage == 0);
    wire data_phase = (cycle_stage >= 1) && (cycle_stage <= 8);
    wire end_phase = (cycle_stage == 9);
    
    always @(posedge sample_clock) begin
        if(latch_phase) begin
            data <= 8'h0;
            cycle_stage <= cycle_stage + 1;
        end else if(data_phase) begin
            data <= {data[6:0], serial_data};
            cycle_stage <= cycle_stage + 1;
        end else if(end_phase) begin
            cycle_stage <= 4'h0;
            button_state <= data;
        end else begin
            cycle_stage <= cycle_stage + 1;
        end
    end
    
    assign data_latch = latch_phase;
    assign data_clock = data_phase & sample_clock;
    assign update_clock = sample_clock;
    
    function integer log2;
        input [31:0] value;
        integer i;
        begin
            value = value - 1;
            for (i = 0; value > 0; i = i + 1) begin
                value = value >> 1;
            end
            log2 = i;
        end
    endfunction
endmodule