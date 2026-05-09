`timescale 1ns/1ps
`timescale 1ns/1ps
module eclock (
   test_i,
   CCLK_P, CCLK_N, lclk_s, lclk_out, lclk_p,
   clkin, reset, ecfg_cclk_en, ecfg_cclk_div, ecfg_cclk_pllcfg
   );
   parameter  CLKIN_PERIOD = 10.000; 
   parameter  CLKIN_DIVIDE = 1;
   parameter  VCO_MULT = 12;         
   parameter  CCLK_DIVIDE = 2;       
   parameter  LCLK_DIVIDE = 4;       
   parameter  FEATURE_CCLK_DIV = 1'b1;
   parameter  IOSTD_ELINK = "LVDS_25";
   input        clkin;
   input        reset;
   input        ecfg_cclk_en;           
   input [3:0]  ecfg_cclk_div;          
   input [3:0]  ecfg_cclk_pllcfg;       
   input test_i;
   output       CCLK_P, CCLK_N;
   output       lclk_s;
   output       lclk_out;
   output       lclk_p;
   wire         cclk_src;
   wire         cclk_base;
   wire         cclk_p_src;
   wire         cclk_p;
   wire         cclk_pre;
   wire         cclk;
   wire         lclk_s_src;
   wire         lclk_out_src;
   wire         lclk_p_src;
   wire         clkfb;
   PLLE2_BASE
     #(
       .BANDWIDTH("OPTIMIZED"),     
       .CLKFBOUT_MULT(VCO_MULT),    
       .CLKFBOUT_PHASE(0.0),        
       .CLKIN1_PERIOD(CLKIN_PERIOD),
       .CLKOUT0_DIVIDE(CCLK_DIVIDE),
       .CLKOUT1_DIVIDE(LCLK_DIVIDE),
       .CLKOUT2_DIVIDE(LCLK_DIVIDE),
       .CLKOUT3_DIVIDE(LCLK_DIVIDE * 4),
       .CLKOUT4_DIVIDE(CCLK_DIVIDE * 4),
       .CLKOUT5_DIVIDE(128),
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(90.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .DIVCLK_DIVIDE(CLKIN_DIVIDE),
       .REF_JITTER1(0.01),          
       .STARTUP_WAIT("FALSE")       
       ) eclk_pll
       (
        .CLKOUT0(cclk_src),     
        .CLKOUT1(lclk_s_src),   
        .CLKOUT2(lclk_out_src), 
        .CLKOUT3(lclk_p_src),   
        .CLKOUT4(cclk_p_src),   
        .CLKOUT5(),             
        .CLKFBOUT(clkfb),       
        .LOCKED(),              
        .CLKIN1(clkin),         
        .PWRDWN(1'b0),          
        .RST(reset),            
        .CLKFBIN(clkfb)         
        );
   BUFG cclk_buf
     (.O   (cclk_base),
      .I   (cclk_src));
   BUFG cclk_p_buf
     (.O   (cclk_p),
      .I   (cclk_p_src));
   BUFG lclk_s_buf
     (.O   (lclk_s),
      .I   (lclk_s_src));
   BUFG lclk_out_buf
     (.O   (lclk_out),
      .I   (lclk_out_src));
   BUFG lclk_p_buf
     (.O   (lclk_p),
      .I   (lclk_p_src));
generate
   if( FEATURE_CCLK_DIV ) begin : gen_cclk_div
   wire      rxi_cclk_out;
   reg [7:0] cclk_pattern;
   reg [3:0] clk_div_sync;
   reg       enb_sync;
   always @ (posedge cclk_p) begin  
      clk_div_sync <= ecfg_cclk_div;
      enb_sync     <= ecfg_cclk_en;
      if(enb_sync)
        case(clk_div_sync)
          4'h0:    cclk_pattern <= 8'd0;         
          4'h7:    cclk_pattern <= 8'b10101010;  
          4'h6:    cclk_pattern <= 8'b11001100;  
          4'h5:    cclk_pattern <= 8'b11110000;  
          default: cclk_pattern <= {8{~cclk_pattern[0]}}; 
        endcase
      else
        cclk_pattern <= 8'b00000000;
   end 
   OSERDESE2 
     #(
       .DATA_RATE_OQ("DDR"),  
       .DATA_RATE_TQ("SDR"),  
       .DATA_WIDTH(8),        
       .INIT_OQ(1'b0),        
       .INIT_TQ(1'b0),        
       .SERDES_MODE("MASTER"), 
       .SRVAL_OQ(1'b0),       
       .SRVAL_TQ(1'b0),       
       .TBYTE_CTL("FALSE"),   
       .TBYTE_SRC("FALSE"),   
       .TRISTATE_WIDTH(1)     
       ) OSERDESE2_inst 
       (
        .OFB(),             
        .OQ(cclk_pre),          
        .SHIFTOUT1(),       
        .SHIFTOUT2(),
        .TBYTEOUT(),        
        .TFB(),             
        .TQ(),              
        .CLK(cclk_base),    
        .CLKDIV(cclk_p),    
        .D1(cclk_pattern[0]), 
        .D2(cclk_pattern[1]),
        .D3(cclk_pattern[2]),
        .D4(cclk_pattern[3]),
        .D5(cclk_pattern[4]),
        .D6(cclk_pattern[5]),
        .D7(cclk_pattern[6]),
        .D8(cclk_pattern[7]),
        .OCE(1'b1),         
        .RST(reset),        
        .SHIFTIN1(1'b0),    
        .SHIFTIN2(1'b0),
        .T1(1'b0),          
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),     
        .TCE(1'b0)          
        );
   end else begin : gen_fixed_cclk 
   reg       enb_sync;
   always @ (posedge cclk_p)
      enb_sync     <= ecfg_cclk_en;
   assign cclk_pre = cclk_base & enb_sync;
   end
endgenerate

assign cclk = test_i ? clkin : cclk_pre;

   OBUFDS
     #(.IOSTANDARD (IOSTD_ELINK)) 
   obufds_cclk_inst
     (.O   (CCLK_P),
	  .OB  (CCLK_N),
	  .I   (cclk));
endmodule