module jtag_comm_corrected_acn (
    // Clocks and Reset
    input rst, // Added primary asynchronous reset input
    input rx_hash_clk,
    input jt_tck, // Assuming JTAG TCK is a primary clock input for this domain

    // JTAG Interface (Assuming these are primary inputs for DFT)
    input jt_tdi,
    input jt_sel,
    input jt_capture,
    input jt_shift,
    input jt_update,
    // Note: jt_drck, jt_reset, jt_tms are outputs from BSCAN, not primary inputs here.
    //       We removed jt_reset usage for user FFs.
    output jt_tdo,

    // Functional Inputs
    input rx_golden_nonce_found,
    input [59:0] rx_golden_nonce,

    // Functional Outputs
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

    // Internal JTAG signals from BSCAN
    wire bscan_capture;
    wire bscan_drck;
    wire bscan_reset; // Internal JTAG reset, NOT used for user logic FFs
    wire bscan_sel;
    wire bscan_shift;
    wire bscan_tdi;
    wire bscan_tdo;
    wire bscan_tms;
    wire bscan_update;

    // Instantiate BSCAN - Note: Its outputs connect to internal logic or top-level JTAG pins
    // We now use the primary input 'rst' for user logic reset.
    BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
        .CAPTURE(bscan_capture), // Connect to internal wire
        .DRCK(bscan_drck),       // Connect to internal wire
        .RESET(bscan_reset),     // Connect to internal wire (NOT the main reset)
        .RUNTEST(),              // Unconnected or tied low usually
        .SEL(bscan_sel),         // Connect to internal wire
        .SHIFT(bscan_shift),     // Connect to internal wire
        .TCK(jt_tck),            // Connect directly to primary input TCK
        .TDI(jt_tdi),            // Connect directly to primary input TDI
        .TDO(bscan_tdo),         // Output from BSCAN
        .TMS(bscan_tms),         // Connect to internal wire (driven by JTAG controller)
        .UPDATE(bscan_update)    // Connect to internal wire
    );

    // JTAG TAP Controller signals (now driven by primary inputs for testability)
    // In a real design these might be driven by a top-level JTAG TAP controller
    // For this example, we assume they are provided as primary inputs for DFT test control.
    // wire jt_capture = bscan_capture; // Or directly from primary input if needed
    // wire jt_shift   = bscan_shift;   // Or directly from primary input if needed
    // wire jt_update  = bscan_update;  // Or directly from primary input if needed
    // wire jt_sel     = bscan_sel;     // Or directly from primary input if needed
    // jt_reset is NO LONGER used for user FF reset.

    reg [3:0] addr = 4'hF;
    reg [37:0] dr;
    reg checksum;
    wire checksum_valid = ~checksum;
    wire jtag_we = dr[36];
    wire [3:0] jtag_addr = dr[35:32];
    reg [60:0] golden_nonce_buf, golden_nonce;

    // Golden Nonce Input Sync
    always @ (posedge rx_hash_clk or posedge rst) // Use primary reset
    begin
        if (rst) begin
            golden_nonce_buf <= 61'd0;
            golden_nonce     <= 61'd0;
        end else begin
            golden_nonce_buf <= {rx_golden_nonce_found, rx_golden_nonce};
            golden_nonce <= golden_nonce_buf;
        end
    end

    // JTAG Data Register Logic
    // Use primary input 'rst' for asynchronous reset
    assign jt_tdo = dr[0]; // TDO comes from the shift register
    always @ (posedge jt_tck or posedge rst) // Changed jt_reset to rst
    begin
        if (rst == 1'b1) // Use primary input 'rst'
        begin
            dr <= 38'd0;
            checksum <= 1'b0; // Initialize checksum
            addr <= 4'hF;
            target_hash <= 160'd0;
            fixed_data <= 56'd0;
            start_nonce <= 60'd0;
            current_job <= 276'd0;
            new_work_flag <= 1'b0;
        end
        // Use primary input control signals directly
        else if (jt_capture == 1'b1) // Use primary input jt_capture
        begin
            checksum <= 1'b1; // Start checksum calculation (XOR with TDI bits)
            dr[37:32] <= 6'd0; // Clear control bits on capture
            addr <= 4'hF;      // Reset address pointer for read
            case (addr) // Load data into DR based on previous address for TDO shift-out
                4'h0: dr[31:0] <= 32'h01000100; // Version/ID
                4'h1: dr[31:0] <= target_hash[31:0];
                4'h2: dr[31:0] <= target_hash[63:32];
                4'h3: dr[31:0] <= target_hash[95:64];
                4'h4: dr[31:0] <= target_hash[127:96];
                4'h5: dr[31:0] <= target_hash[159:128];
                4'h6: dr[31:0] <= fixed_data[31:0];
                4'h7: dr[31:0] <= {8'd0, fixed_data[55:32]}; // Pad upper bits
                4'h8: dr[31:0] <= start_nonce[31:0];
                4'h9: dr[31:0] <= {4'd0, start_nonce[59:32]}; // Pad upper bits
                4'hA: dr[31:0] <= 32'hFFFFFFFF; // Unused/Reserved
                4'hB: dr[31:0] <= 32'hFFFFFFFF; // Unused/Reserved
                4'hC: dr[31:0] <= 32'h55555555; // Test pattern
                4'hD: dr[31:0] <= golden_nonce[31:0];
                4'hE: dr[31:0] <= {3'd0, golden_nonce[60:32]}; // Pad upper bits
                4'hF: dr[31:0] <= 32'hFFFFFFFF; // Default/Invalid Address Read
                default: dr[31:0] <= 32'hFFFFFFFF;
            endcase
        end
        else if (jt_shift == 1'b1) // Use primary input jt_shift
        begin
            dr <= {jt_tdi, dr[37:1]}; // Shift in TDI
            checksum <= checksum ^ jt_tdi; // Update checksum
        end
        // Update state uses primary input jt_update
        else if (jt_update == 1'b1 && checksum_valid) // Use primary input jt_update
        begin
            addr <= jtag_addr; // Update address register for next capture
            if (jtag_we) // Write enable is active
            begin
                case (jtag_addr)
                    // Write operations based on shifted-in data (dr)
                    4'h1: target_hash[31:0] <= dr[31:0];
                    4'h2: target_hash[63:32] <= dr[31:0];
                    4'h3: target_hash[95:64] <= dr[31:0];
                    4'h4: target_hash[127:96] <= dr[31:0];
                    4'h5: target_hash[159:128] <= dr[31:0];
                    4'h6: fixed_data[31:0] <= dr[31:0];
                    4'h7: fixed_data[55:32] <= dr[23:0]; // Only 24 bits valid
                    4'h8: start_nonce[31:0] <= dr[31:0];
                    4'h9: start_nonce[59:32] <= dr[27:0]; // Only 28 bits valid
                    // Note: Addr 0, A, B, C, D, E, F are read-only or test
                endcase
            end
            // Check if the last part of the job was written (Addr 9)
            if (jtag_we && jtag_addr == 4'h9)
            begin
                // Combine the newly written data with previously written parts
                // Assuming target_hash, fixed_data, start_nonce[31:0] were written before addr 9
                current_job <= {dr[27:0], start_nonce[31:0], fixed_data, target_hash};
                new_work_flag <= ~new_work_flag; // Toggle flag to indicate new job loaded
            end
        end
    end

    // Job Output Logic (Synchronous to rx_hash_clk)
    reg [275:0] tx_buffer = 276'd0;
    reg [2:0] tx_work_flag = 3'b0;
    always @ (posedge rx_hash_clk or posedge rst) // Use primary reset
    begin
        if (rst) begin
            tx_buffer <= 276'd0;
            {tx_start_nonce, tx_fixed_data, tx_target_hash} <= 276'd0;
            tx_work_flag <= 3'b0;
            tx_new_work <= 1'b0;
        end else begin
            tx_buffer <= current_job; // Sample the job loaded via JTAG
            {tx_start_nonce, tx_fixed_data, tx_target_hash} <= tx_buffer; // Assign to outputs
            tx_work_flag <= {tx_work_flag[1:0], new_work_flag}; // Sync flag to output clock domain
            tx_new_work <= tx_work_flag[2] ^ tx_work_flag[1]; // Generate pulse on flag change
        end
    end

endmodule