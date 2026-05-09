`timescale 1ns/1ps
`timescale 1ns/1ps
module ddr2_phy_dqs_iob #
  (
   parameter DDR_TYPE              = 1,
   parameter HIGH_PERFORMANCE_MODE = "TRUE",
   parameter IODELAY_GRP           = "IODELAY_MIG"
   )
  (
   input        clk0,
   input        clkdiv0,
   input        rst0,
   input        dlyinc_dqs,
   input        dlyce_dqs,
   input        dlyrst_dqs,
   input        dlyinc_gate,
   input        dlyce_gate,
   input        dlyrst_gate,
   input        dqs_oe_n,
   input        dqs_rst_n,
   input        en_dqs,
   inout        ddr_dqs,
   inout        ddr_dqs_n,
   output       dq_ce,
   output       delayed_dqs
   );
  wire                     clk180;
  wire                     dqs_bufio;
  wire                     dqs_ibuf;
  wire                     dqs_idelay;
  wire                     dqs_oe_n_delay;
  (* S = "TRUE" *) wire    dqs_oe_n_r ;
  wire                     dqs_rst_n_delay;
  reg                      dqs_rst_n_r ;
  wire                     dqs_out;
  wire                     en_dqs_sync ;
  localparam    DQS_NET_DELAY = 0.8;
  assign        clk180 = ~clk0;
  assign dqs_rst_n_delay = dqs_rst_n;
  assign dqs_oe_n_delay  = dqs_oe_n;
  (* IODELAY_GROUP = IODELAY_GRP *) IODELAY #
    (
     .DELAY_SRC("I"),
     .IDELAY_TYPE("VARIABLE"),
     .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE),
     .IDELAY_VALUE(0),
     .ODELAY_VALUE(0)
     )
    u_idelay_dqs
      (
       .DATAOUT (dqs_idelay),
       .C       (clkdiv0),
       .CE      (dlyce_dqs),
       .DATAIN  (),
       .IDATAIN (dqs_ibuf),
       .INC     (dlyinc_dqs),
       .ODATAIN (),
       .RST     (dlyrst_dqs),
       .T       ()
       );
  BUFIO u_bufio_dqs
    (
     .I  (dqs_idelay),
     .O  (dqs_bufio)
     );
  assign #(DQS_NET_DELAY) i_delayed_dqs = dqs_bufio;
  assign #(DQS_NET_DELAY) delayed_dqs   = dqs_bufio;
  (* IODELAY_GROUP = IODELAY_GRP *) IODELAY #
    (
     .DELAY_SRC             ("DATAIN"),
     .IDELAY_TYPE           ("VARIABLE"),
     .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
     .IDELAY_VALUE          (0),
     .ODELAY_VALUE          (0)
     )
    u_iodelay_dq_ce
      (
       .DATAOUT (en_dqs_sync),
       .C       (clkdiv0),
       .CE      (dlyce_gate),
       .DATAIN  (en_dqs),
       .IDATAIN (),
       .INC     (dlyinc_gate),
       .ODATAIN (),
       .RST     (dlyrst_gate),
       .T       ()
       );
  (* IOB = "FORCE" *) FDCPE_1 #
    (
     .INIT(1'b0)
    )
    u_iddr_dq_ce
      (
       .Q   (dq_ce),
       .C   (i_delayed_dqs),
       .CE  (1'b1),
       .CLR (1'b0),
       .D   (en_dqs_sync),
       .PRE (en_dqs_sync)
       ) 
         ;
  always @(posedge clk180)
    dqs_rst_n_r <= dqs_rst_n_delay;
  ODDR #
    (
     .SRTYPE("SYNC"),
     .DDR_CLK_EDGE("OPPOSITE_EDGE")
     )
    u_oddr_dqs
      (
       .Q  (dqs_out),
       .C  (clk180),
       .CE (1'b1),
       .D1 (dqs_rst_n_r),      
       .D2 (1'b0),
       .R  (1'b0),
       .S  (1'b0)
       );
  (* IOB = "FORCE" *) FDP u_tri_state_dqs
    (
     .D   (dqs_oe_n_delay),
     .Q   (dqs_oe_n_r),
     .C   (clk180),
     .PRE (rst0)
     ) ;
  generate
    if (DDR_TYPE > 0) begin: gen_dqs_iob_ddr2
      IOBUFDS u_iobuf_dqs
        (
         .O   (dqs_ibuf),
         .IO  (ddr_dqs),
         .IOB (ddr_dqs_n),
         .I   (dqs_out),
         .T   (dqs_oe_n_r)
         );
    end else begin: gen_dqs_iob_ddr1
      IOBUF u_iobuf_dqs
        (
         .O   (dqs_ibuf),
         .IO  (ddr_dqs),
         .I   (dqs_out),
         .T   (dqs_oe_n_r)
         );
    end
  endgenerate
endmodule
