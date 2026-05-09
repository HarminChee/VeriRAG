module red_pitaya_analog
(
  input    [ 16-1: 2] adc_dat_a_i        ,
  input    [ 16-1: 2] adc_dat_b_i        ,
  input               adc_clk_p_i        ,
  input               adc_clk_n_i        ,
  output   [ 14-1: 0] dac_dat_o          ,
  output              dac_wrt_o          ,
  output              dac_sel_o          ,
  output              dac_clk_o          ,
  output              dac_rst_o          ,
  output   [  4-1: 0] dac_pwm_o          , // Assuming PWM logic exists elsewhere or is incomplete
  output   [ 14-1: 0] adc_dat_a_o        ,
  output   [ 14-1: 0] adc_dat_b_o        ,
  output              adc_clk_o          ,
  input               adc_rst_i          , // Use this as the primary DFT reset
  output              ser_clk_o          ,
  input    [ 14-1: 0] dac_dat_a_i        ,
  input    [ 14-1: 0] dac_dat_b_i        ,
  input    [ 24-1: 0] dac_pwm_a_i        , // Assuming used by PWM logic
  input    [ 24-1: 0] dac_pwm_b_i        , // Assuming used by PWM logic
  input    [ 24-1: 0] dac_pwm_c_i        , // Assuming used by PWM logic
  input    [ 24-1: 0] dac_pwm_d_i        , // Assuming used by PWM logic
  output              dac_pwm_sync_o     , // Assuming used by PWM logic
  input               test_i             // DFT test mode enable
);

// ADC Input Path
reg  [14-1: 0] adc_dat_a_ff  ; // Renamed to avoid conflict
reg  [14-1: 0] adc_dat_b_ff  ; // Renamed to avoid conflict
wire           adc_clk_in ;
wire           adc_clk    ;

IBUFDS i_clk ( .I(adc_clk_p_i), .IB(adc_clk_n_i), .O(adc_clk_in));
BUFG i_adc_buf  (.O(adc_clk), .I(adc_clk_in));

// Use primary reset adc_rst_i (active low assumed based on PLL usage)
wire dft_adc_rst_n = adc_rst_i; // Assuming active low primary reset
wire dft_adc_rst   = !dft_adc_rst_n; // Active high version for internal use

always @(posedge adc_clk or negedge dft_adc_rst_n) begin // Use primary async reset
   if (!dft_adc_rst_n) begin
       adc_dat_a_ff <= 14'b0;
       adc_dat_b_ff <= 14'b0;
   end else begin
       adc_dat_a_ff <= adc_dat_a_i[16-1:2];
       adc_dat_b_ff <= adc_dat_b_i[16-1:2];
   end
end

assign adc_dat_a_o = {adc_dat_a_ff[14-1], ~adc_dat_a_ff[14-2:0]};
assign adc_dat_b_o = {adc_dat_b_ff[14-1], ~adc_dat_b_ff[14-2:0]};
assign adc_clk_o   =  adc_clk ;

// DAC Clock Generation
wire  dac_clk_fb      ;
wire  dac_clk_fb_buf  ;
wire  dac_clk_out     ;
wire  dac_2clk_out    ;
wire  dac_clk         ; // PLL output 1x clock
wire  dac_2clk        ; // PLL output 2x clock
wire  dac_locked      ;
reg   dac_rst_internal; // Internal functional reset based on PLL lock
wire  ser_clk_out     ;
wire  dac_2ph_out     ;
wire  dac_2ph         ; // PLL output 2x clock, phase shifted

// DFT Clock Muxes - Select primary-derived clock 'adc_clk' in test mode
wire  dft_dac_clk     = test_i ? adc_clk : dac_clk;
wire  dft_dac_2clk    = test_i ? adc_clk : dac_2clk;
wire  dft_dac_2ph     = test_i ? adc_clk : dac_2ph;

