`default_nettype none
`default_nettype none
module pulse_gen(
	input 	clk, 
input clk_pll,
	input 	RS232_Rx, 
	input 	resetn, 
	output RS232_Tx, 
	output Pulse, 
	output Sync, 
	 output P2
	);
	reg [31:0] 	period;
	reg [15:0] 	p1width;
	reg [15:0] 	delay;
	reg [15:0] 	p2width;
	reg [15:0]		nut_del;
	reg [7:0]		nut_wid;
	reg 			block;
	reg [7:0] 		pulse_block;
	reg [15:0] 	pulse_block_off;
	reg [7:0]	 	cpmg;
	reg			rx_done;
	pulses pulses(
		.clk(clk),
		.clk_pll(clk_pll),
		.reset(resetn),
		.per(period),
		.p1wid(p1width),
		.del(delay),
		.p2wid(p2width),
		.nut_d(nut_del),
		.nut_w(nut_wid),
		.cp(cpmg),
		.p_bl(pulse_block),
		.p_bl_off(pulse_block_off),
		.bl(block),
		.rxd(rx_done),
		.sync_on(Sync),
		.pulse_on(Pulse),
		.inhib(P2)
		);
   parameter att_on_val = 7'b1111111;
   parameter att_off_val = 7'b0000000;
   parameter stperiod = 1;
   parameter stp1width = 30; 
   parameter stp2width = 60;
   parameter stdelay = 200; 
   parameter stcpmg = 3; 
   parameter stblock = 50;
   parameter stblockoff = 100;
   parameter stnutwid = 100;
   parameter stnutdel = 100;
   always @(posedge clk) begin
		if (resetn) begin
			period = stperiod << 18;
			p1width = stp1width;
			delay = stdelay;
			p2width = stp2width;
			pulse_block = stblock;
			pulse_block_off = stblockoff;
			block = 1;
			cpmg = stcpmg;
			nut_wid = stnutwid;
			nut_del = stnutdel;
		end 
	end 
endmodule 
