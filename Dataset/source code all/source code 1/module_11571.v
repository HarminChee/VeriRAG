`timescale 1ns/1ps
`timescale 1ns/1ps
module simul_axi_fifo
#(
  parameter integer WIDTH=  64,         
  parameter integer LATENCY=0,          
  parameter integer DEPTH=8,            
  parameter integer FIFO_DEPTH=LATENCY+DEPTH+1
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
  integer            in_count;
  integer            out_count;
  reg    [LATENCY:0] latency_delay_r;
  wire [LATENCY+1:0] latency_delay={latency_delay_r,load};             
  wire               out_inc=latency_delay[LATENCY];
  assign data_out=    fifo[out_address];
  assign valid=       out_count!=0;
  assign input_ready= in_count<DEPTH;
  always @ (posedge clk or posedge reset) begin
    if (reset) latency_delay_r <= 0;
    else       latency_delay_r <= latency_delay[LATENCY:0];
    if    (reset)  in_address <= 0;
    else if (load) in_address <= (in_address==(FIFO_DEPTH-1))?0:in_address+1;
    if    (reset)            out_address <= 0;
    else if (valid && ready) out_address <= (out_address==(FIFO_DEPTH-1))?0:out_address+1;
    if    (reset)                       in_count <= 0;
    else if (!(valid && ready) && load) in_count <= in_count+1;
    else if (valid && ready && !load)   in_count <= in_count-1;
    if    (reset)                          out_count <= 0;
    else if (!(valid && ready) && out_inc) out_count <= out_count+1;
    else if (valid && ready && !out_inc)   out_count <= out_count-1;
  end
  always @ (posedge clk) begin
    if (load) fifo[in_address] <= data_in;
  end
endmodule
