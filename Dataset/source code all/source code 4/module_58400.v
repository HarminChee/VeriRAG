module crc16_2bit #(
  parameter             POLYNOMIAL  =   16'h1021,
  parameter             SEED        =   16'h0000
)(
  input                 clk,
  input                 rst,
  input                 en,
  input                 bit0,
  input                 bit1,
  output  reg   [15:0]  crc
);
wire         inv0;
wire         inv1;
assign inv1 = bit1 ^ crc[15];
assign inv0 = (bit0 ^ crc[14]);
always @ (posedge clk) begin
  if (rst) begin
    crc  <=  0;
  end
  else begin
    if (en) begin
      crc[15] <= crc[13];
      crc[14] <= crc[12];
      crc[13] <= crc[11] ^ inv1;
      crc[12] <= crc[10] ^ inv0;
      crc[11] <= crc[9];
      crc[10] <= crc[8];
      crc[9]  <= crc[7];
      crc[8]  <= crc[6];
      crc[7]  <= crc[5];
      crc[6]  <= crc[4] ^ inv1;
      crc[5]  <= crc[3] ^ inv0;
      crc[4]  <= crc[2];
      crc[3]  <= crc[1];
      crc[2]  <= crc[0];
      crc[1]  <= inv1;
      crc[0]  <= inv0;
    end
  end
end
endmodule
