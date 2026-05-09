`timescale 1 ns / 1 ns
module altera_pli_streaming_corrected_clk (
    clk,
    reset_n,
    test_mode, // Added test_mode input for DFT control
    source_valid,
    source_data,
    source_ready,
    sink_valid,
    sink_data,
    sink_ready,
    resetrequest
);
    parameter PLI_PORT = 50000;
    parameter PURPOSE = 0;
    input clk;          // Primary clock input - Good for DFT
    input reset_n;      // Primary asynchronous reset input - Good for DFT
    input test_mode;    // Input to select between functional and test paths
    output reg source_valid;
    output reg [7 : 0] source_data;
    input source_ready;
    input sink_valid;
    input [7 : 0] sink_data;
    output reg sink_ready;
    output reg resetrequest;

    // Internal registers driven by the primary clock 'clk'
    reg pli_out_valid;
    reg pli_in_ready;
    reg [7 : 0] pli_out_data;

    // Sequential block using primary clock and reset - DFT compliant
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pli_out_valid <= 1'b0;
            pli_out_data <= 8'b0;
            pli_in_ready <= 1'b0;
        end
        else begin
            // Conditional compilation for simulation behavior
            `ifdef MODEL_TECH
            // In a real scenario, PLI calls might need bypass logic for DFT hardware emulation,
            // but for simulation, this remains. DFT tools handle PLI differently.
            $do_transaction(
                PLI_PORT,
                pli_out_valid,
                source_ready,
                pli_out_data,
                sink_valid,
                pli_in_ready,
                sink_data);
            `else
            // Provide default behavior if not simulating with MODEL_TECH or if PLI needs stubbing
            // This part depends heavily on actual functional requirements vs. test stubbing needs.
            // For this example, we'll assume PLI values don't change without the $do_transaction call.
            // A more robust stub might assign default/test values.
            pli_out_valid <= pli_out_valid;
            pli_out_data  <= pli_out_data;
            pli_in_ready  <= pli_in_ready;
            `endif
        end
    end

    // JTAG interface signals
    wire [7:0] jtag_source_data;
    wire jtag_source_valid;
    wire jtag_sink_ready;
    wire jtag_resetrequest;

    // Instantiation of JTAG module - Ensure it's also DFT compliant internally
    // It uses the primary clock 'clk' and reset 'reset_n', which is good.
    altera_jtag_dc_streaming #(.PURPOSE(PURPOSE)) jtag_dc_streaming (
       .clk(clk),
       .reset_n(reset_n),
       .source_data(jtag_source_data),
       .source_valid(jtag_source_valid),
       .sink_data(sink_data), // Note: sink_data is shared input
       .sink_valid(sink_valid), // Note: sink_valid is shared input
       .sink_ready(jtag_sink_ready),
       .resetrequest(jtag_resetrequest)
       );

    // Combinational logic to select output source based on test_mode
    // This resolves the conflicting assignments in the original code
    // and provides a standard way to switch between functional and test paths.
    always @* begin
       if (test_mode) begin
           // Use JTAG path during test mode
           source_valid = jtag_source_valid;
           source_data = jtag_source_data;
           sink_ready = jtag_sink_ready;
           resetrequest = jtag_resetrequest;
       end else begin
           // Use PLI path during functional mode (non-test mode)
           source_valid = pli_out_valid;
           source_data = pli_out_data;
           sink_ready = pli_in_ready;
           resetrequest = 1'b0; // Original PLI path assigned 0
       end
    end

endmodule