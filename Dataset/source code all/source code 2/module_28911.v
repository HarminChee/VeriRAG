module pulses(
	input 		 clk, 
	input 	     clk_pll, 
	input 	     reset, 
	input [31:0]  per, 
	input [15:0] p1wid, 
	input [15:0] del, 
	input [15:0] p2wid, 
	input [7:0] nut_w, 
	input [15:0] nut_d, 
	input [7:0]  cp, 
	input [7:0]  p_bl, 
	input [15:0] p_bl_off, 
	input 	     bl,
	input		 rxd,
	output 	   sync_on, 
	output 	   pulse_on, 
	output 	   inhib 
	);
	reg [31:0] 		   counter = 32'd0; 
	reg 			   sync;
	reg 			   pulse; 
	reg 			   pulses; 
	reg 			   nut_pulse; 
	reg 			   inh;
	reg 			   rec = 0;
	reg				   cw = 0;
	parameter stperiod = 1; 
	parameter stp1width = 30; 
	parameter stp2width = 30; 
	parameter stdelay = 200; 
	parameter stblock = 100; 
	parameter stcpmg = 3; 
	reg [31:0] 			    period = stperiod << 16; 
	reg [15:0] 			    p1width = stp1width;
	reg [15:0] 			    delay = stdelay;
	reg [15:0] 			    p2width = stp2width;
	reg [7:0] 			    pulse_block = 8'd50;
	reg [15:0] 			    pulse_block_off = stblock;
	reg [7:0]  			    cpmg = stcpmg;
	reg 				   	block = 1;
	reg 					rx_done = 0;
	reg [15:0] p2start = stp1width+stdelay;
	reg [15:0] sync_down = stp1width+stdelay+stp2width;
	reg [15:0] block_off = stp1width+stdelay+stdelay+stp2width-8'd50;
	reg [15:0] block_on = stp1width+stdelay+stdelay+stp2width;
	reg  		nutation_pulse = 0;
	reg [7:0]  nutation_pulse_width = 8'd50;
	reg [15:0]  nutation_pulse_delay = 16'd300;
	reg [23:0]  nutation_pulse_start;
	reg [23:0]  nutation_pulse_stop;
	reg [7:0] 		   ccount = 0; 
	reg [31:0] 		   cdelay; 
	reg [31:0] 		   cpulse; 
	reg [31:0] 		   cblock_delay; 
	reg [31:0] 		   cblock_on; 
	reg [1:0] xfer_bits = 1;
	assign sync_on = sync; 
	assign pulse_on = pulse; 
	assign inhib = inh; 
	always @(posedge clk) begin
		{ rx_done, xfer_bits } <= { xfer_bits, rxd };
		if (rx_done) begin
			period  <= per;
			p1width <= p1wid;
			p2width <= p2wid;
			delay <= del;
			nutation_pulse_delay <= nut_d;
			nutation_pulse_width <= nut_w;
			pulse_block <= p_bl;
			pulse_block_off <= p_bl_off;
			cpmg <= cp;
			block <= bl;
		end
		p2start <= p1width + delay;
		sync_down <= p1width + delay + p2width;
		block_off <= p1width + delay + p2width + delay - pulse_block;
		block_on <= p1width + delay + p2width + delay;
		if (reset) begin
			counter <= 0;
		end
		cw <= (cpmg > 0) ? 0 : 1;
	end
	always @(posedge clk_pll) begin
		if (!reset) begin			
			nutation_pulse_start <= per - nutation_pulse_delay - nutation_pulse_width;
			nutation_pulse_stop <= per - nutation_pulse_delay;
			nut_pulse <= (counter < nutation_pulse_start) ? 0 :
				((counter < nutation_pulse_stop) ? 1 : 0);
			case (cpmg)
			0 : begin 
				pulse <= 1;
				if (counter == per/2) begin 
					sync <= 0;
				end
			end
			1: begin 
				pulses <= (counter < p1width) ? 1 :
				((counter < p2start) ? cw : 
				((counter < sync_down) ? 1 : cw)); 
				inh <= (counter < block_off) ? block : 
				((counter < block_on) ? 0 : block); 
				sync <= (counter < sync_down) ? 1 : 0; 
			end
			default : begin 
				case (counter) 
					0: begin 
					sync <= 1;
					pulses <= 1;
					inh <= block;
					cdelay <= p1width + delay; 
					cpulse <= p1width + delay + p2width; 
					cblock_delay <= p1width + delay + p2width + pulse_block; 
					cblock_on <= p1width + delay + p2width + pulse_block_off; 
					ccount <= 0;
					end 
					p1width: begin
						pulses <= 0; 
					end 
					cdelay: begin
						pulses <= (ccount < cpmg) ? 1 : pulses; 
					end 
					cpulse: begin		 
						if (ccount < cpmg) begin 
						pulses <= 0;
						cdelay <= cpulse + delay + delay; 
						cpulse <= cpulse + delay + delay + p2width; 
						end
						sync <= (ccount == cpmg - 1) ? 0 : sync; 
					end 
					cblock_delay: begin
						if (ccount < cpmg) begin 
							inh <= 0;
						end
					end 
					cblock_on: begin
						if (ccount < cpmg) begin 
							inh <= block;
							cblock_delay <= cpulse + pulse_block; 
							cblock_on <= cpulse + pulse_block_off; 
							ccount <= ccount + 1;
						end
					end 
				endcase 
			end
		endcase
		counter <= (counter < period) ? counter + 1 : 0; 
		pulse <= pulses || nut_pulse;
		end
	end 
endmodule 
