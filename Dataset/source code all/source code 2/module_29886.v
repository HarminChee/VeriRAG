`timescale 1ns / 10ps
`timescale 1ns / 10ps
module dd_sync  #(WIDTH = 1,  STAGES  = 2,  RST_VAL = 0)
(
    clk,
    rst_n,
    data_i,
    data_sync_o
);
  input                       clk;
  input                       rst_n;
  input   [WIDTH-1:0]         data_i;
  output  [WIDTH-1:0]         data_sync_o;
  reg     [WIDTH-1:0]         sync_pipe_f [0:STAGES-1];
  genvar  i;
  generate
    for(i=0;  i<STAGES; i++)
    begin : SYNC
      always@(posedge clk,  negedge rst_n)
      begin
        if(~rst_n)
        begin
          sync_pipe_f[i]      <=  RST_VAL;
        end
        else
        begin
          sync_pipe_f[i]      <=  (i  ==  0)  ? data_i  : sync_pipe_f[i-1];
        end
      end
    end
  endgenerate
  assign  data_sync_o = sync_pipe_f[STAGES-1];
endmodule 
