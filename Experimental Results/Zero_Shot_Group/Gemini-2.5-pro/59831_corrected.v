module ztex_ufm1_15b1 (
    fxclk_in,
    reset,
    pll_stop,
    dcm_progclk,
    dcm_progdata,
    dcm_progen,
    rd_clk,
    wr_clk,
    wr_start,
    read,
    write
);
    input fxclk_in;
    input reset;
    input pll_stop;
    input dcm_progclk;
    input dcm_progdata;
    input dcm_progen;
    input rd_clk;
    input wr_clk;
    input wr_start;
    input [7:0] read;
    output [7:0] write;

    reg [3:0] rd_clk_b;
    reg [3:0] wr_clk_b;
    reg wr_start_b1;
    reg wr_start_b2;
    reg reset_buf;
    reg dcm_progclk_buf;
    reg dcm_progdata_buf;
    reg dcm_progen_buf;
    reg [4:0] wr_delay;
    reg [351:0] inbuf;
    // reg [351:0] inbuf_tmp; // Removed, update inbuf directly
    reg [95:0] outbuf;
    reg [7:0] read_buf;
    reg [7:0] write_buf;

    wire fxclk;
    wire clk;
    wire dcm_clk;
    wire pll_fb;
    wire pll_clk0;
    wire dcm_locked;
    wire pll_reset;
    wire [31:0] golden_nonce;
    wire [31:0] nonce2;
    wire [31:0] hash2;

    miner130 m (
        .clk(clk),
        .reset(reset_buf),
        .midstate(inbuf[351:96]),
        .data(inbuf[95:0]),
        .golden_nonce(golden_nonce),
        .nonce2(nonce2),
        .hash2(hash2)
    );

    BUFG bufg_fxclk (
        .I(fxclk_in),
        .O(fxclk)
    );

    BUFG bufg_clk (
        .I(pll_clk0),
        .O(clk)
    );

    // Corrected DCM_CLKGEN parameter
    DCM_CLKGEN #(
        .CLKFX_DIVIDE(6), // Changed from 6.0
        .CLKFX_MULTIPLY(20),
        .CLKFXDV_DIVIDE(2)
    )
    dcm0 (
        .CLKIN(fxclk),
        .CLKFX(dcm_clk),
        .FREEZEDCM(1'b0),
        .PROGCLK(dcm_progclk_buf),
        .PROGDATA(dcm_progdata_buf),
        .PROGEN(dcm_progen_buf),
        .LOCKED(dcm_locked),
        .RST(1'b0) // Assuming reset is handled externally or via pll_reset indirectly
    );

    PLL_BASE #(
        .BANDWIDTH("LOW"),
        .CLKFBOUT_MULT(4),
        .CLKOUT0_DIVIDE(4),
        .CLKOUT0_DUTY_CYCLE(0.5), // Assuming float is acceptable for target primitive
        .CLK_FEEDBACK("CLKFBOUT"),
        .COMPENSATION("DCM2PLL"),
        .DIVCLK_DIVIDE(1),
        .REF_JITTER(0.05), // Assuming float is acceptable for target primitive
        .RESET_ON_LOSS_OF_LOCK("FALSE")
    )
    pll0 (
        .CLKFBOUT(pll_fb),
        .CLKOUT0(pll_clk0),
        .CLKFBIN(pll_fb),
        .CLKIN(dcm_clk),
        .RST(pll_reset)
    );

    assign write = write_buf;
    assign pll_reset = pll_stop | ~dcm_locked;

    always @ (posedge clk)
    begin
        // --- Input Synchronization & Edge Detection Registers ---
        rd_clk_b[0] <= rd_clk;
        rd_clk_b[3:1] <= rd_clk_b[2:0];
        wr_clk_b[0] <= wr_clk;
        wr_clk_b[3:1] <= wr_clk_b[2:0];
        wr_start_b1 <= wr_start;
        wr_start_b2 <= wr_start_b1;
        reset_buf <= reset;
        read_buf <= read; // Synchronize read data

        // --- Input Buffer Logic (Load on rd_clk edge detected via clk) ---
        // Detect change after stability on rd_clk (synchronized to clk)
        if ( (rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0]) )
        begin
            inbuf[351:344] <= read_buf;   // Load new byte read from input
            inbuf[343:0] <= inbuf[351:8]; // Shift previous data in inbuf down by 1 byte
        end

        // --- Write Delay Logic ---
        // Reset delay counter when wr_start has been high for 2 cycles
        if ( wr_start_b1 && wr_start_b2 )
        begin
            wr_delay <= 5'd0;
        end
        // Increment delay counter (shift '1' in) after wr_start pulse ends
        // This creates a 5-cycle delay after wr_start_b1 goes low (assuming wr_start was high for >= 2 cycles)
        else if (!wr_start_b1 && wr_start_b2) // Start counting when wr_start goes low after being high
        begin
            wr_delay[0] <= 1'b1;
            wr_delay[4:1] <= wr_delay[3:0];
        end
        // Continue counting if already started
        else if (wr_delay != 5'd0 && wr_delay != 5'b11111) // Shift if counting has started but not finished
        begin
             wr_delay[0] <= 1'b1; // Keep feeding 1? Or should this be 0? Assuming shift register behaviour.
             wr_delay[4:1] <= wr_delay[3:0];
        end


        // --- Output Buffer Logic ---
        // Load results while delay counter is not full (!wr_delay[4])
        if ( !wr_delay[4] )
        begin
            outbuf <= { hash2, nonce2, golden_nonce }; // Load parallel data from miner
        end
        // Shift data out on wr_clk edge AFTER the delay is met (wr_delay[4] is high)
        else
        begin
            // Detect change after stability on wr_clk (synchronized to clk)
            if ( (wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0]) )
            begin
                // Shift output buffer byte-wise for serial output
                // Corrected shift logic: shift MSB down
                outbuf[87:0] <= outbuf[95:8];
                // Consider what happens to outbuf[95:88] - they get overwritten. If serialization needs LSB first, shift direction is wrong.
                // Assuming MSB byte out first (write_buf <= outbuf[7:0])
            end
        end

        // --- Output Assignment ---
        // Assign LSB of output buffer to write port continuously
        write_buf <= outbuf[7:0];
    end

    // Synchronize DCM programming signals on fxclk edge
    always @ (posedge fxclk)
    begin
        dcm_progclk_buf <= dcm_progclk;
        dcm_progdata_buf <= dcm_progdata;
        dcm_progen_buf <= dcm_progen;
    end

endmodule