`define ACCUM	2
`define COEFWIDTH	8
`define DATAWIDTH	8
module biquad
	(
	clk,				
	nreset,			
	x,				
	valid,			
	a11,				
	a12,				
	b10,				
	b11,				
	b12,				
	yout				
	);
input 								clk;
input 								nreset;
input	[`DATAWIDTH-1:0]				x;
input								valid;
input	[`COEFWIDTH-1:0]				a11;
input	[`COEFWIDTH-1:0]				a12;
input	[`COEFWIDTH-1:0]				b10;
input	[`COEFWIDTH-1:0]				b11;
input	[`COEFWIDTH-1:0]				b12;
output	[`DATAWIDTH-1:0]				yout;
reg		[`DATAWIDTH-1:0]				xvalid;
reg		[`DATAWIDTH-1:0]				xm1;
reg		[`DATAWIDTH-1:0]				xm2;
reg		[`DATAWIDTH-1:0]				xm3;
reg		[`DATAWIDTH-1:0]				xm4;
reg		[`DATAWIDTH-1:0]				xm5;
reg		[`DATAWIDTH+3+`ACCUM:0]			sumb10reg;
reg		[`DATAWIDTH+3+`ACCUM:0]			sumb11reg;
reg		[`DATAWIDTH+3+`ACCUM:0]			sumb12reg;
reg		[`DATAWIDTH+3+`ACCUM:0]			suma12reg;
reg		[`DATAWIDTH+3:0]				y;
reg		[`DATAWIDTH-1:0]				yout;
wire		[`COEFWIDTH-1:0]				sa11;
wire		[`COEFWIDTH-1:0]				sa12;
wire		[`COEFWIDTH-1:0]				sb10;
wire		[`COEFWIDTH-1:0]				sb11;
wire		[`COEFWIDTH-1:0]				sb12;
wire		[`DATAWIDTH-2:0]				tempsum;
wire		[`DATAWIDTH+3+`ACCUM:0]			tempsum2;
wire		[`DATAWIDTH + `COEFWIDTH - 3:0]		mb10out;
wire		[`DATAWIDTH+3+`ACCUM:0]			sumb10;
wire		[`DATAWIDTH + `COEFWIDTH - 3:0]		mb11out;
wire		[`DATAWIDTH+3+`ACCUM:0]			sumb11;
wire		[`DATAWIDTH + `COEFWIDTH - 3:0]		mb12out;
wire		[`DATAWIDTH+3+`ACCUM:0]			sumb12;
wire		[`DATAWIDTH + `COEFWIDTH + 1:0] 	ma12out;
wire		[`DATAWIDTH+3+`ACCUM:0]			suma12;
wire		[`DATAWIDTH + `COEFWIDTH + 1:0] 	ma11out;
wire		[`DATAWIDTH+3+`ACCUM:0]			suma11;
wire		[`DATAWIDTH+2:0]				sy;
wire		[`DATAWIDTH-1:0]				olimit;
assign sa11 = a11[`COEFWIDTH-1] ? (-a11) : a11;
assign sa12 = a12[`COEFWIDTH-1] ? (-a12) : a12;
assign sb10 = b10[`COEFWIDTH-1] ? (-b10) : b10;
assign sb11 = b11[`COEFWIDTH-1] ? (-b11) : b11;
assign sb12 = b12[`COEFWIDTH-1] ? (-b12) : b12;
assign tempsum = -xvalid[`DATAWIDTH-2:0];
assign tempsum2 = -{4'b0000,mb10out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]};
always @(posedge clk or negedge nreset)
begin
if ( ~nreset )
  begin
    xvalid <= 0;
    xm1 <= 0;
    xm2 <= 0;
    xm3 <= 0;
    xm4 <= 0;
    xm5 <= 0;
  end
else
  begin
    xvalid <= valid ? x : xvalid;
    xm1 <= valid ? (xvalid[`DATAWIDTH-1] ? ({xvalid[`DATAWIDTH-1],tempsum}) : {xvalid}) : xm1;
    xm2 <= valid ? xm1 : xm2;
    xm3 <= valid ? xm2 : xm3;
    xm4 <= valid ? xm3 : xm4;
    xm5 <= valid ? xm4 : xm5;
  end
