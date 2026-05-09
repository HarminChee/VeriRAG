module userio_osd
(
	input 	clk,		    	
	input	clk7_en,
    input clk7n_en,
	input	reset,				
	input	c1,					
	input	c3,
	input	sol,				
	input	sof,				
    input varbeamen,
	input	[7:0] osd_ctrl,		
	input	_scs,				
	input	sdi,		  		
	output	sdo,	 			
	input	sck,	  			
	output	osd_blank,			
	output	osd_pixel,			
	output	reg osd_enable = 0,			
    output  reg key_disable = 0,      
	output	reg [1:0] lr_filter = 0,
	output	reg [1:0] hr_filter = 0,
	output	reg [6:0] memory_config = 7'b0_00_01_01,
	output	reg [4:0] chipset_config = 0,
	output	reg [3:0] floppy_config = 0,
	output	reg [1:0] scanline = 0,
    output  reg [1:0] dither = 0,
	output	reg	[2:0] ide_config = 0,		
    output  reg [3:0] cpu_config = 0,
    output  reg [1:0] autofire_config = 0,
    output  reg       cd32pad = 0,
	output	reg usrrst=1'b0,
    output reg cpurst=1'b1,
    output reg cpuhlt=1'b1,
    output wire fifo_full,
    output reg            host_cs,
    output wire [ 24-1:0] host_adr,
    output reg            host_we,
    output reg  [  2-1:0] host_bs,
    output wire [ 16-1:0] host_wdat,
    input  wire [ 16-1:0] host_rdat,
    input  wire           host_ack
);
reg		[10:0] horbeam;			
reg		[8:0] verbeam;			
reg		[7:0] osdbuf [0:2048-1];	
wire	osdframe;				
reg		[7:0] bufout;			
reg 	[10:0] wraddr;			
wire	[7:0] wrdat;			
wire	wren;					
reg		[3:0] highlight;		
reg		invert;					
reg		[5:0] vpos;
reg		vena;
reg 	[6:0] t_memory_config = 7'b0_00_01_01;
reg		[2:0] t_ide_config = 0;
reg   [3:0] t_cpu_config = 0;
reg   [4:0] t_chipset_config = 0;
always @(posedge clk)
  if (clk7_en) begin
    if (reset)
    begin
      chipset_config <= t_chipset_config;
      ide_config <= t_ide_config;
      cpu_config[1:0] <= t_cpu_config[1:0];
      memory_config[5:0] <= t_memory_config[5:0];
    end
  end
always @(posedge clk) begin
  if (clk7_en) begin
    cpu_config[3:2] <= t_cpu_config[3:2];
    memory_config[6] <= #1 t_memory_config[6];
  end
end
always @(posedge clk)
	if (sol && !c1 && !c3)
		horbeam <= 11'd0;
	else
		horbeam <= horbeam + 11'd1;
always @(posedge clk)
  if (clk7_en) begin
  	if (sof)
  		verbeam <= 9'd0;
  	else if (sol)
  		verbeam <= verbeam + 9'd1;
  end
always @(posedge clk)
  if (clk7_en) begin
  	if (sol)
  		vpos[5:0] <= verbeam[5:0];
  end
wire hframe_normal;
wire hframe_varbeam;
wire hframe;
assign hframe_normal = (horbeam[7] & horbeam[8] & horbeam[9] & ~horbeam[10]) | (~horbeam[8] & ~horbeam[9] & horbeam[10]) | (~horbeam[7] & horbeam[8] & ~horbeam[9] & horbeam[10]);
assign hframe_varbeam = ~horbeam[10] & ~horbeam[9];
assign hframe = hframe_normal;
reg vframe;
always @(posedge clk)
  if (clk7_en) begin
  	if (!verbeam[8] && verbeam[7] && !verbeam[6])
  		vframe <= 1;
  	else if (verbeam[0])
  		vframe <= 0;
  end
always @(posedge clk)
  if (clk7_en) begin
  	if (sol)
  		vena <= vframe;
  end
reg osd_enabled;
always @(posedge clk)
  if (clk7_en) begin
    if (sof)
      osd_enabled <= osd_enable;
  end
assign osdframe = vframe & hframe & osd_enabled;
always @(posedge clk)
  if (clk7_en) begin
  	if (~highlight[3] && verbeam[5:3]==highlight[2:0] && !verbeam[6])
  		invert <= 1;
  	else if (verbeam[0])
  		invert <= 0;
  end
