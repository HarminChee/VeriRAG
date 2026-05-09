`define WB_UNBUFFERED_8254
`define WB_UNBUFFERED_8254
module timer
  (
    input             wb_clk_i,
    input             wb_rst_i,
    input             wb_adr_i,
    input      [1:0]  wb_sel_i,
    input      [15:0] wb_dat_i,
    output reg [15:0] wb_dat_o,
    input             wb_stb_i,
    input             wb_cyc_i,
    input             wb_we_i,
    output            wb_ack_o,
    output reg        wb_tgc_o,   
    input             tclk_i,     
    input             gate2_i,
    output            out2_o
  );
`ifdef WB_UNBUFFERED_8254
  wire [15:0] data_ib;
  wire wr_cyc1;
  wire rd_cyc1;
  wire [1:0] datasel;
`else
  reg [15:0] data_ib;
  reg wr_cyc1;
  reg rd_cyc1, rd_cyc2;
  reg [1:0] datasel;
`endif
  wire intr, refresh;
  reg intr1;
  wire wrc, wrd0, wrd1, wrd2, rdd0, rdd1, rdd2;
  wire [7:0] data0;
  wire [7:0] data1;
  wire [7:0] data2;
  always @(posedge wb_clk_i)
  begin
    intr1 <= wb_rst_i ? 1'b0 : intr;
    wb_tgc_o <= wb_rst_i ? 1'b0 : (!intr1 & intr);
  end
  reg [7:0] data_i;
  reg [15:0] data_ob;
  always @(datasel or data0 or data1 or data2)
    case (datasel)
      2'b00: data_ob = { 8'h0, data0 };
      2'b01: data_ob = { data1, 8'h0 };
      2'b10: data_ob = { 8'h0, data2 };
      2'b11: data_ob = { 8'h0, 8'h0 }; 
    endcase
  always @(datasel or data_ib)
    case (datasel)
      2'b00: data_i = data_ib[7:0];
      2'b01: data_i = data_ib[15:8];
      2'b10: data_i = data_ib[7:0];
      2'b11: data_i = data_ib[15:8];
    endcase
  assign wrc = wr_cyc1 & (datasel == 2'b11);
  assign wrd0 = wr_cyc1 & (datasel == 2'b00);
  assign wrd1 = wr_cyc1 & (datasel == 2'b01);
  assign wrd2 = wr_cyc1 & (datasel == 2'b10);
  assign rdd0 = rd_cyc1 & (datasel == 2'b00);
  assign rdd1 = rd_cyc1 & (datasel == 2'b01);
  assign rdd2 = rd_cyc1 & (datasel == 2'b10);
  `ifdef WB_UNBUFFERED_8254
  assign wb_ack_o = wb_stb_i & wb_cyc_i;
  assign wr_cyc1 = wb_ack_o & wb_we_i;
  assign rd_cyc1 = wb_ack_o & ~wb_we_i;
  assign datasel = {wb_adr_i,wb_sel_i[1]};
  always @(data_ob)
    wb_dat_o = data_ob;
  assign data_ib = wb_dat_i;
  `else
  assign wb_ack_o = wr_cyc1 | rd_cyc2;
  always @(posedge wb_clk_i)
  begin
    wr_cyc1 <= (wr_cyc1) ? 1'b0 : wb_stb_i & wb_cyc_i & wb_we_i;            
    rd_cyc1 <= (rd_cyc1 | rd_cyc2) ? 1'b0 : wb_stb_i & wb_cyc_i & ~wb_we_i; 
    rd_cyc2 <= rd_cyc1;                                                     
    datasel <= {wb_adr_i,wb_sel_i[1]};
    wb_dat_o <= data_ob;
    data_ib <= wb_dat_i;
  end
  `endif 
  timer_counter cnt0 (
    .cntnum (2'd0),
    .cw0    (6'h36),      
    .cr0    (16'hFFFF),   
    .clkrw  (wb_clk_i),
    .rst    (wb_rst_i),
    .wrc    (wrc),
    .wrd    (wrd0),
    .rdd    (rdd0),
    .data_i (data_i),
    .data_o (data0),
    .clkt   (tclk_i),
    .gate   (1'b1),
    .out    (intr)
    );
  timer_counter cnt1 (
    .cntnum (2'd1),
    .cw0    (6'h14),      
    .cr0    (16'h0012),   
    .clkrw  (wb_clk_i),
    .rst    (wb_rst_i),
    .wrc    (wrc),
    .wrd    (wrd1),
    .rdd    (rdd1),
    .data_i (data_i),
    .data_o (data1),
    .clkt   (tclk_i),
    .gate   (1'b1),
    .out    (refresh)
    );
  timer_counter cnt2 (
    .cntnum (2'd2),
    .cw0    (6'h36),      
    .cr0    (16'h04A9),   
    .clkrw  (wb_clk_i),
    .rst    (wb_rst_i),
    .wrc    (wrc),
    .wrd    (wrd2),
    .rdd    (rdd2),
    .data_i (data_i),
    .data_o (data2),
    .clkt   (tclk_i),
    .gate   (gate2_i),
    .out    (out2_o)
    );
endmodule
