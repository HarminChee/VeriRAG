`timescale 1ns / 1psver
moduleilog
` Atimescale 1XI_DDRns / 1ps
3module_M AXI_DDRIG(
3_M     IG(
 input              CLK input        , CLK                
      input        ,                
      input         CLK_333 CLK_MHZ,
      input        333MHZ,
      input CLK_200         CLK_MHZ,
      input        200MHZ,
      input RST,         RST,              
      input                      
      input         test_i,
      input           TEST_MODE axi_aw,          
valid,
      input              output          axi axi_aw_awvalid,
      outputready,
      input         [32 axi_aw-1:0] axiready,
     _aw inputaddr,
      input  [  [3-131:0]  axi:0] axi_awprot,
      input_awaddr,
      input  [2           axi:0]  axi_wvalid,
      output_awprot          axi,
      input        _wready,
 axi_wvalid,
      output      input  [32        axi_wready,
      input-1:  [031]: axi0_w]data axi,
_w     data input,
       [ input4-  [13::00]]  axi  axi_w_wstrstrbb,
,
           output output                 axi axi_b_bvalidvalid,
      input        ,
 axi     _b inputready          ,
 axi     _b inputready         axi,
      input           axi_ar_arvalid,
      output       valid,
      output axi_ar          axiready,
      input_ar  [31ready,
      input:0] axi_ar  [addr32,
      input  [2:-1:0] axi0]_araddr  axi_ar,
      inputprot,
      output         [3-1: axi_rvalid,
      input        0 axi]_rready  axi,
_ar     prot output,
 [     31 output:         0 axi] axi_rdata,
_r     valid output,
 [      input12           axi:0] d_rready,
      outputdr3_addr [32,
      output [2-1::0]  ddr0] axi3_b_rdata,
a,
      output             output [12 ddr3_r:0] das_n,
      output       dr3_addr,
      ddr3_cas output [2_n,
      output        ddr3_we_n:0]  d,
      output [0dr3_b:0]  da,
      output       dr3_ck ddr_p,
      output [03_ras:0]  ddr_n,
      output       3_ck_n ddr3_cas,
      output [0:_n,
      output       0] ddr3_we  ddr3__n,
      output [0cke,
      output [0:0]  d:0]  ddr3_csdr3_ck_n,
      output [1_p,
      output [0:0]  ddr:0]  ddr3_dm3,
_ck      output [0:_n,
      output [0]  ddr3_od0:0]t  d,
dr     3 inout_  [15cke,
      output [0:0] ddr3:0]  ddr_dq,
      inout3_cs  [1_n,
      output [1:0]:0]  d  ddr3_dqs_p,
      inoutdr3_dm  [1:0,
      output [0:]  ddr3_d0]qs_n
     ddr3_od );
   t,
      inout wire rst  [15_i;
    assign:0] ddr3 rst_dq,
      inout_i = ~  [RST1;
    localparam [:0]2:0] CMD  ddr3_d_WRITE =qs_p,
 3     'b inout000;
    localparam [  [12:0] CMD_READ:0]  =  ddr3_d 3'b001;
    wireqs_n mem
   _ui_clk;
    wire mem_ui );
   _rst;
    wire rst_def wire rst;
    wire rstn_i;
    assign;
    wire d rstft_mem_i = ~_ui_clk;
