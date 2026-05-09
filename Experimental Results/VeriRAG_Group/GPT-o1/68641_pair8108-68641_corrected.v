`timescale 1 ps / 1 ps
module jtag_fifo (
    input               test_i,
    input               rx_clk,
    input       [11:0]  rx_data,
    input               wr_en,
    input               rd_en,
    output      [8:0]   tx_data,
    output              tx_full,
    output              tx_empty
);
   wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
   wire jt_tdo;
   BSCAN_SPARTAN6 #(.JTAG_CHAIN(1)) jtag_blk (
      .CAPTURE   (jt_capture),
      .DRCK      (jt_drck),
      .RESET     (jt_reset),
      .RUNTEST   (),
      .SEL       (jt_sel),
      .SHIFT     (jt_shift),
      .TCK       (jt_tck),
      .TDI       (jt_tdi),
      .TDO       (jt_tdo),
      .TMS       (),
      .UPDATE    (jt_update)
   );

   wire jt_tck_dft;
   wire jt_reset_dft;
   assign jt_tck_dft   = test_i ? rx_clk : jt_tck;
   assign jt_reset_dft = test_i ? 1'b0   : jt_reset;

   reg  captured_data_valid = 1'b0;
   reg  [12:0] dr;
   wire full;
   fifo_generator_v8_2 tck_to_rx_clk_blk (
      .wr_clk  (jt_tck_dft),
      .rd_clk  (rx_clk),
      .din     ({7'd0, dr[8:0]}),
      .wr_en   (jt_update & jt_sel & !full),
      .rd_en   (rd_en & !tx_empty),
      .dout    (tx_data),
      .full    (full),
      .empty   (tx_empty)
   );

   wire [11:0] captured_data;
   wire empty;
   fifo_generator_v8_2 rx_clk_to_tck_blk (
      .wr_clk  (rx_clk),
      .rd_clk  (jt_tck_dft),
      .din     ({4'd0, rx_data}),
      .wr_en   (wr_en & !tx_full),
      .rd_en   (jt_capture & ~empty & ~jt_reset),
      .dout    (captured_data),
      .full    (tx_full),
      .empty   (empty)
   );

   assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

   always @(posedge jt_tck_dft or posedge jt_reset_dft)
   begin
      if (jt_reset_dft)
      begin
         dr <= 13'd0;
      end
      else if (jt_capture)
      begin
         captured_data_valid <= !empty;
         dr <= 13'd0;
      end
      else if (jt_shift & captured_data_valid)
      begin
         captured_data_valid <= 1'b0;
         dr <= {jt_tdi, 1'b1, captured_data[11:1]};
      end
      else if (jt_shift)
      begin
         dr <= {jt_tdi, dr[12:1]};
      end
   end
endmodule