// 1_corrected_clk.v
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
  // DFT input
  input               test_mode          // Test mode enable signal
);

reg  [14-1: 0] adc_dat_a  ;
reg  [14-1: 0] adc_dat_b  ;
wire           adc_clk_in ;
wire           adc_clk    ;

// Input buffer for primary clock
IBUFDS i_clk ( .I(adc_clk_p_i), .IB(adc_clk_n_i), .O(adc_clk_in));
// Buffer for the primary clock
BUFG i_adc_buf  (.O(adc_clk), .I(adc_clk_in));

// ADC data registers clocked by the primary clock derivative
always @(posedge adc_clk) begin
   adc_dat_a <= adc_dat_a_i[16-1:2];
   adc_dat_b <= adc_dat_b_i[16-1:2];
end

assign adc_dat_a_o = {adc_dat_a[14-1], ~adc_dat_a[14-2:0]};
assign adc_dat_b_o = {adc_dat_b[14-1], ~adc_dat_b[14-2:0]};
assign adc_clk_o   =  adc_clk ; // Output the buffered primary clock

// Wires for PLL generated clocks
wire  dac_clk_fb      ;
wire  dac_clk_fb_buf  ;
wire  dac_clk_out     ;
wire  dac_2clk_out    ;
wire  dac_clk_int     ; // Internal PLL clock 1x
wire  dac_2clk_int    ; // Internal PLL clock 2x
wire  dac_locked      ;
reg   dac_rst         ;
wire  ser_clk_out     ;
wire  dac_2ph_out     ;
wire  dac_2ph_int     ; // Internal PLL clock 2x phase shifted

// PLL instance generating internal clocks
PLLE2_ADV
#(
   .BANDWIDTH            ( "OPTIMIZED"   ),
   .COMPENSATION         ( "ZHOLD"       ),
   .DIVCLK_DIVIDE        (  1            ),
   .CLKFBOUT_MULT        (  8            ),
   .CLKFBOUT_PHASE       (  0.000        ),
   .CLKOUT0_DIVIDE       (  8            ), // Generates dac_clk_out (1x)
   .CLKOUT0_PHASE        (  0.000        ),
   .CLKOUT0_DUTY_CYCLE   (  0.5          ),
   .CLKOUT1_DIVIDE       (  4            ), // Generates dac_2clk_out (2x)
   .CLKOUT1_PHASE        (  0.000        ),
   .CLKOUT1_DUTY_CYCLE   (  0.5          ),
   .CLKOUT2_DIVIDE       (  4            ), // Generates dac_2ph_out (2x, phase shifted)
   .CLKOUT2_PHASE        ( -45.000       ),
   .CLKOUT2_DUTY_CYCLE   (  0.5          ),
   .CLKOUT3_DIVIDE       (  4            ), // Generates ser_clk_out
   .CLKOUT3_PHASE        (  0.000        ),
   .CLKOUT3_DUTY_CYCLE   (  0.5          ),
   .CLKIN1_PERIOD        (  8.000        ), // Assuming adc_clk is 125MHz
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
   .CLKIN1       (  adc_clk        ), // PLL input is derived from primary clock
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
   .RST          ( !adc_rst_i      ) // Reset is derived from primary input
);

// Buffers for PLL outputs
BUFG i_dacfb_buf   (.O(dac_clk_fb_buf), .I(dac_clk_fb));
BUFG i_dac1_buf    (.O(dac_clk_int),    .I(dac_clk_out));
BUFG i_dac2_buf    (.O(dac_2clk_int),   .I(dac_2clk_out));
BUFG i_dac2ph_buf  (.O(dac_2ph_int),    .I(dac_2ph_out));
BUFG i_ser_buf     (.O(ser_clk_o),      .I(ser_clk_out)); // ser_clk_o directly used

// DFT Clock Muxing: Select primary clock (adc_clk) in test_mode
wire dac_clk;
wire dac_2clk;
wire dac_2ph;

assign dac_clk  = test_mode ? adc_clk : dac_clk_int;
assign dac_2clk = test_mode ? adc_clk : dac_2clk_int;
assign dac_2ph  = test_mode ? adc_clk : dac_2ph_int;

reg  [14-1: 0] dac_dat_a  ;
reg  [14-1: 0] dac_dat_b  ;

// DAC data registers clocked by the muxed clock
always @(posedge dac_clk) begin
   dac_dat_a <= {dac_dat_a_i[14-1], ~dac_dat_a_i[14-2:0]};
   dac_dat_b <= {dac_dat_b_i[14-1], ~dac_dat_b_i[14-2:0]};
   dac_rst   <= !dac_locked; // dac_rst is synchronous to dac_clk
end

