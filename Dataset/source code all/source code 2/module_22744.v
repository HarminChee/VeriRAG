`timescale 1ps / 1ps
`timescale 1ps / 1ps
module tx_client_fifo_8 (
   rd_clk,
   rd_sreset,
   rd_enable,
   tx_data,
   tx_data_valid,
   tx_ack,
   tx_collision,
   tx_retransmit,
   overflow,
   wr_clk,
   wr_sreset,
   wr_data,
   wr_sof_n,
   wr_eof_n,
   wr_src_rdy_n,
   wr_dst_rdy_n,
   wr_fifo_status
);
  input        rd_clk;
  input        rd_sreset;
  input        rd_enable;
  output [7:0] tx_data;
  output       tx_data_valid;
  input        tx_ack;
  input        tx_collision;
  input        tx_retransmit;
  output       overflow;
  input        wr_clk;
  input        wr_sreset;
  input  [7:0] wr_data;
  input        wr_sof_n;
  input        wr_eof_n;
  input        wr_src_rdy_n;
  output       wr_dst_rdy_n;
  output [3:0] wr_fifo_status;
  parameter    FULL_DUPLEX_ONLY = 0;
  reg [7:0]    tx_data;
  reg          tx_data_valid;
  reg [3:0]    wr_fifo_status;
  wire        GND;
  wire        VCC;
  wire [31:0] GND_BUS;
  parameter  IDLE_s = 4'b0000;      parameter  QUEUE1_s = 4'b0001;
  parameter  QUEUE2_s = 4'b0010;    parameter  QUEUE3_s = 4'b0011;
  parameter  QUEUE_ACK_s = 4'b0100; parameter  WAIT_ACK_s = 4'b0101;
  parameter  FRAME_s = 4'b0110;     parameter  DROP_s = 4'b0111;
  parameter  RETRANSMIT_s = 4'b1000;
  reg  [3:0]  rd_state;
  reg  [3:0]  rd_nxt_state;
  parameter WAIT_s = 2'b00;  parameter DATA_s = 2'b01;
  parameter EOF_s = 2'b10;   parameter OVFLOW_s = 2'b11;
  reg  [1:0]  wr_state;
  reg  [1:0]  wr_nxt_state;
  reg  [7:0]  wr_data_bram;
  reg  [7:0]  wr_data_pipe[0:1];
  reg         wr_sof_pipe[0:1];
  reg         wr_eof_pipe[0:1];
  reg         wr_accept_pipe[0:1];
  reg         wr_accept_bram;
  reg  [0:0]  wr_eof_bram;
  reg  [11:0] wr_addr;
  wire        wr_addr_inc;
  wire        wr_start_addr_load;
  wire        wr_addr_reload;
  reg  [11:0] wr_start_addr;
  reg         wr_fifo_full;
  wire        wr_en;
  reg         wr_ovflow_dst_rdy;
  wire        wr_dst_rdy_int_n;
  reg         frame_in_fifo;
  reg         frame_in_fifo_sync;
  wire        rd_eof_bram;
  reg         rd_eof;
  reg         rd_eof_reg;
  reg  [11:0] rd_addr;
  wire        rd_addr_inc;
  wire        rd_addr_reload;
  wire [7:0]  rd_data_bram;
  reg  [7:0]  rd_data_pipe;
  wire        rd_en;
  wire        rd_en_bram;
  wire [31:0] dob_bram;
  wire [3:0]  dopb_bram;
  reg         rd_tran_frame_tog;
  reg         wr_tran_frame_tog;
  reg         wr_tran_frame_sync;
  reg         wr_tran_frame_delay;
  reg         rd_retran_frame_tog;
  reg         wr_retran_frame_tog;
  reg         wr_retran_frame_sync;
  reg         wr_retran_frame_delay;
  wire        wr_store_frame;
  wire        wr_eof_state;
  reg         wr_eof_state_reg;
  reg         wr_transmit_frame;
  reg         wr_retransmit_frame;
  reg  [8:0]  wr_frames;
  reg         wr_frame_in_fifo;
  reg   [3:0] rd_16_count;
  wire        rd_txfer_en;
  reg  [11:0] rd_addr_txfer;
  reg         rd_txfer_tog;
  reg         wr_txfer_tog;
  reg         wr_txfer_tog_sync;
  reg         wr_txfer_tog_delay;
  wire        wr_txfer_en;
  reg  [11:0] wr_rd_addr;
  reg  [11:0] wr_addr_diff;
  reg         rd_drop_frame;
  reg         rd_retransmit;
  reg  [11:0] rd_start_addr;
  wire        rd_start_addr_load;
  wire        rd_start_addr_reload;
  reg  [11:0] rd_dec_addr;
  wire        rd_transmit_frame;
  wire        rd_retransmit_frame;
  reg         rd_col_window_expire;
  reg         rd_col_window_pipe[0:1];
  reg         wr_col_window_pipe[0:1];
  wire        wr_fifo_overflow;
  reg  [9:0]  rd_slot_timer;
  reg         wr_col_window_expire;
  wire        rd_idle_state;
  reg         rd_enable_delay;
  reg         rd_enable_delay2;
  assign GND = 1'b0;
  assign VCC = 1'b1;
  assign GND_BUS = 32'b0;
  always @(posedge rd_clk)
  begin
    if (rd_sreset == 1'b1) begin
       rd_enable_delay <= 1'b0;
       rd_enable_delay2 <= 1'b0;
   end
   else begin
       rd_enable_delay <= rd_enable;
       rd_enable_delay2 <= rd_enable_delay;
   end
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
         wr_state <= WAIT_s;
     else
         wr_state <= wr_nxt_state;
  end
  always @(wr_state or wr_sof_pipe[1] or wr_eof_pipe[0] or wr_eof_pipe[1] or wr_eof_bram[0] or wr_fifo_overflow)
  begin
  case (wr_state)
     WAIT_s : begin
        if (wr_sof_pipe[1] == 1'b1)
           wr_nxt_state <= DATA_s;
        else
           wr_nxt_state <= WAIT_s;
        end
     DATA_s : begin
        if (wr_fifo_overflow == 1'b1 && wr_eof_pipe[0] == 1'b0 && wr_eof_pipe[1] == 1'b0)
           wr_nxt_state <= OVFLOW_s;
        else if (wr_eof_pipe[1] == 1'b1)
           wr_nxt_state <= EOF_s;
        else
           wr_nxt_state <= DATA_s;
        end
     EOF_s : begin
        if (wr_sof_pipe[1] == 1'b1)
           wr_nxt_state <= DATA_s;
        else if (wr_eof_bram[0] == 1'b1)
           wr_nxt_state <= WAIT_s;
        else
           wr_nxt_state <= EOF_s;
        end
     OVFLOW_s : begin
        if (wr_eof_bram[0] == 1'b1)
           wr_nxt_state <= WAIT_s;
        else
           wr_nxt_state <= OVFLOW_s;
        end
     default : begin
        wr_nxt_state <= WAIT_s;
        end
  endcase
  end
  assign wr_en = (wr_state == OVFLOW_s) ? 1'b0 : wr_accept_bram;
  assign wr_addr_inc = wr_en;
  assign wr_addr_reload = (wr_state == OVFLOW_s) ? 1'b1 : 1'b0;
  assign wr_start_addr_load = (wr_state == EOF_s && wr_nxt_state == WAIT_s) ? 1'b1 :
                              (wr_state == EOF_s && wr_nxt_state == DATA_s) ? 1'b1 : 1'b0;
  assign wr_dst_rdy_int_n = (wr_state == OVFLOW_s) ? wr_ovflow_dst_rdy : wr_fifo_full;
  assign wr_dst_rdy_n = wr_dst_rdy_int_n;
  assign overflow = (wr_state == OVFLOW_s) ? 1'b1 : 1'b0;
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_ovflow_dst_rdy <= 1'b0;
     else
        begin
        if (wr_fifo_overflow == 1'b1 && wr_state == DATA_s)
            wr_ovflow_dst_rdy <= 1'b0;
        else if (wr_eof_n == 1'b0 && wr_src_rdy_n == 1'b0)
            wr_ovflow_dst_rdy <= 1'b1;
        end
  end
  assign wr_eof_state = (wr_state == EOF_s) ? 1'b1 : 1'b0;
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_eof_state_reg <= 1'b0;
     else
        wr_eof_state_reg <= wr_eof_state;
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_state <= IDLE_s;
     else if (rd_enable == 1'b1)
        rd_state <= rd_nxt_state;
  end
  generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_sm
  always @(rd_state or frame_in_fifo or rd_eof or tx_ack)
  begin
      case (rd_state)
           IDLE_s : begin
              if (frame_in_fifo == 1'b1)
                 rd_nxt_state <= QUEUE1_s;
              else
                 rd_nxt_state <= IDLE_s;
              end
           QUEUE1_s : begin
                 rd_nxt_state <= QUEUE2_s;
              end
           QUEUE2_s : begin
                 rd_nxt_state <= QUEUE3_s;
              end
           QUEUE3_s : begin
                 rd_nxt_state <= QUEUE_ACK_s;
              end
           QUEUE_ACK_s : begin
                 rd_nxt_state <= WAIT_ACK_s;
              end
           WAIT_ACK_s : begin
              if (tx_ack == 1'b1)
                 rd_nxt_state <= FRAME_s;
              else
                 rd_nxt_state <= WAIT_ACK_s;
              end
           FRAME_s : begin
              if (rd_eof == 1'b1)
                 rd_nxt_state <= IDLE_s;
              else
                 rd_nxt_state <= FRAME_s;
              end
           default : begin
                 rd_nxt_state <= IDLE_s;
              end
      endcase
  end
  end 
  endgenerate
  generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_sm
  always @(rd_state or frame_in_fifo or rd_eof_reg or tx_ack or rd_drop_frame or rd_retransmit)
  begin
  case (rd_state)
           IDLE_s : begin
              if (rd_retransmit == 1'b1)
                 rd_nxt_state <= RETRANSMIT_s;
              else if (frame_in_fifo == 1'b1)
                 rd_nxt_state <= QUEUE1_s;
              else
                 rd_nxt_state <= IDLE_s;
              end
           QUEUE1_s : begin
              if (rd_retransmit == 1'b1)
                 rd_nxt_state <= RETRANSMIT_s;
              else
                rd_nxt_state <= QUEUE2_s;
              end
           QUEUE2_s : begin
              if (rd_retransmit == 1'b1)
                 rd_nxt_state <= RETRANSMIT_s;
              else
                 rd_nxt_state <= QUEUE3_s;
              end
           QUEUE3_s : begin
              if (rd_retransmit == 1'b1)
                 rd_nxt_state <= RETRANSMIT_s;
              else
                 rd_nxt_state <= QUEUE_ACK_s;
              end
           QUEUE_ACK_s : begin
              if (rd_retransmit == 1'b1)
                 rd_nxt_state <= RETRANSMIT_s;
              else
                 rd_nxt_state <= WAIT_ACK_s;
              end
           WAIT_ACK_s : begin
              if (rd_retransmit == 1'b1)
                 rd_nxt_state <= RETRANSMIT_s;
              else if (tx_ack == 1'b1)
                 rd_nxt_state <= FRAME_s;
              else
                 rd_nxt_state <= WAIT_ACK_s;
              end
           FRAME_s : begin
              if (rd_drop_frame == 1'b1)
                 rd_nxt_state <= DROP_s;
              else if (rd_retransmit == 1'b1)
                 rd_nxt_state <= RETRANSMIT_s;
              else if (rd_eof_reg == 1'b1)
                 rd_nxt_state <= IDLE_s;
              else
                 rd_nxt_state <= FRAME_s;
              end
           DROP_s : begin
              if (rd_eof_reg == 1'b1)
                 rd_nxt_state <= IDLE_s;
              else
                 rd_nxt_state <= DROP_s;
              end
           RETRANSMIT_s : begin
                 rd_nxt_state <= QUEUE1_s;
              end
           default : begin
                 rd_nxt_state <= IDLE_s;
              end
        endcase
  end
  end 
  endgenerate
  always @(posedge rd_clk)
  begin
     if (rd_enable == 1'b1)
        begin
        if (rd_nxt_state == FRAME_s)
           tx_data <= rd_data_pipe;
        else
        begin
           case (rd_state)
              QUEUE_ACK_s :
                 tx_data <= rd_data_pipe;
              WAIT_ACK_s :
                 tx_data <= tx_data;
              FRAME_s :
                 tx_data <= rd_data_pipe;
              default :
                 tx_data <= 8'b0;
           endcase
           end
        end
  end
  always @(posedge rd_clk)
  begin
     if (rd_enable == 1'b1)
        begin
        if (rd_nxt_state == FRAME_s)
           tx_data_valid <= ~(tx_collision && ~(tx_retransmit));
        else
        begin
           case (rd_state)
              QUEUE_ACK_s :
                 tx_data_valid <= 1'b1;
              WAIT_ACK_s :
                 tx_data_valid <= 1'b1;
              FRAME_s :
                 tx_data_valid <= ~(rd_nxt_state == DROP_s);
              default :
                 tx_data_valid <= 1'b0;
           endcase
           end
        end
  end
  generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_decode
  assign rd_en = (rd_state == IDLE_s) ? 1'b0 :
                 (rd_nxt_state == FRAME_s) ? 1'b1 :
                 (rd_state == WAIT_ACK_s) ? 1'b0 : 1'b1;
  assign rd_addr_inc = rd_en;
  assign rd_addr_reload = (rd_state == FRAME_s && rd_nxt_state == IDLE_s) ? 1'b1 : 1'b0;
  assign rd_transmit_frame = (rd_state == WAIT_ACK_s && rd_nxt_state == FRAME_s) ? 1'b1 : 1'b0;
  assign rd_start_addr_reload = 1'b0;
  assign rd_start_addr_load   = 1'b0;
  assign rd_retransmit_frame  = 1'b0;
  end 
  endgenerate
  generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_decode
  assign rd_en = (rd_state == IDLE_s) ? 1'b0 :
                 (rd_nxt_state == DROP_s && rd_eof == 1'b1) ? 1'b0 :
                 (rd_nxt_state == FRAME_s) ? 1'b1 :
                 (rd_state == RETRANSMIT_s) ? 1'b0 :
                 (rd_state == WAIT_ACK_s) ? 1'b0 : 1'b1;
  assign rd_addr_inc = rd_en;
  assign rd_addr_reload = (rd_state == FRAME_s && rd_nxt_state == IDLE_s) ? 1'b1 :
                          (rd_state == DROP_s && rd_nxt_state == IDLE_s) ? 1'b1 : 1'b0;
  assign rd_start_addr_reload = (rd_state == RETRANSMIT_s) ? 1'b1 : 1'b0;
  assign rd_start_addr_load = (rd_state == WAIT_ACK_s && rd_nxt_state == FRAME_s) ? 1'b1 :
                              (rd_col_window_expire == 1'b1) ? 1'b1 : 1'b0;
  assign rd_transmit_frame = (rd_state == WAIT_ACK_s && rd_nxt_state == FRAME_s) ? 1'b1 : 1'b0;
  assign rd_retransmit_frame = (rd_state == RETRANSMIT_s) ? 1'b1 : 1'b0;
  end 
  endgenerate
  assign wr_store_frame = (wr_state == EOF_s && wr_nxt_state != EOF_s) ? 1'b1 : 1'b0;
  always @(posedge rd_clk)
  begin  
     if (rd_sreset == 1'b1)
         rd_tran_frame_tog <= 1'b0;
     else if (rd_enable == 1'b1)
        if (rd_transmit_frame == 1'b1)  
              rd_tran_frame_tog <= !rd_tran_frame_tog;
  end
  always @(posedge wr_clk)
  begin
      if (wr_sreset == 1'b1)
      begin
            wr_tran_frame_tog  <= 1'b0;
            wr_tran_frame_sync <= 1'b0;
            wr_tran_frame_delay <= 1'b0;
            wr_transmit_frame   <= 1'b0;
      end
      else
      begin
           wr_tran_frame_tog  <= rd_tran_frame_tog;
           wr_tran_frame_sync <= wr_tran_frame_tog;
           wr_tran_frame_delay <= wr_tran_frame_sync;
           if ((wr_tran_frame_delay ^ wr_tran_frame_sync) == 1'b1)
             wr_transmit_frame    <= 1'b1;
           else
             wr_transmit_frame    <= 1'b0;
      end
  end
  generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_count
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_frames <= 9'b0;
     else
        if ((wr_store_frame & !wr_transmit_frame) == 1'b1)
           wr_frames <= wr_frames + 9'b1;
        else if ((!wr_store_frame & wr_transmit_frame) == 1'b1)
           wr_frames <= wr_frames - 9'b1;
  end
  end 
  endgenerate
  generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_count
  always @(posedge rd_clk)
  begin  
     if (rd_sreset == 1'b1)
        rd_retran_frame_tog <= 1'b0;
     else if (rd_enable == 1'b1)
        if (rd_retransmit_frame == 1'b1) 
           rd_retran_frame_tog <= !rd_retran_frame_tog;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        begin
           wr_retran_frame_tog  <= 1'b0;
           wr_retran_frame_sync <= 1'b0;
           wr_retran_frame_delay <= 1'b0;
           wr_retransmit_frame  <= 1'b0;
        end
     else
        begin
           wr_retran_frame_tog  <= rd_retran_frame_tog;
           wr_retran_frame_sync <= wr_retran_frame_tog;
           wr_retran_frame_delay <= wr_retran_frame_sync;
           if ((wr_retran_frame_delay ^ wr_retran_frame_sync) == 1'b1)
              wr_retransmit_frame    <= 1'b1;
           else
              wr_retransmit_frame    <= 1'b0;
        end
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_frames <= 9'b0;
     else
        if ((wr_store_frame & wr_retransmit_frame) == 1'b1)
           wr_frames <= wr_frames + 9'd2;
        else if (((wr_store_frame | wr_retransmit_frame) & !wr_transmit_frame) == 1'b1)
           wr_frames <= wr_frames + 9'b1;
        else if (wr_transmit_frame == 1'b1 & !wr_store_frame)
           wr_frames <= wr_frames - 9'b1;
  end
  end 
  endgenerate
  always @(posedge wr_clk)
  begin
      if (wr_sreset == 1'b1)
         wr_frame_in_fifo <= 1'b0;
      else
         if (wr_frames != 9'b0)
            wr_frame_in_fifo <= 1'b1;
         else
            wr_frame_in_fifo <= 1'b0;
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        begin
           frame_in_fifo_sync <= 1'b0;
           frame_in_fifo <= 1'b0;
        end
     else if (rd_enable == 1'b1)
        begin
           frame_in_fifo_sync <= wr_frame_in_fifo;
           frame_in_fifo <= frame_in_fifo_sync;
        end
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_addr <= 12'b0;
     else if (wr_addr_reload == 1'b1)
        wr_addr <= wr_start_addr;
     else if (wr_addr_inc == 1'b1)
        wr_addr <= wr_addr + 12'b1;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_start_addr <= 12'b0;
     else if (wr_start_addr_load == 1'b1)
        wr_start_addr <= wr_addr + 12'b1;
  end
  generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_addr
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_addr <= 12'b0;
     else if (rd_enable == 1'b1)
        if (rd_addr_reload == 1'b1)
           rd_addr <= rd_dec_addr;
        else if (rd_addr_inc == 1'b1)
           rd_addr <= rd_addr + 12'b1;
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_start_addr <= 12'b0;
     else if (rd_enable == 1'b1)
        rd_start_addr <= rd_addr;
  end
  end 
  endgenerate
  generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_addr
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_addr <= 12'b0;
     else if (rd_enable == 1'b1)
        if (rd_addr_reload == 1'b1)
           rd_addr <= rd_dec_addr;
        else if (rd_start_addr_reload == 1'b1)
           rd_addr <= rd_start_addr;
        else if (rd_addr_inc == 1'b1)
           rd_addr <= rd_addr + 12'b1;
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_start_addr <= 12'b0;
     else if (rd_enable == 1'b1)
        if (rd_start_addr_load == 1'b1)
           rd_start_addr <= rd_addr - 12'd4;
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_col_window_expire <= 1'b0;
     else if (rd_enable == 1'b1)
        if (rd_transmit_frame == 1'b1)
           rd_col_window_expire <= 1'b0;
        else if (rd_slot_timer[9:8] == 2'b11)
           rd_col_window_expire <= 1'b1;
  end
  assign rd_idle_state = (rd_state == IDLE_s) ? 1'b1 : 1'b0;
  always @(posedge rd_clk)
  begin
     if (rd_enable == 1'b1)
        begin
           rd_col_window_pipe[0] <= rd_col_window_expire & rd_idle_state;
           if (rd_txfer_en == 1'b1)
              rd_col_window_pipe[1] <= rd_col_window_pipe[0];
        end
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1) 
        rd_slot_timer <= 10'b0;
     else if (rd_enable == 1'b1)
        if (rd_transmit_frame == 1'b1)  
           rd_slot_timer <= 10'b0;
        else if (rd_slot_timer != 10'b1111111111)
           rd_slot_timer <= rd_slot_timer + 10'b1;
  end
  end 
  endgenerate
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
           rd_dec_addr <= 12'b0;
     else if (rd_enable == 1'b1)
        if (rd_addr_inc == 1'b1)
           rd_dec_addr <= rd_addr - 12'b1;
  end
  always @(posedge wr_clk)
  begin
     wr_data_pipe[0] <= wr_data;
     if (wr_accept_pipe[0] == 1'b1)
        wr_data_pipe[1] <= wr_data_pipe[0];
     if (wr_accept_pipe[1] == 1'b1)
        wr_data_bram    <= wr_data_pipe[1];
  end
  always @(posedge wr_clk)
  begin
     wr_sof_pipe[0] <= !wr_sof_n;
     if (wr_accept_pipe[0] == 1'b1)
        wr_sof_pipe[1] <= wr_sof_pipe[0];
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        begin
           wr_accept_pipe[0] <= 1'b0;
           wr_accept_pipe[1] <= 1'b0;
           wr_accept_bram    <= 1'b0;
        end
     else
        begin
           wr_accept_pipe[0] <= !wr_src_rdy_n & !wr_dst_rdy_int_n;
           wr_accept_pipe[1] <= wr_accept_pipe[0];
           wr_accept_bram    <= wr_accept_pipe[1];
        end
  end
  always @(posedge wr_clk)
  begin
     wr_eof_pipe[0] <= !wr_eof_n;
     if (wr_accept_pipe[0] == 1'b1)
        wr_eof_pipe[1] <= wr_eof_pipe[0];
     if (wr_accept_pipe[1] == 1'b1)
        wr_eof_bram[0] <= wr_eof_pipe[1];
  end
  always @(posedge rd_clk)
  begin
     if (rd_enable == 1'b1)
        if (rd_en == 1'b1)
           rd_data_pipe <= rd_data_bram;
  end
  always @(posedge rd_clk)
  begin
     if (rd_enable == 1'b1)
        if (rd_en == 1'b1)
           begin
              rd_eof <= rd_eof_bram;
              rd_eof_reg <= rd_eof | rd_eof_bram;
           end
  end
  generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_input
  always @(posedge rd_clk)
  begin
     if (rd_enable == 1'b1)
        rd_drop_frame <= tx_collision & !tx_retransmit;
  end
  always @(posedge rd_clk)
  begin
     if (rd_enable == 1'b1)
        rd_retransmit <= tx_collision & tx_retransmit;
  end
  end 
  endgenerate
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_16_count <= 4'b0;
     else if (rd_enable == 1'b1)
        rd_16_count <= rd_16_count + 4'b1;
  end
  assign rd_txfer_en = (rd_16_count == 4'b1111) ? 1'b1 : 1'b0;
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_addr_txfer <= 12'b0;
     else if (rd_enable == 1'b1)
        begin
        if (rd_txfer_en == 1'b1)
           rd_addr_txfer <= rd_start_addr;
        end
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_txfer_tog <= 1'b0;
     else if (rd_enable == 1'b1)
        begin
        if (rd_txfer_en == 1'b1)
           rd_txfer_tog <= !rd_txfer_tog;
        end
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        begin
           wr_txfer_tog <= 1'b0;
           wr_txfer_tog_sync <= 1'b0;
           wr_txfer_tog_delay <= 1'b0;
        end
     else
        begin
           wr_txfer_tog <= rd_txfer_tog;
           wr_txfer_tog_sync <= wr_txfer_tog;
           wr_txfer_tog_delay <= wr_txfer_tog_sync;
        end
  end
  assign wr_txfer_en = wr_txfer_tog_delay ^ wr_txfer_tog_sync;
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_rd_addr <= 12'b0;
     else if (wr_txfer_en == 1'b1)
        wr_rd_addr <= rd_addr_txfer;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_addr_diff <= 12'b0;
     else
        wr_addr_diff <= wr_rd_addr - wr_addr;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_fifo_full <= 1'b0;
     else
        if (wr_addr_diff[11:4] == 8'b0 && wr_addr_diff[3:2] != 2'b0)
           wr_fifo_full <= 1'b1;
        else
           wr_fifo_full <= 1'b0;
  end
  generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_ovflow
     assign wr_fifo_overflow = (wr_fifo_full == 1'b1 && wr_frame_in_fifo == 1'b0
                             && wr_eof_state == 1'b0 && wr_eof_state_reg == 1'b0) ? 1'b1 : 1'b0;
  end 
  endgenerate
  generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_ovflow
    assign wr_fifo_overflow = (wr_fifo_full == 1'b1 && wr_frame_in_fifo == 1'b0
                            && wr_eof_state == 1'b0 && wr_eof_state_reg == 1'b0
                            && wr_col_window_expire == 1'b1) ? 1'b1 : 1'b0;
    always @(posedge wr_clk)
    begin  
       if (wr_sreset == 1'b1)
          begin
             wr_col_window_pipe[0] <= 1'b0;
             wr_col_window_pipe[1] <= 1'b0;
             wr_col_window_expire  <= 1'b0;
          end
       else
          begin
             if (wr_txfer_en == 1'b1)
                wr_col_window_pipe[0] <= rd_col_window_pipe[1];
             wr_col_window_pipe[1] <= wr_col_window_pipe[0];
             wr_col_window_expire <= wr_col_window_pipe[1];
          end
    end
  end 
  endgenerate
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_fifo_status <= 4'b0;
     else
        if (wr_addr_diff == 12'b0)
           wr_fifo_status <= 4'b0;
        else
           begin
              wr_fifo_status[3] <= !wr_addr_diff[11];
              wr_fifo_status[2] <= !wr_addr_diff[10];
              wr_fifo_status[1] <= !wr_addr_diff[9];
              wr_fifo_status[0] <= !wr_addr_diff[8];
           end
  end
  assign rd_en_bram = rd_en & rd_enable_delay2;
  RAMB36E1 #(
    .DOB_REG             (1),
    .READ_WIDTH_A        (9),
    .READ_WIDTH_B        (9),
    .RSTREG_PRIORITY_B   ("RSTREG"),
    .SIM_COLLISION_CHECK ("ALL"),
    .SRVAL_B             (36'h0),
    .WRITE_MODE_A        ("READ_FIRST"),
    .WRITE_MODE_B        ("READ_FIRST"),
    .WRITE_WIDTH_A       (9),
    .WRITE_WIDTH_B       (9)
  )
  ramgen (
    .ENARDEN       (VCC),
    .CLKARDCLK     (wr_clk),
    .RSTRAMARSTRAM (wr_sreset),
    .RSTREGARSTREG (GND),
    .CASCADEINA    (GND),
    .REGCEAREGCE   (GND),
    .ENBWREN       (rd_en_bram),
    .CLKBWRCLK     (rd_clk),
    .RSTRAMB       (rd_sreset),
    .RSTREGB       (rd_sreset),
    .CASCADEINB    (GND),
    .REGCEB        (rd_en_bram),
    .INJECTDBITERR (GND),
    .INJECTSBITERR (GND),
    .ADDRARDADDR   ({GND, wr_addr, GND_BUS[2:0]}),
    .ADDRBWRADDR   ({GND, rd_addr, GND_BUS[2:0]}),
    .DIADI         ({GND_BUS[23:0], wr_data_bram}),
    .DIBDI         (GND_BUS),
    .DIPADIP       ({GND_BUS[2:0], wr_eof_bram[0]}),
    .DIPBDIP       (GND_BUS[3:0]),
    .WEA           ({GND_BUS[2:0], wr_en}),
    .WEBWE         (GND_BUS[7:0]),
    .CASCADEOUTA   (),
    .CASCADEOUTB   (),
    .DOADO         (),
    .DOBDO         (dob_bram),
    .DOPADOP       (),
    .DOPBDOP       (dopb_bram),
    .ECCPARITY     (),
    .RDADDRECC     (),
    .SBITERR       (),
    .DBITERR       ()
  );
  assign rd_data_bram = dob_bram[7:0];
  assign rd_eof_bram  = dopb_bram[0];
endmodule
