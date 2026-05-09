module fifo
(
	input 	clk,		    	
	input 	reset,			   	
	input	[15:0] in,			
	output	reg [15:0] out,	
	input	rd,					
	input	wr,					
	output	reg empty,			
	output	full,				
	output	[11:0] cnt       
);
reg 	[15:0] mem [2047:0];	
reg		[11:0] in_ptr;			
reg		[11:0] out_ptr;			
wire	equal;					
assign cnt = in_ptr - out_ptr;
always @(posedge clk)
	if (wr)
		mem[in_ptr[10:0]] <= in;
always @(posedge clk)
	out=mem[out_ptr[10:0]];
always @(posedge clk)
	if (reset)
		in_ptr[11:0] <= 0;
	else if(wr)
		in_ptr[11:0] <= in_ptr[11:0] + 12'd1;
always @(posedge clk)
	if (reset)
		out_ptr[11:0] <= 0;
	else if (rd)
		out_ptr[11:0] <= out_ptr[11:0] + 12'd1;
assign equal = (in_ptr[10:0]==out_ptr[10:0]) ? 1'b1 : 1'b0;
always @(posedge clk)
	if (equal && (in_ptr[11]==out_ptr[11]))
		empty <= 1'b1;
	else
		empty <= 1'b0;
assign full = (equal && (in_ptr[11]!=out_ptr[11])) ? 1'b1 : 1'b0;	
endmodule
module floppy
(
	input 	clk,		    		
	input 	reset,			   		
  input ntsc,         
  input sof,          
	input	enable,					
	input 	[8:1] reg_address_in,	
	input	[15:0] data_in,			
	output	[15:0] data_out,		
	output	dmal,					
	output	dmas,					
	input	_step,					
	input	direc,					
	input	[3:0] _sel,				
	input	side,					
	input	_motor,					
	output	_track0,				
	output	_change,				
	output	_ready,					
	output	_wprot,					
  output  index,          
	output	reg blckint,			
	output	syncint,				
	input	wordsync,				
	input	_scs,					
	input	sdi,					
	output	sdo,					
	input	sck,					
	output	disk_led,				
	input	[1:0] floppy_drives,	
	input	direct_scs,				
	input	direct_sdi,				
	input	hdd_cmd_req,			
	input	hdd_dat_req,			
	output	[2:0] hdd_addr,			
	output	[15:0] hdd_data_out,	
	input	[15:0] hdd_data_in,		
	output	hdd_wr,					
	output	hdd_status_wr,			
	output	hdd_data_wr,			
	output	hdd_data_rd,			
	output  [7:0]trackdisp,
	output  [13:0]secdisp,
  output  floppy_fwr,
  output  floppy_frd
);
	parameter DSKBYTR = 9'h01a;
	parameter DSKDAT  = 9'h026;		
	parameter DSKDATR = 9'h008;
	parameter DSKSYNC = 9'h07e;
	parameter DSKLEN  = 9'h024;
	reg		[15:0] dsksync;			
	reg		[15:0] dsklen;			
	reg		[6:0] dsktrack[3:0];	
	wire	[7:0] track;
	reg		dmaon;					
	wire	lenzero;				
	wire	spidat;					
	reg		trackwr;				
	reg		trackrd;				
	wire	_dsktrack0;				
  wire  dsktrack79;       
	wire	[15:0] fifo_in;			
	wire	[15:0] fifo_out; 		
	wire	fifo_wr;					
	reg		fifo_wr_del;				
	wire	fifo_rd;					
	wire	fifo_empty;				
	wire	fifo_full;				
  wire  [11:0] fifo_cnt;
	wire	[15:0] dskbytr;			
	wire	[15:0] dskdatr;
	wire	fifo_reset;
	reg		dmaen;					
	reg		[15:0] wr_fifo_status;
	reg		[3:0] disk_present;		
	reg		[3:0] disk_writable;	
	wire	_selx;					
	wire	[1:0] sel;				
	reg		[1:0] drives;			
  reg   [3:0] _disk_change;
  reg   _step_del;
  reg   [8:0] step_ena_cnt;
  wire  step_ena;
  reg   [3:0] _sel_del;     
  reg   [3:0] motor_on;     
	reg		cmd_fdd;				
	reg		cmd_hdd_rd;				
	reg		cmd_hdd_wr;				
	reg		cmd_hdd_data_wr;		
	reg		cmd_hdd_data_rd;		
	wire sdin;					
	wire scs;					
	wire scs1;
	wire scs2;
	reg [3:0] spi_bit_cnt;		
	wire spi_bit_15;
	wire spi_bit_0;
	reg [15:1] spi_sdi_reg;		
	reg [15:0] rx_data;			
	reg [15:0] spi_sdo_reg;		
	reg spi_rx_flag;
	reg rx_flag_sync;
	reg rx_flag;
	wire spi_rx_flag_clr;
	reg spi_tx_flag;
	reg tx_flag_sync;
	reg tx_flag;
	wire spi_tx_flag_clr;
	reg [15:0] spi_tx_data;		
	reg [15:0] spi_tx_data_0;
	reg [15:0] spi_tx_data_1;
	reg [15:0] spi_tx_data_2;
	reg [15:0] spi_tx_data_3;
	reg [1:0] spi_tx_cnt;		
	reg [1:0] spi_tx_cnt_del;	
	reg [1:0] tx_cnt;			
	reg	[2:0] tx_data_cnt;
	reg	[2:0] rx_data_cnt;
	reg	[1:0] rx_cnt;
	reg	[1:0] spi_rx_cnt;		
	reg	spi_rx_cnt_rst;			
