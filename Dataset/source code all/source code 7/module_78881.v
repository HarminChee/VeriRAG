`timescale 1ns / 1ps
`timescale 1ns / 1ps
module wasca_jtag_uart_0_scfifo_w (
                                     clk,
                                     fifo_clear,
                                     fifo_wdata,
                                     fifo_wr,
                                     rd_wfifo,
                                     fifo_FF,
                                     r_dat,
                                     wfifo_empty,
                                     wfifo_used
                                  )
;
  output           fifo_FF;
  output  [  7: 0] r_dat;
  output           wfifo_empty;
  output  [  5: 0] wfifo_used;
  input            clk;
  input            fifo_clear;
  input   [  7: 0] fifo_wdata;
  input            fifo_wr;
  input            rd_wfifo;
  wire             fifo_FF;
  wire    [  7: 0] r_dat;
  wire             wfifo_empty;
  wire    [  5: 0] wfifo_used;
  wasca_jtag_uart_0_sim_scfifo_w the_wasca_jtag_uart_0_sim_scfifo_w
    (
      .clk         (clk),
      .fifo_FF     (fifo_FF),
      .fifo_wdata  (fifo_wdata),
      .fifo_wr     (fifo_wr),
      .r_dat       (r_dat),
      .wfifo_empty (wfifo_empty),
      .wfifo_used  (wfifo_used)
    );
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0_sim_scfifo_r (
                                         clk,
                                         fifo_rd,
                                         rst_n,
                                         fifo_EF,
                                         fifo_rdata,
                                         rfifo_full,
                                         rfifo_used
                                      )
;
  output           fifo_EF;
  output  [  7: 0] fifo_rdata;
  output           rfifo_full;
  output  [  5: 0] rfifo_used;
  input            clk;
  input            fifo_rd;
  input            rst_n;
  reg     [ 31: 0] bytes_left;
  wire             fifo_EF;
  reg              fifo_rd_d;
  wire    [  7: 0] fifo_rdata;
  wire             new_rom;
  wire    [ 31: 0] num_bytes;
  wire    [  6: 0] rfifo_entries;
  wire             rfifo_full;
  wire    [  5: 0] rfifo_used;
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          bytes_left <= 32'h0;
          fifo_rd_d <= 1'b0;
        end
      else 
        begin
          fifo_rd_d <= fifo_rd;
          if (fifo_rd_d)
              bytes_left <= bytes_left - 1'b1;
          if (new_rom)
              bytes_left <= num_bytes;
        end
    end
  assign fifo_EF = bytes_left == 32'b0;
  assign rfifo_full = bytes_left > 7'h40;
  assign rfifo_entries = (rfifo_full) ? 7'h40 : bytes_left;
  assign rfifo_used = rfifo_entries[5 : 0];
  assign new_rom = 1'b0;
  assign num_bytes = 32'b0;
  assign fifo_rdata = 8'b0;
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0_scfifo_r (
                                     clk,
                                     fifo_clear,
                                     fifo_rd,
                                     rst_n,
                                     t_dat,
                                     wr_rfifo,
                                     fifo_EF,
                                     fifo_rdata,
                                     rfifo_full,
                                     rfifo_used
                                  )
