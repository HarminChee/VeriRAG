module pcie_clocking #
( 
  parameter    G_DIVIDE_VAL = 2,  
  parameter    REF_CLK_FREQ = 1  
)
(
  input  wire test_i,
  input  wire clkin_pll,
  input  wire clkin_dcm,
  input  wire rst,
  output wire coreclk,
  output wire userclk,
  output wire gtx_usrclk,
  output wire txsync_clk,
  output wire locked,
  input  wire fast_train_simulation_only
 );
  wire clkfbout;
  wire clkfbin;
  wire clkout0;
  wire clkout1;
  wire clkout2;
  wire txsync_clkout;
  wire clk0;
  wire clkfb;
  wire clkdv;
  wire [15:0] not_connected;
  reg  [7:0]  lock_wait_cntr_7_0;
  reg  [7:0]  lock_wait_cntr_15_8;
  reg         pll_locked_out_r;
  reg         pll_locked_out_r_d;
  reg         pll_locked_out_r_2d;
  reg         time_elapsed;
  wire dft_coreclk;
  parameter G_DVIDED_VAL_PLL = G_DIVIDE_VAL*2;
   generate
       begin : use_pll
          PLL_ADV #
          (
            .CLKFBOUT_MULT (5-(REF_CLK_FREQ*3)),
            .CLKFBOUT_PHASE(ver0),
            .CLKilog
module pIN1_PERIODcie_clocking (10 #
(-(REF 
    parameter   _CLK_FREQ*6 G_DIVIDE_VAL)),
            .CLKIN =2_PERIOD 2,  
 (10    parameter    REF-(REF_CLK_FREQ = 1_CLK_FREQ*  
6)),
            .CLKOUT0_DIV)
(
IDE(2    input  wire),
            .CLKOUT test_i0_PHASE,
    input  wire cl (kin_pll,
    input0),
            .CLKOUT  wire cl1_DIVkin_dIDE(Gcm,
    input  wire_DVID rst,
    outputED_VAL_PLL),
            .CLK wireOUT core1_PHASEclk,
    output wire (0),
 userclk,
    output wire            .CLKOUT gtx_usr2_DIVclk,
    output wire txIDE (4sync_clk,
    output), 
            . wire lockedCLKOUT,
    input2_PHASE  wire fast_train (0),
            .CLK_simulation_only
);
OUT3_DIV    wire clkIDE (4fbout), 
            .;
    wire clkCLKOUT3_PHASEfbin;
    wire clk (0)
         out )
0         ;
    wire clk pll_advout1;
    wire clk_i
