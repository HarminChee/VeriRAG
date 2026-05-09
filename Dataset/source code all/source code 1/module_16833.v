`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v2_0_qdr_rld_byte_group_io #(
    parameter MEMORY_TYPE            = "SRAM",
    parameter DATA_CTL_N             = 1,
    parameter OSERDES_DATA_RATE      = "DDR",
    parameter BITLANES_IN            = 12'b0000_0000_0000,
    parameter BITLANES_OUT           = 12'b0000_0000_0000,
	parameter CK_P_OUT               = 12'b0000_0000_0000,
	parameter CK_VALUE_D1            = 1'b0,
    parameter BUS_WIDTH              = 12,
    parameter ABCD                   = "A",
    parameter BYTE_GROUP_TYPE        = "IN",
	parameter BUFG_FOR_OUTPUTS       = "OFF",
    parameter IODELAY_GRP            = "IODELAY_MIG", 
    parameter IODELAY_HP_MODE        = "ON", 
	parameter REFCLK_FREQ            = 200.0,
	parameter ODELAY_90_SHIFT        = 0
   )
   (
   output wire [BUS_WIDTH-1:0]     O,
   input [11:0]                    I,
   output wire [BUS_WIDTH-1:0]     mem_dq_ts,
   input                           phy_clk,
   output wire [(4*12)-1:0]        iserdes_q, 
   input                           iserdes_clk,
   input                           iserdes_clkb,
   input                           iserdes_clkdiv,
   input                           oserdes_rst,
   input                           iserdes_rst,
   input [(4*BUS_WIDTH)-1:0]       oserdes_d,
   input [1:0]                     oserdes_dqts_in,
   input                           oserdes_clk,
   input                           oserdes_clkdiv,
   input                           idelay_ld,
   input [BUS_WIDTH-1:0]           idelay_ce,
   input [BUS_WIDTH-1:0]           idelay_inc,
   input [5*12-1:0]                idelay_cnt_in,
   output wire [5*12-1:0]          idelay_cnt_out
   );
wire [BUS_WIDTH-1:0] data_in_dly;
wire                 tbyte_out;
wire                 tbyte_out_uni;
wire [1:0]           oserdes_dqts;
wire [BUS_WIDTH-1:0] oserdes_data_out;
wire [BUS_WIDTH-1:0] oserdes_data_delay_out;
wire [BUS_WIDTH-1:0] ddr_ck_out_q;
wire [11:0]          data_in;
wire [11:0]          iserdes_r0;
wire [11:0]          iserdes_f0;
wire [11:0]          iserdes_r1;
wire [11:0]          iserdes_f1;
reg                  iserdes_clk_d;
reg                  iserdes_clkb_d;
  function [11:0] calc_byte_group_type;
    input [11:0] bitlanes_in;
    input [11:0] bitlanes_out;
    integer       x;
    begin
      calc_byte_group_type = 'b0;
      for (x = 0; x < 12; x = x + 1)
        if (bitlanes_in[x] && bitlanes_out[x]) 
          calc_byte_group_type = 1; 
        else 
          calc_byte_group_type = calc_byte_group_type;
    end
  endfunction
  localparam BYTE_GROUP_TYPE_CALC = 
                 (calc_byte_group_type(BITLANES_IN, BITLANES_OUT) == 0 ) ? 
                 "OUT" : BYTE_GROUP_TYPE;
  localparam BYTE_TYPE = (BYTE_GROUP_TYPE == "BIDIR") ? 
                          BYTE_GROUP_TYPE_CALC : BYTE_GROUP_TYPE;
localparam    ISERDES_Q_DATA_RATE          = "DDR"; 
localparam    ISERDES_Q_DATA_WIDTH         = 4;
localparam    ISERDES_Q_DYN_CLKDIV_INV_EN  = "FALSE";
localparam    ISERDES_Q_DYN_CLK_INV_EN     = "FALSE";
localparam    ISERDES_Q_INIT_Q1            = 1'b0;
localparam    ISERDES_Q_INIT_Q2            = 1'b0;
localparam    ISERDES_Q_INIT_Q3            = 1'b0;
localparam    ISERDES_Q_INIT_Q4            = 1'b0;
localparam    ISERDES_Q_INTERFACE_TYPE     = "MEMORY_DDR3";
localparam    ISERDES_NUM_CE               = 2;
localparam    ISERDES_Q_IOBDELAY           = "IFD";
localparam    ISERDES_Q_OFB_USED           = "FALSE";
localparam    ISERDES_Q_SERDES_MODE        = "MASTER";
localparam    ISERDES_Q_SRVAL_Q1           = 1'b0;
localparam    ISERDES_Q_SRVAL_Q2           = 1'b0;
localparam    ISERDES_Q_SRVAL_Q3           = 1'b0;
localparam    ISERDES_Q_SRVAL_Q4           = 1'b0;
always @(*) begin 
   iserdes_clk_d  = iserdes_clk;
   iserdes_clkb_d = iserdes_clkb;
end
generate
genvar rd_i;
for (rd_i=0; rd_i <12; rd_i= rd_i+1) begin : gen_iserdes_q
   assign iserdes_q[4*rd_i]    = iserdes_r0[rd_i];    
   assign iserdes_q[4*rd_i+1]  = iserdes_f0[rd_i];   
   assign iserdes_q[4*rd_i+2]  = iserdes_r1[rd_i];       
   assign iserdes_q[4*rd_i+3]  = iserdes_f1[rd_i];     
end
endgenerate
generate
genvar j;
for ( j = 0; j != 12; j=j+1) 
  begin  : i_serdesq_
  if (BITLANES_IN[j]) begin : gen_iserdes
     ISERDESE2 #(
      .DATA_RATE          ( ISERDES_Q_DATA_RATE),
      .DATA_WIDTH         ( ISERDES_Q_DATA_WIDTH),
      .DYN_CLKDIV_INV_EN  ( ISERDES_Q_DYN_CLKDIV_INV_EN),
      .DYN_CLK_INV_EN     ( ISERDES_Q_DYN_CLK_INV_EN),
      .INIT_Q1            ( ISERDES_Q_INIT_Q1),
      .INIT_Q2            ( ISERDES_Q_INIT_Q2),
      .INIT_Q3            ( ISERDES_Q_INIT_Q3),
      .INIT_Q4            ( ISERDES_Q_INIT_Q4),
      .INTERFACE_TYPE     ( ISERDES_Q_INTERFACE_TYPE),
      .NUM_CE             ( ISERDES_NUM_CE),
      .IOBDELAY           ( ISERDES_Q_IOBDELAY),
      .OFB_USED           ( ISERDES_Q_OFB_USED),
      .SERDES_MODE        ( ISERDES_Q_SERDES_MODE),
      .SRVAL_Q1           ( ISERDES_Q_SRVAL_Q1),
      .SRVAL_Q2           ( ISERDES_Q_SRVAL_Q2),
      .SRVAL_Q3           ( ISERDES_Q_SRVAL_Q3),
      .SRVAL_Q4           ( ISERDES_Q_SRVAL_Q4)
      )
      iserdesq
      (
      .O                  (),
      .Q1                 (iserdes_f1[j]),
      .Q2                 (iserdes_r1[j]),
      .Q3                 (iserdes_f0[j]),
      .Q4                 (iserdes_r0[j]),
      .Q5                 (),
      .Q6                 (),
      .Q7                 (),
      .Q8                 (),
      .SHIFTOUT1          (),
      .SHIFTOUT2          (),
      .BITSLIP            (1'b0),
      .CE1                (1'b1),
      .CE2                (1'b1),
      .CLK                (iserdes_clk_d),
      .CLKB               (iserdes_clkb_d), 
      .CLKDIVP            (iserdes_clkdiv),
      .CLKDIV             (),
      .DDLY               (data_in_dly[j]),
      .D                  (),
      .DYNCLKDIVSEL       (1'b0),
      .DYNCLKSEL          (1'b0),
      .OCLK               (),
      .OCLKB              (),
      .OFB                (),
      .RST                (1'b0),
      .SHIFTIN1           (1'b0),
      .SHIFTIN2           (1'b0)
      );
  localparam IDELAYE2_CINVCTRL_SEL          = "FALSE";
  localparam IDELAYE2_DELAY_SRC             = "IDATAIN";
  localparam IDELAYE2_HIGH_PERFORMANCE_MODE = (IODELAY_HP_MODE=="ON") ? "TRUE": 
                                                                        "FALSE";
  localparam IDELAYE2_IDELAY_TYPE           = "VAR_LOAD";
  localparam IDELAYE2_IDELAY_VALUE          = 0; 
  localparam IDELAYE2_PIPE_SEL              = "FALSE";
  localparam IDELAYE2_ODELAY_TYPE           = "FIXED";
  localparam IDELAYE2_REFCLK_FREQUENCY      = REFCLK_FREQ;
  localparam IDELAYE2_SIGNAL_PATTERN        = "DATA";
  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYE2 #(
      .CINVCTRL_SEL             ( IDELAYE2_CINVCTRL_SEL),
      .DELAY_SRC                ( IDELAYE2_DELAY_SRC),
      .HIGH_PERFORMANCE_MODE    ( IDELAYE2_HIGH_PERFORMANCE_MODE),
      .IDELAY_TYPE              ( IDELAYE2_IDELAY_TYPE),
      .IDELAY_VALUE             ( IDELAYE2_IDELAY_VALUE),
      .PIPE_SEL                 ( IDELAYE2_PIPE_SEL),
      .REFCLK_FREQUENCY         ( IDELAYE2_REFCLK_FREQUENCY ),
      .SIGNAL_PATTERN           ( IDELAYE2_SIGNAL_PATTERN)
      )
      idelaye2
      (
      .CNTVALUEOUT              (idelay_cnt_out[j*5+4:j*5]),
      .DATAOUT                  (data_in_dly[j]),
      .C                        (phy_clk), 
      .CE                       (idelay_ce[j]),
      .CINVCTRL                 (),
      .CNTVALUEIN               (idelay_cnt_in[j*5+4:j*5]), 
      .DATAIN                   (1'b0),
      .IDATAIN                  (data_in[j]),
      .INC                      (idelay_inc[j]),
      .LD                       (idelay_ld),
      .LDPIPEEN                 (1'b0),
      .REGRST                   (iserdes_rst) 
  );
    assign data_in[j] = I[j];
  end      
end      
endgenerate			
localparam OSERDES_D_DATA_RATE_OQ   = OSERDES_DATA_RATE;
localparam OSERDES_D_DATA_RATE_TQ   = OSERDES_D_DATA_RATE_OQ;
localparam OSERDES_D_DATA_WIDTH     = 4;
localparam OSERDES_D_DDR3_DATA      = 0;
localparam OSERDES_D_INIT_OQ        = 1'b1;
localparam OSERDES_D_INIT_TQ        = 1'b1;
localparam OSERDES_D_INTERFACE_TYPE = "DEFAULT";
localparam OSERDES_D_ODELAY_USED    = 0;
localparam OSERDES_D_SERDES_MODE    = "MASTER";
localparam OSERDES_D_SRVAL_OQ       = 1'b1;
localparam OSERDES_D_SRVAL_TQ       = 1'b1;
localparam OSERDES_D_TRISTATE_WIDTH = (OSERDES_D_DATA_RATE_OQ == "DDR") ? 4 : 1;
localparam TRI_STATE_LOC            = 10;
localparam TRI_STATE_LOC_DOWN       = 5; 
localparam BITLANES_TRI_STATE       = 12'b0100_0000_0000;
localparam EMPTY_TRI_STATE          = (BITLANES_OUT[TRI_STATE_LOC] &&
                                       BITLANES_TRI_STATE[TRI_STATE_LOC] &&
									   MEMORY_TYPE != "RLD3") ?  
                                       "FALSE" : "TRUE";
localparam SHIFT_TRI_STATE_MAP_UP   = (EMPTY_TRI_STATE == "FALSE" && 
                                       (ABCD == "A" || ABCD == "B")) ?
                                       "TRUE" : "FALSE";
localparam SHIFT_TRI_STATE_MAP_DOWN = (EMPTY_TRI_STATE == "FALSE" && 
                                       (ABCD == "C" || ABCD == "D")) ?
                                       "TRUE" : "FALSE";
generate
  if ( BYTE_TYPE == "BIDIR" && DATA_CTL_N == 1 ) begin : gen_tri_state
    if (MEMORY_TYPE == "RLD3") begin : gen_rld3_tri_state
	  assign oserdes_dqts = oserdes_dqts_in;
	end else begin: gen_rld2_tri_state
      assign oserdes_dqts = (SHIFT_TRI_STATE_MAP_UP == "TRUE") ? 
                             oserdes_d[((TRI_STATE_LOC+1)*4)+:4] :
                             ((SHIFT_TRI_STATE_MAP_DOWN == "TRUE") ?
                             oserdes_d[((TRI_STATE_LOC_DOWN)*4)+:4] :
                             oserdes_d[((TRI_STATE_LOC)*4)+:4]); 
    end                    
  end else begin: gen_tri_state_low
    assign oserdes_dqts = 2'b0; 
  end
  if ( BYTE_TYPE == "BIDIR" && 
       DATA_CTL_N == 1 &&
       EMPTY_TRI_STATE == "TRUE" ) begin  : slave_ts
    OSERDESE2 #(
          .DATA_RATE_OQ         (OSERDES_D_DATA_RATE_OQ),
          .DATA_RATE_TQ         (OSERDES_D_DATA_RATE_TQ),
          .DATA_WIDTH           (OSERDES_D_DATA_WIDTH),
          .INIT_OQ              (OSERDES_D_INIT_OQ),
          .INIT_TQ              (OSERDES_D_INIT_TQ),
          .SERDES_MODE          (OSERDES_D_SERDES_MODE),
          .SRVAL_OQ             (OSERDES_D_SRVAL_OQ),
          .SRVAL_TQ             (OSERDES_D_SRVAL_TQ), 
          .TBYTE_CTL            ("TRUE"),
          .TBYTE_SRC            ("TRUE"),
          .TRISTATE_WIDTH       (OSERDES_D_TRISTATE_WIDTH) 
         )
         oserdes_slave_ts
         (
           .OFB               (),                        
           .OQ                (),     
           .SHIFTOUT1         (),	
           .SHIFTOUT2         (),	
           .TBYTEOUT          (tbyte_out),                        
           .TFB               (),                         
           .TQ                (),                        
           .CLK               (oserdes_clk),             
           .CLKDIV            (oserdes_clkdiv),          
           .D1                (),    
           .D2                (),    
           .D3                (),    
           .D4                (),    
           .D5                (1'b0),                        
           .D6                (1'b0),                        
           .D7                (1'b0),                    
           .D8                (1'b0),                    
          .OCE                (1'b1),                    
          .RST                (oserdes_rst),             
          .SHIFTIN1           (1'b0),     
          .SHIFTIN2           (1'b0),     
          .T1                 (oserdes_dqts[0]),         
          .T2                 (oserdes_dqts[0]),         
          .T3                 (oserdes_dqts[1]),         
          .T4                 (oserdes_dqts[1]),            
          .TBYTEIN            (tbyte_out),                    
          .TCE                (1'b1)                     
         );
  end
genvar i;
  for (i = 0; i != BUS_WIDTH; i=i+1) begin:o_serdesd_
    assign O[i] = (BUFG_FOR_OUTPUTS == "ON") ? oserdes_data_delay_out[i] : 
	                                           oserdes_data_out[i];
    if (!BITLANES_IN[i] && BITLANES_OUT[i] ) begin : gen_oserdes_uni
      if (BYTE_GROUP_TYPE == "BIDIR" && EMPTY_TRI_STATE == "FALSE" && 
          BITLANES_TRI_STATE[i]) begin : gen_oserdes_uni_tri
        OSERDESE2 #(
            .DATA_RATE_OQ         (OSERDES_D_DATA_RATE_OQ),
            .DATA_RATE_TQ         (OSERDES_D_DATA_RATE_TQ),
            .DATA_WIDTH           (OSERDES_D_DATA_WIDTH),
            .INIT_OQ              (OSERDES_D_INIT_OQ),
            .INIT_TQ              (OSERDES_D_INIT_TQ),
            .SERDES_MODE          (OSERDES_D_SERDES_MODE),
            .SRVAL_OQ             (OSERDES_D_SRVAL_OQ),
            .SRVAL_TQ             (OSERDES_D_SRVAL_TQ), 
            .TBYTE_CTL            ("FALSE"),
            .TBYTE_SRC            ("TRUE"),
            .TRISTATE_WIDTH       (OSERDES_D_TRISTATE_WIDTH)
           )
           oserdes_d_i 
           (
             .OFB               (),                        
             .OQ                (oserdes_data_out[i]),
             .SHIFTOUT1         (),	
             .SHIFTOUT2         (),	
             .TBYTEOUT          (tbyte_out_uni),
             .TFB               (),
             .TQ                (),
             .CLK               (oserdes_clk),
             .CLKDIV            (oserdes_clkdiv),
             .D1                (oserdes_d[4 * i + 0]),    
             .D2                (oserdes_d[4 * i + 1]),    
             .D3                (oserdes_d[4 * i + 2]),    
             .D4                (oserdes_d[4 * i + 3]),
             .D5                (1'b0),
             .D6                (1'b0),    
             .D7                (1'b0),
             .D8                (1'b0),
            .OCE                (1'b1),
            .RST                (oserdes_rst),
            .SHIFTIN1           (1'b0),     
            .SHIFTIN2           (1'b0),     
            .T1                 (oserdes_dqts[0]),
            .T2                 (oserdes_dqts[0]),
            .T3                 (oserdes_dqts[1]),
            .T4                 (oserdes_dqts[1]),
            .TBYTEIN            (),
            .TCE                (1'b1)                     
           );
        assign tbyte_out = tbyte_out_uni;
      end else begin : gen_oserdes_uni_notri
        OSERDESE2 #(
            .DATA_RATE_OQ         (OSERDES_D_DATA_RATE_OQ),
            .DATA_RATE_TQ         (OSERDES_D_DATA_RATE_TQ),
            .DATA_WIDTH           (OSERDES_D_DATA_WIDTH),
            .INIT_OQ              (OSERDES_D_INIT_OQ),
            .INIT_TQ              (OSERDES_D_INIT_TQ),
            .SERDES_MODE          (OSERDES_D_SERDES_MODE),
            .SRVAL_OQ             (OSERDES_D_SRVAL_OQ),
            .SRVAL_TQ             (OSERDES_D_SRVAL_TQ), 
            .TBYTE_CTL            ("FALSE"),
            .TBYTE_SRC            ("FALSE"),
            .TRISTATE_WIDTH       (OSERDES_D_TRISTATE_WIDTH)
           )
           oserdes_d_i 
           (
             .OFB               (),                        
             .OQ                (oserdes_data_out[i]),
             .SHIFTOUT1         (),	
             .SHIFTOUT2         (),	
             .TBYTEOUT          (),
             .TFB               (),
             .TQ                (),
             .CLK               (oserdes_clk),
             .CLKDIV            (oserdes_clkdiv),
             .D1                (oserdes_d[4 * i + 0]),
             .D2                (oserdes_d[4 * i + 1]),
             .D3                (oserdes_d[4 * i + 2]),
             .D4                (oserdes_d[4 * i + 3]),
             .D5                (1'b0),
             .D6                (1'b0),    
             .D7                (1'b0),
             .D8                (1'b0),
            .OCE                (1'b1),
            .RST                (oserdes_rst),
            .SHIFTIN1           (1'b0),     
            .SHIFTIN2           (1'b0),     
            .T1                 (1'b0),
            .T2                 (1'b0),
            .T3                 (1'b0),
            .T4                 (1'b0),
            .TBYTEIN            (),
            .TCE                (1'b1)                     
           );
         end
    end else if (BITLANES_IN[i] && BITLANES_OUT[i]) begin : gen_oserdes_bidir
      OSERDESE2 #(
          .DATA_RATE_OQ         (OSERDES_D_DATA_RATE_OQ),
          .DATA_RATE_TQ         (OSERDES_D_DATA_RATE_TQ),
          .DATA_WIDTH           (OSERDES_D_DATA_WIDTH),
          .INIT_OQ              (OSERDES_D_INIT_OQ),
          .INIT_TQ              (OSERDES_D_INIT_TQ),
          .SERDES_MODE          (OSERDES_D_SERDES_MODE),
          .SRVAL_OQ             (OSERDES_D_SRVAL_OQ),
          .SRVAL_TQ             (OSERDES_D_SRVAL_TQ),
          .TBYTE_CTL            ("TRUE"),
          .TBYTE_SRC            ("FALSE"),
          .TRISTATE_WIDTH       (OSERDES_D_TRISTATE_WIDTH) 
         )
         oserdes_d_i
         (
           .OFB               (),
           .OQ                (oserdes_data_out[i]),
           .SHIFTOUT1         (),	
           .SHIFTOUT2         (),	
           .TBYTEOUT          (),
           .TFB               (),                         
           .TQ                (mem_dq_ts[i]), 
           .CLK               (oserdes_clk),             
           .CLKDIV            (oserdes_clkdiv),          
           .D1                (oserdes_d[4 * i + 0]),
           .D2                (oserdes_d[4 * i + 1]),
           .D3                (oserdes_d[4 * i + 2]),
           .D4                (oserdes_d[4 * i + 3]),
           .D5                (1'b0),
           .D6                (1'b0),
           .D7                (1'b0),
           .D8                (1'b0),
          .OCE                (1'b1),
          .RST                (oserdes_rst),
          .SHIFTIN1           (1'b0),     
          .SHIFTIN2           (1'b0),     
          .T1                 (oserdes_dqts[0]),
          .T2                 (oserdes_dqts[0]),
          .T3                 (oserdes_dqts[1]),
          .T4                 (oserdes_dqts[1]),
          .TBYTEIN            (tbyte_out),               
          .TCE                (1'b1)                     
         );
    end
	if (BUFG_FOR_OUTPUTS == "ON") begin : gen_odelay
	  (* IODELAY_GROUP = IODELAY_GRP *) ODELAYE2 #(
        .CINVCTRL_SEL             ( "FALSE"),
        .DELAY_SRC                ( "ODATAIN"), 
        .HIGH_PERFORMANCE_MODE    ((IODELAY_HP_MODE=="ON") ? "TRUE": "FALSE"),
        .ODELAY_TYPE              ( "FIXED"),
        .ODELAY_VALUE             ( (DATA_CTL_N == 1) ? 0 : ODELAY_90_SHIFT ),
        .PIPE_SEL                 ( "FALSE"),
        .REFCLK_FREQUENCY         ( REFCLK_FREQ ),
        .SIGNAL_PATTERN           ( "DATA")
      )
      u_odelaye2_i
      (
        .CNTVALUEOUT              (),
        .DATAOUT                  (oserdes_data_delay_out[i]), 
        .C                        (oserdes_clkdiv),
        .CE                       (1'b0),
        .CINVCTRL                 (1'b0),
        .CLKIN                    (), 
	    .CNTVALUEIN               (5'b0),
        .INC                      (1'b0),
        .LD                       (1'b0),
        .LDPIPEEN                 (1'b0),
	    .ODATAIN                  (oserdes_data_out[i]),
        .REGRST                   (oserdes_rst) 
      );
	end
    if (DATA_CTL_N == 0 && CK_P_OUT[i])  begin : gen_ck
	  ODDR #
	  (
	   .DDR_CLK_EDGE ("SAME_EDGE")
	  )
	  ddr_ck (
        .C    (oserdes_clk),
        .R    (oserdes_rst),
        .S    (),
        .D1   (CK_VALUE_D1),
        .D2   (~CK_VALUE_D1),
        .CE   (1'b1),
        .Q    (ddr_ck_out_q[i])
      );
      OBUFDS ddr_ck_obuf  (.I(ddr_ck_out_q[i]),
                           .O(oserdes_data_out[i]), .OB(oserdes_data_out[i-1]));
    end
  end 
endgenerate
endmodule			
