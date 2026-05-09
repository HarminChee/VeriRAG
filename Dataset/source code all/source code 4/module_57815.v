`define TOTAL_BITS   11
`define RELEASE_CODE 16'hF0
`define LEFT_SHIFT   16'h12
`define RIGHT_SHIFT  16'h59
`define TOTAL_BITS   11
`define RELEASE_CODE 16'hF0
`define LEFT_SHIFT   16'h12
`define RIGHT_SHIFT  16'h59
module ps2_keyb (
    output           released,
    output           rx_shifting_done,
    output           tx_shifting_done,
    input            reset,               
    input            clk,                 
    output     [7:0] scancode,            
    output           rx_output_strobe,    
    input            ps2_clk_,            
    inout            ps2_data_
  );
  parameter TIMER_60USEC_VALUE_PP = 1920; 
  parameter TIMER_60USEC_BITS_PP  = 11;   
  parameter TIMER_5USEC_VALUE_PP  = 186;  
  parameter TIMER_5USEC_BITS_PP   = 8;    
  parameter TRAP_SHIFT_KEYS_PP    = 0;    
  parameter m1_rx_clk_h = 1;
  parameter m1_rx_clk_l = 0;
  parameter m1_rx_falling_edge_marker = 13;
  parameter m1_rx_rising_edge_marker = 14;
  parameter m1_tx_force_clk_l = 3;
  parameter m1_tx_first_wait_clk_h = 10;
  parameter m1_tx_first_wait_clk_l = 11;
  parameter m1_tx_reset_timer = 12;
  parameter m1_tx_wait_clk_h = 2;
  parameter m1_tx_clk_h = 4;
  parameter m1_tx_clk_l = 5;
  parameter m1_tx_wait_keyboard_ack = 6;
  parameter m1_tx_done_recovery = 7;
  parameter m1_tx_error_no_keyboard_ack = 8;
  parameter m1_tx_rising_edge_marker = 9;
  wire         rx_output_event;
  wire         timer_60usec_done;
  wire         timer_5usec_done;
  wire   [6:0] xt_code;
  reg    [7:0] dat_o;
  reg    [3:0] bit_count;
  reg    [3:0] m1_state;
  reg    [3:0] m1_next_state;
  reg          ps2_data_hi_z;         
  reg          ps2_clk_s;             
  reg          ps2_data_s;            
  reg          enable_timer_60usec;
  reg          enable_timer_5usec;
  reg          hold_released;       
  reg [TIMER_60USEC_BITS_PP-1:0]  timer_60usec_count;
  reg [TIMER_5USEC_BITS_PP-1 :0]  timer_5usec_count;
  reg [`TOTAL_BITS-1:0]           q_r;
  wire [`TOTAL_BITS-1:0]          q;
  assign q = (q_r[8:1]==8'h83)?{q_r[`TOTAL_BITS-1:9],8'h02,q_r[0]} : q_r;
  ps2_keyb_xtcodes keyb_xtcodes (
    .at_code (q[7:1]),
    .xt_code (xt_code)
  );
  assign rx_shifting_done = (bit_count == `TOTAL_BITS);
  assign tx_shifting_done = (bit_count == `TOTAL_BITS-1);
  assign rx_output_event  = (rx_shifting_done  && ~released );
  assign rx_output_strobe = (rx_shifting_done  && ~released
                          && ( (TRAP_SHIFT_KEYS_PP == 0) || ( (q[8:1] != `RIGHT_SHIFT)
                                    &&(q[8:1] != `LEFT_SHIFT) ) ) );
  assign ps2_data_ = ps2_data_hi_z ? 1'bZ : 1'b0;
  assign timer_60usec_done = (timer_60usec_count == (TIMER_60USEC_VALUE_PP - 1));
  assign timer_5usec_done = (timer_5usec_count == TIMER_5USEC_VALUE_PP - 1);
  assign       scancode = dat_o;
  assign released = (q[8:1] == `RELEASE_CODE) && rx_shifting_done;
  always @(posedge clk)
    if(reset) q_r <= 0;
    else 
    if((m1_state == m1_rx_falling_edge_marker) ||(m1_state == m1_tx_rising_edge_marker)) q_r <= {ps2_data_s,q_r[`TOTAL_BITS-1:1]};
  always @(posedge clk)
    if(~enable_timer_60usec) timer_60usec_count <= 0;
    else if (~timer_60usec_done) timer_60usec_count <= timer_60usec_count + 10'd1;
  always @(posedge clk)
    if (~enable_timer_5usec) timer_5usec_count <= 0;
    else if (~timer_5usec_done) timer_5usec_count <= timer_5usec_count + 6'd1;
  always @(posedge clk) begin
    ps2_clk_s <= ps2_clk_;
    ps2_data_s <= ps2_data_;
  end
  always @(m1_state
           or q
           or tx_shifting_done
           or ps2_clk_s
           or ps2_data_s
           or timer_60usec_done
           or timer_5usec_done
          )
  begin : m1_state_logic
    ps2_data_hi_z <= 1;
    enable_timer_60usec <= 0;
    enable_timer_5usec  <= 0;
    case (m1_state)
      m1_rx_clk_h :
      begin
        enable_timer_60usec <= 1;
        if (~ps2_clk_s)
          m1_next_state <= m1_rx_falling_edge_marker;
        else m1_next_state <= m1_rx_clk_h;
      end
      m1_rx_falling_edge_marker :
      begin
        enable_timer_60usec <= 0;
        m1_next_state <= m1_rx_clk_l;
      end
      m1_rx_rising_edge_marker :
      begin
        enable_timer_60usec <= 0;
        m1_next_state <= m1_rx_clk_h;
      end
      m1_rx_clk_l :
      begin
        enable_timer_60usec <= 1;
        if (ps2_clk_s)
          m1_next_state <= m1_rx_rising_edge_marker;
        else m1_next_state <= m1_rx_clk_l;
      end
      m1_tx_reset_timer :
      begin
        enable_timer_60usec <= 0;
        m1_next_state <= m1_tx_force_clk_l;
      end
      m1_tx_force_clk_l :
      begin
        enable_timer_60usec <= 1;
        if (timer_60usec_done)
          m1_next_state <= m1_tx_first_wait_clk_h;
        else m1_next_state <= m1_tx_force_clk_l;
      end
      m1_tx_first_wait_clk_h :
      begin
        enable_timer_5usec <= 1;
        ps2_data_hi_z <= 0;        
        if (~ps2_clk_s && timer_5usec_done)
          m1_next_state <= m1_tx_clk_l;
        else
          m1_next_state <= m1_tx_first_wait_clk_h;
      end
      m1_tx_first_wait_clk_l :
      begin
        ps2_data_hi_z <= 0;
        if (~ps2_clk_s) m1_next_state <= m1_tx_clk_l;
        else m1_next_state <= m1_tx_first_wait_clk_l;
      end
      m1_tx_wait_clk_h :
      begin
        enable_timer_5usec <= 1;
        ps2_data_hi_z <= q[0];
        if (ps2_clk_s && timer_5usec_done)
          m1_next_state <= m1_tx_rising_edge_marker;
        else
          m1_next_state <= m1_tx_wait_clk_h;
      end
      m1_tx_rising_edge_marker :
      begin
        ps2_data_hi_z <= q[0];
        m1_next_state <= m1_tx_clk_h;
      end
      m1_tx_clk_h :
      begin
        ps2_data_hi_z <= q[0];
        if (tx_shifting_done) m1_next_state <= m1_tx_wait_keyboard_ack;
        else if (~ps2_clk_s) m1_next_state <= m1_tx_clk_l;
        else m1_next_state <= m1_tx_clk_h;
      end
      m1_tx_clk_l :
      begin
        ps2_data_hi_z <= q[0];
        if (ps2_clk_s) m1_next_state <= m1_tx_wait_clk_h;
        else m1_next_state <= m1_tx_clk_l;
      end
      m1_tx_wait_keyboard_ack :
      begin
        if (~ps2_clk_s && ps2_data_s)
          m1_next_state <= m1_tx_error_no_keyboard_ack;
        else if (~ps2_clk_s && ~ps2_data_s)
          m1_next_state <= m1_tx_done_recovery;
        else m1_next_state <= m1_tx_wait_keyboard_ack;
      end
      m1_tx_done_recovery :
      begin
        if (ps2_clk_s && ps2_data_s) m1_next_state <= m1_rx_clk_h;
        else m1_next_state <= m1_tx_done_recovery;
      end
      m1_tx_error_no_keyboard_ack :
      begin
        if (ps2_clk_s && ps2_data_s) m1_next_state <= m1_rx_clk_h;
        else m1_next_state <= m1_tx_error_no_keyboard_ack;
      end
      default : m1_next_state <= m1_rx_clk_h;
    endcase
  end
  always @(posedge clk)
  begin : m1_state_register
    if(reset) m1_state <= m1_rx_clk_h;
    else m1_state <= m1_next_state;
  end
  always @(posedge clk)
    if(reset) dat_o <= 8'b0;
    else dat_o <= (rx_output_strobe && q[8:1]) ? (q[8] ? q[8:1] : {hold_released,xt_code}) : dat_o;
  always @(posedge clk)
    begin
      if(reset || rx_shifting_done  || (m1_state == m1_tx_wait_keyboard_ack) 
         ) bit_count <= 0;  
      else if (timer_60usec_done && (m1_state == m1_rx_clk_h) && (ps2_clk_s)
              ) bit_count <= 0;  
      else if ( (m1_state == m1_rx_falling_edge_marker) 
              ||(m1_state == m1_tx_rising_edge_marker)  
              )
        bit_count <= bit_count + 4'd1;
  end
  always @(posedge clk)
    if(reset || rx_output_event) hold_released <= 0;
    else if (rx_shifting_done && released) hold_released <= 1;
endmodule
