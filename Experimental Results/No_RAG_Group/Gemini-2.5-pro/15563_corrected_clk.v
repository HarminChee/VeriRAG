`timescale 1ps/1ps
module top_nto1_ddr_se_rx_corrected_clk ( // Renamed module
    input           reset,
    input   [7:0]   datain,
    input           clkin1, clkin2,
    input           test_clk,       // Added test clock
    input           test_mode,      // Added test mode signal
    output  [63:0]  dummy_out
);
    parameter integer     S = 8 ;
    parameter integer     D = 8 ;
    parameter integer     DS = (D*S)-1 ; // DS = 63

    wire            rst ;
    wire    [DS:0]  rxd ;
    reg     [DS:0]  rxr ;
    reg             state ;
    reg             bslip ;
    reg     [3:0]   count ;

    // Internal wires from instantiations
    wire            rxioclkp;
    wire            rxioclkn;
    wire            rx_serdesstrobe;
    wire            rx_bufg_x1; // The problematic internal clock

    wire            scan_clk; // Multiplexed clock for FFs

    assign rst = reset ;
    assign dummy_out = rxr ;

    // Clock selection mux: Use test_clk in test_mode, otherwise use functional clock rx_bufg_x1
    assign scan_clk = test_mode ? test_clk : rx_bufg_x1;

    // Instantiate the clock generation block
    // This block generates rx_bufg_x1 internally based on clkin1, clkin2
    serdes_1_to_n_clk_ddr_s8_se #(
        .S          (S)
    ) inst_clkin (
        .clkin1         (clkin1),
        .clkin2         (clkin2),
        .rxioclkp       (rxioclkp),
        .rxioclkn       (rxioclkn),
        .rx_serdesstrobe(rx_serdesstrobe),
        .rx_bufg_x1     (rx_bufg_x1) // Output: internally generated clock
    );

    // Instantiate the data deserializer block
    // Note: This block's internal clocking might also need DFT modification,
    // but here we focus on the top-level flops clocked by its output.
    serdes_1_to_n_data_ddr_s8_se #(
        .S          (S),
        .D          (D),
        .USE_PD     ("TRUE")
    ) inst_datain (
        .use_phase_detector (1'b1),
        .datain         (datain),
        .rxioclkp       (rxioclkp),
        .rxioclkn       (rxioclkn),
        .rxserdesstrobe (rx_serdesstrobe),
        .gclk           (rx_bufg_x1), // Internal clock connection remains the same
        .bitslip        (bslip),
        .reset          (rst),
        .data_out       (rxd),
        .debug_in       (2'b00),
        .debug          ()
    );

    // Logic for state, bslip, count control
    // Clocked by scan_clk (muxed functional/test clock) with asynchronous reset
    always @ (posedge scan_clk or posedge rst)
    begin
        if (rst == 1'b1) begin
            state <= 1'b0 ;
            bslip <= 1'b0 ;
            count <= 4'b0000 ;
        end
        else begin
            // State machine logic
            if (state == 0) begin
                // Check specific bits of incoming data
                if (rxd[DS:DS-3] != 4'h3) begin // Corrected indexing: [63:60]
                    bslip <= 1'b1 ; // Trigger bitslip
                    state <= 1'b1 ; // Move to state 1
                    count <= 4'b0000 ;
                end
                // else: Remain in state 0 if condition is met
            end
            else if (state == 1) begin // In state 1 (during/after bitslip adjustment)
                bslip <= 1'b0 ; // Deassert bitslip signal
                count <= count + 4'b0001 ; // Increment counter
                // Stay in state 1 for a duration determined by count
                if (count == 4'b1111) begin
                    state <= 1'b0; // Return to state 0 after count reaches max
                end
            end
            // Default case: if state is somehow not 0 or 1, behavior is undefined by this code.
        end
    end

    // Register for capturing the deserialized data
    // Clocked by scan_clk (muxed functional/test clock). No reset in original logic.
    always @ (posedge scan_clk)
    begin
        rxr <= rxd ; // Capture parallel data output from deserializer
    end

endmodule