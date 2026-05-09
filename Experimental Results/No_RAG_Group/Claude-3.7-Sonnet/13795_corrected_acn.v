`timescale 1 ns / 1 ns
module altera_jtag_streaming #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1
) (
    input  wire       tck,
    input  wire       tdi,
    output reg        tdo,
    input  wire [2:0] ir_in,
    input  wire       virtual_state_cdr,
    input  wire       virtual_state_sdr,
    input  wire       virtual_state_udr,
    input  wire       reset_n,
    output wire [7:0] source_data,
    output wire       source_valid,
    input  wire [7:0] sink_data,
    input  wire       sink_valid,
    output wire       sink_ready,
    input  wire       clock_to_sample,
    input  wire       reset_to_sample,
    output reg        resetrequest,
    output wire       debug_reset,
    output reg        mgmt_valid,
    output reg  [(MGMT_CHANNEL_WIDTH>0?MGMT_CHANNEL_WIDTH:1)-1:0] mgmt_channel,
    output reg        mgmt_data,
    input  wire       clock_sense_reset_n_in // Added primary input for reset
);

// ... existing code ...

    wire clock_sensor_sync;
    wire reset_to_sample_sync;
    wire clock_to_sample_div2_sync;
    wire clock_sense_reset_n_sync;

    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_sensor_synchronizer (
        .clk(tck),
        .reset_n(1'b1),
        .din(clock_sensor),
        .dout(clock_sensor_sync));

    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) reset_to_sample_synchronizer (
        .clk(tck),
        .reset_n(1'b1),
        .din(reset_to_sample),
        .dout(reset_to_sample_sync));

    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_to_sample_div2_synchronizer (
        .clk(tck),
        .reset_n(1'b1),
        .din(clock_to_sample_div2),
        .dout(clock_to_sample_div2_sync));

    altera_std_synchronizer #(.depth(TCK_TO_SYSCLK_SYNC_DEPTH)) clock_sense_reset_n_synchronizer (
        .clk(clock_to_sample),
        .reset_n(clock_sense_reset_n_in), // Use primary input instead of register
        .din(1'b1),
        .dout(clock_sense_reset_n_sync));

    always @ (posedge clock_to_sample or negedge clock_sense_reset_n_in) begin // Use primary input
        if (~clock_sense_reset_n_in) begin // Use primary input
            clock_sensor <= 1'b0;
        end else begin
            clock_sensor <= 1'b1;
        end
    end

// ... rest of existing code ...

endmodule