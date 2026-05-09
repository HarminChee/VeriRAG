`timescale 1 ns / 1 ns
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
    parameter PURPOSE = 0;
    input clk;
    input reset_n;
    output reg source_valid;
    output reg [7 : 0] source_data;
    input source_ready;
    input sink_valid;
    input [7 : 0] sink_data;
    output reg sink_ready;
    output reg resetrequest;

`ifdef MODEL_TECH
    // PLI specific logic (simulation only)
    reg pli_out_valid;
    reg pli_in_ready;
    reg [7 : 0] pli_out_data;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pli_out_valid <= 1'b0;
            pli_out_data  <= 8'b0;
            pli_in_ready  <= 1'b0;
            // Reset output registers as well in simulation path
            source_valid <= 1'b0;
            source_data  <= 8'b0;
            sink_ready   <= 1'b0;
            resetrequest <= 1'b0;
        end
        else begin
            // $do_transaction is expected to update pli_* signals based on inputs
            $do_transaction(
                PLI_PORT,
                pli_out_valid,
                source_ready,
                pli_out_data,
                sink_valid,
                pli_in_ready,
                sink_data);
            // Assign outputs based on PLI signals for simulation
            source_valid <= pli_out_valid;
            source_data  <= pli_out_data;
            sink_ready   <= pli_in_ready;
            resetrequest <= 1'b0; // Assuming PLI path doesn't drive resetrequest
        end
    end

`else // Synthesizable hardware path using JTAG

    // JTAG related wires
    wire [7:0] jtag_source_data;
    wire       jtag_source_valid;
    wire       jtag_sink_ready;
    wire       jtag_resetrequest;

    // Instantiate JTAG block for hardware implementation
    // Note: altera_jtag_dc_streaming needs to be defined elsewhere and DFT clean
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

    // Register the outputs based on the JTAG block's outputs
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            source_valid <= 1'b0;
            source_data  <= 8'b0;
            sink_ready   <= 1'b0;
            resetrequest <= 1'b0;
        end else begin
            source_valid <= jtag_source_valid;
            source_data  <= jtag_source_data;
            sink_ready   <= jtag_sink_ready;
            resetrequest <= jtag_resetrequest;
        end
    end

`endif // MODEL_TECH

endmodule