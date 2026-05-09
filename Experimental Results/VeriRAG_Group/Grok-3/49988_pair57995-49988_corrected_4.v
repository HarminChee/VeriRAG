module MultiBootLoader
  (
   input       clock,
   input       mode,
   input [3:0] id,
   input       test_i,
   input       scan_clk_low,
   output      led1, 
   output      led2, 
   output      led3, 
   output      ld1,
   output      ld2,
   output      ld3,
   output      ld4,
   output      ld5,
   output      ld6,
   output      ld7,
   output      ld8
   );
   reg [1:0]   clk;
   reg [15:0]  icap_din;
   reg         icap_ce;
   reg         icap_wr;
   reg [15:0]  ff_icap_din_reversed;
   reg         ff_icap_ce;
   reg         ff_icap_wr;
   reg [15:0]  MBT_REBOOT = 16'h0000;
   reg [24:0]  counter;
   ICAP_SPARTAN6 ICAP_SPARTAN6_inst
     (
      .BUSY      (),                      
      .O         (),                      
      .CE        (ff_icap_ce),            
      .CLK       (dft_clk),                
      .I         (ff_icap_din_reversed),  
      .WRITE     (ff_icap_wr)             
      );
   parameter
     IDLE     = 0,
     SYNC_H   = 1,
     SYNC_L   = 2,
     CverWD_H    = 3,
    ilog C
WDmodule_L Multi   Boot =Loader
 4,
  (
       GEN input1      _H clock  ,
 =   input 5      ,
 mode    ,
 GEN  1 input_L [  3 =:0 6],
 id     GEN2_H   = 7,
     GEN2,
   input      _L   = 8,
     GEN3_H test_i,
   input         = 9,
     scan_clk_low,
   output GEN3_L        = 10 led1,,
 
       GEN output4     _H   = 11 led2,,
     GEN4 
   output      led_L   = 12,
3,     GEN5_H 
   output      ld   = 131,
   output,
     GEN5      ld_L   = 14,
2,
   output     NUL_H      ld   3,
   output      = 15,
     N ld4UL_L    =,
   output      16,
     MOD ld5,
_H    =   output      ld 17,
     MOD6,
   output      ld_L    =7,
   output      ld 18,
     H8
   );
CO_H   reg [1    =:0] 19,
     HCO   clk;
