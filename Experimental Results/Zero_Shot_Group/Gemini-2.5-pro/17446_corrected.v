module timing(clk, pixclk,
              txtrow, txtcol,
              chrrow, chrcol,
              blank, hsync, vsync, blink);
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

  reg pclk;
  reg [9:0] hcnt;
  reg hblank, hsynch;
  reg [9:0] vcnt;
  reg vblank, vsynch;
  reg [5:0] bcnt;

  // Initial values for simulation/power-up
  initial begin
    pclk = 1'b0;
    hcnt = 10'd0;
    hblank = 1'b1; // Start in blanking
    hsynch = 1'b1; // Sync normally high (inactive low for VGA)
    vcnt = 10'd0;
    vblank = 1'b1; // Start in blanking
    vsynch = 1'b1; // Sync normally high (inactive low for VGA)
    bcnt = 6'd0;
    blink = 1'b0;
  end

  // Pixel clock generation (divides clk by 2)
  always @(posedge clk) begin
    pclk <= ~pclk;
  end
  assign pixclk = pclk;

  // Horizontal timing generation
  always @(posedge clk) begin
    // Use the rising edge of the pixel clock for timing updates
    if (pclk == 1'b1) begin
      if (hcnt == 10'd799) begin // End of horizontal line
        hcnt <= 10'd0;
      end else begin
        hcnt <= hcnt + 1;
      end

      // Horizontal Blanking logic (active high)
      // Starts slightly before active video ends, ends when active video starts
      if (hcnt == 10'd639) begin // End of active video
        hblank <= 1'b1;
      end else if (hcnt == 10'd799) begin // End of H blanking period (start of active video on next cycle)
         // Note: This transition happens when hcnt wraps to 0.
         // To make it active at hcnt=0, set it here or check hcnt == 0 below.
         // Let's set it low when count is 0 for clarity.
      end
       if (hcnt == 10'd0) begin // Start of active video
            hblank <= 1'b0;
       end


      // Horizontal Sync logic (active low, assuming standard VGA-like)
      // Sync pulse occurs within the blanking interval
      if (hcnt == 10'd655) begin // Start of HSync pulse
        hsynch <= 1'b0; // Active low
      end else if (hcnt == 10'd751) begin // End of HSync pulse
        hsynch <= 1'b1;
      end
    end
  end

  // Vertical timing generation
  always @(posedge clk) begin
    // Update vertical counter only at the end of a horizontal line
    if (pclk == 1'b1 && hcnt == 10'd799) begin
      if (vcnt == 10'd524) begin // End of vertical frame
        vcnt <= 10'd0;
      end else begin
        vcnt <= vcnt + 1;
      end

      // Vertical Blanking logic (active high)
      if (vcnt == 10'd479) begin // End of active vertical lines
        vblank <= 1'b1;
      end else if (vcnt == 10'd524) begin // End of V blanking period (start of active frame on next cycle)
         // Set low when vcnt wraps to 0
      end
      if (vcnt == 10'd0) begin // Start of active frame
            vblank <= 1'b0;
      end


      // Vertical Sync logic (active low, assuming standard VGA-like)
      // Sync pulse occurs within the vertical blanking interval
      if (vcnt == 10'd489) begin // Start of VSync pulse
        vsynch <= 1'b0; // Active low
      end else if (vcnt == 10'd491) begin // End of VSync pulse
        vsynch <= 1'b1;
      end
    end
  end

  // Blinking counter (updates once per frame)
  always @(posedge clk) begin
    // Update blink counter only at the end of a full frame
    if (pclk == 1'b1 && hcnt == 10'd799 && vcnt == 10'd524) begin
      if (bcnt == 6'd59) begin // Approx 1 Hz blink rate if frame rate is 60Hz
        bcnt <= 6'd0;
        // Toggle blink state - easier than setting high/low explicitly at different counts
        // blink <= ~blink; // Let's stick to the original logic structure for minimal changes
         blink <= 1'b1; // Set high at the start of the cycle
      end else begin
        bcnt <= bcnt + 1;
      end

      // Set blink low halfway through the blink cycle count
      if (bcnt == 6'd29) begin
        blink <= 1'b0;
      end
    end
  end

  // Combined Blanking signal (active high if either H or V blanking is active)
  assign blank = hblank | vblank;

  // Assign sync signals to outputs
  assign hsync = hsynch;
  assign vsync = vsynch;

  // Calculate character grid coordinates from pixel coordinates
  // Assuming 8x16 character cells (standard VGA text mode)
  // Note: indices might need adjustment depending on exact pixel mapping desired

  // Text row (based on vertical count, skipping lower bits for character row)
  // vcnt[8:4] -> 480 lines / 16 lines/char -> 30 rows (needs 5 bits)
  assign txtrow[4:0] = vcnt[8:4]; // Check calculation: 480 lines -> vcnt 0 to 479. vcnt[8:4] -> 0 to 29. OK.

  // Text column (based on horizontal count, skipping lower bits for character column)
  // hcnt[9:3] -> 640 pixels / 8 pixels/char -> 80 cols (needs 7 bits)
  assign txtcol[6:0] = hcnt[9:3]; // Check calculation: 640 pixels -> hcnt 0 to 639. hcnt[9:3] -> 0 to 79. OK.

  // Character row (pixel row within a character cell)
  // vcnt[3:0] -> 16 rows (0-15)
  assign chrrow[3:0] = vcnt[3:0];

  // Character column (pixel column within a character cell)
  // hcnt[2:0] -> 8 columns (0-7)
  assign chrcol[2:0] = hcnt[2:0];

endmodule