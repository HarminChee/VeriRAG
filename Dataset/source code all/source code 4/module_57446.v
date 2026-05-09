`timescale 1ps/1ps
`timescale 1ps/1ps
module rd_bitslip #
  (
   parameter TCQ = 100
  )
  (
   input            clk,
   input [1:0]      bitslip_cnt,
   input [1:0]      clkdly_cnt,
   input [5:0]      din,
   output reg [3:0] qout
   );
  reg       din2_r;
  reg [3:0] slip_out;
  reg [3:0] slip_out_r;
  reg [3:0] slip_out_r2;
  reg [3:0] slip_out_r3;
  always @(posedge clk)
    din2_r <= #TCQ din[2];
  always @(bitslip_cnt or din or din2_r)
    case (bitslip_cnt)
      2'b00: 
        slip_out = {din[3], din[2], din[1], din[0]};
      2'b01: 
        slip_out = {din[4], din[3], din[2], din[1]};
      2'b10: 
        slip_out = {din[5], din[4], din[3], din[2]};
      2'b11: 
        slip_out = {din2_r, din[5], din[4], din[3]};
    endcase
  always @(posedge clk) begin
    slip_out_r  <= #TCQ slip_out;
    slip_out_r2 <= #TCQ slip_out_r;
    slip_out_r3 <= #TCQ slip_out_r2;
  end
  always @(posedge clk)
    case (clkdly_cnt)
      2'b00: qout <= #TCQ slip_out;
      2'b01: qout <= #TCQ slip_out_r;
      2'b10: qout <= #TCQ slip_out_r2;
      2'b11: qout <= #TCQ slip_out_r3;
    endcase
endmodule
