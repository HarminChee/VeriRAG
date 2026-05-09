`timescale 1 ps / 1 ps
module dvi_gen_top (
  input  wire        rst_n_pad_i,
  input  wire        dvi_clk_i, // Assume this is the reference clock (e.g., 50MHz)
  input  wire [15:0] hlen,
  input  wire [15:0] vlen,
  output wire [3:0]  TMDS,
  output wire [3:0]  TMDSB,
  output wire        pclk_o,  // Pixel clock output
  input  wire        hsync_i,
  input  wire        vsync_i,
  input  wire        blank_i,
  input  wire [7:0]  red_data_i,
  input  wire [7:0]  green_data_i,
  input  wire [7:0]  blue_data_i,
  input  wire        test_i // DFT test mode input
);

  // Internal signals
  wire          locked; // From PLL
  wire          reset;
  wire          clk50m; // Input clock (renamed for clarity)
  wire          clk50m_bufg; // Buffered input clock
  wire          pwrup;
  wire          pclk; // Pixel clock (internal)
  wire          pclkx2; // Pixel clock * 2 (internal)
  wire          pclkx10; // Pixel clock * 10 (internal, for SERDES)
  wire          pclk_lckd; // DCM lock signal
  wire          pll_lckd; // PLL lock signal
  wire          RSTBTN; // Debounced reset
  wire          switch_dcm; // Signal to trigger DCM reconfiguration
  wire          gopclk; // Delayed switch signal
  wire          serdes_rst; // Reset for SERDES blocks
  wire          pll_rst_internal; // Internal PLL reset logic
  wire          dcm_rst_internal; // Internal DCM reset logic
  wire          sync_reset; // Synchronized reset for pclk domain

  // DFT Signals
  wire dft_clk50m_bufg; // Muxed clock for 50MHz domain logic
  wire dft_pclk;        // Muxed clock for pixel clock domain logic
  wire dft_pclkx2;      // Muxed clock for pclkx2 domain logic
  wire dft_pclkx10;     // Muxed clock for pclkx10 domain logic
  wire dft_dcm_rst;     // Muxed reset for DCM
  wire dft_pll_rst;     // Muxed reset for PLL
  wire dft_sync_async_data; // Muxed async data input for synchronizer
  wire dft_serdes_rst;  // Muxed reset for SERDES
  wire dft_sync_reset;  // Muxed synchronous reset


  assign clk50m = dvi_clk_i;
  BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));

  assign RSTBTN = ~rst_n_pad_i; // Assuming active-low external reset

  // DFT Muxing Logic
  // Use dvi_clk_i (clk50m) as the single test clock source
  assign dft_clk50m_bufg = test_i ? clk50m : clk50m_bufg; // Use unbuffered clk50m for test to avoid BUFG issues if possible, or use buffered if required by tool
  assign dft_pclk        = test_i ? clk50m : pclk;
  assign dft_pclkx2      = test_i ? clk50m : pclkx2;
  assign dft_pclkx10     = test_i ? clk50m : pclkx10;

  // Use rst_n_pad_i (active low) as the primary test reset source
  // Match polarity of functional reset being replaced (Assume functional resets are active high unless specified otherwise)
  assign dcm_rst_internal = switch_dcm; // Functional reset for DCM (active high)
  assign pll_rst_internal = ~pll_lckd;   // Functional reset for PLL (active high)
  assign serdes_rst       = ~sync_reset; // Functional reset for SERDES (active high, derived from synchronized reset)

  assign dft_dcm_rst     = test_i ? ~rst_n_pad_i : dcm_rst_internal; // Test reset active high
  assign dft_pll_rst     = test_i ? ~rst_n_pad_i : pll_rst_internal; // Test reset active high
  assign dft_serdes_rst  = test_i ? ~rst_n_pad_i : serdes_rst;       // Test reset active high
  assign dft_sync_reset  = test_i ? ~rst_n_pad_i : sync_reset;     // Test reset active high (for sync flops reset)

  // Muxing the asynchronous data input to the synchronizer
  assign dft_sync_async_data = test_i ? rst_n_pad_i  : ~pll_lckd;    // Functional async data active low, Test async data active low


  // Power-up detection / Initial configuration trigger
  SRL16E #(.INIT(16'hFFFF)) pwrup_srl ( // Initialize high, goes low after 16 clocks
    .Q(pwrup),
    .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1), // Select Q[15]
    .CE(1'b1), // Always enabled
    .CLK(dft_clk50m_bufg), // Use muxed clock
    // .D tied to GND implicitly by INIT=FFFF and shifting zeros in
    .D(1'b0)
  );

  reg switch_dcm_reg = 1'b1; // Start high to trigger initial config
  reg [15:0] hlen_q, vlen_q;
  always @ (posedge dft_clk50m_bufg or posedge dft_dcm_rst) // Use muxed clock and reset
  begin
    if (dft_dcm_rst) begin
        switch_dcm_reg <= 1'b1; // Reset behavior: trigger reconfiguration
        hlen_q <= 16'b0;
        vlen_q <= 16'b0;
    end else begin
        // Trigger reconfiguration on power-up or resolution change
        switch_dcm_reg <= pwrup | ({hlen_q, vlen_q} != {hlen, vlen});
        hlen_q <= hlen;
        vlen_q <= vlen;
    end
  end
  assign switch_dcm = switch_dcm_reg;

  // Delay switch signal slightly
  SRL16E #(.INIT(16'h0000)) gopclk_srl (
    .Q(gopclk),
    .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1), // Select Q[15]
    .CE(1'b1),
    .CLK(dft_clk50m_bufg), // Use muxed clock
    .D(switch_dcm)
  );

  // DCM parameters calculation based on resolution
  reg [7:0] pclk_M, pclk_D;
  always @(*) // Combinational based on inputs hlen, vlen
  begin
      case ({hlen,vlen}) // Example cases, add all required resolutions
        // 640x480 @ 60Hz (25.175MHz pixel clock -> 50MHz * (54/125) approx) - Needs fractional PLL/MMCM ideally
        // Using integer M/D for DCM, might not be precise
        32'h031f01df: // 800x480 - Approximation
        begin
          pclk_M <= 8'd3; // Example M=3
          pclk_D <= 8'd5; // Example D=5 -> 50 * 3 / 5 = 30 MHz
        end
        // 800x600 @ 60Hz (40MHz pixel clock -> 50MHz * (4/5))
        32'h031f0258: // 800x600
        begin
          pclk_M <= 8'd4 - 8'd1; // M=4
          pclk_D <= 8'd5 - 8'd1; // D=5
        end
         // 1024x768 @ 60Hz (65MHz pixel clock -> 50MHz * (13/10))
        32'h03ff02ff: // 1024x768
        begin
          pclk_M <= 8'd13 - 8'd1; // M=13
          pclk_D <= 8'd10 - 8'd1; // D=10
        end
        // 1280x1024 @ 60Hz (108MHz pixel clock -> 50MHz * (54/25) approx)
        32'h04ff03ff: // 1280x1024
        begin
          pclk_M <= 8'd54 - 8'd1; // M=54
          pclk_D <= 8'd25 - 8'd1; // D=25
        end
        // Add other resolutions as needed...
        // Default case (e.g., 800x600)
        default: begin
          pclk_M <= 8'd4 - 8'd1; // M=4
          pclk_D <= 8'd5 - 8'd1; // D=5
        end
      endcase
  end

  // Instantiate DCM or MMCM/PLL for pixel clock generation
  // Using PLL_BASE for example, parameters need adjustment for target device/frequency
  wire clkfbout;
  wire clkout0, clkout1, clkout2; // pclk, pclkx2, pclkx10

  PLL_BASE #(
      .BANDWIDTH("OPTIMIZED"),
      .CLKFBOUT_MULT(10),         // Multiply by 10 (example)
      .CLKIN_PERIOD(20.0),        // 50MHz input clock period
      .CLKOUT0_DIVIDE(10),        // Divide by 10 for pclk (50MHz * 10 / 10 = 50MHz, adjust!)
      .CLKOUT1_DIVIDE(5),         // Divide by 5 for pclkx2 (50MHz * 10 / 5 = 100MHz, adjust!)
      .CLKOUT2_DIVIDE(1),         // Divide by 1 for pclkx10 (50MHz * 10 / 1 = 500MHz, adjust!)
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .COMPENSATION("SYSTEM_SYNCHRONOUS"),
      .DIVCLK_DIVIDE(1),          // Input divider
      .REF_JITTER(0.01),
      .RESET_ON_LOCK(1'b0)       // Use external reset
    // .STARTUP_WAIT("FALSE") // For simulation speedup if needed
   ) PLL_BASE_inst (
      .CLKFBOUT(clkfbout),
      .CLKOUT0(clkout0),         // pclk candidate
      .CLKOUT1(clkout1),         // pclkx2 candidate
      .CLKOUT2(clkout2),         // pclkx10 candidate
      .CLKOUT3(),
      .CLKOUT4(),
      .CLKOUT5(),
      .LOCKED(pll_lckd),         // Use PLL lock status
      .CLKFBIN(clkfbout),
      .CLKIN(clk50m_bufg),       // Use buffered input clock
      .RST(dft_pll_rst)          // Use muxed reset
   );

   // Assign PLL outputs to internal clock signals
   // This example PLL setup might not match the dynamic M/D values calculated above.
   // A dynamic reconfiguration approach (MMCM/DCM) or fixed PLL for max rate + dividers is needed.
   // For simplicity here, assuming PLL provides the necessary clocks directly or indirectly.
   // Let's assume clkout0 is pclk, clkout1 is pclkx2, clkout2 is pclkx10
   // **WARNING**: This fixed PLL doesn't match the dynamic M/D calculation logic.
   // A real design would use MMCM dynamic reconfiguration or multiple fixed PLLs/DCMs.
   assign pclk = clkout0;
   assign pclkx2 = clkout1;
   assign pclkx10 = clkout2;
   assign pclk_lckd = pll_lckd; // Use PLL lock for downstream logic if needed

   assign pclk_o = pclk; // Output the pixel clock

  // Reset Synchronizer for pixel clock domain
  sync_cell sync_pll_lckd (
      .clk(dft_pclk), // Destination clock domain (muxed)
      .rst(dft_sync_reset), // Synchronous reset for synchronizer FFs (muxed)
      .async_in(dft_sync_async_data), // Asynchronous input signal (muxed)
      .sync_out(sync_reset) // Synchronized output (active high)
  );


  // DVI Encoder instantiation
  dvi_encoder encoder (
      .pclk(dft_pclk), // Muxed pixel clock
      .pclkx2(dft_pclkx2), // Muxed pixel clock x2 (if needed by encoder)
      .reset(dft_serdes_rst), // Muxed reset (active high)
      .hsync_i(hsync_i),
      .vsync_i(vsync_i),
      .blank_i(blank_i),
      .red_data_i(red_data_i),
      .green_data_i(green_data_i),
      .blue_data_i(blue_data_i),
      .tmds_out(TMDS),
      .tmds_n_out(TMDSB),
      // Assuming encoder uses pclkx10 for serialization internally or drives separate SERDES
      .pclk_sd(dft_pclkx10) // Muxed serialization clock
    );

endmodule

// Basic Reset Synchronizer Cell
module sync_cell (
    input wire clk,
    input wire rst, // Synchronous reset for the FFs
    input wire async_in, // Asynchronous input
    output reg sync_out  // Synchronized output
);

    reg sync_meta;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_meta <= 1'b1; // Reset to inactive state (assuming active low async_in means reset asserted)
            sync_out  <= 1'b1; // Adjust reset state based on polarity needed
        end else begin
            sync_meta <= async_in;
            sync_out  <= sync_meta;
        end
    end

endmodule

// Placeholder for DVI Encoder module (replace with actual implementation)
module dvi_encoder (
    input wire pclk,
    input wire pclkx2,
    input wire reset, // Active high reset
    input wire hsync_i,
    input wire vsync_i,
    input wire blank_i,
    input wire [7:0] red_data_i,
    input wire [7:0] green_data_i,
    input wire [7:0] blue_data_i,
    output wire [3:0] tmds_out,
    output wire [3:0] tmds_n_out,
    input wire pclk_sd // Serialization clock (e.g., pclk x10)
);

    // Simplified example: Pass through blanking state to TMDS channel 0
    // A real encoder performs 8b/10b encoding and serialization.
    reg [9:0] tmds_r_ser, tmds_g_ser, tmds_b_ser, tmds_c_ser; // Serialized data (example)

    // Example: Simple serialization logic placeholder
    always @(posedge pclk_sd or posedge reset) begin
        if (reset) begin
            tmds_r_ser <= 10'b0;
            tmds_g_ser <= 10'b0;
            tmds_b_ser <= 10'b0;
            tmds_c_ser <= 10'b0; // Clock channel
        end else begin
            // Dummy serialization - replace with actual logic
            tmds_r_ser <= {red_data_i, 2'b0}; // Placeholder
            tmds_g_ser <= {green_data_i, 2'b0}; // Placeholder
            tmds_b_ser <= {blue_data_i, 2'b0}; // Placeholder
            tmds_c_ser <= {tmds_c_ser[8:0], tmds_c_ser[9]}; // Example clock pattern
        end
    end

    // Output driver placeholder (replace with OSERDES and OBUFDS)
    assign tmds_out[0] = tmds_b_ser[0]; // Blue LSB
    assign tmds_out[1] = tmds_g_ser[0]; // Green LSB
    assign tmds_out[2] = tmds_r_ser[0]; // Red LSB
    assign tmds_out[3] = tmds_c_ser[0]; // Clock LSB

    assign tmds_n_out[0] = ~tmds_b_ser[0];
    assign tmds_n_out[1] = ~tmds_g_ser[0];
    assign tmds_n_out[2] = ~tmds_r_ser[0];
    assign tmds_n_out[3] = ~tmds_c_ser[0];

endmodule

// Note: PLL_BASE, BUFG, SRL16E are Xilinx primitives. Replace if using a different FPGA vendor.
// The PLL/MMCM configuration and dynamic switching logic needs to be implemented correctly
// based on the target device and required pixel clock frequencies.
// The DVI Encoder module is a placeholder and needs the actual DVI encoding/serialization logic.