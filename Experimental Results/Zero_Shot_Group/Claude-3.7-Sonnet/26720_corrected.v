`timescale 1ns / 1ps

module ControllerReadTempI2C(
    input Clock,
    input ClockI2C,
    input Reset,
    input SDA,
    input Start,
    output reg BaudEnable,
    output reg Done,
    output reg ReadOrWrite,
    output reg Select,
    output reg ShiftOrHold,
    output reg StartStopAck,
    output reg WriteLoad
);

    reg [3:0] DataCounter;
    reg [2:0] State;
    reg [2:0] NextState;

    parameter InitialState = 3'd0;
    parameter LoadState = 3'd1;
    parameter WriteState = 3'd2;
    parameter ReadState = 3'd3;

    wire OneShotNegative, OneShotPositive;
	 reg ACKbit;

    ClockedNegativeOneShot OneShotNegativeUnit(
        .Clock(ClockI2C),
        .OneShot(OneShotNegative),
        .Reset(Reset)
    );

    ClockedPositiveOneShot OneShotPositiveUnit(
        .Clock(ClockI2C),
        .OneShot(OneShotPositive),
        .Reset(Reset)
    );



    always @(posedge Clock) begin
        if (Reset == 1) begin
            State <= InitialState;
            ACKbit <= 1'b1;
        end else begin
            State <= NextState;
            if (OneShotPositive == 1'b1)
                ACKbit <= SDA;
            
        end
    end

    always @(posedge Clock) begin
        if (Reset == 1) begin
            DataCounter <= 4'd9;
        end else case (State)
            LoadState: begin
                if (OneShotNegative == 1'b0)
                    DataCounter <= DataCounter - 1'b1;
            end
            WriteState: begin
                if (OneShotNegative == 1'b0)
                    DataCounter <= DataCounter - 1'b1;
            end
            ReadState: begin
                if (OneShotPositive == 1'b1)
                    DataCounter <= DataCounter - 1'b1;
            end
            default: begin
                DataCounter <= 4'd9;
            end
        endcase
    end

	 always @(*) begin
		case(State)
			InitialState: NextState = LoadState;
			LoadState: NextState = WriteState;
			WriteState: NextState = ReadState;
			ReadState: NextState = InitialState;
			default: NextState = InitialState;
		endcase
	 end
	 
	 always @(posedge Clock) begin
		if (Reset) begin
			BaudEnable <= 1'b0;
			Done <= 1'b0;
			ReadOrWrite <= 1'b0;
			Select <= 1'b0;
			ShiftOrHold <= 1'b0;
			StartStopAck <= 1'b0;
			WriteLoad <= 1'b0;
		end else begin
			case(State)
				InitialState: begin
					BaudEnable <= 1'b0;
					Done <= 1'b0;
					ReadOrWrite <= 1'b0;
					Select <= 1'b0;
					ShiftOrHold <= 1'b0;
					StartStopAck <= 1'b0;
					WriteLoad <= 1'b0;
				end
				LoadState: begin
					BaudEnable <= 1'b1;
					Done <= 1'b0;
					ReadOrWrite <= 1'b0;
					Select <= 1'b0;
					ShiftOrHold <= 1'b0;
					StartStopAck <= 1'b0;
					WriteLoad <= 1'b0;
				end
				WriteState: begin
					BaudEnable <= 1'b0;
					Done <= 1'b0;
					ReadOrWrite <= 1'b1;
					Select <= 1'b1;
					ShiftOrHold <= 1'b1;
					StartStopAck <= 1'b1;
					WriteLoad <= 1'b1;
				end
				ReadState: begin
					BaudEnable <= 1'b0;
					Done <= 1'b1;
					ReadOrWrite <= 1'b0;
					Select <= 1'b0;
					ShiftOrHold <= 1'b0;
					StartStopAck <= 1'b0;
					WriteLoad <= 1'b0;
				end
				default: begin
					BaudEnable <= 1'b0;
					Done <= 1'b0;
					ReadOrWrite <= 1'b0;
					Select <= 1'b0;
					ShiftOrHold <= 1'b0;
					StartStopAck <= 1'b0;
					WriteLoad <= 1'b0;
				end
			endcase
		end
	 end

endmodule

module ClockedNegativeOneShot(
    input Clock,
    output reg OneShot,
    input Reset
);

    reg PreviousClock;

    always @(posedge Clock) begin
        if (Reset) begin
            OneShot <= 1'b0;
            PreviousClock <= 1'b0;
        end else begin
            if (Clock == 1'b0 && PreviousClock == 1'b1)
                OneShot <= 1'b1;
            else
                OneShot <= 1'b0;

            PreviousClock <= Clock;
        end
    end

endmodule

module ClockedPositiveOneShot(
    input Clock,
    output reg OneShot,
    input Reset
);

    reg PreviousClock;

    always @(posedge Clock) begin
        if (Reset) begin
            OneShot <= 1'b0;
            PreviousClock <= 1'b0;
        end else begin
            if (Clock == 1'b1 && PreviousClock == 1'b0)
                OneShot <= 1'b1;
            else
                OneShot <= 1'b0;

            PreviousClock <= Clock;
        end
    end

endmodule