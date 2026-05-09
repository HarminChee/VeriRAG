module zet_front_prefetch_wb (
  input             clk_i,
  input             rst_i,
  input      [15:0] wb_dat_i,
  output     [19:1] wb_adr_o,
  output     [ 1:0] wb_sel_o,
  output            wb_cyc_o,
  output            wb_stb_o,
  input             wb_ack_i,
  input             flush,
  input             load_cs_ip,
  input      [15:0] requested_cs,
  input      [15:0] requested_ip,
  output reg [15:0] fifo_cs_o,
  output reg [15:0] fifo_ip_o,
  output reg [15:0] fetch_dat_o,
  output reg        wr_fetch_fifo,
  input             fifo_full
);
wire abort_fetch;
wire stalled;
wire wb_cyc_complete;
reg valid_cyc;
reg wb_cyc;
reg [15:0] cs;
reg [15:0] ip;
assign abort_fetch = rst_i || flush || load_cs_ip;
assign stalled = fifo_full;
assign wb_adr_o = (cs << 4) + ip;
assign wb_sel_o = 2'b11;
assign wb_cyc_o = (!abort_fetch & !stalled) || wb_cyc;
assign wb_stb_o = (!abort_fetch & !stalled) || wb_cyc;
assign wb_cyc_complete = wb_cyc_o & wb_stb_o & wb_ack_i;
always @(posedge clk_i)
  if (rst_i) wb_cyc <= 1'b0;
  else wb_cyc <= !abort_fetch & !stalled ? 1'b1
               : wb_cyc_complete ? 1'b0
               : wb_cyc;
always @(posedge clk_i)
  if (rst_i) valid_cyc <= 1'b0;
  else valid_cyc <= abort_fetch ? 1'b0
                  : wb_cyc_complete ? 1'b1
                  : valid_cyc;
always @(posedge clk_i)
  if (rst_i) begin
    cs <= 16'hf000;
    ip <= 16'hfff0;
  end
  else begin
    if (flush) begin
      cs <= requested_cs;
      ip <= requested_ip;
    end
    else if (load_cs_ip) begin
        cs <= requested_cs;
        ip <= requested_ip;
    end
    else if (!stalled & wb_cyc & valid_cyc & wb_cyc_complete)
        ip <= ip + 1; 
  end
always @(posedge clk_i)
  if (rst_i) begin
    fetch_dat_o <= 16'b0;
    fifo_cs_o  <= 16'b0;
    fifo_ip_o  <= 16'b0;
  end
  else if (wb_cyc & valid_cyc & wb_cyc_complete) begin
    fetch_dat_o <= wb_dat_i;
    fifo_cs_o  <= cs;
    fifo_ip_o  <= ip;
  end
always @(posedge clk_i)
  if (rst_i) wr_fetch_fifo <= 1'b0;
  else wr_fetch_fifo <= !abort_fetch & !stalled & wb_cyc & valid_cyc & wb_cyc_complete;
endmodule
