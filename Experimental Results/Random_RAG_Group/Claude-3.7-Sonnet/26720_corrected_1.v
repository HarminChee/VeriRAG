`timescale 1ns / 1ps
module ControllerReadTempI2C(Clock,ClockI2C,Reset,SDA,Start,BaudEnable,Done,ReadOrWrite,Select,ShiftOrHold,StartStopAck,WriteLoad,test_i);
	input Clock;
	input ClockI2C;
	input Reset;
	input SDA;
	input Start;
	input test_i;
	output BaudEnable;
	output Done;
	output ReadOrWrite;
	output Select;
	output ShiftOrHold;
	output StartStopAck;
	output WriteLoad;
	reg [3:0] DataCounter;
	reg [2:0] State;
	reg [2:0] NextState;
	parameter InitialState = 3'd0;
	parameter LoadState = 3'd1;
	parameter WriteState = 3'd2;
	parameter ReadState = 3'd3;
	wire OneShotNegative, OneShotPositive;
	wire dft_clock;
	assign dft_clock = test_i ? Clock : ClockI2C;
	ClockedNegativeOneShot OneShotNegativeUnit(dft_clock, OneShotNegative, Reset, Clock);
	ClockedPositiveOneShot OneShotPositiveUnit(dft_clock, OneShotPositive, Reset, Clock);
	reg ACKbit;
	always@(posedge Clock or negedge Reset)
		if(!Reset) begin State<=InitialState; ACKbit<=1; end
		else begin
			State<=NextState;
			if(OneShotPositive==1) ACKbit<=SDA; else ACKbit<=ACKbit;
		end
	always@(posedge Clock or negedge Reset)
		if(!Reset) begin DataCounter<=4'd9; end
		else case (State)
		LoadState:
			if(OneShotNegative==0) DataCounter<=DataCounter-1'b1;
			else DataCounter<=DataCounter;
		WriteState:
			if(OneShotNegative==0) DataCounter<=DataCounter-1'b1;
			else DataCounter<=DataCounter;
		ReadState:
			if(OneShotPositive==1) DataCounter<=DataCounter-1'b1;
			else DataCounter<=DataCounter;
		default: DataCounter<=4'd9;
		endcase
endmodule