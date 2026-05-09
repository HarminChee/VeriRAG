`timescale 1ns / 1ps

module ControllerReadTempI2C(Clock, Reset, SDA, Start, BaudEnable, Done, ReadOrWrite, Select, ShiftOrHold, StartStopAck, WriteLoad);
  input Clock;
  input Reset;
  input SDA;
  input Start;
  output reg BaudEnable;
  output reg Done;
  output reg ReadOrWrite;
  output reg Select;
  output reg ShiftOrHold;
  output reg StartStopAck;
  output reg WriteLoad;

  reg [3:0] DataCounter;
  reg [2:0] State;
  reg [2:0] NextState;
  parameter InitialState = 3'd0;
  parameter LoadState = 3'd1;
  parameter WriteState = 3'd2;
  parameter ReadState = 3'd3;
  
  wire OneShotNegative, OneShotPositive;
  reg ACKbit;

  // Instantiate one-shot modules, using the primary clock
  ClockedNegativeOneShot OneShotNegativeUnit(Clock, OneShotNegative, Reset, Clock);
  ClockedPositiveOneShot OneShotPositiveUnit(Clock, OneShotPositive, Reset, Clock);


  always @(posedge Clock) begin
    if (Reset == 1) begin
      State <= InitialState;
      ACKbit <= 1;
    end else begin
      State <= NextState;
      if (OneShotPositive == 1)
        ACKbit <= SDA;
      else
        ACKbit <= ACKbit;
    end
  end

  always @(posedge Clock) begin
    if (Reset == 1)
      DataCounter <= 4'd9;
    else
      case (State)
        LoadState:
          if (OneShotNegative == 0)
            DataCounter <= DataCounter - 1'b1;
          else
            DataCounter <= DataCounter;
        WriteState:
          if (OneShotNegative == 0)
            DataCounter <= DataCounter - 1'b1;
          else
            DataCounter <= DataCounter;
        ReadState:
          if (OneShotPositive == 1)
            DataCounter <= DataCounter - 1'b1;
          else
            DataCounter <= DataCounter;
        default:
          DataCounter <= 4'd9;
      endcase
  end

  //Example output assignments, replace with actual logic
  always @(posedge Clock) begin
    if (Reset) begin
      BaudEnable <= 0;
      Done <= 0;
      ReadOrWrite <= 0;
      Select <= 0;
      ShiftOrHold <= 0;
      StartStopAck <= 0;
      WriteLoad <= 0;
    end else begin
      // Add logic here to control the outputs based on the state machine
      // This is just a placeholder
      BaudEnable <= 1'b0;
      Done <= 1'b0;
      ReadOrWrite <= 1'b0;
      Select <= 1'b0;
      ShiftOrHold <= 1'b0;
      StartStopAck <= 1'b0;
      WriteLoad <= 1'b0;
    end
  end

endmodule

module ClockedNegativeOneShot(clock, one_shot, reset, clk);
  input clock, reset, clk;
  output reg one_shot;
  reg q;

  always @(posedge clk) begin
    if (reset) begin
      q <= 0;
      one_shot <= 0;
    end else begin
      if (clock == 1 && q == 0) begin
        q <= 1;
        one_shot <= 1;
      end else begin
        q <= 0;
        one_shot <= 0;
      end
    end
  end
endmodule

module ClockedPositiveOneShot(clock, one_shot, reset, clk);
  input clock, reset, clk;
  output reg one_shot;
  reg q;

  always @(posedge clk) begin
    if (reset) begin
      q <= 0;
      one_shot <= 0;
    end else begin
      if (clock == 0 && q == 0) begin
        q <= 1;
        one_shot <= 1;
      end else begin
        q <= 0;
        one_shot <= 0;
      end
    end
  end
endmodule