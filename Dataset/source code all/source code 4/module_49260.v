`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_rdctrl_sync #
  (
   parameter TCQ = 100
  )
  (
   input                      clk,
   input                      rst_rsync,       
   input                      mc_data_sel,
   input [4:0]                rd_active_dly,
   input                      dfi_rddata_en,
   input                      phy_rddata_en,
   output reg                 dfi_rddata_valid,
   output reg                 dfi_rddata_valid_phy,
   output reg                 rdpath_rdy       
   );
  localparam RDPATH_RDY_DLY = 10;
  wire                     rddata_en;
  wire                     rddata_en_rsync;
  wire                     rddata_en_srl_out;
  reg [RDPATH_RDY_DLY-1:0] rdpath_rdy_dly_r;
  assign rddata_en = (mc_data_sel) ? dfi_rddata_en : phy_rddata_en;
  SRLC32E u_rddata_en_srl
    (
     .Q   (rddata_en_srl_out),
     .Q31 (),
     .A   (rd_active_dly),
     .CE  (1'b1),
     .CLK (clk),
     .D   (rddata_en)
     );
  always @(posedge clk) begin
    dfi_rddata_valid <= #TCQ rddata_en_srl_out & mc_data_sel;
    dfi_rddata_valid_phy <= #TCQ rddata_en_srl_out;
  end
  always @(posedge clk or posedge rst_rsync) begin
    if (rst_rsync)
      rdpath_rdy_dly_r <= #TCQ {{RDPATH_RDY_DLY}{1'b0}};
    else
      rdpath_rdy_dly_r[RDPATH_RDY_DLY-1:1]
        <= #TCQ {rdpath_rdy_dly_r[RDPATH_RDY_DLY-2:0], 1'b1};
  end
  always @(posedge clk)
    rdpath_rdy <= rdpath_rdy_dly_r[RDPATH_RDY_DLY-1];
endmodule
