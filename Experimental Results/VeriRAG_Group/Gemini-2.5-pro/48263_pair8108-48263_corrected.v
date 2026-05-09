module red_pitaya_analog
(
  input               test_mode_i        ,  // DFT Test Mode input
  input               test_clk_i         ,  // DFT Test Clock input (can be tied to adc_clk or a dedicated test clock)
  input               test_rst_i         ,  // DFT Test Reset input (active high for FFs/ODDRs)
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
  input               adc_rst_i          ,  // Functional Reset (active low assumed based on PLL usage)
  output              ser_clk_o          ,
  input    [ 14-1: 0] dac_dat_a_i        ,
  input    [ 14-1: 0] dac_dat_b_i        ,
  input    [ 24-1: 0] dac_pwm_a_i        ,
  input    [ 24-1: 0] dac_pwm_b_i        ,
  input    [ 24-1: 0] dac_pwm_c_i        ,
  input    [ 24-1: 0] dac_pwm_d_i        ,
  output              dac_pwm_sync_o
);
reg  [14-1: 0] adc_dat_a  ;
reg  [14-1: 0] adc_dat_b  ;
wire           adc_clk_in ;
wire           adc_clk    ;

// DFT Signals
wire           dac_clk_dft;
wire           dac_2clk_dft;
wire           dac_2ph_dft;
wire           dac_rst_dft;


IBUFDS i_clk ( .I(adc_clk_p_i), .IB(adc_clk_n_i), .O(adc_clk_in));
BUFG i_adc_buf  (.O(adc_clk), .I(adc_clk_in));

always @(posedge adc_clk) begin // Clocked by primary-derived clock - OK
   adc_dat_a <= adc_dat_a_i[16-1:2];
   adc_dat_b <= adc_dat_b_i[16-1:2];
end
assign adc_dat_a_o = {adc_dat_a[14-1], ~adc_dat_a[14-2:0]};
assign adc_dat_b_o = {adc_dat_b[14-1], ~adc_dat_b[14-2:0]};
assign adc_clk_o   =  adc_clk ; // Outputting derived clock - OK for output

wire  dac_clk_fb      ;
wire  dac_clk_fb_buf  ;
wire  dac_clk_out     ;
wire  dac_2clk_out    ;
wire  dac_clk         ; // Internally generated clock
wire  dac_2clk        ; // Internally generated clock
wire  dac_locked      ;
reg   dac_rst         ; // Internally generated reset signal
wire  ser_clk_out     ;
wire  dac_2ph_out     ;
wire  dac_2ph         ; // Internally generated clock
wire  pll_rst         ; // PLL reset derived from primary input

assign pll_rst = !adc_rst_i; // Assuming functional reset adc_rst_i is active low

PLLE2_ADV
#(
   .BANDWIDTH            ( "OPTIMIZED"   ),
   .COMPENSATION         ( "ZHOLD"       ),
   .DIVCLK_DIVIDE        (  1            ),
   .CLKFBOUT_MULT        (  8            ),
   .CLKFBOUT_PHASE       (  0.000        ),
   .CLKOUT0_DIVIDE       (  8            ), // Generates dac_clk_out (dac_clk)
   .CLKOUT0_PHASE        (  0.000        ),
   .CLKOUT0_DUTY_CYCLE   (  0.5          ),
   .CLKOUT1_DIVIDE       (  4            ), // Generates dac_2clk_out (dac_2clk)
   .CLKOUT1_PHASE        (  0.000        ),
   .CLKOUT1_DUTY_CYCLE   (  0.5          ),
   .CLKOUT2_DIVIDE       (  4            ), // Generates dac_2ph_out (dac_2ph)
   .CLKOUT2_PHASE        ( -45.000       ),
   .CLKOUT2_DUTY_CYCLE   (  0.5          ),
   .CLKOUT3_DIVIDE       (  4            ), // Generates ser_clk_out (ser_clk_o)
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
   .CLKIN1       (  adc_clk        ), // Clock input derived from primary inputs - OK for PLL input
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
   .RST          (  pll_rst        ) // Reset derived from primary input - OK
);

BUFG i_dacfb_buf   (.O(dac_clk_fb_buf), .I(dac_clk_fb));
BUFG i_dac1_buf    (.O(dac_clk),        .I(dac_clk_out));
BUFG i_dac2_buf    (.O(dac_2clk),       .I(dac_2clk_out));
BUFG i_dac2ph_buf  (.O(dac_2ph),        .I(dac_2ph_out));
BUFG i_ser_buf     (.O(ser_clk_o),      .I(ser_clk_out)); // Outputting derived clock - OK for output