// ODDR instances using muxed clocks
ODDR i_dac_clk ( .Q(dac_clk_o), .D1(1'b0), .D2(1'b1), .C(dac_2ph),  .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by muxed dac_2ph
ODDR i_dac_wrt ( .Q(dac_wrt_o), .D1(1'b0), .D2(1'b1), .C(dac_2clk), .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by muxed dac_2clk
ODDR i_dac_sel ( .Q(dac_sel_o), .D1(1'b1), .D2(1'b0), .C(dac_clk ), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_rst ( .Q(dac_rst_o), .D1(dac_rst), .D2(dac_rst), .C(dac_clk ), .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_0  ( .Q(dac_dat_o[ 0]), .D1(dac_dat_b[ 0]), .D2(dac_dat_a[ 0]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_1  ( .Q(dac_dat_o[ 1]), .D1(dac_dat_b[ 1]), .D2(dac_dat_a[ 1]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_2  ( .Q(dac_dat_o[ 2]), .D1(dac_dat_b[ 2]), .D2(dac_dat_a[ 2]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_3  ( .Q(dac_dat_o[ 3]), .D1(dac_dat_b[ 3]), .D2(dac_dat_a[ 3]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_4  ( .Q(dac_dat_o[ 4]), .D1(dac_dat_b[ 4]), .D2(dac_dat_a[ 4]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_5  ( .Q(dac_dat_o[ 5]), .D1(dac_dat_b[ 5]), .D2(dac_dat_a[ 5]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_6  ( .Q(dac_dat_o[ 6]), .D1(dac_dat_b[ 6]), .D2(dac_dat_a[ 6]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_7  ( .Q(dac_dat_o[ 7]), .D1(dac_dat_b[ 7]), .D2(dac_dat_a[ 7]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_8  ( .Q(dac_dat_o[ 8]), .D1(dac_dat_b[ 8]), .D2(dac_dat_a[ 8]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_9  ( .Q(dac_dat_o[ 9]), .D1(dac_dat_b[ 9]), .D2(dac_dat_a[ 9]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_10 ( .Q(dac_dat_o[10]), .D1(dac_dat_b[10]), .D2(dac_dat_a[10]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_11 ( .Q(dac_dat_o[11]), .D1(dac_dat_b[11]), .D2(dac_dat_a[11]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_12 ( .Q(dac_dat_o[12]), .D1(dac_dat_b[12]), .D2(dac_dat_a[12]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk
ODDR i_dac_13 ( .Q(dac_dat_o[13]), .D1(dac_dat_b[13]), .D2(dac_dat_a[13]), .C(dac_clk), .CE(1'b1), .R(dac_rst), .S(1'b0) ); // Clocked by muxed dac_clk

// PWM Logic
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

// PWM registers clocked by the muxed 2x clock
always @(posedge dac_2clk) begin // Use the muxed clock
   // Use synchronous reset derived from dac_rst (which is sync to dac_clk)
   // For simplicity in this fix, we assume dac_rst can be used directly here,
   // though proper reset synchronization between clock domains might be needed in a real design.
   if (dac_rst == 1'b1) begin
      dac_pwm_vcnt <=  8'h0 ;
      dac_pwm_bcnt <=  4'h0 ;
      dac_pwm_r    <=  4'h0 ;
      // Initialize other PWM regs on reset
      dac_pwm_va   <=  8'h0;
      dac_pwm_vb   <=  8'h0;
      dac_pwm_vc   <=  8'h0;
      dac_pwm_vd   <=  8'h0;
      dac_pwm_ba   <= 16'h0;
      dac_pwm_bb   <= 16'h0;
      dac_pwm_bc   <= 16'h0;
      dac_pwm_bd   <= 16'h0;
      dac_pwm_vcnt_r <= 8'h0;
      dac_pwm_va_r <= 8'h0;
      dac_pwm_vb_r <= 8'h0;
      dac_pwm_vc_r <= 8'h0;
      dac_pwm_vd_r <= 8'h0;
      dac_pwm      <= 4'h0;
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
         // Update base values only when bcnt wraps around (or is about to)
         if (dac_pwm_bcnt == 4'hF) begin
            dac_pwm_va <= dac_pwm_a_i[24-1:16];
            dac_pwm_vb <= dac_pwm_b_i[24-1:16];
            dac_pwm_vc <= dac_pwm_c_i[24-1:16];
            dac_pwm_vd <= dac_pwm_d_i[24-1:16];
            dac_pwm_ba <= dac_pwm_a_i[16-1:0];
            dac_pwm_bb <= dac_pwm_b_i[16-1:0];
            dac_pwm_bc <= dac_pwm_c_i[16-1:0];
            dac_pwm_bd <= dac_pwm_d_i[16-1:0];
         end else begin // Shift otherwise
            dac_pwm_ba <= {1'b0, dac_pwm_ba[15:1]};
            dac_pwm_bb <= {1'b0, dac_pwm_bb[15:1]};
            dac_pwm_bc <= {1'b0, dac_pwm_bc[15:1]};
            dac_pwm_bd <= {1'b0, dac_pwm_bd[15:1]};
         end
      end
      dac_pwm <= dac_pwm_r ;
   end
end

assign dac_pwm_o      = dac_pwm ;
assign dac_pwm_sync_o = (dac_pwm_bcnt == 4'hF) && (dac_pwm_vcnt == (PWM_FULL-1)) ;

endmodule