`timescale 1ns/1ps
`timescale 1ns/1ps
module ddr2_usr_wr #
  (
   parameter BANK_WIDTH    = 2,
   parameter COL_WIDTH     = 10,
   parameter CS_BITS       = 0,
   parameter DQ_WIDTH      = 72,
   parameter APPDATA_WIDTH = 144,
   parameter ECC_ENABLE    = 0,
   parameter ROW_WIDTH     = 14
   )
  (
   input                         clk0,
   input                         clk90,
   input                         rst0,
   input                         app_wdf_wren,
   input [APPDATA_WIDTH-1:0]     app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0] app_wdf_mask_data,
   input                         wdf_rden,
   output                        app_wdf_afull,
   output [(2*DQ_WIDTH)-1:0]     wdf_data,
   output [((2*DQ_WIDTH)/8)-1:0] wdf_mask_data
   );
  localparam WDF_FIFO_NUM = (ECC_ENABLE) ? (APPDATA_WIDTH+63)/64 :
             ((2*DQ_WIDTH)+63)/64;
  localparam MASK_WIDTH = DQ_WIDTH/8;
  wire [WDF_FIFO_NUM-1:0]      i_wdf_afull;
  wire [DQ_WIDTH-1:0]          i_wdf_data_fall_in;
  wire [DQ_WIDTH-1:0]          i_wdf_data_fall_out;
  wire [(64*WDF_FIFO_NUM)-1:0] i_wdf_data_in;
  wire [(64*WDF_FIFO_NUM)-1:0] i_wdf_data_out;
  wire [DQ_WIDTH-1:0]          i_wdf_data_rise_in;
  wire [DQ_WIDTH-1:0]          i_wdf_data_rise_out;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_fall_in;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_fall_out;
  wire [(8*WDF_FIFO_NUM)-1:0]  i_wdf_mask_data_in;
  wire [(8*WDF_FIFO_NUM)-1:0]  i_wdf_mask_data_out;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_rise_in;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_rise_out;
  reg                          rst_r;
  wire [(2*DQ_WIDTH)-1:0]      i_wdf_data_out_ecc;
  wire [((2*DQ_WIDTH)/8)-1:0]  i_wdf_mask_data_out_ecc;
  wire [63:0]                  i_wdf_mask_data_out_ecc_wire;
  wire [((2*DQ_WIDTH)/8)-1:0]  mask_data_in_ecc;
  wire [63:0]                  mask_data_in_ecc_wire;
  assign app_wdf_afull = i_wdf_afull[0];
  always @(posedge clk0 )
      rst_r <= rst0;
  genvar wdf_di_i;
  genvar wdf_do_i;
  genvar mask_i;
  genvar wdf_i;
  generate
    if(ECC_ENABLE) begin    
      assign wdf_data = i_wdf_data_out_ecc;
      assign wdf_mask_data = i_wdf_mask_data_out_ecc;
      for (wdf_i = 0; wdf_i < WDF_FIFO_NUM; wdf_i = wdf_i + 1) begin: gen_wdf
        FIFO36_72  #
          (
           .ALMOST_EMPTY_OFFSET     (9'h007),
           .ALMOST_FULL_OFFSET      (9'h00F),
           .DO_REG                  (1),          
           .EN_ECC_WRITE            ("TRUE"),
           .EN_ECC_READ             ("FALSE"),
           .EN_SYN                  ("FALSE"),
           .FIRST_WORD_FALL_THROUGH ("FALSE")
           )
          u_wdf_ecc
            (
             .ALMOSTEMPTY (),
             .ALMOSTFULL  (i_wdf_afull[wdf_i]),
             .DBITERR     (),
             .DO          (i_wdf_data_out_ecc[((64*(wdf_i+1))+(wdf_i *8))-1:
                                              (64*wdf_i)+(wdf_i *8)]),
             .DOP         (i_wdf_data_out_ecc[(72*(wdf_i+1))-1:
                                              (64*(wdf_i+1))+ (8*wdf_i) ]),
             .ECCPARITY   (),
             .EMPTY       (),
             .FULL        (),
             .RDCOUNT     (),
             .RDERR       (),
             .SBITERR     (),
             .WRCOUNT     (),
             .WRERR       (),
             .DI          (app_wdf_data[(64*(wdf_i+1))-1:
                                        (64*wdf_i)]),
             .DIP         (),
             .RDCLK       (clk90),
             .RDEN        (wdf_rden),
             .RST         (rst_r),          
             .WRCLK       (clk0),
             .WREN        (app_wdf_wren)
             );
      end
      for (mask_i = 0; mask_i < (DQ_WIDTH)/36;
           mask_i = mask_i +1) begin: gen_mask
        assign mask_data_in_ecc[((8*(mask_i+1))+ mask_i)-1:((8*mask_i)+mask_i)]
                 = app_wdf_mask_data[(8*(mask_i+1))-1:8*(mask_i)] ;
        assign mask_data_in_ecc[((8*(mask_i+1))+mask_i)] = 1'd0;
      end
       assign  mask_data_in_ecc_wire[((2*DQ_WIDTH)/8)-1:0] = mask_data_in_ecc;
       assign  mask_data_in_ecc_wire[63:((2*DQ_WIDTH)/8)]  =
              {(64-((2*DQ_WIDTH)/8)){1'b0}};
       assign i_wdf_mask_data_out_ecc =
               i_wdf_mask_data_out_ecc_wire[((2*DQ_WIDTH)/8)-1:0];
      FIFO36_72  #
        (
         .ALMOST_EMPTY_OFFSET     (9'h007),
         .ALMOST_FULL_OFFSET      (9'h00F),
         .DO_REG                  (1),          
         .EN_ECC_WRITE            ("TRUE"),
         .EN_ECC_READ             ("FALSE"),
         .EN_SYN                  ("FALSE"),
         .FIRST_WORD_FALL_THROUGH ("FALSE")
         )
        u_wdf_ecc_mask
          (
           .ALMOSTEMPTY (),
           .ALMOSTFULL  (),
           .DBITERR     (),
           .DO          (i_wdf_mask_data_out_ecc_wire),
           .DOP         (),
           .ECCPARITY   (),
           .EMPTY       (),
           .FULL        (),
           .RDCOUNT     (),
           .RDERR       (),
           .SBITERR     (),
           .WRCOUNT     (),
           .WRERR       (),
           .DI          (mask_data_in_ecc_wire),
           .DIP         (),
           .RDCLK       (clk90),
           .RDEN        (wdf_rden),
           .RST         (rst_r),          
           .WRCLK       (clk0),
           .WREN        (app_wdf_wren)
           );
    end else begin
      assign i_wdf_data_rise_in
        = app_wdf_data[DQ_WIDTH-1:0];
      assign i_wdf_data_fall_in
        = app_wdf_data[(2*DQ_WIDTH)-1:DQ_WIDTH];
      assign i_wdf_mask_data_rise_in
        = app_wdf_mask_data[MASK_WIDTH-1:0];
      assign i_wdf_mask_data_fall_in
        = app_wdf_mask_data[(2*MASK_WIDTH)-1:MASK_WIDTH];
      for (wdf_di_i = 0; wdf_di_i < MASK_WIDTH;
           wdf_di_i = wdf_di_i + 1) begin: gen_wdf_data_in
        assign i_wdf_data_in[(16*wdf_di_i)+15:(16*wdf_di_i)]
                 = {i_wdf_data_fall_in[(8*wdf_di_i)+7:(8*wdf_di_i)],
                    i_wdf_data_rise_in[(8*wdf_di_i)+7:(8*wdf_di_i)]};
        assign i_wdf_mask_data_in[(2*wdf_di_i)+1:(2*wdf_di_i)]
                 = {i_wdf_mask_data_fall_in[wdf_di_i],
                    i_wdf_mask_data_rise_in[wdf_di_i]};
      end
      for (wdf_do_i = 0; wdf_do_i < MASK_WIDTH;
           wdf_do_i = wdf_do_i + 1) begin: gen_wdf_data_out
        assign i_wdf_data_rise_out[(8*wdf_do_i)+7:(8*wdf_do_i)]
                 = i_wdf_data_out[(16*wdf_do_i)+7:(16*wdf_do_i)];
        assign i_wdf_data_fall_out[(8*wdf_do_i)+7:(8*wdf_do_i)]
                 = i_wdf_data_out[(16*wdf_do_i)+15:(16*wdf_do_i)+8];
        assign i_wdf_mask_data_rise_out[wdf_do_i]
                 = i_wdf_mask_data_out[2*wdf_do_i];
        assign i_wdf_mask_data_fall_out[wdf_do_i]
                 = i_wdf_mask_data_out[(2*wdf_do_i)+1];
      end
      assign wdf_data = {i_wdf_data_fall_out,
                         i_wdf_data_rise_out};
      assign wdf_mask_data = {i_wdf_mask_data_fall_out,
                              i_wdf_mask_data_rise_out};
      for (wdf_i = 0; wdf_i < WDF_FIFO_NUM; wdf_i = wdf_i + 1) begin: gen_wdf
        FIFO36_72  #
          (
           .ALMOST_EMPTY_OFFSET     (9'h007),
           .ALMOST_FULL_OFFSET      (9'h00F),
           .DO_REG                  (1),          
           .EN_ECC_WRITE            ("FALSE"),
           .EN_ECC_READ             ("FALSE"),
           .EN_SYN                  ("FALSE"),
           .FIRST_WORD_FALL_THROUGH ("FALSE")
           )
          u_wdf
            (
             .ALMOSTEMPTY (),
             .ALMOSTFULL  (i_wdf_afull[wdf_i]),
             .DBITERR     (),
             .DO          (i_wdf_data_out[(64*(wdf_i+1))-1:64*wdf_i]),
             .DOP         (i_wdf_mask_data_out[(8*(wdf_i+1))-1:8*wdf_i]),
             .ECCPARITY   (),
             .EMPTY       (),
             .FULL        (),
             .RDCOUNT     (),
             .RDERR       (),
             .SBITERR     (),
             .WRCOUNT     (),
             .WRERR       (),
             .DI          (i_wdf_data_in[(64*(wdf_i+1))-1:64*wdf_i]),
             .DIP         (i_wdf_mask_data_in[(8*(wdf_i+1))-1:8*wdf_i]),
             .RDCLK       (clk90),
             .RDEN        (wdf_rden),
             .RST         (rst_r),          
             .WRCLK       (clk0),
             .WREN        (app_wdf_wren)
             );
      end
    end
  endgenerate
endmodule
