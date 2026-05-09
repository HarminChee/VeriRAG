`timescale 1ns/1ps
`timescale 1ns/1ps
module simul_fifo
#(
  parameter integer WIDTH=  32,         
  parameter integer DEPTH=  64,         
  parameter integer FIFO_DEPTH=DEPTH+1
)(
  input              clk,
  input              reset,
  input  [WIDTH-1:0] data_in,
  input              load,
  output             input_ready,
  output [WIDTH-1:0] data_out,
  output             valid,
  input              ready);
  reg  [WIDTH-1:0]   fifo [0:FIFO_DEPTH-1];
  integer            in_address;
  integer            out_address;
  integer            count;
  assign data_out=    fifo[out_address];
  assign valid=       count!=0;
  assign input_ready= count<DEPTH;
  always @ (posedge clk or posedge reset) begin
    if    (reset)  in_address <= 0;
    else if (load) in_address <= (in_address==(FIFO_DEPTH-1))?0:in_address+1;
    if    (reset)            out_address <= 0;
    else if (valid && ready) out_address <= (out_address==(FIFO_DEPTH-1))?0:out_address+1;
    if    (reset)                       count <= 0;
    else if (!(valid && ready) && load) count <= count+1;
    else if (valid && ready && !load)   count <= count-1;
  end
  always @ (posedge clk) begin
    if (load) fifo[in_address] <= data_in;
  end
endmodule
