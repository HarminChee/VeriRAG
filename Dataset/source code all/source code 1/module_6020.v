`timescale 1ns/1ps
`timescale 1ns/1ps
module ddr2_tb_test_cmp #
  (
   parameter DQ_WIDTH      = 72,
   parameter APPDATA_WIDTH = 144,
   parameter ECC_ENABLE    = 0
   )
  (
   input                     clk,
   input                     rst,
   input                     phy_init_done,
   input                     rd_data_valid,
   input [APPDATA_WIDTH-1:0] app_cmp_data,
   input [APPDATA_WIDTH-1:0] rd_data_fifo_in,
   output reg                error,
   output reg                error_cmp
   );
  wire [(APPDATA_WIDTH/16)-1:0] byte_err_fall;
  reg [(APPDATA_WIDTH/16)-1:0]  byte_err_fall_r;
  wire [(APPDATA_WIDTH/16)-1:0] byte_err_rise;
  reg [(APPDATA_WIDTH/16)-1:0]  byte_err_rise_r;
  wire [(APPDATA_WIDTH/2)-1:0]  cmp_data_fall;
  wire [(APPDATA_WIDTH/2)-1:0]  cmp_data_rise;
  wire [APPDATA_WIDTH-1:0]      cmp_data_r;
  reg  [APPDATA_WIDTH-1:0]      cmp_data_r1;
  reg                           cmp_start;
  wire [(APPDATA_WIDTH/2)-1:0]  data_fall_r;
  wire [(APPDATA_WIDTH/2)-1:0]  data_rise_r;
  reg                           err_fall;
  reg                           err_rise;
  reg                           error_tmp_r;
  wire                          error_tmp_r1;
  wire                          error_tmp_r2;
  wire [APPDATA_WIDTH-1:0]      rd_data_r;
  wire [APPDATA_WIDTH-1:0]      rd_data_r1;
  reg [APPDATA_WIDTH-1:0]       rd_data_r2;
  wire                          rd_data_valid_r;
  reg                           rd_data_valid_r1;
  reg                           rd_data_valid_r2;
  reg                           rst_r
                                ;
  reg                           rst_r1
                                ;
  always @(posedge clk) begin
    rst_r  <= rst;
    rst_r1 <= rst_r;
  end
  genvar rd_data_i;
  generate
    for (rd_data_i = 0; rd_data_i < APPDATA_WIDTH;
         rd_data_i = rd_data_i + 1) begin: gen_rd_data
      FDRSE ff_rd_data
        (
         .Q   (rd_data_r[rd_data_i]),
         .C   (clk),
         .CE  (1'b1),
         .D   (rd_data_fifo_in[rd_data_i]),
         .R   (1'b0),
         .S   (1'b0)
         );
      FDRSE ff_rd_data_r1
        (
         .Q   (rd_data_r1[rd_data_i]),
         .C   (clk),
         .CE  (1'b1),
         .D   (rd_data_r[rd_data_i]),
         .R   (1'b0),
         .S   (1'b0)
         );
    end
  endgenerate
  genvar cmp_data_i;
  generate
    for (cmp_data_i = 0; cmp_data_i < APPDATA_WIDTH;
         cmp_data_i = cmp_data_i + 1) begin: gen_cmp_data
        FDRSE ff_cmp_data
          (
           .Q   (cmp_data_r[cmp_data_i]),
           .C   (clk),
           .CE  (1'b1),
           .D   (app_cmp_data[cmp_data_i]),
           .R   (1'b0),
           .S   (1'b0)
           );
    end
  endgenerate
  assign data_fall_r   = rd_data_r2[APPDATA_WIDTH-1:(APPDATA_WIDTH/2)];
  assign data_rise_r   = rd_data_r2[(APPDATA_WIDTH/2)-1:0];
  assign cmp_data_fall = cmp_data_r[APPDATA_WIDTH-1:(APPDATA_WIDTH/2)];
  assign cmp_data_rise = cmp_data_r[(APPDATA_WIDTH/2)-1:0];
  FDRSE ff_rd_data_valid_r
    (
     .Q   (rd_data_valid_r),
     .C   (clk),
     .CE  (1'b1),
     .D   (rd_data_valid),
     .R   (1'b0),
     .S   (1'b0)
     );
  always @(posedge clk) begin
    if (rst_r1) begin
      rd_data_valid_r1 <= 1'd0;
    end else begin
      rd_data_valid_r1 <= rd_data_valid_r & phy_init_done;
    end
  end
  always @(posedge clk)begin
     rd_data_r2 <= rd_data_r1;
     cmp_data_r1 <= cmp_data_r;
     rd_data_valid_r2 <= rd_data_valid_r1;
  end
  genvar cmp_i;
  generate
    for (cmp_i = 0; cmp_i < APPDATA_WIDTH/16; cmp_i = cmp_i + 1) begin: gen_cmp
      assign byte_err_fall[cmp_i]
               = (rd_data_valid_r2 &&
                  (data_fall_r[8*(cmp_i+1)-1:8*cmp_i] !=
                   cmp_data_fall[8*(cmp_i+1)-1:8*cmp_i]));
      assign byte_err_rise[cmp_i]
               = (rd_data_valid_r2 &&
                  (data_rise_r[8*(cmp_i+1)-1:8*cmp_i] !=
                   cmp_data_rise[8*(cmp_i+1)-1:8*cmp_i]));
    end
  endgenerate
  always @(posedge clk) begin
    byte_err_rise_r  <= byte_err_rise;
    byte_err_fall_r  <= byte_err_fall;
  end
  always @(posedge clk)
    if (rst_r1) begin
      err_rise    <= 1'bx;
      err_fall    <= 1'bx;
      cmp_start   <= 1'b0;
      error_tmp_r <= 1'b0;
    end else begin
      err_rise <= | byte_err_rise_r;
      err_fall <= | byte_err_fall_r;
      if (rd_data_valid_r2)
        cmp_start <= 1'b1;
      if (cmp_start && !error_tmp_r)
        error_tmp_r <= err_rise | err_fall;
      if ((err_rise || err_fall) && cmp_start)
        $display ("ERROR at time %t" , $time);
    end
  FDRSE ff_error_1
    (
     .Q   (error_tmp_r1),
     .C   (clk),
     .CE  (1'b1),
     .D   (error_tmp_r),
     .R   (1'b0),
     .S   (1'b0)
     );
  FDRSE ff_error_2
    (
     .Q   (error_tmp_r2),
     .C   (clk),
     .CE  (1'b1),
     .D   (error_tmp_r1),
     .R   (1'b0),
     .S   (1'b0)
     );
  always @(posedge clk) begin
    error     <= error_tmp_r2;
    error_cmp <= err_rise | err_fall;
  end
endmodule
