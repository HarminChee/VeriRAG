`define		SEC_DATA_LEN		192
`define		NS_DATA_LEN			96
`define		TIME_ZONE_LEN		8
`define		LEAP_CNT_LEN		16
`define		LEAP_DST_LEN		64
`define		LEAP_DCT_LEN		8
`define		TIME_QLT_LEN		8
`define		SEC_DATA_LEN		192
`define		NS_DATA_LEN			96
`define		TIME_ZONE_LEN		8
`define		LEAP_CNT_LEN		16
`define		LEAP_DST_LEN		64
`define		LEAP_DCT_LEN		8
`define		TIME_QLT_LEN		8
module tai_utc_timer_reg
(
	input									clk,
	input									rst_n,
	input									io_update,
	input		[`SEC_DATA_LEN		: 0]	sec_cnt_reg_in,
	input		[`NS_DATA_LEN		: 0]	ns_cnt_reg_in,
	input		[`TIME_ZONE_LEN		: 0]	time_zone_reg_in,
	input		[`LEAP_CNT_LEN		: 0]	leap_cnt_reg_in,
	input		[`LEAP_DST_LEN		: 0]	leap_occur_reg_in,
	input		[`LEAP_DCT_LEN		: 0]	leap_direct_reg_in,
	input		[`LEAP_DST_LEN		: 0]	dst_ingress_reg_in,
	input		[`LEAP_DST_LEN		: 0]	dst_engress_reg_in,
	input		[`TIME_QLT_LEN		: 0]	time_quality_reg_in,
	output		[`SEC_DATA_LEN	- 1 : 0]	sec_cnt_reg_out,
	output		[`NS_DATA_LEN	- 1 : 0]	ns_cnt_reg_out,
	output		[`TIME_ZONE_LEN	- 1 : 0]	time_zone_reg_out,
	output		[`LEAP_CNT_LEN	- 1 : 0]	leap_cnt_reg_out,
	output		[`LEAP_DST_LEN	- 1 : 0]	leap_occur_reg_out,
	output		[`LEAP_DCT_LEN	- 1 : 0]	leap_direct_reg_out,
	output		[`LEAP_DST_LEN	- 1 : 0]	dst_ingress_reg_out,
	output		[`LEAP_DST_LEN	- 1 : 0]	dst_engress_reg_out,
	output		[`TIME_QLT_LEN	- 1 : 0]	time_quality_reg_out
);
reg			[`SEC_DATA_LEN	- 1 : 0]	sec_cnt_reg_hold;
reg			[`NS_DATA_LEN	- 1 : 0]	ns_cnt_reg_hold;
reg			[`TIME_ZONE_LEN	- 1 : 0]	time_zone_reg_hold;
reg			[`LEAP_CNT_LEN	- 1 : 0]	leap_cnt_reg_hold;
reg			[`LEAP_DST_LEN	- 1 : 0]	leap_occur_reg_hold;
reg			[`LEAP_DCT_LEN	- 1 : 0]	leap_direct_reg_hold;
reg			[`LEAP_DST_LEN	- 1 : 0]	dst_ingress_reg_hold;
reg			[`LEAP_DST_LEN	- 1 : 0]	dst_engress_reg_hold;
reg			[`TIME_QLT_LEN	- 1 : 0]	time_quality_reg_hold;
reg			[1					: 0]	io_update_edge_catch;
assign	sec_cnt_reg_out			= sec_cnt_reg_hold;
assign	ns_cnt_reg_out			= ns_cnt_reg_hold;
assign	time_zone_reg_out		= time_zone_reg_hold;
assign	leap_cnt_reg_out		= leap_cnt_reg_hold;
assign	leap_occur_reg_out		= leap_occur_reg_hold;
assign	leap_direct_reg_out 	= leap_direct_reg_hold;
assign	dst_ingress_reg_out 	= dst_ingress_reg_hold;
assign	dst_engress_reg_out		= dst_engress_reg_hold;
assign	time_quality_reg_out	= time_quality_reg_hold;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		io_update_edge_catch <= 2'b11;
	end
	else begin
		io_update_edge_catch[1]	<= io_update_edge_catch[0];
		io_update_edge_catch[0]	<= io_update;
	end
end
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		sec_cnt_reg_hold		<= 0;
		ns_cnt_reg_hold			<= 0;
		time_zone_reg_hold		<= 0;
		leap_cnt_reg_hold		<= 0;
		leap_occur_reg_hold		<= 0;
		leap_direct_reg_hold	<= 0;
		dst_ingress_reg_hold	<= 0;
		dst_engress_reg_hold	<= 0;
		time_quality_reg_hold	<= 0;
	end
	else begin
		if (io_update_edge_catch == 2'b01) begin
			if (sec_cnt_reg_in[`SEC_DATA_LEN]) begin
				sec_cnt_reg_hold		<= sec_cnt_reg_in		[`SEC_DATA_LEN	- 1 : 0];
			end
			if (ns_cnt_reg_in[`NS_DATA_LEN]) begin
				ns_cnt_reg_hold			<= ns_cnt_reg_in		[`NS_DATA_LEN	- 1 : 0];
			end
			if (time_zone_reg_in[`TIME_ZONE_LEN]) begin
				time_zone_reg_hold		<= time_zone_reg_in		[`TIME_ZONE_LEN	- 1 : 0];
			end
			if (leap_cnt_reg_in[`LEAP_CNT_LEN]) begin
				leap_cnt_reg_hold		<= leap_cnt_reg_in		[`LEAP_CNT_LEN	- 1 : 0];
			end
			if (leap_occur_reg_in[`LEAP_DST_LEN]) begin
				leap_occur_reg_hold		<= leap_occur_reg_in	[`LEAP_DST_LEN	- 1 : 0];
			end
			if (leap_direct_reg_in[`LEAP_DCT_LEN]) begin
				leap_direct_reg_hold	<= leap_direct_reg_in	[`LEAP_DCT_LEN	- 1 : 0];
			end
			if (dst_ingress_reg_in[`LEAP_DST_LEN]) begin
				dst_ingress_reg_hold	<= dst_ingress_reg_in	[`LEAP_DST_LEN	- 1 : 0];
			end
			if (dst_engress_reg_in[`LEAP_DST_LEN]) begin
				dst_engress_reg_hold	<= dst_engress_reg_in	[`LEAP_DST_LEN	- 1 : 0];
			end
			if (time_quality_reg_in[`TIME_QLT_LEN]) begin
				time_quality_reg_hold	<= time_quality_reg_in	[`TIME_QLT_LEN	- 1 : 0];
			end
		end
	end
end
`undef		SEC_DATA_LEN
`undef		NS_DATA_LEN
`undef		TIME_ZONE_LEN
`undef		LEAP_CNT_LEN
`undef		LEAP_DST_LEN
`undef		LEAP_DCT_LEN
`undef		TIME_QLT_LEN
endmodule
