module fpga_zet_top (
    input             clk_i,
    input             rst_i,
    input      [15:0] wb_dat_i,
    output reg [15:0] wb_dat_o,
    output reg [19:1] wb_adr_o,
    output reg        wb_we_o,
    output reg        wb_tga_o,  
    output reg [ 1:0] wb_sel_o,
    output reg        wb_stb_o,
    output reg        wb_cyc_o,
    input             wb_ack_i,
    input             intr,
    output reg        inta,
    input      [ 3:0] iid,
    output reg [19:0] pc
  );
  reg  [15:0] wb_dat_i_l;
  wire [15:0] wb_dat_o_l;
  wire [19:1] wb_adr_o_l;
  wire        wb_we_o_l;
  wire        wb_tga_o_l;  
  wire [ 1:0] wb_sel_o_l;
  wire        wb_stb_o_l;
  wire        wb_cyc_o_l;
  reg         wb_ack_i_l;
  reg         intr_l;  
  wire        inta_l;  
  reg  [ 3:0] iid_l;
  wire [19:0] pc_l;
  zet zet (
    .clk_i (clk_i),
    .rst_i (rst_i),
    .wb_dat_i (wb_dat_i_l),
    .wb_dat_o (wb_dat_o_l),
    .wb_adr_o (wb_adr_o_l),
    .wb_we_o  (wb_we_o_l),
    .wb_tga_o (wb_tga_o_l),  
    .wb_sel_o (wb_sel_o_l),
    .wb_stb_o (wb_stb_o_l),
    .wb_cyc_o (wb_cyc_o_l),
    .wb_ack_i (wb_ack_i_l),
    .intr (intr_l),  
    .inta (inta_l),  
    .iid (iid_l),
    .pc  (pc_l)
  );
  always @(posedge clk_i)
    begin
      wb_dat_i_l <= wb_dat_i;
      wb_dat_o <= wb_dat_o_l;
      wb_adr_o <= wb_adr_o_l;
      wb_we_o  <= wb_we_o_l;
      wb_tga_o <= wb_tga_o_l;
      wb_sel_o <= wb_sel_o_l;
      wb_stb_o <= wb_stb_o_l;
      wb_cyc_o <= wb_cyc_o_l;
      wb_ack_i_l <= wb_ack_i;
      intr_l <= intr;
      inta   <= inta_l;
      iid_l  <= iid;
      pc     <= pc_l;
    end
endmodule
