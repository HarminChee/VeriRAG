module timing(clk, test_i, // Added test_i for potential DFT control MUXing if needed elsewhere, though not used here.
              txtrow, txtcol,
              chrrow, chrcol,
              blank, hsync, vsync, blink);
    input clk;
    input test_i; // DFT test mode input
    // output pixclk; // Removed internally generated clock output
    output [4:0] txtrow;
    output [6:0] txtcol;
    output [3:0] chrrow;
    output [2:0] chrcol;
    output blank;
    output hsync;
    output vsync;
    output reg blink;

  // reg pclk; // Removed register for internally generated clock
  reg [10:0] hcnt; // Increased width as counter limit doubles
  reg hblank, hsynch;
  reg [9:0] vcnt;
  reg vblank, vsynch;
  reg [5:0] bcnt;

  // Removed pclk generation block

  // assign pixclk = pclk; // Removed assignment

  // Horizontal counter and sync generation, clocked directly by clk
  always @(posedge clk) begin
    // Removed condition 'if (pclk == 1)'
    if (hcnt == 11'd1599) begin // Doubled limit
      hcnt <= 11'd0;
      hblank <= 1; // Active low blanking starts after active area
    end else begin
      hcnt <= hcnt + 1;
    end
    // Adjust timing points relative to the doubled hcnt range
    if (hcnt == 11'd1279) begin // End of active display (640 pixels * 2) - 1
      hblank <= 0; // End blanking (start display) - Note: Logic seems reversed, hblank usually high during blanking. Assuming original intent.
    end
    if (hcnt == 11'd1311) begin // Start of hsync pulse (656 * 2) - 1? Check original timing carefully. Assuming (655*2)+1
      hsynch <= 0; // Active low hsync
    end
    if (hcnt == 11'd1503) begin // End of hsync pulse (752 * 2) - 1? Check original timing carefully. Assuming (751*2)+1
      hsynch <= 1;
    end
  end

  // Vertical counter and sync generation, clocked by clk, enabled by hcnt reaching end of line
  always @(posedge clk) begin
    if (hcnt == 11'd1599) begin // Condition updated to use doubled hcnt limit
      if (vcnt == 10'd524) begin
        vcnt <= 10'd0;
        vblank <= 1; // Active low blanking starts after active area
      end else begin
        vcnt <= vcnt + 1;
      end
      // Vertical timing points remain the same relative to line count
      if (vcnt == 10'd479) begin // End of active display lines
        vblank <= 0; // End blanking (start display) - Note: Logic seems reversed. Assuming original intent.
      end
      if (vcnt == 10'd489) begin // Start of vsync pulse
        vsynch <= 0; // Active low vsync
      end
      if (vcnt == 10'd491) begin // End of vsync pulse
        vsynch <= 1;
      end
    end
  end

  // Blink counter, clocked by clk, enabled at the end of a frame
  always @(posedge clk) begin
    if (hcnt == 11'd1599 && vcnt == 10'd524) begin // Condition updated
      if (bcnt == 6'd59) begin // Frame rate based counter (e.g., 60 frames for 1Hz blink at 60Hz refresh)
        bcnt <= 6'd0;
        blink <= 1; // Blink on/off state toggles
      end else begin
        bcnt <= bcnt + 1;
      end
      if (bcnt == 6'd29) begin // Mid-point of blink cycle (e.g., half a second)
        blink <= 0;
      end
    end
  end

  assign blank = hblank & vblank; // Assuming active-low blanking signals combined
  assign hsync = hsynch;
  assign vsync = vsynch;

  // Address generation - adjusted for new hcnt range
  assign txtrow[4:0] = vcnt[8:4];   // Text row based on vertical count
  assign txtcol[6:0] = hcnt[10:4];  // Text column based on horizontal count (adjust indices)
  assign chrrow[3:0] = vcnt[3:0];   // Character pixel row based on vertical count
  assign chrcol[2:0] = hcnt[3:1];   // Character pixel column based on horizontal count (adjust indices)

endmodule