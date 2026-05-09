module denise_bitplanes
(
  input   clk,             
  input   clk7_en,
  input   reset,
  input   c1,            
  input   c3,
  input   aga,
  input   [8:1] reg_address_in,   
  input   [15:0] data_in,       
  input   [48-1:0] chip48,  
  input   hires,             
  input   shres,             
  input  [8:0] hpos,        
  output   [8:1] bpldata      
);
parameter BPLCON1 = 9'h102;
parameter BPL1DAT = 9'h110;
parameter BPL2DAT = 9'h112;
parameter BPL3DAT = 9'h114;
parameter BPL4DAT = 9'h116;
parameter BPL5DAT = 9'h118;
parameter BPL6DAT = 9'h11a;
parameter BPL7DAT = 9'h11c;
parameter BPL8DAT = 9'h11e;
parameter FMODE   = 9'h1fc;
reg   [15:0] bplcon1;    
reg   [15:0] fmode;     
reg    [63:0] bpl1dat;    
reg    [63:0] bpl2dat;    
reg    [63:0] bpl3dat;    
reg    [63:0] bpl4dat;    
reg    [63:0] bpl5dat;    
reg    [63:0] bpl6dat;    
reg    [63:0] bpl7dat;    
reg    [63:0] bpl8dat;    
reg    load;        
reg    [7:0] extra_delay_f0;  
reg    [7:0] extra_delay_f12;
reg    [7:0] extra_delay_f3;
reg    [7:0] extra_delay_r;
reg    [7:0] pf1h;      
reg    [7:0] pf2h;      
reg    [7:0] pf1h_del;    
reg    [7:0] pf2h_del;    
always @(hpos)
  case (hpos[3:2])
    2'b00 : extra_delay_f0 = 8'b00_0000_00;
    2'b01 : extra_delay_f0 = 8'b00_1100_00;
    2'b10 : extra_delay_f0 = 8'b00_1000_00;
    2'b11 : extra_delay_f0 = 8'b00_0100_00;
  endcase
always @(hpos)
  case (hpos[4:3])
    2'b00 : extra_delay_f12 = 8'b00_0000_00;
    2'b01 : extra_delay_f12 = 8'b01_1000_00;
    2'b10 : extra_delay_f12 = 8'b01_0000_00;
    2'b11 : extra_delay_f12 = 8'b00_1000_00;
  endcase
always @(hpos)
  case (hpos[5:4])
    2'b00 : extra_delay_f3 = 8'b00_0000_00;
    2'b01 : extra_delay_f3 = 8'b11_0000_00;
    2'b10 : extra_delay_f3 = 8'b10_0000_00;
    2'b11 : extra_delay_f3 = 8'b01_0000_00;
  endcase
always @ (posedge clk) begin
  if (clk7_en) begin
    if (load) extra_delay_r <= #1 (fmode[1:0] == 2'b00) ? extra_delay_f0 : (fmode[1:0] == 2'b11) ? extra_delay_f3 : extra_delay_f12;
  end
end
always @(posedge clk)
  if (clk7_en) begin
    if (load)
      pf1h <= {bplcon1[11:10],bplcon1[3:0],bplcon1[9:8]};
  end
always @(posedge clk)
  if (clk7_en) begin
    pf1h_del <= pf1h + extra_delay_r;
  end
always @(posedge clk)
  if (clk7_en) begin
    if (load)
      pf2h <= {bplcon1[15:14],bplcon1[7:4],bplcon1[13:12]};
  end
always @(posedge clk)
  if (clk7_en) begin
    pf2h_del <= pf2h + extra_delay_r;
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reset)
      bplcon1 <= #1 16'h3300;
    if ((reg_address_in[8:1] == BPLCON1[8:1]))
      bplcon1 <= #1 aga ? data_in[15:0] : {2'b00,2'b11,2'b00,2'b11,data_in[7:0]};
  end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reset)
      fmode <= #1 16'h0000;
    else if (aga && (reg_address_in[8:1] == FMODE[8:1]))
      fmode <= #1 data_in;
  end
end
reg [47:0] chip48_fmode=0;
always @ (*) begin
  case (fmode[1:0])
    2'b11   : chip48_fmode[47:0] = chip48[47:0];
    2'b10,
    2'b01   : chip48_fmode[47:0] = {chip48[47:32], 32'h00000000};
    default : chip48_fmode[47:0] = 48'h000000000000;
  endcase
end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL1DAT[8:1])
      bpl1dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL2DAT[8:1])
      bpl2dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL3DAT[8:1])
      bpl3dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL4DAT[8:1])
      bpl4dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL5DAT[8:1])
      bpl5dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL6DAT[8:1])
      bpl6dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL7DAT[8:1])
      bpl7dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    if (reg_address_in[8:1] == BPL8DAT[8:1])
      bpl8dat <= {data_in,chip48_fmode};
  end
always @(posedge clk)
  if (clk7_en) begin
    load <= reg_address_in[8:1] == BPL1DAT[8:1] ? 1'b1 : 1'b0;
  end
denise_bitplane_shifter bplshft1
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl1dat),
  .scroll(pf1h_del),
  .out(bpldata[1])
);
denise_bitplane_shifter bplshft2
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl2dat),
  .scroll(pf2h_del),
  .out(bpldata[2])
);
denise_bitplane_shifter bplshft3
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl3dat),
  .scroll(pf1h_del),
  .out(bpldata[3])
);
denise_bitplane_shifter bplshft4
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl4dat),
  .scroll(pf2h_del),
  .out(bpldata[4])
);
denise_bitplane_shifter bplshft5
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl5dat),
  .scroll(pf1h_del),
  .out(bpldata[5])
);
denise_bitplane_shifter bplshft6
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl6dat),
  .scroll(pf2h_del),
  .out(bpldata[6])
);
denise_bitplane_shifter bplshft7
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl7dat),
  .scroll(pf1h_del),
  .out(bpldata[7])
);
denise_bitplane_shifter bplshft8
(
  .clk(clk),
  .clk7_en(clk7_en),
  .c1(c1),
  .c3(c3),
  .load(load),
  .hires(hires),
  .shres(shres),
  .fmode(fmode[1:0]),
  .data_in(bpl8dat),
  .scroll(pf2h_del),
  .out(bpldata[8])
);
endmodule
