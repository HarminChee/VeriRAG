`timescale 1ps / 1ps
`timescale 1ps / 1ps
module rx_client_fifo
  (
    input            rx_fifo_aclk,
    input            rx_fifo_resetn,
    output reg [7:0] rx_axis_fifo_tdata,
    output reg       rx_axis_fifo_tvalid,
    output           rx_axis_fifo_tlast,
    input            rx_axis_fifo_tready,
    input            rx_mac_aclk,
    input            rx_mac_resetn,
    input [7:0]      rx_axis_mac_tdata,
    input            rx_axis_mac_tvalid,
    input            rx_axis_mac_tlast,
    output reg       rx_axis_mac_tready,
    input            rx_axis_mac_tuser,
    output [3:0]     fifo_status,
    output           fifo_overflow
  );
  wire       GND;
  wire       VCC;
  wire [8:0] GND_BUS;
  parameter WAIT_s      = 3'b000;
  parameter QUEUE1_s    = 3'b001;
  parameter QUEUE2_s    = 3'b010;
  parameter QUEUE3_s    = 3'b011;
  parameter QUEUE_SOF_s = 3'b100;
  parameter SOF_s       = 3'b101;
  parameter DATA_s      = 3'b110;
  parameter EOF_s       = 3'b111;
  reg [2:0]   rd_state;
  reg [2:0]   rd_nxt_state;
  parameter IDLE_s   = 3'b000;
  parameter FRAME_s  = 3'b001;
  parameter GF_s     = 3'b010;
  parameter BF_s     = 3'b011;
  parameter OVFLOW_s = 3'b100;
  reg  [2:0]  wr_state;
  reg  [2:0]  wr_nxt_state;
  wire        wr_en;
  wire        wr_en_u;
  wire [0:0]  wr_en_u_bram;
  wire        wr_en_l;
  wire [0:0]  wr_en_l_bram;
  reg  [11:0] wr_addr;
  wire        wr_addr_inc;
  wire        wr_start_addr_load;
  wire        wr_addr_reload;
  reg  [11:0] wr_start_addr;
  wire [8:0]  wr_eof_data_bram;
  reg  [7:0]  wr_data_bram;
  reg  [7:0]  wr_data_pipe[0:1];
  reg         wr_dv_pipe[0:2];
  reg         wr_gfbf_pipe[0:1];
  reg         wr_gf;
  reg         wr_bf;
  reg         wr_eof_bram_pipe[0:1];
  reg         wr_eof_bram;
  reg         frame_in_fifo;
  reg  [11:0] rd_addr;
  wire        rd_addr_inc;
  reg         rd_addr_reload;
  wire [8:0]  rd_eof_data_bram_u;
  wire [8:0]  rd_eof_data_bram_l;
  wire [7:0]  rd_data_bram_u;
  wire [7:0]  rd_data_bram_l;
  reg  [7:0]  rd_data_pipe_u;
  reg  [7:0]  rd_data_pipe_l;
  reg  [7:0]  rd_data_pipe;
  reg  [1:0]  rd_valid_pipe;
  wire [0:0]  rd_eof_bram_u;
  wire [0:0]  rd_eof_bram_l;
  reg         rd_en;
  reg         rd_bram_u;
  reg         rd_bram_u_reg;
  reg         rd_pull_frame;
  reg         rd_eof;
  reg         wr_store_frame_tog = 1'b0;
  wire        rd_store_frame_sync;
  reg         rd_store_frame_delay = 1'b0;
  reg         rd_store_frame;
  reg  [8:0]  rd_frames;
  reg         wr_fifo_full;
  reg  [1:0]  old_rd_addr;
  reg         update_addr_tog;
  wire        update_addr_tog_sync;
  reg         update_addr_tog_sync_reg;
  reg  [11:0] wr_rd_addr;
  wire [12:0] wr_addr_diff_in;
  reg  [11:0] wr_addr_diff;
  reg  [3:0]  wr_fifo_status;
  reg         rx_axis_fifo_tlast_int;
  wire        rx_fifo_reset;
  wire        rx_mac_reset;
  assign rx_fifo_reset = !rx_fifo_resetn;
  assign rx_mac_reset  = !rx_mac_resetn;
  assign GND     = 1'b0;
  assign VCC     = 1'b1;
  assign GND_BUS = 9'b0;
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rd_state <= WAIT_s;
     end
     else begin
        rd_state <= rd_nxt_state;
     end
  end
  assign rx_axis_fifo_tlast = rx_axis_fifo_tlast_int;
  always @(rd_state, frame_in_fifo, rd_eof, rx_axis_fifo_tready, rx_axis_fifo_tlast_int,
           rd_valid_pipe)
  begin
     case (rd_state)
        WAIT_s : begin
           if (frame_in_fifo == 1'b1 && rx_axis_fifo_tlast_int == 1'b0) begin
              rd_nxt_state <= QUEUE1_s;
           end
           else begin
              rd_nxt_state <= WAIT_s;
           end
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
           if (rx_axis_fifo_tready == 1'b1) begin
              rd_nxt_state <= DATA_s;
           end
           else begin
              rd_nxt_state <= SOF_s;
           end
        end
        DATA_s : begin
           if (rx_axis_fifo_tready == 1'b1 && rd_eof == 1'b1) begin
              rd_nxt_state <= EOF_s;
           end
           else begin
              rd_nxt_state <= DATA_s;
           end
        end
        EOF_s : begin
           if (rx_axis_fifo_tready == 1'b1) begin
              if (rd_valid_pipe[1] == 1'b1) begin
                 rd_nxt_state <= SOF_s;
              end
              else begin
                 rd_nxt_state <= WAIT_s;
              end
           end
           else begin
              rd_nxt_state <= EOF_s;
           end
         end
         default : begin
           rd_nxt_state <= WAIT_s;
         end
     endcase
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_axis_fifo_tready == 1'b1) begin
        rd_valid_pipe <= {rd_valid_pipe[0], frame_in_fifo};
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rx_axis_fifo_tlast_int <= 1'b0;
     end
     else if (rx_axis_fifo_tready == 1'b1) begin
        case (rd_state)
           EOF_s :
              rx_axis_fifo_tlast_int <= 1'b1;
           default :
              rx_axis_fifo_tlast_int <= 1'b0;
        endcase
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rx_axis_fifo_tvalid <= 1'b0;
     end
     else begin
        case (rd_state)
           QUEUE_SOF_s :
              rx_axis_fifo_tvalid <= 1'b1;
           SOF_s :
              rx_axis_fifo_tvalid <= 1'b1;
           DATA_s :
              rx_axis_fifo_tvalid <= 1'b1;
           EOF_s :
              rx_axis_fifo_tvalid <= 1'b1;
           default :
              if (rx_axis_fifo_tready == 1'b1) begin
                 rx_axis_fifo_tvalid <= 1'b0;
              end
         endcase
     end
  end
  always @(rd_state, rx_axis_fifo_tready)
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
            rd_en <= rx_axis_fifo_tready;
     endcase
  end
  assign rd_addr_inc = rd_en;
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rd_addr_reload <= 1'b0;
     end
     else begin
        if (rd_state == EOF_s && rd_nxt_state == WAIT_s)
           rd_addr_reload <= 1'b1;
        else
           rd_addr_reload <= 1'b0;
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        frame_in_fifo <= 1'b0;
     end
     else begin
        if (rd_frames != 9'b0) begin
           frame_in_fifo <= 1'b1;
        end
        else begin
           frame_in_fifo <= 1'b0;
        end
     end
  end
  sync_block resync_wr_store_frame_tog
  (
    .clk       (rx_fifo_aclk),
    .data_in   (wr_store_frame_tog),
    .data_out  (rd_store_frame_sync)
  );
  always @(posedge rx_fifo_aclk)
  begin
     rd_store_frame_delay <= rd_store_frame_sync;
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rd_store_frame       <= 1'b0;
     end
     else begin
        if ((rd_store_frame_delay ^ rd_store_frame_sync) == 1'b1) begin
           rd_store_frame    <= 1'b1;
        end
        else begin
           rd_store_frame    <= 1'b0;
        end
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rd_pull_frame <= 1'b0;
     end
     else begin
        if (rd_state == SOF_s && rd_nxt_state != SOF_s) begin
           rd_pull_frame <= 1'b1;
        end
        else if (rd_state == QUEUE_SOF_s && rd_nxt_state != QUEUE_SOF_s) begin
           rd_pull_frame <= 1'b1;
        end
        else begin
           rd_pull_frame <= 1'b0;
        end
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rd_frames <= 9'b0;
     end
     else begin
        if (rd_store_frame == 1'b1 && rd_pull_frame == 1'b0) begin
           rd_frames <= rd_frames + 9'b1;
        end
        else if (rd_store_frame == 1'b0 && rd_pull_frame == 1'b1) begin
           rd_frames <= rd_frames - 9'b1;
        end
     end
  end
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
        wr_state <= IDLE_s;
     end
     else begin
        wr_state <= wr_nxt_state;
     end
  end
  always @(wr_state, wr_dv_pipe[1], wr_gf, wr_bf, wr_fifo_full)
  begin
     case (wr_state)
        IDLE_s : begin
           if (wr_dv_pipe[1] == 1'b1) begin
              wr_nxt_state <= FRAME_s;
           end
           else begin
              wr_nxt_state <= IDLE_s;
           end
        end
        FRAME_s : begin
           if (wr_fifo_full == 1'b1) begin
              wr_nxt_state <= OVFLOW_s;
           end
           else if (wr_gf == 1'b1) begin
              wr_nxt_state <= GF_s;
           end
           else if (wr_bf == 1'b1) begin
              wr_nxt_state <= BF_s;
           end
           else begin
              wr_nxt_state <= FRAME_s;
           end
        end
        GF_s : begin
           wr_nxt_state <= IDLE_s;
        end
        BF_s : begin
           wr_nxt_state <= IDLE_s;
        end
        OVFLOW_s : begin
           if (wr_gf == 1'b1 || wr_bf == 1'b1) begin
              wr_nxt_state <= IDLE_s;
           end
           else begin
              wr_nxt_state <= OVFLOW_s;
           end
        end
        default : begin
           wr_nxt_state <= IDLE_s;
        end
     endcase
  end
  assign wr_en = (wr_state == FRAME_s) ? wr_dv_pipe[2] : 1'b0;
  assign wr_en_l = wr_en & !wr_addr[11];
  assign wr_en_u = wr_en &  wr_addr[11];
  assign wr_en_l_bram[0] = wr_en_l;
  assign wr_en_u_bram[0] = wr_en_u;
  assign wr_addr_inc = (wr_state == FRAME_s) ? wr_dv_pipe[2] : 1'b0;
  assign wr_addr_reload = (wr_state == BF_s || wr_state == OVFLOW_s)
                          ? 1'b1 : 1'b0;
  assign wr_start_addr_load = (wr_state == IDLE_s) ? 1'b1 : 1'b0;
  always @(posedge rx_mac_aclk)
  begin
     if (wr_state == GF_s) begin
        wr_store_frame_tog <= !wr_store_frame_tog;
     end
  end
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
        wr_addr <= 12'b0;
     end
     else begin
        if (wr_addr_reload == 1'b1) begin
           wr_addr <= wr_start_addr;
        end
        else if (wr_addr_inc == 1'b1) begin
           wr_addr <= wr_addr + 12'b1;
        end
     end
  end
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
        wr_start_addr <= 12'b0;
     end
     else begin
        if (wr_start_addr_load == 1'b1) begin
           wr_start_addr <= wr_addr;
        end
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rd_addr <= 12'd0;
     end
     else begin
        if (rd_addr_reload == 1'b1) begin
           rd_addr <= rd_addr - 12'd3;
        end
        else if (rd_addr_inc == 1'b1) begin
           rd_addr <= rd_addr + 12'd1;
        end
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        rd_bram_u <= 1'b0;
        rd_bram_u_reg <= 1'b0;
     end
     else if (rd_addr_inc == 1'b1) begin
        rd_bram_u <= rd_addr[11];
        rd_bram_u_reg <= rd_bram_u;
     end
  end
  always @(posedge rx_mac_aclk)
  begin
     wr_data_pipe[0] <= rx_axis_mac_tdata;
     wr_data_pipe[1] <= wr_data_pipe[0];
     wr_data_bram    <= wr_data_pipe[1];
  end
  always @(posedge rx_mac_aclk)
  begin
     wr_dv_pipe[0] <= rx_axis_mac_tvalid;
     wr_dv_pipe[1] <= wr_dv_pipe[0];
     wr_dv_pipe[2] <= wr_dv_pipe[1];
  end
  always @(posedge rx_mac_aclk)
  begin
     wr_eof_bram_pipe[0] <= rx_axis_mac_tlast;
     wr_eof_bram_pipe[1] <= wr_eof_bram_pipe[0];
     wr_eof_bram <= wr_eof_bram_pipe[1] & wr_dv_pipe[1];
  end
  always @(posedge rx_mac_aclk)
  begin
     wr_gfbf_pipe[0] <= rx_axis_mac_tuser;
     wr_gfbf_pipe[1] <= wr_gfbf_pipe[0];
     wr_gf <= !wr_gfbf_pipe[1] & wr_eof_bram_pipe[1] & wr_dv_pipe[1];
     wr_bf <=  wr_gfbf_pipe[1] & wr_eof_bram_pipe[1] & wr_dv_pipe[1];
  end
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
        rx_axis_mac_tready <= 1'b0;
     end
     else begin
        rx_axis_mac_tready <= 1'b1;
     end
  end
  always @(posedge rx_fifo_aclk)
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
        rx_axis_fifo_tdata <= rd_data_pipe;
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rd_en == 1'b1) begin
        if (rd_bram_u == 1'b1) begin
           rd_eof <= rd_eof_bram_u[0];
        end
        else begin
           rd_eof <= rd_eof_bram_l[0];
        end
     end
  end
  always @(posedge rx_fifo_aclk)
  begin
     if (rx_fifo_reset == 1'b1) begin
        old_rd_addr <= 2'b00;
        update_addr_tog <= 1'b0;
     end
     else begin
        old_rd_addr <= rd_addr[5:4];
        if (rd_addr[5:4] == 2'b10 & old_rd_addr == 2'b01) begin
           update_addr_tog <= !update_addr_tog;
        end
     end
  end
  sync_block sync_rd_addr_tog
  (
    .clk      (rx_mac_aclk),
    .data_in  (update_addr_tog),
    .data_out (update_addr_tog_sync)
  );
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
        update_addr_tog_sync_reg <= 1'b0;
        wr_rd_addr               <= 12'd0;
     end
     else begin
        update_addr_tog_sync_reg <= update_addr_tog_sync;
        if (update_addr_tog_sync_reg ^ update_addr_tog_sync) begin
           wr_rd_addr <= {rd_addr[11:6], 6'd0};
        end
     end
  end
  assign wr_addr_diff_in = {1'b0,wr_rd_addr} - {1'b0,wr_addr};
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
        wr_addr_diff <= 12'b0;
     end
     else begin
        wr_addr_diff <= wr_addr_diff_in[11:0];
     end
  end
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
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
  assign fifo_overflow = (wr_state == OVFLOW_s) ? 1'b1 : 1'b0;
  always @(posedge rx_mac_aclk)
  begin
     if (rx_mac_reset == 1'b1) begin
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
  assign wr_eof_data_bram[8]   = wr_eof_bram;
  assign wr_eof_data_bram[7:0] = wr_data_bram;
  assign rd_eof_bram_l[0] = rd_eof_data_bram_l[8];
  assign rd_data_bram_l   = rd_eof_data_bram_l[7:0];
  BRAM_TDP_MACRO #
  (
     .DEVICE        ("VIRTEX6"),
     .WRITE_WIDTH_A (9),
     .WRITE_WIDTH_B (9),
     .READ_WIDTH_A  (9),
     .READ_WIDTH_B  (9)
  )
  ramgen_l (
     .DOA    (),
     .DOB    (rd_eof_data_bram_l),
     .ADDRA  (wr_addr[10:0]),
     .ADDRB  (rd_addr[10:0]),
     .CLKA   (rx_mac_aclk),
     .CLKB   (rx_fifo_aclk),
     .DIA    (wr_eof_data_bram),
     .DIB    (GND_BUS[8:0]),
     .ENA    (VCC),
     .ENB    (rd_en),
     .REGCEA (VCC),
     .REGCEB (VCC),
     .RSTA   (rx_mac_reset),
     .RSTB   (rx_fifo_reset),
     .WEA    (wr_en_l_bram),
     .WEB    (GND)
  );
  assign rd_eof_bram_u[0] = rd_eof_data_bram_u[8];
  assign rd_data_bram_u   = rd_eof_data_bram_u[7:0];
  BRAM_TDP_MACRO #
  (
     .DEVICE        ("VIRTEX6"),
     .WRITE_WIDTH_A (9),
     .WRITE_WIDTH_B (9),
     .READ_WIDTH_A  (9),
     .READ_WIDTH_B  (9)
  )
  ramgen_u (
     .DOA    (),
     .DOB    (rd_eof_data_bram_u),
     .ADDRA  (wr_addr[10:0]),
     .ADDRB  (rd_addr[10:0]),
     .CLKA   (rx_mac_aclk),
     .CLKB   (rx_fifo_aclk),
     .DIA    (wr_eof_data_bram),
     .DIB    (GND_BUS[8:0]),
     .ENA    (VCC),
     .ENB    (rd_en),
     .REGCEA (VCC),
     .REGCEB (VCC),
     .RSTA   (rx_mac_reset),
     .RSTB   (rx_fifo_reset),
     .WEA    (wr_en_u_bram),
     .WEB    (GND)
  );
endmodule
