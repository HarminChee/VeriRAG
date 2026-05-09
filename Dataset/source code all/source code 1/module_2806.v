module master #(
	parameter id = 0,
	parameter nreads = 128,
	parameter nwrites = 128,
	parameter p = 4
) (
	input sys_clk,
	input sys_rst,
	output reg [31:0] dat_w,
	input [31:0] dat_r,
	output reg [31:0] adr,
	output [2:0] cti,
	output reg we,
	output reg [3:0] sel,
	output cyc,
	output stb,
	input ack,
	output reg tend
);
integer rcounter;
integer wcounter;
reg active;
assign cyc = active;
assign stb = active;
assign cti = 0;
always @(posedge sys_clk) begin
	if(sys_rst) begin
		dat_w = 0;
		adr = 0;
		we = 0;
		sel = 0;
		active = 0;
		rcounter = 0;
		wcounter = 0;
		tend = 0;
	end else begin
		if(ack) begin
			if(~active)
				$display("[M%d] Spurious ack", id);
			else begin
				if(we)
					$display("[M%d] Ack W: %x:%x [%x]", id, adr, dat_w, sel);
				else
					$display("[M%d] Ack R: %x:%x [%x]", id, adr, dat_r, sel);
			end
			active = 1'b0;
		end else if(~active) begin
			if(($random % p) == 0) begin
				adr = $random;
				adr = adr % 5;
				adr = (adr << (32-3)) + id;
				sel = sel + 1;
				active = 1'b1;
				if(($random % 2) == 0) begin
					we = 1'b0;
					rcounter = rcounter + 1;
				end else begin
					we = 1'b1;
					dat_w = ($random << 16) + id;
					wcounter = wcounter + 1;
				end
			end
		end
		tend = (rcounter >= nreads) && (wcounter >= nwrites);
	end
end
endmodule
