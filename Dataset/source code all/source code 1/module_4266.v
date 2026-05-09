`timescale 1ns / 1ps
`define DLY #1
`timescale 1ns / 1ps
`define DLY #1
module srio_gen2_0_RX_STARTUP_FSM #
   (
       parameter     EXAMPLE_SIMULATION      = 0,          
       parameter     EQ_MODE                 = "DFE",       
       parameter     STABLE_CLOCK_PERIOD     = 8,           
       parameter     RETRY_COUNTER_BITWIDTH  = 8, 
       parameter     TX_QPLL_USED            = "FALSE",     
       parameter     RX_QPLL_USED            = "FALSE",     
       parameter     PHASE_ALIGNMENT_MANUAL  = "TRUE"       
   )
   ( 
       input       wire     STABLE_CLOCK,     
       input       wire     RXUSERCLK,        
       input       wire     SOFT_RESET,       
       input       wire     QPLLREFCLKLOST,   
       input       wire     CPLLREFCLKLOST,   
       input       wire     QPLLLOCK,         
       input       wire     CPLLLOCK,         
       input       wire     RXRESETDONE,
       input       wire     MMCM_LOCK,
       input       wire     RECCLK_STABLE,
       input       wire     RECCLK_MONITOR_RESTART,
       input       wire     DATA_VALID,
       input       wire     TXUSERRDY,                
       input       wire     DONT_RESET_ON_DATA_ERROR, 
       output            GTRXRESET ,
       output            MMCM_RESET ,
       output      reg      QPLL_RESET = 1'b0,        
       output      reg      CPLL_RESET = 1'b0,        
       output               RX_FSM_RESET_DONE,        
       output      reg      RXUSERRDY = 1'b0,
       output      wire     RUN_PHALIGNMENT,
       input       wire     PHALIGNMENT_DONE,
       output      reg      RESET_PHALIGNMENT = 1'b0,           
       output      reg      RXDFEAGCHOLD  = 1'b0,
       output      reg      RXDFELFHOLD  = 1'b0,
       output      reg      RXLPMLFHOLD  = 1'b0,
       output      reg      RXLPMHFHOLD  = 1'b0,
       output      wire     [RETRY_COUNTER_BITWIDTH-1:0] RETRY_COUNTER 
       ); 
  localparam [3:0] 
             INIT                 = 4'b0000,
             ASSERT_ALL_RESETS    = 4'b0001,
             WAIT_FOR_PLL_LOCK    = 4'b0010,
             RELEASE_PLL_RESET    = 4'b0011,
             VERIFY_RECCLK_STABLE = 4'b0100,
             RELEASE_MMCM_RESET   = 4'b0101,
             WAIT_FOR_RXUSRCLK    = 4'b0110,
             WAIT_RESET_DONE      = 4'b0111,
             DO_PHASE_ALIGNMENT   = 4'b1000,
             MONITOR_DATA_VALID   = 4'b1001,
             FSM_DONE             = 4'b1010;
  reg [3:0] rx_state = INIT;
  function [12:0] get_max_wait_bypass;
    input manual_mode;
    reg [12:0] max_wait_cnt;
  begin
    if (manual_mode == "TRUE") 
      max_wait_cnt = 5000;
    else
      max_wait_cnt = 3100;
    get_max_wait_bypass = max_wait_cnt;
  end
  endfunction
  localparam integer MMCM_LOCK_CNT_MAX = 1024;
  localparam integer STARTUP_DELAY = 500;
  localparam integer WAIT_CYCLES = STARTUP_DELAY / STABLE_CLOCK_PERIOD; 
  localparam integer WAIT_MAX = WAIT_CYCLES + 10;                       
  localparam integer WAIT_TIMEOUT_2ms   = 2000000 / STABLE_CLOCK_PERIOD;  
  localparam integer WAIT_TLOCK_MAX     = 100000 / STABLE_CLOCK_PERIOD;   
  localparam integer WAIT_TIMEOUT_500us = 500000 / STABLE_CLOCK_PERIOD;   
  localparam integer WAIT_TIMEOUT_1us   = 1000 / STABLE_CLOCK_PERIOD;     
  localparam integer WAIT_TIMEOUT_100us = 100000 / STABLE_CLOCK_PERIOD;   
  integer    WAIT_TIME_ADAPT    = (37000000 /1.25)/STABLE_CLOCK_PERIOD;
  localparam integer WAIT_TIME_MAX   = EXAMPLE_SIMULATION? 100 : 10000 / STABLE_CLOCK_PERIOD;
  reg [7:0] init_wait_count = 0;
  reg       init_wait_done = 1'b0;
  reg       pll_reset_asserted = 1'b0;
  reg       rx_fsm_reset_done_int = 1'b0;
  wire      rx_fsm_reset_done_int_s2;
  reg       rx_fsm_reset_done_int_s3 = 1'b0;
  localparam integer MAX_RETRIES = 2**RETRY_COUNTER_BITWIDTH-1; 
  reg [7:0]  retry_counter_int = 0;  
  reg [18:0] time_out_counter = 0;
  reg [1:0]  recclk_mon_restart_count = 0 ;
  reg        recclk_mon_count_reset = 0;
  reg        reset_time_out = 1'b0;
  reg        time_out_2ms = 1'b0;  
  reg        time_tlock_max = 1'b0; 
  reg        time_out_500us = 1'b0; 
  reg        time_out_1us = 1'b0;   
  reg        time_out_100us = 1'b0;  
  reg        check_tlock_max = 1'b0;
  reg [9:0]  mmcm_lock_count = 1'b0;
  reg        mmcm_lock_int = 1'b0;
  wire       mmcm_lock_i;
  reg        mmcm_lock_reclocked = 1'b0;
  reg       run_phase_alignment_int = 1'b0;
  wire      run_phase_alignment_int_s2;
  reg       run_phase_alignment_int_s3 = 1'b0;
  localparam integer MAX_WAIT_BYPASS = 5000;
  reg [12:0] wait_bypass_count = 0;
  reg        time_out_wait_bypass = 1'b0;
  wire       time_out_wait_bypass_s2;
  reg        time_out_wait_bypass_s3 = 1'b0;
  reg        gtrxreset_i = 1'b0;
  reg        mmcm_reset_i = 1'b1;
  reg        rxpmaresetdone_i = 1'b0;
  reg        txpmaresetdone_i = 1'b0;
  wire       refclk_lost;
  wire       rxpmaresetdone_sync;
  wire       txpmaresetdone_sync;
  wire       rxpmaresetdone_s;
  reg       rxpmaresetdone_ss = 1'b0;
  reg       pmaresetdone_fallingedge_detect = 1'b0;
  wire      rxresetdone_s2;
  reg       rxresetdone_s3 = 1'b0;
  wire      data_valid_sync;
  wire      cplllock_sync;
  wire      qplllock_sync;
  reg       cplllock_ris_edge = 1'b0;
  reg       qplllock_ris_edge = 1'b0;
  reg       cplllock_prev;
  reg       qplllock_prev;
  integer    adapt_count = 0;
  reg        time_out_adapt = 1'b0;
  reg        adapt_count_reset = 1'b0;
  reg   [15:0] wait_time_cnt;
  wire  wait_time_done; 
  assign    RETRY_COUNTER     = retry_counter_int;
  assign    RUN_PHALIGNMENT   = run_phase_alignment_int;
  assign    RX_FSM_RESET_DONE = rx_fsm_reset_done_int;
  assign    GTRXRESET = gtrxreset_i;
  assign    MMCM_RESET = mmcm_reset_i;
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
      if (recclk_mon_count_reset == 1)
        recclk_mon_restart_count <= `DLY  0;
      else if (RECCLK_MONITOR_RESTART == 1) 
      begin
        if (recclk_mon_restart_count == 3)
          recclk_mon_restart_count <= `DLY  0;
        else 
          recclk_mon_restart_count <= `DLY  recclk_mon_restart_count + 1;
      end
  end
generate
 if(EXAMPLE_SIMULATION == 1)
 begin
    always @(posedge STABLE_CLOCK)
    begin
        time_out_adapt <= `DLY  1'b1;
    end 
 end
 else
 begin
  always @(posedge STABLE_CLOCK)
  begin
      if (adapt_count_reset == 1'b1)
      begin
        adapt_count    <= `DLY  0;
        time_out_adapt <= `DLY  1'b0;
      end
      else 
      begin
        if (adapt_count == WAIT_TIME_ADAPT -1)
          time_out_adapt <= `DLY  1'b1;
        else 
          adapt_count <= `DLY  adapt_count + 1;
      end
  end
 end 
endgenerate
  always @(posedge STABLE_CLOCK)
  begin
      if (reset_time_out == 1)
      begin
        time_out_counter  <= `DLY  0;
        time_out_2ms      <= `DLY  1'b0;
        time_tlock_max    <= `DLY  1'b0;
        time_out_500us    <= `DLY  1'b0;
        time_out_1us      <= `DLY  1'b0;
        time_out_100us    <= `DLY  1'b0;
      end
      else
      begin
        if (time_out_counter == WAIT_TIMEOUT_2ms)
          time_out_2ms <= `DLY  1'b1;
        else
          time_out_counter <= `DLY  time_out_counter + 1;
        if (time_out_counter > WAIT_TLOCK_MAX && check_tlock_max == 1)
        begin
          time_tlock_max <= `DLY  1'b1;
        end
        if (time_out_counter == WAIT_TIMEOUT_500us)
        begin
          time_out_500us <= `DLY  1'b1;
        end
        if (time_out_counter == WAIT_TIMEOUT_1us)
        begin
          time_out_1us <= `DLY  1'b1;
        end
        if (time_out_counter == WAIT_TIMEOUT_100us)
        begin
          time_out_100us <= `DLY  1'b1;
        end
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
           .clk             (RXUSERCLK),
           .data_in         (run_phase_alignment_int),
           .data_out        (run_phase_alignment_int_s2)
        );
 srio_gen2_0_sync_block sync_rx_fsm_reset_done_int 
        (
           .clk             (RXUSERCLK),
           .data_in         (rx_fsm_reset_done_int),
           .data_out        (rx_fsm_reset_done_int_s2)
        );
  always @(posedge RXUSERCLK)
  begin
     run_phase_alignment_int_s3 <= `DLY run_phase_alignment_int_s2;
     rx_fsm_reset_done_int_s3   <= `DLY rx_fsm_reset_done_int_s2;
  end
