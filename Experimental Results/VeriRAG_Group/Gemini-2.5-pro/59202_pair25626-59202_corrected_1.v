`timescale 1 ns / 1 ns

module altera_pli_streaming (
    clk,
    reset_n,
    source_valid,
    source_data,
    source_ready,
    sink_valid,
    sink_data,
    sink_ready,
    resetrequest,
    test_clk, // Added test clock input
    test_mode // Added test mode input
);
    parameter PLI_PORT = 50000;
    parameter PURPOSE = 0;
    input clk;
    input reset_n;
    output source_valid; // Changed to wire
    output [7 : 0] source_data; // Changed to wire
    input source_ready;
    input sink_valid;
    input [7 : 0] sink_data;
    output sink_ready; // Changed to wire
    output resetrequest; // Changed to wire
    input test_clk; // Added test clock input
    input test_mode; // Added test mode input

    // Internal signals for PLI simulation model
    reg pli_out_valid_sim;
    reg pli_in_ready_sim;
    reg [7 : 0] pli_out_data_sim;

    // DFT clock selection
    wire dft_clk;
    assign dft_clk = test_mode ? test_clk : clk;

    // JTAG Streaming Instance (for synthesis and potentially simulation if MODEL_TECH not defined)
    wire [7:0] jtag_source_data;
    wire jtag_source_valid;
    wire jtag_sink_ready;
    wire jtag_resetrequest;

    altera_jtag_dc_streaming #(.PURPOSE(PURPOSE)) jtag_dc_streaming (
       .clk(dft_clk), // Use DFT clock
       .reset_n(reset_n),
       .source_data(jtag_source_data),
       .source_valid(jtag_source_valid),
       .sink_data(sink_data),
       .sink_valid(sink_valid),
       .sink_ready(jtag_sink_ready),
       .resetrequest(jtag_resetrequest)
       );

    // PLI Simulation Model Logic (Excluded from Synthesis)
    // synthesis translate_off
    `ifdef MODEL_TECH
    always @(posedge dft_clk or negedge reset_n) begin
        if (!reset_n) begin
            pli_out_valid_sim <= 1'b0;
            pli_out_data_sim  <= 8'b0;
            pli_in_ready_sim  <= 1'b0;
        end
        else begin
            // Call the PLI task
            $do_transaction(
                PLI_PORT,
                pli_out_valid_sim, // Output from PLI task
                source_ready,      // Input to PLI task
                pli_out_data_sim,  // Output from PLI task
                sink_valid,        // Input to PLI task
                pli_in_ready_sim,  // Output from PLI task
                sink_data);        // Input to PLI task
        end
    end

    // During simulation with MODEL_TECH, PLI signals drive the outputs
    assign source_valid = pli_out_valid_sim;
    assign source_data  = pli_out_data_sim;
    assign sink_ready   = pli_in_ready_sim;
    assign resetrequest = 1'b0; // PLI model doesn't generate resetrequest
    `else
    // During simulation without MODEL_TECH (or for synthesis), JTAG signals drive the outputs
    assign source_valid = jtag_source_valid;
    assign source_data  = jtag_source_data;
    assign sink_ready   = jtag_sink_ready;
    assign resetrequest = jtag_resetrequest;
    `endif
    // synthesis translate_on

    // For Synthesis (outside translate_off/on and `ifdef)
    // JTAG signals drive the outputs
    // Note: These assignments are redundant if `else block above is hit during synthesis,
    // but ensures correct connection if synthesis tool handles `ifdefs differently.
    `ifndef MODEL_TECH // Ensure these are considered for synthesis if MODEL_TECH is not defined
    assign source_valid = jtag_source_valid;
    assign source_data  = jtag_source_data;
    assign sink_ready   = jtag_sink_ready;
    assign resetrequest = jtag_resetrequest;
    `endif

endmodule