// DFT Clock Muxing
assign dac_clk_dft  = test_mode_i ? test_clk_i : dac_clk;
assign dac_2clk_dft = test_mode_i ? test_clk_i : dac_2clk;
assign dac_2ph_dft  = test_mode_i ? test_clk_i : dac_2ph;

// DFT Reset Muxing
// dac_rst is the functional reset based on PLL lock
// test_rst_i is the primary test reset (active high assumed for FFs/ODDRs)
assign dac_rst_dft  = test_mode_i ? test_rst_i : dac_rst;


reg  [14-1: 0] dac_dat_a  ;
reg  [14-1: 0] dac_dat_b  ;

// This block generates the functional reset dac_rst and registers DAC data
// Clocked by the DFT-muxed clock
always @(posedge dac_clk_dft) begin
   dac_dat_a <= {dac_dat_a_i[14-1], ~dac_dat_a_i[14-2:0]};
   dac_dat_b <= {dac_dat_b_i[14-1], ~dac_dat_b_i[14-2:0]};
   dac_rst   <= !dac_locked; // Functional reset generation (value may be ignored in test mode)
end

// ODDR instances using DFT-muxed clocks and reset
ODDR i_dac_clk ( .Q(dac_clk_o), .D1(1'b0), .D2(1'b1), .C(dac_2ph_dft),  .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by dac_2ph_dft
ODDR i_dac_wrt ( .Q(dac_wrt_o), .D1(1'b0), .D2(1'b1), .C(dac_2clk_dft), .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by dac_2clk_dft
ODDR i_dac_sel ( .Q(dac_sel_o), .D1(1'b1), .D2(1'b0), .C(dac_clk_dft ), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) ); // Clocked by dac_clk_dft, Reset by dac_rst_dft
ODDR i_dac_rst ( .Q(dac_rst_o), .D1(dac_rst_dft), .D2(dac_rst_dft), .C(dac_clk_dft ), .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by dac_clk_dft, Data sourced from dac_rst_dft
ODDR i_dac_0  ( .Q(dac_dat_o[ 0]), .D1(dac_dat_b[ 0]), .D2(dac_dat_a[ 0]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) ); // Clocked by dac_clk_dft, Reset by dac_rst_dft
ODDR i_dac_1  ( .Q(dac_dat_o[ 1]), .D1(dac_dat_b[ 1]), .D2(dac_dat_a[ 1]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_2  ( .Q(dac_dat_o[ 2]), .D1(dac_dat_b[ 2]), .D2(dac_dat_a[ 2]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_3  ( .Q(dac_dat_o[ 3]), .D1(dac_dat_b[ 3]), .D2(dac_dat_a[ 3]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_4  ( .Q(dac_dat_o[ 4]), .D1(dac_dat_b[ 4]), .D2(dac_dat_a[ 4]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_5  ( .Q(dac_dat_o[ 5]), .D1(dac_dat_b[ 5]), .D2(dac_dat_a[ 5]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_6  ( .Q(dac_dat_o[ 6]), .D1(dac_dat_b[ 6]), .D2(dac_dat_a[ 6]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_7  ( .Q(dac_dat_o[ 7]), .D1(dac_dat_b[ 7]), .D2(dac_dat_a[ 7]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_8  ( .Q(dac_dat_o[ 8]), .D1(dac_dat_b[ 8]), .D2(dac_dat_a[ 8]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_9  ( .Q(dac_dat_o[ 9]), .D1(dac_dat_b[ 9]), .D2(dac_dat_a[ 9]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_10 ( .Q(dac_dat_o[10]), .D1(dac_dat_b[10]), .D2(dac_dat_a[10]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_11 ( .Q(dac_dat_o[11]), .D1(dac_dat_b[11]), .D2(dac_dat_a[11]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_12 ( .Q(dac_dat_o[12]), .D1(dac_dat_b[12]), .D2(dac_dat_a[12]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_13 ( .Q(dac_dat_o[13]), .D1(dac_dat_b[13]), .D2(dac_dat_a[13]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );

localparam PWM_FULL = 8'd156 ;
reg  [ 4-1: 0] dac_pwm_bcnt   ;
reg  [16-1: 0] dac_pwm_ba     ;
reg  [16-1: 0] dac_pwm_bb     ;
reg  [16-1: 0] dac_pwm_bc     ;
reg  [16-1: 0] dac_pwm_bd     ;
reg  [ 8-1: 0] dac_pwm_vcnt   ;
reg  [ 8-1: 0] dac_pwm_vcnt_r ;
reg  [ 8-1: 0] dac_pwm_va     ;
reg  [ 8-1: 0] dac_pwm_vb     ;
reg  [ 8-1: 0] dac_pwm_vc     ;
reg  [ 8-1: 0] dac_pwm_vd     ;
reg  [ 8-1: 0] dac_pwm_va_r   ;
reg  [ 8-1: 0] dac_pwm_vb_r   ;
reg  [ 8-1: 0] dac_pwm_vc_r   ;
reg  [ 8-1: 0] dac_pwm_vd_r   ;
reg  [ 4-1: 0] dac_pwm        ;
reg  [ 4-1: 0] dac_pwm_r      ;

// PWM logic using DFT-muxed clock and reset
always @(posedge dac_2clk_dft) begin
   if (dac_rst_dft == 1'b1) begin // Use DFT-muxed reset
      dac_pwm_vcnt <=  8'h0 ;
      dac_pwm_bcnt <=  4'h0 ;
      dac_pwm_r    <=  4'h0 ;
      // Consider resetting other PWM registers if necessary for test
      dac_pwm_va <= 8'h0;
      dac_pwm_vb <= 8'h0;
      dac_pwm_vc <= 8'h0;
      dac_pwm_vd <= 8'h0;
      dac_pwm_ba <= 16'h0;
      dac_pwm_bb <= 16'h0;
      dac_pwm_bc <= 16'h0;
      dac_pwm_bd <= 16'h0;
      dac_pwm_vcnt_r <= 8'h0;
      dac_pwm_va_r <= 8'h0;
      dac_pwm_vb_r <= 8'h0;
      dac_pwm_vc_r <= 8'h0;
      dac_pwm_vd_r <= 8'h0;
      dac_pwm <= 4'h0;
   end
   else begin
      dac_pwm_vcnt <= (dac_pwm_vcnt == PWM_FULL) ? 8'h1 : (dac_pwm_vcnt + 8'd1) ;
      dac_pwm_vcnt_r <= dac_pwm_vcnt;
      dac_pwm_va_r   <= (dac_pwm_va + dac_pwm_ba[0]) ;
      dac_pwm_vb_r   <= (dac_pwm_vb + dac_pwm_bb[0]) ;
      dac_pwm_vc_r   <= (dac_pwm_vc + dac_pwm_bc[0]) ;
      dac_pwm_vd_r   <= (dac_pwm_vd + dac_pwm_bd[0]) ;
      dac_pwm_r[0] <= (dac_pwm_vcnt_r <= dac_pwm_va_r) ;
      dac_pwm_r[1] <= (dac_pwm_vcnt_r <= dac_pwm_vb_r) ;
      dac_pwm_r[2] <= (dac_pwm_vcnt_r <= dac_pwm_vc_r) ;
      dac_pwm_r[3] <= (dac_pwm_vcnt_r <= dac_pwm_vd_r) ;
      if (dac_pwm_vcnt == PWM_FULL) begin
         dac_pwm_bcnt <= dac_pwm_bcnt + 4'h1 ;
         dac_pwm_va <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_a_i[24-1:16] : dac_pwm_va ;
         dac_pwm_vb <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_b_i[24-1:16] : dac_pwm_vb ;
         dac_pwm_vc <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_c_i[24-1:16] : dac_pwm_vc ;
         dac_pwm_vd <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_d_i[24-1:16] : dac_pwm_vd ;
         dac_pwm_ba <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_a_i[16-1:0] : {1'b0,dac_pwm_ba[15:1]} ;
         dac_pwm_bb <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_b_i[16-1:0] : {1'b0,dac_pwm_bb[15:1]} ;
         dac_pwm_bc <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_c_i[16-1:0] : {1'b0,dac_pwm_bc[15:1]} ;
         dac_pwm_bd <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_d_i[16-1:0] : {1'b0,dac_pwm_bd[15:1]} ;
      end
      dac_pwm <= dac_pwm_r ;
   end
end
assign dac_pwm_o      = dac_pwm ;
assign dac_pwm_sync_o = (dac_pwm_bcnt == 4'hF) && (dac_pwm_vcnt == (PWM_FULL-1)) ;
endmodule