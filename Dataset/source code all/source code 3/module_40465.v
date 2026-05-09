`timescale 1ps / 1ps
`timescale 1ps / 1ps
module rx_client_fifo_8 (
   rd_clk,
   rd_sreset,
   rd_data_out,
   rd_sof_n,
   rd_eof_n,
   rd_src_rdy_n,
   rd_dst_rdy_n,
   rx_fifo_status,
   wr_sreset,
   wr_clk,
   wr_enable,
   rx_data,
   rx_data_valid,
   rx_good_frame,
   rx_bad_frame,
   overflow
);
  input        rd_clk;
  input        rd_sreset;
  output [7:0] rd_data_out;
  output       rd_sof_n;
  output       rd_eof_n;
  output       rd_src_rdy_n;
  input        rd_dst_rdy_n;
  output [3:0] rx_fifo_status;
  input        wr_sreset;
  input        wr_clk;
  input        wr_enable;
  input [7:0]  rx_data;
  input        rx_data_valid;
  input        rx_good_frame;
  input        rx_bad_frame;
  output       overflow;
  reg [7:0]    rd_data_out;
  wire        GND;
  wire        VCC;
  wire [31:0] GND_BUS;
  parameter WAIT_s = 3'b000;      parameter QUEUE1_s = 3'b001;
  parameter QUEUE2_s = 3'b010;    parameter QUEUE3_s = 3'b011;
  parameter QUEUE_SOF_s = 3'b100; parameter SOF_s = 3'b101;
  parameter DATA_s = 3'b110;      parameter EOF_s = 3'b111;
  reg [2:0]   rd_state;
  reg [2:0]   rd_nxt_state;
  parameter IDLE_s = 3'b000; parameter FRAME_s = 3'b001;
  parameter END_s= 3'b010;   parameter GF_s = 3'b011;
  parameter BF_s = 3'b100;   parameter OVFLOW_s = 3'b101;
  reg  [2:0]  wr_state;
  reg  [2:0]  wr_nxt_state;
  wire        wr_en;
  reg  [11:0] wr_addr;
  wire        wr_addr_inc;
  wire        wr_start_addr_load;
  wire        wr_addr_reload;
  reg  [11:0] wr_start_addr;
  reg  [7:0]  wr_data_bram;
  reg  [7:0]  wr_data_pipe[0:1];
  reg  [0:0]  wr_eof_bram;
  reg         wr_dv_pipe[0:1];
  reg         wr_gf_pipe[0:1];
  reg         wr_bf_pipe[0:1];
  reg         frame_in_fifo;
  reg  [11:0] rd_addr;
  wire        rd_addr_inc;
  wire        rd_addr_reload;
  wire [7:0]  rd_data_bram;
  reg  [7:0]  rd_data_pipe;
  reg         rd_en;
  wire        rd_pull_frame;
  wire        rd_eof;
  wire [31:0] dob_bram;
  wire [3:0]  dopb_bram;
  reg         wr_store_frame_tog;
  reg         rd_store_frame_tog;
  reg         rd_store_frame_delay;
  reg         rd_store_frame_sync;
  reg         rd_store_frame;
  reg  [8:0]  rd_frames;
  reg         wr_fifo_full;
  reg  [11:0] rd_addr_gray;
  reg  [11:0] wr_rd_addr_gray_sync;
  reg  [11:0] wr_rd_addr_gray;
  wire [11:0] wr_rd_addr;
  reg  [11:0] wr_addr_diff;
  reg  [3:0]  wr_fifo_status;
  reg         rd_sof_n_int     = 1'b1;
  reg         rd_eof_n_int     = 1'b1;
  reg         rd_src_rdy_n_int = 1'b1;
  reg  [2:0]  rd_valid_pipe;
  function [11:0] bin_to_gray;
  input    [11:0] bin;
  integer         i;
  begin
     for (i=0;i<12;i=i+1)
        begin
          if (i == 11)
             bin_to_gray[i] = bin[i];
          else
             bin_to_gray[i] = bin[i+1] ^ bin[i];
        end
  end
  endfunction
  function [11:0] gray_to_bin;
  input   [11:0] gray;
  integer        i;
  begin
     for (i=11;i>=0;i=i-1)
        begin
          if (i == 11)
            gray_to_bin[i] = gray[i];
          else
            gray_to_bin[i] = gray_to_bin[i+1] ^ gray[i];
        end
  end
  endfunction 
  assign GND     = 1'b0;
  assign VCC     = 1'b1;
  assign GND_BUS = 32'b0;
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_state <= WAIT_s;
     else
        rd_state <= rd_nxt_state;
  end
  assign rd_eof_n = rd_eof_n_int;
  always @(rd_state or frame_in_fifo or rd_eof or rd_dst_rdy_n or rd_eof_n_int or rd_valid_pipe[1])
  begin
     case (rd_state)
        WAIT_s : begin
           if (frame_in_fifo == 1'b1 && rd_eof_n_int == 1'b1)
              rd_nxt_state <= QUEUE1_s;
           else
              rd_nxt_state <= WAIT_s;
           end
        QUEUE1_s : begin
           rd_nxt_state <= QUEUE2_s;
           end
        QUEUE2_s : begin
           rd_nxt_state <= QUEUE3_s;
           end
        QUEUE3_s : begin
           rd_nxt_state <= QUEUE_SOF_s;
           end
        QUEUE_SOF_s : begin
              rd_nxt_state <= DATA_s;  
           end
        SOF_s : begin
           if (rd_dst_rdy_n == 1'b0)
              rd_nxt_state <= DATA_s;
           else
              rd_nxt_state <= SOF_s;
           end
        DATA_s : begin
           if (rd_dst_rdy_n == 1'b0 && rd_eof == 1'b1)
              rd_nxt_state <= EOF_s;
           else
              rd_nxt_state <= DATA_s;
           end
        EOF_s : begin
           if (rd_dst_rdy_n == 1'b0)
              if (rd_valid_pipe[1] == 1'b1)
                 rd_nxt_state <= SOF_s;
              else
                 rd_nxt_state <= WAIT_s;
              else
              rd_nxt_state <= EOF_s;
           end
        default : begin
           rd_nxt_state <= WAIT_s;
           end
        endcase
  end
  always @(posedge rd_clk)
  begin
    if (rd_dst_rdy_n == 1'b0)
      rd_valid_pipe <= {rd_valid_pipe[1], rd_valid_pipe[0], frame_in_fifo};
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_sof_n_int <= 1'b1;
     else
        case (rd_state)
           QUEUE_SOF_s :
              rd_sof_n_int <= 1'b0;
           SOF_s :
              if (rd_dst_rdy_n == 1'b0)
                 rd_sof_n_int <= 1'b0;
           default :
              if (rd_dst_rdy_n == 1'b0)
                 rd_sof_n_int <= 1'b1;
        endcase
  end
  assign rd_sof_n = rd_sof_n_int;
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_eof_n_int <= 1'b1;
     else if (rd_dst_rdy_n == 1'b0)
        case (rd_state)
           EOF_s :
               rd_eof_n_int <= 1'b0;
           default :
              rd_eof_n_int <= 1'b1;
        endcase
  end
  always @(posedge rd_clk)
  begin
     if (rd_en == 1'b1)
     begin
        rd_data_out  <= rd_data_pipe;
        rd_data_pipe <= rd_data_bram;
     end
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_src_rdy_n_int <= 1'b1;
     else
        case (rd_state)
           QUEUE_SOF_s :
              rd_src_rdy_n_int <= 1'b0;
           SOF_s :
              rd_src_rdy_n_int <= 1'b0;
           DATA_s :
              rd_src_rdy_n_int <= 1'b0;
           EOF_s :
              rd_src_rdy_n_int <= 1'b0;
           default :
              if (rd_dst_rdy_n == 1'b0)
                 rd_src_rdy_n_int <= 1'b1;
         endcase
  end
  assign rd_src_rdy_n = rd_src_rdy_n_int;
  always @(rd_state or rd_dst_rdy_n)
  begin
     case (rd_state)
         WAIT_s :
              rd_en <= 1'b0;
         QUEUE1_s :
              rd_en <= 1'b1;
         QUEUE2_s :
              rd_en <= 1'b1;
         QUEUE3_s :
              rd_en <= 1'b1;
         QUEUE_SOF_s :
              rd_en <= 1'b1;
         default :
              rd_en <= !rd_dst_rdy_n;
         endcase
  end
  assign rd_addr_inc = rd_en;
  assign rd_addr_reload = (rd_state == EOF_s && rd_nxt_state == WAIT_s) ? 1'b1 : 1'b0;
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        frame_in_fifo <= 1'b0;
     else
        if (rd_frames != 9'b0)
           frame_in_fifo <= 1'b1;
        else
           frame_in_fifo <= 1'b0;
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        begin
           rd_store_frame_tog  <= 1'b0;
           rd_store_frame_sync <= 1'b0;
           rd_store_frame_delay <= 1'b0;
           rd_store_frame      <= 1'b0;
        end
     else
        begin
           rd_store_frame_tog  <= wr_store_frame_tog;
           rd_store_frame_sync <= rd_store_frame_tog;
           rd_store_frame_delay <= rd_store_frame_sync;
           if ((rd_store_frame_delay ^ rd_store_frame_sync) == 1'b1)
              rd_store_frame    <= 1'b1;
           else
              rd_store_frame    <= 1'b0;
        end
  end
  assign rd_pull_frame = (rd_state == SOF_s && rd_nxt_state != SOF_s) ? 1'b1 :
                         (rd_state == QUEUE_SOF_s && rd_nxt_state != QUEUE_SOF_s) ? 1'b1 : 1'b0;
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_frames <= 9'b0;
     else
        if (rd_store_frame == 1'b1 && rd_pull_frame == 1'b0)
           rd_frames <= rd_frames + 9'b1;
        else if (rd_store_frame == 1'b0 && rd_pull_frame == 1'b1)
           rd_frames <= rd_frames - 9'b1;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_state <= IDLE_s;
     else if (wr_enable == 1'b1)
        wr_state <= wr_nxt_state;
  end
  always @(wr_state or wr_dv_pipe[1] or wr_gf_pipe[1] or wr_bf_pipe[1] or wr_eof_bram[0] or wr_fifo_full)
  begin
     case (wr_state)
        IDLE_s : begin
           if (wr_dv_pipe[1] == 1'b1)
              wr_nxt_state <= FRAME_s;
           else
              wr_nxt_state <= IDLE_s;
           end
        FRAME_s : begin
              if (wr_fifo_full == 1'b1)
                 wr_nxt_state <= OVFLOW_s;
              else if (wr_gf_pipe[1] == 1'b1)
                 wr_nxt_state <= GF_s;
              else if (wr_bf_pipe[1] == 1'b1)
                 wr_nxt_state <= BF_s;
              else if (wr_eof_bram[0] == 1'b1)
                 wr_nxt_state <= END_s;
              else
                 wr_nxt_state <= FRAME_s;
              end
           END_s : begin
              if (wr_gf_pipe[1] == 1'b1)
                 wr_nxt_state <= GF_s;
              else if (wr_bf_pipe[1] == 1'b1)
                 wr_nxt_state <= BF_s;
              else
                 wr_nxt_state <= END_s;
              end
           GF_s : begin
              wr_nxt_state <= IDLE_s;
              end
           BF_s : begin
              wr_nxt_state <= IDLE_s;
              end
           OVFLOW_s : begin
              if (wr_gf_pipe[1] == 1'b1 || wr_bf_pipe[1] == 1'b1)
                 wr_nxt_state <= IDLE_s;
              else
                 wr_nxt_state <= OVFLOW_s;
              end
           default : begin
              wr_nxt_state <= IDLE_s;
              end
        endcase
  end
  assign wr_en = (wr_state == FRAME_s) ? 1'b1 : 1'b0;
  assign wr_addr_inc = (wr_state == FRAME_s) ? 1'b1 : 1'b0;
  assign wr_addr_reload = (wr_state == BF_s || wr_state == OVFLOW_s) ? 1'b1 : 1'b0;
  assign wr_start_addr_load = (wr_state == IDLE_s) ? 1'b1 : 1'b0;
  always @(posedge wr_clk)
  begin  
     if (wr_sreset == 1'b1)
        wr_store_frame_tog <= 1'b0;
     else if (wr_enable == 1'b1)
        if (wr_state == GF_s)
           wr_store_frame_tog <= ! wr_store_frame_tog;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_addr <= 12'b0;
     else if (wr_enable == 1'b1)
        if (wr_addr_reload == 1'b1)
           wr_addr <= wr_start_addr;
        else if (wr_addr_inc == 1'b1)
           wr_addr <= wr_addr + 12'b1;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_start_addr <= 12'b0;
     else if (wr_enable == 1'b1)
        if (wr_start_addr_load == 1'b1)
           wr_start_addr <= wr_addr;
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_addr <= 12'b0;
     else
        if (rd_addr_reload == 1'b1)
           rd_addr <= rd_addr - 12'd2;
        else if (rd_addr_inc == 1'b1)
           rd_addr <= rd_addr + 12'b1;
  end
  always @(posedge wr_clk)
  begin
     if (wr_enable == 1'b1)
        begin
           wr_data_pipe[0] <= rx_data;
           wr_data_pipe[1] <= wr_data_pipe[0];
           wr_data_bram    <= wr_data_pipe[1];
        end
  end
  always @(posedge wr_clk)
  begin
     if (wr_enable == 1'b1)
        begin
           wr_dv_pipe[0] <= rx_data_valid;
           wr_dv_pipe[1] <= wr_dv_pipe[0];
           wr_eof_bram[0] <= wr_dv_pipe[1] & !wr_dv_pipe[0];
        end
  end
  always @(posedge wr_clk)
  begin
     if (wr_enable == 1'b1)
        begin
           wr_gf_pipe[0] <= rx_good_frame;
           wr_gf_pipe[1] <= wr_gf_pipe[0];
           wr_bf_pipe[0] <= rx_bad_frame;
           wr_bf_pipe[1] <= wr_bf_pipe[0];
        end
  end
  always @(posedge rd_clk)
  begin
     if (rd_sreset == 1'b1)
        rd_addr_gray <= 12'b0;
     else
        rd_addr_gray <= bin_to_gray(rd_addr);
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        begin
           wr_rd_addr_gray_sync <= 12'b0;
           wr_rd_addr_gray <= 12'b0;
        end
     else if (wr_enable == 1'b1)
        begin
           wr_rd_addr_gray_sync <= rd_addr_gray;
           wr_rd_addr_gray <= wr_rd_addr_gray_sync;
        end
  end
  assign wr_rd_addr = gray_to_bin(wr_rd_addr_gray);
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_addr_diff <= 12'b0;
     else if (wr_enable == 1'b1)
        wr_addr_diff <= wr_rd_addr - wr_addr;
  end
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
        wr_fifo_full <= 1'b0;
     else if (wr_enable == 1'b1)
        if (wr_addr_diff[11:4] == 8'b0 && wr_addr_diff[3:2] != 2'b0)
           wr_fifo_full <= 1'b1;
        else
           wr_fifo_full <= 1'b0;
  end
  assign overflow = (wr_state == OVFLOW_s) ? 1'b1 : 1'b0;
  always @(posedge wr_clk)
  begin
     if (wr_sreset == 1'b1)
         wr_fifo_status <= 4'b0;
     else if (wr_enable == 1'b1)
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
  assign rx_fifo_status = wr_fifo_status;
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
    .ENBWREN       (rd_en),
    .CLKBWRCLK     (rd_clk),
    .RSTRAMB       (rd_sreset),
    .RSTREGB       (rd_sreset),
    .CASCADEINB    (GND),
    .REGCEB        (rd_en),
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
  assign rd_eof       = dopb_bram[0];
endmodule
