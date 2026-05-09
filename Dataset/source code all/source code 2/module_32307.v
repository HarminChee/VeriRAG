module agnus_bitplanedma (
  input  wire           clk,              
  input  wire           clk7_en,          
  input  wire           reset,            
  input  wire           harddis,
  input  wire           aga,              
  input  wire           ecs,              
  input  wire           a1k,              
  input  wire           sof,              
  input  wire           dmaena,           
  input  wire [ 11-1:0] vpos,             
  input  wire [  9-1:0] hpos,             
  output wire           dma,              
  input  wire [  9-1:1] reg_address_in,   
  output reg  [  9-1:1] reg_address_out,  
  input  wire [ 16-1:0] data_in,          
  output wire [ 21-1:1] address_out       
);
localparam DIWSTRT_REG   = 9'h08E;
localparam DIWSTOP_REG   = 9'h090;
localparam DIWHIGH_REG   = 9'h1E4;
localparam BPLPTBASE_REG = 9'h0E0; 
localparam DDFSTRT_REG   = 9'h092;
localparam DDFSTOP_REG   = 9'h094;
localparam BPL1MOD_REG   = 9'h108;
localparam BPL2MOD_REG   = 9'h10a;
localparam BPLCON0_REG   = 9'h100;
localparam FMODE_REG     = 9'h1fc;
reg  [ 8: 2] ddfstrt;             
reg  [ 8: 2] ddfstop;             
wire [ 8: 2] ddfdiff;
wire [ 8: 2] ddfdiff_masked;
reg  [15: 1] bpl1mod;             
reg  [15: 1] bpl2mod;             
wire [15: 1] bpl1mod_bscan;       
wire [15: 1] bpl2mod_bscan;       
reg  [ 5: 0] bplcon0;             
reg  [ 5: 0] bplcon0_delayed;     
reg  [ 5: 0] bplcon0_delay [1:0];
reg  [15: 0] fmode;
wire         hires;               
wire         shres;               
wire [ 3: 0] bpu;                 
reg  [20: 1] newpt;               
reg  [20:16] bplpth [7:0];        
reg  [15: 1] bplptl [7:0];        
reg  [ 4: 0] plane;               
wire         mod;                 
reg          hardena;             
reg          softena;             
reg          ddfena;              
reg          ddfena_0;
reg  [ 4: 0] ddfseq;              
reg          ddfrun;              
reg          ddfend;              
reg  [ 1: 0] dmaena_delayed;      
reg  [10: 0] vdiwstrt;            
reg  [10: 0] vdiwstop;            
reg          vdiwena;             
wire [ 2: 0] bplptr_sel;          
wire [20:16] bplpth_in;
wire [15: 1] bplptl_in;
wire         ddfstrt_sel;
wire         bp_fmode0;           
wire         bp_fmode12;          
wire         bp_fmode3;           
reg          soft_start;
reg          soft_stop;
reg          hard_start;
reg          hard_stop;
wire         ddfseq_match;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reg_address_in[8:1]==DIWSTRT_REG[8:1])
      vdiwstrt[7:0] <= #1 data_in[15:8];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reg_address_in[8:1]==DIWSTRT_REG[8:1])
      vdiwstrt[10:8] <= #1 3'b000; 
    else if (reg_address_in[8:1]==DIWHIGH_REG[8:1] && ecs) 
      vdiwstrt[10:8] <= #1 data_in[2:0];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reg_address_in[8:1]==DIWSTOP_REG[8:1])
      vdiwstop[7:0] <= #1 data_in[15:8];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reg_address_in[8:1]==DIWSTOP_REG[8:1])
      vdiwstop[10:8] <= #1 {2'b00,~data_in[15]}; 
    else if (reg_address_in[8:1]==DIWHIGH_REG[8:1] && ecs) 
      vdiwstop[10:8] <= #1 data_in[10:8];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (sof && ~a1k || vpos[10:0]==0 && a1k || vpos[10:0]==vdiwstop[10:0]) 
      vdiwena <= #1 1'b0;
    else if (vpos[10:0]==vdiwstrt[10:0])
      vdiwena <= #1 1'b1;
  end
