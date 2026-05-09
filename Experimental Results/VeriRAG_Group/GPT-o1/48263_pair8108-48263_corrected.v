`timescale 1 ps / 1 ps
module red_pitaya_analog
(
  input                test_i,
  input                test_clk_i,
  input    [ 16-1: 2] adc_dat_a_i,
  input    [ 16-1: 2] adc_dat_b_i,
  input               adc_clk_p_i,
  input               adc_clk_n_i,
  output   [ 14-1: 0] dac_dat_o,
  output              dac_wrt_o,
  output              dac_sel_o,
  output              dac_clk_o,
  output              dac_rst_o,
  output   [  4-1: 0] dac_pwm_o,
  output   [ 14-1: 0] adc_dat_a_o,
  output   [ 14-1: 0] adc_dat_b_o,
  output              adc_clk_o,
  input               adc_rst_i,
  output              ser_clk_o,
  input    [ 14-1: 0] dac_dat_a_i,
  input    [ 14-1: 0] dac_dat_b_i,
  input    [ 24-1: 0] dac_pwm_a_i,
  input    [ 24-1: 0] dac_pwm_b_i,
  input    [ 24-1: 0] dac_pwm_c_i,
  input    [ 24-1: 0] dac_pwm_d_i,
  output              dac_pwm_sync_o
);

wire           adc_clk_in;
wire           adc_clk;
wire           adc_clk_dft;

IBUFDS i_clk (
  .I(adc_clk_p_i),
  .IB(adc_clk_n_i),
  .O(adc_clk_in)
);

BUFG i_adc_buf  (
  .O(adc_clk),
  .I(adc_clk_in)
);

wire  dac_clk_fb;
wire  dac_clk_fb_buf;
wire  dac_clk_out;
wire  dac_2clk_out;
wire  dac_clk;
wire  dac_2clk;
wire  dac_locked;
wire  ser_clk_out;
wire  dac_2ph_out;
wire  dac_2ph;

reg  [14-1: 0] adc_dat_a;
reg  [14-1: 0] adc_dat_b;
wire           dac_clk_dft;
wire           dac_2clk_dft;
wire           dac_2ph_dft;
wire           ser_clk_dft;

assign adc_clk_dft   = test_i ? test_clk_i : adc_clk;
assign adc_clk_o     = adc_clk_dft;
assign dac_clk_dft   = test_i ? test_clk_i : dac_clk;
assign dac_2clk_dft  = test_i ? test_clk_i : dac_2clk;
assign dac_2ph_dft   = test_i ? test_clk_i : dac_2ph;
assign ser_clk_dft   = test_i ? test_clk_i : ser_clk_out;
assign ser_clk_o     = ser_clk_dft;

always @(posedge adc_clk_dft) begin
   adc_dat_a <= adc_dat_a_i[16-1:2];
   adc_dat_b <= adc_dat_b_i[16-1:2];
end

assign adc_dat_a_o = {adc_dat_a[14-1], ~adc_dat_a[14-2:0]};
assign adc_dat_b_o = {adc_dat_b[14-1], ~adc_dat_b[14-2:0]};

PLLE2_ADV #(
   .BANDWIDTH          ( "OPTIMIZED" ),
   .COMPENSATION       ( "ZHOLD"     ),
   .DIVCLK_DIVIDE      (  1          ),
   .CLKFBOUT_MULT      (  8          ),
   .CLKFBOUT_PHASE     (  0.000      ),
   .CLKOUT0_DIVIDE     (  8          ),
   .CLKOUT0_PHASE      (  0.000      ),
   .CLKOUT0_DUTY_CYCLE (  0.5        ),
   .CLKOUT1_DIVIDE     (  4          ),
   .CLKOUT1_PHASE      (  0.000      ),
   .CLKOUT1_DUTY_CYCLE (  0.5        ),
   .CLKOUT2_DIVIDE     (  4          ),
   .CLKOUT2_PHASE      ( -45.000     ),
   .CLKOUT2_DUTY_CYCLE (  0.5        ),
   .CLKOUT3_DIVIDE     (  4          ),
   .CLKOUT3_PHASE      (  0.000      ),
   .CLKOUT3_DUTY_CYCLE (  0.5        ),
   .CLKIN1_PERIOD      (  8.000      ),
   .REF_JITTER1        (  0.010      )
)
i_dac_plle2 (
   .CLKFBOUT  ( dac_clk_fb     ),
   .CLKOUT0   ( dac_clk_out    ),
   .CLKOUT1   ( dac_2clk_out   ),
   .CLKOUT2   ( dac_2ph_out    ),
   .CLKOUT3   ( ser_clk_out    ),
   .CLKOUT4   (               ),
   .CLKOUT5   (               ),
   .CLKFBIN   ( dac_clk_fb_buf ),
   .CLKIN1    ( adc_clk_dft    ),
   .CLKIN2    ( 1'b0           ),
   .CLKINSEL  ( 1'b1           ),
   .DADDR     ( 7'h0           ),
   .DCLK      ( 1'b0           ),
   .DEN       ( 1'b0           ),
   .DI        ( 16'h0          ),
   .DO        (               ),
   .DRDY      (               ),
   .DWE       ( 1'b0           ),
   .LOCKED    ( dac_locked     ),
   .PWRDWN    ( 1'b0           ),
   .RST       ( !adc_rst_i     )
);

BUFG i_dacfb_buf   (.O(dac_clk_fb_buf), .I(dac_clk_fb));
BUFG i_dac1_buf    (.O(dac_clk),        .I(dac_clk_out));
BUFG i_dac2_buf    (.O(dac_2clk),       .I(dac_2clk_out));
BUFG i_dac2ph_buf  (.O(dac_2ph),        .I(dac_2ph_out));

reg  [14-1: 0] dac_dat_a_reg;
reg  [14-1: 0] dac_dat_b_reg;
reg            dac_rst_reg;

always @(posedge dac_clk_dft) begin
   dac_dat_a_reg <= {dac_dat_a_i[14-1], ~dac_dat_a_i[14-2:0]};
   dac_dat_b_reg <= {dac_dat_b_i[14-1], ~dac_dat_b_i[14-2:0]};
   dac_rst_reg   <= !dac_locked;
end

ODDR i_dac_clk (
  .Q (dac_clk_o),
  .D1(1'b0),
  .D2(1'b1),
  .C (dac_2ph_dft),
  .CE(1'b1),
  .R (1'b0),
  .S (1'b0)
);

ODDR i_dac_wrt (
  .Q (dac_wrt_o),
  .D1(1'b0),
  .D2(1'b1),
  .C (dac_2clk_dft),
  .CE(1'b1),
  .R (1'b0),
  .S (1'b0)
);

ODDR i_dac_sel (
  .Q (dac_sel_o),
  .D1(1'b1),
  .D2(1'b0),
  .C (dac_clk_dft),
  .CE(1'b1),
  .R (1'b0),
  .S (1'b0)
);

ODDR i_dac_rst (
  .Q (dac_rst_o),
  .D1(dac_rst_reg),
  .D2(dac_rst_reg),
  .C (dac_clk_dft),
  .CE(1'b1),
  .R (1'b0),
  .S (1'b0)
);

genvar i;
generate
  for (i=0; i<14; i=i+1) begin : gen_dac_data
    ODDR i_dac (
      .Q  (dac_dat_o[i]),
      .D1 (dac_dat_b_reg[i]),
      .D2 (dac_dat_a_reg[i]),
      .C  (dac_clk_dft),
      .CE (1'b1),
      .R  (1'b0),
      .S  (1'b0)
    );
  end
endgenerate

localparam PWM_FULL = 8'd156;

reg  [ 4-1: 0] dac_pwm_bcnt;
reg  [16-1: 0] dac_pwm_ba;
reg  [16-1: 0] dac_pwm_bb;
reg  [16-1: 0] dac_pwm_bc;
reg  [16-1: 0] dac_pwm_bd;
reg  [ 8-1: 0] dac_pwm_vcnt;
reg  [ 8-1: 0] dac_pwm_vcnt_r;
reg  [ 8-1: 0] dac_pwm_va;
reg  [ 8-1: 0] dac_pwm_vb;
reg  [ 8-1: 0] dac_pwm_vc;
reg  [ 8-1: 0] dac_pwm_vd;
reg  [ 8-1: 0] dac_pwm_va_r;
reg  [ 8-1: 0] dac_pwm_vb_r;
reg  [ 8-1: 0] dac_pwm_vc_r;
reg  [ 8-1: 0] dac_pwm_vd_r;
reg  [ 4-1: 0] dac_pwm;
reg  [ 4-1: 0] dac_pwm_r;

always @(posedge dac_2clk_dft) begin
   if (dac_rst_reg == 1'b1) begin
      dac_pwm_vcnt <=  8'h0;
      dac_pwm_bcnt <=  4'h0;
      dac_pwm_r    <=  4'h0;
   end
   else begin
      dac_pwm_vcnt     <= (dac_pwm_vcnt == PWM_FULL) ? 8'h1 : (dac_pwm_vcnt + 8'd1);
      dac_pwm_vcnt_r   <= dac_pwm_vcnt;
      dac_pwm_va_r     <= (dac_pwm_va + dac_pwm_ba[0]);
      dac_pwm_vb_r     <= (dac_pwm_vb + dac_pwm_bb[0]);
      dac_pwm_vc_r     <= (dac_pwm_vc + dac_pwm_bc[0]);
      dac_pwm_vd_r     <= (dac_pwm_vd + dac_pwm_bd[0]);
      dac_pwm_r[0]     <= (dac_pwm_vcnt_r <= dac_pwm_va_r);
      dac_pwm_r[1]     <= (dac_pwm_vcnt_r <= dac_pwm_vb_r);
      dac_pwm_r[2]     <= (dac_pwm_vcnt_r <= dac_pwm_vc_r);
      dac_pwm_r[3]     <= (dac_pwm_vcnt_r <= dac_pwm_vd_r);
      if (dac_pwm_vcnt == PWM_FULL) begin
         dac_pwm_bcnt <= dac_pwm_bcnt + 4'h1;
         dac_pwm_va   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_a_i[24-1:16] : dac_pwm_va;
         dac_pwm_vb   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_b_i[24-1:16] : dac_pwm_vb;
         dac_pwm_vc   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_c_i[24-1:16] : dac_pwm_vc;
         dac_pwm_vd   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_d_i[24-1:16] : dac_pwm_vd;
         dac_pwm_ba   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_a_i[16-1:0] : {1'b0,dac_pwm_ba[15:1]};
         dac_pwm_bb   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_b_i[16-1:0] : {1'b0,dac_pwm_bb[15:1]};
         dac_pwm_bc   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_c_i[16-1:0] : {1'b0,dac_pwm_bc[15:1]};
         dac_pwm_bd   <= (dac_pwm_bcnt == 4'hF) ? dac_pwm_d_i[16-1:0] : {1'b0,dac_pwm_bd[15:1]};
      end
      dac_pwm <= dac_pwm_r;
   end
end

assign dac_pwm_o      = dac_pwm;
assign dac_pwm_sync_o = (dac_pwm_bcnt == 4'hF) && (dac_pwm_vcnt == (PWM_FULL-1));

endmodule