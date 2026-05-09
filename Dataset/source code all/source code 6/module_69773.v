`timescale 1ns / 1ps
`timescale 1ns / 1ps
module dcmspi (
    input  RST,                
    input  PROGCLK,            
    input  PROGDONE,           
    input  DFSLCKD,
    input  [7:0] M,            
    input  [7:0] D,            
    input  GO,                 
    output reg BUSY,
    output reg PROGEN,         
    output reg PROGDATA        
);
parameter TCQ = 1;
wire [9:0] mval = {M, 1'b1, 1'b1}; 
wire [9:0] dval = {D, 1'b0, 1'b1}; 
reg dfslckd_q;
reg dfslckd_rising;
always @ (posedge PROGCLK)
begin
  dfslckd_q <=#TCQ DFSLCKD;
  dfslckd_rising <=#TCQ !dfslckd_q & DFSLCKD;
end
always @ (posedge PROGCLK)
begin
  if(RST || (PROGDONE & dfslckd_rising))
    BUSY <=#TCQ 1'b0;
  else if (GO)
    BUSY <=#TCQ 1'b1;
end
reg [9:0] sndval;
reg sndm = 1'b0;
reg sndd = 1'b0;
wire ddone;
SRL16E VCNT (
  .Q(ddone), 
  .A0(1'b1), 
  .A1(1'b0), 
  .A2(1'b0), 
  .A3(1'b1), 
  .CE(1'b1), 
  .CLK(PROGCLK), 
  .D(GO) 
);
defparam VCNT.INIT = 16'h0;
always @ (posedge PROGCLK)
begin
  if(RST || ddone)
    sndd <=#TCQ 1'b0;
  else if(GO)
    sndd <=#TCQ 1'b1;
end
wire ldm;
SRL16E DMGAP (
  .Q(ldm), 
  .A0(1'b0), 
  .A1(1'b0), 
  .A2(1'b1), 
  .A3(1'b0), 
  .CE(1'b1), 
  .CLK(PROGCLK), 
  .D(ddone) 
);
defparam DMGAP.INIT = 16'h0;
wire mdone;
SRL16E MCNT (
  .Q(mdone), 
  .A0(1'b1), 
  .A1(1'b0), 
  .A2(1'b0), 
  .A3(1'b1), 
  .CE(1'b1), 
  .CLK(PROGCLK), 
  .D(ldm) 
);
defparam MCNT.INIT = 16'h0;
always @ (posedge PROGCLK)
begin
  if(RST || mdone)
    sndm <=#TCQ 1'b0;
  else if(ldm)
    sndm <=#TCQ 1'b1;
end
wire gocmd;
SRL16E GOGAP (
  .Q(gocmd), 
  .A0(1'b0), 
  .A1(1'b0), 
  .A2(1'b1), 
  .A3(1'b0), 
  .CE(1'b1), 
  .CLK(PROGCLK), 
  .D(mdone) 
);
defparam GOGAP.INIT = 16'h0;
always @ (posedge PROGCLK)
begin
  if(RST)
    sndval <=#TCQ 10'h0;
  else if(GO) 
    sndval <=#TCQ dval;
  else if(ldm)
    sndval <=#TCQ mval;
  else if(sndm || sndd)
    sndval <=#TCQ sndval >> 1;
end
always @ (posedge PROGCLK)
begin
  PROGEN <=#TCQ sndd | sndm | gocmd;
end
always @ (posedge PROGCLK)
begin
  if(sndm || sndd)
    PROGDATA <=#TCQ sndval[0];
  else
    PROGDATA <=#TCQ 1'b0;
end
endmodule
