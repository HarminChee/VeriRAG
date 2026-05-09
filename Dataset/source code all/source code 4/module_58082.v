module calc_res(
input wire rst_n,    
input wire clk,      
input de,
input hsync,
input vsync,
output reg [15:0] resX,
output reg [15:0] resY
);
reg [15:0] resX_q,resY_q,resY_t;
reg vsync_q,hsync_q,de_q;
wire hsync_risingedge;
wire vsync_risingedge;
wire de_risingedge;
assign hsync_risingedge = ((hsync_q ^ hsync) & hsync);
assign vsync_risingedge = ((vsync_q ^ vsync) & vsync);
assign de_risingedge = ((de_q ^ de) & de);
assign de_fallingedge = ((de_q ^ de) & de_q);
always @(posedge clk) begin
if (~rst_n) begin	
	resX <= 0;
	resY <= 0;		
	resY_q <= 0;
	resX_q <= 0;	
	resY_t <= 0;	
end else begin
	vsync_q <= vsync;
	hsync_q <= hsync;
	de_q <= de;
	if (de) begin
		resX_q <= resX_q +1;
	end else if (hsync_risingedge) begin
		resX_q <= 0;
		if (resX_q != 0) begin
			resX <= resX_q;	
		end
	end
	if (de_risingedge) begin
		resY_q <= resY_q + 1;
	end else if (de_fallingedge) begin
		resY_t <= resY_q;
	end else if (vsync_risingedge) begin
		resY_q <= 0;
		if (resY_q != 0) begin
			resY <= resY_t;
		end
	end 
end
end
endmodule
