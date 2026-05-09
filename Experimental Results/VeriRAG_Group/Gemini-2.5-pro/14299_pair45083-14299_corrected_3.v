module clk_reset(clk_in, reset_pad_in_n, reset_pad_out_n, reset_pad_oen,
                 sdram_clk, sdram_fb,
                 clk, clk_ok, reset,
                 // Added DFT Ports
                 test_mode, scan_clk, scan_reset); // Add test_mode, scan_clk, scan_reset inputs
    input clk_in;
    // Replace inout reset_inout_n with separate I/O/OE for clarity and tool compatibility
    input  reset_pad_in_n;  // Input from the pad buffer
    output reset_pad_out_n; // Output data to the pad buffer
    output reset_pad_oen;   // Output enable for the pad buffer (active high)

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
  // Wire for functional clk_ok logic output
  wire func_clk_ok;
  // Wire for muxed internal DCM reset
  wire dft_int_dcm_reset;


  IBUFG clk_in_buffer(
    .I(clk_in),
    .O(clk_in_buf)
  );

  // Mux the reset for int_dcm
  assign dft_int_dcm_reset = test_mode ? scan_reset : 1'b0;

  // Internal DCM - Add controllable reset
  DCM int_dcm(
    .CLKIN(clk_in_buf),
    .CLKFB(func_clk), // Feedback functional clock
    .RST(dft_int_dcm_reset), // Use controllable reset in test mode
    .CLK0(int_clk),
    .LOCKED(int_locked)
  );

  BUFG int_clk_buffer(
    .I(int_clk),
    .O(func_clk) // Output functional clock
  );

  // Use parameter override instead of defparam
  SRL16 #(
    .INIT(16'h0000)
  ) ext_dll_rst_gen (
    .CLK(clk_in_buf), // Clocked by primary-derived clock
    .D(int_locked),
    .Q(ext_rst_n),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1)
  );
  // defparam ext_dll_rst_gen.INIT = 16'h0000; // Replaced by parameter override

  IBUFG ext_fb_buffer(
    .I(sdram_fb),
    .O(ext_fb)
  );

  // Mux the reset for ext_dcm to fix ACNCPI during test
  // Functional reset depends on inverted SRL output
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
  // In test mode, clk_ok should ideally be controllable or predictable.
  // Forcing to 1'b1 might be acceptable if downstream logic handles it.
  assign clk_ok = test_mode ? 1'b1 : func_clk_ok; // Force OK in test mode


  // Control external tristate buffer for reset pin
  assign reset_pad_out_n = 1'b0; // Value to drive (pull low)
  assign reset_pad_oen = (reset_counter[23] == 0); // Enable output when counter[23] is 0


  // Reset counter logic - clocked by clk_in_buf (OK)
  // Simplified reset condition to depend only on synchronized external reset
  // to potentially avoid issues with using func_clk_ok (derived from LOCKED)
  always @(posedge clk_in_buf) begin
      reset_p_n <= reset_pad_in_n; // Read from input path of reset pin
      reset_s_n <= reset_p_n;      // Synchronize reset input

      // Reset counter when external reset is active (low), regardless of mode or clk_ok status
      if (~reset_s_n) begin
          reset_counter <= 24'h000000;
      // Increment if not at max value and not in reset
      end else if (reset_counter != 24'hFFFFFF) begin
          reset_counter <= reset_counter + 1;
      end
      // Implicitly hold value if reset_counter == 24'hFFFFFF and not in reset
  end

  // Internal reset signal derived from counter state
  // reset is high while counting (counter not full), low when done/held at max
  assign reset_counting = (reset_counter != 24'hFFFFFF);
  assign reset = reset_counting;

endmodule