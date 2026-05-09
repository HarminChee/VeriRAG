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
  input               adc_rst_i          ,
  output              ser_clk_o          ,
  input    [ 14-1: 0] dac_dat_a_i        ,
  input    [ 14-1: 0] dac_dat_b_i        ,
  input    [ 24-1: 0] dac_pwm_a_i        , // Assuming used by PWM logic
  input    [ 24-1: 0] dac_pwm_b_i        , // Assuming used by PWM logic
  input    [ 24-1: 0] dac_pwm_c_i        , // Assuming used by PWM logic
  input    [ 24-1: 0] dac_pwm_d_i        , // Assuming used by PWM logic
  output              dac_pwm_sync_o     , // Assuming used by PWM logic
  input               test_i
);
reg  [14-1: 0] adc_dat_a  ;
reg  [14-1: 0] adc_dat_b  ;
wire           adc_clk_in ;
wire           adc_clk    ;

IBUFDS i_clk ( .I(adc_clk_p_i), .IB(adc_clk_n_i), .O(adc_clk_in));
BUFG i_adc_buf  (.O(adc_clk), .I(adc_clk_in));

always @(posedge adc_clk) begin
   adc_dat_a <= adc_dat_a_i[16-1:2];
   adc_dat_b <= adc_dat_b_i[16-1:2];
end

assign adc_dat_a_o = {adc_dat_a[14-1], ~adc_dat_a[14-2:0]};
assign adc_dat_b_o = {adc_dat_b[14-1], ~adc_dat_b[14-2:0]};
assign adc_clk_o   =  adc_clk ;

wire  dac_clk_fb      ;
wire  dac_clk_fb_buf  ;
wire  dac_clk_out     ;
wire  dac_2clk_out    ;
wire  dac_clk         ;
wire  dac_2clk        ;
wire  dac_locked      ;
reg   dac_rst         ;
wire  ser_clk_out     ;
wire  dac_2ph_out     ;
wire  dac_2ph         ;
wire  dft_dac_clk     ;
wire  dft_dac_2clk    ;
wire  dft_dac_2ph     ;

// DFT Clock Muxes
assign dft_dac_clk  = test_i ? adc_clk : dac_clk;
assign dft_dac_2clk = test_i ? adc_clk : dac_2clk;
assign dft_dac_2ph  = test_i ? adc_clk : dac_2ph;

