`define fpga_clk_out5_reg 16'h0EFF
`define fpga_clk_out4_reg 16'h07FF
`define fpga_clk_out5_reg 16'h0EFF
`define fpga_clk_out4_reg 16'h07FF
module clock_board_config (
	sys_clk,
	sys_rst,
	cfg_radio_dat_out,
	cfg_radio_csb_out,
	cfg_radio_en_out,
	cfg_radio_clk_out,
	cfg_logic_dat_out,
	cfg_logic_csb_out,
	cfg_logic_en_out,
	cfg_logic_clk_out,
	config_invalid
);
parameter sys_clk_freq_hz = 120000000;
parameter fpga_radio_clk_source = 16'h1Aff;
parameter fpga_logic_clk_source = 16'h1Aff;
parameter radio_clk_out0_mode = 16'h01ff; 
parameter radio_clk_out1_mode = 16'h1eff; 
parameter radio_clk_out2_mode = 16'h1eff; 
parameter radio_clk_out3_mode = 16'h01ff; 
parameter logic_clk_out0_mode = 16'h02ff; 
parameter logic_clk_out1_mode = 16'h08ff; 
parameter logic_clk_out2_mode = 16'h08ff; 
parameter logic_clk_out3_mode = 16'h02ff; 
input  sys_clk;
input  sys_rst;
output cfg_radio_dat_out; reg cfg_radio_dat_out = 1'b1;
output cfg_radio_csb_out; reg cfg_radio_csb_out = 1'b1;
output cfg_radio_en_out;  reg cfg_radio_en_out  = 1'b1;
output cfg_radio_clk_out; reg cfg_radio_clk_out = 1'b1;
output cfg_logic_dat_out; reg cfg_logic_dat_out = 1'b1;
output cfg_logic_csb_out; reg cfg_logic_csb_out = 1'b1;
output cfg_logic_en_out;  reg cfg_logic_en_out  = 1'b1;
output cfg_logic_clk_out; reg cfg_logic_clk_out = 1'b1;
output config_invalid;
parameter scp_min_freq_hz = 2500000;
parameter scp_cyc_leng_a = ((sys_clk_freq_hz + scp_min_freq_hz - 1) / scp_min_freq_hz);
parameter scp_cyc_leng_b = (scp_cyc_leng_a < 2) ? 2 : scp_cyc_leng_a;
parameter scp_cyc_leng   = scp_cyc_leng_b;
reg [3:0] scp_cnt_en     = 4'b0000;     
reg [7:0] scp_cnt        = 8'b00000000; 
reg       scp_cnt_tc     = 1'b0;        
reg       scp_cyc_start  = 1'b0;        
reg       scp_cyc_mid    = 1'b0;        
always @ (posedge sys_clk)
begin
	scp_cnt_en [3:0] <= {1'b1,scp_cnt_en [3:1]};
	if (~scp_cnt_en [0])
	begin
		scp_cnt       [7:0] <= 8'b00000000;
		scp_cnt_tc          <= 1'b0;
		scp_cyc_start       <= 1'b0;
		scp_cyc_mid         <= 1'b0;
	end
	else
	begin
		if   (~scp_cnt_tc) scp_cnt [7:0] <= scp_cnt [7:0] + 1;
		else               scp_cnt [7:0] <= 8'b00000000;
		scp_cnt_tc     <= (scp_cnt [7:0] == ((scp_cyc_leng + 0) - 2));
		scp_cyc_start  <= (scp_cnt [7:0] ==                       0 );
		scp_cyc_mid    <= (scp_cnt [7:0] == ((scp_cyc_leng + 1) / 2));
	end
end
reg [3:0] sys_rst_lock = 4'b1111;
reg [2:0] sys_rst_sync = 3'b111;
always @ (posedge sys_clk or posedge sys_rst)
begin
	if   (sys_rst) sys_rst_lock [3] <= 1'b1;
	else           sys_rst_lock [3] <= 1'b0;
end
always @ (posedge sys_clk or posedge sys_rst_lock [3])
begin
	if   (sys_rst_lock [3]) sys_rst_lock [2:0] <= 3'b111;
	else                    sys_rst_lock [2:0] <= {1'b0,sys_rst_lock [2:1]};
end
always @ (posedge sys_clk)
begin
	sys_rst_sync [2:0] <= {sys_rst_lock [0],sys_rst_sync [2:1]};
end
reg [9:0] cfg_cyc      = 10'b0000000000;
reg       cfg_cyc_done =  1'b1;
reg       cfg_restart  =  1'b0;
reg       cfg_clk_low  =  1'b0;
reg       cfg_clk_high =  1'b0;
reg		  cfg_cyc_done_d1 = 1'b1;
always @ (posedge sys_clk)
begin
	cfg_cyc_done_d1 <= cfg_cyc_done;
end
always @ (posedge sys_clk)
begin
	if (~scp_cyc_mid)
	begin
		cfg_cyc      [9:0] <= cfg_cyc [9:0];
		cfg_cyc_done       <= cfg_cyc_done;
	end
	else
	begin
		if (cfg_cyc_done)
		begin
			cfg_cyc      [9:0] <= 10'b0000000000;
			cfg_cyc_done       <= ~cfg_restart;
		end
		else
		begin
			cfg_cyc      [9:0] <= cfg_cyc [9:0] + 1;
			cfg_cyc_done       <= (cfg_cyc [9:0] == 10'b1111111111);
		end
	end
   cfg_restart  <= ~cfg_restart & cfg_cyc_done & (sys_rst_sync [1:0] == 2'b01)
                 |  cfg_restart & cfg_cyc_done & ~scp_cyc_mid;
   cfg_clk_low  <= ~cfg_cyc_done & scp_cyc_start;
   cfg_clk_high <= ~cfg_cyc_done & scp_cyc_mid;
end
wire        srl_shift;
wire [63:0] srl_radio_d;
wire [63:0] srl_radio_q;
wire [63:0] srl_logic_d;
wire [63:0] srl_logic_q;
assign srl_shift          = cfg_clk_low;
assign srl_radio_d [63:0] = {srl_radio_q [0],srl_radio_q [63:1]};
assign srl_logic_d [63:0] = {srl_logic_q [0],srl_logic_q [63:1]};
reg    config_invalid = 1'b1;
always @(posedge sys_clk)
begin
	if(cfg_cyc_done & ~cfg_cyc_done_d1)
		config_invalid <= 1'b0;
	else if(cfg_restart)
		config_invalid <= 1'b1;
end
genvar ii;
generate
	for (ii = 0 ; ii < 64 ; ii = ii + 1)
	begin : gen_srls
		SRL16E srl_radio (
			.Q   (srl_radio_q [ii]),
			.A0  (1'b1            ),
			.A1  (1'b1            ),
			.A2  (1'b1            ),
			.A3  (1'b1            ),
			.CE  (srl_shift       ),
			.CLK (sys_clk         ),
			.D   (srl_radio_d [ii])
		);
		SRL16E srl_logic (
			.Q   (srl_logic_q [ii]),
			.A0  (1'b1            ),
			.A1  (1'b1            ),
			.A2  (1'b1            ),
			.A3  (1'b1            ),
			.CE  (srl_shift       ),
			.CLK (sys_clk         ),
			.D   (srl_logic_d [ii])
		);
	end
endgenerate
defparam gen_srls[ 0].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[ 1].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[ 2].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[ 3].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[ 4].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[ 5].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[ 6].srl_radio.INIT = 16'h0000; 
defparam gen_srls[ 7].srl_radio.INIT = 16'h30FF; 
defparam gen_srls[ 8].srl_radio.INIT = 16'h0000; 
defparam gen_srls[ 9].srl_radio.INIT = 16'h10FF; 
defparam gen_srls[10].srl_radio.INIT = 16'h0045;               
defparam gen_srls[11].srl_radio.INIT = fpga_radio_clk_source; 
defparam gen_srls[12].srl_radio.INIT = 16'h0049; 
defparam gen_srls[13].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[14].srl_radio.INIT = 16'h004B; 
defparam gen_srls[15].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[16].srl_radio.INIT = 16'h004D; 
defparam gen_srls[17].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[18].srl_radio.INIT = 16'h004F; 
defparam gen_srls[19].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[20].srl_radio.INIT = 16'h0051; 
defparam gen_srls[21].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[22].srl_radio.INIT = 16'h0053; 
defparam gen_srls[23].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[24].srl_radio.INIT = 16'h0055; 
defparam gen_srls[25].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[26].srl_radio.INIT = 16'h0057; 
defparam gen_srls[27].srl_radio.INIT = 16'h80FF; 
defparam gen_srls[28].srl_radio.INIT = 16'h0040; 
defparam gen_srls[29].srl_radio.INIT = radio_clk_out0_mode; 
defparam gen_srls[30].srl_radio.INIT = 16'h0041; 
defparam gen_srls[31].srl_radio.INIT = radio_clk_out1_mode; 
defparam gen_srls[32].srl_radio.INIT = 16'h0042; 
defparam gen_srls[33].srl_radio.INIT = radio_clk_out2_mode; 
defparam gen_srls[34].srl_radio.INIT = 16'h0043; 
defparam gen_srls[35].srl_radio.INIT = radio_clk_out3_mode; 
defparam gen_srls[36].srl_radio.INIT = 16'h003C; 
defparam gen_srls[37].srl_radio.INIT = 16'h08FF; 
defparam gen_srls[38].srl_radio.INIT = 16'h003D; 
defparam gen_srls[39].srl_radio.INIT = 16'h0BFF; 
defparam gen_srls[40].srl_radio.INIT = 16'h003E; 
defparam gen_srls[41].srl_radio.INIT = 16'h0BFF; 
defparam gen_srls[42].srl_radio.INIT = 16'h003F; 
defparam gen_srls[43].srl_radio.INIT = 16'h0BFF; 
defparam gen_srls[44].srl_radio.INIT = 16'h005A; 
defparam gen_srls[45].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[46].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[47].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[48].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[49].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[50].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[51].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[52].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[53].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[54].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[55].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[56].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[57].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[58].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[59].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[60].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[61].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[62].srl_radio.INIT = 16'hFFFF; 
defparam gen_srls[63].srl_radio.INIT = 16'hFFFF; 
`define RADIO_CSB_LOW_DECODE  ((cfg_cyc ==  96) | (cfg_cyc == 128) | (cfg_cyc == 160) | (cfg_cyc == 192) | (cfg_cyc == 224) | (cfg_cyc == 256) | (cfg_cyc == 288) | (cfg_cyc == 320) | (cfg_cyc == 352) | (cfg_cyc == 384) | (cfg_cyc == 416) | (cfg_cyc == 448) | (cfg_cyc == 480) | (cfg_cyc == 512) | (cfg_cyc == 544) | (cfg_cyc == 576) | (cfg_cyc == 608) | (cfg_cyc == 640) | (cfg_cyc == 672) | (cfg_cyc == 704))
`define RADIO_CSB_HIGH_DECODE ((cfg_cyc == 120) | (cfg_cyc == 152) | (cfg_cyc == 184) | (cfg_cyc == 216) | (cfg_cyc == 248) | (cfg_cyc == 280) | (cfg_cyc == 312) | (cfg_cyc == 344) | (cfg_cyc == 376) | (cfg_cyc == 408) | (cfg_cyc == 440) | (cfg_cyc == 472) | (cfg_cyc == 504) | (cfg_cyc == 536) | (cfg_cyc == 568) | (cfg_cyc == 600) | (cfg_cyc == 632) | (cfg_cyc == 664) | (cfg_cyc == 696) | (cfg_cyc == 728))
`define RADIO_EN_LOW_DECODE   ( cfg_cyc ==   0)
`define RADIO_EN_HIGH_DECODE	( cfg_cyc ==   4)
defparam gen_srls[ 0].srl_logic.INIT = 16'hFFFF; 
defparam gen_srls[ 1].srl_logic.INIT = 16'hFFFF; 
defparam gen_srls[ 2].srl_logic.INIT = 16'hFFFF; 
defparam gen_srls[ 3].srl_logic.INIT = 16'hFFFF; 
defparam gen_srls[ 4].srl_logic.INIT = 16'hFFFF; 
defparam gen_srls[ 5].srl_logic.INIT = 16'hFFFF; 
defparam gen_srls[ 6].srl_logic.INIT = 16'h0000; 
defparam gen_srls[ 7].srl_logic.INIT = 16'h30FF; 
defparam gen_srls[ 8].srl_logic.INIT = 16'h0000; 
defparam gen_srls[ 9].srl_logic.INIT = 16'h10FF; 
defparam gen_srls[10].srl_logic.INIT = 16'h0045;               
defparam gen_srls[11].srl_logic.INIT = fpga_logic_clk_source; 
defparam gen_srls[12].srl_logic.INIT = 16'h0049; 
defparam gen_srls[13].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[14].srl_logic.INIT = 16'h004B; 
defparam gen_srls[15].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[16].srl_logic.INIT = 16'h004D; 
defparam gen_srls[17].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[18].srl_logic.INIT = 16'h004F; 
defparam gen_srls[19].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[20].srl_logic.INIT = 16'h0051; 
defparam gen_srls[21].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[22].srl_logic.INIT = 16'h0053; 
defparam gen_srls[23].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[24].srl_logic.INIT = 16'h0055; 
defparam gen_srls[25].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[26].srl_logic.INIT = 16'h0057; 
defparam gen_srls[27].srl_logic.INIT = 16'h80FF; 
defparam gen_srls[28].srl_logic.INIT = 16'h003C; 
defparam gen_srls[29].srl_logic.INIT = logic_clk_out0_mode; 
defparam gen_srls[30].srl_logic.INIT = 16'h003D; 
defparam gen_srls[31].srl_logic.INIT = logic_clk_out1_mode; 
defparam gen_srls[32].srl_logic.INIT = 16'h003E; 
defparam gen_srls[33].srl_logic.INIT = logic_clk_out2_mode; 
defparam gen_srls[34].srl_logic.INIT = 16'h003F; 
defparam gen_srls[35].srl_logic.INIT = logic_clk_out3_mode; 
defparam gen_srls[36].srl_logic.INIT = 16'h0043; 
defparam gen_srls[37].srl_logic.INIT = 16'h1EFF; 
defparam gen_srls[38].srl_logic.INIT = 16'h0042; 
defparam gen_srls[39].srl_logic.INIT = 16'h1FFF; 
defparam gen_srls[40].srl_logic.INIT = 16'h0041;           
defparam gen_srls[41].srl_logic.INIT = `fpga_clk_out5_reg; 
defparam gen_srls[42].srl_logic.INIT = 16'h0040;           
defparam gen_srls[43].srl_logic.INIT = `fpga_clk_out4_reg; 
defparam gen_srls[44].srl_logic.INIT = 16'h005A; 
defparam gen_srls[45].srl_logic.INIT = 16'hFFFF; 
defparam gen_srls[46].srl_logic.INIT = 16'h0000; 
defparam gen_srls[47].srl_logic.INIT = 16'h0000; 
defparam gen_srls[48].srl_logic.INIT = 16'h0000; 
defparam gen_srls[49].srl_logic.INIT = 16'h0000; 
defparam gen_srls[50].srl_logic.INIT = 16'h0000; 
defparam gen_srls[51].srl_logic.INIT = 16'h0000; 
defparam gen_srls[52].srl_logic.INIT = 16'h0000; 
defparam gen_srls[53].srl_logic.INIT = 16'h0000; 
defparam gen_srls[54].srl_logic.INIT = 16'h0000; 
defparam gen_srls[55].srl_logic.INIT = 16'h0000; 
defparam gen_srls[56].srl_logic.INIT = 16'h0000; 
defparam gen_srls[57].srl_logic.INIT = 16'h0000; 
defparam gen_srls[58].srl_logic.INIT = 16'h0000; 
defparam gen_srls[59].srl_logic.INIT = 16'h0000; 
defparam gen_srls[60].srl_logic.INIT = 16'h0000; 
defparam gen_srls[61].srl_logic.INIT = 16'h0000; 
defparam gen_srls[62].srl_logic.INIT = 16'h0000; 
defparam gen_srls[63].srl_logic.INIT = 16'h0000; 
`define LOGIC_CSB_LOW_DECODE  ((cfg_cyc ==  96) | (cfg_cyc == 128) | (cfg_cyc == 160) | (cfg_cyc == 192) | (cfg_cyc == 224) | (cfg_cyc == 256) | (cfg_cyc == 288) | (cfg_cyc == 320) | (cfg_cyc == 352) | (cfg_cyc == 384) | (cfg_cyc == 416) | (cfg_cyc == 448) | (cfg_cyc == 480) | (cfg_cyc == 512) | (cfg_cyc == 544) | (cfg_cyc == 576) | (cfg_cyc == 608) | (cfg_cyc == 640) | (cfg_cyc == 672) | (cfg_cyc == 704))
`define LOGIC_CSB_HIGH_DECODE ((cfg_cyc == 120) | (cfg_cyc == 152) | (cfg_cyc == 184) | (cfg_cyc == 216) | (cfg_cyc == 248) | (cfg_cyc == 280) | (cfg_cyc == 312) | (cfg_cyc == 344) | (cfg_cyc == 376) | (cfg_cyc == 408) | (cfg_cyc == 440) | (cfg_cyc == 472) | (cfg_cyc == 504) | (cfg_cyc == 536) | (cfg_cyc == 568) | (cfg_cyc == 600) | (cfg_cyc == 632) | (cfg_cyc == 664) | (cfg_cyc == 696) | (cfg_cyc == 728))
`define LOGIC_EN_LOW_DECODE   (cfg_cyc ==  0)
`define LOGIC_EN_HIGH_DECODE  (cfg_cyc ==  4)
reg       cfg_radio_csb_low  = 1'b0;
reg       cfg_radio_csb_high = 1'b0;
reg       cfg_radio_en_low   = 1'b0;
reg       cfg_radio_en_high  = 1'b0;
reg       cfg_logic_csb_low  = 1'b0;
reg       cfg_logic_csb_high = 1'b0;
reg       cfg_logic_en_low   = 1'b0;
reg       cfg_logic_en_high  = 1'b0;
always @ (posedge sys_clk)
begin
	if (~scp_cyc_start)
	begin
		cfg_radio_csb_low   <=  1'b0;
		cfg_radio_csb_high  <=  1'b0;
		cfg_radio_en_low    <=  1'b0;
		cfg_radio_en_high   <=  1'b0;
		cfg_logic_csb_low   <=  1'b0;
		cfg_logic_csb_high  <=  1'b0;
		cfg_logic_en_low    <=  1'b0;
		cfg_logic_en_high   <=  1'b0;
	end
	else
	begin
		if (cfg_cyc_done)
		begin
			cfg_radio_csb_low   <=  1'b0;
			cfg_radio_csb_high  <=  1'b1;
			cfg_radio_en_low    <=  1'b0;
			cfg_radio_en_high   <=  1'b1;
			cfg_logic_csb_low   <=  1'b0;
			cfg_logic_csb_high  <=  1'b1;
			cfg_logic_en_low    <=  1'b0;
			cfg_logic_en_high   <=  1'b1;
		end
		else
		begin
			cfg_radio_csb_low   <= `RADIO_CSB_LOW_DECODE;
			cfg_radio_csb_high  <= `RADIO_CSB_HIGH_DECODE;
			cfg_radio_en_low    <= `RADIO_EN_LOW_DECODE;
			cfg_radio_en_high   <= `RADIO_EN_HIGH_DECODE;
			cfg_logic_csb_low   <= `LOGIC_CSB_LOW_DECODE;
			cfg_logic_csb_high  <= `LOGIC_CSB_HIGH_DECODE;
			cfg_logic_en_low    <= `LOGIC_EN_LOW_DECODE;
			cfg_logic_en_high   <= `LOGIC_EN_HIGH_DECODE;
		end
	end
end
always @ (posedge sys_clk)
begin
	if   (srl_shift) cfg_radio_dat_out <=  srl_radio_q [0];
	else             cfg_radio_dat_out <=  cfg_radio_dat_out; 
	cfg_radio_csb_out <=  cfg_radio_csb_out & ~cfg_radio_csb_low
                      | ~cfg_radio_csb_out &  cfg_radio_csb_high;
	cfg_radio_en_out  <=  cfg_radio_en_out  & ~cfg_radio_en_low
                      | ~cfg_radio_en_out  &  cfg_radio_en_high;
	cfg_radio_clk_out <=  cfg_radio_clk_out & ~cfg_clk_low
                      | ~cfg_radio_clk_out &  cfg_clk_high;
	if   (srl_shift) cfg_logic_dat_out <=  srl_logic_q [0];
	else             cfg_logic_dat_out <=  cfg_logic_dat_out;
	cfg_logic_csb_out <=  cfg_logic_csb_out & ~cfg_logic_csb_low
                      | ~cfg_logic_csb_out &  cfg_logic_csb_high;
	cfg_logic_en_out  <=  cfg_logic_en_out  & ~cfg_logic_en_low
                      | ~cfg_logic_en_out  &  cfg_logic_en_high;
	cfg_logic_clk_out <=  cfg_logic_clk_out & ~cfg_clk_low
                      | ~cfg_logic_clk_out &  cfg_clk_high;
end
endmodule
