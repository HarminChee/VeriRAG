`timescale 1ns / 1ps

// File: 1_corrected_ffc.v
module Freq_Count_Top(
	input					sys_clk_50m,ch_c,
	output	reg	[63:0]	freq_reg,
	input					sys_rst_n
	);

	reg	Gate_1S;			// 1s gate signal
	wire	Load;
	reg	EN_FT;
	wire	CLR; // Changed CLR to wire for combinational logic

//-----------------------------------------------------------------------
	parameter	HIGH_TIME_Gate_1S  	= 	50_000_000;
	parameter	LOW_TIME_Gate_1S   	= 	100_000_000;
//-----------------------------------------------------------------------
	reg [31:0] count;
	// This FF block uses primary clock sys_clk_50m - OK
	always@(posedge sys_clk_50m or negedge sys_rst_n)begin
		if(!sys_rst_n)begin
			count <= 32'b0;
			Gate_1S <= 1'b0;
			end
		else begin
			// Use non-blocking assignments for sequential logic outputs
			count <= count + 1'b1;
			if(count == HIGH_TIME_Gate_1S)
				Gate_1S <= 1'b0;
			else if(count == LOW_TIME_Gate_1S)begin
				count 	<= 32'b1; // Start count from 1 after wrap-around
				Gate_1S <= 1'b1;
				end
			// else: count keeps incrementing, Gate_1S holds value
			end
		end
//-----------------------------------------------------------------------
	// Define CLR combinationally based on Gate_1S and EN_FT
	assign CLR = Gate_1S | EN_FT;

	// This FF block uses primary clock ch_c - OK
	always@(posedge ch_c or negedge sys_rst_n)begin
		if(!sys_rst_n)begin
			EN_FT <= 1'b0; // Use non-blocking assignment
			end
		else begin
			EN_FT <= Gate_1S; // Use non-blocking assignment
			end
		end

	// Load is combinational logic derived from EN_FT (FF output)
	assign	Load = !EN_FT;

	reg	[63:0]	FT_out;
	// This FF block uses primary clock ch_c and primary reset sys_rst_n - OK
	// CLR is now treated as synchronous control logic, not asynchronous reset
	always @(posedge ch_c or negedge sys_rst_n)begin
		if(!sys_rst_n)begin
			FT_out <= 64'b0;
		end
		// Implement synchronous clear based on CLR signal
		else if(!CLR) begin // If CLR is low, clear the counter synchronously
			FT_out <= 64'b0;
		end
		else if(EN_FT)begin // If not cleared and enabled, increment
			FT_out <= FT_out + 1'b1;
		end
		// else: If !EN_FT and CLR is high, hold the value
	end

//   COUNTER_LOAD_MACRO #(
//      .COUNT_BY(48'h000000000001),
//      .DEVICE("7SERIES"),
//      .WIDTH_DATA(48)
//   ) freq_counter (
//      .Q(FT_out), // Should match WIDTH_DATA if used
//      .CLK(ch_c),
//      .CE(EN_FT),
//      .DIRECTION(1'b1),
//      .LOAD(!CLR), // Example: Use !CLR for synchronous load/clear
//      .LOAD_DATA(64'b0), // Match width
//      .RST(!sys_rst_n)
//   );

	// MODIFIED: This FF block now uses primary clock ch_c and primary reset sys_rst_n.
	// 'Load' is used as a synchronous enable signal. This fixes the FFCKNP violation.
	always@(posedge ch_c or negedge sys_rst_n)begin
	    if (!sys_rst_n) begin
	        freq_reg <= 64'b0;
	    end
		// Capture FT_out into freq_reg on posedge ch_c only when Load is asserted
		else if (Load) begin
			freq_reg <= FT_out;
		end
		// else: Hold the value of freq_reg if Load is low
	end


endmodule