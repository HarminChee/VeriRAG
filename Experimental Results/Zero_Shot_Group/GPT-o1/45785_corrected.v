`timescale 1ns / 1ps
module adc_mkid_4x_interface(
    input DRDY_I_p,
    input DRDY_I_n,
    input DRDY_Q_p,
    input DRDY_Q_n,
    input ADC_ext_in_p,
    input ADC_ext_in_n,
    input [11:0]DI_p,
    input [11:0]DI_n,
    input [11:0]DQ_p,
    input [11:0]DQ_n,
    input fpga_clk,
    output adc_clk_out,
    output adc_clk90_out,
    output adc_clk180_out,
    output adc_clk270_out,
    output adc_dcm_locked,
    output [11:0]user_data_i0,
    output [11:0]user_data_i1,
    output [11:0]user_data_i2,
    output [11:0]user_data_i3,
    output [11:0]user_data_q0,
    output [11:0]user_data_q1,
    output [11:0]user_data_q2,
    output [11:0]user_data_q3,
    output user_sync
    );
parameter OUTPUT_CLK=0;
  wire drdy_clk;
  wire data_clk;
  wire [11:0]data_i;
  wire [11:0]data_q;
  wire [11:0]data_serdes_i0;
  wire [11:0]data_serdes_i1;
  wire [11:0]data_serdes_i2;
  wire [11:0]data_serdes_i3;
  wire [11:0]data_serdes_q0;
  wire [11:0]data_serdes_q1;
  wire [11:0]data_serdes_q2;
  wire [11:0]data_serdes_q3;
  reg [11:0]recapture_data_i0; 
  reg [11:0]recapture_data_i1; 
  reg [11:0]recapture_data_i2; 
  reg [11:0]recapture_data_i3; 
  reg [11:0]recapture_data_q0; 
  reg [11:0]recapture_data_q1; 
  reg [11:0]recapture_data_q2; 
  reg [11:0]recapture_data_q3; 
  wire [47:0]fifo_in_q;
  wire [47:0]fifo_out_q;
  wire [47:0]fifo_in_i;
  wire [47:0]fifo_out_i;
  wire dcm_clk_in;
  wire dcm_clk;
  wire dcm_clk2x;
  wire dcm_clk90;
  wire dcm_clk180;
  wire dcm_clk270;
  wire clk;
  wire clkdiv;     
  wire clkinv;
  wire clk90div;
  wire clk180div;
  wire clk270div;
  wire fifo_rd_en;
  wire fifo_wr_en;
  wire fifo_rst;
  wire fifo_empty_i;
  wire fifo_empty_q;
  wire fifo_full_i;
  wire fifo_full_q;
assign fifo_rd_en = 1'b1;
assign fifo_wr_en = 1'b1;
assign fifo_rst = 1'b0;
genvar j;
generate
for (j=0; j<12;j=j+1)
begin: IBUFDS_inst_data_i_generate
	IBUFDS #(.IOSTANDARD("LVDS_25"))
	IBUFDS_inst_data_i (
		.O(data_i[j]),
      .I(DI_p[j]),
      .IB(DI_n[j])
	);
end
endgenerate
generate
for (j=0; j<12;j=j+1)
begin: ISERDES_NODELAY_inst_i_generate 
   ISERDESE1 #(
      .DATA_RATE("DDR"),           
      .DATA_WIDTH(4),              
      .DYN_CLKDIV_INV_EN("FALSE"), 
      .DYN_CLK_INV_EN("FALSE"),    
      .INIT_Q1(1'b0),
      .INIT_Q2(1'b0),
      .INIT_Q3(1'b0),
      .INIT_Q4(1'b0),
      .INTERFACE_TYPE("NETWORKING"),   
      .IOBDELAY("NONE"),           
      .NUM_CE(1),                  
      .OFB_USED("FALSE"),          
      .SERDES_MODE("MASTER"),      
      .SRVAL_Q1(1'b0),
      .SRVAL_Q2(1'b0),
      .SRVAL_Q3(1'b0),
      .SRVAL_Q4(1'b0) 
   )
   ISERDES_NODELAY_inst_i (
      .O(),
      .Q1(data_serdes_i3[j]),
      .Q2(data_serdes_i2[j]),
      .Q3(data_serdes_i1[j]),
      .Q4(data_serdes_i0[j]),
      .Q5(),
      .Q6(),
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .BITSLIP(1'b0),
      .CE1(1'b1),
      .CE2(1'b0),
      .CLK(clk),
      .CLKB(!clk),
      .CLKDIV(clkdiv),
      .OCLK(1'b0),
      .DYNCLKDIVSEL(1'b0),
      .DYNCLKSEL(1'b0),
      .D(data_i[j]),
      .DDLY(1'b0),
      .OFB(),
      .RST(1'b0),
      .SHIFTIN1(1'b0),
      .SHIFTIN2(1'b0)
   );
end
endgenerate
generate
for (j=0; j<12;j=j+1)
begin: IBUFDS_inst_data_q_generate 
	IBUFDS #(.IOSTANDARD("LVDS_25"))
	IBUFDS_inst_data_q
	(
	     .O(data_q[j]),
        .I(DQ_p[j]),
        .IB(DQ_n[j])
	);
end
endgenerate
generate
for (j=0; j<12;j=j+1)
begin: ISERDES_NODELAY_inst_q_generate
   ISERDESE1 #(
      .DATA_RATE("DDR"),           
      .DATA_WIDTH(4),              
      .DYN_CLKDIV_INV_EN("FALSE"), 
      .DYN_CLK_INV_EN("FALSE"),    
      .INIT_Q1(1'b0),
      .INIT_Q2(1'b0),
      .INIT_Q3(1'b0),
      .INIT_Q4(1'b0),
      .INTERFACE_TYPE("NETWORKING"),   
      .IOBDELAY("NONE"),           
      .NUM_CE(1),                  
      .OFB_USED("FALSE"),          
      .SERDES_MODE("MASTER"),      
      .SRVAL_Q1(1'b0),
      .SRVAL_Q2(1'b0),
      .SRVAL_Q3(1'b0),
      .SRVAL_Q4(1'b0) 
   )
   ISERDES_NODELAY_inst_q (
      .O(),
      .Q1(data_serdes_q3[j]),
      .Q2(data_serdes_q2[j]),
      .Q3(data_serdes_q1[j]),
      .Q4(data_serdes_q0[j]),
      .Q5(),
      .Q6(),
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .BITSLIP(1'b0),
      .CE1(1'b1),
      .CE2(1'b0),
      .CLK(clk),
      .CLKB(!clk),
      .CLKDIV(clkdiv),
      .OCLK(1'b0),
      .DYNCLKDIVSEL(1'b0),
      .DYNCLKSEL(1'b0),
      .D(data_q[j]),
      .DDLY(1'b0),
      .OFB(),
      .RST(1'b0),
      .SHIFTIN1(1'b0),
      .SHIFTIN2(1'b0)
   );
end
endgenerate
IBUFGDS #(.IOSTANDARD("LVDS_25"))
IBUFDS_inst_user_sync (
    .O(user_sync),           
    .I(ADC_ext_in_p),
    .IB(ADC_ext_in_n)
);
always @(posedge clkdiv)
begin
    recapture_data_q0  <= data_serdes_q0;
    recapture_data_q1  <= data_serdes_q1;
    recapture_data_q2  <= data_serdes_q2;
    recapture_data_q3  <= data_serdes_q3;
    recapture_data_i0  <= data_serdes_i0;
    recapture_data_i1  <= data_serdes_i1;
    recapture_data_i2  <= data_serdes_i2;
    recapture_data_i3  <= data_serdes_i3; 
end
generate
  if (OUTPUT_CLK == 0)
  begin:ADC_FIFO_Q_generate   
    assign fifo_in_q = {recapture_data_q3, recapture_data_q2, recapture_data_q1, recapture_data_q0};
    assign fifo_in_i = {recapture_data_i3, recapture_data_i2, recapture_data_i1, recapture_data_i0};
    assign user_data_q0 = fifo_out_q[11:0];
    assign user_data_q1 = fifo_out_q[23:12];
    assign user_data_q2 = fifo_out_q[35:24];
    assign user_data_q3 = fifo_out_q[47:36];
    assign user_data_i0 = fifo_out_i[11:0];
    assign user_data_i1 = fifo_out_i[23:12];
    assign user_data_i2 = fifo_out_i[35:24];
    assign user_data_i3 = fifo_out_i[47:36];
    FIFO_DUALCLOCK_MACRO  #(
        .ALMOST_EMPTY_OFFSET(9'h080), 
        .ALMOST_FULL_OFFSET(9'h080),  
        .DATA_WIDTH(48),   
        .DEVICE("VIRTEX6"),  
        .FIFO_SIZE ("36Kb"), 
        .FIRST_WORD_FALL_THROUGH ("FALSE") 
    ) ADC_FIFO_Q (
        .ALMOSTEMPTY(), 
        .ALMOSTFULL(),   
        .DO(fifo_out_q),                   
        .EMPTY(fifo_empty_q),             
        .FULL(fifo_full_q),               
        .RDCOUNT(),         
        .RDERR(),             
        .WRCOUNT(),         
        .WRERR(),             
        .DI(fifo_in_q),                   
        .RDCLK(fpga_clk),             
        .RDEN(fifo_rd_en),               
        .RST(fifo_rst),                 
        .WRCLK(clkdiv),             
        .WREN(fifo_wr_en)                
    );
    FIFO_DUALCLOCK_MACRO  #(
        .ALMOST_EMPTY_OFFSET(9'h080), 
        .ALMOST_FULL_OFFSET(9'h080),  
        .DATA_WIDTH(48),   
        .DEVICE("VIRTEX6"),  
        .FIFO_SIZE ("36Kb"), 
        .FIRST_WORD_FALL_THROUGH ("FALSE") 
    ) ADC_FIFO_I (
        .ALMOSTEMPTY(), 
        .ALMOSTFULL(),   
        .DO(fifo_out_i),                   
        .EMPTY(fifo_empty_i),             
        .FULL(fifo_full_i),               
        .RDCOUNT(),         
        .RDERR(),             
        .WRCOUNT(),         
        .WRERR(),             
        .DI(fifo_in_i),                   
        .RDCLK(fpga_clk),             
        .RDEN(fifo_rd_en),               
        .RST(fifo_rst),                 
        .WRCLK(clkdiv),             
        .WREN(fifo_wr_en)                
    );
  end
endgenerate
generate  
 if (OUTPUT_CLK == 1)
  begin
    assign user_data_q0 = recapture_data_q0;
    assign user_data_q1 = recapture_data_q1;
    assign user_data_q2 = recapture_data_q2;
    assign user_data_q3 = recapture_data_q3;
    assign user_data_i0 = recapture_data_i0;
    assign user_data_i1 = recapture_data_i1;
    assign user_data_i2 = recapture_data_i2;
    assign user_data_i3 = recapture_data_i3;
  end 
endgenerate
IBUFGDS #(.IOSTANDARD("LVDS_25"))
IBUFDS_inst_adc_clk(
    .O(drdy_clk),           
    .I(DRDY_I_p),
    .IB(DRDY_I_n)
);
BUFG BUFG_data_clk(
    .I(drdy_clk),
    .O(dcm_clk_in)
);
BUFG BUFG_clk0 
    (.I(dcm_clk), .O(clkdiv));
BUFG BUFG_clk2x
    (.I(dcm_clk2x),.O(clk));
BUFG  BUFG_clk90 
    (.I(dcm_clk90), .O(clk90div));
BUFG BUFG_clk180 
    (.I(dcm_clk180), .O(clk180div));
BUFG BUFG_clk270 
    (.I(dcm_clk270), .O(clk270div));
generate
  if (OUTPUT_CLK == 1)
  begin
    assign adc_clk_out = clkdiv;
    assign adc_clk90_out = clk90div;
    assign adc_clk180_out = clk180div;
    assign adc_clk270_out = clk270div;
  end
endgenerate
MMCM_BASE #(
    .BANDWIDTH("OPTIMIZED"),   
    .CLKFBOUT_MULT_F(8.0),     
    .CLKFBOUT_PHASE(0.0),      
    .CLKIN1_PERIOD(3.906),       
    .CLKOUT0_DIVIDE_F(4.0),    
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(90.0),
    .CLKOUT2_PHASE(180.0),
    .CLKOUT3_PHASE(270.0),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_PHASE(0.0),
    .CLKOUT6_PHASE(0.0),
    .CLKOUT1_DIVIDE(8),
    .CLKOUT2_DIVIDE(8),
    .CLKOUT3_DIVIDE(8),
    .CLKOUT4_DIVIDE(4),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT4_CASCADE("FALSE"), 
    .CLOCK_HOLD("FALSE"),      
    .DIVCLK_DIVIDE(2),         
    .REF_JITTER1(0.0),         
    .STARTUP_WAIT("FALSE")     
)
CLK_DCM (
    .CLKOUT0(dcm_clk),     
    .CLKOUT0B(),   
    .CLKOUT1(dcm_clk90),     
    .CLKOUT1B(),   
    .CLKOUT2(dcm_clk180),     
    .CLKOUT2B(),   
    .CLKOUT3(dcm_clk270),     
    .CLKOUT3B(),   
    .CLKOUT4(dcm_clk2x),     
    .CLKOUT5(),     
    .CLKOUT6(),     
    .CLKFBOUT(),   
    .CLKFBOUTB(), 
    .LOCKED(adc_dcm_locked),       
    .CLKIN1(dcm_clk_in),
    .PWRDWN(1'b0),       
    .RST(1'b0),             
    .CLKFBIN(clkdiv)      
);
endmodule