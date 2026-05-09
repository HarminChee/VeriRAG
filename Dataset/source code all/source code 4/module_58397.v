module avalon_mapped_timer_reg_buf #(
	parameter	NUMBER_OF_COUNTER	= 3,
	parameter	SECOND_COUNTER_OCTET= 8,
	parameter	NS_COUNTER_OCTET	= 4,
	parameter	CTRL_COUNTER_OCTET	= 1,
	parameter	ERROR_COUNTER_OCTET	= 1,
	parameter	UTC_YEAR_OCTET		= 2,
	parameter	UTC_DAYS_OCTET		= 2,
	parameter	UTC_HOUR_OCTET		= 1,
	parameter	UTC_MINUTE_OCTET	= 1,
	parameter	UTC_SECOND_OCTET	= 1,
	parameter	TIME_ZONE_OCTET		= 1,
	parameter	LEAP_COUNTER_OCTET	= 2,
	parameter	LEAP_DIRECT_OCTET	= 1,
	parameter	TIME_QUALITY_OCTET	= 1
	`define		SEC_DATA_LEN		(NUMBER_OF_COUNTER * SECOND_COUNTER_OCTET * 8)
	`define		NS_DATA_LEN			(NUMBER_OF_COUNTER * NS_COUNTER_OCTET * 8)
	`define		CTRL_CNT_LEN		(NUMBER_OF_COUNTER * CTRL_COUNTER_OCTET * 8)
	`define		ERR_CNT_LEN			(NUMBER_OF_COUNTER * ERROR_COUNTER_OCTET * 8)
	`define		UTC_TIME_LEN		(UTC_YEAR_OCTET * 8 + UTC_DAYS_OCTET * 8 + UTC_HOUR_OCTET * 8 + UTC_MINUTE_OCTET * 8 + UTC_SECOND_OCTET * 8) 
	`define		TIME_ZONE_LEN		(TIME_ZONE_OCTET * 8)
	`define		LEAP_CNT_LEN		(LEAP_COUNTER_OCTET * 8)
	`define		LEAP_OCCR_LEN		(SECOND_COUNTER_OCTET * 8)
	`define		LEAP_DCT_LEN		(LEAP_DIRECT_OCTET * 8)
	`define		DST_INEN_LEN		(SECOND_COUNTER_OCTET * 8)
	`define		TIME_QLT_LEN		(TIME_QUALITY_OCTET * 8)
)(
	input	[4:0]					avs_address,
	input							avs_read_n,
	output	[31:0]					avs_readdata,
	input							avs_write_n,
	input	[31:0]					avs_writedata,
	input							csi_clk,
	input							csi_reset_n,
	input							coe_io_update_in,
	input	[`SEC_DATA_LEN	- 1	:0]	coe_sec_cnt_get_data_in,
	input	[`NS_DATA_LEN	- 1	:0]	coe_ns_cnt_get_data_in,
	input	[`CTRL_CNT_LEN	- 1	:0]	coe_ctrl_cnt_get_in,
	input	[`ERR_CNT_LEN	- 1	:0]	coe_err_cnt_in,
	input	[`UTC_TIME_LEN	- 1	:0]	coe_utc_time_in,
	input	[`TIME_ZONE_LEN	- 1	:0]	coe_time_zone_get_in,
	input	[`LEAP_CNT_LEN	- 1	:0]	coe_leap_cnt_get_in,
	input	[`LEAP_OCCR_LEN	- 1	:0]	coe_leap_occur_get_in,
	input	[`LEAP_DCT_LEN 	- 1	:0]	coe_leap_direct_get_in,
	input	[`DST_INEN_LEN	- 1	:0]	coe_dst_ingress_get_in,
	input	[`DST_INEN_LEN	- 1	:0]	coe_dst_engress_get_in,
	input	[`TIME_QLT_LEN	- 1 :0] coe_time_quality_get_in,
	output	[`SEC_DATA_LEN		:0]	coe_sec_cnt_set_data_out,
	output	[`NS_DATA_LEN		:0]	coe_ns_cnt_set_data_out,
	output	[`CTRL_CNT_LEN		:0]	coe_ctrl_cnt_set_out,
	output	[`TIME_ZONE_LEN		:0]	coe_time_zone_set_out,
	output	[`LEAP_CNT_LEN		:0]	coe_leap_cnt_set_out,
	output	[`LEAP_OCCR_LEN		:0]	coe_leap_occur_set_out,
	output	[`LEAP_DCT_LEN		:0]	coe_leap_direct_set_out,
	output	[`DST_INEN_LEN		:0]	coe_dst_ingress_set_out,
	output	[`DST_INEN_LEN		:0]	coe_dst_engress_set_out,
	output	[`TIME_QLT_LEN		:0] coe_time_quality_set_out
);
wire		[31:0]	read_data_line;
reg			[31:0]	read_data_buf;
reg			[31:0]	read_reg_buf	[31 :0];
reg			[ 4:0]	write_addr_buf;
reg			[32:0]	write_data_buf;
reg			[31:0]	write_reg_buf	[31 :0];
reg			[31:0]	write_refresh;
reg			[ 2:0]	io_update_cnt;
reg					io_update;
reg			[3:0]	io_update_state;
localparam	BASE_ADDR				=	(8'h00);
localparam	SEC_CNT_DATA_BASE		=	(BASE_ADDR);
localparam	NS_CNT_DATA_BASE		=	(SEC_CNT_DATA_BASE + NUMBER_OF_COUNTER * ((SECOND_COUNTER_OCTET / 4) + (|(SECOND_COUNTER_OCTET & 8'b11))));
localparam	CTRL_CNT_BASE			=	(NS_CNT_DATA_BASE + NUMBER_OF_COUNTER * ((NS_COUNTER_OCTET / 4) + (|(NS_COUNTER_OCTET & 8'b11))));
localparam	ERR_CNT_BASE			=	(CTRL_CNT_BASE + NUMBER_OF_COUNTER * ((CTRL_COUNTER_OCTET / 4) + (|(CTRL_COUNTER_OCTET & 8'b11))));
localparam	UTC_TIME_BASE			=	(ERR_CNT_BASE + NUMBER_OF_COUNTER * ((ERROR_COUNTER_OCTET / 4) + (|(ERROR_COUNTER_OCTET & 8'b11))));
localparam	TIME_ZONE_BASE			=	(UTC_TIME_BASE + 5);
localparam	LEAP_CNT_BASE			=	(TIME_ZONE_BASE + (`TIME_ZONE_LEN / 32) + (|((`TIME_ZONE_LEN / 8) & 8'b11)));
localparam	LEAP_OCCUR_BASE			=	(LEAP_CNT_BASE + (`LEAP_CNT_LEN / 32) + (|((`LEAP_CNT_LEN / 8) & 8'b11)));
localparam	LEAP_DCT_BASE			=	(LEAP_OCCUR_BASE + (`LEAP_OCCR_LEN / 32) + (|((`LEAP_OCCR_LEN / 8) & 8'b11)));
localparam	DST_INGRESS_BASE		=	(LEAP_DCT_BASE + (`LEAP_DCT_LEN / 32) + (|((`LEAP_DCT_LEN / 8) & 8'b11)));
localparam	DST_ENGRESS_BASE		=	(DST_INGRESS_BASE + (`DST_INEN_LEN / 32) + (|((`DST_INEN_LEN / 8) & 8'b11)));
localparam	TIME_QUALITY_BASE		=	(DST_ENGRESS_BASE + (`DST_INEN_LEN / 32) + (|((`DST_INEN_LEN / 8) & 8'b11)));
localparam	ADDR_UPPER_LIMIT		=	(TIME_QUALITY_BASE + (`TIME_QLT_LEN / 32) + (|((`TIME_QLT_LEN / 8) & 8'b11)));
localparam	SEC_CNT_DATA_BUSUNIT	=	((SECOND_COUNTER_OCTET / 4) + (|(SECOND_COUNTER_OCTET & 8'b11)));
localparam	NS_CNT_DATA_BUSUNIT		=	((NS_COUNTER_OCTET / 4) + (|(NS_COUNTER_OCTET & 8'b11)));
localparam	CTRL_CNT_BUSUNIT		=	((CTRL_COUNTER_OCTET / 4) + (|(CTRL_COUNTER_OCTET & 8'b11)));
localparam	ERR_CNT_BUSUNIT			=	((ERROR_COUNTER_OCTET / 4) + (|(ERROR_COUNTER_OCTET & 8'b11)));
localparam	UTC_TIME_BUSUNIT		=	(((UTC_YEAR_OCTET + UTC_DAYS_OCTET + UTC_HOUR_OCTET + UTC_MINUTE_OCTET + UTC_SECOND_OCTET) / 4) + 
										(|((UTC_YEAR_OCTET + UTC_DAYS_OCTET + UTC_HOUR_OCTET + UTC_MINUTE_OCTET + UTC_SECOND_OCTET) & 8'b11)));
localparam	TIME_ZONE_BUSUNIT		=	((TIME_ZONE_OCTET / 4) + (|(TIME_ZONE_OCTET & 8'b11)));
localparam	LEAP_CNT_BUSUNIT		=	((LEAP_COUNTER_OCTET / 4) + (|(LEAP_COUNTER_OCTET & 8'b11)));
localparam	LEAP_OCCUR_BUSUNIT		=	((SECOND_COUNTER_OCTET / 4) + (|(SECOND_COUNTER_OCTET & 8'b11)));
localparam	DST_INGRESS_BUSUNIT		=	((SECOND_COUNTER_OCTET / 4) + (|(SECOND_COUNTER_OCTET & 8'b11)));
localparam	DST_ENGRESS_BUSUNIT		=	((SECOND_COUNTER_OCTET / 4) + (|(SECOND_COUNTER_OCTET & 8'b11)));
localparam	TIME_QUALITY_BUSUNIT	=	((TIME_QUALITY_OCTET / 4) + (|(TIME_QUALITY_OCTET & 8'b11)));
localparam	WRITE_NEW_DATA_YES		=	(1'b1);
localparam	WRITE_NEW_DATA_NO		=	(1'b0);
localparam	IO_UD_IDLE				=	(4'b0001);
localparam	IO_UD_DELAY				=	(4'b0010);
localparam	IO_UD_TRIG				=	(4'b0100);
localparam	IO_UD_CLEAN				=	(4'b1000);
assign	coe_sec_cnt_set_data_out[32 * 0 +: 32] = write_reg_buf[SEC_CNT_DATA_BASE	+ 0];
assign	coe_sec_cnt_set_data_out[32 * 1 +: 32] = write_reg_buf[SEC_CNT_DATA_BASE	+ 1];
assign	coe_sec_cnt_set_data_out[32 * 2 +: 32] = write_reg_buf[SEC_CNT_DATA_BASE	+ 2];
assign	coe_sec_cnt_set_data_out[32 * 3 +: 32] = write_reg_buf[SEC_CNT_DATA_BASE	+ 3];
assign	coe_sec_cnt_set_data_out[32 * 4 +: 32] = write_reg_buf[SEC_CNT_DATA_BASE	+ 4];
assign	coe_sec_cnt_set_data_out[32 * 5 +: 32] = write_reg_buf[SEC_CNT_DATA_BASE	+ 5];
assign	coe_sec_cnt_set_data_out[32 * 6      ] =|write_refresh[SEC_CNT_DATA_BASE    +:6];
assign	coe_ns_cnt_set_data_out	[32 * 0 +: 32] = write_reg_buf[NS_CNT_DATA_BASE		+ 0];
assign	coe_ns_cnt_set_data_out	[32 * 1 +: 32] = write_reg_buf[NS_CNT_DATA_BASE		+ 1];
assign	coe_ns_cnt_set_data_out	[32 * 2 +: 32] = write_reg_buf[NS_CNT_DATA_BASE		+ 2];
assign	coe_ns_cnt_set_data_out	[32 * 3      ] =|write_refresh[NS_CNT_DATA_BASE		+:3];
assign	coe_ctrl_cnt_set_out	[ 8 * 0 +:  8] = write_reg_buf[CTRL_CNT_BASE		+ 0];
assign	coe_ctrl_cnt_set_out	[ 8 * 1 +:  8] = write_reg_buf[CTRL_CNT_BASE		+ 1];
assign	coe_ctrl_cnt_set_out	[ 8 * 2 +:  8] = write_reg_buf[CTRL_CNT_BASE		+ 2];
assign	coe_ctrl_cnt_set_out	[ 8 * 3      ] =|write_refresh[CTRL_CNT_BASE		+:3]; 
assign	coe_time_zone_set_out	[ 8 * 0 +:  8] = write_reg_buf[TIME_ZONE_BASE		+ 0];
assign	coe_time_zone_set_out	[ 8 * 1      ] =|write_refresh[TIME_ZONE_BASE		+:1];
assign	coe_leap_cnt_set_out	[16 * 0 +: 16] = write_reg_buf[LEAP_CNT_BASE		+ 0];
assign	coe_leap_cnt_set_out	[16 * 1      ] =|write_refresh[LEAP_CNT_BASE		+:1];
assign	coe_leap_occur_set_out	[32 * 0 +: 32] = write_reg_buf[LEAP_OCCUR_BASE		+ 0];
assign	coe_leap_occur_set_out	[32 * 1 +: 32] = write_reg_buf[LEAP_OCCUR_BASE		+ 1];
assign	coe_leap_occur_set_out	[32 * 2      ] =|write_refresh[LEAP_OCCUR_BASE		+:2];
assign	coe_leap_direct_set_out	[ 8 * 0 +:  8] = write_reg_buf[LEAP_DCT_BASE		+ 0];
assign	coe_leap_direct_set_out	[ 8 * 1      ] =|write_refresh[LEAP_DCT_BASE		+:1];
assign	coe_dst_ingress_set_out	[32 * 0 +: 32] = write_reg_buf[DST_INGRESS_BASE		+ 0];
assign	coe_dst_ingress_set_out	[32 * 1 +: 32] = write_reg_buf[DST_INGRESS_BASE		+ 1];
assign	coe_dst_ingress_set_out	[32 * 2      ] =|write_refresh[DST_INGRESS_BASE		+:2];
assign	coe_dst_engress_set_out	[32 * 0 +: 32] = write_reg_buf[DST_ENGRESS_BASE		+ 0];
assign	coe_dst_engress_set_out	[32 * 1 +: 32] = write_reg_buf[DST_ENGRESS_BASE		+ 1];
assign	coe_dst_engress_set_out	[32 * 2      ] =|write_refresh[DST_ENGRESS_BASE		+:2];
assign	coe_time_quality_set_out[ 8 * 0 +:  8] = write_reg_buf[TIME_QUALITY_BASE	+ 0];
assign	coe_time_quality_set_out[ 8 * 1		 ] =|write_refresh[TIME_QUALITY_BASE	+:1];
always @ (posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n) begin
		read_reg_buf[SEC_CNT_DATA_BASE	+ 0] <= 32'b0;
		read_reg_buf[SEC_CNT_DATA_BASE	+ 1] <= 32'b0;
		read_reg_buf[SEC_CNT_DATA_BASE	+ 2] <= 32'b0;
		read_reg_buf[SEC_CNT_DATA_BASE	+ 3] <= 32'b0;
		read_reg_buf[SEC_CNT_DATA_BASE	+ 4] <= 32'b0;
		read_reg_buf[SEC_CNT_DATA_BASE	+ 5] <= 32'b0;
		read_reg_buf[NS_CNT_DATA_BASE	+ 0] <= 32'b0;
		read_reg_buf[NS_CNT_DATA_BASE	+ 1] <= 32'b0;
		read_reg_buf[NS_CNT_DATA_BASE	+ 2] <= 32'b0;
		read_reg_buf[CTRL_CNT_BASE		+ 0] <= 32'b0;
		read_reg_buf[CTRL_CNT_BASE		+ 1] <= 32'b0;
		read_reg_buf[CTRL_CNT_BASE		+ 2] <= 32'b0;
		read_reg_buf[ERR_CNT_BASE		+ 0] <= 32'b0;
		read_reg_buf[ERR_CNT_BASE		+ 1] <= 32'b0;
		read_reg_buf[ERR_CNT_BASE		+ 2] <= 32'b0;
		read_reg_buf[UTC_TIME_BASE		+ 0] <= 32'b0;
		read_reg_buf[UTC_TIME_BASE		+ 1] <= 32'b0;
		read_reg_buf[UTC_TIME_BASE		+ 2] <= 32'b0;
		read_reg_buf[UTC_TIME_BASE		+ 3] <= 32'b0;
		read_reg_buf[UTC_TIME_BASE		+ 4] <= 32'b0;
		read_reg_buf[TIME_ZONE_BASE		+ 0] <= 32'b0;
		read_reg_buf[LEAP_CNT_BASE		+ 0] <= 32'b0;
		read_reg_buf[LEAP_OCCUR_BASE	+ 0] <= 32'b0;
		read_reg_buf[LEAP_OCCUR_BASE	+ 1] <= 32'b0;
		read_reg_buf[LEAP_DCT_BASE		+ 0] <= 32'b0;
		read_reg_buf[DST_INGRESS_BASE	+ 0] <= 32'b0;
		read_reg_buf[DST_INGRESS_BASE	+ 1] <= 32'b0;
		read_reg_buf[DST_ENGRESS_BASE	+ 0] <= 32'b0;
		read_reg_buf[DST_ENGRESS_BASE	+ 1] <= 32'b0;
		read_reg_buf[TIME_QUALITY_BASE	+ 0] <= 32'b0;
	end
	else if (avs_read_n) begin
		read_reg_buf[SEC_CNT_DATA_BASE	+ 0] <= coe_sec_cnt_get_data_in	[32 * 0 +: 32];
		read_reg_buf[SEC_CNT_DATA_BASE	+ 1] <= coe_sec_cnt_get_data_in	[32 * 1 +: 32];
		read_reg_buf[SEC_CNT_DATA_BASE	+ 2] <= coe_sec_cnt_get_data_in	[32 * 2 +: 32];
		read_reg_buf[SEC_CNT_DATA_BASE	+ 3] <= coe_sec_cnt_get_data_in	[32 * 3 +: 32];
		read_reg_buf[SEC_CNT_DATA_BASE	+ 4] <= coe_sec_cnt_get_data_in	[32 * 4 +: 32];
		read_reg_buf[SEC_CNT_DATA_BASE	+ 5] <= coe_sec_cnt_get_data_in	[32 * 5 +: 32];
		read_reg_buf[NS_CNT_DATA_BASE	+ 0] <= coe_ns_cnt_get_data_in	[32 * 0 +: 32];
		read_reg_buf[NS_CNT_DATA_BASE	+ 1] <= coe_ns_cnt_get_data_in	[32 * 1 +: 32];
		read_reg_buf[NS_CNT_DATA_BASE	+ 2] <= coe_ns_cnt_get_data_in	[32 * 2 +: 32];
		read_reg_buf[CTRL_CNT_BASE		+ 0] <= coe_ctrl_cnt_get_in		[ 8 * 0 +:  8];
		read_reg_buf[CTRL_CNT_BASE		+ 1] <= coe_ctrl_cnt_get_in		[ 8 * 1 +:  8];
		read_reg_buf[CTRL_CNT_BASE		+ 2] <= coe_ctrl_cnt_get_in		[ 8 * 2 +:  8];
		read_reg_buf[ERR_CNT_BASE		+ 0] <= coe_err_cnt_in			[ 8 * 0 +:  8];
		read_reg_buf[ERR_CNT_BASE		+ 1] <= coe_err_cnt_in			[ 8 * 1 +:  8];
		read_reg_buf[ERR_CNT_BASE		+ 2] <= coe_err_cnt_in			[ 8 * 2 +:  8];
		read_reg_buf[UTC_TIME_BASE		+ 0] <= coe_utc_time_in			[ 8 * 0 +: 16];
		read_reg_buf[UTC_TIME_BASE		+ 1] <= coe_utc_time_in			[ 8 * 2 +: 16];
		read_reg_buf[UTC_TIME_BASE		+ 2] <= coe_utc_time_in			[ 8 * 4 +:  8];
		read_reg_buf[UTC_TIME_BASE		+ 3] <= coe_utc_time_in			[ 8 * 5 +:  8];
		read_reg_buf[UTC_TIME_BASE		+ 4] <= coe_utc_time_in			[ 8 * 6 +:  8];
		read_reg_buf[TIME_ZONE_BASE		+ 0] <= coe_time_zone_get_in	[ 8 * 0 +:  8];
		read_reg_buf[LEAP_CNT_BASE		+ 0] <= coe_leap_cnt_get_in		[16 * 0 +: 16];
		read_reg_buf[LEAP_OCCUR_BASE	+ 0] <= coe_leap_occur_get_in	[32 * 0 +: 32];
		read_reg_buf[LEAP_OCCUR_BASE	+ 1] <= coe_leap_occur_get_in	[32 * 1 +: 32];
		read_reg_buf[LEAP_DCT_BASE		+ 0] <= coe_leap_direct_get_in	[ 8 * 0 +:  8];
		read_reg_buf[DST_INGRESS_BASE	+ 0] <= coe_dst_ingress_get_in	[32 * 0 +: 32];
		read_reg_buf[DST_INGRESS_BASE	+ 1] <= coe_dst_ingress_get_in	[32 * 1 +: 32];
		read_reg_buf[DST_ENGRESS_BASE	+ 0] <= coe_dst_engress_get_in	[32 * 0 +: 32];
		read_reg_buf[DST_ENGRESS_BASE	+ 1] <= coe_dst_engress_get_in	[32 * 1 +: 32];
		read_reg_buf[TIME_QUALITY_BASE	+ 0] <= coe_time_quality_get_in	[ 8 * 0 +:  8];
	end
end
assign	avs_readdata = read_data_buf;
always @ (posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n) begin
		read_data_buf <= 32'b0;
	end
	else if (!avs_read_n) begin
		read_data_buf <= read_reg_buf[avs_address];
	end
	else begin
		read_data_buf <= read_data_buf;
	end
end
always @ (posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n) begin
		write_addr_buf <= 8'b0;
		write_data_buf <= 33'b0;
	end
	else begin
		write_addr_buf <= avs_address;
		write_data_buf[31:0] <= avs_writedata;
		if (avs_write_n == 0) begin
			write_data_buf[32] <= 1'b1;
		end
		else begin
			write_data_buf[32] <= 1'b0;
		end
	end
end
always @ (posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n) begin
 		write_reg_buf[SEC_CNT_DATA_BASE	+ 0] <= 32'b0;
		write_reg_buf[SEC_CNT_DATA_BASE	+ 1] <= 32'b0;
		write_reg_buf[SEC_CNT_DATA_BASE	+ 2] <= 32'b0;
		write_reg_buf[SEC_CNT_DATA_BASE	+ 3] <= 32'b0;
		write_reg_buf[SEC_CNT_DATA_BASE	+ 4] <= 32'b0;
		write_reg_buf[SEC_CNT_DATA_BASE	+ 5] <= 32'b0;
		write_reg_buf[NS_CNT_DATA_BASE	+ 0] <= 32'b0;
		write_reg_buf[NS_CNT_DATA_BASE	+ 1] <= 32'b0;
		write_reg_buf[NS_CNT_DATA_BASE	+ 2] <= 32'b0;
		write_reg_buf[CTRL_CNT_BASE		+ 0] <= 32'b0;
		write_reg_buf[CTRL_CNT_BASE		+ 1] <= 32'b0;
		write_reg_buf[CTRL_CNT_BASE		+ 2] <= 32'b0;
		write_reg_buf[TIME_ZONE_BASE	+ 0] <= 32'b0;
		write_reg_buf[LEAP_CNT_BASE		+ 0] <= 32'b0;
		write_reg_buf[LEAP_OCCUR_BASE	+ 0] <= 32'b0;
		write_reg_buf[LEAP_OCCUR_BASE	+ 1] <= 32'b0;
		write_reg_buf[LEAP_DCT_BASE		+ 0] <= 32'b0;
		write_reg_buf[DST_INGRESS_BASE	+ 0] <= 32'b0;
		write_reg_buf[DST_INGRESS_BASE	+ 1] <= 32'b0;
		write_reg_buf[DST_ENGRESS_BASE	+ 0] <= 32'b0;
		write_reg_buf[DST_ENGRESS_BASE	+ 1] <= 32'b0; 
		write_reg_buf[TIME_QUALITY_BASE	+ 0] <= 32'b0;
	end
	else begin
		if (write_data_buf[32] == WRITE_NEW_DATA_YES) begin
			write_reg_buf[write_addr_buf] <= write_data_buf[31:0];
		end
	end
end
always @ (posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n) begin
		write_refresh <= 32'b0;
	end
	else if (io_update) begin
		write_refresh <= 32'b0;
	end
	else if ((write_data_buf[32] == WRITE_NEW_DATA_NO)) begin
		write_refresh <= write_refresh;
	end
	else begin
		write_refresh[write_addr_buf] <= 1'b1;
	end
end
always @ (posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n) begin
		io_update_state	<= IO_UD_IDLE;
		io_update_cnt	<= 2'b00;
		io_update		<= 1'b0;
	end
	else begin
		case (io_update_state)
			IO_UD_IDLE	: begin
				io_update <= 1'b0;
				io_update_cnt <= 2'b00;
				if (coe_io_update_in) begin
					io_update_state <= IO_UD_DELAY;
				end
				else begin
					io_update_state <= IO_UD_IDLE;
				end
			end
			IO_UD_DELAY	: begin
				if (io_update_cnt == 2'b11) begin
					io_update_state <= IO_UD_TRIG;
				end
				else if (!coe_io_update_in) begin
					io_update_state <= IO_UD_IDLE;
				end
				io_update_cnt <= io_update_cnt + 1'b1;
			end
			IO_UD_TRIG	: begin
				io_update <= 1'b1;
				io_update_state <= IO_UD_CLEAN;
			end
			IO_UD_CLEAN	: begin
				io_update <= 1'b0;
				if (!coe_io_update_in) begin
					io_update_state <= IO_UD_IDLE;
				end
			end
			default		: begin
				io_update_state <= IO_UD_IDLE;
			end
		endcase
	end
end
`undef		SEC_DATA_LEN
`undef		NS_DATA_LEN
`undef		CTRL_CNT_LEN
`undef		ERR_CNT_LEN
`undef		UTC_TIME_LEN
`undef		TIME_ZONE_LEN
`undef		LEAP_CNT_LEN
`undef		LEAP_OCCR_LEN
`undef		LEAP_DCT_LEN
`undef		DST_INEN_LEN
`undef		TIME_QLT_LEN
endmodule
