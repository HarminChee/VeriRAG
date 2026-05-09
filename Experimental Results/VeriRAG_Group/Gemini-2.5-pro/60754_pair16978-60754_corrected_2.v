`timescale 1 ps / 1 ps

module dvi_gen_top (
  input  wire        rst_n_pad_i,     // Asynchronous reset input (active low)
  input  wire        dvi_clk_i,       // Input clock (e.g., 50 MHz)
  input  wire [15:0] hlen,
  input  wire [15:0] vlen,
  output wire [3:0]  TMDS,
  output wire [3:0]  TMDSB,
  output wire        pclk_o,          // Pixel clock output
  input  wire        hsync_i,
  input  wire        vsync_i,
  input  wire        blank_i,
  input  wire [7:0]  red_data_i,
  input  wire [7:0]  green_data_i,
  input  wire [7:0]  blue_data_i,
  // DFT Ports
  input  wire        test_mode_i,     // DFT test mode enable
  input  wire        test_clk_i,      // DFT test clock
  input  wire        test_rst_i       // DFT test reset (active high)
);

  // Internal signals
  wire          clk50m;
  wire          clk50m_bufg;
  wire          pclk_lckd; // DCM lock signal
  wire          pll_lckd;  // PLL lock signal
  reg           pwrup_q;   // Registered power-up signal
  wire          pwrup_done; // Signal indicating power-up delay finished
  wire          RSTBTN;
  wire          busy;
  wire          switch_sig; // Renamed from 'switch' to avoid keyword conflict
  reg  [15:0]   hlen_q, vlen_q;
  wire          gopclk;
  reg  [7:0]    pclk_M, pclk_D;
  wire          progdone, progen, progdata;
  wire          clkfx;
  wire          pclk;
  wire          pllclk0, pllclk1, pllclk2;
  wire          pclkx2;
  wire          pclkx10; // Assigned from pllclk1
  wire          clkfbout;

  // DFT Internal signals
  reg           rst_n_sync_0, rst_n_sync_1, rst_n_sync_2;
  wire          sync_reset; // Synchronized active high reset
  wire          functional_reset_dcm_pll;
  wire          dft_reset_ctrl; // Combined reset for control logic
  wire          dft_reset_clkgen; // Combined reset for clock generators (DCM/PLL/DCMSPI)
  wire          dft_pclk;
  wire          dft_pclkx2;
  wire          dft_pclkx10;
  wire          dft_clk50m_bufg; // Muxed clock for control logic if needed (using test_clk_i)

  // Clock buffering
  assign clk50m = dvi_clk_i;
  BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));

  // DFT Clock Muxing (using test_clk_i for primary clock domain during test)
  assign dft_clk50m_bufg = test_mode_i ? test_clk_i : clk50m_bufg;

  // Reset generation and synchronization
  assign RSTBTN = ~rst_n_pad_i;

  // Synchronize asynchronous reset rst_n_pad_i to the DFT-muxed clock domain
  always @(posedge dft_clk50m_bufg or negedge rst_n_pad_i) begin
    if (!rst_n_pad_i) begin
      rst_n_sync_0 <= 1'b0; // Active low during reset assertion
      rst_n_sync_1 <= 1'b0;
      rst_n_sync_2 <= 1'b0;
    end else begin
      rst_n_sync_0 <= 1'b1;
      rst_n_sync_1 <= rst_n_sync_0;
      rst_n_sync_2 <= rst_n_sync_1;
    end
  end
  assign sync_reset = ~rst_n_sync_2; // Active high synchronized reset

  // Define combined DFT resets using test_mode_i
  assign dft_reset_ctrl = test_mode_i ? test_rst_i : sync_reset; // Reset for general control logic
  assign dft_reset_clkgen = test_mode_i ? test_rst_i : sync_reset; // Use sync_reset for clock generators functional reset


  // Simplified Power-up sequence / initial reset delay using SRL16E
  // Generates a pulse 'pwrup_done' after sync_reset goes low
  // This avoids dependency on DCM lock for basic initialization control
  SRL16E #(.INIT(16'hFFFF)) pwrup_srl (
    .Q(pwrup_q),        // Goes low after 16 clocks
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(~sync_reset),   // Enable shifting only when not in reset
    .CLK(dft_clk50m_bufg), // Use DFT-muxed clock
    .D(1'b0)            // Shift in zeros
  );
  assign pwrup_done = ~pwrup_q; // High after power-up delay finishes


  // Logic to detect configuration change or initial power-up
  assign switch_sig = ~pwrup_done | ({hlen_q, vlen_q} != {hlen, vlen}); // Trigger on config change or during power-up phase

  // GO signal generation for dcmspi using SRL16E
  SRL16E #(.INIT(16'h0000)) gopclk_srl (
    .Q(gopclk),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(1'b1),          // Always enabled
    .CLK(dft_clk50m_bufg), // Use DFT-muxed clock
    .D(switch_sig)      // Start GO sequence when switch_sig is high
  );

  // Register inputs and calculate DCM parameters based on resolution
  always @ (posedge dft_clk50m_bufg or posedge dft_reset_ctrl) begin
     if (dft_reset_ctrl) begin
         hlen_q <= 16'b0;
         vlen_q <= 16'b0;
         pclk_M <= 8'd2 - 8'd1;  // Default M
         pclk_D <= 8'd4 - 8'd1;  // Default D
     end else begin
        hlen_q <= hlen;
        vlen_q <= vlen;
        if (switch_sig) begin // Update M/D values only when switch_sig is asserted
          case ({hlen,vlen})
            // Timing parameters based on resolution (Example values)
             32'h031f01c1: begin pclk_M <= 8'd54 - 8'd1; pclk_D <= 8'd125 - 8'd1; end // 640x480@60Hz ? -> pclk = 25.92MHz ? (50 * 54 / 125 = 21.6?) Check calc.
             32'h03ff0270: begin pclk_M <= 8'd96 - 8'd1; pclk_D <= 8'd125 - 8'd1; end // 800x600@60Hz ? -> pclk = 38.4MHz?
             32'h027f0193: begin pclk_M <= 8'd76 - 8'd1; pclk_D <= 8'd245 - 8'd1; end
             32'h018f00e0: begin pclk_M <= 8'd27 - 8'd1; pclk_D <= 8'd250 - 8'd1; end
             32'h018f0105: begin pclk_M <= 8'd21 - 8'd1; pclk_D <= 8'd167 - 8'd1; end
             32'h01ff0137: begin pclk_M <= 8'd37 - 8'd1; pclk_D <= 8'd193 - 8'd1; end
             32'h020f0139: begin pclk_M <= 8'd38 - 8'd1; pclk_D <= 8'd191 - 8'd1; end
             32'h0207014c: begin pclk_M <= 8'd16 - 8'd1; pclk_D <= 8'd77 - 8'd1; end
             32'h02670137: begin pclk_M <= 8'd3 - 8'd1;  pclk_D <= 8'd13 - 8'd1; end
             32'h02770139: begin pclk_M <= 8'd5 - 8'd1;  pclk_D <= 8'd21 - 8'd1; end
             32'h026f014c: begin pclk_M <= 8'd63 - 8'd1; pclk_D <= 8'd253 - 8'd1; end
             32'h0a1f04d9: begin pclk_M <= 8'd197 - 8'd1; pclk_D <= 8'd51 - 8'd1; end
             32'h05bf0325: begin pclk_M <= 8'd84 - 8'd1; pclk_D <= 8'd59 - 8'd1; end
             32'h05f70315: begin pclk_M <= 8'd197 - 8'd1; pclk_D <= 8'd136 - 8'd1; end
             32'h068f033b: begin pclk_M <= 8'd217 - 8'd1; pclk_D <= 8'd130 - 8'd1; end
             32'h035f0270: begin pclk_M <= 8'd81 - 8'd1; pclk_D <= 8'd125 - 8'd1; end
             32'h043f0270: begin pclk_M <= 8'd102 - 8'd1; pclk_D <= 8'd125 - 8'd1; end
             default:      begin pclk_M <= 8'd2 - 8'd1;  pclk_D <= 8'd4 - 8'd1; end // Default case (e.g., 50 * 2 / 4 = 25 MHz)
          endcase
        end // if (switch_sig)
     end // else: !if(dft_reset_ctrl)
  end // always

  // Instantiate dcmspi module (controls DCM programming)
  dcmspi dcmspi_0 (
    .RST(dft_reset_clkgen),     // Use DFT controllable reset for clock gen blocks
    .PROGCLK(clk50m_bufg),      // Use original clock for programming sequence timing
    .PROGDONE(progdone),
    .DFSLCKD(pclk_lckd),        // Lock status from DCM
    .M(pclk_M),                 // Program value M
    .D(pclk_D),                 // Program value D
    .GO(gopclk),                // Start programming signal
    .BUSY(busy),                // Busy status output
    .PROGEN(progen),            // Program enable to DCM
    .PROGDATA(progdata)         // Program data to DCM
  );

  // Instantiate the DCM
  // Ensure feedback path is correct (CLKFB usually connects to CLK0 or CLKDV output)
  DCM_SP #(
    .CLK_FEEDBACK("1X"),      // Specify feedback source (e.g., "1X" or "2X") - Adjust as needed
    .CLKDV_DIVIDE(2.0),       // Example division factor - Adjust as needed
    .CLKFX_DIVIDE(1),         // Example division factor - Adjust as needed
    .CLKFX_MULTIPLY(4),       // Example multiplication factor - Adjust as needed
    .CLKIN_DIVIDE_BY_2("FALSE"), // Example - Adjust as needed
    .CLKIN_PERIOD(20.0),      // Input clock period (e.g., 50MHz = 20.0 ns) - Adjust as needed
    .CLKOUT_PHASE_SHIFT("NONE"), // Example - Adjust as needed
    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // Example - Adjust as needed
    .DFS_FREQUENCY_MODE("LOW"), // Example - Adjust as needed
    .DLL_FREQUENCY_MODE("LOW"), // Example - Adjust as needed
    .DUTY_CYCLE_CORRECTION("TRUE"), // Example - Adjust as needed
    .FACTORY_JF(16'hC080),    // Example - Adjust as needed
    .PHASE_SHIFT(0),          // Example - Adjust as needed
    .STARTUP_WAIT("FALSE")    // Example - Adjust as needed
  ) DCM_SP_inst (
    .CLK0(pclk),             // Generated clock (pixel clock)
    .CLK180(),           // 180 degree shifted clock output (unused)
    .CLK270(),           // 270 degree shifted clock output (unused)
    .CLK2X(pclkx2),           // 2X clock output
    .CLK2X180(),         // 2X, 180 degree shifted clock output (unused)
    .CLK90(),            // 90 degree shifted clock output (unused)
    .CLKDV(),            // Divided clock output (unused, configured by CLKDV_DIVIDE)
    .CLKFX(clkfx),            // Synthesized clock output (usually higher frequency)
    .CLKFX180(),         // Synthesized clock, 180 degree shifted output (unused)
    .LOCKED(pclk_lckd),         // DCM lock status
    .PSDONE(),           // Phase shift done status (unused)
    .STATUS(),           // Status output (unused)
    .CLKFB(pclk),            // Clock feedback (Connect to CLK0 typically for "1X")
    .CLKIN(clk50m_bufg),         // Input clock (buffered primary clock)
    .PSCLK(1'b0),          // Phase shift clock input (unused)
    .PSEN(1'b0),           // Phase shift enable input (unused)
    .PSINCDEC(1'b0),       // Phase shift increment/decrement input (unused)
    .RST(dft_reset_clkgen),  // Reset input (Use DFT controllable reset)
    // Dynamic Reconfiguration Port (DRP) signals from dcmspi
    .PROGCLK(clk50m_bufg),    // Programming clock
    .PROGDATA(progdata),     // Programming data
    .PROGEN(progen),         // Programming enable
    .PROGDONE(progdone)      // Programming done status
  );

  // Instantiate the PLL (Example: multiply clk50m_bufg by 5 for pclkx10)
  PLL_BASE #(
    .BANDWIDTH("OPTIMIZED"), // "HIGH", "LOW" or "OPTIMIZED"
    .CLKFBOUT_MULT(10),      // Multiply Factor for feedback clock (adjust for desired VCO)
    .CLKFBOUT_PHASE(0.0),
    .CLKIN_PERIOD(20.0),     // Input clock period (50MHz = 20.0ns)
    .CLKOUT0_DIVIDE(1),      // Divide Factor for CLKOUT0 (pllclk0 - pclkx10 * 2?)
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_DIVIDE(5),      // Divide Factor for CLKOUT1 (pllclk1 - pclkx10 -> 50MHz * 10 / 5 = 100MHz?) Need 10x pclk. Reconfigure.
    // Let's assume pclk is ~25MHz. We need pclkx10 ~ 250MHz.
    // If CLKIN is 50MHz, VCO target = 50 * M. Let M=10, VCO=500MHz.
    // CLKOUT0 = VCO / D0. CLKOUT1 = VCO / D1. CLKOUT2 = VCO / D2.
    // We need pclkx10 ~ 250MHz. Let D1 = 2. -> CLKOUT1 = 500/2 = 250MHz.
    // Let's reconfigure PLL: CLKFBOUT_MULT=10, CLKOUT1_DIVIDE=2
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0.0),
    .CLKOUT2_DIVIDE(1),      // Divide Factor for CLKOUT2 (unused)
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_DIVIDE(1),      // (unused)
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_DIVIDE(1),      // (unused)
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_DIVIDE(1),      // (unused)
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0.0),
    .COMPENSATION("INTERNAL"), // "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "INTERNAL" etc.
    .DIVCLK_DIVIDE(1),       // Division factor for input clock
    .REF_JITTER(0.010)       // Input reference jitter
  ) PLL_BASE_inst (
    .CLKFBOUT(clkfbout),     // PLL feedback output
    .CLKOUT0(pllclk0),       // PLL output 0
    .CLKOUT1(pllclk1),       // PLL output 1 (intended for pclkx10)
    .CLKOUT2(pllclk2),       // PLL output 2
    .CLKOUT3(),       // PLL output 3 (unused)
    .CLKOUT4(),       // PLL output 4 (unused)
    .CLKOUT5(),       // PLL output 5 (unused)
    .LOCKED(pll_lckd),       // PLL lock status output
    .CLKFBIN(clkfbout),      // PLL feedback input
    .CLKIN(clk50m_bufg),     // Clock input
    .RST(dft_reset_clkgen)   // Reset input (Use DFT controllable reset)
  );

  assign pclkx10 = pllclk1; // Assign PLL output to pclkx10 signal

  // DFT Clock Muxing for generated clocks
  assign dft_pclk    = test_mode_i ? test_clk_i : pclk;
  assign dft_pclkx2  = test_mode_i ? test_clk_i : pclkx2; // Note: May need separate test clock if frequency differs significantly
  assign dft_pclkx10 = test_mode_i ? test_clk_i : pclkx10; // Note: May need separate test clock if frequency differs significantly

  // Instantiate DVI Encoder
  dvi_encoder encode_rgb (
    .pclk(dft_pclk),            // Use DFT-muxed pixel clock
    .reset_n(~dft_reset_ctrl),  // Use DFT-muxed reset (active low)
    .hsync(hsync_i),
    .vsync(vsync_i),
    .blank(blank_i),
    .r_in(red_data_i),
    .g_in(green_data_i),
    .b_in(blue_data_i),
    .tmds_out(TMDS),
    .tmdsb_out(TMDSB)
    // Assuming dvi_encoder does not need pclkx2. If it does, add port and connect dft_pclkx2.
  );

  // Instantiate Serializer (if needed separately, or maybe part of dvi_encoder)
  // Assuming TMDS generation happens inside dvi_encoder which handles serialization.
  // If a separate serializer module exists:
  /*
  serializer_10_to_1 ser_inst (
    .clk_pixel(dft_pclk),     // Low speed clock
    .clk_serial(dft_pclkx10), // High speed clock (10x pixel clock)
    .reset_n(~dft_reset_ctrl),// Use DFT-muxed reset (active low)
    .parallel_data_in(...), // Connect parallel data from encoder
    .serial_data_out(...) // Connect to TMDS generation logic (ODDR etc.)
  );
  */

  // Assign pixel clock output
  assign pclk_o = pclk; // Output the functional pixel clock

endmodule

// Placeholder for dcmspi module definition (assuming it exists elsewhere)
module dcmspi (
  input        RST,
  input        PROGCLK,
  output       PROGDONE,
  input        DFSLCKD,
  input  [7:0] M,
  input  [7:0] D,
  input        GO,
  output       BUSY,
  output       PROGEN,
  output       PROGDATA
);
  // Internal logic of dcmspi
  // This module likely contains state machines and logic to
  // generate the PROGEN/PROGDATA signals based on M, D, GO inputs
  // and monitor PROGDONE/DFSLCKD status.
  // For simulation/synthesis, a real or behavioral model is needed.
  assign PROGDONE = 1'b1; // Dummy assignment
  assign BUSY = 1'b0;     // Dummy assignment
  assign PROGEN = 1'b0;   // Dummy assignment
  assign PROGDATA = 1'b0; // Dummy assignment
endmodule

// Placeholder for dvi_encoder module definition
module dvi_encoder (
  input        pclk,
  input        reset_n,
  input        hsync,
  input        vsync,
  input        blank,
  input  [7:0] r_in,
  input  [7:0] g_in,
  input  [7:0] b_in,
  output [3:0] tmds_out,
  output [3:0] tmdsb_out
);
  // Internal logic for TMDS encoding and serialization
  // Likely uses pclk and potentially a 10x clock internally
  // generated or provided.
  // For simulation/synthesis, a real or behavioral model is needed.

  // Dummy assignments
  assign tmds_out = 4'b0;
  assign tmdsb_out = 4'b0;
endmodule