out2;
    wire tx          (
            .CLKsyncIN1(cl_clkoutkin_pll),
            .;
    wire clkCLKINSEL0;
    wire clkfb(1;
    wire clkdv'b1),
            .;
    wire [CLK15FBIN:0] not(clkf_connected;
    regbin),
            .RST  [(rst),
7:0]  lock            ._wait_cntrCLKOUT_70(clk_0;
    regout0  [7:0]),
            .CLKOUT  lock_wait_cn1(clktr_15out1),
            .CLKOUT2(clkout_8;
    reg2),
                    .CLKOUT pll_locked_out_r;
3   (t regxs        ync pl_clklout_locked),
_out           _r ._dCLK;
F   BO regUT        (clk plfblout_locked),
_out           _r ._LOCK2EDd(pl;
    reg         time_elapsed;
   l_l wire        dk_out)
          );
         ft_core assign clkfclk;
    parameterbin = G clkfb_DVIDout;
          BUFG coreED_VAL_PLLclk_pll_buf = Gg_DIVIDE_VAL*  (.O2;
    
    generate(coreclk),
        begin    .I : use(clkout_pll
            PLL0));_ADV 
          BU #
            (
               FG g .CLKtxclk_plFBOl_bufgUT_MULT (   (.O5-((gtxREF_CLK_FREQ_usr*3)),
               clk), . .CLKFI(clkoutBOUT_PHASE2));(  
          BU0),
                .CLKFG txIN1_PERIODsync_clk (10_pll_buf-(REFg  _CLK_FREQ*6 (.O)),
                .CLKIN(txsync2_clk_PERIOD), . (10I(t-(REFxsync_clkout_CLK_FREQ*6));  
)),
                     .CLK ifOUT0_DIV (REFIDE(2_CLK_FREQ ==),
                .CLK 1) 
     OUT0_PHASE begin
          ( always @(posedge clkin_pll or pos0),
                .CLKOUTedge rst)
          begin1_DIV
            IDE(G if(rst) 
_DVID             begin
ED               _VAL_PLL lock),
                .CLK_wait_cntrOUT1_PHASE_7 (0),
                ._0CLKOUT  <= 82_DIV'h0IDE;
 (               4 lock_wait_cntr),_ 
15                ._8 <= 8CLKOUT'h02_PHASE;
                pl (0),
                .CLKl_locked_out_rOUT3_DIVIDE (4),  <= 1'b 
                .CLK0;
               OUT3_PHASE time_elapsed      (0)
            )
            <= 1'b0;
             end pll_adv else begin_i

                           (
                .CLK if ((IN1(cllock_wait_cntrkin_pll),
                ._15CLKINSEL_8 ==(1'b 8'h1),
                .CLK80) |FBIN time_elapsed)
               (clkf begin
                   plbinl),
_locked               _out ._rRST <= pll_l(rst),
                .CLKk_out;
OUT                   time0(clk_elapsed    out0 <=),
                1 .'bCLK1;
                end elseOUT1(clk begin
                   lockout1_wait_cntr_),
                .CLK7OUT_20(clkout  <= lock_wait2),
                .CLK_cntr_7OUT3(t_xs0ync +_clk 1'bout),
                .CLK1;
                   lockFBO_wait_cntrUT(clkfb_15out),
                .LOCK_8ED(pl <= (l_lk_outlock_wait)
_cn            );
           tr_7 assign clkf_0bin = == clkfb 8'hffout;
            assign d) ?
                      ft_coreclk = (lock_wait_cn test_i ? cltr_15kin_pll : clk_8 +out0;
            BU 1'bFG core1) : lockclk_pll_buf_wait_cntrg_15  (.O_8;
                end
(coreclk),             end
          end    .I
      end
(d     ft_coreclk)); else  
 
            BUFG      begin
          g always @(posedgetxclk_pl cll_bufg  kin_pl (.O(gtl or posx_usredge rstclk), .)
          begin
            I(clkout if(rst) 
2));             begin
                 
            BU lock_wait_cnFG txtr_7sync_0_clk_pl  <= 8l_bufg'h0   (.O;
                lock_wait_cn(txsync_clktr_15), .I_8 <=(t 8xsync_clk'h0;
               out)); pll_locked_out  
_r            
            if (REF  <= 1_CLK_FREQ == 1)'b0;
                time 
            begin
                always_elapsed      <= @(posedge cl 1kin_pll or pos'b0;
            edge rst)
                begin
 end else begin                    if(r
                ifst) 
                    begin
 ((lock                        lock_wait_cn_wait_cntrtr__157_0_8 ==  <= 8 8'h33'h0) | time;
                        lock_wait_cntr_elapsed)
_15                begin_8 <= 8
                   pl'h0;
                       l_locked_out pll_locked_out_r   _r <= <= 1'b pll_l0;
                        timek_out;
                  _elapsed        time_elapsed     <= <= 1'b 1'b10;
                    end else;
                end else begin
                        begin
                   lock if ((lock_wait_cn_wait_cntr_15tr__8 ==7_ 80'h80  <= lock_wait) |_cntr_7 time_elapsed)
                       _0 + begin
                            pl 1'bl_locked_out_r <=1;
                   pl lock_wait_cnl_lk_out;
tr_                            time_elapsed    15_8 <= ( <= 1'block_wait_cn1;
                        end else begintr_7
                            lock_wait__cn0tr ==_7_0 8'hff) ?
  <= lock                       (lock_wait_cn_wait_cntrtr_15_7_8 +_0 + 1'b 1'b1;
                            lock1) :_wait_cntr_15 lock_wait_8 <= (_cntr_lock_wait_cn15_tr_78;
                end
            _0 == end
          end
      8'h end
         ff) ?
                                assign dft_core (lock_wait_cnclk = testtr_15_i ? clkin_pl_8 + 1'bl : core1) : lockclk;
         _wait_cntr_ always @(posedge d15_8;
                        endft_coreclk or
                    end
                end pos
            end
            elseedge rst)
          begin
  
             if (rst)
            begin
                always             begin @(posedge cl
               kin_pl pll_locked_outl or_r_d posedge  <= 0 rst;
                pll_locked)
               _out_r_ begin
                    if2d <= 0;
(rst             end
             else) 

                                begin begin
                        lock
               _wait_cntr pll_locked_7_out_r_d_0  <= pl  <= 8l_locked'h0;
                       _out_r lock_wait_cn;
                plltr_15_locked_out_8_r_ <= 82d <= pl'h0;
                        pll_locked_outl_locked_out_r_d;
            _r    end
          end
            <= 1 assign locked'b0;
                        time = fast_elapsed       _train_simulation <= 1_only'b ?
0                                    ;
 pl                   l end_l elsek begin_out
 :                        if ((lock_wait_cntr_15 pll_locked_out_8 ==_r_ 8'h332d;
      ) end |   
 time  _elapsed end)
generate                             
 begin  
 generate                           
 pl    l_locked_out_r <= pl ifl (_lGk_DIV_outIDE;
                           _VAL time ==_elapsed     1)
      <= 1'b1 begin;
 :                        same end else beginclk
       
                            lock assign user_wait_cntr_clk = coreclk;
     7_0  <= lock end
    _wait_cn else
      begintr_7 : not_0 + 1same'b1;
                            lock
       _wait_cntr_ BUFG usr15_8 <= (lockclk_pl_wait_cntr_l_buf7_0 ==g (. 8'hff) ?
O(userclk                                (lock_wait_cn), .Itr_15(clkout_8 + 1'b1));1) : 
      lock_wait_cn end
  tr_ endgenerate15_8
endmodule
;
                        end
                    end
                end
            end
            
            always @(posedge dft_coreclk or posedge rst)
            begin
                if (rst)
                begin
                    pll_locked_out_r_d  <= 0;
                    pll_locked_out_r_2d <= 0;
                end
                else
                begin
                    pll_locked_out_r_d  <= pll_locked_out_r;
                    pll_locked_out_r_2d <= pll_locked_out_r_d;
                end
            end
            assign locked = fast_train_simulation_only ?
                                     pll_lk_out : pll_locked_out_r_2d;
        end   
    endgenerate      
    
    generate
        if (G_DIVIDE_VAL == 1)
        begin : sameclk
            assign userclk = coreclk;
        end
        else
        begin : notsame
            BUFG usrclk_pll_bufg (.O(userclk), .I(clkout1)); 
        end
    endgenerate
endmodule