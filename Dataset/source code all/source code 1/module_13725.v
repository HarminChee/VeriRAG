`timescale 1ns / 1ps
`define DLY #1
`timescale 1ns / 1ps
`define DLY #1
module srio_gen2_0_TX_STARTUP_FSM  #
   (
      parameter     STABLE_CLOCK_PERIOD      = 8,        
      parameter     RETRY_COUNTER_BITWIDTH   = 8, 
      parameter     EXAMPLE_SIMULATION       = 0, 
      parameter     TX_QPLL_USED             = "FALSE",  
      parameter     RX_QPLL_USED             = "FALSE",  
      parameter     PHASE_ALIGNMENT_MANUAL   = "TRUE"    
   )
   (    
      input  wire      STABLE_CLOCK,             
      input  wire      TXUSERCLK,                
      input  wire      SOFT_RESET,               
      input  wire      QPLLREFCLKLOST,           
      input  wire      CPLLREFCLKLOST,           
      input  wire      QPLLLOCK,                 
      input  wire      CPLLLOCK ,                
      input  wire      TXRESETDONE,            
      input  wire      MMCM_LOCK,              
      output           GTTXRESET,              
      output reg       MMCM_RESET = 1'b1,             
      output reg       QPLL_RESET = 1'b0,        
      output reg       CPLL_RESET = 1'b0,        
      output           TX_FSM_RESET_DONE,        
      output reg       TXUSERRDY = 1'b0 ,        
      output           RUN_PHALIGNMENT,  
      output reg       RESET_PHALIGNMENT = 1'b0,
      input  wire      PHALIGNMENT_DONE, 
      output [RETRY_COUNTER_BITWIDTH-1:0] RETRY_COUNTER 
   );
   localparam [3:0] 
               INIT = 4'b0000,
               ASSERT_ALL_RESETS = 4'b0001,
               WAIT_FOR_PLL_LOCK = 4'b0010,
               RELEASE_PLL_RESET = 4'b0011,
               WAIT_FOR_TXOUTCLK = 4'b0100,
               RELEASE_MMCM_RESET = 4'b0101,
               WAIT_FOR_TXUSRCLK = 4'b0110,
               WAIT_RESET_DONE = 4'b0111,
               DO_PHASE_ALIGNMENT = 4'b1000,
               RESET_FSM_DONE = 4'b1001;
  reg [3:0] tx_state = INIT;
  localparam integer MMCM_LOCK_CNT_MAX = 1024;
  localparam integer STARTUP_DELAY    = 500;
  localparam integer WAIT_CYCLES      = STARTUP_DELAY / STABLE_CLOCK_PERIOD; 
  localparam integer WAIT_MAX         = WAIT_CYCLES + 10;                    
  localparam integer WAIT_TIMEOUT_2ms   = 2000000 / STABLE_CLOCK_PERIOD;
  localparam integer WAIT_TLOCK_MAX     =  100000 / STABLE_CLOCK_PERIOD;
  localparam integer WAIT_TIMEOUT_500us =  500000 / STABLE_CLOCK_PERIOD;
  localparam integer WAIT_1us_CYCLES =  1000 / STABLE_CLOCK_PERIOD;
  localparam integer WAIT_1us =  WAIT_1us_CYCLES+10; 
  localparam integer WAIT_TIME_MAX   = EXAMPLE_SIMULATION? 100 : 10000 / STABLE_CLOCK_PERIOD;
  reg [7:0] init_wait_count = 0;
  reg       init_wait_done = 1'b0;
  reg       pll_reset_asserted = 1'b0;
  reg       tx_fsm_reset_done_int    = 1'b0;
  wire      tx_fsm_reset_done_int_s2;
  reg       tx_fsm_reset_done_int_s3 = 1'b0;
  localparam integer MAX_RETRIES          = 2**RETRY_COUNTER_BITWIDTH-1; 
  reg [7:0] retry_counter_int = 0;
  reg [18:0] time_out_counter = 0;
  reg      reset_time_out = 1'b0;
  reg      time_out_2ms   = 1'b0;  
  reg      time_tlock_max = 1'b0;  
  reg      time_out_500us = 1'b0;  
  reg [9:0] mmcm_lock_count = 0;
  reg       mmcm_lock_int = 1'b0;
  wire      mmcm_lock_i;
  reg       mmcm_lock_reclocked = 1'b0;
  reg       run_phase_alignment_int = 1'b0;
  wire      run_phase_alignment_int_s2;
  reg       run_phase_alignment_int_s3 = 1'b0;
  localparam integer MAX_WAIT_BYPASS      = 86784;
  reg [16:0] wait_bypass_count = 0;
  reg       time_out_wait_bypass    = 1'b0;
  wire      time_out_wait_bypass_s2;
  reg       time_out_wait_bypass_s3 = 1'b0;
  wire      txresetdone_s2;
  reg       txresetdone_s3 = 1'b0;
  reg       gttxreset_i = 1'b0;
  reg       txpmaresetdone_i = 1'b0;
  wire      txpmaresetdone_sync;
  wire      refclk_lost;
  wire      cplllock_sync;
  wire      qplllock_sync;
  reg   [15:0] wait_time_cnt;
  wire  wait_time_done;      
 assign RETRY_COUNTER     = retry_counter_int;
 assign RUN_PHALIGNMENT   = run_phase_alignment_int;
 assign TX_FSM_RESET_DONE = tx_fsm_reset_done_int;
 assign GTTXRESET = gttxreset_i;
  always @(posedge STABLE_CLOCK or posedge SOFT_RESET)
  begin
     if(SOFT_RESET)
      begin
          init_wait_count <= `DLY 8'h0;
          init_wait_done  <= `DLY 1'b0;
      end
      else if (init_wait_count == WAIT_MAX) 
          init_wait_done <= `DLY  1'b1;
      else
        init_wait_count <= `DLY  init_wait_count + 1;
   end 
  always @(posedge STABLE_CLOCK)
  begin
      if (reset_time_out == 1'b1)
      begin
        time_out_counter  <= `DLY  0;
        time_out_2ms      <= `DLY  1'b0;
        time_tlock_max    <= `DLY  1'b0;
        time_out_500us    <= `DLY  1'b0;
      end
      else
      begin
        if (time_out_counter == WAIT_TIMEOUT_2ms) 
          time_out_2ms <= `DLY  1'b1;
        else
          time_out_counter <= `DLY  time_out_counter + 1;
        if (time_out_counter == WAIT_TLOCK_MAX)
          time_tlock_max <= `DLY  1'b1;
        if (time_out_counter == WAIT_TIMEOUT_500us)
          time_out_500us <= `DLY  1'b1;
      end
  end 
  always @(posedge STABLE_CLOCK)
  begin
      if (mmcm_lock_i == 1'b0)
      begin
        mmcm_lock_count <= `DLY  0;
        mmcm_lock_reclocked   <= `DLY  1'b0;
      end
      else
      begin 
        if (mmcm_lock_count < MMCM_LOCK_CNT_MAX - 1)
          mmcm_lock_count <= `DLY  mmcm_lock_count + 1;
        else
          mmcm_lock_reclocked <= `DLY  1'b1;
      end
  end
 srio_gen2_0_sync_block sync_run_phase_alignment_int 
        (
           .clk             (TXUSERCLK),
           .data_in         (run_phase_alignment_int),
           .data_out        (run_phase_alignment_int_s2)
        );
 srio_gen2_0_sync_block sync_tx_fsm_reset_done_int 
        (
           .clk             (TXUSERCLK),
           .data_in         (tx_fsm_reset_done_int),
           .data_out        (tx_fsm_reset_done_int_s2)
        );
  always @(posedge TXUSERCLK)
  begin
     run_phase_alignment_int_s3 <= `DLY run_phase_alignment_int_s2;
     tx_fsm_reset_done_int_s3   <= `DLY tx_fsm_reset_done_int_s2;
  end
srio_gen2_0_sync_block sync_time_out_wait_bypass 
        (
           .clk             (STABLE_CLOCK),
           .data_in         (time_out_wait_bypass),
           .data_out        (time_out_wait_bypass_s2)
        );
 srio_gen2_0_sync_block sync_TXRESETDONE 
        (
           .clk             (STABLE_CLOCK),
           .data_in         (TXRESETDONE),
           .data_out        (txresetdone_s2)
        );
 srio_gen2_0_sync_block sync_mmcm_lock_reclocked
        (
           .clk             (STABLE_CLOCK),
           .data_in         (MMCM_LOCK),
           .data_out        (mmcm_lock_i)
        );
 srio_gen2_0_sync_block sync_cplllock
        (
           .clk             (STABLE_CLOCK),
           .data_in         (CPLLLOCK),
           .data_out        (cplllock_sync)
        );
 srio_gen2_0_sync_block sync_qplllock
        (
           .clk             (STABLE_CLOCK),
           .data_in         (QPLLLOCK),
           .data_out        (qplllock_sync)
        );
  always @(posedge STABLE_CLOCK)
  begin
     time_out_wait_bypass_s3   <= `DLY time_out_wait_bypass_s2;
     txresetdone_s3            <= `DLY txresetdone_s2;
  end
  always @(posedge TXUSERCLK)
  begin
      if (run_phase_alignment_int_s3 == 1'b0)
      begin
        wait_bypass_count     <= `DLY  0;
        time_out_wait_bypass  <= `DLY  1'b0;
      end
      else if (run_phase_alignment_int_s3 == 1'b1 && tx_fsm_reset_done_int_s3 == 1'b0)
      begin
        if (wait_bypass_count == MAX_WAIT_BYPASS - 1)
          time_out_wait_bypass <= `DLY  1'b1;
        else
          wait_bypass_count <= `DLY  wait_bypass_count + 1;
      end
  end
  assign refclk_lost = ( TX_QPLL_USED == "TRUE"  && QPLLREFCLKLOST == 1'b1) ? 1'b1 : 
                       ( TX_QPLL_USED == "FALSE" && CPLLREFCLKLOST == 1'b1) ? 1'b1 : 1'b0;
  always @(posedge STABLE_CLOCK )
  begin
    if((tx_state == ASSERT_ALL_RESETS) |
       (tx_state == RELEASE_PLL_RESET) | 
       (tx_state == RELEASE_MMCM_RESET))
    begin
        wait_time_cnt <= `DLY WAIT_TIME_MAX;
    end else if (wait_time_cnt != 16'h0)
    begin
        wait_time_cnt <= wait_time_cnt - 16'h1;
    end
  end
  assign wait_time_done = (wait_time_cnt == 16'h0);
  always @(posedge STABLE_CLOCK)
  begin
      if (SOFT_RESET == 1'b1)
      begin
        tx_state                <= `DLY  INIT;
        TXUSERRDY               <= `DLY  1'b0;
        gttxreset_i             <= `DLY  1'b0;
        MMCM_RESET              <= `DLY  1'b0;
        tx_fsm_reset_done_int   <= `DLY  1'b0;
        QPLL_RESET              <= `DLY  1'b0;
        CPLL_RESET              <= `DLY  1'b0;
        pll_reset_asserted      <= `DLY  1'b0;
        reset_time_out          <= `DLY  1'b0;
        retry_counter_int       <= `DLY   0;
        run_phase_alignment_int <= `DLY  1'b0;
        RESET_PHALIGNMENT       <= `DLY  1'b1;
      end
      else
      begin 
        case (tx_state)
           INIT :
           begin 
            if (init_wait_done == 1'b1)
              tx_state           <= `DLY  ASSERT_ALL_RESETS;
              reset_time_out     <= `DLY  1'b1;
           end 
           ASSERT_ALL_RESETS :
           begin 
            if (TX_QPLL_USED == "TRUE") 
            begin
              if (pll_reset_asserted == 1'b0)
              begin
                QPLL_RESET          <= `DLY  1'b1;
                pll_reset_asserted  <= `DLY  1'b1;
              end
              else
                QPLL_RESET          <= `DLY  1'b0;
            end
            else
            begin
              if (pll_reset_asserted == 1'b0)
              begin
                CPLL_RESET <= `DLY  1'b1;
                pll_reset_asserted  <= `DLY  1'b1;
              end
              else
                CPLL_RESET          <= `DLY  1'b0;
            end
            TXUSERRDY               <= `DLY  1'b0;
            gttxreset_i             <= `DLY  1'b1;
            MMCM_RESET              <= `DLY  1'b1;
            reset_time_out          <= `DLY  1'b1;
            run_phase_alignment_int <= `DLY  1'b0;     
            RESET_PHALIGNMENT       <= `DLY  1'b1;
            if ((TX_QPLL_USED == "TRUE" && qplllock_sync == 1'b0 && pll_reset_asserted ) ||
               (TX_QPLL_USED == "FALSE" && cplllock_sync == 1'b0 && pll_reset_asserted )) 
              tx_state  <= `DLY  WAIT_FOR_PLL_LOCK; 
           end           
           WAIT_FOR_PLL_LOCK :
           begin
              if(wait_time_done)
                 tx_state        <= `DLY RELEASE_PLL_RESET;  
           end        
           RELEASE_PLL_RESET :
           begin 
            pll_reset_asserted  <= `DLY  1'b0;
            reset_time_out  <= `DLY  1'b0;
            if ((TX_QPLL_USED == "TRUE" && qplllock_sync == 1'b1) ||
               (TX_QPLL_USED == "FALSE" && cplllock_sync == 1'b1)) 
           begin
              tx_state  <= `DLY  WAIT_FOR_TXOUTCLK;
              reset_time_out  <= `DLY  1'b1;
           end
            if (time_out_2ms == 1'b1)
            begin
                if (retry_counter_int == MAX_RETRIES) 
                retry_counter_int <= `DLY  0;
                else
                retry_counter_int <= `DLY  retry_counter_int + 1;
              tx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end
           end           
           WAIT_FOR_TXOUTCLK :
           begin
            gttxreset_i <= `DLY  1'b0;
              if(wait_time_done)
               tx_state <= `DLY RELEASE_MMCM_RESET;  
           end       
           RELEASE_MMCM_RESET :
           begin 
            MMCM_RESET <= `DLY  1'b0;
            reset_time_out  <= `DLY  1'b0;
            if (mmcm_lock_reclocked == 1'b1)
            begin
              tx_state <= `DLY  WAIT_FOR_TXUSRCLK;
              reset_time_out  <= `DLY  1'b1;
            end
            if (time_tlock_max == 1'b1 && mmcm_lock_reclocked == 1'b0 && reset_time_out == 1'b0)
            begin
              if (retry_counter_int == MAX_RETRIES)
                retry_counter_int <= `DLY  0;
              else
                retry_counter_int <= `DLY  retry_counter_int + 1;
              tx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end
           end            
           WAIT_FOR_TXUSRCLK :
           begin
              if(wait_time_done)
               tx_state <= `DLY WAIT_RESET_DONE;  
           end            
           WAIT_RESET_DONE :
           begin 
            TXUSERRDY   <= `DLY  1'b1;
            reset_time_out  <= `DLY  1'b0;
            if (txresetdone_s3 == 1'b1)
            begin              
              tx_state      <= `DLY  DO_PHASE_ALIGNMENT;               
              reset_time_out  <= `DLY  1'b1;
            end          
            if (time_out_500us == 1'b1 && reset_time_out == 1'b0)
            begin
              if (retry_counter_int == MAX_RETRIES) 
                retry_counter_int <= `DLY  0;
              else
                retry_counter_int <= `DLY  retry_counter_int + 1;
              tx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end 
           end            
           DO_PHASE_ALIGNMENT :
           begin 
            RESET_PHALIGNMENT       <= `DLY  1'b0;
            run_phase_alignment_int <= `DLY  1'b1;
            reset_time_out          <= `DLY  1'b0;
            if (PHALIGNMENT_DONE == 1'b1)
              tx_state        <= `DLY  RESET_FSM_DONE;
            if (time_out_wait_bypass_s3 == 1'b1)
            begin
              if (retry_counter_int == MAX_RETRIES) 
                retry_counter_int <= `DLY  0;
              else
                retry_counter_int <= `DLY   retry_counter_int + 1;
              tx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end           
           end
           RESET_FSM_DONE :
           begin 
            reset_time_out        <= `DLY  1'b1;
            tx_fsm_reset_done_int <= `DLY  1'b1;
           end
           default:
              tx_state            <= `DLY  INIT; 
        endcase
      end
    end
endmodule