end
multb multb10(.a(sb10[`COEFWIDTH-2:0]),.b(xm1[`DATAWIDTH-2:0]),.r(mb10out));
assign sumb10 = (b10[`COEFWIDTH-1] ^ xm1[`DATAWIDTH-1]) ? (tempsum2) : ({4'b0000,mb10out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]});
multb multb11(.a(sb11[`COEFWIDTH-2:0]),.b(xm3[`DATAWIDTH-2:0]),.r(mb11out));
assign sumb11 = (b11[`COEFWIDTH-1] ^ xm3[`DATAWIDTH-1]) ? (sumb10reg - {4'b0000,mb11out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]}) : 
     (sumb10reg + {4'b0000,mb11out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]});
multb multb12(.a(sb12[`COEFWIDTH-2:0]),.b(xm5[`DATAWIDTH-2:0]),.r(mb12out));
assign sumb12 = (b12[`COEFWIDTH-1] ^ xm5[`DATAWIDTH-1]) ? (sumb11reg - {4'b0000,mb12out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]}) : 
     (sumb11reg + {4'b0000,mb12out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]});
assign sy = y[`DATAWIDTH+3] ? (~y + 1) : y;
multa multa12(.a(sa12[`COEFWIDTH-2:0]),.b(sy[`DATAWIDTH+2:0]),.r(ma12out));
assign suma12 = (a12[`COEFWIDTH-1] ^ y[`DATAWIDTH+3]) ? (sumb12reg - {1'b0,ma12out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]}) : 
     (sumb12reg + {1'b0,ma12out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]});
multa multa11(.a(sa11[`COEFWIDTH-2:0]),.b(sy[`DATAWIDTH+2:0]),.r(ma11out));
assign suma11 = (a11[`COEFWIDTH-1] ^ y[`DATAWIDTH+3]) ? (suma12reg - {1'b0,ma11out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]}) : 
     (suma12reg + {1'b0,ma11out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]});
assign olimit = {y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],
				~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3]};
always @(posedge clk or negedge nreset)
begin
if ( ~nreset )
  begin
    sumb10reg <= 0;
    sumb11reg <= 0;
    sumb12reg <= 0;
    suma12reg <= 0;
    y <= 0;
    yout <= 0;
  end
else
  begin
    sumb10reg <= valid ? (sumb10) : (sumb10reg);
    sumb11reg <= valid ? (sumb11) : (sumb11reg);
    sumb12reg <= valid ? (sumb12) : (sumb12reg);
    suma12reg <= valid ? (suma12) : (suma12reg);
    y <= valid ? suma11[`DATAWIDTH+3+`ACCUM:`ACCUM] : y;
    yout <= valid ? (( (&y[`DATAWIDTH+3:`DATAWIDTH-1]) | (~|y[`DATAWIDTH+3:`DATAWIDTH-1])  ) ? 
		(y[`DATAWIDTH-1:0]) : (olimit)) : (yout);
  end
end
endmodule
module coefio
	(
	clk_i,
	rst_i,
	we_i,	
	stb_i,
	ack_o,
	dat_i,
	dat_o,
	adr_i,
	a11,
	a12,
	b10,
	b11,
	b12
	);
input 		clk_i;
input 		rst_i;
input		we_i;
input		stb_i;
output		ack_o;
input	[15:0]	dat_i;
output	[15:0]	dat_o;
input	[2:0]	adr_i;
output	[15:0]	a11;
output	[15:0]	a12;
output	[15:0]	b10;
output	[15:0]	b11;
output	[15:0]	b12;
reg	[15:0]	a11;
reg	[15:0]	a12;
reg	[15:0]	b10;
reg	[15:0]	b11;
reg	[15:0]	b12;
wire		ack_o;
wire		sel_a11;
wire		sel_a12;
wire		sel_b10;
wire		sel_b11;
wire		sel_b12;
assign sel_a11 = (adr_i == 3'b000);
assign sel_a12 = (adr_i == 3'b001);
assign sel_b10 = (adr_i == 3'b010);
assign sel_b11 = (adr_i == 3'b011);
assign sel_b12 = (adr_i == 3'b100);
assign ack_o = stb_i;
always @(posedge clk_i or posedge rst_i)
if ( rst_i )
  begin
    a11 <= 15'b11111111;
    a12 <= 15'b11111;
    b10 <= 15'b1111111;
    b11 <= 15'b11;
    b12 <= 15'b11111111;
  end
else
  begin
    a11 <= (stb_i & we_i & sel_a11) ? (dat_i) : (a11);
    a12 <= (stb_i & we_i & sel_a12) ? (dat_i) : (a12);
    b10 <= (stb_i & we_i & sel_b10) ? (dat_i) : (b10);
    b11 <= (stb_i & we_i & sel_b11) ? (dat_i) : (b11);
    b12 <= (stb_i & we_i & sel_b12) ? (dat_i) : (b12);
  end
assign dat_o = sel_a11 ? (a11) : 
		((sel_a12) ? (a12) : 
		((sel_b10) ? (b10) : 
		((sel_b11) ? (b11) : 
		((sel_b12) ? (b12) : 
		(16'h0000)))));
endmodule
module multa
	(
	a,			
	b,			
	r			
	);
input	[`COEFWIDTH-2:0]			a;
input	[`DATAWIDTH+2:0]			b;
output	[`DATAWIDTH + `COEFWIDTH + 1:0]	r;
assign r = a*b;
endmodule
module multb
	(
	a,			
	b,			
	r			
	);
input	[`COEFWIDTH-2:0]			a;
input	[`DATAWIDTH-2:0]			b;
output	[`DATAWIDTH + `COEFWIDTH - 3:0]	r;
assign r = a*b;
endmodule
`define ACCUM	2
`define COEFWIDTH	8
`define DATAWIDTH	8
module iir1
	(
	clk_i,		
	rst_i,		
	we_i,		
	stb_i,		
	ack_o,		
	dat_i,		
	dat_o,		
	adr_i,		
	dspclk,		
	nreset,		
	x,		
	valid,		
	y		
	);
input			clk_i;
input			rst_i;
input			we_i;
input			stb_i;
output			ack_o;
input	[15:0]		dat_i;
output	[15:0]		dat_o;
input	[2:0]		adr_i;
input			dspclk;
input			nreset;
input	[`DATAWIDTH-1:0]	x;
input			valid;
output	[`DATAWIDTH-1:0]	y;
wire	[15:0]	a11;
wire	[15:0]	a12;
wire	[15:0]	b10;
wire	[15:0]	b11;
wire	[15:0]	b12;
biquad biquadi
	(
	.clk(dspclk),				
	.nreset(nreset),			
	.x(x),					
	.valid(valid),				
	.a11(a11[15:16-`COEFWIDTH]),		
	.a12(a12[15:16-`COEFWIDTH]),		
	.b10(b10[15:16-`COEFWIDTH]),		
	.b11(b11[15:16-`COEFWIDTH]),		
	.b12(b12[15:16-`COEFWIDTH]),		
	.yout(y)				
	);
coefio coefioi
	(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.we_i(we_i),	
	.stb_i(stb_i),
	.ack_o(ack_o),
	.dat_i(dat_i),
	.dat_o(dat_o),
	.adr_i(adr_i),
	.a11(a11),
	.a12(a12),
	.b10(b10),
	.b11(b11),
	.b12(b12)
	);
endmodule
module biquad
	(
	clk,				
	nreset,			
	x,				
	valid,			
	a11,				
	a12,				
	b10,				
	b11,				
	b12,				
	yout				
	);
input 								clk;
input 								nreset;
input	[`DATAWIDTH-1:0]				x;
input								valid;
input	[`COEFWIDTH-1:0]				a11;
input	[`COEFWIDTH-1:0]				a12;
input	[`COEFWIDTH-1:0]				b10;
input	[`COEFWIDTH-1:0]				b11;
input	[`COEFWIDTH-1:0]				b12;
output	[`DATAWIDTH-1:0]				yout;
reg		[`DATAWIDTH-1:0]				xvalid;
reg		[`DATAWIDTH-1:0]				xm1;
reg		[`DATAWIDTH-1:0]				xm2;
reg		[`DATAWIDTH-1:0]				xm3;
reg		[`DATAWIDTH-1:0]				xm4;
reg		[`DATAWIDTH-1:0]				xm5;
reg		[`DATAWIDTH+3+`ACCUM:0]			sumb10reg;
reg		[`DATAWIDTH+3+`ACCUM:0]			sumb11reg;
reg		[`DATAWIDTH+3+`ACCUM:0]			sumb12reg;
reg		[`DATAWIDTH+3+`ACCUM:0]			suma12reg;
reg		[`DATAWIDTH+3:0]				y;
reg		[`DATAWIDTH-1:0]				yout;
wire		[`COEFWIDTH-1:0]				sa11;
wire		[`COEFWIDTH-1:0]				sa12;
wire		[`COEFWIDTH-1:0]				sb10;
wire		[`COEFWIDTH-1:0]				sb11;
wire		[`COEFWIDTH-1:0]				sb12;
wire		[`DATAWIDTH-2:0]				tempsum;
wire		[`DATAWIDTH+3+`ACCUM:0]			tempsum2;
wire		[`DATAWIDTH + `COEFWIDTH - 3:0]		mb10out;
wire		[`DATAWIDTH+3+`ACCUM:0]			sumb10;
wire		[`DATAWIDTH + `COEFWIDTH - 3:0]		mb11out;
wire		[`DATAWIDTH+3+`ACCUM:0]			sumb11;
wire		[`DATAWIDTH + `COEFWIDTH - 3:0]		mb12out;
wire		[`DATAWIDTH+3+`ACCUM:0]			sumb12;
wire		[`DATAWIDTH + `COEFWIDTH + 1:0] 	ma12out;
wire		[`DATAWIDTH+3+`ACCUM:0]			suma12;
wire		[`DATAWIDTH + `COEFWIDTH + 1:0] 	ma11out;
wire		[`DATAWIDTH+3+`ACCUM:0]			suma11;
wire		[`DATAWIDTH+2:0]				sy;
wire		[`DATAWIDTH-1:0]				olimit;
assign sa11 = a11[`COEFWIDTH-1] ? (-a11) : a11;
assign sa12 = a12[`COEFWIDTH-1] ? (-a12) : a12;
assign sb10 = b10[`COEFWIDTH-1] ? (-b10) : b10;
assign sb11 = b11[`COEFWIDTH-1] ? (-b11) : b11;
assign sb12 = b12[`COEFWIDTH-1] ? (-b12) : b12;
assign tempsum = -xvalid[`DATAWIDTH-2:0];
assign tempsum2 = -{4'b0000,mb10out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]};
always @(posedge clk or negedge nreset)
begin
if ( ~nreset )
  begin
    xvalid <= 0;
    xm1 <= 0;
    xm2 <= 0;
    xm3 <= 0;
    xm4 <= 0;
    xm5 <= 0;
  end
else
  begin
    xvalid <= valid ? x : xvalid;
    xm1 <= valid ? (xvalid[`DATAWIDTH-1] ? ({xvalid[`DATAWIDTH-1],tempsum}) : {xvalid}) : xm1;
    xm2 <= valid ? xm1 : xm2;
    xm3 <= valid ? xm2 : xm3;
    xm4 <= valid ? xm3 : xm4;
    xm5 <= valid ? xm4 : xm5;
  end
end
multb multb10(.a(sb10[`COEFWIDTH-2:0]),.b(xm1[`DATAWIDTH-2:0]),.r(mb10out));
assign sumb10 = (b10[`COEFWIDTH-1] ^ xm1[`DATAWIDTH-1]) ? (tempsum2) : ({4'b0000,mb10out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]});
multb multb11(.a(sb11[`COEFWIDTH-2:0]),.b(xm3[`DATAWIDTH-2:0]),.r(mb11out));
assign sumb11 = (b11[`COEFWIDTH-1] ^ xm3[`DATAWIDTH-1]) ? (sumb10reg - {4'b0000,mb11out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]}) : 
     (sumb10reg + {4'b0000,mb11out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]});
multb multb12(.a(sb12[`COEFWIDTH-2:0]),.b(xm5[`DATAWIDTH-2:0]),.r(mb12out));
assign sumb12 = (b12[`COEFWIDTH-1] ^ xm5[`DATAWIDTH-1]) ? (sumb11reg - {4'b0000,mb12out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]}) : 
     (sumb11reg + {4'b0000,mb12out[`COEFWIDTH+`DATAWIDTH-3:`COEFWIDTH-2-`ACCUM]});
assign sy = y[`DATAWIDTH+3] ? (~y + 1) : y;
multa multa12(.a(sa12[`COEFWIDTH-2:0]),.b(sy[`DATAWIDTH+2:0]),.r(ma12out));
assign suma12 = (a12[`COEFWIDTH-1] ^ y[`DATAWIDTH+3]) ? (sumb12reg - {1'b0,ma12out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]}) : 
     (sumb12reg + {1'b0,ma12out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]});
multa multa11(.a(sa11[`COEFWIDTH-2:0]),.b(sy[`DATAWIDTH+2:0]),.r(ma11out));
assign suma11 = (a11[`COEFWIDTH-1] ^ y[`DATAWIDTH+3]) ? (suma12reg - {1'b0,ma11out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]}) : 
     (suma12reg + {1'b0,ma11out[`COEFWIDTH+`DATAWIDTH:`COEFWIDTH-2-`ACCUM]});
assign olimit = {y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],
				~y[`DATAWIDTH+3],~y[`DATAWIDTH+3],~y[`DATAWIDTH+3]};
always @(posedge clk or negedge nreset)
begin
if ( ~nreset )
  begin
    sumb10reg <= 0;
    sumb11reg <= 0;
    sumb12reg <= 0;
    suma12reg <= 0;
    y <= 0;
    yout <= 0;
  end
else
  begin
    sumb10reg <= valid ? (sumb10) : (sumb10reg);
    sumb11reg <= valid ? (sumb11) : (sumb11reg);
    sumb12reg <= valid ? (sumb12) : (sumb12reg);
    suma12reg <= valid ? (suma12) : (suma12reg);
    y <= valid ? suma11[`DATAWIDTH+3+`ACCUM:`ACCUM] : y;
    yout <= valid ? (( (&y[`DATAWIDTH+3:`DATAWIDTH-1]) | (~|y[`DATAWIDTH+3:`DATAWIDTH-1])  ) ? 
		(y[`DATAWIDTH-1:0]) : (olimit)) : (yout);
  end
end
endmodule
module coefio
	(
	clk_i,
	rst_i,
	we_i,	
	stb_i,
	ack_o,
	dat_i,
	dat_o,
	adr_i,
	a11,
	a12,
	b10,
	b11,
	b12
	);
input 		clk_i;
input 		rst_i;
input		we_i;
input		stb_i;
output		ack_o;
input	[15:0]	dat_i;
output	[15:0]	dat_o;
input	[2:0]	adr_i;
output	[15:0]	a11;
output	[15:0]	a12;
output	[15:0]	b10;
output	[15:0]	b11;
output	[15:0]	b12;
reg	[15:0]	a11;
reg	[15:0]	a12;
reg	[15:0]	b10;
reg	[15:0]	b11;
reg	[15:0]	b12;
wire		ack_o;
wire		sel_a11;
wire		sel_a12;
wire		sel_b10;
wire		sel_b11;
wire		sel_b12;
assign sel_a11 = (adr_i == 3'b000);
assign sel_a12 = (adr_i == 3'b001);
assign sel_b10 = (adr_i == 3'b010);
assign sel_b11 = (adr_i == 3'b011);
assign sel_b12 = (adr_i == 3'b100);
assign ack_o = stb_i;
always @(posedge clk_i or posedge rst_i)
if ( rst_i )
  begin
    a11 <= 15'b11111111;
    a12 <= 15'b11111;
    b10 <= 15'b1111111;
    b11 <= 15'b11;
    b12 <= 15'b11111111;
  end
else
  begin
    a11 <= (stb_i & we_i & sel_a11) ? (dat_i) : (a11);
    a12 <= (stb_i & we_i & sel_a12) ? (dat_i) : (a12);
    b10 <= (stb_i & we_i & sel_b10) ? (dat_i) : (b10);
    b11 <= (stb_i & we_i & sel_b11) ? (dat_i) : (b11);
    b12 <= (stb_i & we_i & sel_b12) ? (dat_i) : (b12);
  end
assign dat_o = sel_a11 ? (a11) : 
		((sel_a12) ? (a12) : 
		((sel_b10) ? (b10) : 
		((sel_b11) ? (b11) : 
		((sel_b12) ? (b12) : 
		(16'h0000)))));
endmodule
module multa
	(
	a,			
	b,			
	r			
	);
input	[`COEFWIDTH-2:0]			a;
input	[`DATAWIDTH+2:0]			b;
output	[`DATAWIDTH + `COEFWIDTH + 1:0]	r;
assign r = a*b;
endmodule
module multb
	(
	a,			
	b,			
	r			
	);
input	[`COEFWIDTH-2:0]			a;
input	[`DATAWIDTH-2:0]			b;
output	[`DATAWIDTH + `COEFWIDTH - 3:0]	r;
assign r = a*b;
endmodule