assign trackdisp = track;
assign secdisp = dsklen[13:0];
assign floppy_fwr = fifo_wr;
assign floppy_frd = fifo_rd;
assign sdin = direct_scs ? direct_sdi : sdi;
assign scs1 = ~_scs;
assign scs2 = direct_scs;
assign scs = scs1 | scs2;
always @(posedge sck or negedge scs)
	if (~scs)
		spi_bit_cnt <= 4'h0; 
	else
		spi_bit_cnt <= spi_bit_cnt + 1'b1;
assign spi_bit_15 = spi_bit_cnt==4'd15 ? 1'b1 : 1'b0;
assign spi_bit_0 = spi_bit_cnt==4'd0 ? 1'b1 : 1'b0;
always @(posedge sck)
	spi_sdi_reg <= {spi_sdi_reg[14:1],sdin};
always @(posedge sck)
	if (spi_bit_15)
		rx_data <= {spi_sdi_reg[15:1],sdin};		
assign spi_rx_flag_clr = rx_flag | reset;
always @(posedge sck or posedge spi_rx_flag_clr)
	if (spi_rx_flag_clr)
		spi_rx_flag <= 1'b0;
	else if (spi_bit_cnt==4'd15)
		spi_rx_flag <= 1'b1;
always @(negedge clk)
	rx_flag_sync <= spi_rx_flag;	
always @(posedge clk)
	rx_flag <= rx_flag_sync;		
assign spi_tx_flag_clr = tx_flag | reset;
always @(negedge sck or posedge spi_tx_flag_clr)
	if (spi_tx_flag_clr)
		spi_tx_flag <= 1'b0;
	else if (spi_bit_cnt==4'd0)
		spi_tx_flag <= 1'b1;
always @(negedge clk)
	tx_flag_sync <= spi_tx_flag;	
always @(posedge clk)
	tx_flag <= tx_flag_sync;		
always @(negedge sck or negedge scs)
	if (~scs)
		spi_tx_cnt <= 2'd0;
	else if (spi_bit_0 && spi_tx_cnt!=2'd3)
		spi_tx_cnt <= spi_tx_cnt + 2'd1;
always @(negedge sck)
	if (spi_bit_0) 
		spi_tx_cnt_del <= spi_tx_cnt;
always @(posedge clk)
	tx_cnt <= spi_tx_cnt_del;		
always @(negedge sck)
	if (spi_bit_cnt==4'd0)
		if (spi_tx_cnt==2'd2)
			tx_data_cnt <= 3'd0;
		else
			tx_data_cnt <= tx_data_cnt + 3'd1;
always @(posedge clk)
	if (rx_flag)
		if (rx_cnt != 2'd3)
			rx_data_cnt <= 3'd0;
		else
			rx_data_cnt <= rx_data_cnt + 3'd1;			
assign hdd_addr = cmd_hdd_rd ? tx_data_cnt : cmd_hdd_wr ? rx_data_cnt : 1'b0;
assign hdd_wr = cmd_hdd_wr && rx_flag && rx_cnt==2'd3 ? 1'b1 : 1'b0;
assign hdd_data_wr = (cmd_hdd_data_wr && rx_flag && rx_cnt==2'd3) || (scs2 && rx_flag) ? 1'b1 : 1'b0;	
assign hdd_status_wr = rx_data[15:12]==4'b1111 && rx_flag && rx_cnt==2'd0 ? 1'b1 : 1'b0;
assign hdd_data_rd = cmd_hdd_data_rd && tx_flag && tx_cnt==2'd3 ? 1'b1 : 1'b0;
assign hdd_data_out = rx_data[15:0];
always @(posedge sck or negedge scs1)
	if (~scs1)
		spi_rx_cnt_rst <= 1'b1;
	else if (spi_bit_15)
		spi_rx_cnt_rst <= 1'b0;
always @(posedge sck)
	if (scs1 && spi_bit_15)
		if (spi_rx_cnt_rst)
			spi_rx_cnt <= 2'd0;
		else if (spi_rx_cnt!=2'd3)
			spi_rx_cnt <= spi_rx_cnt + 2'd1;
always @(posedge clk)
	rx_cnt <= spi_rx_cnt;
assign spidat = cmd_fdd && rx_flag && rx_cnt==3 ? 1'b1 : 1'b0;
always @(negedge sck)
	if (spi_bit_cnt==4'd0)
		spi_sdo_reg <= spi_tx_data;
	else
		spi_sdo_reg <= {spi_sdo_reg[14:0],1'b0};
assign sdo = scs1 & spi_sdo_reg[15];
always @(spi_tx_cnt or spi_tx_data_0 or spi_tx_data_1 or spi_tx_data_2 or spi_tx_data_3)
	case (spi_tx_cnt[1:0])
		0 : spi_tx_data = spi_tx_data_0;
		1 : spi_tx_data = spi_tx_data_1;
		2 : spi_tx_data = spi_tx_data_2;
		3 : spi_tx_data = spi_tx_data_3;
	endcase
always @(sel or drives or hdd_dat_req or hdd_cmd_req or trackwr or trackrd or track or fifo_cnt)
	spi_tx_data_0 = {sel[1:0],drives[1:0],hdd_dat_req,hdd_cmd_req,trackwr,trackrd&~fifo_cnt[10],track[7:0]};
always @(dsksync)
		spi_tx_data_1 = dsksync[15:0]; 
always @(trackrd or dmaen or dsklen or trackwr or wr_fifo_status)
	if (trackrd)
		spi_tx_data_2 = {dmaen,dsklen[14:0]};
	else if (trackwr)
		spi_tx_data_2 = wr_fifo_status;
	else
		spi_tx_data_2 = 16'd0;
always @(cmd_fdd or trackrd or dmaen or dsklen or trackwr or fifo_out	or cmd_hdd_rd or cmd_hdd_data_rd or hdd_data_in)	
	if (cmd_fdd)
		if (trackrd)
			spi_tx_data_3 = {dmaen,dsklen[14:0]};
		else if (trackwr)
			spi_tx_data_3 = fifo_out;
		else
			spi_tx_data_3 = 16'd0;
	else if (cmd_hdd_rd || cmd_hdd_data_rd)
		spi_tx_data_3 = hdd_data_in;	
	else
		spi_tx_data_3 = 16'd0;			
always @(posedge clk)
	if (tx_flag)
		wr_fifo_status <= {dmaen&dsklen[14],3'b000,fifo_cnt[11:0]};
always @(posedge clk)
	if (reset)
		drives <= floppy_drives;
reg [3:0] rpm_pulse_cnt;
always @(posedge clk)
  if (sof)
    if (rpm_pulse_cnt==4'd11 || !ntsc && rpm_pulse_cnt==4'd9)
      rpm_pulse_cnt <= 4'd0;
    else
      rpm_pulse_cnt <= rpm_pulse_cnt + 4'd1;
assign index = |(~_sel & motor_on) & ~|rpm_pulse_cnt & sof;
assign data_out = dskbytr | dskdatr;
assign _selx = &_sel[3:0];
always @(posedge clk)
  _step_del <= _step;
always @(posedge clk)
  if (!step_ena)
    step_ena_cnt <= step_ena_cnt + 9'd1;
  else if (_step && !_step_del)
    step_ena_cnt <= 9'd0;
assign step_ena = step_ena_cnt[8];
always @(posedge clk)
  _disk_change <= (_disk_change | ~_sel & {4{_step}} & ~{4{_step_del}} & disk_present) & ~({4{reset}} | ~disk_present);
assign sel = !_sel[0] ? 2'd0 : !_sel[1] ? 2'd1 : !_sel[2] ? 2'd2 : !_sel[3] ? 2'd3 : 2'd0;
always @(posedge clk)
  _sel_del <= _sel;
always @(posedge clk)
  if (reset)
    motor_on[0] <= 1'b0;
  else if (!_sel[0] && _sel_del[0])
    motor_on[0] <= ~_motor;
always @(posedge clk)
  if (reset)
    motor_on[1] <= 1'b0;
  else if (!_sel[1] && _sel_del[1])
    motor_on[1] <= ~_motor;
always @(posedge clk)
  if (reset)
    motor_on[2] <= 1'b0;
  else if (!_sel[2] && _sel_del[2])
    motor_on[2] <= ~_motor;
always @(posedge clk)
  if (reset)
    motor_on[3] <= 1'b0;
  else if (!_sel[3] && _sel_del[3])
    motor_on[3] <= ~_motor;
assign _change = &(_sel | _disk_change);
assign _wprot = &(_sel | disk_writable);
assign  _track0 =&(_selx | _dsktrack0);
assign track = {dsktrack[sel],~side};
always @(posedge clk)
  if (!_selx && _step && !_step_del && step_ena) 
    if (!dsktrack79 && !direc)
      dsktrack[sel] <= dsktrack[sel] + 7'd1;
    else if (_dsktrack0 && direc)
      dsktrack[sel] <= dsktrack[sel] - 7'd1;	
assign _dsktrack0 = dsktrack[sel]==0 ? 1'b0 : 1'b1;
assign dsktrack79 = dsktrack[sel]==82 ? 1'b1 : 1'b0;
assign _ready   = (_sel[3] | ~(drives[1] & drives[0])) 
        & (_sel[2] | ~drives[1]) 
        & (_sel[1] | ~(drives[1] | drives[0])) 
        & (_sel[0]);
assign dskbytr = reg_address_in[8:1]==DSKBYTR[8:1] ? {1'b1,(trackrd|trackwr),dsklen[14],5'b1_0000,8'h00} : 16'h00_00;
always @(posedge clk)
	if (reset) 
		dsksync[15:0] <= 16'h4489;
	else if (reg_address_in[8:1]==DSKSYNC[8:1])
		dsksync[15:0] <= data_in[15:0];
always @(posedge clk)
	if (reset)
		dsklen[14:0] <= 15'd0;
	else if (reg_address_in[8:1]==DSKLEN[8:1])
		dsklen[14:0] <= data_in[14:0];
	else if (fifo_wr)
		dsklen[13:0] <= dsklen[13:0] - 14'd1;
always @(posedge clk)
	if (reset)
		dsklen[15] <= 1'b0;
	else if (blckint)
		dsklen[15] <= 1'b0;
	else if (reg_address_in[8:1]==DSKLEN[8:1])
		dsklen[15] <= data_in[15];
always @(posedge clk)
	if (reset)
		dmaen <= 1'b0;
	else if (blckint)
		dmaen <= 1'b0;
	else if (reg_address_in[8:1]==DSKLEN[8:1])
		dmaen <= data_in[15] & dsklen[15];
assign lenzero = (dsklen[13:0]==0) ? 1'b1 : 1'b0;
wire	busrd;				
wire	buswr;				
reg		trackrdok;			
assign busrd = (reg_address_in[8:1]==DSKDATR[8:1]) ? 1'b1 : 1'b0;
assign buswr = (reg_address_in[8:1]==DSKDAT[8:1]) ? 1'b1 : 1'b0;
assign fifo_in[15:0] = trackrd ? rx_data[15:0] : data_in[15:0];
assign fifo_wr = (trackrdok & spidat & ~lenzero) | (buswr & dmaon);
always @(posedge clk)
	fifo_wr_del <= fifo_wr;
assign fifo_rd = (busrd & dmaon) | (trackwr & spidat);
wire sync_match;
assign sync_match = dsksync[15:0]==rx_data[15:0] && spidat && trackrd ? 1'b1 : 1'b0;
assign syncint = sync_match | ~dmaen & |(~_sel & motor_on & disk_present) & sof;
always @(posedge clk)
	if (!trackrd)
		trackrdok <= 0;
	else
		trackrdok <= ~wordsync | sync_match | trackrdok;
assign fifo_reset = reset | ~dmaen;
fifo db1
(
	.clk(clk),
	.reset(fifo_reset),
	.in(fifo_in),
	.out(fifo_out),
	.rd(fifo_rd & ~fifo_empty),
	.wr(fifo_wr & ~fifo_full),
	.empty(fifo_empty),
	.full(fifo_full),
	.cnt(fifo_cnt)
);
assign dskdatr[15:0] = busrd ? fifo_out[15:0] : 16'h00_00;
assign dmal = dmaon & (~dsklen[14] & ~fifo_empty | dsklen[14] & ~fifo_full);
assign dmas = dmaon & dsklen[14] & ~fifo_full;
reg		[1:0] dskstate;		
reg		[1:0] nextstate; 	
parameter DISKDMA_IDLE   = 2'b00;
parameter DISKDMA_ACTIVE = 2'b10;
parameter DISKDMA_INT    = 2'b11;
always @(posedge clk)
	if(reset)
		{disk_writable[3:0],disk_present[3:0]} <= 8'b0000_0000;
	else if (rx_data[15:12]==4'b0001 && rx_flag && rx_cnt==0)
		{disk_writable[3:0],disk_present[3:0]} <= rx_data[7:0];
always @(posedge clk)
	if (reset)
	begin
		cmd_fdd <= 0;
		cmd_hdd_rd <= 0;
		cmd_hdd_wr <= 0;
		cmd_hdd_data_wr <= 0;
		cmd_hdd_data_rd <= 0;
	end
	else if (rx_flag && rx_cnt==0)
	begin
		cmd_fdd <= rx_data[15:13]==3'b000 ? 1'b1 : 1'b0;
		cmd_hdd_rd <= rx_data[15:12]==4'b1000 ? 1'b1 : 1'b0;
		cmd_hdd_wr <= rx_data[15:12]==4'b1001 ? 1'b1 : 1'b0;
		cmd_hdd_data_wr <= rx_data[15:12]==4'b1010 ? 1'b1 : 1'b0;
		cmd_hdd_data_rd <= rx_data[15:12]==4'b1011 ? 1'b1 : 1'b0;
	end
assign disk_led = |motor_on;
always @(posedge clk)
	if (reset)
		dskstate <= DISKDMA_IDLE;		
	else
		dskstate <= nextstate;
always @(dskstate or spidat or rx_data or dmaen or lenzero or enable or dsklen or fifo_empty or rx_flag or cmd_fdd or rx_cnt or fifo_wr_del)
begin
	case(dskstate)
		DISKDMA_IDLE:
		begin
			trackrd = 0;
			trackwr = 0;
			dmaon = 0;
			blckint = 0;
			if (cmd_fdd && rx_flag && rx_cnt==1 && dmaen && !lenzero && enable)
				nextstate = DISKDMA_ACTIVE; 
			else
				nextstate = DISKDMA_IDLE;			
		end
		DISKDMA_ACTIVE:
		begin
      trackrd = ~lenzero & ~dsklen[14]; 
      trackwr = dsklen[14]; 
      dmaon = ~lenzero | ~dsklen[14];
			blckint=0;
			if (!dmaen || !enable)
				nextstate = DISKDMA_IDLE;
			else if (lenzero && fifo_empty && !fifo_wr_del)
				nextstate = DISKDMA_INT;
			else
				nextstate = DISKDMA_ACTIVE;			
		end
		DISKDMA_INT:
		begin
			trackrd = 0;
			trackwr = 0;
			dmaon = 0;
			blckint = 1;
			nextstate = DISKDMA_IDLE;			
		end
		default:
		begin
			trackrd = 1'bx;
			trackwr = 1'bx;
			dmaon = 1'bx;
			blckint = 1'bx;
			nextstate = DISKDMA_IDLE;			
		end
	endcase
end
endmodule
module fifo
(
	input 	clk,		    	
	input 	reset,			   	
	input	[15:0] in,			
	output	reg [15:0] out,	
	input	rd,					
	input	wr,					
	output	reg empty,			
	output	full,				
	output	[11:0] cnt       
);
reg 	[15:0] mem [2047:0];	
reg		[11:0] in_ptr;			
reg		[11:0] out_ptr;			
wire	equal;					
assign cnt = in_ptr - out_ptr;
always @(posedge clk)
	if (wr)
		mem[in_ptr[10:0]] <= in;
always @(posedge clk)
	out=mem[out_ptr[10:0]];
always @(posedge clk)
	if (reset)
		in_ptr[11:0] <= 0;
	else if(wr)
		in_ptr[11:0] <= in_ptr[11:0] + 12'd1;
always @(posedge clk)
	if (reset)
		out_ptr[11:0] <= 0;
	else if (rd)
		out_ptr[11:0] <= out_ptr[11:0] + 12'd1;
assign equal = (in_ptr[10:0]==out_ptr[10:0]) ? 1'b1 : 1'b0;
always @(posedge clk)
	if (equal && (in_ptr[11]==out_ptr[11]))
		empty <= 1'b1;
	else
		empty <= 1'b0;
assign full = (equal && (in_ptr[11]!=out_ptr[11])) ? 1'b1 : 1'b0;	
endmodule
