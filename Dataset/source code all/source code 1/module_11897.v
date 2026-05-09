`timescale 1ns/1ps
`timescale 1ns/1ps
module ddr2_tb_test_addr_gen #
  (
   parameter BANK_WIDTH = 2,
   parameter COL_WIDTH  = 10,
   parameter ROW_WIDTH  = 14
   )
  (
   input             clk,
   input             rst,
   input             wr_addr_en,
   output reg [2:0]  app_af_cmd,
   output reg [30:0] app_af_addr,
   output reg        app_af_wren
   );
  localparam RAM_INIT_00 = {128'h800020C0_800020C8_000020D0_000020D8,
                            128'h000010E0_000010E8_800010F0_800010F8};
  localparam RAM_INIT_01 = {128'h800020C0_800020C8_000020D0_000020D8,
                            128'h000010E0_000010E8_800010F0_800010F8};
  localparam RAM_INIT_02 = {128'h100040C0_100040C8_900040D0_900040D8,
                            128'h900030E0_900030E8_100030F0_100030F8};
  localparam RAM_INIT_03 = {128'h100040C0_100040C8_900040D0_900040D8,
                            128'h900030E0_900030E8_100030F0_100030F8};
  localparam RAM_INIT_04 = {128'hA00060C0_200060C8_200060D0_A00060D8,
                            128'h200050E0_A00050E8_A00050F0_200050F8};
  localparam RAM_INIT_05 = {128'hA00060C0_200060C8_200060D0_A00060D8,
                            128'h200050E0_A00050E8_A00050F0_200050F8};
  localparam RAM_INIT_06 = {128'h300080C0_B00080C8_B00080D0_300080D8,
                            128'hB00070E0_300070E8_300070F0_B00070F8};
  localparam RAM_INIT_07 = {128'h300080C0_B00080C8_B00080D0_300080D8,
                            128'hB00070E0_300070E8_300070F0_B00070F8};
  localparam RAM_INITP_00 = {128'h11111111_00000000_11111111_00000000,
                             128'h11111111_00000000_11111111_00000000};
  reg             wr_addr_en_r1;
  reg [2:0]       af_cmd_r;
  reg [30:0]      af_addr_r;
  reg             af_wren_r;
  wire [15:0]     ramb_addr;
  wire [35:0]     ramb_dout;
  reg             rst_r
                  ;
  reg             rst_r1
                  ;
  reg [5:0]       wr_addr_cnt;
  reg             wr_addr_en_r0;
  always @(posedge clk) begin
    rst_r  <= rst;
    rst_r1 <= rst_r;
  end
  assign ramb_addr = {5'b00000, wr_addr_cnt, 5'b00000};
  RAMB36 #
    (
     .READ_WIDTH_A (36),
     .READ_WIDTH_B (36),
     .DOA_REG      (1),              
     .INIT_00      (RAM_INIT_00),
     .INIT_01      (RAM_INIT_01),
     .INIT_02      (RAM_INIT_02),
     .INIT_03      (RAM_INIT_03),
     .INIT_04      (RAM_INIT_04),
     .INIT_05      (RAM_INIT_05),
     .INIT_06      (RAM_INIT_06),
     .INIT_07      (RAM_INIT_07),
     .INITP_00     (RAM_INITP_00)
     )
    u_wr_rd_addr_lookup
      (
       .CASCADEOUTLATA   (),
       .CASCADEOUTLATB   (),
       .CASCADEOUTREGA   (),
       .CASCADEOUTREGB   (),
       .DOA              (ramb_dout[31:0]),
       .DOB              (),
       .DOPA             (ramb_dout[35:32]),
       .DOPB             (),
       .ADDRA            (ramb_addr),
       .ADDRB            (16'h0000),
       .CASCADEINLATA    (),
       .CASCADEINLATB    (),
       .CASCADEINREGA    (),
       .CASCADEINREGB    (),
       .CLKA             (clk),
       .CLKB             (clk),
       .DIA              (32'b0),
       .DIB              (32'b0),
       .DIPA             (4'b0),
       .DIPB             (4'b0),
       .ENA              (1'b1),
       .ENB              (1'b1),
       .REGCEA           (1'b1),
       .REGCEB           (1'b1),
       .SSRA             (1'b0),
       .SSRB             (1'b0),
       .WEA              (4'b0000),
       .WEB              (4'b0000)
       );
  always @(posedge clk)
    if (rst_r1) begin
      app_af_wren   <= 1'b0;
      wr_addr_en_r0 <= 1'b0;
      wr_addr_en_r1 <= 1'b0;
      af_wren_r     <= 1'b0;
    end else begin
      wr_addr_en_r0 <= wr_addr_en;
      wr_addr_en_r1 <= wr_addr_en_r0;
      af_wren_r   <= wr_addr_en_r1;
      app_af_wren   <= af_wren_r;
    end
  always @(posedge clk) begin
    af_addr_r <= {30{1'b0}};
    af_addr_r[COL_WIDTH-1:0] <= ramb_dout[COL_WIDTH-1:0];
    af_addr_r[ROW_WIDTH+COL_WIDTH-1:COL_WIDTH]
      <= ramb_dout[ROW_WIDTH+11:12];
    af_addr_r[BANK_WIDTH+ROW_WIDTH+COL_WIDTH-1:ROW_WIDTH+COL_WIDTH]
      <= ramb_dout[BANK_WIDTH+27:28];
    af_addr_r[BANK_WIDTH+ROW_WIDTH+COL_WIDTH]
      <= ramb_dout[31];
    af_cmd_r  <= {1'b0, ramb_dout[33:32]};
    app_af_cmd <= af_cmd_r;
    app_af_addr <= af_addr_r;
  end
  always @ (posedge clk)
    if (rst_r1)
      wr_addr_cnt <= 6'b000000;
    else if (wr_addr_en)
      wr_addr_cnt <= wr_addr_cnt + 1;
endmodule