srio_gen2_0_sync_block sync_time_out_wait_bypass 
        (
           .clk             (STABLE_CLOCK),
           .data_in         (time_out_wait_bypass),
           .data_out        (time_out_wait_bypass_s2)
        );
 srio_gen2_0_sync_block sync_RXRESETDONE 
        (
           .clk             (STABLE_CLOCK),
           .data_in         (RXRESETDONE),
           .data_out        (rxresetdone_s2)
        );
 srio_gen2_0_sync_block sync_mmcm_lock_reclocked
        (
           .clk             (STABLE_CLOCK),
           .data_in         (MMCM_LOCK),
           .data_out        (mmcm_lock_i)
        );
 srio_gen2_0_sync_block sync_data_valid
        (
           .clk             (STABLE_CLOCK),
           .data_in         (DATA_VALID),
           .data_out        (data_valid_sync)
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
     rxresetdone_s3            <= `DLY rxresetdone_s2;
  end
  always @(posedge RXUSERCLK)
  begin
      if (run_phase_alignment_int_s3 == 1'b0)
      begin 
        wait_bypass_count     <= `DLY  0;
        time_out_wait_bypass  <= `DLY  1'b0;
      end
      else if ((run_phase_alignment_int_s3 == 1'b1) && (rx_fsm_reset_done_int_s3 == 1'b0))
      begin
        if (wait_bypass_count == MAX_WAIT_BYPASS - 1)
          time_out_wait_bypass <= `DLY  1'b1;
        else
          wait_bypass_count <= `DLY  wait_bypass_count + 1;
      end
  end
  assign refclk_lost = ( RX_QPLL_USED == "TRUE"  && QPLLREFCLKLOST == 1'b1) ? 1'b1 : 
                       ( RX_QPLL_USED == "FALSE" && CPLLREFCLKLOST == 1'b1) ? 1'b1 : 1'b0;
  always @(posedge STABLE_CLOCK )
  begin
    if((rx_state == ASSERT_ALL_RESETS) |
       (rx_state == RELEASE_MMCM_RESET))
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
        rx_state                <= `DLY  INIT;
        RXUSERRDY               <= `DLY  1'b0;
        gtrxreset_i             <= `DLY  1'b0;
        mmcm_reset_i            <= `DLY  1'b0;
        rx_fsm_reset_done_int   <= `DLY  1'b0;
        QPLL_RESET              <= `DLY  1'b0;
        CPLL_RESET              <= `DLY  1'b0;
        pll_reset_asserted      <= `DLY  1'b0;
        reset_time_out          <= `DLY  1'b1;
        retry_counter_int       <= `DLY  0;
        run_phase_alignment_int <= `DLY  1'b0;
        check_tlock_max         <= `DLY  1'b0;
        RESET_PHALIGNMENT       <= `DLY  1'b1;
        recclk_mon_count_reset  <= `DLY  1'b1;
        adapt_count_reset       <= `DLY  1'b1;
        RXDFEAGCHOLD            <= `DLY  1'b0;
        RXDFELFHOLD             <= `DLY  1'b0;
        RXLPMLFHOLD             <= `DLY  1'b0;
        RXLPMHFHOLD             <= `DLY  1'b0;
      end
      else
      begin
        case (rx_state)
           INIT :
           begin 
            if (init_wait_done == 1'b1)
              rx_state  <= `DLY  ASSERT_ALL_RESETS;
           end
           ASSERT_ALL_RESETS :
           begin 
             if (RX_QPLL_USED == "TRUE" && TX_QPLL_USED == "FALSE")
             begin
              if (pll_reset_asserted == 1'b0)
              begin
                QPLL_RESET          <= `DLY  1'b1;
                pll_reset_asserted  <= `DLY  1'b1;
              end
              else
                QPLL_RESET          <= `DLY  1'b0;
             end 
            else if (RX_QPLL_USED == "FALSE" && TX_QPLL_USED == "TRUE")
            begin
              if (pll_reset_asserted == 1'b0)
              begin
                CPLL_RESET <= `DLY  1'b1;
                pll_reset_asserted  <= `DLY  1'b1;
              end
              else
                CPLL_RESET          <= `DLY  1'b0;
            end
            RXUSERRDY               <= `DLY  1'b0;
            gtrxreset_i             <= `DLY  1'b1;
            mmcm_reset_i            <= `DLY  1'b1;
            run_phase_alignment_int <= `DLY  1'b0;    
            RESET_PHALIGNMENT       <= `DLY  1'b1;
            check_tlock_max         <= `DLY  1'b0;
            recclk_mon_count_reset  <= `DLY  1'b1;
            adapt_count_reset       <= `DLY  1'b1;
            if ((RX_QPLL_USED == "TRUE" && TX_QPLL_USED == "FALSE"   && qplllock_sync == 1'b0 && pll_reset_asserted) ||
                (RX_QPLL_USED == "FALSE"&& TX_QPLL_USED == "TRUE"    && cplllock_sync == 1'b0 && pll_reset_asserted) ||
                (RX_QPLL_USED == "TRUE" && TX_QPLL_USED == "TRUE"   ) ||
                (RX_QPLL_USED == "FALSE"&& TX_QPLL_USED == "FALSE"  ) 
               ) 
           begin
              rx_state              <= `DLY  WAIT_FOR_PLL_LOCK;
              reset_time_out        <= `DLY  1'b1;
           end 
           end           
           WAIT_FOR_PLL_LOCK :
           begin
              if(wait_time_done)
                 rx_state        <= `DLY RELEASE_PLL_RESET;  
           end     
           RELEASE_PLL_RESET : 
           begin
            pll_reset_asserted  <= `DLY  1'b0;
            reset_time_out      <= `DLY  1'b0;
            if ((RX_QPLL_USED == "TRUE"  && TX_QPLL_USED == "FALSE" && qplllock_sync == 1'b1) ||
                (RX_QPLL_USED == "FALSE" && TX_QPLL_USED == "TRUE"  && cplllock_sync == 1'b1))
            begin 
              rx_state                <= `DLY  VERIFY_RECCLK_STABLE;
              reset_time_out          <= `DLY  1'b1;
              recclk_mon_count_reset  <= `DLY  1'b0;
              adapt_count_reset       <= `DLY  1'b0;
            end
            else if ((RX_QPLL_USED == "TRUE"  && qplllock_sync == 1'b1) ||
                     (RX_QPLL_USED == "FALSE" && cplllock_sync == 1'b1))
            begin 
              rx_state                <= `DLY  VERIFY_RECCLK_STABLE;
              reset_time_out          <= `DLY  1'b1;
              recclk_mon_count_reset  <= `DLY  1'b0;
              adapt_count_reset       <= `DLY  1'b0;
            end
            if (time_out_2ms == 1'b1) 
            begin
              if (retry_counter_int == MAX_RETRIES) 
                retry_counter_int <= `DLY  0;
              else
              begin
                retry_counter_int <= `DLY  retry_counter_int + 1;
              end
              rx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end            
           end
           VERIFY_RECCLK_STABLE :
           begin
            gtrxreset_i <= `DLY  1'b0;
            if (RECCLK_STABLE == 1'b1)
            begin
              rx_state        <= `DLY  RELEASE_MMCM_RESET;
              reset_time_out  <= `DLY  1'b1;
            end           
            if (recclk_mon_restart_count == 2)
            begin
              if (retry_counter_int == MAX_RETRIES) 
                retry_counter_int <= `DLY  0;
              else
              begin
                retry_counter_int <= `DLY  retry_counter_int + 1;
              end 
              rx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end   
           end          
           RELEASE_MMCM_RESET :
           begin 
            check_tlock_max <= `DLY  1'b1;
            mmcm_reset_i <= `DLY  1'b0;
            reset_time_out  <= `DLY  1'b0;
            if (mmcm_lock_reclocked == 1'b1)
            begin
              rx_state <= `DLY  WAIT_FOR_RXUSRCLK;
              reset_time_out  <= `DLY  1'b1;
            end           
            if (time_tlock_max == 1'b1 && reset_time_out  == 1'b0 )
            begin
              if (retry_counter_int == MAX_RETRIES)
                retry_counter_int <= `DLY  0;
              else
              begin
                retry_counter_int <= `DLY  retry_counter_int + 1;
              end
              rx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end 
           end            
           WAIT_FOR_RXUSRCLK :
           begin
              if(wait_time_done)
               rx_state <= `DLY WAIT_RESET_DONE;  
           end  
           WAIT_RESET_DONE :
           begin
            if(TXUSERRDY)
               RXUSERRDY    <= `DLY  1'b1;
            reset_time_out  <= `DLY  1'b0;
            if (rxresetdone_s3 == 1'b1)
            begin
              rx_state        <= `DLY  DO_PHASE_ALIGNMENT; 
              reset_time_out  <= `DLY  1'b1;
            end           
            if (time_out_2ms == 1'b1 && reset_time_out  == 1'b0)
            begin
              if (retry_counter_int == MAX_RETRIES) 
                retry_counter_int <= `DLY  0;
              else 
              begin
                retry_counter_int <= `DLY  retry_counter_int + 1;
              end 
              rx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end 
           end            
           DO_PHASE_ALIGNMENT :
           begin 
            RESET_PHALIGNMENT       <= `DLY  1'b0;
            run_phase_alignment_int <= `DLY  1'b1;
            reset_time_out          <= `DLY  1'b0;
            if (PHALIGNMENT_DONE == 1'b1)
            begin
              rx_state        <= `DLY  MONITOR_DATA_VALID;
              reset_time_out  <= `DLY  1'b1;
            end 
            if (time_out_wait_bypass_s3 == 1'b1)
            begin
              if (retry_counter_int == MAX_RETRIES)
                retry_counter_int <= `DLY  0;
              else
              begin
                retry_counter_int <= `DLY   retry_counter_int + 1;
              end 
              rx_state            <= `DLY  ASSERT_ALL_RESETS; 
            end            
           end
           MONITOR_DATA_VALID :
           begin 
            reset_time_out  <= `DLY  1'b0;
            if (data_valid_sync == 1'b0 && time_out_100us == 1'b1 && DONT_RESET_ON_DATA_ERROR == 1'b0 && reset_time_out  == 1'b0)
            begin
              rx_state              <= `DLY  ASSERT_ALL_RESETS; 
              rx_fsm_reset_done_int <= `DLY  1'b0;
            end
            else if (data_valid_sync == 1'b1)
            begin
              rx_state              <= `DLY  FSM_DONE; 
              rx_fsm_reset_done_int <= `DLY  1'b0;
              reset_time_out        <= `DLY  1'b1;
            end
           end            
           FSM_DONE :
           begin 
            reset_time_out        <= `DLY  1'b0;
            if (data_valid_sync == 1'b0)
            begin
               rx_fsm_reset_done_int <= `DLY  1'b0;
               reset_time_out        <= `DLY  1'b1;
               rx_state              <= `DLY  MONITOR_DATA_VALID; 
            end
            else if(time_out_1us == 1'b1 && reset_time_out  == 1'b0)  
               rx_fsm_reset_done_int <= `DLY  1'b1;
            if(time_out_adapt)
            begin
               if(EQ_MODE == "DFE")
               begin
                  RXDFEAGCHOLD  <= `DLY 1'b1;
                  RXDFELFHOLD   <= `DLY 1'b1;
               end
               else
               begin
                  RXDFEAGCHOLD  <= `DLY 1'b0;
                  RXDFELFHOLD   <= `DLY 1'b0;
                  RXLPMHFHOLD   <= `DLY 1'b0;
                  RXLPMLFHOLD   <= `DLY 1'b0;
               end
            end
           end
           default:
             rx_state                <= `DLY  INIT;
        endcase
      end
  end 
endmodule
