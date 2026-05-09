`timescale 1ps/1ps

module top_nto1_ddr_se_rx (
    input               reset,
    input       [7:0]   datain,
    input               clkin1,
    input               clkin2,
    output      [63:0]  dummy_out
);

    parameter integer S = 8;
    parameter integer D = 8;
    parameter integer DS = (D * S) - 1;

    wire            rst;
    wire    [DS:0]  rxd;
    reg     [DS:0]  rxr;
    reg             state;
    reg             bslip;
    reg     [3:0]   count;

    // Internal wires for SERDES connections
    wire            rxioclkp;
    wire            rxioclkn;
    wire            rx_serdesstrobe;
    wire            rx_bufg_x1;

    assign rst = reset;
    assign dummy_out = rxr;

    serdes_1_to_n_clk_ddr_s8_se #(
        .S          (S)
    ) inst_clkin (
        .clkin1         (clkin1),
        .clkin2         (clkin2),
        .rxioclkp       (rxioclkp),
        .rxioclkn       (rxioclkn),
        .rx_serdesstrobe(rx_serdesstrobe),
        .rx_bufg_x1     (rx_bufg_x1)
    );

    serdes_1_to_n_data_ddr_s8_se #(
        .S                  (S),
        .D                  (D),
        .USE_PD             ("TRUE")
    ) inst_datain (
        .use_phase_detector (1'b1),
        .datain             (datain),
        .rxioclkp           (rxioclkp),
        .rxioclkn           (rxioclkn),
        .rxserdesstrobe     (rx_serdesstrobe), // Assuming port name is rxserdesstrobe based on instance connection
        .gclk               (rx_bufg_x1),
        .bitslip            (bslip),
        .reset              (rst),
        .data_out           (rxd),
        .debug_in           (2'b00),
        .debug              () // Connect to dummy wire if needed later
    );

    // State machine for bit slip control
    always @(posedge rx_bufg_x1 or posedge rst) begin
        if (rst == 1'b1) begin
            state <= 1'b0;
            bslip <= 1'b0;
            count <= 4'b0000;
        end else begin
            if (state == 1'b0) begin
                // Check for a specific pattern (e.g., sync word) - assuming 4'h3 is part of it
                if (rxd[DS : DS-3] != 4'h3) begin // Adjusted index based on DS
                    bslip <= 1'b1;
                    state <= 1'b1;
                    count <= 4'b0000;
                end else begin
                    // Pattern found, stay in state 0, deassert bslip (if asserted previously)
                    bslip <= 1'b0; // Ensure bslip is low if pattern matches
                    state <= 1'b0;
                    // count <= count; // No need to update count here
                end
            end else if (state == 1'b1) begin
                // In state 1, bslip was asserted on the previous cycle.
                // Deassert bslip and wait for a few cycles before checking again.
                bslip <= 1'b0;
                count <= count + 4'b0001;
                if (count == 4'b1111) begin // Wait for 16 cycles after slip
                    state <= 1'b0; // Go back to checking state
                end
                // else stay in state 1, keep counting
            end
        end
    end

    // Register the deserialized data
    always @(posedge rx_bufg_x1) begin
        rxr <= rxd;
    end

endmodule

// Note: The definitions for the submodules serdes_1_to_n_clk_ddr_s8_se
// and serdes_1_to_n_data_ddr_s8_se are assumed to exist elsewhere.
// The bit slip logic condition `rxd[DS : DS-3] != 4'h3` is based on the original code's
// intent (checking top 4 bits) and might need adjustment based on the actual
// expected data pattern and alignment.