assign osd_pixel = invert ^ (vena & bufout[vpos[2:0]]);
assign osd_blank = osdframe;
always @(posedge clk) begin
  if (clk7_en) begin
  	if (wren)
  		osdbuf[wraddr[10:0]] <= wrdat[7:0];
  end
end
always @(posedge clk)
	bufout[7:0] <= osdbuf[{vpos[5:3],horbeam[8]^horbeam[7],~horbeam[7],horbeam[6:1]}];
wire	rx;
wire	cmd;
reg   wrcmd;    
wire  vld;
reg   vld_d;
wire  spi_invalidate;
wire [7:0] rddat;
userio_osd_spi spi0
(
	.clk(clk),
    .clk7_en(clk7_en),
    .clk7n_en(clk7n_en),
	._scs(_scs),
	.sdi(sdi),
	.sdo(sdo),
	.sck(sck),
	.in(rddat),
	.out(wrdat),
	.rx(rx),
	.cmd(cmd),
    .vld(vld)
);
always @ (posedge clk) begin
  if (clk7_en) begin
    vld_d <= #1 vld;
  end
end
assign spi_invalidate = ~vld && vld_d;
localparam [5:0]
  SPI_RESET_CTRL_ADR   = 6'b0_000_10,
  SPI_CLOCK_CTRL_ADR   = 6'b0_001_10,
  SPI_OSD_CTRL_ADR     = 6'b0_010_10,
  SPI_CHIP_CFG_ADR     = 6'b0_000_01,
  SPI_CPU_CFG_ADR      = 6'b0_001_01,
  SPI_MEMORY_CFG_ADR   = 6'b0_010_01,
  SPI_VIDEO_CFG_ADR    = 6'b0_011_01,
  SPI_FLOPPY_CFG_ADR   = 6'b0_100_01,
  SPI_HARDDISK_CFG_ADR = 6'b0_101_01,
  SPI_JOYSTICK_CFG_ADR = 6'b0_110_01,
  SPI_OSD_BUFFER_ADR   = 6'b0_000_11,
  SPI_MEM_WRITE_ADR    = 6'b0_001_11,
  SPI_VERSION_ADR      = 6'b1_000_10,
  SPI_MEM_READ_ADR     = 6'b1_001_11;
reg [5:0] cmd_dat = 6'h00;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (rx && cmd) cmd_dat <= #1 wrdat[7:2];
  end
end
reg [2:0] dat_cnt = 3'h0;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (rx && cmd)
      dat_cnt <= #1 3'h0;
    else if (rx && (dat_cnt != 4))
      dat_cnt <= #1 dat_cnt + 3'h1;
  end
