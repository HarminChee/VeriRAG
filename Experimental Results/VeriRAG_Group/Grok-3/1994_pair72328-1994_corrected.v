`timescale 1 ns / 1ps

module dyn_pll_ctrl # (parameter SPEED_MHZ = 25, parameter SPEED_LIMIT = 100, parameter SPEED_MIN = 25, parameter OSC_MHZ = 100)
	(clk,
	clk_valid,
	speed_in,
	start,
	progclk,
	progdata,
	progen,
	reset,
	locked,
	status,
	scan_clk,
	test_i);

	input clk;				// NB Assumed to be 12.5MHz uart_clk
	input clk_valid;		// Drive from LOCKED output of first dcm (ie uart_clk valid)
	input [7:0] speed_in;
	input start;
	output reg progclk = 0;
	output reg progdata = 0;
	output reg progen = 0;
	output reg reset = 0;
	input locked;
	input [2:1] status;
	input scan_clk;
	input test_i;

	wire dft_clk;
	assign dft_clk = test_i ? scan_clk : clk;

	reg [23:0] watchdog = 0;
	reg [7:0] state = 0;
	reg [7:0] dval = OSC_MHZ;	// Osc clock speed (hence mval scales in MHz)
	reg [7:0] mval = SPEED_MHZ;
	reg start_d1 = 0;
	
	always @ (posedge dft_clk)
	begin
		progclk <= ~progclk;
		start_d1 <= start;
		reset <= 1'b0;
		
		if (locked)
			watchdog <= 0;
		else
			watchdog <= watchdog + 1'b1;
		
		if (watchdog[23])
		begin
			watchdog <= 0;
			reset <= 1'b1;
		end
		
		if (~clk_valid)
		begin
			progen <= 0;
			progdata <= 0;
			state <= 0;
		end
		else
		begin
		
			if ((start || start_d1) && state==0 && speed_in >= SPEED_MIN && speed_in <= SPEED_LIMIT && progclk==1)
			begin
				progen <= 0;
				progdata <= 0;
				mval <= speed_in;
				dval <= OSC_MHZ;
				state <= 1;
			end
			if (state != 0)
				state <= state + 1'd1;
			case (state)
				2: begin
					progen <= 1;
					progdata <= 1;
				end
				4: begin
					progdata <= 0;
				end
				6,8,10,12,14,16,18,20: begin
					progdata <= dval[0];
					dval[6:0] <= dval[7:1];
				end
				22: begin
					progen <= 0;
					progdata <= 0;
				end
				32: begin
					progen <= 1;
					progdata <= 1;
				end
				36,38,40,42,44,46,48,50: begin
					progdata <= mval[0];
					mval[6:0] <= mval[7:1];
				end
				52: begin
					progen <= 0;
					progdata <= 0;
				end
				62: begin
					progen <= 1;
				end
				64: begin
					progen <= 0;
				end
				254: begin
					state <= 0;
				end
			endcase
		end
	end
endmodule