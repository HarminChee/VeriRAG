module ztex_ufm1_15d3 (
    input        fxclk_in,
    input        reset,
    input        clk_reset,
    input        pll_stop,
    input        dcm_progclk,
    input        dcm_progdata,
    input        dcm_progen,
    input        rd_clk,
    input        wr_clk,
    input        wr_start,
    input  [7:0] read,
    output [7:0] write,
    input        test_mode // Added test_mode input for DFT
);

    // Internal signals
    reg [3:0] rd_clk_b;
    reg [3:0] wr_clk_b;
    reg wr_start_b1, wr_start_b2;
    // reset_buf removed, using primary 'reset' directly for miner253
    reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
    reg [4:0] wr_delay;
    reg [351:0] inbuf, inbuf_tmp;
    reg [95:0] outbuf;
    reg [7:0] read_buf, write_buf;

    wire fxclk, clk, dcm_clk, pll_fb, pll_clk0, dcm_locked, pll_reset, pll_reset_func;
    wire [2:1] dcm_status;
    wire [31:0] golden_nonce, nonce2, hash2;
    wire dft_clk; // Added wire for DFT clock muxing

    // Instantiation of miner253 (Assuming definition exists elsewhere or treated as blackbox)
    miner253 m (
        .clk(dft_clk), // Use DFT clock
        .reset(reset), // Use primary input reset directly
        .midstate(inbuf[351:96]),
        .data(inbuf[95:0]),
        .golden_nonce(golden_nonce),
        .nonce2(nonce2),
        .hash2(hash2)
    );

    // Clock Buffers
    BUFG bufg_fxclk (
        .I(fxclk_in),
        .O(fxclk)
    );

    BUFG bufg_clk (
        .I(pll_clk0),
        .O(clk)
    );

    // DCM Instantiation
    DCM_CLKGEN #(
        .CLKFX_DIVIDE(4), // Use integer format for parameter
        .CLKFX_MULTIPLY(32),
        .CLKFXDV_DIVIDE(2),
        .CLKIN_PERIOD(20.8333)
    ) dcm0 (
        .CLKIN(fxclk),
        .CLKFXDV(dcm_clk),
        .FREEZEDCM(1'b0),
        .PROGCLK(dcm_progclk_buf),
        .PROGDATA(dcm_progdata_buf),
        .PROGEN(dcm_progen_buf),
        .LOCKED(dcm_locked),
        .STATUS(dcm_status),
        .RST(clk_reset) // Use primary input reset for DCM
    );

    // PLL Instantiation
    PLL_BASE #(
        .BANDWIDTH("LOW"),
        .CLKFBOUT_MULT(4),
        .CLKOUT0_DIVIDE(4),
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLK_FEEDBACK("CLKFBOUT"),
        .COMPENSATION("INTERNAL"),
        .DIVCLK_DIVIDE(1),
        .REF_JITTER(0.10),
        .RESET_ON_LOSS_OF_LOCK("FALSE")
    ) pll0 (
        .CLKFBOUT(pll_fb),
        .CLKOUT0(pll_clk0),
        .CLKFBIN(pll_fb),
        .CLKIN(dcm_clk),
        .RST(pll_reset) // Use muxed reset for PLL
    );

    // Assignments
    assign write = write_buf;
    // Functional PLL reset logic
    assign pll_reset_func = pll_stop | ~dcm_locked | clk_reset | dcm_status[2];
    // Mux PLL reset: Use primary clk_reset in test_mode, functional reset otherwise
    assign pll_reset = test_mode ? clk_reset : pll_reset_func;

    // DFT Clock Mux: Select primary clock fxclk in test_mode, functional clock clk otherwise
    assign dft_clk = test_mode ? fxclk : clk;

    // Main Sequential Logic Block (Clocked by DFT Muxed Clock)
    always @ (posedge dft_clk) begin
        // Input buffer logic
        // Detect rising edge of rd_clk by sampling
        if ((rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0])) begin
            inbuf_tmp[351:344] <= read_buf;
            inbuf_tmp[343:0] <= inbuf_tmp[351:8]; // Shift register behavior
        end
        inbuf <= inbuf_tmp; // Update main buffer

        // Write start delay logic
        if (wr_start_b1 && wr_start_b2) begin // Assuming wr_start is active high pulse, detect end
            wr_delay <= 5'd0;
        end else begin // Start delay counter or hold if wr_start not asserted properly
           // Check if wr_start is asserted to start delay, simple increment shown
           // Logic might need refinement based on exact wr_start behavior
           // Assuming delay starts when wr_start goes high (sampled by wr_start_b1/b2)
           // This counter seems to count continuously until wr_start sequence is met.
           // Let's assume it shifts '1' in when wr_start is not asserted after being asserted.
           // The original logic seems to shift '1' in always unless wr_start was high for 2 cycles.
           // Keeping original logic:
            wr_delay[0] <= 1'b1;
            wr_delay[4:1] <= wr_delay[3:0];
        end

        // Output buffer logic
        if (!wr_delay[4]) begin // Load output buffer when delay not finished? Seems inverted logic.
                               // Assuming wr_delay[4] signals 'ready to output'
                               // Let's assume original intent: Load when wr_delay[4] is low.
            outbuf <= { hash2, nonce2, golden_nonce };
        end else begin // Shift out data when delay is finished (wr_delay[4] is high)
            // Detect rising edge of wr_clk by sampling
            if ((wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0])) begin
                outbuf[87:0] <= outbuf[95:8]; // Shift register behavior
            end
        end

        // Sample inputs/update outputs
        read_buf <= read;
        write_buf <= outbuf[7:0]; // Output lowest byte of shift register

        // Sample clock and control signals
        rd_clk_b[0] <= rd_clk;
        rd_clk_b[3:1] <= rd_clk_b[2:0]; // Shift register for rd_clk sampling
        wr_clk_b[0] <= wr_clk;
        wr_clk_b[3:1] <= wr_clk_b[2:0]; // Shift register for wr_clk sampling
        wr_start_b1 <= wr_start;
        wr_start_b2 <= wr_start_b1; // Sample wr_start over two cycles
        // reset_buf sampling removed
    end

    // Logic for DCM Programming Interface (Clocked by Primary Clock Derived fxclk)
    // This part is DFT clean as it uses fxclk
    always @ (posedge fxclk) begin
        dcm_progclk_buf <= dcm_progclk;
        dcm_progdata_buf <= dcm_progdata;
        dcm_progen_buf <= dcm_progen;
    end

endmodule