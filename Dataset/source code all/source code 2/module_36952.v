module red_pitaya_asg (
  output     [ 14-1: 0] dac_a_o   ,  
  output     [ 14-1: 0] dac_b_o   ,  
  input                 dac_clk_i ,  
  input                 dac_rstn_i,  
  input                 trig_a_i  ,  
  input                 trig_b_i  ,  
  output     [  2-1: 0] trig_out_o,  
  input                 trig_scope_i    ,  
  output     [ 14-1: 0] asg1phase_o,
  input      [ 32-1: 0] sys_addr  ,  
  input      [ 32-1: 0] sys_wdata ,  
  input      [  4-1: 0] sys_sel   ,  
  input                 sys_wen   ,  
  input                 sys_ren   ,  
  output reg [ 32-1: 0] sys_rdata ,  
  output reg            sys_err   ,  
  output reg            sys_ack      
);
localparam RSZ = 14 ;  
reg   [RSZ+15: 0] set_a_size   , set_b_size   ;
reg   [RSZ+15: 0] set_a_step   , set_b_step   ;
reg   [RSZ+15: 0] set_a_ofs    , set_b_ofs    ;
reg               set_a_rst    , set_b_rst    ;
reg               set_a_once   , set_b_once   ;
reg               set_a_wrap   , set_b_wrap   ;
reg   [  14-1: 0] set_a_amp    , set_b_amp    ;
reg   [  14-1: 0] set_a_dc     , set_b_dc     ;
reg               set_a_zero   , set_b_zero   ;
reg   [  32-1: 0] set_a_ncyc   , set_b_ncyc   ;
reg   [  16-1: 0] set_a_rnum   , set_b_rnum   ;
reg   [  32-1: 0] set_a_rdly   , set_b_rdly   ;
reg               set_a_rgate  , set_b_rgate  ;
reg               buf_a_we     , buf_b_we     ;
reg   [ RSZ-1: 0] buf_a_addr   , buf_b_addr   ;
wire  [  14-1: 0] buf_a_rdata  , buf_b_rdata  ;
wire  [ RSZ-1: 0] buf_a_rpnt   , buf_b_rpnt   ;
reg   [  32-1: 0] buf_a_rpnt_rd, buf_b_rpnt_rd;
reg               trig_a_sw    , trig_b_sw    ;
reg   [   3-1: 0] trig_a_src   , trig_b_src   ;
wire              trig_a_done  , trig_b_done  ;
reg               rand_a_on    , rand_b_on    ;
wire  [ RSZ-1: 0] rand_pnt;
reg [64-1:0] at_counts_a;
reg          at_reset_a;
reg          at_invert_a;
reg          at_autorearm_a;
wire         at_trig_a;
red_pitaya_adv_trigger adv_trig_a (
    .dac_clk_i (dac_clk_i) ,
    .reset_i   (at_reset_a),  
    .trig_i    (trig_a_i)  ,
    .trig_o    (at_trig_a) ,    
    .invert_i  (at_invert_a),
    .rearm_i   (at_autorearm_a),
    .hysteresis_i (at_counts_a)
    );
reg [64-1:0] at_counts_b;
reg          at_reset_b;
reg          at_invert_b;
reg          at_autorearm_b;
wire         at_trig_b;
red_pitaya_adv_trigger adv_trig_b (
    .dac_clk_i (dac_clk_i) ,
    .reset_i   (at_reset_b),  
    .trig_i    (trig_b_i)  ,
    .trig_o    (at_trig_b)   ,    
    .invert_i  (at_invert_b),
    .rearm_i   (at_autorearm_b),
    .hysteresis_i (at_counts_b)
    );
