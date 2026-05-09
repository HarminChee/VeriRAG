module crc (
  clk,
  rst,
  en,
  din,
  dout
);
input               clk;
input               rst;
input               en;
input   [31:0]      din;
output  reg [31:0]  dout;
parameter         CRC_INIT  = 32'h52325032;
wire    [31:0]    crc_next;
wire    [31:0]    crc_new;
always @ (posedge clk) begin
  if (rst) begin
    dout           <=  CRC_INIT;
  end
  else if (en) begin
    dout           <=  crc_next;
  end
end
assign crc_new    = dout ^ din;
assign crc_next[31] =crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[15]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[5];
assign crc_next[30] =crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[4];
assign crc_next[29] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[3];
assign crc_next[28] =crc_new[30]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[12]   ^
                     crc_new[8]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[2];
assign crc_next[27] =crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[11]   ^
                     crc_new[7]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[1];
assign crc_next[26] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[10]   ^
                     crc_new[6]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[0];
assign crc_next[25] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[3]    ^
                     crc_new[2];
assign crc_next[24] =crc_new[30]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[2]    ^
                     crc_new[1];
assign crc_next[23] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[1]    ^
                     crc_new[0];
assign crc_next[22] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[0];
assign crc_next[21] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[13]   ^
                     crc_new[10]   ^
                     crc_new[9]    ^
                     crc_new[5];
assign crc_next[20] =crc_new[30]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[23]   ^
                     crc_new[21]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[4];
assign crc_next[19] =crc_new[29]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[20]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[3];
assign crc_next[18] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[21]   ^
                     crc_new[19]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[2];
assign crc_next[17] =crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[20]   ^
                     crc_new[18]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[1];
assign crc_next[16] =crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[19]   ^
                     crc_new[17]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[8]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[0];
assign crc_next[15] =crc_new[30]   ^
                     crc_new[27]   ^
                     crc_new[24]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[18]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[3];
assign crc_next[14] =crc_new[29]   ^
                     crc_new[26]   ^
                     crc_new[23]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[2];
assign crc_next[13] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[25]   ^
                     crc_new[22]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[1];
assign crc_next[12] =crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[27]   ^
                     crc_new[24]   ^
                     crc_new[21]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[2]    ^
                     crc_new[1]    ^
                     crc_new[0];
assign crc_next[11] =crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[20]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[12]   ^
                     crc_new[9]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[1]    ^
                     crc_new[0];
assign crc_next[10] =crc_new[31]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[19]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[5]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[0];
assign crc_next[9] = crc_new[29]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[18]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[2]    ^
                     crc_new[1];
assign crc_next[8] = crc_new[31]   ^
                     crc_new[28]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[17]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[10]   ^
                     crc_new[8]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[1]    ^
                     crc_new[0];
assign crc_next[7] = crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[23]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[16]   ^
                     crc_new[15]   ^
                     crc_new[10]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[5]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[0];
assign crc_next[6] = crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[25]   ^
                     crc_new[22]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[14]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[2]    ^
                     crc_new[1];
assign crc_next[5] = crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[24]   ^
                     crc_new[21]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[13]   ^
                     crc_new[10]   ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[5]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[1]    ^
                     crc_new[0];
assign crc_next[4] = crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[20]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[15]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[8]    ^
                     crc_new[6]    ^
                     crc_new[4]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[0];
assign crc_next[3] = crc_new[31]   ^
                     crc_new[27]   ^
                     crc_new[25]   ^
                     crc_new[19]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[15]   ^
                     crc_new[14]   ^
                     crc_new[10]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[3]    ^
                     crc_new[2]    ^
                     crc_new[1];
assign crc_next[2] = crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[26]   ^
                     crc_new[24]   ^
                     crc_new[18]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[14]   ^
                     crc_new[13]   ^
                     crc_new[9]    ^
                     crc_new[8]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[2]    ^
                     crc_new[1]    ^
                     crc_new[0];
assign crc_next[1] = crc_new[28]   ^
                     crc_new[27]   ^
                     crc_new[24]   ^
                     crc_new[17]   ^
                     crc_new[16]   ^
                     crc_new[13]   ^
                     crc_new[12]   ^
                     crc_new[11]   ^
                     crc_new[9]    ^
                     crc_new[7]    ^
                     crc_new[6]    ^
                     crc_new[1]    ^
                     crc_new[0];
assign crc_next[0] = crc_new[31]   ^
                     crc_new[30]   ^
                     crc_new[29]   ^
                     crc_new[28]   ^
                     crc_new[26]   ^
                     crc_new[25]   ^
                     crc_new[24]   ^
                     crc_new[16]   ^
                     crc_new[12]   ^
                     crc_new[10]   ^
                     crc_new[9]    ^
                     crc_new[6]    ^
                     crc_new[0];
endmodule