end
reg spi_reset_ctrl_sel    = 1'b0;
reg spi_clock_ctrl_sel    = 1'b0;
reg spi_osd_ctrl_sel      = 1'b0;
reg spi_chip_cfg_sel      = 1'b0;
reg spi_cpu_cfg_sel       = 1'b0;
reg spi_memory_cfg_sel    = 1'b0;
reg spi_video_cfg_sel     = 1'b0;
reg spi_floppy_cfg_sel    = 1'b0;
reg spi_harddisk_cfg_sel  = 1'b0;
reg spi_joystick_cfg_sel  = 1'b0;
reg spi_osd_buffer_sel    = 1'b0;
reg spi_mem_write_sel     = 1'b0;
reg spi_version_sel       = 1'b0;
reg spi_mem_read_sel      = 1'b0;
always @ (*) begin
  spi_reset_ctrl_sel   = 1'b0;
  spi_clock_ctrl_sel   = 1'b0;
  spi_osd_ctrl_sel     = 1'b0;
  spi_chip_cfg_sel     = 1'b0;
  spi_cpu_cfg_sel      = 1'b0;
  spi_memory_cfg_sel   = 1'b0;
  spi_video_cfg_sel    = 1'b0;
  spi_floppy_cfg_sel   = 1'b0;
  spi_harddisk_cfg_sel = 1'b0;
  spi_joystick_cfg_sel = 1'b0;
  spi_osd_buffer_sel   = 1'b0;
  spi_mem_write_sel    = 1'b0;
  spi_version_sel      = 1'b0;
  spi_mem_read_sel     = 1'b0;
  case (cmd_dat)
    SPI_RESET_CTRL_ADR   : spi_reset_ctrl_sel   = 1'b1;
    SPI_CLOCK_CTRL_ADR   : spi_clock_ctrl_sel   = 1'b1;
    SPI_OSD_CTRL_ADR     : spi_osd_ctrl_sel     = 1'b1;
    SPI_CHIP_CFG_ADR     : spi_chip_cfg_sel     = 1'b1;
    SPI_CPU_CFG_ADR      : spi_cpu_cfg_sel      = 1'b1;
    SPI_MEMORY_CFG_ADR   : spi_memory_cfg_sel   = 1'b1;
    SPI_VIDEO_CFG_ADR    : spi_video_cfg_sel    = 1'b1;
    SPI_FLOPPY_CFG_ADR   : spi_floppy_cfg_sel   = 1'b1;
    SPI_HARDDISK_CFG_ADR : spi_harddisk_cfg_sel = 1'b1;
    SPI_JOYSTICK_CFG_ADR : spi_joystick_cfg_sel = 1'b1;
    SPI_OSD_BUFFER_ADR   : spi_osd_buffer_sel   = 1'b1;
    SPI_MEM_WRITE_ADR    : spi_mem_write_sel    = 1'b1;
    SPI_VERSION_ADR      : spi_version_sel      = 1'b1;
    SPI_MEM_READ_ADR     : spi_mem_read_sel     = 1'b1;
    default: begin
      spi_reset_ctrl_sel   = 1'b0;
      spi_clock_ctrl_sel   = 1'b0;
      spi_osd_ctrl_sel     = 1'b0;
      spi_chip_cfg_sel     = 1'b0;
      spi_cpu_cfg_sel      = 1'b0;
      spi_memory_cfg_sel   = 1'b0;
      spi_video_cfg_sel    = 1'b0;
      spi_floppy_cfg_sel   = 1'b0;
      spi_harddisk_cfg_sel = 1'b0;
      spi_joystick_cfg_sel = 1'b0;
      spi_osd_buffer_sel   = 1'b0;
      spi_mem_write_sel    = 1'b0;
      spi_version_sel      = 1'b0;
      spi_mem_read_sel     = 1'b0;
    end
  endcase
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (rx && !cmd) begin
      if (spi_reset_ctrl_sel)   begin if (dat_cnt == 0) {cpuhlt, cpurst, usrrst} <= #1 wrdat[2:0]; end
      if (spi_osd_ctrl_sel)     begin if (dat_cnt == 0) {key_disable, osd_enable} <= #1 wrdat[1:0]; end
      if (spi_chip_cfg_sel)     begin if (dat_cnt == 0) t_chipset_config <= #1 wrdat[4:0]; end
      if (spi_cpu_cfg_sel)      begin if (dat_cnt == 0) t_cpu_config <= #1 wrdat[3:0]; end
      if (spi_memory_cfg_sel)   begin if (dat_cnt == 0) t_memory_config <= #1 wrdat[6:0]; end
      if (spi_video_cfg_sel)    begin if (dat_cnt == 0) {dither, hr_filter, lr_filter, scanline} <= #1 wrdat[7:0]; end
      if (spi_floppy_cfg_sel)   begin if (dat_cnt == 0) floppy_config <= #1 wrdat[3:0]; end
      if (spi_harddisk_cfg_sel) begin if (dat_cnt == 0) t_ide_config <= #1 wrdat[2:0]; end 
      if (spi_joystick_cfg_sel) begin if (dat_cnt == 0) {autofire_config} <= #1 wrdat[1:0]; end
    end
  end
end
reg wr_en_r = 1'b0;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (rx && (dat_cnt == 3) && spi_osd_buffer_sel)
      wr_en_r <= #1 1'b1;
    else if (rx && cmd)
      wr_en_r <= #1 1'b0;
  end
