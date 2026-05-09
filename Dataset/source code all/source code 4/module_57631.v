`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_pd #
  (
   parameter TCQ             = 100,
   parameter SIM_CAL_OPTION  = "NONE", 
   parameter PD_LHC_WIDTH    = 16      
   )
  (
   output [99:0] dbg_pd,              
   input [4:0]   dqs_dly_val_in,
   output [4:0]  dqs_dly_val,
   output reg    pd_en_maintain,      
   output reg    pd_incdec_maintain,  
   output        pd_cal_done,         
   input         pd_cal_start,        
   input         dfi_init_complete,
   input         pd_read_valid,       
   input [1:0]   trip_points,         
   input         dbg_pd_off,
   input         dbg_pd_maintain_off,
   input         dbg_pd_inc_cpt,      
   input         dbg_pd_dec_cpt,      
   input         dbg_pd_inc_dqs,      
   input         dbg_pd_dec_dqs,      
   input         dbg_pd_disab_hyst,
   input [3:0]   dbg_pd_msb_sel,      
   input         clk,                 
   input         rst                  
   );
  localparam FAST_SIM  = ((SIM_CAL_OPTION == "FAST_CAL") | (SIM_CAL_OPTION == "FAST_WIN_DETECT")) ? "YES" : "NO";
  localparam LHC_WIDTH    = (FAST_SIM == "YES") ? 6 : PD_LHC_WIDTH;
  localparam CDC_WIDTH   = (FAST_SIM == "YES") ? 3 : 6;
  localparam RVPLS_WIDTH = 1; 
  wire                  pd_en_maintain_d;
  wire                  pd_incdec_maintain_d;
  wire [LHC_WIDTH-1:0]  low_d;
  wire [LHC_WIDTH-1:0]  high_d;
  reg                   ld_dqs_dly_val_r;    
  reg  [4:0]            dqs_dly_val_r;
  wire                  pd_cal_done_i;       
  reg                   first_calib_sample;
  reg                   rev_direction;
  wire                  rev_direction_ce;
  wire                  pd_en_calib;         
  wire                  pd_incdec_calib;     
  reg                   pd_en;
  wire                  pd_incdec;
  reg                   reset;               
  reg [2:0]             pd_state_r;
  reg [2:0]             pd_next_state;       
  reg [LHC_WIDTH-1:0]   low;                 
  reg [LHC_WIDTH-1:0]   high;                
  wire                  samples_done;
  reg [2:0]             samples_done_pl;
  wire                  inc_cntrs;
  wire                  clr_low_high;
  wire                  low_high_ce;
  wire                  update_phase;
  reg [CDC_WIDTH-1:0]   calib_done_cntr;
  wire                  calib_done_cntr_inc;
  wire                  calib_done_cntr_ce;
  wire                  high_ge_low;
  reg [1:0]             l_addend;
  reg [1:0]             h_addend;
  wire                  read_valid_pl;
  wire                  enab_maintenance;
  reg [3:0]             pd_done_state_r;
  reg [3:0]             pd_done_next_state;
  reg                   pd_incdec_done;      
  reg                   pd_incdec_done_next; 
  wire                  block_change;
  reg                   low_nearly_done;
  reg                   high_nearly_done;
  reg                   low_done;
  reg                   high_done;
  wire [3:0]            hyst_mux_sel;
  wire [3:0]            mux_sel;
  reg                   low_mux;             
  reg                   high_mux;            
  reg                   low_nearly_done_r;
  reg                   high_nearly_done_r;
  assign mux_sel = pd_cal_done_i ? 
                   ((FAST_SIM == "YES") ? (LHC_WIDTH-1) : dbg_pd_msb_sel) :
                   (LHC_WIDTH-1); 
  always @(mux_sel or low)  low_mux  = low[mux_sel];
  always @(mux_sel or high) high_mux = high[mux_sel];
  always @(posedge clk)
  begin
    if (clr_low_high)
    begin
      low_done  <= #TCQ 1'b0;
      high_done <= #TCQ 1'b0;
    end
    else
    begin
      low_done  <= #TCQ low_mux;
      high_done <= #TCQ high_mux;
    end
  end
  assign hyst_mux_sel = (FAST_SIM == "YES") ? 
                        (LHC_WIDTH-2) : dbg_pd_msb_sel - 1;
  always @(hyst_mux_sel or low)  low_nearly_done  = low[hyst_mux_sel];
  always @(hyst_mux_sel or high) high_nearly_done = high[hyst_mux_sel];
  always @(posedge clk) 
  begin
    if (reset | (dbg_pd_disab_hyst))
    begin
      low_nearly_done_r  <= #TCQ 1'b0;
      high_nearly_done_r <= #TCQ 1'b0;
    end
    else
    begin
      low_nearly_done_r  <= #TCQ low_nearly_done;
      high_nearly_done_r <= #TCQ high_nearly_done;
    end
  end
  assign block_change = ((high_done & low_done)
                      | (high_done ? low_nearly_done_r : high_nearly_done_r));
  assign samples_done = (low_done | high_done) & ~clr_low_high;  
  assign high_ge_low  = high_done;
  reg pd_incdec_tp;     
  always @(posedge clk)
    if (reset)     pd_incdec_tp <= #TCQ 1'b0;
    else if(pd_en) pd_incdec_tp <= #TCQ pd_incdec;
  assign dbg_pd[0]     = pd_en;
  assign dbg_pd[1]     = pd_incdec;
  assign dbg_pd[2]     = pd_cal_done_i;
  assign dbg_pd[3]     = pd_cal_start;
  assign dbg_pd[4]     = samples_done;
  assign dbg_pd[5]     = inc_cntrs;
  assign dbg_pd[6]     = clr_low_high;
  assign dbg_pd[7]     = low_high_ce;
  assign dbg_pd[8]     = update_phase;
  assign dbg_pd[9]     = calib_done_cntr_inc;
  assign dbg_pd[10]    = calib_done_cntr_ce;
  assign dbg_pd[11]    = first_calib_sample;
  assign dbg_pd[12]    = rev_direction;
  assign dbg_pd[13]    = rev_direction_ce;
  assign dbg_pd[14]    = pd_en_calib;
  assign dbg_pd[15]    = pd_incdec_calib;
  assign dbg_pd[16]    = read_valid_pl;
  assign dbg_pd[17]    = pd_read_valid;
  assign dbg_pd[18]    = pd_incdec_tp;
  assign dbg_pd[19]    = block_change;
  assign dbg_pd[20]    = low_nearly_done_r;
  assign dbg_pd[21]    = high_nearly_done_r;
  assign dbg_pd[23:22] = 'b0;                                    
  assign dbg_pd[29:24] = {1'b0, dqs_dly_val_r};                  
  assign dbg_pd[33:30] = {1'b0, pd_state_r};                     
  assign dbg_pd[37:34] = {1'b0, pd_next_state};                  
  assign dbg_pd[53:38] =  high;                                  
  assign dbg_pd[69:54] = low;                                    
  assign dbg_pd[73:70] = pd_done_state_r;
  assign dbg_pd[81:74] = {{8-CDC_WIDTH{1'b0}}, calib_done_cntr}; 
  assign dbg_pd[83:82] = l_addend;
  assign dbg_pd[85:84] = h_addend;
  assign dbg_pd[87:86] = trip_points;
  assign dbg_pd[99:88] = 'b0;                                    
  generate
    begin: gen_rvpls
      if(RVPLS_WIDTH == 0)
      begin
        assign read_valid_pl = pd_read_valid;
      end
      else if(RVPLS_WIDTH == 1)
      begin
        reg [RVPLS_WIDTH-1:0] read_valid_shftr;
        always @(posedge clk)
        if (reset) read_valid_shftr <= #TCQ 'b0;
        else       read_valid_shftr <= #TCQ pd_read_valid;
        assign read_valid_pl = read_valid_shftr[RVPLS_WIDTH-1];
      end
      else
      begin
        reg [RVPLS_WIDTH-1:0] read_valid_shftr;
        always @(posedge clk)
        if (reset) read_valid_shftr <= #TCQ 'b0;
        else       read_valid_shftr <= #TCQ {read_valid_shftr[RVPLS_WIDTH-2:0], pd_read_valid};
        assign read_valid_pl = read_valid_shftr[RVPLS_WIDTH-1];
      end
    end
  endgenerate
  always @(posedge clk)
    if (reset) pd_en <= #TCQ 1'b0;
    else       pd_en <= #TCQ update_phase;
  assign pd_incdec = high_ge_low;
  assign rev_direction_ce = first_calib_sample & pd_en & (pd_incdec ~^ dqs_dly_val_r[4]);
  always @(posedge clk)
  begin
    if (reset)
    begin
      first_calib_sample <= #TCQ 1'b1;
      rev_direction      <= #TCQ 1'b0;
    end
    else
    begin
      if(pd_en)            first_calib_sample <= #TCQ 1'b0;
      if(rev_direction_ce) rev_direction      <= #TCQ 1'b1;
    end
  end
  assign pd_en_calib          = (pd_en & ~pd_cal_done_i & ~first_calib_sample) | dbg_pd_inc_dqs | dbg_pd_dec_dqs;
  assign pd_incdec_calib      = (pd_incdec ^ rev_direction) | dbg_pd_inc_dqs;
  assign enab_maintenance     = dfi_init_complete & ~dbg_pd_maintain_off;
  assign pd_en_maintain_d     = (pd_en &  pd_cal_done_i & enab_maintenance & ~block_change) | dbg_pd_inc_cpt | dbg_pd_dec_cpt;
  assign pd_incdec_maintain_d = (~pd_incdec_calib | dbg_pd_inc_cpt) & ~dbg_pd_dec_cpt;
  always @(posedge clk)  
  begin
    if (reset)
    begin
      pd_en_maintain     <= #TCQ 1'b0;
      pd_incdec_maintain <= #TCQ 1'b0;
    end
    else
    begin
      pd_en_maintain     <= #TCQ pd_en_maintain_d;
      pd_incdec_maintain <= #TCQ pd_incdec_maintain_d;
    end
  end
  always @(posedge clk)
  begin
    if (rst)
    begin
      dqs_dly_val_r <= #TCQ 5'b0_0000;
    end
    else if(ld_dqs_dly_val_r)
    begin
      dqs_dly_val_r <= #TCQ dqs_dly_val_in;
    end
    else
    begin
      if(pd_en_calib)
      begin
        if(pd_incdec_calib) dqs_dly_val_r <= #TCQ dqs_dly_val_r + 1;
        else                dqs_dly_val_r <= #TCQ dqs_dly_val_r - 1;
      end
    end
  end
  assign dqs_dly_val = dqs_dly_val_r;
  always @(posedge clk or posedge rst)
    if (rst) reset <= #TCQ 1'b1;
    else     reset <= #TCQ 1'b0;
  localparam PD_IDLE         = 3'h0;
  localparam PD_CLR_CNTRS    = 3'h1;
  localparam PD_INC_CNTRS    = 3'h2;
  localparam PD_UPDATE       = 3'h3;
  localparam PD_WAIT         = 3'h4;
  always @(posedge clk)
    if (reset) pd_state_r <= #TCQ 'b0;
    else       pd_state_r <= #TCQ pd_next_state;
  always @(pd_state_r or pd_cal_start or dbg_pd_off or samples_done_pl[2] or pd_incdec_done)
  begin
    pd_next_state    = PD_IDLE; 
    ld_dqs_dly_val_r = 1'b0;
    case (pd_state_r)
      PD_IDLE         : begin 
                          if(pd_cal_start)
                          begin
                            pd_next_state    = PD_CLR_CNTRS;
                            ld_dqs_dly_val_r = 1'b1;
                          end
                        end
      PD_CLR_CNTRS    : begin 
                          if(~dbg_pd_off) pd_next_state = PD_INC_CNTRS;
                          else            pd_next_state = PD_CLR_CNTRS;
                        end
      PD_INC_CNTRS    : begin 
                          if(samples_done_pl[2]) pd_next_state = PD_UPDATE;
                          else                   pd_next_state = PD_INC_CNTRS;
                        end
      PD_UPDATE       : begin 
                          pd_next_state = PD_WAIT;
                        end
      PD_WAIT         : begin 
                          if(pd_incdec_done) pd_next_state = PD_CLR_CNTRS;
                          else               pd_next_state = PD_WAIT;
                        end
    endcase
  end
  assign inc_cntrs    = (pd_state_r == PD_INC_CNTRS) & read_valid_pl & ~samples_done;
  assign clr_low_high = reset | (pd_state_r == PD_CLR_CNTRS);
  assign low_high_ce  = inc_cntrs;
  assign update_phase = (pd_state_r == PD_UPDATE);
  assign calib_done_cntr_inc = high_ge_low ~^ calib_done_cntr[0];
  assign calib_done_cntr_ce  = update_phase & ~calib_done_cntr[CDC_WIDTH-1] & ~first_calib_sample;
  always @(posedge clk)
    if (reset)                  calib_done_cntr <= #TCQ 'b0;
    else if(calib_done_cntr_ce) calib_done_cntr <= #TCQ calib_done_cntr + calib_done_cntr_inc;
  assign pd_cal_done_i = calib_done_cntr[CDC_WIDTH-1] | dbg_pd_off;
  assign pd_cal_done   = pd_cal_done_i;
  always @(posedge clk)
  begin
    if (reset)
    begin
      l_addend <= #TCQ 'b0;
      h_addend <= #TCQ 'b0;
    end
    else
    begin
      l_addend <= #TCQ {~trip_points[1] & ~trip_points[0], trip_points[1] ^ trip_points[0]};
      h_addend <= #TCQ { trip_points[1] &  trip_points[0], trip_points[1] ^ trip_points[0]};
    end
  end
  assign low_d = low + {{LHC_WIDTH-2{1'b0}}, l_addend};
  always @(posedge clk)
    if (clr_low_high)    low <= #TCQ 'b0;
    else if(low_high_ce) low <= #TCQ low_d;
  assign high_d = high + {{LHC_WIDTH-2{1'b0}}, h_addend};
  always @(posedge clk)
    if (clr_low_high)    high <= #TCQ 'b0;
    else if(low_high_ce) high <= #TCQ high_d;
  always @(posedge clk)
    if (reset) samples_done_pl <= #TCQ 'b0;
    else       samples_done_pl <= #TCQ {samples_done_pl[1] & samples_done,
                                        samples_done_pl[0] & samples_done, samples_done};
  localparam PD_DONE_IDLE    = 4'd0;
  localparam PD_DONE_MAX     = 4'd10;
  always @(posedge clk)
  begin
    if (reset)
    begin
      pd_done_state_r <= #TCQ  'b0;
      pd_incdec_done  <= #TCQ 1'b0;
    end
    else
    begin
      pd_done_state_r <= #TCQ pd_done_next_state;
      pd_incdec_done  <= #TCQ pd_incdec_done_next;
    end
  end
  always @(pd_done_state_r or pd_en)
  begin
    pd_done_next_state  = pd_done_state_r + 1; 
    pd_incdec_done_next = 1'b0;                
    case (pd_done_state_r)
      PD_DONE_IDLE : begin 
                       if(~pd_en) pd_done_next_state = PD_DONE_IDLE;
                     end
      PD_DONE_MAX  : begin 
                       pd_done_next_state  = PD_DONE_IDLE;
                       pd_incdec_done_next = 1'b1;
                     end
    endcase
  end
endmodule
