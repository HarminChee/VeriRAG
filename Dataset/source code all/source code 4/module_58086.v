module				cog_vid
(
input				clk_cog,
input				clk_vid,
input				ena,
input				setvid,
input				setscl,
input		[31:0]	data,
input		[31:0]	pixel,
input		[31:0]	color,
input		 [7:0]	aural,
input				carrier,
output				ack,
output		[31:0]	pin_out
);
reg [31:0] vid;
reg [31:0] scl;
always @(posedge clk_cog or negedge ena)
if (!ena)
	vid <= 32'b0;
else if (setvid)
	vid <= data;
always @(posedge clk_cog)
if (setscl)
	scl <= data;
reg  [7:0] cnts;
reg  [7:0] cnt;
reg [11:0] set;
reg [31:0] pixels;
reg [31:0] colors;
wire enable			= |vid[30:29];
wire vclk			= clk_vid && enable;
wire new_set		= set == 1'b1;
wire new_cnt		= cnt == 1'b1;
always @(posedge vclk)
if (new_set)
	cnts <= scl[19:12];
always @(posedge vclk)
	cnt <= new_set	? scl[19:12]
		 : new_cnt	? cnts
					: cnt - 1'b1;
always @(posedge vclk)
	set <= new_set	? scl[11:0]
					: set - 1'b1;
always @(posedge vclk)
if (new_set || new_cnt)
	pixels <= new_set	? pixel
			: vid[28]	? {pixels[31:30], pixels[31:2]}
						: {pixels[31], pixels[31:1]};
always @(posedge vclk)
if (new_set)
	colors <= color;
reg cap;
reg [1:0] snc;
always @(posedge vclk or posedge snc[1])
if (snc[1])
	cap <= 1'b0;
else if (new_set)
	cap <= 1'b1;
always @(posedge clk_cog)
if (enable)
	snc <= {snc[0], cap};
assign ack			= snc[0];
reg [7:0] discrete;
wire [31:0] colorx	= colors >> {vid[28] && pixels[1], pixels[0], 3'b000};
always @(posedge vclk)
	discrete <= colorx[7:0];
reg [3:0] phase;
reg [3:0] baseband;
always @(posedge vclk)
	phase <= phase + 1'b1;
wire [3:0] colorphs	= discrete[7:4] + phase;
wire [2:0] colormod	= discrete[2:0] + {	discrete[3] && colorphs[3],
										discrete[3] && colorphs[3],
										discrete[3] };
always @(posedge vclk)
	baseband <= {discrete[3] && colorphs[3], vid[26] ? colormod : discrete[2:0]};
reg [2:0] composite;
always @(posedge vclk)
	composite <= vid[27] ? colormod : discrete[2:0];
wire [15:0][2:0] level	= 48'b011_100_100_101_101_110_110_111_011_011_010_010_001_001_000_000;
wire [3:0] broadcast	= {carrier ^ aural[vid[25:23]], level[{carrier, composite}]};
wire [7:0] outp		= vid[30] ? vid[29] ? {baseband, broadcast}
										: {broadcast, baseband}
										: discrete;
assign pin_out		= enable ? {24'b0, outp & vid[7:0]} << {vid[10:9], 3'b000} : 32'b0;
endmodule