end
assign wren = wr_en_r && rx && !cmd;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (rx && !cmd && (spi_osd_buffer_sel || spi_mem_read_sel) && (dat_cnt == 3))
      wraddr[10:0] <= {wrdat[2:0],8'b0000_0000};
    else if (rx)	
      wraddr[10:0] <= wraddr[10:0] + 11'd1;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (~osd_enable)
      highlight <= #1 4'b1000;
    else if (rx && !cmd && spi_osd_buffer_sel && (dat_cnt == 3) && wrdat[4])
      highlight <= #1 wrdat[3:0];
  end
end
reg mem_toggle = 1'b0, mem_toggle_d = 1'b0;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (cmd) begin
      mem_toggle <= #1 1'b0;
      mem_toggle_d <= #1 1'b0;
    end else if (rx && !cmd && spi_mem_write_sel && (dat_cnt == 4)) begin
      mem_toggle <= #1 ~mem_toggle;
      mem_toggle_d <= #1 mem_toggle;
    end
  end
end
reg  [ 8-1:0] mem_dat_r;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (rx && !cmd && spi_mem_write_sel && !mem_toggle) mem_dat_r <= #1 wrdat[7:0];
  end
end
wire wr_fifo_empty;
wire wr_fifo_full;
assign fifo_full = wr_fifo_full;
reg  wr_fifo_rd_en;
sync_fifo #(
  .FD (4),
  .DW (16)
) wr_fifo (
  .clk          (clk),
  //.clk7_en      (clk7_en),
  //.rst          (reset), 
  //.fifo_in      ({mem_dat_r, wrdat}),
  //.fifo_out     (host_wdat),
  //.fifo_wr_en   (rx && !cmd && mem_toggle),
  //.fifo_rd_en   (wr_fifo_rd_en),
  .fifo_full    (wr_fifo_full),
  .fifo_empty   (wr_fifo_empty)
);
reg  [2-1:0] wr_state = 2'b00;
localparam ST_WR_IDLE = 2'b00;
localparam ST_WR_WRITE = 2'b10;
localparam ST_WR_WAIT = 2'b11;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reset || cmd)
      wr_state <= #1 ST_WR_IDLE;
    else begin
      case (wr_state)
        ST_WR_IDLE: begin
          wr_fifo_rd_en <= #1 1'b0;
          host_cs <= #1 1'b0;
          host_we <= #1 1'b0;
          host_bs <= #1 2'b00;
          wr_fifo_rd_en <= #1 1'b0;
          if (!wr_fifo_empty && !wr_fifo_rd_en) wr_state <= #1 ST_WR_WRITE;
        end
        ST_WR_WRITE: begin
          host_cs <= #1 1'b1;
          host_we <= #1 1'b1;
          host_bs <= #1 2'b11;
          if (host_ack) begin
            wr_fifo_rd_en <= #1 1'b1;
            wr_state <= #1 ST_WR_IDLE;
          end
        end
        ST_WR_WAIT: begin
          host_cs <= #1 1'b0;
          host_we <= #1 1'b0;
          host_bs <= #1 2'b00;
          wr_state <= #1 ST_WR_IDLE;
          wr_fifo_rd_en <= #1 1'b0;
        end
      endcase
    end
  end
end
reg  [ 8-1:0] mem_page;
reg  [24-1:0] mem_cnt;
wire [32-1:0] mem_adr;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (rx && !cmd && spi_mem_write_sel) begin
      case (dat_cnt)
        0 : mem_cnt [ 7: 0] <= #1 wrdat[7:0];
        1 : mem_cnt [15: 8] <= #1 wrdat[7:0];
        2 : mem_cnt [23:16] <= #1 wrdat[7:0];
        3 : mem_page[ 7: 0] <= #1 wrdat[7:0];
      endcase
    end else if (wr_fifo_rd_en) mem_cnt [23:0] <= #1 mem_cnt + 24'd2;
  end
end
assign mem_adr = {mem_page, mem_cnt};
assign host_adr  = mem_adr[23:0];
//`include "minimig_version.vh"
reg  [8-1:0] rtl_ver;
always @ (*) begin
  case (dat_cnt[2:0])
    2'b00   : rtl_ver = 8'b0;//BETA_FLAG;
    2'b01   : rtl_ver = 8'b01;//MAJOR_VER;
    2'b10   : rtl_ver = 8'b10;//MINOR_VER;
    default : rtl_ver = 8'b11;//SEPARATOR;
  endcase
end
assign rddat =  (spi_version_sel)  ? rtl_ver :
                (spi_mem_read_sel) ? 8'd00  : osd_ctrl;
endmodule