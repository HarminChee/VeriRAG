`timescale 1ps/1ps
module DemoInterconnect_clk_wiz_0_0_clk_wiz_corrected_clk 
 (
  output        aclk,
  output        uart,
  input         reset,
  output        locked,
  input         clk_in1
 );
wire clk_in1_DemoInterconnect_clk_wiz_0_0;
  IBUF clkin1_ibufg
   (.O (clk_in1_DemoInterconnect_clk_wiz_0_0),
    .I (clk_in1));
  wire        aclk_DemoInterconnect_clk_wiz_0_0;
  wire        uart_DemoInterconnect_clk_wiz_0_0;
  wire        clkfbout_DemoInterconnect_clk_wiz_0_0;
  wire        clkfbout_buf_DemoInterconnect_clk_wiz_0_0;
  wire        locked_int;
  wire        reset_high;
  reg  [7 :0] seq_reg1 = 0;
  reg  [7 :0] seq_reg2 = 0;

  MMCME2_ADV
  #(.BANDWIDTH            ("HIGH"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (63.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (10.500),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (63),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (83.333))
  mmcm_adv_inst
   (
    .CLKFBOUT            (clkfbout_DemoInterconnect_clk_wiz_0_0),
    .CLKFBOUTB           (),
    .CLKOUT0             (aclk_DemoInterconnect_clk_wiz_0_0),
    .CLKOUT0B            (),
    .CLKOUT1             (uart_DemoInterconnect_clk_wiz_0_0),
    .CLKOUT1B            (),
    .CLKOUT2             (),
    .CLKOUT2B            (),
    .CLKOUT3             (),
    .CLKOUT3B            (),
    .CLKOUT4             (),
    .CLKOUT5             (),
    .CLKOUT6             (),
    .CLKFBIN             (clkfbout_buf_DemoInterconnect_clk_wiz_0_0),
    .CLKIN1              (clk_in1_DemoInterconnect_clk_wiz_0_0),
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (),
    .DRDY                (),
    .DWE                 (1'b0),
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (),
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (),
    .CLKFBSTOPPED        (),
    .PWRDWN              (1'b0),
    .RST                 (reset_high));

  assign reset_high = reset; 
  assign locked = locked_int;

  BUFG clkf_buf
   (.O (clkfbout_buf_DemoInterconnect_clk_wiz_0_0),
    .I (clkfbout_DemoInterconnect_clk_wiz_0_0));

  BUFGCE clkout1_buf
   (.O   (aclk),
    .CE  (seq_reg1[7]),
    .I   (aclk_DemoInterconnect_clk_wiz_0_0));

  always @(posedge clk_in1_DemoInterconnect_clk_wiz_0_0 or posedge reset_high) begin
    if(reset_high == 1'b1) begin
	    seq_reg1 <= 8'h00;
    end
    else begin
        seq_reg1 <= {seq_reg1[6:0],locked_int};
    end
  end

  BUFGCE clkout2_buf
   (.O   (uart),
    .CE  (seq_reg2[7]),
    .I   (uart_DemoInterconnect_clk_wiz_0_0));

  always @(posedge clk_in1_DemoInterconnect_clk_wiz_0_0 or posedge reset_high) begin
    if(reset_high == 1'b1) begin
	  seq_reg2 <= 8'h00;
    end
    else begin
        seq_reg2 <= {seq_reg2[6:0],locked_int};
    end
  end
endmodule