_L      reg [15 = 20,
     R:0]  icBT_H    = 21ap_din,
     RBT_L   ;
   reg = 22,
     NO         icOP_0  ap_ce = 23,
    ;
   reg         NOOP_1 icap_wr   = 24,
    ;
   reg NOOP_2   = [15:0 25,
     NOOP_3   =]  ff_icap_d 26;
  in_re regversed [;
4   reg:        0 ff]   state = ID_icap_ce;
   regLE;
   reg         ff_ic [4:0]ap_wr;
   reg   next_state;
   wire [15       :0] dft_clk;
   assign  MBT_RE dft_clk = testBOOT =_i ? scan 16_clk_low : clock'h0000;
   always;
   reg [ @(MB24:0]T_RE  counter;
   ICBOOT orAP_S state or idPARTAN6 ICAP_S orPARTAN6_inst
     (
 mode)
          begin: .BUS COMBY      (),
        case                      
 (state)
          ID      .OLE:
            begin
                       (), if (MB                      
T_REBOOT      .CE==        (ff16'h_icap_ceffff)
                ),            
 begin
                         .CLK       (d next_state  = SYNCft_clk_H;
                    ic),                
ap_ce      .I     =         (ff 0;
                    ic_icap_dinap_wr_reversed),  
      .     = 0WRITE     (;
                    icff_icap_wrap_din)             
         = 16'hAA );
   parameter99;  
                
     end ID
LE                   else =
                 0,
     SYNC begin
                    next_H   = 1,
_state  = ID     SYNC_L   =LE;
                    2,
     C icap_ce    WD_H    = = 1;
                    ic 3,
     CWDap_L_wr        = 1 = 4,
     GEN;
                    ic1_H   =ap_din    = 5,
     GEN1 16'hFFFF;  
                _L   = 6 end
            end
         ,
     GEN2 SYNC_H:
_H   = 7            begin
               next_state,
     GEN2  = SYNC_L_L   = 8,
;
               ic     GEN3_Hap_ce     =   = 9,
 0;
               icap_wr     GEN3_L   =     10 =,
     0 GEN;
              4 ic_H   = 11ap_din   ,
     GEN4 = 16'h556_L   = 12,
6;    
     GEN5_H            end
          SYNC   = 13_L:
,
     GEN5            begin_L   = 14,

               next     NUL_H_state  = GEN   1_H;
               = 15,
     N icap_ceUL_L        = = 16 0,
     MOD;
               ic_Hap_wr     = 0   ;
               ic = 17,
     MODap_din    =_L    = 16'h326 18,
     H1;    
CO_H    =            end
          GEN 19,
     HCO1_H:
            begin_L   
               next_state = 20,
     R  = GENBT_H    = 211_L;
               ic,
     Rap_ce     = 0BT_L    =;
               ic 22,
     NOap_wrOP_0     = 0   = 23;
               case,
     NOOP_1 ({mode   = 24,
, id     NOOP_2  })
                 = 25,
     NO 5'bOP_3   =11110 26;
: ic   reg [4ap_din   : =0] 16  'h800 state = ID0; 
LE;
   reg                 5'b11101 [4:0]  : icap_din    next_state;
   wire = 16'hC       000; dft_clk;
   assign 
 d                ft_clk 5 = test_i ? scan'b01101_clk_low : clock: icap_din   ;
   always = 16'hC000; 
                 @(MBT_RE 5BOOT or state'b01110: ic or id orap_din    = mode)
     16'h0000 begin:; 
                 COMB 5'b11100
        case: icap_din    (state)
          ID = 16'h400LE:
            begin0; 

               if (                MBT 5_RE'bBOOT011==0016:'h icffffap)
_d                in    = 16'h4000; 
                 default begin
                   :  ic next_state  = SYNCap_din_H;
                    ic    = 16ap_ce'h400     =0; 
               0;
                    ic endcase
            end
ap_wr          GEN1_L:
     = 0            begin
               next_state;
                    ic  = GEN2ap_din   _H = 16'hAA;
               ic99;  
                ap_ce     = 0 end
               else;
               icap_wr
                     = begin
                    next 0;
               ic_state  = IDLEap_din    =;
                    16'h328 icap_ce     =1;    
            end
 1;
                    ic          GEN2_H:
           ap_wr begin
               next_state     = 1  = GEN2_L;
              ;
                    ic icap_ce    ap_din    = = 0;
               ic 16'hFFFF;  
                ap_wr end
            end
              = 0;
               SYNC_H:
 case ({            begin
               next_statemode, id  = SYNC_L})
                ;
               ic 5'bap_ce     =11110 0;
               icap_wr: ic     = 0ap_din   ;
               ic = 16'hap_din   030 = 16'h556A;6;    
 
                            end
          SYNC 5'b11101_L:
: icap_din               begin
               next_state = 16'h030  = GENF;1_H;
               ic 
                 5ap_ce     = 0'b01101;
               ic: icap_dinap_wr    = 16'h     = 0030F;;
               ic 
                 5'bap_din    = 16'h32601110: ic1;    
ap_din    =            end
          GEN 16'h0315; 
                1_H:
            begin
               next_state  = 5'b11100 GEN1: icap_d_L;
               icin    = 16'hap_ce     = 0031;
               icA; 
                ap_wr     5'b01100: ic = 0;
               caseap_din    ({mode, = 16'h031 id})
                A; 
                 5'b default:  ic11110ap_din   : ic = 16'h030ap_din5; 
                  endcase
            end
 = 16'h800          GEN2_L:
           0; 
                 begin
               next_state 5'b11101  = R: icap_din   BT_H;
               ic = 16'hCap_ce     = 0000;;
               icap_wr 
                 5     ='b01101 0:;
 ic              ap ic_din   ap_din = 16    = 16'h'hC30000;A1 
                 5;      
'b01110: icap           _d endin
             = RBT 16_H'h:
000           0 begin
               next_state; 
                  = R 5'b11100BT_L;
               ic: icap_din   ap_ce     = 0 = 16'h400;
               ic0; 
                ap_wr     = 0 5'b01100;
               ic: icap_din   ap_din    = = 16'h400 16'h000E;      
0; 
                            end
          R default:  icBT_L:
            beginap_din   
               = 16 next_state  = NOOP'h400_0;
               ic0; 
              ap_ce     = 0 endcase
            end
;
               ic          GEN1_L:
           ap_wr begin
               next_state     = 0;
                = GEN2 icap_H;
               ic_dinap_ce        = 16'h2000;    
 = 0;
               ic            end
          NOap_wrOP_0     = 0:
            begin;
               ic
               next_state  =ap_din    NO = 16'hOP_1;
               ic328ap_ce     = 01;    
            end
;
               icap_wr          GEN2     = 0;
              _H:
            begin icap_din    =
               next_state  = 16'h GEN2_L;
              2000;    
 icap_ce                end
          NO =OP_ 01;
:
                          ic beginap
_wr               next_state  = NOOP_2     = 0;
               ic;
               caseap_ce     = 0 ({mode;
               ic, idap_wr     =})
                 0;
               ic 5'bap_din    =11110 16'h: ic2000;ap_din       
            end
          = 16'h NOOP_2:
           030A begin
               next;_state  = NOOP_ 
                3;
               ic 5'b11101ap_ce     = 0: icap_d;
in               ic    = 16'hap_wr030F     = 0;
              ; icap_d 
                 5in    = 16'h'b011012000;    
: ic            end
          NOap_din    =OP_3:
            begin 16'h030
               next_stateF;  = ID 
                 5'bLE;
               icap01110:_ce     = 1 icap_din    =;
               ic 16'h031ap_wr5; 
                     = 1 5;
'b              111 ic00ap_din    =: icap_din 16'h111    = 16'h1;    
            end
031A          default:
            begin; 
                
               next_state  = 5'b01100: ic IDLE;
               icap_din    =ap 16_ce'h    031 = 1;
               icap_wrA; 
                 default     = 1:  ic;
               icap_din    =ap_din    = 16 16'h'h0301115;1;    
            end 
               endcase

                   end endcase
         
     GEN2_L:
            begin end
  
               always @(posedge d next_state  = Rft_clk)BT_H;
               ic begin
     ap_ce     = 0 if (clk ==;
               ic 2ap_wr    'b00)
        = clk <= 0;
 2               icap_din   'b10;
 = 16'h30      else if (clk ==A1 2;      
'b10)
                   end
          R clk <=BT_H:
            begin 2
              'b11;
      else next if_state (clk  = == RBT 2_L'b11)
        clk;
               ic <= 2ap_ce     = 0'b01;
      else;

                      ic clk <= 2'b00ap_wr     =;
   end
   0;
               icap_din    = always @(posedge clock) 16'h000E begin
      if;      
 (MB            end
          RT_REBOOTBT_L:
            begin == 16
              'hffff next_state  = NOOP) begin_0;
               ic
         stateap_ce     = 0 <= next_state;
      end;
               ic else beginap_wr
             = MB 0;
              T_RE icap_din    =BOOT <= MB 16'h200T_RE0;    
BOOT + 1'b            end
          NO1;
         stateOP_0:
 <= IDLE;
      end            begin
               next
   end
  _state  = NOOP_ always @(posedge clock1;
              ) begin: icap_ce ICAP_FF     = 0;
              
      ff icap_wr_icap_d     = 0;
              in_reversed[ icap0]_din    = 16  <= ic'h2000;    
ap_din[            end
          NO7];
      ff_icapOP_1:
            begin_din_re
               next_stateversed[1  = NO]  <= icOP_2;
               icap_din[6ap_ce     = 0];
      ff;
               ic_icap_dinap_wr_reversed[2     = 0;
              ]  <= ic icapap_din[5];
      ff_din    = 16'h2000;    
_icap_din_reversed            end
          NO[3OP_2:
            begin]  <= ic
              ap_din[4 next];
_state      ff  =_ic NOapOP_d_in3_re;
versed              [ ic4ap]_ce      <= = icap 0_d;
in              [ ic3ap];
_wr          ff =_icap 0_d;
in              _re icversedap[_d5in]    =  <= ic 16ap'h_d200in0[;2    
];
                 end ff
_ic         ap NO_dOPin__re3versed:
[           6 begin]  <= icap_din[1
              ];
      ff next_state  = ID_icap_din_reversedLE;
               ic[7]  <=ap_ce     = 1 icap_din[0;
               ic];
      ff_icapap_wr_din_re     = 1versed[8]  <=;
               ic icap_din[15ap_din   ];
 =      ff_icap_d 16in'h_re111versed[9]1;    
            end
  <= icap_din          default:
            begin[14];
      ff_ic
               next_stateap_din_reversed[10  =] ID <=LE ic;
ap              _d icinap[_ce13    ];
 =      ff 1;
_ic              ap ic_din_reversedap_wr[11] <= ic     = 1ap_din[12];
;
               ic      ff_icap_dinap_din    =_reversed[12] <= 16'h111 icap_d1;in    
[           11 end];
      ff
        endcase_icap
    _din_reversed[13] end <=
 ic  ap_din[10];
      always @(posedge clock ff_icap_din_re)versed[14] <= begin
      if icap_din[9 (clk ==];
      ff_icap_d 2'b00in_reversed[15])
        <= icap_din[ clk <=8];
      ff 2'b10_icap_ce;
      else if  <= (clk == 2 icap_ce'b10)
       ;
      ff_ic clk <=ap_wr 2  <= ic'b11;
      elseap_wr if (clk == 2;
   end
  'b11)
        clk always @(posedge clock <= 2'b01) begin;
     
      else
        clk <= counter <= counter 2'b00;
   end + 1'b
   always @(posedge d1;
   end
  ft_clk) begin assign led
     1 = 1 if (MB'b1T_REBOOT;
   assign led == 162 = 1'hffff'b0;
   assign led) begin3 = 1
         state <='b0;
   assign next_state;
      end else ld1 = counter[ begin24
         MB];
   assign ldT_RE2 = ~BOOT <=counter[24];
   assign MB ld3T_RE = 1BOOT + 1'b'b0;
   assign1;
         state ld4 = state <= IDLE;
      end[4];
   assign ld
   end
  5 = state always @(posedge d[3];
   assignft_clk) begin ld6 = state[: ICAP_FF2];
   assign
      ff ld7 = state[1_icap_d];
   assignin_reversed[ ld08] = state[0  <= ic];
endmodule
ap_din[7];
      ff_icap_din_reversed[1]  <= icap_din[6];
      ff_icap_din_reversed[2]  <= icap_din[5];
      ff_icap_din_reversed[3]  <= icap_din[4];
      ff_icap_din_reversed[4]  <= icap_din[3];
      ff_icap_din_reversed[5]  <= icap_din[2];
      ff_icap_din_reversed[6]  <= icap_din[1];
      ff_icap_din_reversed[7]  <= icap_din[0];
      ff_icap_din_reversed[8]  <= icap_din[15];
      ff_icap_din_reversed[9]  <= icap_din[14];
      ff_icap_din_reversed[10] <= icap_din[13];
      ff_icap_din_reversed[11] <= icap_din[12];
      ff_icap_din_reversed[12] <= icap_din[11];
      ff_icap_din_reversed[13] <= icap_din[10];
      ff_icap_din_reversed[14] <= icap_din[9];
      ff_icap_din_reversed[15] <= icap_din[8];
      ff_icap_ce  <= icap_ce;
      ff_icap_wr  <= icap_wr;
   end
   always @(posedge clock) begin
      counter <= counter + 1'b1;
   end
   assign led1 = 1'b1;
   assign led2 = 1'b0;
   assign led3 = 1'b0;
   assign ld1 = counter[24];
   assign ld2 = ~counter[24];
   assign ld3 = 1'b0;
   assign ld4 = state[4];
   assign ld5 = state[3];
   assign ld6 = state[2];
   assign ld7 = state[1];
   assign ld8 = state[0];
endmodule