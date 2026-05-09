`define simu 
`define simu 
module TOP_SYS(  
input i_100MHz_P,
input i_100MHz_N,
input rstn,
input TXD,
output RXD,
inout [63:0] DDR3DQ,
inout [7:0] DDR3DQS_N,
inout [7:0] DDR3DQS_P,
output [13:0] DDR3ADDR,
output [2:0] DDR3BA,
output DDR3RAS_N,
output DDR3CAS_N,
output DDR3WE_N,
output DDR3CK_P,
output DDR3CK_N,
output DDR3CKE,
output DDR3RST_N,
output [7:0] DDR3DM,
output DDR3ODT,
input sdin,
output sdout,
output sdcs,
inout [31:0] gpioA,
input VID_CLK_N,
input VID_CLK_P,
input [3:0] VID_D_N,
input [3:0] VID_D_P
);

wire clk;
wire npor;
wire reset_n;
reg npor_r;
reg npor_rr;
reg reset_n_r;
reg reset_n_rr;
reg [10:0] rsnt_cntn;
reg srst;
reg crst;
reg RxmResetRequest_o;
wire [4:0] ltssm;
wire l2_exit;
wire hotrst_exit;
wire dlup_exit;

wire test_mode;
wire dft_pld_clk;

assign test_mode = 1'b0;
assign dft_pld_clk = test_mode ? i_100MHz_P : clk;

always @(posedge dft_pld_clk or negedge npor)
  begin
    if (npor == 0)
      begin
        npor_r <= 0;
        npor_rr <= 0;
      end
    else 
      begin
        npor_r <= 1;
        npor_rr <= npor_r;
      end
  end

always @(posedge dft_pld_clk)
  begin
    if (reset_n_rr == 1'b0)
        RxmResetRequest_o <= 0;
    else if ((npor_rr == 1'b0) | (l2_exit == 1'b0) | (hotrst_exit == 1'b0) | (dlup_exit == 1'b0) | (ltssm == 5'h10))
        RxmResetRequest_o <= 1;
  end

always @(posedge dft_pld_clk or negedge reset_n)
  begin
    if (reset_n == 0)
      begin
        reset_n_r <= 0;
        reset_n_rr <= 0;
      end
    else 
      begin
        reset_n_r <= 1;
        reset_n_rr <= reset_n_r;
      end
  end

always @(posedge dft_pld_clk or negedge reset_n_rr)
  begin
    if (reset_n_rr == 0)
        rsnt_cntn <= 0;
    else if (rsnt_cntn != 4'hf)
        rsnt_cntn <= rsnt_cntn + 1;
  end

always @(posedge dft_pld_clk or negedge reset_n_rr)
  begin
    if (reset_n_rr == 0)
      begin
        srst <= 1;
        crst <= 1;
      end
    else if (rsnt_cntn == 4'hf)
      begin
        srst <= 0;
        crst <= 0;
      end
  end

endmodule