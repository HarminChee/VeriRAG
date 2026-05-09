module slave #(
	parameter id = 0,
	parameter p = 3
) (
	input sys_clk,
	input sys_rst,
	input [31:0] dat_w,
	output reg [31:0] dat_r,
	input [31:0] adr,
	input [2:0] cti,
	input we,
	input [3:0] sel,
	input cyc,
	input stb,
	output reg ack
);
always @(posedge sys_clk) begin
	if(sys_rst) begin
		dat_r = 0;
		ack = 0;
	end else begin
		if(cyc & stb & ~ack) begin
			if(($random % p) == 0) begin
				ack = 1;
				if(~we)
					dat_r = ($random << 16) + id;
				if(we)
					$display("[S%d] Ack W: %x:%x [%x]", id, adr, dat_w, sel);
				else
					$display("[S%d] Ack R: %x:%x [%x]", id, adr, dat_r, sel);
			end
		end else
			ack = 0;
	end
end
endmodule
