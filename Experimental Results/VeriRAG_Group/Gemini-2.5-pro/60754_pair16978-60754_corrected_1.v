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
  wire          pwrup;
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
  wire          pclkx2, pclkx10;
  wire          clkfbout;

  // DFT Internal signals
  reg           rst_n_sync_0, rst_n_sync_1, rst_n_sync_2;
  wire          sync_reset; // Synchronized active high reset
  wire          functional_reset_dcmspi;
  wire          functional_reset_dcm_pll;
  wire          dft_reset_dcmspi;
  wire          dft_reset_dcm_pll;
  wire          dft_pclk;
  wire          dft_pclkx2;
  wire          dft_pclkx10;

  // Clock buffering
  assign clk50m = dvi_clk_i;
  BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));

  // Reset generation and synchronization
  assign RSTBTN = ~rst_n_pad_i;

  // Synchronize asynchronous reset rst_n_pad_i to clk50m_bufg domain
  always @(posedge clk50m_bufg or negedge rst_n_pad_i) begin
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

  // Power-up sequence / initial reset delay using SRL16E
  SRL16E #(.INIT(16'hFFFF)) pwrup_srl ( // Initialize high, go low after lock
    .Q(pwrup),          // Active high during initial phase
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(pclk_lckd),    // Enable shift after DCM locks
    .CLK(clk50m_bufg),
    .D(1'b0)           // Shift in zeros
  );

  // Logic to detect configuration change or initial power-up
  // Use registered hlen/vlen for comparison
  assign switch_sig = pwrup | ({hlen_q, vlen_q} != {hlen, vlen});

  // GO signal generation for dcmspi using SRL16E
  SRL16E #(.INIT(16'h0000)) gopclk_srl ( // Initialize low
    .Q(gopclk),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(1'b1),          // Always enabled? Or should depend on 'switch_sig'? Assume always enabled.
    .CLK(clk50m_bufg),
    .D(switch_sig)     // Start GO sequence when switch_sig is high
  );

  // Register inputs and calculate DCM parameters based on resolution
  always @ (posedge clk50m_bufg) begin
    hlen_q <= hlen;
    vlen_q <= vlen;
    if (switch_sig) begin // Update M/D values only when switch_sig is asserted
      case ({hlen,vlen})
        // Timing parameters based on resolution (Example values)
        32'h031f01c1: begin pclk_M <= 8'd54 - 8'd1; pclk_D <= 8'd125 - 8'd1; end // 640x480@60Hz ?
        32'h03ff0270: begin pclk_M <= 8'd96 - 8'd1; pclk_D <= 8'd125 - 8'd1; end // 800x600@60Hz ?
        // ... Add all other cases from the original code ...
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
        default:      begin pclk_M <= 8'd2 - 8'd1;  pclk_D <= 8'd4 - 8'd1; end // Default case
      endcase
    end
  end

  // Define functional resets for sub-modules
  assign functional_reset_dcmspi = switch_sig; // Reset controlled by config change/power-up
  assign functional_reset_dcm_pll = sync_reset; // Reset controlled by synchronized external reset

  // Define combined DFT resets using test_mode_i
  assign dft_reset_dcmspi = test_mode_i ? test_rst_i : functional_reset_dcmspi;
  assign dft_reset_dcm_pll = test_mode_i ? test_rst_i : functional_reset_dcm_pll;

  // Instantiate dcmspi module (controls DCM programming)
  dcmspi dcmspi_0 (
    .RST(dft_reset_dcmspi),     // Use DFT controllable reset
    .PROGCLK(clk50m_bufg),
    .PROGDONE(progdone),
    .DFSLCKD(pclk_lckd),        // Lock status from DCM
    .M(pclk_M),                 // Program value M
    .D(pclk_D),                 // Program value D
    .GO(gopclk),                // Start programming signal
    .BUSY(busy),                // Busy status output
    .PROGEN(progen),            //