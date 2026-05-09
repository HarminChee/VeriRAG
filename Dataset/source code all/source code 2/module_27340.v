`timescale 1ns / 1ps
module Clock
  #(COUNT_HALF_CYCLE = 26'd49999999,
    COUNT_BIT_WIDTH = 26)
   (input      baseClock,
    input      reset,
    output reg derivClock);
   reg [COUNT_BIT_WIDTH - 1:0] halfCycleCount; 
   wire isPassedHalfCycle = (halfCycleCount == COUNT_HALF_CYCLE);  
   always @(posedge baseClock) begin
      if (reset) begin
	halfCycleCount <= 1'b0;
	derivClock <= 1'b0;
      end
      else if (isPassedHalfCycle) begin
	halfCycleCount <= 1'b0;
	derivClock <= ~derivClock;
      end
      else
	halfCycleCount <= halfCycleCount + 1'b1;
   end;
endmodule 
`timescale 1ns / 1ps
module Clocks
  (input baseClock,
   input  reset,
   output clock1Hz,
   output clock10Hz);
   parameter COUNT_HALF_1HZ = 26'd49999999;
   parameter COUNT_HALF_BIT_WIDTH_1HZ = 26;
   parameter COUNT_HALF_10HZ = 23'd4999999;
   parameter COUNT_HALF_BIT_WIDTH_10HZ = 23;
   Clock #(COUNT_HALF_1HZ, COUNT_HALF_BIT_WIDTH_1HZ)clk1Hz(baseClock, reset, clock1Hz);
   Clock #(COUNT_HALF_10HZ, COUNT_HALF_BIT_WIDTH_10HZ)clk10Hz(baseClock, reset, clock10Hz);
endmodule 
module Clock
  #(COUNT_HALF_CYCLE = 26'd49999999,
    COUNT_BIT_WIDTH = 26)
   (input      baseClock,
    input      reset,
    output reg derivClock);
   reg [COUNT_BIT_WIDTH - 1:0] halfCycleCount; 
   wire isPassedHalfCycle = (halfCycleCount == COUNT_HALF_CYCLE);  
   always @(posedge baseClock) begin
      if (reset) begin
	halfCycleCount <= 1'b0;
	derivClock <= 1'b0;
      end
      else if (isPassedHalfCycle) begin
	halfCycleCount <= 1'b0;
	derivClock <= ~derivClock;
      end
      else
	halfCycleCount <= halfCycleCount + 1'b1;
   end;
endmodule 
