module  template_periph_16b (
    per_dout,                       
    mclk,                           
    per_addr,                       
    per_din,                        
    per_en,                         
    per_we,                         
    puc_rst                         
);
output       [15:0] per_dout;       
input               mclk;           
input        [13:0] per_addr;       
input        [15:0] per_din;        
input               per_en;         
input         [1:0] per_we;         
input               puc_rst;        
parameter       [14:0] BASE_ADDR   = 15'h0190;
parameter              DEC_WD      =  3;
parameter [DEC_WD-1:0] CNTRL1      = 'h0,
                       CNTRL2      = 'h2,
                       CNTRL3      = 'h4,
                       CNTRL4      = 'h6;
parameter              DEC_SZ      =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};
parameter [DEC_SZ-1:0] CNTRL1_D    = (BASE_REG << CNTRL1),
                       CNTRL2_D    = (BASE_REG << CNTRL2),
                       CNTRL3_D    = (BASE_REG << CNTRL3),
                       CNTRL4_D    = (BASE_REG << CNTRL4);
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);
wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};
wire [DEC_SZ-1:0] reg_dec   =  (CNTRL1_D  &  {DEC_SZ{(reg_addr == CNTRL1 )}})  |
                               (CNTRL2_D  &  {DEC_SZ{(reg_addr == CNTRL2 )}})  |
                               (CNTRL3_D  &  {DEC_SZ{(reg_addr == CNTRL3 )}})  |
                               (CNTRL4_D  &  {DEC_SZ{(reg_addr == CNTRL4 )}});
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};
reg  [15:0] cntrl1;
wire        cntrl1_wr = reg_wr[CNTRL1];
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        cntrl1 <=  16'h0000;
  else if (cntrl1_wr) cntrl1 <=  per_din;
reg  [15:0] cntrl2;
wire        cntrl2_wr = reg_wr[CNTRL2];
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        cntrl2 <=  16'h0000;
  else if (cntrl2_wr) cntrl2 <=  per_din;
reg  [15:0] cntrl3;
wire        cntrl3_wr = reg_wr[CNTRL3];
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        cntrl3 <=  16'h0000;
  else if (cntrl3_wr) cntrl3 <=  per_din;
reg  [15:0] cntrl4;
wire        cntrl4_wr = reg_wr[CNTRL4];
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        cntrl4 <=  16'h0000;
  else if (cntrl4_wr) cntrl4 <=  per_din;
wire [15:0] cntrl1_rd  = cntrl1  & {16{reg_rd[CNTRL1]}};
wire [15:0] cntrl2_rd  = cntrl2  & {16{reg_rd[CNTRL2]}};
wire [15:0] cntrl3_rd  = cntrl3  & {16{reg_rd[CNTRL3]}};
wire [15:0] cntrl4_rd  = cntrl4  & {16{reg_rd[CNTRL4]}};
wire [15:0] per_dout   =  cntrl1_rd  |
                          cntrl2_rd  |
                          cntrl3_rd  |
                          cntrl4_rd;
endmodule 
