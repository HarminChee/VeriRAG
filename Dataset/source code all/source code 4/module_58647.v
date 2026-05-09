`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pg_sequencer
(
  input clk,
  input sync,
  input reset,
	input enable,
  input start,
  output reg running,
  output reg [4:0]pgout,
  output reg [7:0]ip,  
  input [15:0]cmd
);
  wire [4:0]cmd_sig = cmd[12:8];
  wire [7:0]cmd_del = cmd[7:0];
  wire stop = cmd_del == 0;   
  reg [7:0]delay;   
  wire next = delay == 0;
  always @(posedge clk or posedge reset)
  begin
    if (reset) running <= 0;
    else if (enable)
    begin
    	if (sync)
    	begin
    	  if (start)             running <= 1;
    	  else if (stop && next) running <= 0;
    	end
    end
    else running <= 0;
  end
  always @(posedge clk or posedge reset)
  begin
    if (reset) ip <= 0;
    else if (sync)
    begin
      if (!running)  ip <= 0;
      else if (next) ip <= ip + 1;
    end
  end
  always @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      delay <= 0;
      pgout <= 0;
    end
    else if (sync)
    begin
      if (!running)
      begin
        delay <= 0;
        pgout <= 0;
      end
      else if (next)
      begin
        delay <= cmd_del;
        pgout <= cmd_sig;
      end
      else
      begin
        delay <= delay - 1;
        pgout <= 4'b0000;
      end
    end
  end
endmodule
