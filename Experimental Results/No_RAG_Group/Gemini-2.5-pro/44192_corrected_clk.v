`timescale 1ns / 1ps
module can_controller_corrected_clk // Renamed module as requested
    (
    input wire GCLK, // Primary Clock Input
    input wire RES,  // Primary Reset Input
    inout wire CAN,
    input wire [107:0] DIN,
    output reg [107:0] DOUT,
    input wire tx_start,
    output reg tx_ready = 1'b0,
    output reg rx_ready = 1'b0
    );

    wire tx;
    wire rx;
    wire cntmn;
    wire cntmn_ready;
    wire tsync; // Internal signal, potential clock source in original code

    reg [107:0] DIN_BUF = 108'd0;
    reg timeslot_start  = 1'b0; // Internal signal, potential clock source in original code
    reg timeslot_finish = 1'b0;
    reg have_arb = 1'b0; // Reset to known state
    reg tx_requested = 1'b0;
    reg [127:0] can_state = "RECEIVING"; // Reset to known state
    reg [63:0] bit_cnt = 64'd0;
    reg [107:0] rx_buf = 108'd0;

    // Registers to detect rising edges of internal signals synchronously to GCLK
    reg tsync_dly;
    reg timeslot_start_dly;
    wire tsync_posedge;
    wire timeslot_start_posedge;

    // Edge detection logic - All synchronous to GCLK
    always @(posedge GCLK) begin
        if (RES) begin
            tsync_dly <= 1'b0;
            timeslot_start_dly <= 1'b0;
        end else begin
            tsync_dly <= tsync;
            timeslot_start_dly <= timeslot_start;
        end
    end

    assign tsync_posedge = tsync & ~tsync_dly;
    assign timeslot_start_posedge = timeslot_start & ~timeslot_start_dly;

    // Main synchronous logic block - All registers clocked by GCLK
    always @(posedge GCLK) begin
        if (RES) begin
            // Reset conditions for all registers
            DIN_BUF <= 108'd0;
            tx_ready <= 1'b0;
            rx_ready <= 1'b0;
            tx_requested <= 1'b0;
            have_arb <= 1'b0; // Consistent reset state
            can_state <= "RECEIVING";
            bit_cnt <= 64'd0;
            rx_buf <= 108'd0;
            timeslot_start <= 1'b0;
            timeslot_finish <= 1'b0;
            DOUT <= 108'd0; // Ensure DOUT has defined reset state
        end else begin
            // Default assignments (can be overridden by specific conditions below)
            // Keep current values unless explicitly changed

            // Logic previously dependent on GCLK posedge (continuous arbitration check)
            if (cntmn_ready & cntmn) begin
                have_arb <= 1'b0;
                can_state <= "RECEIVING";
            end

            // Logic previously dependent on timeslot_start posedge (using synchronous edge detect)
            if (timeslot_start_posedge) begin
                if (tx_start) begin
                    DIN_BUF <= DIN;
                    tx_requested <= 1'b1;
                    // tx_ready <= 1'b0; // Removed redundant assignment, reset handles initial state
                end
                if (!cntmn_ready) begin
                    // This overrides the continuous check if edge occurs simultaneously
                    have_arb <= 1'b1;
                    can_state <= "TRANSMITTING";
                end
            end

            // Logic previously dependent on tsync posedge (using synchronous edge detect)
            if (tsync_posedge) begin
                 // Update rx_buf using current bit_cnt value before it increments/resets
                 rx_buf[bit_cnt] <= rx;

                 // Update bit_cnt based on *current* timeslot_finish state
                 if (timeslot_finish) begin
                     bit_cnt <= 64'd0;
                 end else begin
                     bit_cnt <= bit_cnt + 64'd1;
                 end

                 // Update timeslot flags based on *current* bit_cnt state
                 if (bit_cnt == 64'd106) begin
                     timeslot_finish <= 1'b1;
                     timeslot_start <= 1'b0;
                 end else if (bit_cnt == 64'd107) begin
                     timeslot_finish <= 1'b0;
                     timeslot_start <= 1'b1;
                 end else begin
                     // Clear flags if not at the specific bit counts on tsync edge
                     timeslot_finish <= 1'b0;
                     timeslot_start <= 1'b0;
                 end
            end // end if (tsync_posedge)

            // Logic previously dependent on GCLK posedge (output/status updates based on timeslot_finish state)
            // This logic runs every clock cycle when not in reset.
            if (timeslot_finish) begin // Check the state, not the edge
                 if (cntmn_ready & cntmn) begin // RX finished
                     rx_ready <= 1'b1;
                     DOUT <= rx_buf; // Update DOUT only when RX finishes
                     tx_ready <= 1'b0; // Ensure TX ready is low
                 end
                 else if (cntmn_ready & !cntmn) begin // TX finished
                     tx_ready <= 1'b1;
                     tx_requested <= 1'b0; // Clear request on successful TX finish
                     rx_ready <= 1'b0; // Ensure RX ready is low
                 end else begin
                     // If timeslot_finish is high but cntmn_ready is low (or other undefined state?)
                     tx_ready <= 1'b0;
                     rx_ready <= 1'b0;
                 end
            end else begin
                // When not finished, ready flags should be low (unless set by future finish condition)
                tx_ready <= 1'b0;
                rx_ready <= 1'b0;
                // DOUT retains its value until the next rx finish
            end

        end // end else (!RES)
    end // end always @(posedge GCLK)

    // Combinational assignment for tx output based on current state
    assign tx = (have_arb & tx_requested) ? DIN_BUF[bit_cnt] : 1'b1;

    // Instantiation of can_qsampler (assuming this module is DFT-friendly or black-boxed for DFT)
    can_qsampler CQS
    (
        .GCLK(GCLK),
        .RES(RES),
        .CAN(CAN),
        .din(tx),
        .dout(rx),
        .cntmn(cntmn),
        .cntmn_ready(cntmn_ready),
        .sync(tsync) // tsync is now just a signal, not used as a clock source in this module
    );

endmodule