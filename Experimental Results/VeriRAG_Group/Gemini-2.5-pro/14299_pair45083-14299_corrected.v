module clk_reset(clk_in, reset_inout_n,
                 sdram_clk, sdram_fb,
                 clk, clk_ok, reset,
                 // Added DFT Ports
                 test_mode, scan_clk, scan_reset); // Add test_mode, scan_clk, scan_reset inputs
    input clk_in;
    inout reset_inout_n;
    output sdram_clk;
    input sdram_fb;
    output clk;
    output clk_ok;
    output reset;
    // Added DFT Ports
    input test_mode;
    input scan_clk;
    input scan_reset;

  wire clk_in_buf;
  wire int_clk;
  wire int_locked;
  wire ext_rst_n;
  wire ext_fb;
  wire ext_locked;
  reg reset_p_n;
  reg reset_s_n;
  reg [23:0] reset_counter;
  wire reset_counting;

  // Wires for functional clocks before output muxing
  wire func_clk;
  wire func_sdram_clk;
  // Wire for muxed external DCM reset
  wire dft_ext_dcm_reset;
  // Wire for potentially modified clk_ok in test mode
  wire func_clk_ok; // Original clk_ok logic output


  IBUFG clk_in_buffer(
    .I(clk_in),
    .O(clk_in_buf)
  );

  // Internal DCM - Add controllable reset
  DCM int_dcm(
    .CLKIN(clk_in_buf),
    .CLKFB(func_clk), // Feedback functional clock
    .RST(test_mode ? scan_reset : 1'b0), // Use controllable reset in test mode
    .CLK0(int_clk),
    .LOCKED(int_locked)
  );

  BUFG int_clk_buffer(
    .I(int_clk),
    .O(func_clk) // Output functional clock
  );

  SRL16 ext_dll_rst_gen(
    .CLK(clk_in_buf), // Clocked by primary-derived clock
    .D(int_locked),
    .Q(ext_rst_n),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1)
  );
  defparam ext_dll_rst_gen.INIT = 16'h0000;

  IBUFG ext_fb_buffer(
    .I(sdram_fb),
    .O(ext_fb)
  );

  // Mux the reset for ext_dcm to fix ACNCPI
  assign dft_ext_dcm_reset = test_mode ? scan_reset : ~ext_rst_n;

  DCM ext_dcm(
    .CLKIN(clk_in_buf),
    .CLKFB(ext_fb),
    .RST(dft_ext_dcm_reset), // Use muxed reset
    .CLK0(func_sdram_clk), // Output functional clock
    .LOCKED(ext_locked)
  );

  // Original clk_ok logic
  assign func_clk_ok = int_locked & ext_locked;

  // Mux the clock outputs for testability (addressing potential downstream CLKNPI)
  assign clk = test_mode ? scan_clk : func_clk;
  assign sdram_clk = test_mode ? scan_clk : func_sdram_clk;

  // Mux or bypass clk_ok output for test mode
  assign clk_ok = test_mode ? 1'b1 : func_clk_ok; // Force OK in test mode


  assign reset_counting = (reset_counter == 24'hFFFFFF) ? 0 : 1;
  assign reset_inout_n = (reset_counter[23] == 0) ? 1'b0 : 1'bz;

  // Reset counter logic - clocked by clk_in_buf (OK)
  // Condition uses clk_ok, which is now muxed/forced in test mode.
  always @(posedge clk_in_buf) begin
    reset_p_n <= reset_inout_n;
    reset_s_n <= reset_p_n;
    if (reset_counting == 1) begin
      reset_counter <= reset_counter + 1;
    end else begin
      // Use the potentially modified clk_ok signal (forced to 1 in test mode)
      if (~reset_s_n | ~clk_ok) begin
        reset_counter <= 24'h000000;
      end
    end
  end

  assign reset = reset_counting;
endmodule