end
assign bplptr_sel = dma ? plane[2:0] : reg_address_in[4:2];
assign bplpth_in = dma ? newpt[20:16] : data_in[4:0];
always @ (posedge clk) begin
  if (clk7_en) begin
    if (dma || ((reg_address_in[8:5]==BPLPTBASE_REG[8:5]) && !reg_address_in[1])) 
      bplpth[bplptr_sel] <= #1 bplpth_in;
  end
end
assign address_out[20:16] = bplpth[plane[2:0]];
assign bplptl_in = dma ? newpt[15:1] : data_in[15:1];
always @ (posedge clk) begin
  if (clk7_en) begin
    if (dma || ((reg_address_in[8:5]==BPLPTBASE_REG[8:5]) && reg_address_in[1])) 
      bplptl[bplptr_sel] <= #1 bplptl_in;
  end
end
assign address_out[15:1] = bplptl[plane[2:0]];
assign ddfstrt_sel = reg_address_in[8:1]==DDFSTRT_REG[8:1] ? 1'b1 : 1'b0;
always @ (posedge clk) begin
  if (clk7_en) begin
    if (ddfstrt_sel)
      ddfstrt[8:2] <= #1 data_in[7:1];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reg_address_in[8:1]==DDFSTOP_REG[8:1])
      ddfstop[8:2] <= #1 data_in[7:1];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reg_address_in[8:1]==BPL1MOD_REG[8:1])
      bpl1mod[15:1] <= #1 data_in[15:1];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reg_address_in[8:1]==BPL2MOD_REG[8:1])
      bpl2mod[15:1] <= #1 data_in[15:1];
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reset)
      bplcon0 <= #1 6'b00_0000;
    else if (reg_address_in[8:1]==BPLCON0_REG[8:1])
      bplcon0 <= #1 {data_in[6], data_in[15], aga & data_in[4], data_in[14:12]}; 
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0]) begin
      bplcon0_delay[0] <= #1 bplcon0;
      bplcon0_delay[1] <= #1 bplcon0_delay[0];
      bplcon0_delayed  <= #1 bplcon0_delay[1];
    end
  end
end
assign shres = ecs & bplcon0_delayed[5];
assign hires = bplcon0_delayed[4];
assign bpu = aga ? bplcon0_delayed[3:0] : {1'b0, &bplcon0_delayed[2:0] ? 3'd4 : bplcon0_delayed[2:0]};
always @ (posedge clk) begin
  if (clk7_en) begin
    if (reset)
      fmode <= #1 16'h0000;
    else if (aga && (reg_address_in[8:1] == FMODE_REG[8:1]))
      fmode <= #1 data_in;
  end
