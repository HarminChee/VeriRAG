`timescale 1ps / 1ps
`timescale 1ps / 1ps
module tx_client_fifo_8 #
  (
    parameter FULL_DUPLEX_ONLY = 0
  )
  (
    input            tx_fifo_aclk,
    input            tx_fifo_resetn,
    input      [7:0] tx_axis_fifo_tdata,
    input            tx_axis_fifo_tvalid,
    input            tx_axis_fifo_tlast,
    output           tx_axis_fifo_tready,
    input            tx_mac_aclk,
    input            tx_mac_resetn,
    output     [7:0] tx_axis_mac_tdata,
    output reg       tx_axis_mac_tvalid,
    output reg       tx_axis_mac_tlast,
    input            tx_axis_mac_tready,
    output reg       tx_axis_mac_tuser,
    output           fifo_overflow,
    output     [3:0] fifo_status,
    input            tx_collision,
    input            tx_retransmit
  );
  wire        GND;
  wire        VCC;
  wire [8:0]  GND_BUS;
  parameter  IDLE_s             = 4'b0000;
  parameter  QUEUE1_s           = 4'b0001;
  parameter  QUEUE2_s           = 4'b0010;
  parameter  QUEUE3_s           = 4'b0011;
  parameter  QUEUE_ACK_s        = 4'b0100;
  parameter  WAIT_ACK_s         = 4'b0101;
  parameter  FRAME_s            = 4'b0110;
  parameter  HANDSHAKE_s        = 4'b0111;
  parameter  FINISH_s           = 4'b1000;
  parameter  DROP_ERROR_s       = 4'b1001;
  parameter  DROP_s             = 4'b1010;
  parameter  RETRANSMIT_ERROR_s = 4'b1011;
  parameter  RETRANSMIT_s       = 4'b1100;
  reg  [3:0]  rd_state;
  reg  [3:0]  rd_nxt_state;
  parameter WAIT_s   = 2'b00;
  parameter DATA_s   = 2'b01;
  parameter EOF_s    = 2'b10;
  parameter OVFLOW_s = 2'b11;
  reg  [1:0]  wr_state;
  reg  [1:0]  wr_nxt_state;
  wire [8:0]  wr_eof_data_bram;
  reg  [7:0]  wr_data_bram;
  reg  [7:0]  wr_data_pipe[0:1];
  reg         wr_sof_pipe[0:1];
  reg         wr_eof_pipe[0:1];
  reg         wr_accept_pipe[0:1];
  reg         wr_accept_bram;
  wire        wr_sof_int;
  reg  [0:0]  wr_eof_bram;
  reg         wr_eof_reg;
  reg  [11:0] wr_addr;
  wire        wr_addr_inc;
  wire        wr_start_addr_load;
  wire        wr_addr_reload;
  reg  [11:0] wr_start_addr;
  reg         wr_fifo_full;
  wire        wr_en;
  wire        wr_en_u;
  wire [0:0]  wr_en_u_bram;
  wire        wr_en_l;
  wire [0:0]  wr_en_l_bram;
  reg         wr_ovflow_dst_rdy;
  wire        tx_axis_fifo_tready_int_n;
  wire        frame_in_fifo;
  reg         rd_eof;
  reg         rd_eof_reg;
  reg         rd_eof_pipe;
  reg  [11:0] rd_addr;
  wire        rd_addr_inc;
  wire        rd_addr_reload;
  wire [8:0]  rd_bram_u_unused;
  wire [8:0]  rd_bram_l_unused;
  wire [8:0]  rd_eof_data_bram_u;
  wire [8:0]  rd_eof_data_bram_l;
  wire [7:0]  rd_data_bram_u;
  wire [7:0]  rd_data_bram_l;
  reg  [7:0]  rd_data_pipe_u;
  reg  [7:0]  rd_data_pipe_l;
  reg  [7:0]  rd_data_pipe;
  wire [0:0]  rd_eof_bram_u;
  wire [0:0]  rd_eof_bram_l;
  wire        rd_en;
  reg         rd_bram_u;
  reg         rd_bram_u_reg;
  reg         rd_tran_frame_tog = 1'b0;
  wire        wr_tran_frame_sync;
  reg         wr_tran_frame_delay = 1'b0;
  reg         rd_retran_frame_tog = 1'b0;
  wire        wr_retran_frame_sync;
  reg         wr_retran_frame_delay = 1'b0;
  wire        wr_store_frame;
  reg         wr_transmit_frame;
  reg         wr_retransmit_frame;
  reg  [8:0]  wr_frames;
  reg         wr_frame_in_fifo;
  reg   [3:0] rd_16_count;
  wire        rd_txfer_en;
  reg  [11:0] rd_addr_txfer;
  reg         rd_txfer_tog = 1'b0;
  wire        wr_txfer_tog_sync;
  reg         wr_txfer_tog_delay = 1'b0;
  wire        wr_txfer_en;
  reg  [11:0] wr_rd_addr;
  reg  [11:0] wr_addr_diff;
  reg  [3:0]  wr_fifo_status;
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
  wire        wr_eof_state;
  reg         wr_eof_state_reg;
  wire        wr_fifo_overflow;
  reg  [9:0]  rd_slot_timer;
  reg         wr_col_window_expire;
  wire        rd_idle_state;
  wire [7:0]  tx_axis_mac_tdata_int_frame;
  wire [7:0]  tx_axis_mac_tdata_int_handshake;
  reg  [7:0]  tx_axis_mac_tdata_int;
  wire        tx_axis_mac_tvalid_int_finish;
  wire        tx_axis_mac_tvalid_int_droperror;
  wire        tx_axis_mac_tvalid_int_retransmiterror;
  wire        tx_axis_mac_tlast_int_frame_handshake;
  wire        tx_axis_mac_tlast_int_finish;
  wire        tx_axis_mac_tlast_int_droperror;
  wire        tx_axis_mac_tlast_int_retransmiterror;
  wire        tx_axis_mac_tuser_int_droperror;
  wire        tx_axis_mac_tuser_int_retransmit;
  wire        tx_fifo_reset;
  wire        tx_mac_reset;
  assign tx_fifo_reset = !tx_fifo_resetn;
  assign tx_mac_reset  = !tx_mac_resetn;
  assign GND = 1'b0;
  assign VCC = 1'b1;
  assign GND_BUS = 9'b0;
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
         wr_state <= WAIT_s;
     end
     else begin
         wr_state <= wr_nxt_state;
     end
  end
  always @(wr_state, wr_sof_pipe[1], wr_eof_pipe[0], wr_eof_pipe[1],
           wr_eof_bram[0], wr_fifo_overflow)
  begin
  case (wr_state)
     WAIT_s : begin
        if (wr_sof_pipe[1] == 1'b1 && wr_eof_pipe[1] == 1'b0) begin
           wr_nxt_state <= DATA_s;
        end
        else begin
           wr_nxt_state <= WAIT_s;
        end
     end
     DATA_s : begin
        if (wr_fifo_overflow == 1'b1 && wr_eof_pipe[0] == 1'b0
            && wr_eof_pipe[1] == 1'b0) begin
           wr_nxt_state <= OVFLOW_s;
        end
        else if (wr_eof_pipe[1] == 1'b1) begin
           wr_nxt_state <= EOF_s;
        end
        else begin
           wr_nxt_state <= DATA_s;
        end
     end
     EOF_s : begin
        if (wr_sof_pipe[1] == 1'b1 && wr_eof_pipe[1] == 1'b0) begin
           wr_nxt_state <= DATA_s;
        end
        else if (wr_eof_bram[0] == 1'b1) begin
           wr_nxt_state <= WAIT_s;
        end
        else begin
           wr_nxt_state <= EOF_s;
        end
     end
     OVFLOW_s : begin
        if (wr_eof_bram[0] == 1'b1) begin
           wr_nxt_state <= WAIT_s;
        end
        else begin
           wr_nxt_state <= OVFLOW_s;
        end
     end
     default : begin
        wr_nxt_state <= WAIT_s;
     end
  endcase
  end
  assign wr_en = (wr_state == OVFLOW_s) ? 1'b0 : wr_accept_bram;
  assign wr_en_l = wr_en & !wr_addr[11];
  assign wr_en_u = wr_en &  wr_addr[11];
  assign wr_en_l_bram[0] = wr_en_l;
  assign wr_en_u_bram[0] = wr_en_u;
  assign wr_addr_inc = wr_en;
  assign wr_addr_reload = (wr_state == OVFLOW_s) ? 1'b1 : 1'b0;
  assign wr_start_addr_load = (wr_state == EOF_s && wr_nxt_state == WAIT_s)
                              ? 1'b1 :
                              (wr_state == EOF_s && wr_nxt_state == DATA_s)
                              ? 1'b1 : 1'b0;
  assign tx_axis_fifo_tready_int_n = (wr_state == OVFLOW_s) ?
                                wr_ovflow_dst_rdy : wr_fifo_full;
  assign tx_axis_fifo_tready = !tx_axis_fifo_tready_int_n;
  assign fifo_overflow = (wr_state == OVFLOW_s) ? 1'b1 : 1'b0;
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_ovflow_dst_rdy <= 1'b0;
     end
     else begin
        if (wr_fifo_overflow == 1'b1 && wr_state == DATA_s) begin
            wr_ovflow_dst_rdy <= 1'b0;
        end
        else if (tx_axis_fifo_tvalid == 1'b1 && tx_axis_fifo_tlast == 1'b1) begin
            wr_ovflow_dst_rdy <= 1'b1;
        end
     end
  end
  assign wr_eof_state = (wr_state == EOF_s) ? 1'b1 : 1'b0;
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_eof_state_reg <= 1'b0;
     end
     else begin
        wr_eof_state_reg <= wr_eof_state;
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_state <= IDLE_s;
     end
     else begin
        rd_state <= rd_nxt_state;
     end
  end
generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_sm
  always @(rd_state, frame_in_fifo, rd_eof, rd_eof_reg, tx_axis_mac_tready)
  begin
  case (rd_state)
           IDLE_s : begin
              if (frame_in_fifo == 1'b1) begin
                 rd_nxt_state <= QUEUE1_s;
              end
              else begin
                 rd_nxt_state <= IDLE_s;
              end
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
              if (tx_axis_mac_tready == 1'b1) begin
                 rd_nxt_state <= FRAME_s;
              end
              else begin
                 rd_nxt_state <= WAIT_ACK_s;
              end
           end
           FRAME_s : begin
              if (tx_axis_mac_tready == 1'b0)
              begin
                 rd_nxt_state <= HANDSHAKE_s;
              end
              else if (rd_eof == 1'b1) begin
                 rd_nxt_state <= FINISH_s;
              end
              else begin
                 rd_nxt_state <= FRAME_s;
              end
           end
           HANDSHAKE_s : begin
              if (tx_axis_mac_tready == 1'b1 && rd_eof_reg == 1'b1) begin
                 rd_nxt_state <= FINISH_s;
              end
              else if (tx_axis_mac_tready == 1'b1 && rd_eof_reg == 1'b0) begin
                 rd_nxt_state <= FRAME_s;
              end
              else begin
                 rd_nxt_state <= HANDSHAKE_s;
              end
           end
           FINISH_s : begin
              if (tx_axis_mac_tready == 1'b1) begin
                 rd_nxt_state <= IDLE_s;
              end
              else begin
                 rd_nxt_state <= FINISH_s;
              end
           end
           default : begin
              rd_nxt_state <= IDLE_s;
           end
        endcase
  end
end
endgenerate
generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_sm
  always @(rd_state, frame_in_fifo, rd_eof_reg, tx_axis_mac_tready, rd_drop_frame,
           rd_retransmit)
  begin
  case (rd_state)
           IDLE_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else if (frame_in_fifo == 1'b1) begin
                 rd_nxt_state <= QUEUE1_s;
              end
              else begin
                 rd_nxt_state <= IDLE_s;
              end
           end
           QUEUE1_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else begin
                rd_nxt_state <= QUEUE2_s;
              end
           end
           QUEUE2_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else begin
                 rd_nxt_state <= QUEUE3_s;
              end
           end
           QUEUE3_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else begin
                 rd_nxt_state <= QUEUE_ACK_s;
              end
           end
           QUEUE_ACK_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else begin
                 rd_nxt_state <= WAIT_ACK_s;
              end
           end
           WAIT_ACK_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else if (tx_axis_mac_tready == 1'b1) begin
                 rd_nxt_state <= FRAME_s;
              end
              else begin
                 rd_nxt_state <= WAIT_ACK_s;
              end
           end
           FRAME_s : begin
              if (rd_drop_frame == 1'b1) begin
                 rd_nxt_state <= DROP_ERROR_s;
              end
              else if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else if (tx_axis_mac_tready == 1'b0) begin
                 rd_nxt_state <= HANDSHAKE_s;
              end
              else if (rd_eof_reg == 1'b1) begin
                 rd_nxt_state <= FINISH_s;
              end
              else begin
                 rd_nxt_state <= FRAME_s;
              end
           end
           HANDSHAKE_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              else if (tx_axis_mac_tready == 1'b1 && rd_eof_reg == 1'b1) begin
                 rd_nxt_state <= FINISH_s;
              end
              else if (tx_axis_mac_tready == 1'b1 && rd_eof_reg == 1'b0) begin
                 rd_nxt_state <= FRAME_s;
              end
              else begin
                 rd_nxt_state <= HANDSHAKE_s;
              end
           end
           FINISH_s : begin
              if (rd_retransmit == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
              if (tx_axis_mac_tready == 1'b1) begin
                 rd_nxt_state <= IDLE_s;
              end
              else begin
                 rd_nxt_state <= FINISH_s;
              end
           end
           DROP_ERROR_s : begin
              if (tx_axis_mac_tready == 1'b1) begin
                 rd_nxt_state <= DROP_s;
              end
              else begin
                 rd_nxt_state <= DROP_ERROR_s;
              end
           end
           DROP_s : begin
              if (rd_eof_reg == 1'b1) begin
                 rd_nxt_state <= IDLE_s;
              end
              else begin
                 rd_nxt_state <= DROP_s;
              end
           end
           RETRANSMIT_ERROR_s : begin
              if (tx_axis_mac_tready == 1'b1) begin
                 rd_nxt_state <= RETRANSMIT_s;
              end
              else begin
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end
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
  assign tx_axis_mac_tdata_int_frame = (rd_nxt_state == HANDSHAKE_s) ?
                                      tx_axis_mac_tdata_int : rd_data_pipe;
  assign tx_axis_mac_tdata_int_handshake = (rd_nxt_state == FINISH_s)    ?
                                      rd_data_pipe : tx_axis_mac_tdata_int;
  assign tx_axis_mac_tdata          = tx_axis_mac_tdata_int;
  always @(posedge tx_mac_aclk)
  begin
     if (rd_nxt_state == FRAME_s)
        tx_axis_mac_tdata_int <= rd_data_pipe;
     else if (rd_nxt_state == RETRANSMIT_ERROR_s || rd_nxt_state == DROP_ERROR_s)
        tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int;
     else begin
        case (rd_state)
           QUEUE_ACK_s :
              tx_axis_mac_tdata_int <= rd_data_pipe;
           FRAME_s :
              tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int_frame;
           HANDSHAKE_s :
              tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int_handshake;
           default :
              tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int;
        endcase
     end
  end
  assign tx_axis_mac_tvalid_int_finish     = (rd_nxt_state == IDLE_s)       ?
                                             1'b0 : 1'b1;
  assign tx_axis_mac_tvalid_int_droperror  = (rd_nxt_state == DROP_s)       ?
                                             1'b0 : 1'b1;
  assign tx_axis_mac_tvalid_int_retransmiterror = (rd_nxt_state == RETRANSMIT_s) ?
                                             1'b0 : 1'b1;
  always @(posedge tx_mac_aclk)
  begin
     if (rd_nxt_state == FRAME_s)
        tx_axis_mac_tvalid <= 1'b1;
     else if (rd_nxt_state == RETRANSMIT_ERROR_s || rd_nxt_state == DROP_ERROR_s)
        tx_axis_mac_tvalid <= 1'b1;
     else
     begin
        case (rd_state)
           QUEUE_ACK_s :
              tx_axis_mac_tvalid <= 1'b1;
           WAIT_ACK_s :
              tx_axis_mac_tvalid <= 1'b1;
           FRAME_s :
              tx_axis_mac_tvalid <= 1'b1;
           HANDSHAKE_s :
              tx_axis_mac_tvalid <= 1'b1;
           FINISH_s :
              tx_axis_mac_tvalid <= tx_axis_mac_tvalid_int_finish;
           DROP_ERROR_s :
              tx_axis_mac_tvalid <= tx_axis_mac_tvalid_int_droperror;
           RETRANSMIT_ERROR_s :
              tx_axis_mac_tvalid <= tx_axis_mac_tvalid_int_retransmiterror;
           default :
              tx_axis_mac_tvalid <= 1'b0;
        endcase
     end
  end
  assign tx_axis_mac_tlast_int_frame_handshake = (rd_nxt_state == FINISH_s)     ?
                                            rd_eof_reg : 1'b0;
  assign tx_axis_mac_tlast_int_finish     = (rd_nxt_state == IDLE_s)       ?
                                            1'b0 : rd_eof_reg;
  assign tx_axis_mac_tlast_int_droperror  = (rd_nxt_state == DROP_s)       ?
                                            1'b0 : 1'b1;
  assign tx_axis_mac_tlast_int_retransmiterror = (rd_nxt_state == RETRANSMIT_s) ?
                                            1'b0 : 1'b1;
  always @(posedge tx_mac_aclk)
  begin
     if (rd_nxt_state == FRAME_s)
        tx_axis_mac_tlast <= rd_eof;
     else if (rd_nxt_state == RETRANSMIT_ERROR_s || rd_nxt_state == DROP_ERROR_s)
        tx_axis_mac_tlast <= 1'b1;
     else
     begin
        case (rd_state)
           WAIT_ACK_s :
              tx_axis_mac_tlast <= rd_eof;
           FRAME_s :
              tx_axis_mac_tlast <= tx_axis_mac_tlast_int_frame_handshake;
           HANDSHAKE_s :
              tx_axis_mac_tlast <= tx_axis_mac_tlast_int_frame_handshake;
           FINISH_s :
              tx_axis_mac_tlast <= tx_axis_mac_tlast_int_finish;
           DROP_ERROR_s :
              tx_axis_mac_tlast <= tx_axis_mac_tlast_int_droperror;
           RETRANSMIT_ERROR_s :
              tx_axis_mac_tlast <= tx_axis_mac_tlast_int_retransmiterror;
           default :
              tx_axis_mac_tlast <= 1'b0;
        endcase
     end
  end
  assign tx_axis_mac_tuser_int_droperror = (rd_nxt_state == DROP_s)       ?
                                       1'b0 : 1'b1;
  assign tx_axis_mac_tuser_int_retransmit = (rd_nxt_state == RETRANSMIT_s) ?
                                       1'b0 : 1'b1;
  always @(posedge tx_mac_aclk)
  begin
     if (rd_nxt_state == RETRANSMIT_ERROR_s || rd_nxt_state == DROP_ERROR_s)
        tx_axis_mac_tuser <= 1'b1;
     else
     begin
        case (rd_state)
           DROP_ERROR_s :
              tx_axis_mac_tuser <= tx_axis_mac_tuser_int_droperror;
           RETRANSMIT_ERROR_s :
              tx_axis_mac_tuser <= tx_axis_mac_tuser_int_retransmit;
           default :
              tx_axis_mac_tuser <= 1'b0;
        endcase
     end
  end
generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_decode
  assign rd_en = (rd_state == IDLE_s) ? 1'b0 :
                 (rd_nxt_state == FRAME_s) ? 1'b1 :
                 (rd_state == FRAME_s && rd_nxt_state == HANDSHAKE_s) ? 1'b0 :
                 (rd_nxt_state == HANDSHAKE_s) ? 1'b0 :
                 (rd_state == FINISH_s) ? 1'b0 :
                 (rd_state == WAIT_ACK_s) ? 1'b0 : 1'b1;
  assign rd_addr_inc = rd_en;
  assign rd_addr_reload = (rd_state != FINISH_s && rd_nxt_state == FINISH_s)
                          ? 1'b1 : 1'b0;
  assign rd_transmit_frame = (rd_state == WAIT_ACK_s && rd_nxt_state == FRAME_s)
                             ? 1'b1 : 1'b0;
  assign rd_start_addr_reload = 1'b0;
  assign rd_start_addr_load   = 1'b0;
  assign rd_retransmit_frame  = 1'b0;
end
endgenerate
generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_decode
  assign rd_en = (rd_state == IDLE_s) ? 1'b0 :
                 (rd_nxt_state == DROP_ERROR_s) ? 1'b0 :
                 (rd_nxt_state == DROP_s && rd_eof == 1'b1) ? 1'b0 :
                 (rd_nxt_state == FRAME_s) ? 1'b1 :
                 (rd_state == FRAME_s && rd_nxt_state == HANDSHAKE_s) ? 1'b0 :
                 (rd_nxt_state == HANDSHAKE_s) ? 1'b0 :
                 (rd_state == FINISH_s) ? 1'b0 :
                 (rd_state == RETRANSMIT_ERROR_s) ? 1'b0 :
                 (rd_state == RETRANSMIT_s) ? 1'b0 :
                 (rd_state == WAIT_ACK_s) ? 1'b0 : 1'b1;
  assign rd_addr_inc = rd_en;
  assign rd_addr_reload = (rd_state != FINISH_s && rd_nxt_state == FINISH_s)
                          ? 1'b1 :
                          (rd_state == DROP_s && rd_nxt_state == IDLE_s)
                          ? 1'b1 : 1'b0;
  assign rd_start_addr_reload = (rd_state == RETRANSMIT_s) ? 1'b1 : 1'b0;
  assign rd_start_addr_load = (rd_state== WAIT_ACK_s && rd_nxt_state == FRAME_s)
                              ? 1'b1 :
                              (rd_col_window_expire == 1'b1) ? 1'b1 : 1'b0;
  assign rd_transmit_frame = (rd_state == WAIT_ACK_s && rd_nxt_state == FRAME_s)
                             ? 1'b1 : 1'b0;
  assign rd_retransmit_frame = (rd_state == RETRANSMIT_s) ? 1'b1 : 1'b0;
end
endgenerate
  assign wr_store_frame = (wr_state == EOF_s && wr_nxt_state != EOF_s)
                          ? 1'b1 : 1'b0;
  always @(posedge tx_mac_aclk)
  begin
     if (rd_transmit_frame == 1'b1) begin
        rd_tran_frame_tog <= !rd_tran_frame_tog;
     end
  end
  sync_block resync_rd_tran_frame_tog
  (
    .clk       (tx_fifo_aclk),
    .data_in   (rd_tran_frame_tog),
    .data_out  (wr_tran_frame_sync)
  );
  always @(posedge tx_fifo_aclk)
  begin
     wr_tran_frame_delay <= wr_tran_frame_sync;
  end
  always @(posedge tx_fifo_aclk)
  begin
      if (tx_fifo_reset == 1'b1) begin
         wr_transmit_frame   <= 1'b0;
      end
      else begin
         if ((wr_tran_frame_delay ^ wr_tran_frame_sync) == 1'b1) begin
           wr_transmit_frame <= 1'b1;
         end
         else begin
           wr_transmit_frame <= 1'b0;
         end
      end
  end
generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_count
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_frames <= 9'b0;
     end
     else begin
        if ((wr_store_frame & !wr_transmit_frame) == 1'b1) begin
           wr_frames <= wr_frames + 9'b1;
        end
        else if ((!wr_store_frame & wr_transmit_frame) == 1'b1) begin
           wr_frames <= wr_frames - 9'b1;
        end
     end
  end
end
endgenerate
generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_count
  always @(posedge tx_mac_aclk)
  begin  
     if (rd_retransmit_frame == 1'b1) begin
        rd_retran_frame_tog <= !rd_retran_frame_tog;
     end
  end
  sync_block resync_rd_tran_frame_tog
  (
    .clk       (tx_fifo_aclk),
    .data_in   (rd_retran_frame_tog),
    .data_out  (wr_retran_frame_sync)
  );
  always @(posedge tx_fifo_aclk)
  begin
     wr_retran_frame_delay <= wr_retran_frame_sync;
  end
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_retransmit_frame    <= 1'b0;
     end
     else begin
        if ((wr_retran_frame_delay ^ wr_retran_frame_sync) == 1'b1) begin
           wr_retransmit_frame <= 1'b1;
        end
        else begin
           wr_retransmit_frame <= 1'b0;
        end
     end
  end
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_frames <= 9'd0;
     end
     else begin
        if ((wr_store_frame & wr_retransmit_frame) == 1'b1) begin
           wr_frames <= wr_frames + 9'd2;
        end
        else if (((wr_store_frame | wr_retransmit_frame)
                 & !wr_transmit_frame) == 1'b1) begin
           wr_frames <= wr_frames + 9'd1;
        end
        else if (wr_transmit_frame == 1'b1 & !wr_store_frame) begin
           wr_frames <= wr_frames - 9'd1;
        end
     end
  end
end
endgenerate
  always @(posedge tx_fifo_aclk)
  begin
      if (tx_fifo_reset == 1'b1) begin
         wr_frame_in_fifo <= 1'b0;
      end
      else begin
         if (wr_frames != 9'b0) begin
            wr_frame_in_fifo <= 1'b1;
         end
         else begin
            wr_frame_in_fifo <= 1'b0;
         end
      end
  end
  sync_block resync_wr_frame_in_fifo
  (
    .clk       (tx_mac_aclk),
    .data_in   (wr_frame_in_fifo),
    .data_out  (frame_in_fifo)
  );
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_addr <= 12'b0;
     end
     else if (wr_addr_reload == 1'b1) begin
        wr_addr <= wr_start_addr;
     end
     else if (wr_addr_inc == 1'b1) begin
        wr_addr <= wr_addr + 12'b1;
     end
  end
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_start_addr <= 12'b0;
     end
     else if (wr_start_addr_load == 1'b1) begin
        wr_start_addr <= wr_addr + 12'b1;
     end
  end
generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_addr
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_addr <= 12'b0;
     end
     else begin
        if (rd_addr_reload == 1'b1) begin
           rd_addr <= rd_dec_addr;
        end
        else if (rd_addr_inc == 1'b1) begin
           rd_addr <= rd_addr + 12'b1;
        end
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_start_addr <= 12'b0;
     end
     else begin
        rd_start_addr <= rd_addr;
     end
  end
end
endgenerate
generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_addr
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_addr <= 12'b0;
     end
     else begin
        if (rd_addr_reload == 1'b1) begin
           rd_addr <= rd_dec_addr;
        end
        else if (rd_start_addr_reload == 1'b1) begin
           rd_addr <= rd_start_addr;
        end
        else if (rd_addr_inc == 1'b1) begin
           rd_addr <= rd_addr + 12'b1;
        end
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_start_addr <= 12'd0;
     end
     else begin
        if (rd_start_addr_load == 1'b1) begin
           rd_start_addr <= rd_addr - 12'd4;
        end
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_col_window_expire <= 1'b0;
     end
     else begin
        if (rd_transmit_frame == 1'b1) begin
           rd_col_window_expire <= 1'b0;
        end
        else if (rd_slot_timer[9:8] == 2'b11) begin
           rd_col_window_expire <= 1'b1;
        end
     end
  end
  assign rd_idle_state = (rd_state == IDLE_s) ? 1'b1 : 1'b0;
  always @(posedge tx_mac_aclk)
  begin
     rd_col_window_pipe[0] <= rd_col_window_expire & rd_idle_state;
     if (rd_txfer_en == 1'b1) begin
        rd_col_window_pipe[1] <= rd_col_window_pipe[0];
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_slot_timer <= 10'b0;
     end
     else begin
        if (rd_transmit_frame == 1'b1) begin
           rd_slot_timer <= 10'b0;
        end
        else if (rd_slot_timer != 10'b1111111111) begin
           rd_slot_timer <= rd_slot_timer + 10'b1;
        end
     end
  end
end
endgenerate
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_dec_addr <= 12'b0;
     end
     else begin
        if (rd_addr_inc == 1'b1) begin
           rd_dec_addr <= rd_addr - 12'b1;
        end
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_bram_u <= 1'b0;
        rd_bram_u_reg <= 1'b0;
     end
     else begin
        if (rd_addr_inc == 1'b1) begin
           rd_bram_u <= rd_addr[11];
           rd_bram_u_reg <= rd_bram_u;
        end
     end
  end
  always @(posedge tx_fifo_aclk)
  begin
     wr_data_pipe[0] <= tx_axis_fifo_tdata;
     if (wr_accept_pipe[0] == 1'b1) begin
        wr_data_pipe[1] <= wr_data_pipe[0];
     end
     if (wr_accept_pipe[1] == 1'b1) begin
        wr_data_bram    <= wr_data_pipe[1];
     end
  end
  assign wr_sof_int = tx_axis_fifo_tvalid & wr_eof_reg;
  always @(posedge tx_fifo_aclk)
  begin
    if (tx_fifo_reset == 1'b1) begin
      wr_eof_reg <= 1'b1;
    end
    else begin
      if (tx_axis_fifo_tvalid == 1'b1 & tx_axis_fifo_tready_int_n == 1'b0) begin
        wr_eof_reg <= tx_axis_fifo_tlast;
      end
    end
  end
  always @(posedge tx_fifo_aclk)
  begin
     wr_sof_pipe[0] <= wr_sof_int;
     if (wr_accept_pipe[0] == 1'b1) begin
        wr_sof_pipe[1] <= wr_sof_pipe[0];
     end
  end
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_accept_pipe[0] <= 1'b0;
        wr_accept_pipe[1] <= 1'b0;
        wr_accept_bram    <= 1'b0;
     end
     else begin
        wr_accept_pipe[0] <= tx_axis_fifo_tvalid & !tx_axis_fifo_tready_int_n;
        wr_accept_pipe[1] <= wr_accept_pipe[0];
        wr_accept_bram    <= wr_accept_pipe[1];
     end
  end
  always @(posedge tx_fifo_aclk)
  begin
     wr_eof_pipe[0] <= tx_axis_fifo_tvalid & tx_axis_fifo_tlast;
     if (wr_accept_pipe[0] == 1'b1) begin
        wr_eof_pipe[1] <= wr_eof_pipe[0];
     end
     if (wr_accept_pipe[1] == 1'b1) begin
        wr_eof_bram[0] <= wr_eof_pipe[1];
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (rd_en == 1'b1) begin
        rd_data_pipe_u <= rd_data_bram_u;
        rd_data_pipe_l <= rd_data_bram_l;
        if (rd_bram_u_reg == 1'b1) begin
           rd_data_pipe <= rd_data_pipe_u;
        end
        else begin
           rd_data_pipe <= rd_data_pipe_l;
        end
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (rd_en == 1'b1) begin
        if (rd_bram_u == 1'b1) begin
           rd_eof_pipe <= rd_eof_bram_u[0];
        end
        else begin
           rd_eof_pipe <= rd_eof_bram_l[0];
        end
        rd_eof <= rd_eof_pipe;
        rd_eof_reg <= rd_eof | rd_eof_pipe;
     end
  end
generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_input
  always @(posedge tx_mac_aclk)
  begin
     rd_drop_frame <= tx_collision & !tx_retransmit;
  end
  always @(posedge tx_mac_aclk)
  begin
     rd_retransmit <= tx_collision & tx_retransmit;
  end
end
endgenerate
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_16_count <= 4'b0;
     end
     else begin
        rd_16_count <= rd_16_count + 4'b1;
     end
  end
  assign rd_txfer_en = (rd_16_count == 4'b1111) ? 1'b1 : 1'b0;
  always @(posedge tx_mac_aclk)
  begin
     if (tx_mac_reset == 1'b1) begin
        rd_addr_txfer <= 12'b0;
     end
     else begin
        if (rd_txfer_en == 1'b1) begin
           rd_addr_txfer <= rd_start_addr;
        end
     end
  end
  always @(posedge tx_mac_aclk)
  begin
     if (rd_txfer_en == 1'b1) begin
        rd_txfer_tog <= !rd_txfer_tog;
     end
  end
  sync_block resync_rd_txfer_tog
  (
    .clk       (tx_fifo_aclk),
    .data_in   (rd_txfer_tog),
    .data_out  (wr_txfer_tog_sync)
  );
  always @(posedge tx_fifo_aclk)
  begin
     wr_txfer_tog_delay <= wr_txfer_tog_sync;
  end
  assign wr_txfer_en = wr_txfer_tog_delay ^ wr_txfer_tog_sync;
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_rd_addr <= 12'b0;
     end
     else if (wr_txfer_en == 1'b1) begin
        wr_rd_addr <= rd_addr_txfer;
     end
  end
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_addr_diff <= 12'b0;
     end
     else begin
        wr_addr_diff <= wr_rd_addr - wr_addr;
     end
  end
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_fifo_full <= 1'b0;
     end
     else begin
        if (wr_addr_diff[11:4] == 8'b0 && wr_addr_diff[3:2] != 2'b0) begin
           wr_fifo_full <= 1'b1;
        end
        else begin
           wr_fifo_full <= 1'b0;
        end
     end
  end
generate if (FULL_DUPLEX_ONLY == 1) begin : gen_fd_ovflow
     assign wr_fifo_overflow = (wr_fifo_full == 1'b1 && wr_frame_in_fifo == 1'b0
                                   && wr_eof_state == 1'b0
                                   && wr_eof_state_reg == 1'b0)
                                ? 1'b1 : 1'b0;
end
endgenerate
generate if (FULL_DUPLEX_ONLY != 1) begin : gen_hd_ovflow
    assign wr_fifo_overflow = (wr_fifo_full == 1'b1 && wr_frame_in_fifo == 1'b0
                                  && wr_eof_state == 1'b0
                                  && wr_eof_state_reg == 1'b0
                                  && wr_col_window_expire == 1'b1)
                               ? 1'b1 : 1'b0;
    always @(posedge tx_fifo_aclk)
    begin
       if (tx_fifo_reset == 1'b1) begin
          wr_col_window_pipe[0] <= 1'b0;
          wr_col_window_pipe[1] <= 1'b0;
          wr_col_window_expire  <= 1'b0;
       end
       else begin
          if (wr_txfer_en == 1'b1) begin
             wr_col_window_pipe[0] <= rd_col_window_pipe[1];
          end
          wr_col_window_pipe[1] <= wr_col_window_pipe[0];
          wr_col_window_expire <= wr_col_window_pipe[1];
       end
    end
end
endgenerate
  always @(posedge tx_fifo_aclk)
  begin
     if (tx_fifo_reset == 1'b1) begin
        wr_fifo_status <= 4'b0;
     end
     else begin
        if (wr_addr_diff == 12'b0) begin
           wr_fifo_status <= 4'b0;
        end
        else begin
           wr_fifo_status[3] <= !wr_addr_diff[11];
           wr_fifo_status[2] <= !wr_addr_diff[10];
           wr_fifo_status[1] <= !wr_addr_diff[9];
           wr_fifo_status[0] <= !wr_addr_diff[8];
        end
     end
  end
  assign fifo_status = wr_fifo_status;
  assign wr_eof_data_bram[8]   = wr_eof_bram[0];
  assign wr_eof_data_bram[7:0] = wr_data_bram;
  assign rd_eof_bram_l[0] = rd_eof_data_bram_l[8];
  assign rd_data_bram_l   = rd_eof_data_bram_l[7:0];
  BRAM_TDP_MACRO #
  (
     .DEVICE        ("VIRTEX6"),
     .BRAM_SIZE     ("18Kb"),
     .WRITE_WIDTH_A (9),
     .WRITE_WIDTH_B (9),
     .READ_WIDTH_A  (9),
     .READ_WIDTH_B  (9)
  )
  ramgen_l (
     .DOA    (rd_bram_l_unused),
     .DOB    (rd_eof_data_bram_l),
     .ADDRA  (wr_addr[10:0]),
     .ADDRB  (rd_addr[10:0]),
     .CLKA   (tx_fifo_aclk),
     .CLKB   (tx_mac_aclk),
     .DIA    (wr_eof_data_bram),
     .DIB    (GND_BUS[8:0]),
     .ENA    (VCC),
     .ENB    (rd_en),
     .REGCEA (VCC),
     .REGCEB (VCC),
     .RSTA   (tx_fifo_reset),
     .RSTB   (tx_mac_reset),
     .WEA    (wr_en_l_bram),
     .WEB    (GND)
  );
  assign rd_eof_bram_u[0] = rd_eof_data_bram_u[8];
  assign rd_data_bram_u   = rd_eof_data_bram_u[7:0];
  BRAM_TDP_MACRO #
  (
     .DEVICE        ("VIRTEX6"),
     .BRAM_SIZE     ("18Kb"),
     .WRITE_WIDTH_A (9),
     .WRITE_WIDTH_B (9),
     .READ_WIDTH_A  (9),
     .READ_WIDTH_B  (9)
  )
  ramgen_u (
     .DOA    (rd_bram_u_unused),
     .DOB    (rd_eof_data_bram_u),
     .ADDRA  (wr_addr[10:0]),
     .ADDRB  (rd_addr[10:0]),
     .CLKA   (tx_fifo_aclk),
     .CLKB   (tx_mac_aclk),
     .DIA    (wr_eof_data_bram),
     .DIB    (GND_BUS[8:0]),
     .ENA    (VCC),
     .ENB    (rd_en),
     .REGCEA (VCC),
     .REGCEB (VCC),
     .RSTA   (tx_fifo_reset),
     .RSTB   (tx_mac_reset),
     .WEA    (wr_en_u_bram),
     .WEB    (GND)
  );
endmodule