;
  output           fifo_EF;
  output  [  7: 0] fifo_rdata;
  output           rfifo_full;
  output  [  5: 0] rfifo_used;
  input            clk;
  input            fifo_clear;
  input            fifo_rd;
  input            rst_n;
  input   [  7: 0] t_dat;
  input            wr_rfifo;
  wire             fifo_EF;
  wire    [  7: 0] fifo_rdata;
  wire             rfifo_full;
  wire    [  5: 0] rfifo_used;
  wasca_jtag_uart_0_sim_scfifo_r the_wasca_jtag_uart_0_sim_scfifo_r
    (
      .clk        (clk),
      .fifo_EF    (fifo_EF),
      .fifo_rd    (fifo_rd),
      .fifo_rdata (fifo_rdata),
      .rfifo_full (rfifo_full),
      .rfifo_used (rfifo_used),
      .rst_n      (rst_n)
    );
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0 (
                            av_address,
                            av_chipselect,
                            av_read_n,
                            av_write_n,
                            av_writedata,
                            clk,
                            rst_n,
                            av_irq,
                            av_readdata,
                            av_waitrequest,
                            dataavailable,
                            readyfordata
                         )
   ;
  output           av_irq;
  output  [ 31: 0] av_readdata;
  output           av_waitrequest;
  output           dataavailable;
  output           readyfordata;
  input            av_address;
  input            av_chipselect;
  input            av_read_n;
  input            av_write_n;
  input   [ 31: 0] av_writedata;
  input            clk;
  input            rst_n;
  reg              ac;
  wire             activity;
  wire             av_irq;
  wire    [ 31: 0] av_readdata;
  reg              av_waitrequest;
  reg              dataavailable;
  reg              fifo_AE;
  reg              fifo_AF;
  wire             fifo_EF;
  wire             fifo_FF;
  wire             fifo_clear;
  wire             fifo_rd;
  wire    [  7: 0] fifo_rdata;
  wire    [  7: 0] fifo_wdata;
  reg              fifo_wr;
  reg              ien_AE;
  reg              ien_AF;
  wire             ipen_AE;
  wire             ipen_AF;
  reg              pause_irq;
  wire    [  7: 0] r_dat;
  wire             r_ena;
  reg              r_val;
  wire             rd_wfifo;
  reg              read_0;
  reg              readyfordata;
  wire             rfifo_full;
  wire    [  5: 0] rfifo_used;
  reg              rvalid;
  reg              sim_r_ena;
  reg              sim_t_dat;
  reg              sim_t_ena;
  reg              sim_t_pause;
  wire    [  7: 0] t_dat;
  reg              t_dav;
  wire             t_ena;
  wire             t_pause;
  wire             wfifo_empty;
  wire    [  5: 0] wfifo_used;
  reg              woverflow;
  wire             wr_rfifo;
  assign rd_wfifo = r_ena & ~wfifo_empty;
  assign wr_rfifo = t_ena & ~rfifo_full;
  assign fifo_clear = ~rst_n;
  wasca_jtag_uart_0_scfifo_w the_wasca_jtag_uart_0_scfifo_w
    (
      .clk         (clk),
      .fifo_FF     (fifo_FF),
      .fifo_clear  (fifo_clear),
      .fifo_wdata  (fifo_wdata),
      .fifo_wr     (fifo_wr),
      .r_dat       (r_dat),
      .rd_wfifo    (rd_wfifo),
      .wfifo_empty (wfifo_empty),
      .wfifo_used  (wfifo_used)
    );
  wasca_jtag_uart_0_scfifo_r the_wasca_jtag_uart_0_scfifo_r
    (
      .clk        (clk),
      .fifo_EF    (fifo_EF),
      .fifo_clear (fifo_clear),
      .fifo_rd    (fifo_rd),
      .fifo_rdata (fifo_rdata),
      .rfifo_full (rfifo_full),
      .rfifo_used (rfifo_used),
      .rst_n      (rst_n),
      .t_dat      (t_dat),
      .wr_rfifo   (wr_rfifo)
    );
  assign ipen_AE = ien_AE & fifo_AE;
  assign ipen_AF = ien_AF & (pause_irq | fifo_AF);
  assign av_irq = ipen_AE | ipen_AF;
  assign activity = t_pause | t_ena;
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
          pause_irq <= 1'b0;
      else 
      if (t_pause & ~fifo_EF)
          pause_irq <= 1'b1;
      else if (read_0)
          pause_irq <= 1'b0;
    end
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          r_val <= 1'b0;
          t_dav <= 1'b1;
        end
      else 
        begin
          r_val <= r_ena & ~wfifo_empty;
          t_dav <= ~rfifo_full;
        end
    end
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          fifo_AE <= 1'b0;
          fifo_AF <= 1'b0;
          fifo_wr <= 1'b0;
          rvalid <= 1'b0;
          read_0 <= 1'b0;
          ien_AE <= 1'b0;
          ien_AF <= 1'b0;
          ac <= 1'b0;
          woverflow <= 1'b0;
          av_waitrequest <= 1'b1;
        end
      else 
        begin
          fifo_AE <= {fifo_FF,wfifo_used} <= 8;
          fifo_AF <= (7'h40 - {rfifo_full,rfifo_used}) <= 8;
          fifo_wr <= 1'b0;
          read_0 <= 1'b0;
          av_waitrequest <= ~(av_chipselect & (~av_write_n | ~av_read_n) & av_waitrequest);
          if (activity)
              ac <= 1'b1;
          if (av_chipselect & ~av_write_n & av_waitrequest)
              if (av_address)
                begin
                  ien_AF <= av_writedata[0];
                  ien_AE <= av_writedata[1];
                  if (av_writedata[10] & ~activity)
                      ac <= 1'b0;
                end
              else 
                begin
                  fifo_wr <= ~fifo_FF;
                  woverflow <= fifo_FF;
                end
          if (av_chipselect & ~av_read_n & av_waitrequest)
            begin
              if (~av_address)
                  rvalid <= ~fifo_EF;
              read_0 <= ~av_address;
            end
        end
    end
  assign fifo_wdata = av_writedata[7 : 0];
  assign fifo_rd = (av_chipselect & ~av_read_n & av_waitrequest & ~av_address) ? ~fifo_EF : 1'b0;
  assign av_readdata = read_0 ? { {9{1'b0}},rfifo_full,rfifo_used,rvalid,woverflow,~fifo_FF,~fifo_EF,1'b0,ac,ipen_AE,ipen_AF,fifo_rdata } : { {9{1'b0}},(7'h40 - {fifo_FF,wfifo_used}),rvalid,woverflow,~fifo_FF,~fifo_EF,1'b0,ac,ipen_AE,ipen_AF,{6{1'b0}},ien_AE,ien_AF };
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
          readyfordata <= 0;
      else 
        readyfordata <= ~fifo_FF;
    end
  always @(posedge clk)
    begin
      sim_t_pause <= 1'b0;
      sim_t_ena <= 1'b0;
      sim_t_dat <= t_dav ? r_dat : {8{r_val}};
      sim_r_ena <= 1'b0;
    end
  assign r_ena = sim_r_ena;
  assign t_ena = sim_t_ena;
  assign t_dat = sim_t_dat;
  assign t_pause = sim_t_pause;
  always @(fifo_EF)
    begin
      dataavailable = ~fifo_EF;
    end
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0_sim_scfifo_w (
                                         clk,
                                         fifo_wdata,
                                         fifo_wr,
                                         fifo_FF,
                                         r_dat,
                                         wfifo_empty,
                                         wfifo_used
                                      )
;
  output           fifo_FF;
  output  [  7: 0] r_dat;
  output           wfifo_empty;
  output  [  5: 0] wfifo_used;
  input            clk;
  input   [  7: 0] fifo_wdata;
  input            fifo_wr;
  wire             fifo_FF;
  wire    [  7: 0] r_dat;
  wire             wfifo_empty;
  wire    [  5: 0] wfifo_used;
  always @(posedge clk)
    begin
      if (fifo_wr)
          $write("%c", fifo_wdata);
    end
  assign wfifo_used = {6{1'b0}};
  assign r_dat = {8{1'b0}};
  assign fifo_FF = 1'b0;
  assign wfifo_empty = 1'b1;
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0_scfifo_w (
                                     clk,
                                     fifo_clear,
                                     fifo_wdata,
                                     fifo_wr,
                                     rd_wfifo,
                                     fifo_FF,
                                     r_dat,
                                     wfifo_empty,
                                     wfifo_used
                                  )
;
  output           fifo_FF;
  output  [  7: 0] r_dat;
  output           wfifo_empty;
  output  [  5: 0] wfifo_used;
  input            clk;
  input            fifo_clear;
  input   [  7: 0] fifo_wdata;
  input            fifo_wr;
  input            rd_wfifo;
  wire             fifo_FF;
  wire    [  7: 0] r_dat;
  wire             wfifo_empty;
  wire    [  5: 0] wfifo_used;
  wasca_jtag_uart_0_sim_scfifo_w the_wasca_jtag_uart_0_sim_scfifo_w
    (
      .clk         (clk),
      .fifo_FF     (fifo_FF),
      .fifo_wdata  (fifo_wdata),
      .fifo_wr     (fifo_wr),
      .r_dat       (r_dat),
      .wfifo_empty (wfifo_empty),
      .wfifo_used  (wfifo_used)
    );
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0_sim_scfifo_r (
                                         clk,
                                         fifo_rd,
                                         rst_n,
                                         fifo_EF,
                                         fifo_rdata,
                                         rfifo_full,
                                         rfifo_used
                                      )
;
  output           fifo_EF;
  output  [  7: 0] fifo_rdata;
  output           rfifo_full;
  output  [  5: 0] rfifo_used;
  input            clk;
  input            fifo_rd;
  input            rst_n;
  reg     [ 31: 0] bytes_left;
  wire             fifo_EF;
  reg              fifo_rd_d;
  wire    [  7: 0] fifo_rdata;
  wire             new_rom;
  wire    [ 31: 0] num_bytes;
  wire    [  6: 0] rfifo_entries;
  wire             rfifo_full;
  wire    [  5: 0] rfifo_used;
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          bytes_left <= 32'h0;
          fifo_rd_d <= 1'b0;
        end
      else 
        begin
          fifo_rd_d <= fifo_rd;
          if (fifo_rd_d)
              bytes_left <= bytes_left - 1'b1;
          if (new_rom)
              bytes_left <= num_bytes;
        end
    end
  assign fifo_EF = bytes_left == 32'b0;
  assign rfifo_full = bytes_left > 7'h40;
  assign rfifo_entries = (rfifo_full) ? 7'h40 : bytes_left;
  assign rfifo_used = rfifo_entries[5 : 0];
  assign new_rom = 1'b0;
  assign num_bytes = 32'b0;
  assign fifo_rdata = 8'b0;
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0_scfifo_r (
                                     clk,
                                     fifo_clear,
                                     fifo_rd,
                                     rst_n,
                                     t_dat,
                                     wr_rfifo,
                                     fifo_EF,
                                     fifo_rdata,
                                     rfifo_full,
                                     rfifo_used
                                  )
;
  output           fifo_EF;
  output  [  7: 0] fifo_rdata;
  output           rfifo_full;
  output  [  5: 0] rfifo_used;
  input            clk;
  input            fifo_clear;
  input            fifo_rd;
  input            rst_n;
  input   [  7: 0] t_dat;
  input            wr_rfifo;
  wire             fifo_EF;
  wire    [  7: 0] fifo_rdata;
  wire             rfifo_full;
  wire    [  5: 0] rfifo_used;
  wasca_jtag_uart_0_sim_scfifo_r the_wasca_jtag_uart_0_sim_scfifo_r
    (
      .clk        (clk),
      .fifo_EF    (fifo_EF),
      .fifo_rd    (fifo_rd),
      .fifo_rdata (fifo_rdata),
      .rfifo_full (rfifo_full),
      .rfifo_used (rfifo_used),
      .rst_n      (rst_n)
    );
endmodule
`timescale 1ns / 1ps
module wasca_jtag_uart_0 (
                            av_address,
                            av_chipselect,
                            av_read_n,
                            av_write_n,
                            av_writedata,
                            clk,
                            rst_n,
                            av_irq,
                            av_readdata,
                            av_waitrequest,
                            dataavailable,
                            readyfordata
                         )
   ;
  output           av_irq;
  output  [ 31: 0] av_readdata;
  output           av_waitrequest;
  output           dataavailable;
  output           readyfordata;
  input            av_address;
  input            av_chipselect;
  input            av_read_n;
  input            av_write_n;
  input   [ 31: 0] av_writedata;
  input            clk;
  input            rst_n;
  reg              ac;
  wire             activity;
  wire             av_irq;
  wire    [ 31: 0] av_readdata;
  reg              av_waitrequest;
  reg              dataavailable;
  reg              fifo_AE;
  reg              fifo_AF;
  wire             fifo_EF;
  wire             fifo_FF;
  wire             fifo_clear;
  wire             fifo_rd;
  wire    [  7: 0] fifo_rdata;
  wire    [  7: 0] fifo_wdata;
  reg              fifo_wr;
  reg              ien_AE;
  reg              ien_AF;
  wire             ipen_AE;
  wire             ipen_AF;
  reg              pause_irq;
  wire    [  7: 0] r_dat;
  wire             r_ena;
  reg              r_val;
  wire             rd_wfifo;
  reg              read_0;
  reg              readyfordata;
  wire             rfifo_full;
  wire    [  5: 0] rfifo_used;
  reg              rvalid;
  reg              sim_r_ena;
  reg              sim_t_dat;
  reg              sim_t_ena;
  reg              sim_t_pause;
  wire    [  7: 0] t_dat;
  reg              t_dav;
  wire             t_ena;
  wire             t_pause;
  wire             wfifo_empty;
  wire    [  5: 0] wfifo_used;
  reg              woverflow;
  wire             wr_rfifo;
  assign rd_wfifo = r_ena & ~wfifo_empty;
  assign wr_rfifo = t_ena & ~rfifo_full;
  assign fifo_clear = ~rst_n;
  wasca_jtag_uart_0_scfifo_w the_wasca_jtag_uart_0_scfifo_w
    (
      .clk         (clk),
      .fifo_FF     (fifo_FF),
      .fifo_clear  (fifo_clear),
      .fifo_wdata  (fifo_wdata),
      .fifo_wr     (fifo_wr),
      .r_dat       (r_dat),
      .rd_wfifo    (rd_wfifo),
      .wfifo_empty (wfifo_empty),
      .wfifo_used  (wfifo_used)
    );
  wasca_jtag_uart_0_scfifo_r the_wasca_jtag_uart_0_scfifo_r
    (
      .clk        (clk),
      .fifo_EF    (fifo_EF),
      .fifo_clear (fifo_clear),
      .fifo_rd    (fifo_rd),
      .fifo_rdata (fifo_rdata),
      .rfifo_full (rfifo_full),
      .rfifo_used (rfifo_used),
      .rst_n      (rst_n),
      .t_dat      (t_dat),
      .wr_rfifo   (wr_rfifo)
    );
  assign ipen_AE = ien_AE & fifo_AE;
  assign ipen_AF = ien_AF & (pause_irq | fifo_AF);
  assign av_irq = ipen_AE | ipen_AF;
  assign activity = t_pause | t_ena;
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
          pause_irq <= 1'b0;
      else 
      if (t_pause & ~fifo_EF)
          pause_irq <= 1'b1;
      else if (read_0)
          pause_irq <= 1'b0;
    end
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          r_val <= 1'b0;
          t_dav <= 1'b1;
        end
      else 
        begin
          r_val <= r_ena & ~wfifo_empty;
          t_dav <= ~rfifo_full;
        end
    end
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          fifo_AE <= 1'b0;
          fifo_AF <= 1'b0;
          fifo_wr <= 1'b0;
          rvalid <= 1'b0;
          read_0 <= 1'b0;
          ien_AE <= 1'b0;
          ien_AF <= 1'b0;
          ac <= 1'b0;
          woverflow <= 1'b0;
          av_waitrequest <= 1'b1;
        end
      else 
        begin
          fifo_AE <= {fifo_FF,wfifo_used} <= 8;
          fifo_AF <= (7'h40 - {rfifo_full,rfifo_used}) <= 8;
          fifo_wr <= 1'b0;
          read_0 <= 1'b0;
          av_waitrequest <= ~(av_chipselect & (~av_write_n | ~av_read_n) & av_waitrequest);
          if (activity)
              ac <= 1'b1;
          if (av_chipselect & ~av_write_n & av_waitrequest)
              if (av_address)
                begin
                  ien_AF <= av_writedata[0];
                  ien_AE <= av_writedata[1];
                  if (av_writedata[10] & ~activity)
                      ac <= 1'b0;
                end
              else 
                begin
                  fifo_wr <= ~fifo_FF;
                  woverflow <= fifo_FF;
                end
          if (av_chipselect & ~av_read_n & av_waitrequest)
            begin
              if (~av_address)
                  rvalid <= ~fifo_EF;
              read_0 <= ~av_address;
            end
        end
    end
  assign fifo_wdata = av_writedata[7 : 0];
  assign fifo_rd = (av_chipselect & ~av_read_n & av_waitrequest & ~av_address) ? ~fifo_EF : 1'b0;
  assign av_readdata = read_0 ? { {9{1'b0}},rfifo_full,rfifo_used,rvalid,woverflow,~fifo_FF,~fifo_EF,1'b0,ac,ipen_AE,ipen_AF,fifo_rdata } : { {9{1'b0}},(7'h40 - {fifo_FF,wfifo_used}),rvalid,woverflow,~fifo_FF,~fifo_EF,1'b0,ac,ipen_AE,ipen_AF,{6{1'b0}},ien_AE,ien_AF };
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
          readyfordata <= 0;
      else 
        readyfordata <= ~fifo_FF;
    end
  always @(posedge clk)
    begin
      sim_t_pause <= 1'b0;
      sim_t_ena <= 1'b0;
      sim_t_dat <= t_dav ? r_dat : {8{r_val}};
      sim_r_ena <= 1'b0;
    end
  assign r_ena = sim_r_ena;
  assign t_ena = sim_t_ena;
  assign t_dat = sim_t_dat;
  assign t_pause = sim_t_pause;
  always @(fifo_EF)
    begin
      dataavailable = ~fifo_EF;
    end
endmodule
