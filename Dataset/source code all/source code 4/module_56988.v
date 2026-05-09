`define  FFD 1
`define  FFD 1
module cmm_errman_ram8x26 (
                rddata,                 
                wrdata,                 
                wr_ptr,
                rd_ptr,
                we,
                rst,
                clk
                );
  output [49:0] rddata;
  input  [49:0] wrdata;
  input   [2:0] wr_ptr;
  input   [2:0] rd_ptr;
  input         we;
  input         rst;
  input         clk;
  reg    [49:0] lutram_data [0:7];
  always @(posedge clk) begin
    if (we)
      lutram_data[wr_ptr] <= #`FFD wrdata;
  end
  reg    [49:0] reg_rdata;
  always @(posedge clk or posedge rst)
  begin
    if (rst)  reg_rdata <= #`FFD 50'h0000_0000_0000;
    else      reg_rdata <= #`FFD lutram_data[rd_ptr];
  end
  assign rddata = reg_rdata;
endmodule