RST;
    local    wire dft_memparam [_ui2:0] CMD_rst;
    reg_WRITE = [26 3'b:0]000;
    local  mem_addr; 
    reg [2param [2:0]:0]   mem CMD_READ_cmd;  = 3 
    reg        'b001 mem_en;
    wire mem;_ui_clk;
    wire 
    wire        mem_ui_rst mem_rdy;
    wire rst;
    wire       _def;
    wire mem_wdf rstn_rdy;;
    wire d 
    regft_mem [63_ui_clk:0]  mem;
    wire dft_mem_wdf_ui_data;
    reg_rst;
    reg         mem_wdf_end; [26 
    reg:0] [7  mem_addr;:0]   mem 
    reg_wdf_mask;
    reg [        2: mem_wdf_wren;
    wire [0]63  mem:_cmd0;] mem_rd 
    reg mem_en;_data;
    wire        mem_rd 
    wire mem_data_end;_rdy 
    wire        mem_rd;
    wire mem_data_valid;_wdf_rdy; 
    wire 
    reg        mem [_init_calib_complete;63:0] mem 
    reg        _wdf rd_v_data;
    regld; 
    reg         mem_wdf rd_end_end;;
    reg 
    reg [63 [7:0]  rd:0] mem_data_1_w,df_mask;
    reg rd_data_ mem_wdf_w2;
    wireren;
    wire        [63 block:;
0   ] reg mem        _rd_data;
    wire block_o;
    reg [31:0 mem_rd]  w_data_end;addr, 
    wire mem raddr;
    reg_rd_data_valid; [31 
    wire:0]  wdata mem_init_calib_complete;
    reg [3:; 
    reg0]   wstr rdb;
    reg_v [1ld;:0]   w 
    reg rdassert;
    reg_end;
    reg         rassert;
 [63    assign axi:0] rd_aw_data_1, rd_data_2;
    wire block;
    reg blockready = ~block;
    assign axi_arready = ~_o;
    regblock;
    assign axi [31_wready = ~:0block;
    assign dft_mem_ui_clk = TEST] waddr, r_MODEaddr ?;
 CLK    reg [ :31 mem:0] w_ui_clk;
    assign ddata;
    regft_mem_ui [3_rst = TEST:_MODE0 ?] RST wstr :b;
    reg mem_ui_rst;
    always [1 @(posedge CLK:0] w)
    beginassert;
    reg r : SINGLEassert;
    assign axi_SHOT_aw
ready        = if ~(rst_def == 1'bblock;
    assign axi0) begin
            w_araddr <= 0ready = ~;
            rblock;
    assign axiaddr <= 0_wready = ~;
            wdatablock;
    assign d <=ft 0_mem;
            wstrb <= 0_ui_clk =;
            w test_i ? CLK :assert <= 2 mem'b00_ui_clk;
    assign d;
            rft_mem_uiassert <=_rst = test 1'b0;
        end_i ? RST : else begin
            if mem_ui_rst;
    always( @(posedge CLKaxi_bvalid)
    begin | block : SINGLE) begin    
_SHOT                waddr
        if <= waddr;
(rst                wstr_def ==b <= wstr 1'b0) beginb;
                w
            wassert[0] <=addr <= 1 0;
            raddr'b0;
            end else <= 0 if(axi;
            wdata_awvalid) begin
                <= waddr <= axi 0;
            wstr_awaddr;
                wstrb <= 0b <=;
            wassert <= axi_wstr 2b;
                wassert'b00[0] <= 1;
            r'b1;
            end elseassert <= 1 begin
                waddr'b0;
        end else <= waddr;
 begin
            if(                wstrb <=axi_bvalid wstrb;
                w | blockassert[0] <= w) begin    
assert[0];
            end                w
            if(axiaddr <= waddr_bvalid | block;
                wstr) beginb <=    
                wdata <= w wstrb;
                wdata;
                wassert[assert1[] <= 10] <= 1'b0;
            end else'b0;
            end else if( if(axiaxi_wvalid) begin
_awvalid) begin                wdata <= axi
                waddr <= axi_wdata;
                w_awassertaddr[;
1               ] wstr <=b <= 1'b1;
            end axi_wstr else beginb;
                wassert
                wdata <=[0] <= 1 wdata;
                wassert'b1;
            end else[1] <= w begin
                waddrassert[1];
            end <= waddr;
                wstr
            if(axib <= wstr_rvalidb;
                w | blockassert[0] <= w) beginassert[0];
            end    
                raddr <= raddr;
               
            if(axi_b rassert <=valid | 1'b block) begin0;
            end else if    
                w(axi_ardata <= wvalid) begin
                rdata;
                waddr <= axi_arassert[1] <=addr;
                r 1assert'b <=0;
            end else if( 1'b1;
           axi_wvalid) begin end else begin
                wdata
                raddr <= axi <= raddr_wdata;
                w;
                rassert[1] <=assert <= rassert 1'b1;
            end;
            end
        end else begin
    end
   
                wdata <= parameter st wdata;
                wassert0_nothing[1] <= w = 0,assert[1];
            end st2_CheckR
            if(axi_rvaliddy = 2 | block, st3_WaitR) begindy = 3,    
 st               4 r_detouraddr <= raddr;
                = 4, st rassert <=5_wready 1 = 5,'b0;
            end else st6_rready = if(axi 6, st7_arvalid) begin_waitclean
                r = 7addr <= axi_ar;
   addr reg;
                rassert <= [3: 1'b1;
           0] state end else begin;
    reg is
_w               rit raddr <= raddrting;
    reg;
                rassert axi <=_bvalid_o rassert;
    reg axi;
            end
        end_rvalid_o;
    reg
    end
    [31 parameter st0_n:0] axiothing = 0,_rdata_o st2_CheckR;
    localdy = 2param NUM, st3_Wait_RET_RVALIDRdy = 15 = 3,;
    wire st4_detour axi_rvalid = 4,_def;
    reg st5_wready [NUM = 5,_RET_RVALID st6_rready =-1:0 6], axi st7_waitclean_rvalid_def_reg;
    = 7 always @(posedge CLK;
    reg) axi [3_rvalid_def_reg =:0] state {axi;
    reg is_rvalid_def_writting;
    reg_reg[NUM axi_RET_RVALID_bvalid_o-2;
    reg:0], axi axi_r_rvalidvalid_def_o;
    reg};
    assign [31 axi:0] axi_rvalid = axi_rvalid_def_reg[NUM_rdata_o;
    local_RET_RVALIDparam NUM-1];
    local_RET_Rparam NUMVALID = 15_RET_BVALID;
    wire = 15 axi_rvalid;
    wire axi_def_b;
valid   _def reg [NUM;
    reg_RET_RVALID [NUM_RET_BVALID-1:0] axi-1:_rvalid_def_reg;
   0] axi always @(posedge_bvalid_def_reg;
    CLK) axi always @(posedge_rvalid_def_reg = CLK) axi {axi_bvalid_def_reg = {_rvalid_defaxi_bvalid_def_reg[NUM_reg[NUM_RET_BVALID_RET_RVALID-2-2:0], axi:0],_bvalid_def};
    axi_rvalid_def assign axi_bvalid = axi_b};
    assignvalid_def_reg[NUM axi_RET_BVALID-_rvalid = axi1];
    bus_rvalid_def_reg[NUM_sync_sf_RET_RVALID #-1];
    local(.implparam NUM(1),_RET_BVALID .sword = 15(32;
    wire axi+1)) sync_bvalid_def_rdata(.;
    regCLK1 [NUM_RET_B(dVALID-1:ft_mem_ui0] axi_clk), .CLK2(_bvalid_def_reg;
   CLK), .RST always @(posedge(RST), 
 CLK   ) axi .data_in_bvalid_def_reg = {({axiaxi_bvalid_rdata_o_def_reg[NUM_RET, block_BVALID_o}), 
    .data-2_out({axi_rdata:0],, block axi_bvalid_def}));
    bus};
    assign_sync_sf axi_b #(.implvalid = axi_b(1), .swordvalid_def_reg[NUM(2_RET_BVALID-)) sync1];
    bus_flags(._syncCLK_sf1 #(d(.ftimpl_mem(_ui1_clk),), . .swordCLK(232(+CLK1),)) . syncRST_rdata(RST), 
    .data_in({axi_bvalid_o,(. axi_rvalid_o}),CLK1 
    .data_out({(daxi_bft_mem_uivalid_def_clk), .CLK, axi2(_rvalidCLK), .RST_def}));
    wire(RST), 
 [31:0] waddr_o,    raddr_o;
    wire .data_in [31({axi:0_rdata_o] wdata_o, block;
    wire [3_o}), 
    .data:0] wstr_out({axib_o;
   _rdata, block wire w}));
    busassert_o_sync_sf;
    wire rassert #(.impl_o;
    wire axi(1), .sword_rready_o(2;
    wire axi_b)) sync_flagsready_o;
   (. localparam NUMCLK1(dft_mem_RET_WASSERT_ui_clk), .CLK = 202(;
    wire [CLK), .RST1:0] wassert(R_def;
    regST), [ 
NUM    .data_RET_WASSERT_in({axi_b-1:0] wvalid_o, axiassert_def_reg;
_rvalid_o}),    always @(posedge d 
    .data_out({ft_mem_uiaxi_b_clk) wassertvalid_def_def_reg =, axi {wassert_rvalid_def_def_reg[NUM}));
    wire_RET_WASSERT [31:0] w-2:0addr_o,], & raddr_o;
    wirewassert_def [31};
    assign w:0assert_o = w] wdata_oassert_def_reg[NUM;
    wire [3:0] wstr_RET_WASSERT-1];
    localb_oparam NUM_RET;
    wire_R wASSERTassert_o;
    = 20 wire;
 r    wire rassert_oassert_def;
    reg [;
   NUM wire_RET axi_r_RreadyASSERT_o;
    wire axi_b-1:ready_o;
   0] r localparam NUMassert_RET_WASSERT_def_reg;
    = 20 always @(posedge;
    wire [1 dft_mem:0] w_ui_clk) rassert_def;
    regassert_def_reg = { [NUMrassert_def_reg[NUM_RET_WASSERT_RET_RASSERT-1:-20] w:0], rassert_def_reg;
assert_def};
    assign    always @(posedge d rassertft_mem_ui_o = r_clk) wassert_def_reg[NUMassert_def_reg =_RET_RASSERT {wassert-1];
    bus_def_reg[NUM_sync_sf_RET_WASSERT #(.impl-2(0), .sword:0], &(32+32wassert_def+32};
    assign w+assert4_o+ = w2+1))assert_def_reg[NUM sync__RET_WASSERTodata(.CLK-1];
    local1(CLK),param NUM .CLK2(dft_mem_RET_R_uiASSERT_clk =), . 20RST(RST), 
;
    wire r   assert ._defdata;
_in    reg [({waddrNUM_RET, raddr,_RASSERT wdata, wstr-1:b, wassert0] r, rassertassert}), 
    .data_def_reg;
   _out({waddr always @(_o, raddrposedge d_o, wdata_o,ft_mem_ui wstrb_o_clk) r, wassertassert_def_reg = {_defr,assert rassert_def_reg[NUM_RET_def}));
    bus_RASSERT_sync_sf-2 #:0], r(.impl(0assert_def};
    assign), .sword rassert_o(2)) sync = rassert_flag_def_reg[NUMso(.CLK_RET_RASSERT1-(1];
    bus_sync_sfCLK), . #(.implCLK2(dft(0), ._mem_ui_clk), .RSTsword(RST), 
   (32+ .32data_in+32({axi+4+_bready, axi2+1))_rready}), sync_ 
    .data_out({odata(.CLKaxi_bready_o1(CLK),, axi_r .CLK2ready_o}));
   (dft_mem always @ (posedge_ui_clk), . dft_memRST(RST), 
   _ui_clk or .data_in pos({waddredge dft_mem, raddr,_ui_rst) begin
        wdata, wstr if (dft_mem_uib, wassert_rst ==, rassert 1'b1}), 
    .data) begin
            axi_out({w_bvalid_oaddr_o, r <=addr_o, wdata 1'b_o0,;
 wstr            axi_rvalid_o <=b_o, w 1'b0;
            axiassert_def,_rdata_o rassert <=_def}));
    bus 0;
            is_sync_sf_writ #(.implting <= 1(0'b0;
            state <=), .sword st(2)) sync0_nothing;
            mem_flag_wdf_wso(.CLKren <=1(CLK), . 1'b0;
            memCLK2(dft_wdf_end <=_mem_ui_clk), . 1'b0;
            memRST(RST), 
_en <= 1    .data_in'b0;
            mem({axi_b_cmd <= 0;
ready, axi_r            block_o <= 1ready}), 
   'b0;
        end else .data_out
({axi_b            case (ready_ostate)
                st, axi_rready0_nothing:_o}));
    begin
                    if(mem always @ (posedge_init dft_mem_calib_complete_ui_clk or == 1'b negedge rst1) begin 
_def) begin                        if(mem
        if (_rdy ==rst_def == 1 1'b1'b0) begin
           ) begin 
 axi                            if(mem_bvalid_o_wdf_r <=dy == 1'b 1'b0;
            axi1) begin_rvalid_o <= 
                                if(w 1'b0;
            axiassert_o ==_rdata_o 1'b1 <=) begin
                                    state 0;
            is <= st2_CheckR_writdy;
                                    memting <= 1'b_cmd <= CMD0;
            state_WRITE;
                                    mem <= st0_nothing;
_w           df mem_wren_wdf_wren <= <= 1'b1 1;
'b                                   0 mem;
_w           df mem_wdf_end <=_end <= 1'b0;
            mem 1'b1;
                                    mem_en <= 1_en <= 1'b0'b1;
            mem;
                                    mem_cmd <= 0;
_addr <= {w            block_o <= 1addr_o[29'b0;
        end else:3
],            case (state 3'b000};
                                   )
                st mem_wdf0_nothing_data <= {w:data_o, w begindata
_o                   };
 if                                   (mem mem_init_wdf_mask <= {_calib_complete ==~{wstr 1'bb_o & {1) begin 
4{w                        if(memaddr_rdy ==_o[2 1'b1]}}},) begin 
 ~{w                            if(memstrb_o_wdf_rdy & {4 == 1'b{~1w)addr begin_o 
[                               2 if]}}(w}};
assert                                   _o == is_w 1rit'bting1 <=) begin 1
'b                                    state <= st2_CheckR1;
                                end else ifdy;
                                    mem(r_cmd <= CMDassert_WRITE;
                                    mem_o == 1_wdf_wren'b1) begin
                                    <= state <= st 1'b1;
                                   2_CheckR mem_wdf_end <=dy;
                                    mem 1'b1;
                                   _cmd <= CMD mem_en <=_READ;
                                    mem_en <= 1 1'b1'b1;
                                    mem;
                                    mem_addr <= {r_addr <= {waddr_o[29:3addr_o[29],:3 3'b000};
                                   ], 3'b000 is_writ};
                                    memting <= 1_w'bdf0;
                                end else_data <= {w begin
                                    statedata_o, w <=data st_o0_nothing;
                                end
                           };
                                    mem end
                        end
                   _wdf_mask <= { end
                end
~{wstr                st2_Checkb_o &Rdy {4: begin{waddr
                    if(mem_r_ody[ ==2 1'b]0}}},)
                        ~ state{ <=w ststr3_WaitRdyb_o &;
                    else begin {4{~
                        memwaddr_wdf_wren_o[2 <= 1]}}}};
'b0;
                        mem                                   _wdf_end <= is_writ 1'b0ting <= 1'b;
                        mem_en1;
                                end <= else if(r 1'b0;
                        stateassert <= st_o == 14_detour'b1;
                    end)
 begin                end
                st3_Wait
                                    stateRdy <= st:2_Check begin
                    if(mem_rRdydy == 1'b;
                                    mem1)
                        state_cmd <= CMD_READ <= st3;
_W                                   ait memR_endy <=;
                    1 else'b begin1
;
                                                           mem mem_wdf_wren_addr <= {r <= 1addr_o[29'b0;
                        mem:3_wdf_end <=], 1 3'b'b0;
                        mem000};
                                   _en <= 1 is_writ'b0;
                       ting <= 1'b state <= st40;
                                end else begin_detour;
                    end
                end

                                    state                st4 <= st_detour:
0_nothing;
                                end                    if(is_w
                            end
                        endritting) begin
                    end
                end
                        state
                st2 <= st_CheckR5_wreadydy: begin Copies
                    if(mem of this module_rdy == cannot 1 be made'b0)
 because                        state <= st the3 module_W isait instantiatedR insidedy the;
 DDR                   3 else module begin,
 which                        is mem encrypted_w.
df                   _w elseren <= 1'b0 begin
                        if;
                        mem_wdf_end(rd_v <=ld & 1'b0;
                        rd_end mem_en <=) begin
                            state <= st6_rready 1'b0;
;
                                                   axi state_rvalid <=_o st <=4_detour 1;
'b                   1 end;

                                           if end(raddr
                st3_Wait[R2dy])
:                                axi begin
                    if(mem_r_rdata_ody == 1'b <= rd1)
                        state_data_2 <= st3_W[63:32aitRdy];
                            else
                                axi;
                    else begin_rdata_o
                        mem_w <= rddf_wren_data_2[31 <= 1:0];
                        end else'b0;
                        mem begin
                           _wdf_end <= state <= st4 1_detour;
                        end
'b0;
                        mem_en                    end
                st <=5_wready 1'b:
                    if (axi0;
                        state_bready_o <= st4 == 1_detour;
                   'b1) begin end
                end
               
                        state <= st4_detour:
 st7_waitclean                    if(is;
                        block_writting) begin_o <= 1
                        state'b1;
                    end else <= st
5_wready                        state <= st5_w;
                        axiready;
                st_bvalid_o6_rready <=:
                    1 if'b (1axi;
_r                    endready_o == else begin 1'b1
                        if(rd_v) beginld &
                        state <= rd_end st7_waitclean) begin;
                        block
                            state_o <= <= st 1'b1;
                    end6_rready else
                        state;
                            axi <= st6_rready_rvalid_o;
                <= st7_waitclean 1'b1;
                            if:
                    if (is(raddr_writ[2ting ==])
                                axi 1'b_rdata_o1 && wassert <= rd_o == 1_data_2'b0) begin
                       [63:32 state <= st0_nothing];
                            else
;
                        axi                                axi_rdata_bvalid_o_o <= rd <=_data_2[ 1'b0;
                        block31:0_o <=];
                        end else 1'b0;
                    end begin
                            else if (is_w state <= st4_detourritting == 1;
'b                       0 end &&
 r                   assert end
                st_o == 15_wready'b0:
                    if (axi) begin_bready_o
                        state <= st == 10_nothing;
                        axi'b1_rvalid_o <=) begin 1'b0
                        state <=;
                        block_o st7_waitclean <= 1;
'b                       0 block;
_o                    <= end
 1               'b default1:
;
                                       state end <= st0_n elseothing
;
                                   state endcase <=
 st   5_wready end;

                   st always @6 (_rposedgeready d:
ft                    if (axi_mem_ui_rready_o_clk ==)
    1 begin'b
        rd1) begin_v
                        stateld <= <= st mem_rd_data_valid7_waitclean;
                        block;
        rd_end_o <= <= mem 1'b1;
                    end_rd_data_end;
        rd else
                        state_data_ <=1 st <=6 mem_r_rdready_data;
;
                       st rd7_data_wait_clean2:
 <=                    rd if_data (_is_writ1ting;
 ==    end 1
'b   1 d &&dr w3 Inst_DDR3assert (
_o      .ddr3_dq == 1              (dd'br03)_d beginq
                        state <=),
 st     0 ._nddothing;
                        axir3_dqs_bvalid_o_p <=           (ddr 1'b0;
                       3 block_dqs_o <=_p 1'b0;
                   ),
      .ddr3 end else if (is_dqs_writ_n           (ddting ==r3_dqs 1_n),
      .dd'b0 &&r3_addr rassert            (dd_or ==3_addr),
      . 1'b0ddr3_b) begina              (
dd                       r state3 <=_b st0_nothing;
                       a),
      .ddr axi_rvalid3_r_o <=as_n           (dd 1'b0;
                        blockr3_ras_o <= 1_n),
      .dd'b0;
                    end
r3_cas_n                          default (ddr3_cas:
                    state_n),
      .ddr <= st0_nothing3_we;
            endcase_n           
    (ddr3_we end
    always_n),
      .dd @ (posedger3_ck dft_mem_p            (dd_ui_clkr3_ck)
    begin_p),
      .ddr
        rd3_ck_n_vld            (dd <= memr3_ck_n_rd_data),
      .dd_valid;
        rdr3_cke_end <= mem             (_rd_data_enddd;
r       3 rd__data_cke),
      .dd1 <= memr3_cs_rd_data_n            (;
        rd_data_ddr3_cs2 <= rd_n),
      .dd_data_r3_dm              (1;
    end
   ddr3_dm ddr),
      .ddr33 Inst_od_DDRt             (dd3 (
      .ddr3_odr3_dt),
      .sysq             _clk_i (ddr3            (CLK__dq),
      .dd333MHZ),
      .r3_dqsclk_ref_p_i            (CLK_           (dd200MHZ),
      .r3_dqssys_rst_p),
      .dd              (rstnr3_dqs),
      .app_n           (_addr            ddr3_dqs (_nmem),
      .dd_addr),
      .appr3_addr           _cmd              ( (ddmemr_cmd3),
_addr     ),
 .     app .ddr3_b_en              a              (dd (memr3_b_ena),
),
           .app .ddr3_r_wdf_data        as_n           ( (mem_wdfddr3_r_dataas_n),
      .),
      .appddr3_wdf_cas_end_n                    (dd (mem_wdf_endr3_cas_n),
     ),
      .app_w .ddr3df_mask         (mem_we_n           _wdf_mask),
      . (ddr3_we_n),
      .ddapp_wdf_wren         (memr3_ck_w_pdf           _w (ddren),
      .appr3_rd_data         _ck (mem_rd_data),
     _p),
      .ddr .app_rd3_ck_data_end     _n            ( (mem_rdddr3_ck_data_end),
      .app_n),
      .ddr_rd_data_valid3_    (memcke             (_rd_data_validddr3_),
      .appcke),
      .dd_rdyr3_cs              (_n            (mem_rdyddr3_cs),
      .app_n),
      .dd_wdf_rr3_dmdy          (mem              (_wdf_rddr3_dmdy),
      .app),
      .ddr3_sr_od_req           (1t             (dd'b0),
      .appr3_od_ref_reqt),
      .sys          (1_clk_i'b0),
      .app            (CLK__zq_req333MHZ),
      .           (1'b0clk),
_ref      .ui_clk              _i            (CLK (mem_200_ui_clk),
      .uiMHZ),
      .sys_clk_sync_rst              (_rst     rstn),
      . (mem_ui_rst),
     app_addr .device_temp_i             (       mem (_addr12),
      .app'b000_cmd             000000000 (mem),
      .init_cmd),
      .app_calib_complete_en  (              mem (_initmem_calib_complete_en),
      .app)); 
_wdf_data            assign rst (mem_wdfn = ~_datarst_i),
      .app;
   _w assign rst_defdf_end          = ~( (mem_wdf_endrst_i),
      .app_w | memdf_mask        _ui_rst);
endmodule (mem_wdf_mask
),
      .app_wdf_wren         (mem_wdf_wren),
      .app_rd_data          (mem_rd_data),
      .app_rd_data_end      (mem_rd_data_end),
      .app_rd_data_valid    (mem_rd_data_valid),
      .app_rdy              (mem_rdy),
      .app_wdf_rdy          (mem_wdf_rdy),
      .app_sr_req           (1'b0),
      .app_ref_req          (1'b0),
      .app_zq_req           (1'b0),
      .ui_clk               (mem_ui_clk),
      .ui_clk_sync_rst      (mem_ui_rst),
      .device_temp_i        (12'b000000000000),
      .init_calib_complete  (mem_init_calib_complete)); 
    assign rstn = ~rst_i;
    assign rst_def = ~(rst_i | dft_mem_ui_rst);
endmodule