`timescale 1ps/1ps
`timescale 1ps/1ps
module gtwizard_ultrascale_v1_7_1_bit_synchronizer # (
  parameter INITIALIZE = 5'b00000,
  parameter FREQUENCY  = 512
)(
  input  wire clk_in,
  input  wire i_in,
  output wire o_out
);
  (* ASYNC_REG = "TRUE" *) reg i_in_meta  = INITIALIZE[0];
  (* ASYNC_REG = "TRUE" *) reg i_in_sync1 = INITIALIZE[1];
  (* ASYNC_REG = "TRUE" *) reg i_in_sync2 = INITIALIZE[2];
  (* ASYNC_REG = "TRUE" *) reg i_in_sync3 = INITIALIZE[3];
                           reg i_in_out   = INITIALIZE[4];
  always @(posedge clk_in) begin
    i_in_meta  <= i_in;
    i_in_sync1 <= i_in_meta;
    i_in_sync2 <= i_in_sync1;
    i_in_sync3 <= i_in_sync2;
    i_in_out   <= i_in_sync3;
  end
  assign o_out = i_in_out;
endmodule