red_pitaya_asg_ch  #(.RSZ (RSZ)) ch [1:0] (
  .dac_o           ({dac_b_o          , dac_a_o          }),  
  .dac_clk_i       ({dac_clk_i        , dac_clk_i        }),  
  .dac_rstn_i      ({dac_rstn_i       , dac_rstn_i       }),  
  .trig_sw_i       ({trig_b_sw        , trig_a_sw        }),  
  .trig_ext_i      ({at_trig_a        , at_trig_b        }),  
  .trig_src_i      ({trig_b_src       , trig_a_src       }),  
  .trig_done_o     ({trig_b_done      , trig_a_done      }),  
  .buf_we_i        ({buf_b_we         , buf_a_we         }),  
  .buf_addr_i      ({buf_b_addr       , buf_a_addr       }),  
  .buf_wdata_i     ({sys_wdata[14-1:0], sys_wdata[14-1:0]}),  
  .buf_rdata_o     ({buf_b_rdata      , buf_a_rdata      }),  
  .buf_rpnt_o      ({buf_b_rpnt       , buf_a_rpnt       }),  
  .set_size_i      ({set_b_size       , set_a_size       }),  
  .set_step_i      ({set_b_step       , set_a_step       }),  
  .set_ofs_i       ({set_b_ofs        , set_a_ofs        }),  
  .set_rst_i       ({set_b_rst        , set_a_rst        }),  
  .set_once_i      ({set_b_once       , set_a_once       }),  
  .set_wrap_i      ({set_b_wrap       , set_a_wrap       }),  
  .set_amp_i       ({set_b_amp        , set_a_amp        }),  
  .set_dc_i        ({set_b_dc         , set_a_dc         }),  
  .set_zero_i      ({set_b_zero       , set_a_zero       }),  
  .set_ncyc_i      ({set_b_ncyc       , set_a_ncyc       }),  
  .set_rnum_i      ({set_b_rnum       , set_a_rnum       }),  
  .set_rdly_i      ({set_b_rdly       , set_a_rdly       }),  
  .set_rgate_i     ({set_b_rgate      , set_a_rgate      }),  
  .rand_on_i       ({rand_b_on        , rand_a_on        }),
  .rand_pnt_i      ({rand_pnt         , rand_pnt         })
);
reg  [RSZ-1: 0] trigbuf_rp_a       ;
reg  [RSZ-1: 0] trigbuf_rp_b       ;
always @(posedge dac_clk_i) begin
   if (dac_rstn_i == 1'b0) begin
      trigbuf_rp_a <= {RSZ{1'b1}} ;
      trigbuf_rp_b <= {RSZ{1'b1}} ;
      end
   else if (trig_scope_i) begin
      trigbuf_rp_a <= buf_a_rpnt;
      trigbuf_rp_b <= buf_b_rpnt;
      end
end
always @(posedge dac_clk_i)
begin
   buf_a_we   <= sys_wen && (sys_addr[19:RSZ+2] == 'h1);
   buf_b_we   <= sys_wen && (sys_addr[19:RSZ+2] == 'h2);
   buf_a_addr <= sys_addr[RSZ+1:2] ;  
   buf_b_addr <= sys_addr[RSZ+1:2] ;  
end
assign trig_out_o = {trig_b_done,trig_a_done};
reg  [3-1: 0] ren_dly ;
reg           ack_dly ;
always @(posedge dac_clk_i)
if (dac_rstn_i == 1'b0) begin
   trig_a_sw   <=  1'b0    ;
   trig_a_src  <=  3'h0    ;
   set_a_amp   <= 14'h2000 ;
   set_a_dc    <= 14'h0    ;
   set_a_zero  <=  1'b0    ;
   set_a_rst   <=  1'b0    ;
   set_a_once  <=  1'b0    ;
   set_a_wrap  <=  1'b0    ;
   set_a_size  <= {RSZ+16{1'b1}} ;
   set_a_ofs   <= {RSZ+16{1'b0}} ;
   set_a_step  <={{RSZ+15{1'b0}},1'b0} ;
   set_a_ncyc  <= 32'h0    ;
   set_a_rnum  <= 16'h0    ;
   set_a_rdly  <= 32'h0    ;
   set_a_rgate <=  1'b0    ;
   trig_b_sw   <=  1'b0    ;
   trig_b_src  <=  3'h0    ;
   set_b_amp   <= 14'h2000 ;
   set_b_dc    <= 14'h0    ;
   set_b_zero  <=  1'b0    ;
   set_b_rst   <=  1'b0    ;
   set_b_once  <=  1'b0    ;
   set_b_wrap  <=  1'b0    ;
   set_b_size  <= {RSZ+16{1'b1}} ;
   set_b_ofs   <= {RSZ+16{1'b0}} ;
   set_b_step  <={{RSZ+15{1'b0}},1'b0} ;
   set_b_ncyc  <= 32'h0    ;
   set_b_rnum  <= 16'h0    ;
   set_b_rdly  <= 32'h0    ;
   set_b_rgate <=  1'b0    ;
   ren_dly     <=  3'h0    ;
   ack_dly     <=  1'b0    ;
   at_counts_a <= {64{1'b0}};
   at_reset_a <= 1'b1; 
   at_invert_a <= 1'b0;
   at_autorearm_a <= 1'b0;
   at_counts_b <= {64{1'b0}};
   at_reset_b <= 1'b1; 
   at_invert_b <= 1'b0;
   at_autorearm_b <= 1'b0;
   rand_a_on <= 1'b0;
   rand_b_on <= 1'b0;
end else begin
   trig_a_sw  <= sys_wen && (sys_addr[19:0]==20'h0) && sys_wdata[0]  ;
   if (sys_wen && (sys_addr[19:0]==20'h0))
      trig_a_src <= sys_wdata[2:0] ;
   trig_b_sw  <= sys_wen && (sys_addr[19:0]==20'h0) && sys_wdata[16]  ;
   if (sys_wen && (sys_addr[19:0]==20'h0))
      trig_b_src <= sys_wdata[19:16] ;
   if (sys_wen) begin
      if (sys_addr[19:0]==20'h0)   {rand_a_on, at_autorearm_a, at_invert_a, at_reset_a, set_a_rgate, set_a_zero, set_a_rst, set_a_once, set_a_wrap} <= sys_wdata[12: 4] ;
      if (sys_addr[19:0]==20'h0)   {rand_b_on, at_autorearm_b, at_invert_b, at_reset_b, set_b_rgate, set_b_zero, set_b_rst, set_b_once, set_b_wrap} <= sys_wdata[28:20] ;
      if (sys_addr[19:0]==20'h4)   set_a_amp  <= sys_wdata[  0+13: 0] ;
      if (sys_addr[19:0]==20'h4)   set_a_dc   <= sys_wdata[ 16+13:16] ;
      if (sys_addr[19:0]==20'h8)   set_a_size <= sys_wdata[RSZ+15: 0] ;
      if (sys_addr[19:0]==20'hC)   set_a_ofs  <= sys_wdata[RSZ+15: 0] ;
      if (sys_addr[19:0]==20'h10)  set_a_step <= sys_wdata[RSZ+15: 0] ;
      if (sys_addr[19:0]==20'h18)  set_a_ncyc <= sys_wdata[  32-1: 0] ;
      if (sys_addr[19:0]==20'h1C)  set_a_rnum <= sys_wdata[  16-1: 0] ;
      if (sys_addr[19:0]==20'h20)  set_a_rdly <= sys_wdata[  32-1: 0] ;
      if (sys_addr[19:0]==20'h24)  set_b_amp  <= sys_wdata[  0+13: 0] ;
      if (sys_addr[19:0]==20'h24)  set_b_dc   <= sys_wdata[ 16+13:16] ;
      if (sys_addr[19:0]==20'h28)  set_b_size <= sys_wdata[RSZ+15: 0] ;
      if (sys_addr[19:0]==20'h2C)  set_b_ofs  <= sys_wdata[RSZ+15: 0] ;
      if (sys_addr[19:0]==20'h30)  set_b_step <= sys_wdata[RSZ+15: 0] ;
      if (sys_addr[19:0]==20'h38)  set_b_ncyc <= sys_wdata[  32-1: 0] ;
      if (sys_addr[19:0]==20'h3C)  set_b_rnum <= sys_wdata[  16-1: 0] ;
      if (sys_addr[19:0]==20'h40)  set_b_rdly <= sys_wdata[  32-1: 0] ;
      if (sys_addr[19:0]==20'h118)  at_counts_a[32-1:0]  <= sys_wdata[32-1: 0] ;
      if (sys_addr[19:0]==20'h11C)  at_counts_a[64-1:32] <= sys_wdata[32-1: 0] ;
      if (sys_addr[19:0]==20'h138)  at_counts_b[32-1:0]  <= sys_wdata[32-1: 0] ;
      if (sys_addr[19:0]==20'h13C)  at_counts_b[64-1:32] <= sys_wdata[32-1: 0] ;
   end
   ren_dly <= {ren_dly[3-2:0], sys_ren};
   ack_dly <=  ren_dly[3-1] || sys_wen ;
end
wire [32-1: 0] r0_rd = {3'h0,rand_b_on,at_autorearm_b,at_invert_b,at_reset_b,set_b_rgate, set_b_zero,set_b_rst,set_b_once,set_b_wrap, 1'b0,trig_b_src,
                        3'h0,rand_a_on,at_autorearm_a,at_invert_a,at_reset_a,set_a_rgate, set_a_zero,set_a_rst,set_a_once,set_a_wrap, 1'b0,trig_a_src };
wire sys_en;
assign sys_en = sys_wen | sys_ren;
always @(posedge dac_clk_i)
if (dac_rstn_i == 1'b0) begin
   sys_err <= 1'b0 ;
   sys_ack <= 1'b0 ;
end else begin
   sys_err <= 1'b0 ;
   casez (sys_addr[19:0])
     20'h00000 : begin sys_ack <= sys_en;          sys_rdata <= r0_rd                              ; end
     20'h00004 : begin sys_ack <= sys_en;          sys_rdata <= {2'h0, set_a_dc, 2'h0, set_a_amp}  ; end
     20'h00008 : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-16{1'b0}},set_a_size}     ; end
     20'h0000C : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-16{1'b0}},set_a_ofs}      ; end
     20'h00010 : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-16{1'b0}},set_a_step}     ; end
     20'h00014 : begin sys_ack <= sys_en;          sys_rdata <= buf_a_rpnt_rd                      ; end
     20'h00018 : begin sys_ack <= sys_en;          sys_rdata <= set_a_ncyc                         ; end
     20'h0001C : begin sys_ack <= sys_en;          sys_rdata <= {{32-16{1'b0}},set_a_rnum}         ; end
     20'h00020 : begin sys_ack <= sys_en;          sys_rdata <= set_a_rdly                         ; end
     20'h00024 : begin sys_ack <= sys_en;          sys_rdata <= {2'h0, set_b_dc, 2'h0, set_b_amp}  ; end
     20'h00028 : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-16{1'b0}},set_b_size}     ; end
     20'h0002C : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-16{1'b0}},set_b_ofs}      ; end
     20'h00030 : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-16{1'b0}},set_b_step}     ; end
     20'h00034 : begin sys_ack <= sys_en;          sys_rdata <= buf_b_rpnt_rd                      ; end
     20'h00038 : begin sys_ack <= sys_en;          sys_rdata <= set_b_ncyc                         ; end
     20'h0003C : begin sys_ack <= sys_en;          sys_rdata <= {{32-16{1'b0}},set_b_rnum}         ; end
     20'h00040 : begin sys_ack <= sys_en;          sys_rdata <= set_b_rdly                         ; end
     20'h00114 : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-2{1'b0}},trigbuf_rp_a}    ; end
     20'h00118 : begin sys_ack <= sys_en;          sys_rdata <= at_counts_a[32-1:0]     ; end
     20'h0011C : begin sys_ack <= sys_en;          sys_rdata <= at_counts_a[64-1:32]     ; end
     20'h00134 : begin sys_ack <= sys_en;          sys_rdata <= {{32-RSZ-2{1'b0}},trigbuf_rp_b}    ; end
     20'h00138 : begin sys_ack <= sys_en;          sys_rdata <= at_counts_b[32-1:0]     ; end
     20'h0013C : begin sys_ack <= sys_en;          sys_rdata <= at_counts_b[64-1:32]     ; end
	 20'h1zzzz : begin sys_ack <= ack_dly;         sys_rdata <= {{32-14{1'b0}},buf_a_rdata}        ; end
     20'h2zzzz : begin sys_ack <= ack_dly;         sys_rdata <= {{32-14{1'b0}},buf_b_rdata}        ; end
       default : begin sys_ack <= sys_en;          sys_rdata <=  32'h0                             ; end
   endcase
end
assign asg1phase_o = buf_a_rpnt;
red_pitaya_prng_xor  #(.OUTBITS (RSZ)) prng (
  .clk_i       (dac_clk_i  ),  
  .reset_i     (dac_rstn_i ),  
  .signal_o    (rand_pnt)
);
endmodule
