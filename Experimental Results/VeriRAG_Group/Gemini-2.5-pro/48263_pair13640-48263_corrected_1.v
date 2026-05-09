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
  output   [  4-1: 0] dac_pwm_o          ,
  output   [ 14-1: 0] adc_dat_a_o        ,
  output   [ 14-1: 0] adc_dat_b_o        ,
  output              adc_clk_o          ,
  input               adc_rst_i          ,
  output              ser_clk_o          ,
  input    [ 14-1: 0] dac_dat_a_i        ,
  input    [ 14-1: 0] dac_dat_b_i        ,
  input    [ 24-1: 0] dac_pwm_a_i        ,
  input    [ 24-1: 0] dac_pwm_b_i        ,
  input    [ 24-1: 0] dac_pwm_c_i        ,
  input    [ 24-1: 0] dac_pwm_d_i        ,
  output              dac_pwm_sync_o     ,
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
   .RST          ( !adc_rst_i      ) // PLL reset directly from primary input inverted
);
BUFG i_dacfb_buf   (.O(dac_clk_fb_buf), .I(dac_clk_fb));
BUFG i_dac1_buf    (.O(dac_clk),        .I(dac_clk_out));
BUFG i_dac2_buf    (.O(dac_2clk),       .I(dac_2clk_out));
BUFG i_dac2ph_buf  (.O(dac_2ph),        .I(dac_2ph_out));
BUFG i_ser_buf     (.O(ser_clk_o),      .I(ser_clk_out));

// Internal DAC reset generation (functional mode)
always @(posedge dft_dac_clk) begin
   dac_rst   <= !dac_locked;
end

// Synchronize internal reset to dft_dac_2clk domain for PWM logic
reg dac_rst_sync1, dac_rst_sync2;
always @(posedge dft_dac_2clk) begin
    dac_rst_sync1 <= dac_rst;
    dac_rst_sync2 <= dac_rst_sync1;
end

// DFT Reset Muxes
wire pwm_rst_signal = test_i ? !adc_rst_i : dac_rst_sync2; // Synchronous reset for PWM
wire oddr_rst_signal = test_i ? !adc_rst_i : dac_rst;     // Asynchronous reset for ODDRs

reg  [14-1: 0] dac_dat_a  ;
reg  [14-1: 0] dac_dat_b  ;
// DAC input registers (using dft_dac_clk, no reset needed here based on original logic)
always @(posedge dft_dac_clk) begin
   dac_dat_a <= {dac_dat_a_i[14-1], ~dac_dat_a_i[14-2:0]};
   dac_dat_b <= {dac_dat_b_i[14-1], ~dac_dat_b_i[14-2:0]};
end

// ODDR Instances for DAC output interface
ODDR i_dac_clk ( .Q(dac_clk_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2ph),  .CE(1'b1), .R(1'b0), .S(1'b0) ); // No reset
ODDR i_dac_wrt ( .Q(dac_wrt_o), .D1(1'b0), .D2(1'b1), .C(dft_dac_2clk), .CE(1'b1), .R(1'b0), .S(1'b0) ); // No reset
ODDR i_dac_sel (