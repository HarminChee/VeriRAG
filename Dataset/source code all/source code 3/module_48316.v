module vgafb #(
	parameter csr_addr = 4'h0,
	parameter fml_depth = 26
) (
	input sys_clk,
	input sys_rst,
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output [31:0] csr_do,
	output [fml_depth-1:0] fml_adr,
	output fml_stb,
	input fml_ack,
	input [63:0] fml_di,
	output dcb_stb,
	output [fml_depth-1:0] dcb_adr,
	input [63:0] dcb_dat,
	input dcb_hit,
	input vga_clk,
	output vga_psave_n,
	output reg vga_hsync_n,
	output reg vga_vsync_n,
	output vga_sync_n,
	output vga_blank_n,
	output reg [7:0] vga_r,
	output reg [7:0] vga_g,
	output reg [7:0] vga_b,
	inout vga_sda,
	output vga_sdc,
	output [1:0] clksel
);
wire vga_rst;
wire [10:0] hres;
wire [10:0] hsync_start;
wire [10:0] hsync_end;
wire [10:0] hscan;
wire [10:0] vres;
wire [10:0] vsync_start;
wire [10:0] vsync_end;
wire [10:0] vscan;
wire [fml_depth-1:0] baseaddress;
wire baseaddress_ack;
wire [17:0] nbursts;
vgafb_ctlif #(
	.csr_addr(csr_addr),
	.fml_depth(fml_depth)
) ctlif (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_di),
	.csr_do(csr_do),
	.vga_rst(vga_rst),
	.hres(hres),
	.hsync_start(hsync_start),
	.hsync_end(hsync_end),
	.hscan(hscan),
	.vres(vres),
	.vsync_start(vsync_start),
	.vsync_end(vsync_end),
	.vscan(vscan),
	.baseaddress(baseaddress),
	.baseaddress_ack(baseaddress_ack),
	.nbursts(nbursts),
	.vga_sda(vga_sda),
	.vga_sdc(vga_sdc),
	.clksel(clksel)
);
reg hsync_n;
reg vsync_n;
wire pixel_valid;
wire [15:0] pixel_fb;
wire pixel_ack;
wire [15:0] pixel;
wire fifo_full;
reg hactive;
reg vactive;
wire active = hactive & vactive;
assign pixel = active ? pixel_fb : 16'h0000;
wire generate_en;
reg [10:0] hcounter;
reg [10:0] vcounter;
always @(posedge sys_clk) begin
	if(vga_rst) begin
		hcounter <= 10'd0;
		vcounter <= 10'd0;
		hactive <= 1'b0;
		hsync_n <= 1'b1;
		vactive <= 1'b0;
		vsync_n <= 1'b1;
	end else begin
		if(generate_en) begin
			hcounter <= hcounter + 10'd1;
			if(hcounter == 10'd0) hactive <= 1'b1;
			if(hcounter == hres) hactive <= 1'b0;
			if(hcounter == hsync_start) hsync_n <= 1'b0;
			if(hcounter == hsync_end) hsync_n <= 1'b1;
			if(hcounter == hscan) begin
				hcounter <= 10'd0;
				if(vcounter == vscan)
					vcounter <= 10'd0;
				else
					vcounter <= vcounter + 10'd1;
			end
			if(vcounter == 10'd0) vactive <= 1'b1;
			if(vcounter == vres) vactive <= 1'b0;
			if(vcounter == vsync_start) vsync_n <= 1'b0;
			if(vcounter == vsync_end) vsync_n <= 1'b1;
		end
	end
end
assign generate_en = ~fifo_full & (~active | pixel_valid);
assign pixel_ack = ~fifo_full & active & pixel_valid;
vgafb_pixelfeed #(
	.fml_depth(fml_depth)
) pixelfeed (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.vga_rst(vga_rst),
	.nbursts(nbursts),
	.baseaddress(baseaddress),
	.baseaddress_ack(baseaddress_ack),
	.fml_adr(fml_adr),
	.fml_stb(fml_stb),
	.fml_ack(fml_ack),
	.fml_di(fml_di),
	.dcb_stb(dcb_stb),
	.dcb_adr(dcb_adr),
	.dcb_dat(dcb_dat),
	.dcb_hit(dcb_hit),
	.pixel_valid(pixel_valid),
	.pixel(pixel_fb),
	.pixel_ack(pixel_ack)
);
wire [17:0] fifo_do;
asfifo #(
	.data_width(18),
	.address_width(10)
) fifo (
	.data_out(fifo_do),
	.empty(),
	.read_en(1'b1),
	.clk_read(vga_clk),
	.data_in({vsync_n, hsync_n, pixel}),
	.full(fifo_full),
	.write_en(generate_en),
	.clk_write(sys_clk),
	.rst(vga_rst)
);
assign vga_sync_n = 1'b0; 
assign vga_psave_n = 1'b1;
assign vga_blank_n = 1'b1;
always @(posedge vga_clk) begin
	vga_vsync_n <= fifo_do[17];
	vga_hsync_n <= fifo_do[16];
	vga_r <= {fifo_do[15:11], fifo_do[15:13]};
	vga_g <= {fifo_do[10:5], fifo_do[10:9]};
	vga_b <= {fifo_do[4:0], fifo_do[4:2]};
end
endmodule
