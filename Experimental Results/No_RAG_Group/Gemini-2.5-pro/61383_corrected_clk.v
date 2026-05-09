// File: 1_corrected_clk.v
module jtag_fifo_corrected_clk (
    // Functional Ports
    input rx_clk,          // Primary input clock for RX domain - DFT OK
    input [11:0] rx_data,
    input wr_en, rd_en,
    output [8:0] tx_data,
    output tx_full, tx_empty,

    // DFT Ports (added)
    input test_clk,        // Primary test clock input for scan
    input scan_en,         // Scan enable signal (active high)
    input test_reset       // Primary asynchronous test reset (active high)
    // Note: scan_in/scan_out ports would be needed for full scan chain integration
);

    // Internal JTAG signals from BSCAN primitive
    wire jt_capture, jt_drck, jt_reset_bscan, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
    wire jt_tdo_internal; // Internal TDO signal feeding back to BSCAN

    // BSCAN Primitive - Generates JTAG signals including internal jt_tck
    // jt_tck is an internally generated clock, causing CLKNPI for registers clocked by it.
    BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
        .CAPTURE(jt_capture),
        .DRCK(jt_drck),
        .RESET(jt_reset_bscan), // JTAG reset output from BSCAN
        .RUNTEST(),             // Tied off/unused
        .SEL(jt_sel),
        .SHIFT(jt_shift),
        .TCK(jt_tck),           // Internal JTAG clock - CLKNPI source
        .TDI(jt_tdi),
        .TDO(jt_tdo_internal),  // Feed internal TDO logic result back to BSCAN
        .TMS(),                 // Tied off/unused (assuming controlled externally)
        .UPDATE(jt_update)
    );

    // --- DFT Modification: Clock Muxing ---
    // Select primary test_clk during scan mode (scan_en=1),
    // otherwise use the functional JTAG clock (jt_tck).
    wire muxed_clk;
    assign muxed_clk = scan_en ? test_clk : jt_tck;
    // --- End DFT Modification ---

    // Registers potentially involved in JTAG DR path
    reg captured_data_valid = 1'b0; // Flag indicating valid data captured from FIFO
    reg [12:0] dr;                  // JTAG Data Register implementation

    // FIFO signals
    wire tck_fifo_full;             // Full signal from tck_to_rx_clk FIFO
    wire rx_fifo_empty;             // Empty signal from rx_clk_to_tck FIFO
    wire [11:0] captured_data;      // Data output from rx_clk_to_tck FIFO

    // FIFO Instantiations
    // NOTE: These FIFOs still use jt_tck functionally on one clock port.
    // For full DFT compliance, these would typically require DFT wrappers
    // (e.g., clock muxing on jt_tck ports, bypass logic) or be handled
    // as black boxes by scan insertion tools. The fix below focuses on the
    // registers explicitly clocked by jt_tck outside the FIFOs.

    // FIFO: JTAG clock domain (jt_tck) to RX clock domain (rx_clk)
    fifo_generator_v8_2 tck_to_rx_clk_blk (
        .wr_clk(jt_tck), // Still uses internal clock functionally
        .rd_clk(rx_clk), // Uses primary clock - OK
        .din({7'd0, dr[8:0]}), // Data from JTAG DR (lower 9 bits)
        .wr_en(jt_update & jt_sel & !tck_fifo_full), // Write on JTAG Update-DR state
        .rd_en(rd_en & !tx_empty), // Read based on external control in rx_clk domain
        .dout(tx_data),         // Output data in rx_clk domain
        .full(tck_fifo_full),   // Full status in wr_clk domain
        .empty(tx_empty)        // Empty status in rd_clk domain
        // .rst() // Connect reset if available/needed
    );

    // FIFO: RX clock domain (rx_clk) to JTAG clock domain (jt_tck)
    fifo_generator_v8_2 rx_clk_to_tck_blk (
        .wr_clk(rx_clk), // Uses primary clock - OK
        .rd_clk(jt_tck), // Still uses internal clock functionally
        .din({4'd0, rx_data}), // Data from rx_data input (padded)
        .wr_en(wr_en & !tx_full), // Write based on external control in rx_clk domain
        .rd_en(jt_capture & ~rx_fifo_empty & ~jt_reset_bscan), // Read on JTAG Capture-DR state (if not empty/reset)
        .dout(captured_data),   // Output data in jt_tck domain (used for TDO shift)
        .full(tx_full),         // Full status in wr_clk domain
        .empty(rx_fifo_empty)   // Empty status in rd_clk domain
        // .rst() // Connect reset if available/needed
    );

    // JTAG TDO Logic: Selects data source for TDO shift register path
    // If valid data was captured from FIFO, shift out its LSB first.
    // Otherwise, shift out the LSB of the standard DR register.
    assign jt_tdo_internal = captured_data_valid ? captured_data[0] : dr[0];

    // Sequential logic for JTAG DR (dr) and capture state (captured_data_valid)
    // --- DFT Modification: Use muxed_clk and test_reset ---
    // Sensitivity list uses the muxed clock and the asynchronous primary test reset.
    always @ (posedge muxed_clk or posedge test_reset)
    begin
        if (test_reset == 1'b1) // Priority 1: Asynchronous primary test reset
        begin
            dr <= 13'd0;
            captured_data_valid <= 1'b0;
        end
        else if (scan_en == 1'b1) // Priority 2: Scan mode enabled (shift phase)
        begin
             // Scan shift logic should be inserted here by DFT tools.
             // This typically involves connecting to scan_in ports.
             // Without explicit scan_in, we might just hold state or shift dummy data.
             // Placeholder: Hold state during scan shift.
             dr <= dr;
             captured_data_valid <= captured_data_valid;
             // Proper implementation:
             // {captured_data_valid, dr} <= scan_in; // Combined chain example
        end
        else // Functional mode (scan_en == 0 and test_reset == 0)
        begin
            // Functional reset from BSCAN (assumed synchronous to jt_tck based on original logic structure)
            if (jt_reset_bscan == 1'b1)
            begin
                dr <= 13'd0;
                captured_data_valid <= 1'b0; // Ensure state is reset
            end
            // JTAG state machine actions (synchronous to jt_tck / muxed_clk)
            else if (jt_capture == 1'b1) // Capture-DR state
            begin
                // Check if data is available from FIFO to be captured
                captured_data_valid