PLLE2_ADV
#(
   .BANDWIDTH            ( "OPTIMIZED"   ),
   .COMPENSATION         ( "ZHOLD"       ),
   .DIVCLK_DIVIDE        (  1            ),
   .CLKFBOUT_MULT        (  8            ),
   .CLKFBOUT_PHASE       (  0.000        ),
   .CLKOUT0_DIVIDE       (  8            ),
   .CLKOUT0_PHASE        (  0.000        ),
   .CLKOUT0_DUTY_CYCLE   (  0.5          ),
   .CLKOUT1_DIVIDE       (  4            ),
   .CLKOUT1_PHASE        (  0.000        ),
   .CLKOUT1_DUTY_CYCLE   (  0.5          ),
   .CLKOUT2_DIVIDE       (  4            ),
   .CLKOUT2_PHASE        ( -45.000       ),
   .CLKOUT2_DUTY_CYCLE   (  0.5          ),
   .CLKOUT3_DIVIDE       (  4            ),
   .CLKOUT3_PHASE        (  0.000        ),
   .CLKOUT3_DUTY_CYCLE   (  0.5          ),
   .CLKIN1_PERIOD        (  8.000        ),
   .REF_JITTER1          (  0.010        )
)
i_dac_plle2
(
   .CLKFBOUT     (  dac_clk_fb     ),
   .CLKOUT0      (  dac_clk_out    ),
   .CLKOUT1      (  dac_2clk_out   ),
   .CLKOUT2      (  dac_2ph_out    ),
   .CLKOUT3      (  ser_clk_out    ),
   .CLKOUT4      (        ),
   .CLKOUT5      (        ),
   .CLKFBIN      (  dac_clk_fb_buf ),
   .CLKIN1       (  adc_clk        ),
   .CLKIN2       (  1'b0           ),
   .CLKINSEL     (  1'b1           ),
   .DADDR        (  7'h0           ),
   .DCLK         (  1'b0           ),
   .DEN          (  1'b0           ),
   .DI           (  16'h0          ),
   .DO           (        ),
   .DRDY         (        ),
   .DWE          (  1'b0           ),
   .LOCKED       (  dac_locked     ),
   .PWRDWN       (  1'b0           ),
   .RST          ( !adc_rst_i      ) // PLL reset directly from primary input inverted (Active High Reset)
);

BUFG i_dacfb_buf   (.O(dac_clk_fb_buf), .I(dac_clk_fb));
BUFG i_dac1_buf    (.O(dac_clk),        .I(dac_clk_out));
BUFG i_dac2_buf    (.O(dac_2clk),       .I(dac_2clk_out));
BUFG i_dac2ph_buf  (.O(dac_2ph),        .I(dac_2ph_out));
BUFG i_ser_buf     (.O(ser_clk_o),      .I(ser_clk_out));

// Internal DAC reset generation (functional mode) - Active High
always @(posedge dft_dac_clk) begin
   dac_rst   <= !dac_locked;
end

// Synchronize internal reset to dft_dac_2clk domain for PWM logic
reg dac_rst_sync1, dac_rst_sync2;
always @(posedge dft_dac_2clk) begin
    dac_rst_sync1 <= dac_rst;
    dac_rst_sync2 <= dac_rst_sync1;
end

// DFT Reset Muxes (Active High)
wire pwm_rst_signal = test_i ? !adc_rst_i : dac_rst_sync2; // Synchronous reset for PWM (relative to dft_dac_2clk)
wire oddr_rst_signal = test_i ? !adc_rst_i : dac_rst;     // Asynchronous reset for ODDRs (relative to dft_dac_2clk/dft_dac_2ph)

assign dac_rst_o = oddr_rst_signal; // Output the DFT-muxed reset

reg  [14-1: 0] dac_dat_a  ;
reg  [14-1: 0] dac_dat_b  ;
// DAC input registers (using dft_dac_clk)
always @(posedge dft_dac_clk) begin
   // Assuming active-high asynchronous reset is not needed here based on original logic structure
   // If reset was needed: if (oddr_rst_signal) begin ... end else begin ... end
   dac_dat_a <= {dac_dat_a_i[14-1], ~dac_dat_a_i[14-2:0]};
   dac_dat_b <= {dac_dat_b_i[14-1], ~dac_dat_b_i[14-2:0]};
end

// ODDR Instances for DAC output interface
ODDR #( .SRTYPE("ASYNC") ) i_dac_clk ( .Q(dac_clk_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2ph),  .CE(1'b1), .R(oddr_rst_signal), .S(1'b0) );
ODDR #( .SRTYPE("ASYNC") ) i_dac_wrt ( .Q(dac_wrt_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2clk), .CE(1'b1), .R(oddr_rst_signal), .S(1'b0) );
ODDR #( .SRTYPE("ASYNC") ) i_dac_sel ( .Q(dac_sel_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2clk), .CE(1'b1), .R(oddr_rst_signal), .S(1'b0) ); // Completed instance

genvar i;
generate
  for (i = 0; i < 14; i = i + 1) begin : gen_dac_dat_oddr
    ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // Example, adjust as needed
      .INIT(1'b0),
      .SRTYPE("ASYNC") // Reset is asynchronous to the ODDR clock
    ) i_dac_dat_oddr (
      .Q (dac_dat_o[i]),
      .D1(dac_dat_a[i]), // Placeholder: Using registered data
      .D2(dac_dat_b[i]), // Placeholder: Using registered data (adjust based on actual function)
      .C (dft_dac_2clk),
      .CE(1'b1),
      .R (oddr_rst_signal), // Use the muxed reset
      .S (1'b0)
    );
  end
endgenerate

// Placeholder for PWM logic - Assuming it uses dft_dac_2clk and pwm_rst_signal
// assign dac_pwm_o = ...;
// assign dac_pwm_sync_o = ...;

// Note: PWM outputs dac_pwm_o and dac_pwm_sync_o are not driven as the logic is missing.
// Assign default values or implement logic as needed.
assign dac_pwm_o = 4'b0;
assign dac_pwm_sync_o = 1'b0;

endmodule