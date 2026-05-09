module ciab
(
	input 	clk,	  			
	input 	aen,		    	
	input	rd,					
	input	wr,					
	input 	reset, 				
	input 	[3:0] rs,	   		
	input 	[7:0] data_in,		
	output 	[7:0] data_out,		
	input 	tick,				
	input 	eclk,	   			
	input 	flag, 				
	output 	irq,	   			
	input	[5:3] porta_in, 	
	output 	[7:6] porta_out,	
	output	[7:0] portb_out		
);
	wire 	[7:0] icr_out;
	wire	[7:0] tmra_out;			
	wire	[7:0] tmrb_out;
	wire	[7:0] tmrd_out;	
	reg		[7:0] pa_out;
	reg		[7:0] pb_out;		
	wire	alrm;				
	wire	ta;					
	wire	tb;					
	wire	tmra_ovf;			
	reg		[7:0] sdr_latch;
	wire	[7:0] sdr_out;	
	reg		tick_del;			
	wire	pra,prb,ddra,ddrb,cra,talo,tahi,crb,tblo,tbhi,tdlo,tdme,tdhi,sdr,icrs;
	wire	enable;
assign enable = aen & (rd | wr);
assign	pra  = (enable && rs==4'h0) ? 1'b1 : 1'b0;
assign	prb  = (enable && rs==4'h1) ? 1'b1 : 1'b0;
assign	ddra = (enable && rs==4'h2) ? 1'b1 : 1'b0;
assign	ddrb = (enable && rs==4'h3) ? 1'b1 : 1'b0;
assign	talo = (enable && rs==4'h4) ? 1'b1 : 1'b0;
assign	tahi = (enable && rs==4'h5) ? 1'b1 : 1'b0;
assign	tblo = (enable && rs==4'h6) ? 1'b1 : 1'b0;
assign	tbhi = (enable && rs==4'h7) ? 1'b1 : 1'b0;
assign	tdlo = (enable && rs==4'h8) ? 1'b1 : 1'b0;
assign	tdme = (enable && rs==4'h9) ? 1'b1 : 1'b0;
assign	tdhi = (enable && rs==4'hA) ? 1'b1 : 1'b0;
assign	sdr  = (enable && rs==4'hC) ? 1'b1 : 1'b0;
assign	icrs = (enable && rs==4'hD) ? 1'b1 : 1'b0;
assign	cra  = (enable && rs==4'hE) ? 1'b1 : 1'b0;
assign	crb  = (enable && rs==4'hF) ? 1'b1 : 1'b0;
assign data_out = icr_out | tmra_out | tmrb_out | tmrd_out | sdr_out | pb_out | pa_out;
always @(posedge clk)
	if (reset)
		sdr_latch[7:0] <= 8'h00;
	else if (wr & sdr)
		sdr_latch[7:0] <= data_in[7:0];
assign sdr_out = (!wr && sdr) ? sdr_latch[7:0] : 8'h00;		
reg [5:3] porta_in2;
reg [7:0] regporta;
reg [7:0] ddrporta;
always @(posedge clk)
	porta_in2[5:3] <= porta_in[5:3];
always @(posedge clk)
	if (reset)
		regporta[7:0] <= 8'd0;
	else if (wr && pra)
		regporta[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		ddrporta[7:0] <= 8'd0;
	else if (wr && ddra)
 		ddrporta[7:0] <= data_in[7:0];
always @(wr or pra or porta_in2 or porta_out or ddra or ddrporta)
begin
	if (!wr && pra)
		pa_out[7:0] = {porta_out[7:6],porta_in2[5:3],3'b111};
	else if (!wr && ddra)
		pa_out[7:0] = ddrporta[7:0];
	else
		pa_out[7:0] = 8'h00;
end
assign porta_out[7:6] = (~ddrporta[7:6]) | regporta[7:6];	
reg [7:0] regportb;
reg [7:0] ddrportb;
always @(posedge clk)
	if (reset)
		regportb[7:0] <= 8'd0;
	else if (wr && prb)
		regportb[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		ddrportb[7:0] <= 8'd0;
	else if (wr && ddrb)
 		ddrportb[7:0] <= data_in[7:0];
always @(wr or prb or portb_out or ddrb or ddrportb)
begin
	if (!wr && prb)
		pb_out[7:0] = portb_out[7:0];
	else if (!wr && ddrb)
		pb_out[7:0] = ddrportb[7:0];
	else
		pb_out[7:0] = 8'h00;
end
assign portb_out[7:0] = (~ddrportb[7:0]) | regportb[7:0];	
always @(posedge clk)
	tick_del <= tick;
ciaint cnt
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.icrs(icrs),
	.ta(ta),
	.tb(tb),
	.alrm(alrm),
	.flag(flag),
	.ser(1'b0),
	.data_in(data_in),
	.data_out(icr_out),
	.irq(irq)
);
timera tmra
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(talo),
	.thi(tahi),
	.tcr(cra),
	.data_in(data_in),
	.data_out(tmra_out),
	.eclk(eclk),
	.tmra_ovf(tmra_ovf),
	.irq(ta) 
);
timerb tmrb
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(tblo),
	.thi(tbhi),
	.tcr(crb),
	.data_in(data_in),
	.data_out(tmrb_out),
	.eclk(eclk),
	.tmra_ovf(tmra_ovf),
	.irq(tb)
);
timerd tmrd 
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(tdlo),
	.tme(tdme),
	.thi(tdhi),
	.tcr(crb),
	.data_in(data_in),
	.data_out(tmrd_out),
	.count(tick & ~tick_del),
	.irq(alrm)
); 
endmodule
module ciaint
(
	input 	clk,	  			
	input	wr,					
	input 	reset, 				
	input 	icrs,				
	input	ta,					
	input	tb,				    
	input	alrm,	 			
	input 	flag, 				
	input 	ser,				
	input 	[7:0] data_in,		
	output 	[7:0] data_out,		
	output	irq					
);
reg  [4:0] icr = 5'd0;			
reg  [4:0] icrmask = 5'd0;		
assign data_out[7:0] = icrs && !wr ? {irq,2'b00,icr[4:0]} : 8'b0000_0000;
always @(posedge clk)
	if (reset)
		icrmask[4:0] <= 5'b0_0000;
	else if (icrs && wr)
	begin
		if (data_in[7])
			icrmask[4:0] <= icrmask[4:0] | data_in[4:0];
		else
			icrmask[4:0] <= icrmask[4:0] & (~data_in[4:0]);
	end
always @(posedge clk)
	if (reset)
		icr[4:0] <= 5'b0_0000;
	else if (icrs && !wr)
	begin
		icr[0] <= ta;			
		icr[1] <= tb;			
		icr[2] <= alrm;   		
		icr[3] <= ser;	 		
		icr[4] <= flag;			
	end
	else
	begin
		icr[0] <= icr[0] | ta;		
		icr[1] <= icr[1] | tb;		
		icr[2] <= icr[2] | alrm;	
		icr[3] <= icr[3] | ser;		
		icr[4] <= icr[4] | flag;	
	end
assign irq 	= (icrmask[0] & icr[0]) 
			| (icrmask[1] & icr[1])
			| (icrmask[2] & icr[2])
			| (icrmask[3] & icr[3])
			| (icrmask[4] & icr[4]);
endmodule
module timera
(
	input 	clk,	  				
	input	wr,						
	input 	reset, 					
	input 	tlo,					
	input	thi,		 			
	input	tcr,					
	input 	[7:0] data_in,			
	output 	[7:0] data_out,			
	input	eclk,	  				
	output	tmra_ovf,				
	output	spmode,					
	output	irq						
);
reg		[15:0] tmr;				
reg		[7:0] tmlh;				
reg		[7:0] tmll;				
reg		[6:0] tmcr;				
reg		forceload;				
wire	oneshot;				
wire	start;					
reg		thi_load;    			
wire	reload;					
wire	zero;					
wire	underflow;				
wire	count;					
assign count = eclk;
always @(posedge clk)
	if (reset)	
		tmcr[6:0] <= 7'd0;
	else if (tcr && wr)	
		tmcr[6:0] <= {data_in[6:5],1'b0,data_in[3:0]};
	else if (thi_load && oneshot)	
		tmcr[0] <= 1'd1;
	else if (underflow && oneshot) 
		tmcr[0] <= 1'd0;
always @(posedge clk)
	forceload <= tcr & wr & data_in[4];	
assign oneshot = tmcr[3];		
assign start = tmcr[0];			
assign spmode = tmcr[6];		
always @(posedge clk)
	if (reset)
		tmll[7:0] <= 8'b1111_1111;
	else if (tlo && wr)
		tmll[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		tmlh[7:0] <= 8'b1111_1111;
	else if (thi && wr)
		tmlh[7:0] <= data_in[7:0];
always @(posedge clk)
	thi_load <= thi & wr & (~start | oneshot);
assign reload = thi_load | forceload | underflow;
always @(posedge clk)
	if (reset)
		tmr[15:0] <= 16'hFF_FF;
	else if (reload)
		tmr[15:0] <= {tmlh[7:0],tmll[7:0]};
	else if (start && count)
		tmr[15:0] <= tmr[15:0] - 16'd1;
assign zero = ~|tmr;		
assign underflow = zero & start & count;
assign tmra_ovf = underflow;
assign irq = underflow;
assign data_out[7:0] = ({8{~wr&tlo}} & tmr[7:0]) 
					| ({8{~wr&thi}} & tmr[15:8])
					| ({8{~wr&tcr}} & {1'b0,tmcr[6:0]});		
endmodule
module timerb
(
	input 	clk,	  				
	input	wr,						
	input 	reset, 					
	input 	tlo,					
	input	thi,		 			
	input	tcr,					
	input 	[7:0] data_in,			
	output 	[7:0] data_out,			
	input	eclk,	  				
	input	tmra_ovf,				
	output	irq						
);
reg		[15:0] tmr;				
reg		[7:0] tmlh;				
reg		[7:0] tmll;				
reg		[6:0] tmcr;				
reg		forceload;				
wire	oneshot;				
wire	start;					
reg		thi_load; 				
wire	reload;					
wire	zero;					
wire	underflow;				
wire	count;					
assign count = tmcr[6] ? tmra_ovf : eclk;
always @(posedge clk)
	if (reset)	
		tmcr[6:0] <= 7'd0;
	else if (tcr && wr)	
		tmcr[6:0] <= {data_in[6:5],1'b0,data_in[3:0]};
	else if (thi_load && oneshot)	
		tmcr[0] <= 1'd1;
	else if (underflow && oneshot) 
		tmcr[0] <= 1'd0;
always @(posedge clk)
	forceload <= tcr & wr & data_in[4];	
assign oneshot = tmcr[3];					
assign start = tmcr[0];					
always @(posedge clk)
	if (reset)
		tmll[7:0] <= 8'b1111_1111;
	else if (tlo && wr)
		tmll[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		tmlh[7:0] <= 8'b1111_1111;
	else if (thi && wr)
		tmlh[7:0] <= data_in[7:0];
always @(posedge clk)
	thi_load <= thi & wr & (~start | oneshot);
assign reload = thi_load | forceload | underflow;
always @(posedge clk)
	if (reset)
		tmr[15:0] <= 16'hFF_FF;
	else if (reload)
		tmr[15:0] <= {tmlh[7:0],tmll[7:0]};
	else if (start && count)
		tmr[15:0] <= tmr[15:0] - 16'd1;
assign zero = ~|tmr;		
assign underflow = zero & start & count;
assign irq = underflow;
assign data_out[7:0] = ({8{~wr&tlo}} & tmr[7:0]) 
					| ({8{~wr&thi}} & tmr[15:8])
					| ({8{~wr&tcr}} & {1'b0,tmcr[6:0]});		
endmodule
module timerd
(
	input 	clk,	  				
	input	wr,						
	input 	reset, 					
	input 	tlo,					
	input 	tme,					
	input	thi,		 			
	input	tcr,					
	input 	[7:0] data_in,			
	output 	reg [7:0] data_out,		
	input	count,	  				
	output	irq						
);
	reg		latch_ena;				
	reg 	count_ena;				
	reg		crb7;					
	reg		[23:0] tod;				
	reg		[23:0] alarm;			
	reg		[23:0] tod_latch;		
	reg		count_del;				
always @(posedge clk)
	if (reset)
		latch_ena <= 1'd1;
	else if (!wr)
	begin
		if (thi) 
			latch_ena <= 1'd0;
		else if (!thi) 
			latch_ena <= 1'd1;
	end
always @(posedge clk)
	if (latch_ena)
		tod_latch[23:0] <= tod[23:0];
always @(wr or tlo or tme or thi or tcr or tod or tod_latch or crb7)
	if (!wr)
	begin
		if (thi) 
			data_out[7:0] = tod_latch[23:16];
		else if (tme) 
			data_out[7:0] = tod_latch[15:8];
		else if (tlo) 
			data_out[7:0] = tod_latch[7:0];
		else if (tcr) 
			data_out[7:0] = {crb7,7'b000_0000};
		else
			data_out[7:0] = 8'd0;
	end
	else
		data_out[7:0] = 8'd0;  
always @(posedge clk)
	if (reset)
		count_ena <= 1'd1;
	else if (wr && !crb7) 
	begin
		if (thi || tme) 
			count_ena <= 1'd0;
		else if (tlo) 
			count_ena <= 1'd1;			
	end
always @(posedge clk)
	if (reset) 
	begin
		tod[23:0] <= 24'd0;
	end
	else if (wr && !crb7) 
	begin
		if (tlo)
			tod[7:0] <= data_in[7:0];
		if (tme)
			tod[15:8] <= data_in[7:0];
		if (thi)
			tod[23:16] <= data_in[7:0];
	end
	else if (count_ena && count)
		tod[23:0] <= tod[23:0] + 24'd1;
always @(posedge clk)
	if (reset) 
	begin
		alarm[7:0] <= 8'b1111_1111;
		alarm[15:8] <= 8'b1111_1111;
		alarm[23:16] <= 8'b1111_1111;
	end
	else if (wr && crb7) 
	begin
		if (tlo)
			alarm[7:0] <= data_in[7:0];
		if (tme)
			alarm[15:8] <= data_in[7:0];
		if (thi)
			alarm[23:16] <= data_in[7:0];
	end
always @(posedge clk)
	if (reset)
		crb7 <= 1'd0;
	else if (wr && tcr)
		crb7 <= data_in[7];
always @(posedge clk)
	count_del <= count & count_ena;
assign irq = (tod[23:0]==alarm[23:0] && count_del) ? 1'b1 : 1'b0;
endmodule
module ciaa
(
	input 	clk,	  			
	input 	aen,		    	
	input	rd,					
	input	wr,					
	input 	reset, 				
	input 	[3:0] rs,	   		
	input 	[7:0] data_in,		
	output 	[7:0] data_out,		
	input 	tick,				
	input 	eclk,    			
	output 	irq,	   			
	input	[7:2] porta_in, 	
	output 	[1:0] porta_out,	
	output	kbdrst,				
	inout	kbddat,				
	inout	kbdclk,				
	input	keyboard_disabled,	
  input kbd_mouse_strobe,
  input [1:0] kbd_mouse_type,
  input [7:0] kbd_mouse_data,
	output	[7:0] osd_ctrl,		
	output	_lmb,
	output	_rmb,
	output	[5:0] _joy2,
  output  aflock,       
	output	freeze,				
	input	disk_led,			
  output [5:0] mou_emu,
  output [5:0] joy_emu
);
wire 	[7:0] icr_out;
wire	[7:0] tmra_out;			
wire	[7:0] tmrb_out;
wire	[7:0] tmrd_out;
wire	[7:0] sdr_out;	
reg		[7:0] pa_out;
reg		[7:0] pb_out;
wire  [7:0] portb_out;
wire	alrm;				
wire	ta;					
wire	tb;					
wire	tmra_ovf;			
wire	spmode;				
wire	ser_tx_irq;			
reg		[3:0] ser_tx_cnt; 	
reg		ser_tx_run;			
reg		tick_del;			
wire	pra,prb,ddra,ddrb,cra,talo,tahi,crb,tblo,tbhi,tdlo,tdme,tdhi,icrs,sdr;
wire	enable;
assign enable = aen & (rd | wr);
assign	pra  = (enable && rs==4'h0) ? 1'b1 : 1'b0;
assign	prb  = (enable && rs==4'h1) ? 1'b1 : 1'b0;
assign	ddra = (enable && rs==4'h2) ? 1'b1 : 1'b0;
assign  ddrb = (enable && rs==4'h3) ? 1'b1 : 1'b0;
assign	talo = (enable && rs==4'h4) ? 1'b1 : 1'b0;
assign	tahi = (enable && rs==4'h5) ? 1'b1 : 1'b0;
assign	tblo = (enable && rs==4'h6) ? 1'b1 : 1'b0;
assign	tbhi = (enable && rs==4'h7) ? 1'b1 : 1'b0;
assign	tdlo = (enable && rs==4'h8) ? 1'b1 : 1'b0;
assign	tdme = (enable && rs==4'h9) ? 1'b1 : 1'b0;
assign	tdhi = (enable && rs==4'hA) ? 1'b1 : 1'b0;
assign	sdr  = (enable && rs==4'hC) ? 1'b1 : 1'b0;
assign	icrs = (enable && rs==4'hD) ? 1'b1 : 1'b0;
assign	cra  = (enable && rs==4'hE) ? 1'b1 : 1'b0;
assign	crb  = (enable && rs==4'hF) ? 1'b1 : 1'b0;
assign data_out = icr_out | tmra_out | tmrb_out | tmrd_out | sdr_out | pb_out | pa_out;
wire	keystrobe;
wire	keyack;
wire	[7:0] keydat;
reg		[7:0] sdr_latch;
`ifdef MINIMIG_PS2_KEYBOARD
ps2keyboard	kbd1
(
	.clk(clk),
	.reset(reset),
	.ps2kdat(kbddat),
	.ps2kclk(kbdclk),
	.leda(~porta_out[1]),	
	.ledb(disk_led),		
  .aflock(aflock),
	.kbdrst(kbdrst),
	.keydat(keydat[7:0]),
	.keystrobe(keystrobe),
	.keyack(keyack),
	.osd_ctrl(osd_ctrl),
	._lmb(_lmb),
	._rmb(_rmb),
	._joy2(_joy2),
	.freeze(freeze),
  .mou_emu(mou_emu),
  .joy_emu(joy_emu)
);
always @(posedge clk)
	if (reset)
		sdr_latch[7:0] <= 8'h00;
	else if (keystrobe & ~keyboard_disabled)
		sdr_latch[7:0] <= ~{keydat[6:0],keydat[7]};
	else if (wr & sdr)
		sdr_latch[7:0] <= data_in[7:0];
`else
assign kbdrst = 1'b0;
assign _lmb = 1'b1;
assign _rmb = 1'b1;
assign _joy2 = 6'b11_1111;
assign joy_emu = 6'b11_1111;
assign mou_emu = 6'b11_1111;
assign freeze = 1'b0;
assign aflock = 1'b0;
reg [7:0] osd_ctrl_reg;
reg keystrobe_reg;
assign keystrobe = keystrobe_reg;
assign osd_ctrl = osd_ctrl_reg;
reg kbd_mouse_strobeD, kbd_mouse_strobeD2;
always @(posedge clk)
  kbd_mouse_strobeD <= kbd_mouse_strobe;
always @(negedge clk) begin
  kbd_mouse_strobeD2 <= kbd_mouse_strobeD;
  keystrobe_reg <= kbd_mouse_strobeD && !kbd_mouse_strobeD2;
end
always @(posedge clk) begin
  if (reset) begin
    sdr_latch[7:0] <= 8'h00;
    osd_ctrl_reg[7:0] <= 8'd0;
   end else begin
    if (keystrobe && (kbd_mouse_type == 2) && ~keyboard_disabled)
      sdr_latch[7:0] <= ~{kbd_mouse_data[6:0],kbd_mouse_data[7]};
    else if (wr & sdr)
      sdr_latch[7:0] <= data_in[7:0];
    if(keystrobe && ((kbd_mouse_type == 2) || (kbd_mouse_type == 3)))
      osd_ctrl_reg[7:0] <= kbd_mouse_data;
  end
end
`endif
assign sdr_out = (!wr && sdr) ? sdr_latch[7:0] : 8'h00;
assign keyack = (!wr && sdr) ? 1'b1 : 1'b0;
always @(posedge clk)
	if (reset || !spmode) 
		ser_tx_run <= 0;
	else if (sdr && wr) 
		ser_tx_run <= 1;
	else if (ser_tx_irq) 
		ser_tx_run <= 0;
always @(posedge clk)
	if (!ser_tx_run)
		ser_tx_cnt <= 4'd0;
	else if (tmra_ovf) 
		ser_tx_cnt <= ser_tx_cnt + 4'd1;
assign ser_tx_irq = &ser_tx_cnt & tmra_ovf; 
reg [7:2] porta_in2;
reg [1:0] regporta;
reg [7:0] ddrporta;
always @(posedge clk)
	porta_in2[7:2] <= porta_in[7:2];
always @(posedge clk)
	if (reset)
		regporta[1:0] <= 2'd0;
	else if (wr && pra)
		regporta[1:0] <= data_in[1:0];
always @(posedge clk)
	if (reset)
		ddrporta[7:0] <= 8'd0;
	else if (wr && ddra)
 		ddrporta[7:0] <= data_in[7:0];
always @(wr or pra or porta_in2 or porta_out or ddra or ddrporta)
begin
	if (!wr && pra)
		pa_out[7:0] = {porta_in2[7:2],porta_out[1:0]};
	else if (!wr && ddra)
		pa_out[7:0] = ddrporta[7:0];
	else
		pa_out[7:0] = 8'h00;
end
assign porta_out[1:0] = (~ddrporta[1:0]) | regporta[1:0];
reg [7:0] regportb;
reg [7:0] ddrportb;
always @(posedge clk)
  if (reset)
    regportb[7:0] <= 8'd0;
  else if (wr && prb)
    regportb[7:0] <= (data_in[7:0]);
always @(posedge clk)
  if (reset)
    ddrportb[7:0] <= 8'd0;
  else if (wr && ddrb)
    ddrportb[7:0] <= (data_in[7:0]);
always @(wr or prb or portb_out or ddrb or ddrportb)
begin
  if (!wr && prb)
    pb_out[7:0] = (portb_out[7:0]);
  else if (!wr && ddrb)
    pb_out[7:0] = (ddrportb[7:0]);
  else
    pb_out[7:0] = 8'h00;
end
assign portb_out[7:0] = ((~ddrportb[7:0]) | (regportb[7:0]));
always @(posedge clk)
	tick_del <= tick;
ciaint cnt 
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.icrs(icrs),
	.ta(ta),
	.tb(tb),
	.alrm(alrm),
	.flag(1'b0),
	.ser(keystrobe & ~keyboard_disabled | ser_tx_irq),
	.data_in(data_in),
	.data_out(icr_out),
	.irq(irq)	
);
timera tmra 
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(talo),
	.thi(tahi),
	.tcr(cra),
	.data_in(data_in),
	.data_out(tmra_out),
	.eclk(eclk),
	.spmode(spmode),
	.tmra_ovf(tmra_ovf),
	.irq(ta) 
);
timerb tmrb 
(	
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(tblo),
	.thi(tbhi),
	.tcr(crb),
	.data_in(data_in),
	.data_out(tmrb_out),
	.eclk(eclk),
	.tmra_ovf(tmra_ovf),
	.irq(tb) 
);
timerd tmrd
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(tdlo),
	.tme(tdme),
	.thi(tdhi),
	.tcr(crb),
	.data_in(data_in),
	.data_out(tmrd_out),
	.count(tick & ~tick_del),
	.irq(alrm)	
); 
endmodule
module ciab
(
	input 	clk,	  			
	input 	aen,		    	
	input	rd,					
	input	wr,					
	input 	reset, 				
	input 	[3:0] rs,	   		
	input 	[7:0] data_in,		
	output 	[7:0] data_out,		
	input 	tick,				
	input 	eclk,	   			
	input 	flag, 				
	output 	irq,	   			
	input	[5:3] porta_in, 	
	output 	[7:6] porta_out,	
	output	[7:0] portb_out		
);
	wire 	[7:0] icr_out;
	wire	[7:0] tmra_out;			
	wire	[7:0] tmrb_out;
	wire	[7:0] tmrd_out;	
	reg		[7:0] pa_out;
	reg		[7:0] pb_out;		
	wire	alrm;				
	wire	ta;					
	wire	tb;					
	wire	tmra_ovf;			
	reg		[7:0] sdr_latch;
	wire	[7:0] sdr_out;	
	reg		tick_del;			
	wire	pra,prb,ddra,ddrb,cra,talo,tahi,crb,tblo,tbhi,tdlo,tdme,tdhi,sdr,icrs;
	wire	enable;
assign enable = aen & (rd | wr);
assign	pra  = (enable && rs==4'h0) ? 1'b1 : 1'b0;
assign	prb  = (enable && rs==4'h1) ? 1'b1 : 1'b0;
assign	ddra = (enable && rs==4'h2) ? 1'b1 : 1'b0;
assign	ddrb = (enable && rs==4'h3) ? 1'b1 : 1'b0;
assign	talo = (enable && rs==4'h4) ? 1'b1 : 1'b0;
assign	tahi = (enable && rs==4'h5) ? 1'b1 : 1'b0;
assign	tblo = (enable && rs==4'h6) ? 1'b1 : 1'b0;
assign	tbhi = (enable && rs==4'h7) ? 1'b1 : 1'b0;
assign	tdlo = (enable && rs==4'h8) ? 1'b1 : 1'b0;
assign	tdme = (enable && rs==4'h9) ? 1'b1 : 1'b0;
assign	tdhi = (enable && rs==4'hA) ? 1'b1 : 1'b0;
assign	sdr  = (enable && rs==4'hC) ? 1'b1 : 1'b0;
assign	icrs = (enable && rs==4'hD) ? 1'b1 : 1'b0;
assign	cra  = (enable && rs==4'hE) ? 1'b1 : 1'b0;
assign	crb  = (enable && rs==4'hF) ? 1'b1 : 1'b0;
assign data_out = icr_out | tmra_out | tmrb_out | tmrd_out | sdr_out | pb_out | pa_out;
always @(posedge clk)
	if (reset)
		sdr_latch[7:0] <= 8'h00;
	else if (wr & sdr)
		sdr_latch[7:0] <= data_in[7:0];
assign sdr_out = (!wr && sdr) ? sdr_latch[7:0] : 8'h00;		
reg [5:3] porta_in2;
reg [7:0] regporta;
reg [7:0] ddrporta;
always @(posedge clk)
	porta_in2[5:3] <= porta_in[5:3];
always @(posedge clk)
	if (reset)
		regporta[7:0] <= 8'd0;
	else if (wr && pra)
		regporta[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		ddrporta[7:0] <= 8'd0;
	else if (wr && ddra)
 		ddrporta[7:0] <= data_in[7:0];
always @(wr or pra or porta_in2 or porta_out or ddra or ddrporta)
begin
	if (!wr && pra)
		pa_out[7:0] = {porta_out[7:6],porta_in2[5:3],3'b111};
	else if (!wr && ddra)
		pa_out[7:0] = ddrporta[7:0];
	else
		pa_out[7:0] = 8'h00;
end
assign porta_out[7:6] = (~ddrporta[7:6]) | regporta[7:6];	
reg [7:0] regportb;
reg [7:0] ddrportb;
always @(posedge clk)
	if (reset)
		regportb[7:0] <= 8'd0;
	else if (wr && prb)
		regportb[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		ddrportb[7:0] <= 8'd0;
	else if (wr && ddrb)
 		ddrportb[7:0] <= data_in[7:0];
always @(wr or prb or portb_out or ddrb or ddrportb)
begin
	if (!wr && prb)
		pb_out[7:0] = portb_out[7:0];
	else if (!wr && ddrb)
		pb_out[7:0] = ddrportb[7:0];
	else
		pb_out[7:0] = 8'h00;
end
assign portb_out[7:0] = (~ddrportb[7:0]) | regportb[7:0];	
always @(posedge clk)
	tick_del <= tick;
ciaint cnt
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.icrs(icrs),
	.ta(ta),
	.tb(tb),
	.alrm(alrm),
	.flag(flag),
	.ser(1'b0),
	.data_in(data_in),
	.data_out(icr_out),
	.irq(irq)
);
timera tmra
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(talo),
	.thi(tahi),
	.tcr(cra),
	.data_in(data_in),
	.data_out(tmra_out),
	.eclk(eclk),
	.tmra_ovf(tmra_ovf),
	.irq(ta) 
);
timerb tmrb
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(tblo),
	.thi(tbhi),
	.tcr(crb),
	.data_in(data_in),
	.data_out(tmrb_out),
	.eclk(eclk),
	.tmra_ovf(tmra_ovf),
	.irq(tb)
);
timerd tmrd 
(
	.clk(clk),
	.wr(wr),
	.reset(reset),
	.tlo(tdlo),
	.tme(tdme),
	.thi(tdhi),
	.tcr(crb),
	.data_in(data_in),
	.data_out(tmrd_out),
	.count(tick & ~tick_del),
	.irq(alrm)
); 
endmodule
module ciaint
(
	input 	clk,	  			
	input	wr,					
	input 	reset, 				
	input 	icrs,				
	input	ta,					
	input	tb,				    
	input	alrm,	 			
	input 	flag, 				
	input 	ser,				
	input 	[7:0] data_in,		
	output 	[7:0] data_out,		
	output	irq					
);
reg  [4:0] icr = 5'd0;			
reg  [4:0] icrmask = 5'd0;		
assign data_out[7:0] = icrs && !wr ? {irq,2'b00,icr[4:0]} : 8'b0000_0000;
always @(posedge clk)
	if (reset)
		icrmask[4:0] <= 5'b0_0000;
	else if (icrs && wr)
	begin
		if (data_in[7])
			icrmask[4:0] <= icrmask[4:0] | data_in[4:0];
		else
			icrmask[4:0] <= icrmask[4:0] & (~data_in[4:0]);
	end
always @(posedge clk)
	if (reset)
		icr[4:0] <= 5'b0_0000;
	else if (icrs && !wr)
	begin
		icr[0] <= ta;			
		icr[1] <= tb;			
		icr[2] <= alrm;   		
		icr[3] <= ser;	 		
		icr[4] <= flag;			
	end
	else
	begin
		icr[0] <= icr[0] | ta;		
		icr[1] <= icr[1] | tb;		
		icr[2] <= icr[2] | alrm;	
		icr[3] <= icr[3] | ser;		
		icr[4] <= icr[4] | flag;	
	end
assign irq 	= (icrmask[0] & icr[0]) 
			| (icrmask[1] & icr[1])
			| (icrmask[2] & icr[2])
			| (icrmask[3] & icr[3])
			| (icrmask[4] & icr[4]);
endmodule
module timera
(
	input 	clk,	  				
	input	wr,						
	input 	reset, 					
	input 	tlo,					
	input	thi,		 			
	input	tcr,					
	input 	[7:0] data_in,			
	output 	[7:0] data_out,			
	input	eclk,	  				
	output	tmra_ovf,				
	output	spmode,					
	output	irq						
);
reg		[15:0] tmr;				
reg		[7:0] tmlh;				
reg		[7:0] tmll;				
reg		[6:0] tmcr;				
reg		forceload;				
wire	oneshot;				
wire	start;					
reg		thi_load;    			
wire	reload;					
wire	zero;					
wire	underflow;				
wire	count;					
assign count = eclk;
always @(posedge clk)
	if (reset)	
		tmcr[6:0] <= 7'd0;
	else if (tcr && wr)	
		tmcr[6:0] <= {data_in[6:5],1'b0,data_in[3:0]};
	else if (thi_load && oneshot)	
		tmcr[0] <= 1'd1;
	else if (underflow && oneshot) 
		tmcr[0] <= 1'd0;
always @(posedge clk)
	forceload <= tcr & wr & data_in[4];	
assign oneshot = tmcr[3];		
assign start = tmcr[0];			
assign spmode = tmcr[6];		
always @(posedge clk)
	if (reset)
		tmll[7:0] <= 8'b1111_1111;
	else if (tlo && wr)
		tmll[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		tmlh[7:0] <= 8'b1111_1111;
	else if (thi && wr)
		tmlh[7:0] <= data_in[7:0];
always @(posedge clk)
	thi_load <= thi & wr & (~start | oneshot);
assign reload = thi_load | forceload | underflow;
always @(posedge clk)
	if (reset)
		tmr[15:0] <= 16'hFF_FF;
	else if (reload)
		tmr[15:0] <= {tmlh[7:0],tmll[7:0]};
	else if (start && count)
		tmr[15:0] <= tmr[15:0] - 16'd1;
assign zero = ~|tmr;		
assign underflow = zero & start & count;
assign tmra_ovf = underflow;
assign irq = underflow;
assign data_out[7:0] = ({8{~wr&tlo}} & tmr[7:0]) 
					| ({8{~wr&thi}} & tmr[15:8])
					| ({8{~wr&tcr}} & {1'b0,tmcr[6:0]});		
endmodule
module timerb
(
	input 	clk,	  				
	input	wr,						
	input 	reset, 					
	input 	tlo,					
	input	thi,		 			
	input	tcr,					
	input 	[7:0] data_in,			
	output 	[7:0] data_out,			
	input	eclk,	  				
	input	tmra_ovf,				
	output	irq						
);
reg		[15:0] tmr;				
reg		[7:0] tmlh;				
reg		[7:0] tmll;				
reg		[6:0] tmcr;				
reg		forceload;				
wire	oneshot;				
wire	start;					
reg		thi_load; 				
wire	reload;					
wire	zero;					
wire	underflow;				
wire	count;					
assign count = tmcr[6] ? tmra_ovf : eclk;
always @(posedge clk)
	if (reset)	
		tmcr[6:0] <= 7'd0;
	else if (tcr && wr)	
		tmcr[6:0] <= {data_in[6:5],1'b0,data_in[3:0]};
	else if (thi_load && oneshot)	
		tmcr[0] <= 1'd1;
	else if (underflow && oneshot) 
		tmcr[0] <= 1'd0;
always @(posedge clk)
	forceload <= tcr & wr & data_in[4];	
assign oneshot = tmcr[3];					
assign start = tmcr[0];					
always @(posedge clk)
	if (reset)
		tmll[7:0] <= 8'b1111_1111;
	else if (tlo && wr)
		tmll[7:0] <= data_in[7:0];
always @(posedge clk)
	if (reset)
		tmlh[7:0] <= 8'b1111_1111;
	else if (thi && wr)
		tmlh[7:0] <= data_in[7:0];
always @(posedge clk)
	thi_load <= thi & wr & (~start | oneshot);
assign reload = thi_load | forceload | underflow;
always @(posedge clk)
	if (reset)
		tmr[15:0] <= 16'hFF_FF;
	else if (reload)
		tmr[15:0] <= {tmlh[7:0],tmll[7:0]};
	else if (start && count)
		tmr[15:0] <= tmr[15:0] - 16'd1;
assign zero = ~|tmr;		
assign underflow = zero & start & count;
assign irq = underflow;
assign data_out[7:0] = ({8{~wr&tlo}} & tmr[7:0]) 
					| ({8{~wr&thi}} & tmr[15:8])
					| ({8{~wr&tcr}} & {1'b0,tmcr[6:0]});		
endmodule
module timerd
(
	input 	clk,	  				
	input	wr,						
	input 	reset, 					
	input 	tlo,					
	input 	tme,					
	input	thi,		 			
	input	tcr,					
	input 	[7:0] data_in,			
	output 	reg [7:0] data_out,		
	input	count,	  				
	output	irq						
);
	reg		latch_ena;				
	reg 	count_ena;				
	reg		crb7;					
	reg		[23:0] tod;				
	reg		[23:0] alarm;			
	reg		[23:0] tod_latch;		
	reg		count_del;				
always @(posedge clk)
	if (reset)
		latch_ena <= 1'd1;
	else if (!wr)
	begin
		if (thi) 
			latch_ena <= 1'd0;
		else if (!thi) 
			latch_ena <= 1'd1;
	end
always @(posedge clk)
	if (latch_ena)
		tod_latch[23:0] <= tod[23:0];
always @(wr or tlo or tme or thi or tcr or tod or tod_latch or crb7)
	if (!wr)
	begin
		if (thi) 
			data_out[7:0] = tod_latch[23:16];
		else if (tme) 
			data_out[7:0] = tod_latch[15:8];
		else if (tlo) 
			data_out[7:0] = tod_latch[7:0];
		else if (tcr) 
			data_out[7:0] = {crb7,7'b000_0000};
		else
			data_out[7:0] = 8'd0;
	end
	else
		data_out[7:0] = 8'd0;  
always @(posedge clk)
	if (reset)
		count_ena <= 1'd1;
	else if (wr && !crb7) 
	begin
		if (thi || tme) 
			count_ena <= 1'd0;
		else if (tlo) 
			count_ena <= 1'd1;			
	end
always @(posedge clk)
	if (reset) 
	begin
		tod[23:0] <= 24'd0;
	end
	else if (wr && !crb7) 
	begin
		if (tlo)
			tod[7:0] <= data_in[7:0];
		if (tme)
			tod[15:8] <= data_in[7:0];
		if (thi)
			tod[23:16] <= data_in[7:0];
	end
	else if (count_ena && count)
		tod[23:0] <= tod[23:0] + 24'd1;
always @(posedge clk)
	if (reset) 
	begin
		alarm[7:0] <= 8'b1111_1111;
		alarm[15:8] <= 8'b1111_1111;
		alarm[23:16] <= 8'b1111_1111;
	end
	else if (wr && crb7) 
	begin
		if (tlo)
			alarm[7:0] <= data_in[7:0];
		if (tme)
			alarm[15:8] <= data_in[7:0];
		if (thi)
			alarm[23:16] <= data_in[7:0];
	end
always @(posedge clk)
	if (reset)
		crb7 <= 1'd0;
	else if (wr && tcr)
		crb7 <= data_in[7];
always @(posedge clk)
	count_del <= count & count_ena;
assign irq = (tod[23:0]==alarm[23:0] && count_del) ? 1'b1 : 1'b0;
endmodule
