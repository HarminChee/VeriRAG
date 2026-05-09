`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_rddata_sync #
  (
   parameter TCQ             = 100,     
   parameter DQ_WIDTH        = 64,      
   parameter DQS_WIDTH       = 8,       
   parameter DRAM_WIDTH      = 8,       
   parameter nDQS_COL0       = 4,       
   parameter nDQS_COL1       = 4,       
   parameter nDQS_COL2       = 4,       
   parameter nDQS_COL3       = 4,       
   parameter DQS_LOC_COL0    = 32'h03020100,          
   parameter DQS_LOC_COL1    = 32'h07060504,          
   parameter DQS_LOC_COL2    = 0,                     
   parameter DQS_LOC_COL3    = 0                      
   )
  (
   input                        clk,
   input [3:0]                  clk_rsync,
   input [3:0]                  rst_rsync,
   input [DQ_WIDTH-1:0]         rd_data_rise0,
   input [DQ_WIDTH-1:0]         rd_data_fall0,
   input [DQ_WIDTH-1:0]         rd_data_rise1,
   input [DQ_WIDTH-1:0]         rd_data_fall1,
   input [DQS_WIDTH-1:0]        rd_dqs_rise0,
   input [DQS_WIDTH-1:0]        rd_dqs_fall0,
   input [DQS_WIDTH-1:0]        rd_dqs_rise1,
   input [DQS_WIDTH-1:0]        rd_dqs_fall1,
   output reg [4*DQ_WIDTH-1:0]  dfi_rddata,
   output reg [4*DQS_WIDTH-1:0] dfi_rd_dqs
   );
  localparam COL0_VECT_WIDTH = (nDQS_COL0 > 0) ? nDQS_COL0 : 1;
  localparam COL1_VECT_WIDTH = (nDQS_COL1 > 0) ? nDQS_COL1 : 1;
  localparam COL2_VECT_WIDTH = (nDQS_COL2 > 0) ? nDQS_COL2 : 1;
  localparam COL3_VECT_WIDTH = (nDQS_COL3 > 0) ? nDQS_COL3 : 1;
  reg [4*DRAM_WIDTH*COL0_VECT_WIDTH-1:0]  data_c0;
  reg [4*DRAM_WIDTH*COL1_VECT_WIDTH-1:0]  data_c1;
  reg [4*DRAM_WIDTH*COL2_VECT_WIDTH-1:0]  data_c2;
  reg [4*DRAM_WIDTH*COL3_VECT_WIDTH-1:0]  data_c3;
  reg [DQ_WIDTH-1:0]                      data_fall0_sync;
  reg [DQ_WIDTH-1:0]                      data_fall1_sync;
  reg [DQ_WIDTH-1:0]                      data_rise0_sync;
  reg [DQ_WIDTH-1:0]                      data_rise1_sync;
  wire [4*DRAM_WIDTH*COL0_VECT_WIDTH-1:0] data_sync_c0;
  wire [4*DRAM_WIDTH*COL1_VECT_WIDTH-1:0] data_sync_c1;
  wire [4*DRAM_WIDTH*COL2_VECT_WIDTH-1:0] data_sync_c2;
  wire [4*DRAM_WIDTH*COL3_VECT_WIDTH-1:0] data_sync_c3;
  reg [4*COL0_VECT_WIDTH-1:0]             dqs_c0;
  reg [4*COL1_VECT_WIDTH-1:0]             dqs_c1;
  reg [4*COL2_VECT_WIDTH-1:0]             dqs_c2;
  reg [4*COL3_VECT_WIDTH-1:0]             dqs_c3;
  reg [DQS_WIDTH-1:0]                     dqs_fall0_sync;
  reg [DQS_WIDTH-1:0]                     dqs_fall1_sync;
  reg [DQS_WIDTH-1:0]                     dqs_rise0_sync;
  reg [DQS_WIDTH-1:0]                     dqs_rise1_sync;
  wire [4*COL0_VECT_WIDTH-1:0]            dqs_sync_c0;
  wire [4*COL1_VECT_WIDTH-1:0]            dqs_sync_c1;
  wire [4*COL2_VECT_WIDTH-1:0]            dqs_sync_c2;
  wire [4*COL3_VECT_WIDTH-1:0]            dqs_sync_c3;
  generate
    genvar c0_i;
    if (nDQS_COL0 > 0) begin: gen_c0
    for (c0_i = 0; c0_i < nDQS_COL0; c0_i = c0_i + 1) begin: gen_loop_c0
      always @(rd_dqs_fall0 or rd_dqs_fall1 or
               rd_dqs_rise0 or rd_dqs_rise1)
        dqs_c0[4*(c0_i+1)-1-:4]
          = {rd_dqs_fall1[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]],
             rd_dqs_rise1[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]],
             rd_dqs_fall0[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]],
             rd_dqs_rise0[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]]};
      always @(rd_data_rise0 or rd_data_rise1 or
               rd_data_fall0 or rd_data_fall1)
        data_c0[4*DRAM_WIDTH*(c0_i+1)-1-:4*DRAM_WIDTH]
          = {rd_data_fall1[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                           DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])],
             rd_data_rise1[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                           DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])],
             rd_data_fall0[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                           DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])],
             rd_data_rise0[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                           DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])]};
      always @(dqs_sync_c0[4*c0_i] or 
               dqs_sync_c0[4*c0_i+1] or 
               dqs_sync_c0[4*c0_i+2] or 
               dqs_sync_c0[4*c0_i+3]) begin 
        dqs_fall1_sync[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]]
          = dqs_sync_c0[4*c0_i+3];
        dqs_rise1_sync[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]]
          = dqs_sync_c0[4*c0_i+2];
        dqs_fall0_sync[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]]
          = dqs_sync_c0[4*c0_i+1];
        dqs_rise0_sync[DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]]
          = dqs_sync_c0[4*c0_i];
      end
      always @(data_sync_c0[4*DRAM_WIDTH*c0_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i] or 
               data_sync_c0[4*DRAM_WIDTH*c0_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i+DRAM_WIDTH] or 
               data_sync_c0[4*DRAM_WIDTH*c0_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i+2*DRAM_WIDTH] or 
               data_sync_c0[4*DRAM_WIDTH*c0_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i+3*DRAM_WIDTH]) begin
        data_fall1_sync[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                        DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])]
          = data_sync_c0[4*DRAM_WIDTH*c0_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i+3*DRAM_WIDTH];
        data_rise1_sync[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                        DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])]
          = data_sync_c0[4*DRAM_WIDTH*c0_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i+2*DRAM_WIDTH];
        data_fall0_sync[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                        DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])]
          = data_sync_c0[4*DRAM_WIDTH*c0_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i+DRAM_WIDTH];
        data_rise0_sync[DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i]+1)-1:
                        DRAM_WIDTH*(DQS_LOC_COL0[(8*(c0_i+1))-1:8*c0_i])]
          = data_sync_c0[4*DRAM_WIDTH*c0_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c0_i];
      end
    end
  circ_buffer #
    (
      .TCQ        (TCQ),
      .DATA_WIDTH ((4*nDQS_COL0)+(4*DRAM_WIDTH*nDQS_COL0)),
      .BUF_DEPTH  (6)
    )
    u_rddata_sync_c0
    (
      .rclk  (clk),
      .wclk  (clk_rsync[0]),
      .rst   (rst_rsync[0]),
      .wdata ({dqs_c0,data_c0}),
      .rdata ({dqs_sync_c0,data_sync_c0})
    );
    end
  endgenerate
  generate
    genvar c1_i;
    if (nDQS_COL1 > 0) begin: gen_c1
      for (c1_i = 0; c1_i < nDQS_COL1; c1_i = c1_i + 1) begin: gen_loop_c1
        always @(rd_dqs_fall0 or rd_dqs_fall1 or
                 rd_dqs_rise0 or rd_dqs_rise1)
          dqs_c1[4*(c1_i+1)-1-:4]
            = {rd_dqs_fall1[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]],
               rd_dqs_rise1[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]],
               rd_dqs_fall0[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]],
               rd_dqs_rise0[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]]};
        always @(rd_data_rise0 or rd_data_rise1 or
                 rd_data_fall0 or rd_data_fall1)
          data_c1[4*DRAM_WIDTH*(c1_i+1)-1-:4*DRAM_WIDTH]
            = {rd_data_fall1[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])],
               rd_data_rise1[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])],
               rd_data_fall0[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])],
               rd_data_rise0[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])]};
        always @(dqs_sync_c1[4*c1_i] or 
                 dqs_sync_c1[4*c1_i+1] or 
                 dqs_sync_c1[4*c1_i+2] or 
                 dqs_sync_c1[4*c1_i+3] ) begin 
          dqs_fall1_sync[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]]
            = dqs_sync_c1[4*c1_i+3];
          dqs_rise1_sync[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]]
            = dqs_sync_c1[4*c1_i+2];
          dqs_fall0_sync[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]]
            = dqs_sync_c1[4*c1_i+1];
          dqs_rise0_sync[DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]]
            = dqs_sync_c1[4*c1_i];
        end
        always @(data_sync_c1[4*DRAM_WIDTH*c1_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i] or 
                 data_sync_c1[4*DRAM_WIDTH*c1_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i+DRAM_WIDTH] or 
                 data_sync_c1[4*DRAM_WIDTH*c1_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i+2*DRAM_WIDTH] or 
                 data_sync_c1[4*DRAM_WIDTH*c1_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i+3*DRAM_WIDTH]) begin 
          data_fall1_sync[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])]
            = data_sync_c1[4*DRAM_WIDTH*c1_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i+3*DRAM_WIDTH];
          data_rise1_sync[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])]
            = data_sync_c1[4*DRAM_WIDTH*c1_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i+2*DRAM_WIDTH];
          data_fall0_sync[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])]
            = data_sync_c1[4*DRAM_WIDTH*c1_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i+DRAM_WIDTH];
          data_rise0_sync[DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL1[(8*(c1_i+1))-1:8*c1_i])]
            = data_sync_c1[4*DRAM_WIDTH*c1_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c1_i];
        end
      end
      circ_buffer #
        (
         .TCQ        (TCQ),
         .DATA_WIDTH ((4*nDQS_COL1)+(4*DRAM_WIDTH*nDQS_COL1)),
         .BUF_DEPTH  (6)
         )
        u_rddata_sync_c1
          (
           .rclk  (clk),
           .wclk  (clk_rsync[1]),
           .rst   (rst_rsync[1]),
           .wdata ({dqs_c1,data_c1}),
           .rdata ({dqs_sync_c1,data_sync_c1})
           );
    end
  endgenerate
  generate
    genvar c2_i;
    if (nDQS_COL2 > 0) begin: gen_c2
      for (c2_i = 0; c2_i < nDQS_COL2; c2_i = c2_i + 1) begin: gen_loop_c2
        always @(rd_dqs_fall0 or rd_dqs_fall1 or
                 rd_dqs_rise0 or rd_dqs_rise1)
          dqs_c2[4*(c2_i+1)-1-:4]
            = {rd_dqs_fall1[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]],
               rd_dqs_rise1[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]],
               rd_dqs_fall0[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]],
               rd_dqs_rise0[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]]};
        always @(rd_data_fall0 or rd_data_fall1 or
                 rd_data_rise0 or rd_data_rise1)
          data_c2[4*DRAM_WIDTH*(c2_i+1)-1-:4*DRAM_WIDTH]
            = {rd_data_fall1[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])],
               rd_data_rise1[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])],
               rd_data_fall0[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])],
               rd_data_rise0[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])]};
        always @(dqs_sync_c2[4*c2_i] or 
                 dqs_sync_c2[4*c2_i+1] or 
                 dqs_sync_c2[4*c2_i+2] or 
                 dqs_sync_c2[4*c2_i+3] ) begin 
          dqs_fall1_sync[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]]
            = dqs_sync_c2[4*c2_i+3];
          dqs_rise1_sync[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]]
            = dqs_sync_c2[4*c2_i+2];
          dqs_fall0_sync[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]]
            = dqs_sync_c2[4*c2_i+1];
          dqs_rise0_sync[DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]]
            = dqs_sync_c2[4*c2_i];
        end
        always @(data_sync_c2[4*DRAM_WIDTH*c2_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i] or 
                 data_sync_c2[4*DRAM_WIDTH*c2_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i+DRAM_WIDTH] or 
                 data_sync_c2[4*DRAM_WIDTH*c2_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i+2*DRAM_WIDTH] or 
                 data_sync_c2[4*DRAM_WIDTH*c2_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i+3*DRAM_WIDTH]) begin
          data_fall1_sync[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])]
            = data_sync_c2[4*DRAM_WIDTH*c2_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i+3*DRAM_WIDTH];
          data_rise1_sync[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])]
            = data_sync_c2[4*DRAM_WIDTH*c2_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i+2*DRAM_WIDTH];
          data_fall0_sync[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])]
            = data_sync_c2[4*DRAM_WIDTH*c2_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i+DRAM_WIDTH];
          data_rise0_sync[DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL2[(8*(c2_i+1))-1:8*c2_i])]
            = data_sync_c2[4*DRAM_WIDTH*c2_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c2_i];
        end
      end
      circ_buffer #
        (
         .TCQ        (TCQ),
         .DATA_WIDTH ((4*nDQS_COL2)+(4*DRAM_WIDTH*nDQS_COL2)),
         .BUF_DEPTH  (6)
         )
        u_rddata_sync_c2
          (
           .rclk  (clk),
           .wclk  (clk_rsync[2]),
           .rst   (rst_rsync[2]),
           .wdata ({dqs_c2,data_c2}),
           .rdata ({dqs_sync_c2,data_sync_c2})
           );
    end
  endgenerate
  generate
    genvar c3_i;
    if (nDQS_COL3 > 0) begin: gen_c3
      for (c3_i = 0; c3_i < nDQS_COL3; c3_i = c3_i + 1) begin: gen_loop_c3
        always @(rd_dqs_fall0 or rd_dqs_fall1 or
                 rd_dqs_rise0 or rd_dqs_rise1)
          dqs_c3[4*(c3_i+1)-1-:4]
            = {rd_dqs_fall1[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]],
               rd_dqs_rise1[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]],
               rd_dqs_fall0[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]],
               rd_dqs_rise0[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]]};
        always @(rd_data_fall0 or rd_data_fall1 or
                 rd_data_rise0 or rd_data_rise1)
          data_c3[4*DRAM_WIDTH*(c3_i+1)-1-:4*DRAM_WIDTH]
            = {rd_data_fall1[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])],
               rd_data_rise1[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])],
               rd_data_fall0[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])],
               rd_data_rise0[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                             DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])]};
        always @(dqs_sync_c3[4*c3_i] or 
                 dqs_sync_c3[4*c3_i+1] or 
                 dqs_sync_c3[4*c3_i+2] or 
                 dqs_sync_c3[4*c3_i+3]) begin 
          dqs_fall1_sync[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]]
            = dqs_sync_c3[4*c3_i+3];
          dqs_rise1_sync[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]]
            = dqs_sync_c3[4*c3_i+2];
          dqs_fall0_sync[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]]
            = dqs_sync_c3[4*c3_i+1];
          dqs_rise0_sync[DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]]
            = dqs_sync_c3[4*c3_i];
        end
        always @(data_sync_c3[4*DRAM_WIDTH*c3_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i] or 
                 data_sync_c3[4*DRAM_WIDTH*c3_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i+DRAM_WIDTH] or 
                 data_sync_c3[4*DRAM_WIDTH*c3_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i+2*DRAM_WIDTH] or 
                 data_sync_c3[4*DRAM_WIDTH*c3_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i+3*DRAM_WIDTH]) begin
          data_fall1_sync[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])]
            = data_sync_c3[4*DRAM_WIDTH*c3_i+4*DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i+3*DRAM_WIDTH];
          data_rise1_sync[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])]
            = data_sync_c3[4*DRAM_WIDTH*c3_i+3*DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i+2*DRAM_WIDTH];
          data_fall0_sync[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])]
            = data_sync_c3[4*DRAM_WIDTH*c3_i+2*DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i+DRAM_WIDTH];
          data_rise0_sync[DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i]+1)-1:
                          DRAM_WIDTH*(DQS_LOC_COL3[(8*(c3_i+1))-1:8*c3_i])]
            = data_sync_c3[4*DRAM_WIDTH*c3_i+DRAM_WIDTH-1:4*DRAM_WIDTH*c3_i];
        end
      end
      circ_buffer #
        (
         .TCQ        (TCQ),
         .DATA_WIDTH ((4*nDQS_COL3)+(4*DRAM_WIDTH*nDQS_COL3)),
         .BUF_DEPTH  (6)
         )
        u_rddata_sync_c3
          (
           .rclk  (clk),
           .wclk  (clk_rsync[3]),
           .rst   (rst_rsync[3]),
           .wdata ({dqs_c3,data_c3}),
           .rdata ({dqs_sync_c3,data_sync_c3})
           );
    end
  endgenerate
  always @(posedge clk) begin
    dfi_rddata <= #TCQ {data_fall1_sync,
                        data_rise1_sync,
                        data_fall0_sync,
                        data_rise0_sync};
    dfi_rd_dqs <= #TCQ {dqs_fall1_sync,
                        dqs_rise1_sync,
                        dqs_fall0_sync,
                        dqs_rise0_sync};
   end
endmodule
