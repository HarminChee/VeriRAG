`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ghrd_10as066n2_led_pio_altera_avalon_pio_171_yz2rppa (
                                                               address,
                                                               chipselect,
                                                               clk,
                                                               in_port,
                                                               reset_n,
                                                               write_n,
                                                               writedata,
                                                               out_port,
                                                               readdata
                                                            )
;
  output  [  3: 0] out_port;
  output  [ 31: 0] readdata;
  input   [  1: 0] address;
  input            chipselect;
  input            clk;
  input   [  3: 0] in_port;
  input            reset_n;
  input            write_n;
  input   [ 31: 0] writedata;
wire             clk_en;
wire    [  3: 0] data_in;
reg     [  3: 0] data_out;
wire    [  3: 0] out_port;
wire    [  3: 0] read_mux_out;
reg     [ 31: 0] readdata;
  assign clk_en = 1;
  assign read_mux_out = {4 {(address == 0)}} & data_in;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          readdata <= 0;
      else if (clk_en)
          readdata <= {32'b0 | read_mux_out};
    end
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_out <= 0;
      else if (chipselect && ~write_n && (address == 0))
          data_out <= writedata[3 : 0];
    end
  assign out_port = data_out;
  assign data_in = in_port;
endmodule