end
assign bp_fmode0  = (fmode[1:0] == 2'b00);
assign bp_fmode12 = (fmode[1:0] == 2'b01) || (fmode[1:0] == 2'b10);
assign bp_fmode3  = (fmode[1:0] == 2'b11);
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[1:0]==2'b11)
      dmaena_delayed[1:0] <= #1 {dmaena_delayed[0], dmaena};
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0])
      if (hpos[8:1]=={ddfstrt[8:3], ddfstrt[2] & ecs, 1'b0})
        soft_start <= #1 1'b1;
      else
        soft_start <= #1 1'b0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0])
      if (hpos[8:1] == {ddfstop[8:3], ddfstop[2] & ecs, 1'b0})
        soft_stop <= #1 1'b1;
      else
        soft_stop <= #1 1'b0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0])
      if (hpos[8:1]==8'h18)
        hard_start <= #1 1'b1;
      else
        hard_start <= #1 1'b0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0])
      if (hpos[8:1]==8'hD8)
        hard_stop <= #1 1'b1;
      else
        hard_stop <= #1 1'b0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0])
      if (soft_start && (ecs || vdiwena && dmaena) && !ddfstrt_sel) 
        softena <= #1 1'b1;
      else if (soft_stop || !ecs && hard_stop)
        softena <= #1 1'b0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0])
      if (hard_start)
        hardena <= #1 1'b1;
      else if (hard_stop)
        hardena <= #1 1'b0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0]) begin
      ddfena_0 <= #1 (hardena || harddis) && softena;
      ddfena <= #1 ddfena_0;
    end
  end
end
assign ddfseq_match = ((!hires && !shres && bp_fmode3)                            && (ddfseq[4:0] == 5'd7)) ||
                      (((!shres && !hires && bp_fmode12) || (hires && bp_fmode3)) && (ddfseq[3:0] == 4'd7)) ||
                      (!(!hires && !shres && bp_fmode3) && !((!shres && !hires && bp_fmode12) || (hires && bp_fmode3))) && (ddfseq[2:0] == 3'd7);
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0]) 
      if (ddfena && vdiwena && !hpos[1] && dmaena_delayed[0]) 
        ddfrun <= #1 1'b1;
      else if ((ddfend || !vdiwena) && ddfseq_match) 
        ddfrun <= #1 1'b0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0]) 
      if (ddfrun) 
        ddfseq <= #1 ddfseq + 5'd1;
      else
        ddfseq <= #1 5'd0;
  end
end
always @ (posedge clk) begin
  if (clk7_en) begin
    if (hpos[0] && ddfseq_match && ddfend)
      ddfend <= #1 1'b0;
    else if (hpos[0] && (ddfseq[2:0]==7) && !ddfena)
      ddfend <= #1 1'b1;
  end
end
assign mod = (shres && bp_fmode0) ? ddfend & ddfseq[2] & ddfseq[1] : ((hires && bp_fmode0) || (shres && bp_fmode12)) ? ddfend & ddfseq[2] : ddfend;
always @ (*) begin
  if (shres && bp_fmode0) 
    plane = {4'b0000,~ddfseq[0]};
  else if ((hires && bp_fmode0) || (shres && bp_fmode12)) 
    plane = {3'b000,~ddfseq[0],~ddfseq[1]};
  else if ((!shres && !hires && bp_fmode0) || (hires && bp_fmode12) || (shres && bp_fmode3)) 
    plane = {2'b00,~ddfseq[0],~ddfseq[1],~ddfseq[2]};
  else if ((!shres && !hires && bp_fmode12) || (hires && bp_fmode3)) 
    plane = {1'b0,ddfseq[3],~ddfseq[0],~ddfseq[1],~ddfseq[2]};
  else 
    plane = {ddfseq[4],ddfseq[3],~ddfseq[0],~ddfseq[1],~ddfseq[2]};
end
assign dma = (ddfrun) && dmaena_delayed[1] && hpos[0] && (plane[4:0] < {1'b0,bpu[3:0]}) ? 1'b1 : 1'b0;
assign bpl1mod_bscan = fmode[14] ? ((vdiwstrt[0] ^ vpos[0]) ? bpl2mod : bpl1mod) : bpl1mod;
assign bpl2mod_bscan = fmode[14] ? ((vdiwstrt[0] ^ vpos[0]) ? bpl2mod : bpl1mod) : bpl2mod;
always @ (*) begin
  if (mod) begin
    if (plane[0]) 
      newpt[20:1] = address_out[20:1] + {{5{bpl2mod_bscan[15]}},bpl2mod_bscan[15:1]} + (fmode[1:0] == 2'b11 ? 3'd4 : fmode[1:0] == 2'b00 ? 3'd1 : 3'd2);
    else 
      newpt[20:1] = address_out[20:1] + {{5{bpl1mod_bscan[15]}},bpl1mod_bscan[15:1]} + (fmode[1:0] == 2'b11 ? 3'd4 : fmode[1:0] == 2'b00 ? 3'd1 : 3'd2);
  end else begin
    newpt[20:1] = address_out[20:1] + (fmode[1:0] == 2'b11 ? 3'd4 : fmode[1:0] == 2'b00 ? 3'd1 : 3'd2);
  end
end
always @ (*) begin
  case (plane[2:0])
    3'b000 : reg_address_out[8:1] = 8'h88;
    3'b001 : reg_address_out[8:1] = 8'h89;
    3'b010 : reg_address_out[8:1] = 8'h8A;
    3'b011 : reg_address_out[8:1] = 8'h8B;
    3'b100 : reg_address_out[8:1] = 8'h8C;
    3'b101 : reg_address_out[8:1] = 8'h8D;
    3'b110 : reg_address_out[8:1] = 8'h8E;
    3'b111 : reg_address_out[8:1] = 8'h8F;
  endcase
end
endmodule
