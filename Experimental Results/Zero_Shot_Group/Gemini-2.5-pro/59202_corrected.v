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
    resetrequest
);
    parameter PLI_PORT = 50000;
    parameter PURPOSE = 0; // Parameter for the JTAG streaming block

    input clk;
    input reset_n;
    output reg source_valid; // Output driven combinatorially based on selection
    output reg [7 : 0] source_data; // Output driven combinatorially based on selection
    input source_ready; // Input from downstream component
    input sink_valid;   // Input from upstream component
    input [7 : 0] sink_data; // Input from upstream component
    output reg sink_ready; // Output driven combinatorially based on selection
    output reg resetrequest; // Output driven combinatorially based on selection

    // Internal registers to hold PLI state updated at clock edge
    reg pli_source_valid_reg;
    reg [7:0] pli_source_data_reg;
    reg pli_sink_ready_reg;
    // Note: resetrequest is usually from JTAG, PLI mode might not assert it.

    // PLI Interaction (only active during simulation with MODEL_TECH)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pli_source_valid_reg <= 1'b0;
            pli_source_data_reg <= 8'b0;
            pli_sink_ready_reg <= 1'b0;
        end else begin
            `ifdef MODEL_TECH
            // Assume $do_transaction updates the regs passed by reference based on inputs
            // Check specific simulator documentation for exact $do_transaction signature
            // Assuming: (port, out_valid_reg, out_data_reg, in_ready_sig, in_valid_sig, in_data_sig, out_ready_reg)
            $do_transaction(
                PLI_PORT,
                pli_source_valid_reg, // Modified by PLI task
                pli_source_data_reg,  // Modified by PLI task
                source_ready,         // Input to PLI task
                sink_valid,           // Input to PLI task
                sink_data,            // Input to PLI task
                pli_sink_ready_reg    // Modified by PLI task
            );
            `else
            // Keep PLI state registers low if not in PLI mode
            // This prevents unknown states propagating if MODEL_TECH isn't defined during sim
            pli_source_valid_reg <= 1'b0;
            pli_source_data_reg <= 8'b0;
            pli_sink_ready_reg <= 1'b0;
            `endif
        end
    end

    // JTAG Interface Signals
    wire [7:0] jtag_source_data;
    wire jtag_source_valid;
    wire jtag_sink_ready;
    wire jtag_resetrequest;

    // JTAG Streaming DC Instantiation (always present)
    // Ensure 'altera_jtag_dc_streaming' module definition is available
    altera_jtag_dc_streaming #(
        .PURPOSE(PURPOSE)
    ) jtag_dc_streaming_inst (
       .clk(clk),
       .reset_n(reset_n),
       // JTAG Source Interface (Output from JTAG core -> Module Output)
       .source_data(jtag_source_data),   // Output from JTAG core
       .source_valid(jtag_source_valid), // Output from JTAG core
       .source_ready(source_ready),      // Input to JTAG core (from downstream)
       // JTAG Sink Interface (Module Input -> Input to JTAG core)
       .sink_data(sink_data),            // Input to JTAG core (from upstream)
       .sink_valid(sink_valid),          // Input to JTAG core (from upstream)
       .sink_ready(jtag_sink_ready),     // Output from JTAG core (to upstream)
       // JTAG Reset Request
       .resetrequest(jtag_resetrequest)  // Output from JTAG core
    );

    // Combinational logic to select between PLI and JTAG based on simulation mode
    always @* begin
       `ifdef MODEL_TECH
           // Simulation with PLI enabled: Use PLI signals
           source_valid = pli_source_valid_reg;
           source_data = pli_source_data_reg;
           sink_ready = pli_sink_ready_reg;
           resetrequest = 1'b0; // Typically no reset request from PLI
       `else
           // No PLI (e.g., synthesis or other simulator): Use JTAG signals
           source_valid = jtag_source_valid;
           source_data = jtag_source_data;
           sink_ready = jtag_sink_ready;
           resetrequest = jtag_resetrequest;
       `endif
    end

endmodule