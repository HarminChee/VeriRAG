module timing_corrected_cdf (
    // Original Ports
    clk, pixclk,
    txtrow, txtcol,
    chrrow, chrcol,
    blank, hsync, vsync, blink,

    // DFT Ports
    test_mode, // Scan Enable / Test Mode signal
    scan_in,   // Scan input for the pclk flop
    scan_out   // Scan output for the pclk flop
);

    input clk;
    output pixclk;
    output [4:0] txtrow;
    output [6:0] txtcol;
    output [3:0] chrrow;
    output [2:0] chrcol;
    output blank;
    output hsync;
    output vsync;
    output reg blink;

    // DFT Ports
    input test_mode;
    input scan_in;   // Assuming this is the scan input specifically for pclk
    output scan_out; // Assuming this is the scan output specifically for pclk

    reg pclk;
    reg [9:0] hcnt;
    reg hblank, hsynch;
    reg [9:0] vcnt;
    reg vblank, vsynch;
    reg [5:0] bcnt;

    // DFT Modification for pclk generation (potential CDFDAT source)
    // In test_mode, the pclk flop gets data from scan_in, otherwise it toggles.
    wire pclk_next;
    assign pclk_next = test_mode ? scan_in : ~pclk; // Mux for D input based on test_mode

    always @(posedge clk) begin
        pclk <= pclk_next;
    end

    // Assign scan out for the pclk flop
    assign scan_out = pclk;

    // Original logic (mostly unchanged, but now uses the DFT-friendly pclk)
    assign pixclk = pclk;

    // The clock gating using 'pclk == 1' might still be a DFT issue (requiring ICG cells),
    // but the CDFDAT violation on the pclk flop itself is addressed.
    always @(posedge clk) begin
        // This logic block is only active when pclk is high in functional mode.
        // In test mode (test_mode=1), pclk is controlled via scan_in,
        // but the clock gating condition (pclk == 1) still applies.
        // Proper DFT insertion would typically bypass or control this gate during scan shift.
        // However, based *only* on fixing the specified CDFDAT on pclk generation:
        if (!test_mode && pclk == 1'b1) begin // Functional mode clock gate enable
          if (hcnt == 10'd799) begin
            hcnt <= 10'd0;
            hblank <= 1;
          end else begin
            hcnt <= hcnt + 1;
          end
          if (hcnt == 10'd639) begin
            hblank <= 0;
          end
          if (hcnt == 10'd655) begin
            hsynch <= 0;
          end
          if (hcnt == 10'd751) begin
            hsynch <= 1;
          end
        end else if (test_mode) begin
          // In test mode, assume these flops are part of the scan chain
          // and their inputs are controlled by preceding scan elements (not shown here).
          // For simplicity, just hold value or connect to scan inputs if available.
          // This example doesn't add scan chains for hcnt, hblank, hsynch etc.
          // A full DFT insertion would handle these.
          // To make this compilable and minimally functional for the prompt's scope:
          // We can just prevent updates based on pclk during test_mode, assuming
          // scan controls these flops independently.
          // Or, more realistically, the clock gate itself would be controlled.
          // Let's refine to show explicit scan control might be needed:
          // If scan_enable (test_mode) is high, these should ideally get data from scan chain.
          // Since that's not provided, we leave the functional path gated,
          // implying scan logic would bypass this.
          // A simplified view might be:
          // hcnt <= test_mode ? scan_in_hcnt : (pclk ? (hcnt == 799 ? 0 : hcnt+1) : hcnt);
          // But sticking to fixing only the pclk CDFDAT:
          if (pclk == 1'b1) begin // Retain original structure, acknowledging limitations
            // This path might not behave correctly during scan unless clock gate is handled
            if (hcnt == 10'd799) begin
                hcnt <= 10'd0;
                hblank <= 1;
            end else begin
                hcnt <= hcnt + 1;
            end
            if (hcnt == 10'd639) begin
                hblank <= 0;
            end
            if (hcnt == 10'd655) begin
                hsynch <= 0;
            end
            if (hcnt == 10'd751) begin
                hsynch <= 1;
            end
          end
        end
    end

    always @(posedge clk) begin
       if (!test_mode && pclk == 1'b1 && hcnt == 10'd799) begin // Functional mode clock gate enable
            if (vcnt == 10'd524) begin
                vcnt <= 10'd0;
                vblank <= 1;
            end else begin
                vcnt <= vcnt + 1;
            end
            if (vcnt == 10'd479) begin
                vblank <= 0;
            end
            if (vcnt == 10'd489) begin
                vsynch <= 0;
            end
            if (vcnt == 10'd491) begin
                vsynch <= 1;
            end
       end else if (test_mode) begin
            // Similar comment as above regarding scan control for these flops
            if (pclk == 1'b1 && hcnt == 10'd799) begin // Retain original structure
              if (vcnt == 10'd524) begin
                  vcnt <= 10'd0;
                  vblank <= 1;
              end else begin
                  vcnt <= vcnt + 1;
              end
              if (vcnt == 10'd479) begin
                  vblank <= 0;
              end
              if (vcnt == 10'd489) begin
                  vsynch <= 0;
              end
              if (vcnt == 10'd491) begin
                  vsynch <= 1;
              end
            end
       end
    end

    always @(posedge clk) begin
       if (!test_mode && pclk == 1'b1 && hcnt == 10'd799 && vcnt == 10'd524) begin // Functional mode clock gate enable
            if (bcnt == 6'd59) begin
                bcnt <= 6'd0;
                blink <= 1;
            end else begin
                bcnt <= bcnt + 1;
            end
            if (bcnt == 6'd29) begin
                blink <= 0;
            end
       end else if (test_mode) begin
            // Similar comment as above regarding scan control for these flops
            if (pclk == 1'b1 && hcnt == 10'd799 && vcnt == 10'd524) begin // Retain original structure
              if (bcnt == 6'd59) begin
                  bcnt <= 6'd0;
                  blink <= 1;
              end else begin
                  bcnt <= bcnt + 1;
              end
              if (bcnt == 6'd29) begin
                  blink <= 0;
              end
            end
       end
    end

    assign blank = hblank & vblank;
    assign hsync = hsynch;
    assign vsync = vsynch;

    assign txtrow[4:0] = vcnt[8:4];
    assign txtcol[6:0] = hcnt[9:3];
    assign chrrow[3:0] = vcnt[3:0];
    assign chrcol[2:0] = hcnt[2:0];

endmodule