// PLL Instantiation - Reset controlled directly by primary input 'dft_adc_rst' (active high)
PLLE2_ADV
#(
   .BANDWIDTH            ( "OPTIMIZED"   ),
   .COMPENSATION         ( "ZHOLD"       ),
   .DIVCLK_DIVIDE        (  1            ),
   .CLKFBOUT_MULT        (  8            ),
   .CLKFBOUT_PHASE       (  0.000        ),
   .CLKOUT0_DIVIDE       (  8            ), // Generates dac_clk (1x)
   .CLKOUT0_PHASE        (  0.000        ),
   .CLKOUT0_DUTY_CYCLE   (  0.5          ),
   .CLKOUT1_DIVIDE       (  4            ), // Generates dac_2clk (2x)
   .CLKOUT1_PHASE        (  0.000        ),
   .CLKOUT1_DUTY_CYCLE   (  0.5          ),
   .CLKOUT2_DIVIDE       (  4            ), // Generates dac_2ph (2x, phase shifted)
   .CLKOUT2_PHASE        ( -45.000       ), // Phase shift relative to CLKOUT1
   .CLKOUT2_DUTY_CYCLE   (  0.5          ),
   .CLKOUT3_DIVIDE       (  4            ), // Generates ser_clk (2x)
   .CLKOUT3_PHASE        (  0.000        ),
   .CLKOUT3_DUTY_CYCLE   (  0.5          ),
   .CLKIN1_PERIOD        (  8.000        ), // Must match adc_clk period
   .REF_JITTER1          (  0.010        )
)
i_dac_plle2
(
   .CLKFBOUT     (  dac_clk_fb     ),
   .CLKOUT0      (  dac_clk_out    ),
   .CLKOUT1      (  dac_2clk_out   ),
   .CLKOUT2      (  dac_2ph_out    ),
   .CLKOUT3      (  ser_clk_out    ),
   .CLKOUT4      (                 ),
   .CLKOUT5      (                 ),
   .CLKFBIN      (  dac_clk_fb_buf ),
   .CLKIN1       (  adc_clk        ), // Use buffered primary clock
   .CLKIN2       (  1'b0           ),
   .CLKINSEL     (  1'b1           ),
   .DADDR        (  7'h0           ),
   .DCLK         (  1'b0           ),
   .DEN          (  1'b0           ),
   .DI           (  16'h0          ),
   .DO           (                 ),
   .DRDY         (                 ),
   .DWE          (  1'b0           ),
   .LOCKED       (  dac_locked     ),
   .PWRDWN       (  1'b0           ),
   .RST          (  dft_adc_rst    ) // Use active-high primary reset
);

// Clock Buffers
BUFG i_dacfb_buf   (.O(dac_clk_fb_buf), .I(dac_clk_fb));
BUFG i_dac1_buf    (.O(dac_clk),        .I(dac_clk_out));
BUFG i_dac2_buf    (.O(dac_2clk),       .I(dac_2clk_out));
BUFG i_dac2ph_buf  (.O(dac_2ph),        .I(dac_2ph_out));
BUFG i_ser_buf     (.O(ser_clk_o),      .I(ser_clk_out));

// Internal DAC reset generation (functional mode) - Active High
// This reset is only used functionally; DFT reset comes from dft_adc_rst
always @(posedge dac_clk or posedge dft_adc_rst) begin // Use primary reset async
   if (dft_adc_rst)
      dac_rst_internal <= 1'b1; // Reset asserted when primary reset is active
   else
      dac_rst_internal <= !dac_locked; // De-assert reset only when PLL is locked and primary reset is inactive
end

// Synchronize internal reset to dft_dac_2clk domain for potential PWM logic (functional use only)
reg dac_rst_sync1, dac_rst_sync2;
always @(posedge dft_dac_2clk or posedge dft_adc_rst) begin // Use primary reset async
    if (dft_adc_rst) begin
        dac_rst_sync1 <= 1'b1;
        dac_rst_sync2 <= 1'b1;
    end else begin
        dac_rst_sync1 <= dac_rst_internal; // Sync the internal functional reset
        dac_rst_sync2 <= dac_rst_sync1;
    end
end

// DFT Reset Muxes (Active High)
// Select primary reset 'dft_adc_rst' in test mode
wire pwm_rst_signal = test_i ? dft_adc_rst : dac_rst_sync2; // Synchronous reset for PWM (relative to dft_dac_2clk)
wire oddr_rst_signal = test_i ? dft_adc_rst : dac_rst_internal; // Asynchronous reset for ODDRs (relative to dft_dac_2clk/dft_dac_2ph)

assign dac_rst_o = oddr_rst_signal; // Output the DFT-muxed reset

// DAC data path registers - Renamed to avoid conflict
reg  [14-1: 0] dac_dat_a_reg  ;
reg  [14-1: 0] dac_dat_b_reg  ;

// DAC input registers (using dft_dac_clk and primary async reset dft_adc_rst)
always @(posedge dft_dac_clk or posedge dft_adc_rst) begin
   if (dft_adc_rst) begin
       dac_dat_a_reg <= 14'b0;
       dac_dat_b_reg <= 14'b0;
   end else begin
       dac_dat_a_reg <= {dac_dat_a_i[14-1], ~dac_dat_a_i[14-2:0]};
       dac_dat_b_reg <= {dac_dat_b_i[14-1], ~dac_dat_b_i[14-2:0]};
   end
end

// ODDR Instances for DAC output interface
// Use the DFT-muxed clock (dft_dac_2ph or dft_dac_2clk) and DFT-muxed reset (oddr_rst_signal)
ODDR #( .SRTYPE("ASYNC") ) i_dac_clk ( .Q(dac_clk_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2ph),  .CE(1'b1), .R(oddr_rst_signal), .S(1'b0) );
ODDR #( .SRTYPE("ASYNC") ) i_dac_wrt ( .Q(dac_wrt_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2clk), .CE(1'b1), .R(oddr_rst_signal), .S(1'b0) );
ODDR #( .SRTYPE("ASYNC") ) i_dac_sel ( .Q(dac_sel_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2clk), .CE(1'b1), .R(oddr_rst_signal), .S(1'b0) );

genvar i;
generate
  for (i = 0; i < 14; i = i + 1) begin : gen_dac_dat_oddr
    ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // Data captured on opposite edges
      .INIT(1'b0),                   // Initial value of Q
      .SRTYPE("ASYNC")               // Reset is asynchronous
    ) i_dac_dat_oddr (
      .Q (dac_dat_o[i]),
      .D1(dac_dat_a_reg[i]),      // Data for rising edge of C (or falling if OPPOSITE_EDGE)
      .D2(dac_dat_b_reg[i]),      // Data for falling edge of C (or rising if OPPOSITE_EDGE)
      .C (dft_dac_2clk),          // Use DFT-muxed clock
      .CE(1'b1),                  // Clock enable
      .R (oddr_rst_signal),       // Use DFT-muxed asynchronous reset (Active High)
      .S (1'b0)                   // Set (disabled)
    );
  end
endgenerate

// Placeholder for PWM logic - Assuming it uses dft_dac_2clk and pwm_rst_signal
// Ensure any FFs within PWM logic use dft_dac_2clk and pwm_rst_signal correctly for DFT
// assign dac_pwm_o = ...;
// assign dac_pwm_sync_o = ...;

// Note: PWM outputs dac_pwm_o and dac_pwm_sync_o are not driven as the logic is missing.
// Assign default values or implement logic as needed.
assign dac_pwm_o = 4'b0;
assign dac_pwm_sync_o = 1'b0;

endmodule