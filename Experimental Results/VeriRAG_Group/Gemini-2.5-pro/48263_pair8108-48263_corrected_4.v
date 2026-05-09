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
wire           dac_rst_dft; // Active High Reset for DFT


IBUFDS i_clk ( .I(adc_clk_p_i), .IB(adc_clk_n_i), .O(adc_clk_in));
BUFG i_adc_buf  (.O(adc_clk), .I(adc_clk_in));

// Added asynchronous reset test_rst_i (active high)
always @(posedge adc_clk or posedge test_rst_i) begin
   if (test_rst_i) begin
      adc_dat_a <= 14'b0;
      adc_dat_b <= 14'b0;
   end else begin
      adc_dat_a <= adc_dat_a_i[16-1:2];
      adc_dat_b <= adc_dat_b_i[16-1:2];
   end
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
reg   dac_rst_internal; // Internally generated reset signal state (active low based on !dac_locked)
wire  ser_clk_out     ;
wire  dac_2ph_out     ;
wire  dac_2ph         ; // Internally generated clock
wire  pll_rst         ; // PLL reset derived from primary input (active high)

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

// Internal functional reset generation state register
// Added asynchronous reset test_rst_i (active high)
always @(posedge dac_clk_dft or posedge test_rst_i) begin
    if (test_rst_i) begin
        dac_rst_internal <= 1'b1; // Reset to functional reset active state (unlocked)
    end else begin
        dac_rst_internal <= !dac_locked; // dac_rst_internal is 1 if unlocked (reset active), 0 if locked (reset inactive)
    end
end

// DFT Reset Muxing (outputting active-high reset for ODDRs and PWM logic)
// test_rst_i is active high (primary input)
// dac_rst_internal is registered, 1=reset active, 0=reset inactive.
wire func_rst_active_high = dac_rst_internal; // Functional reset is active high
assign dac_rst_dft  = test_mode_i ? test_rst_i : func_rst_active_high; // Selects between test reset and functional reset (both active high)


reg  [14-1: 0] dac_dat_a_reg  ; // Renamed to avoid conflict with adc_dat_a
reg  [14-1: 0] dac_dat_b_reg  ; // Renamed to avoid conflict with adc_dat_b

// This block registers DAC data
// Clocked by the DFT-muxed clock, Reset by DFT-muxed reset (active high)
always @(posedge dac_clk_dft or posedge dac_rst_dft) begin
   if (dac_rst_dft) begin
      dac_dat_a_reg <= 14'b0;
      dac_dat_b_reg <= 14'b0;
   end else begin
      dac_dat_a_reg <= {dac_dat_a_i[14-1], ~dac_dat_a_i[14-2:0]};
      dac_dat_b_reg <= {dac_dat_b_i[14-1], ~dac_dat_b_i[14-2:0]};
   end
end

// ODDR instances using DFT-muxed clocks and active-high reset
// Note: ODDR R (reset) input is typically active high.
ODDR i_dac_clk ( .Q(dac_clk_o), .D1(1'b0), .D2(1'b1), .C(dac_2ph_dft),  .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by dac_2ph_dft
ODDR i_dac_wrt ( .Q(dac_wrt_o), .D1(1'b0), .D2(1'b1), .C(dac_2clk_dft), .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by dac_2clk_dft
ODDR i_dac_sel ( .Q(dac_sel_o), .D1(1'b1), .D2(1'b0), .C(dac_clk_dft ), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) ); // Clocked by dac_clk_dft, Reset by dac_rst_dft (Active High)
ODDR i_dac_rst ( .Q(dac_rst_o), .D1(dac_rst_dft), .D2(dac_rst_dft), .C(dac_clk_dft ), .CE(1'b1), .R(1'b0), .S(1'b0) ); // Clocked by dac_clk_dft, Data sourced from dac_rst_dft
ODDR i_dac_0  ( .Q(dac_dat_o[ 0]), .D1(dac_dat_b_reg[ 0]), .D2(dac_dat_a_reg[ 0]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) ); // Use renamed regs, Clocked by dac_clk_dft, Reset by dac_rst_dft (Active High)
ODDR i_dac_1  ( .Q(dac_dat_o[ 1]), .D1(dac_dat_b_reg[ 1]), .D2(dac_dat_a_reg[ 1]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_2  ( .Q(dac_dat_o[ 2]), .D1(dac_dat_b_reg[ 2]), .D2(dac_dat_a_reg[ 2]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_3  ( .Q(dac_dat_o[ 3]), .D1(dac_dat_b_reg[ 3]), .D2(dac_dat_a_reg[ 3]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_4  ( .Q(dac_dat_o[ 4]), .D1(dac_dat_b_reg[ 4]), .D2(dac_dat_a_reg[ 4]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_5  ( .Q(dac_dat_o[ 5]), .D1(dac_dat_b_reg[ 5]), .D2(dac_dat_a_reg[ 5]), .C(dac_clk_dft), .CE(1'b1), .R(dac_rst_dft), .S(1'b0) );
ODDR i_dac_6