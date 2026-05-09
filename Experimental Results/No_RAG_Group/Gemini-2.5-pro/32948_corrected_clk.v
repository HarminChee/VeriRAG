// Added DFT inputs: test_clk, scan_en, test_rst_n
module jtag_comm_corrected_clk (
    input rx_hash_clk,
    input rx_golden_nonce_found,
    input [59:0] rx_golden_nonce,
    input test_clk,      // DFT Test Clock
    input scan_en,       // DFT Scan Enable
    input test_rst_n,    // DFT Asynchronous Reset (active low)
    output reg tx_new_work,
    output reg [55:0] tx_fixed_data = 56'd0,
    output reg [159:0] tx_target_hash = 160'd0,
    output reg [59:0] tx_start_nonce = 60'd0
);
    reg [56+160+60-1:0] current_job = 276'd0;
    reg [55:0] fixed_data = 56'd0;
    reg [159:0] target_hash = 160'd0;
    reg [59:0] start_nonce = 60'd0;
    reg new_work_flag = 1'b0;

    wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
    wire jt_tdo;

    // BSCAN primitive - Remains unchanged
    BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
        .CAPTURE(jt_capture),
        .DRCK(jt_drck),
        .RESET(jt_reset), // Functional JTAG reset
        .RUNTEST(),
        .SEL(jt_sel),
        .SHIFT(jt_shift),
        .TCK(jt_tck),     // JTAG Clock output from BSCAN
        .TDI(jt_tdi),
        .TDO(jt_tdo),
        .TMS(),
        .UPDATE(jt_update)
    );

    reg [3:0] addr = 4'hF;
    reg [37:0] dr;
    reg checksum;
    wire checksum_valid = ~checksum;
    wire jtag_we = dr[36];
    wire [3:0] jtag_addr = dr[35:32];
    reg [60:0] golden_nonce_buf, golden_nonce;

    // This block is clocked by a primary input - OK
    always @ (posedge rx_hash_clk)
    begin
        golden_nonce_buf <= {rx_golden_nonce_found, rx