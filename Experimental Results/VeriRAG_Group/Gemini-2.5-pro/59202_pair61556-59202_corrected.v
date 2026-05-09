`timescale 1 ns / 1 ns
module altera_pli_streaming (
    input             clk,
    input             reset_n,
    input             test_mode, // Added for DFT
    output reg        source_valid,
    output reg [7 : 0] source_data,
    input             source_ready,
    input             sink_valid,
    input [7 : 0]     sink_data,
    output reg        sink_ready,
    output reg        resetrequest
);
    parameter PLI_PORT = 50000;
    parameter PURPOSE = 0;

    reg pli_out_valid;
    reg pli_in_ready;
    reg [7 : 0] pli_out_data;

    // Sequential logic for PLI interface (active only in functional mode)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pli_out_valid <= 1'b0;
            pli_out_data <= 8'b0;
            pli_in_ready <= 1'b0;
        end
        else begin
            // Only execute PLI transaction in functional mode
            if (!test_mode) begin
                `ifdef MODEL_TECH
                // This remains non-synthesizable but is bypassed in test mode
                $do_transaction(
                    PLI_PORT,
                    pli_out_valid,
                    source_ready,
                    pli_out_data,
                    sink_valid,
                    pli_in_ready,
                    sink_data);
                `endif
            end else begin
                 // In test mode, these FFs would be controlled/observed via scan chain.
                 // No explicit action needed here assuming scan insertion handles them.
                 // Or potentially hold values if scan is not assumed:
                 // pli_out_valid <= pli_out_valid;
                 // pli_out_data <= pli_out_data;
                 // pli_in_ready <= pli_in_ready;
            end
        end
    end

    // JTAG interface instance (used for test mode path)
    wire [7:0] jtag_source_data;
    wire       jtag_source_valid;
    wire       jtag_sink_ready;
    wire       jtag_resetrequest;

    altera_jtag_dc_streaming #(.PURPOSE(PURPOSE)) jtag_dc_streaming (
       .clk(clk),
       .reset_n(reset_n),
       .source_data(jtag_source_data),
       .source_valid(jtag_source_valid),
       .sink_data(sink_data),
       .sink_valid(sink_valid),
       .sink_ready(jtag_sink_ready),
       .resetrequest(jtag_resetrequest)
       );

    // Combinational logic to select output based on mode
    always @* begin
       if (test_mode) begin // Test Mode: Use JTAG path
           source_valid = jtag_source_valid;
           source_data = jtag_source_data;
           sink_ready = jtag_sink_ready;
           resetrequest = jtag_resetrequest;
       end else begin // Functional Mode: Use PLI path results
           source_valid = pli_out_valid;
           source_data = pli_out_data;
           sink_ready = pli_in_ready;
           // Functional mode resetrequest is driven low as in original code's final assignment
           resetrequest = 1'b0;
       end
    end
endmodule