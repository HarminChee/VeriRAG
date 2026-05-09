module fifo4096x16
(
	input 	clk,		    		
	input 	reset,			   		
	input	[15:0] data_in,			
	output	reg [15:0] data_out,	
	input	rd,						
	input	wr,						
	output	full,					
	output	empty,					
	output	last					
);
reg 	[15:0] mem [4095:0];		
reg		[12:0] inptr;				
reg		[12:0] outptr;				
wire	empty_rd;					
reg		empty_wr;					
always @(posedge clk)
	if (wr)
		mem[inptr[11:0]] <= data_in;
always @(posedge clk)
	data_out <= mem[outptr[11:0]];
always @(posedge clk)
	if (reset)
		inptr <= 12'd0;
	else if (wr)
		inptr <= inptr + 12'd1;
always @(posedge clk)
	if (reset)
		outptr <= 0;
	else if (rd)
		outptr <= outptr + 13'd1;
assign empty_rd = inptr==outptr ? 1'b1 : 1'b0;
always @(posedge clk)
	empty_wr <= empty_rd;
assign empty = empty_rd | empty_wr;
assign full = inptr[12:8]!=outptr[12:8] ? 1'b1 : 1'b0;	
assign last = outptr[7:0] == 8'hFF ? 1'b1 : 1'b0;	
endmodule
module gayle
(
	input	clk,
	input	reset,
	input	[23:1] address_in,
	input	[15:0] data_in,
	output	[15:0] data_out,
	input	rd,
	input	hwr,
	input	lwr,
	input	sel_ide,			
	input	sel_gayle,			
	output	irq,
	output	nrdy,				
	input	[1:0] hdd_ena,		
	output	hdd_cmd_req,
	output	hdd_dat_req,
	input	[2:0] hdd_addr,
	input	[15:0] hdd_data_out,
	output	[15:0] hdd_data_in,
	input	hdd_wr,
	input	hdd_status_wr,
	input	hdd_data_wr,
	input	hdd_data_rd,
  output hd_fwr,
  output hd_frd
);
localparam VCC = 1'b1;
localparam GND = 1'b0;
wire 	sel_gayleid;	
wire 	sel_tfr;		
wire 	sel_fifo;		
wire 	sel_status;		
wire 	sel_command;	
wire 	sel_intreq;		
wire 	sel_intena;		
reg		intena;			
reg		intreq;			
reg		busy;			
reg		pio_in;			
reg		pio_out;		
reg		error;			
reg		dev;			
wire 	bsy;			
wire 	drdy;			
wire 	drq;			
wire 	err;			
wire 	[7:0] status;	
wire	fifo_reset;
wire	[15:0] fifo_data_in;
wire	[15:0] fifo_data_out;
wire 	fifo_rd;
wire 	fifo_wr;
wire 	fifo_full;
wire 	fifo_empty;
wire	fifo_last;			
reg		[1:0] gayleid_cnt;	
wire	gayleid;			
assign hd_fwr = fifo_wr;
assign hd_frd = fifo_rd;
assign status = {bsy,drdy,2'b00,drq,2'b00,err};
assign bsy = busy & ~drq;
assign drdy = ~(bsy|drq);
assign err = error;
assign sel_gayleid = sel_gayle && address_in[15:12]==4'b0001 ? VCC : GND;	
assign sel_tfr = sel_ide && address_in[15:14]==2'b00 && !address_in[12] ? VCC : GND;
assign sel_status = rd && sel_tfr && address_in[4:2]==3'b111 ? VCC : GND;
assign sel_command = hwr && sel_tfr && address_in[4:2]==3'b111 ? VCC : GND;
assign sel_fifo = sel_tfr && address_in[4:2]==3'b000 ? VCC : GND;
assign sel_intreq = sel_ide && address_in[15:12]==4'b1001 ? VCC : GND;	
assign sel_intena = sel_ide && address_in[15:12]==4'b1010 ? VCC : GND;	
reg		[7:0] tfr [7:0];
wire	[2:0] tfr_sel;
wire	[7:0] tfr_in;
wire	[7:0] tfr_out;
wire	tfr_we;
reg		[7:0] sector_count;	
wire	sector_count_dec;	
always @(posedge clk)
	if (hwr && sel_tfr && address_in[4:2] == 3'b010) 
		sector_count <= data_in[15:8];
	else if (sector_count_dec)
		sector_count <= sector_count - 8'd1;
assign sector_count_dec = pio_in & fifo_last & sel_fifo & rd;
assign tfr_we = busy ? hdd_wr : sel_tfr & hwr;
assign tfr_sel = busy ? hdd_addr : address_in[4:2];
assign tfr_in = busy ? hdd_data_out[7:0] : data_in[15:8];
assign hdd_data_in = tfr_sel==0 ? fifo_data_out : {8'h00,tfr_out};
always @(posedge clk)
	if (tfr_we)
		tfr[tfr_sel] <= tfr_in;
assign tfr_out = tfr[tfr_sel];
always @(posedge clk)
	if (reset)
		dev <= 0;
	else if (sel_tfr && address_in[4:2]==6 && hwr)
		dev <= data_in[12];
always @(posedge clk)
	if (reset)
		intena <= GND;
	else if (sel_intena && hwr)
		intena <= data_in[15];
always @(posedge clk)
	if (sel_gayleid)
		if (hwr) 
			gayleid_cnt <= 2'd0;
		else if (rd)
			gayleid_cnt <= gayleid_cnt + 2'd1;
assign gayleid = ~gayleid_cnt[1] | gayleid_cnt[0]; 
always @(posedge clk)
	if (reset)
		busy <= GND;
	else if (hdd_status_wr && hdd_data_out[7] || sector_count_dec && sector_count == 8'h01)	
		busy <= GND;
	else if (sel_command)	
		busy <= VCC;
always @(posedge clk)
	if (reset)
		intreq <= GND;
	else if (busy && hdd_status_wr && hdd_data_out[4] && intena) 
		intreq <= VCC;
	else if (sel_intreq && hwr && !data_in[15]) 
		intreq <= GND;
assign irq = (~pio_in | drq) & intreq; 
always @(posedge clk)
	if (reset)
		pio_in <= GND;
	else if (drdy) 
		pio_in <= GND;
	else if (busy && hdd_status_wr && hdd_data_out[3])	
		pio_in <= VCC;		
always @(posedge clk)
	if (reset)
		pio_out <= GND;
	else if (busy && hdd_status_wr && hdd_data_out[7]) 	
		pio_out <= GND;
	else if (busy && hdd_status_wr && hdd_data_out[2])	
		pio_out <= VCC;	
assign drq = (fifo_full & pio_in) | (~fifo_full & pio_out); 
always @(posedge clk)
	if (reset)
		error <= GND;
	else if (sel_command) 
		error <= GND;
	else if (busy && hdd_status_wr && hdd_data_out[0]) 
		error <= VCC;	
assign hdd_cmd_req = bsy; 
assign hdd_dat_req = (fifo_full & pio_out); 
assign fifo_reset = reset | sel_command;
assign fifo_data_in = pio_in ? hdd_data_out : data_in;
assign fifo_rd = pio_out ? hdd_data_rd : sel_fifo & rd;
assign fifo_wr = pio_in ? hdd_data_wr : sel_fifo & hwr & lwr;
fifo4096x16 SECBUF1
(
	.clk(clk),
	.reset(fifo_reset),
	.data_in(fifo_data_in),
	.data_out(fifo_data_out),
	.rd(fifo_rd),
	.wr(fifo_wr),
	.full(fifo_full),
	.empty(fifo_empty),
	.last(fifo_last)
);
assign nrdy = pio_in & sel_fifo & fifo_empty;
assign data_out = (sel_fifo && rd ? fifo_data_out : sel_status ? (!dev && hdd_ena[0]) || (dev && hdd_ena[1]) ? {status,8'h00} : 16'h00_00 : sel_tfr && rd ? {tfr_out,8'h00} : 16'h00_00)
			   | (sel_intreq && rd ? {intreq,15'b000_0000_0000_0000} : 16'h00_00)				
			   | (sel_intena && rd ? {intena,15'b000_0000_0000_0000} : 16'h00_00)				
			   | (sel_gayleid && rd ? {gayleid,15'b000_0000_0000_0000} : 16'h00_00);
endmodule
module fifo4096x16
(
	input 	clk,		    		
	input 	reset,			   		
	input	[15:0] data_in,			
	output	reg [15:0] data_out,	
	input	rd,						
	input	wr,						
	output	full,					
	output	empty,					
	output	last					
);
reg 	[15:0] mem [4095:0];		
reg		[12:0] inptr;				
reg		[12:0] outptr;				
wire	empty_rd;					
reg		empty_wr;					
always @(posedge clk)
	if (wr)
		mem[inptr[11:0]] <= data_in;
always @(posedge clk)
	data_out <= mem[outptr[11:0]];
always @(posedge clk)
	if (reset)
		inptr <= 12'd0;
	else if (wr)
		inptr <= inptr + 12'd1;
always @(posedge clk)
	if (reset)
		outptr <= 0;
	else if (rd)
		outptr <= outptr + 13'd1;
assign empty_rd = inptr==outptr ? 1'b1 : 1'b0;
always @(posedge clk)
	empty_wr <= empty_rd;
assign empty = empty_rd | empty_wr;
assign full = inptr[12:8]!=outptr[12:8] ? 1'b1 : 1'b0;	
assign last = outptr[7:0] == 8'hFF ? 1'b1 : 1'b0;	
endmodule
