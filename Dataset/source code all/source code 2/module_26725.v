module paula_audio
(
  input  wire           clk,            
  input  wire           clk7_en,        
  input  wire           cck,            
  input  wire           rst,            
  input  wire           strhor,         
  input  wire [  9-1:1] reg_address_in, 
  input  wire [ 16-1:0] data_in,        
  input  wire [  4-1:0] dmaena,         
  output wire [  4-1:0] audint,         
  input  wire [  4-1:0] audpen,         
  output reg  [  4-1:0] dmal,           
  output reg  [  4-1:0] dmas,           
  output wire           left,           
  output wire           right,          
  output wire [ 15-1:0] ldata,          
  output wire [ 15-1:0] rdata           
);
parameter  AUD0BASE = 9'h0a0;
parameter  AUD1BASE = 9'h0b0;
parameter  AUD2BASE = 9'h0c0;
parameter  AUD3BASE = 9'h0d0;
wire  [  4-1:0] aen;      
wire  [  4-1:0] dmareq;   
wire  [  4-1:0] dmaspc;   
wire  [  8-1:0] sample0;  
wire  [  8-1:0] sample1;  
wire  [  8-1:0] sample2;  
wire  [  8-1:0] sample3;  
wire  [  7-1:0] vol0;     
wire  [  7-1:0] vol1;     
wire  [  7-1:0] vol2;     
wire  [  7-1:0] vol3;     
wire  [ 16-1:0] ldatasum;
wire  [ 16-1:0] rdatasum;
assign aen[0] = (reg_address_in[8:4]==AUD0BASE[8:4]) ? 1'b1 : 1'b0;
assign aen[1] = (reg_address_in[8:4]==AUD1BASE[8:4]) ? 1'b1 : 1'b0;
assign aen[2] = (reg_address_in[8:4]==AUD2BASE[8:4]) ? 1'b1 : 1'b0;
assign aen[3] = (reg_address_in[8:4]==AUD3BASE[8:4]) ? 1'b1 : 1'b0;
always @(posedge clk) begin
  if (clk7_en) begin
    if (strhor)
    begin
      dmal <= (dmareq);
      dmas <= (dmaspc);
    end
  end
end
paula_audio_channel ach0
(
  .clk(clk),
  .clk7_en (clk7_en),
  .reset(rst),
  .cck(cck),
  .aen(aen[0]),
  .dmaena(dmaena[0]),
  .reg_address_in(reg_address_in[3:1]),
  .data(data_in),
  .volume(vol0),
  .sample(sample0),
  .intreq(audint[0]),
  .intpen(audpen[0]),
  .dmareq(dmareq[0]),
  .dmas(dmaspc[0]),
  .strhor(strhor)
);
paula_audio_channel ach1
(
  .clk(clk),
  .clk7_en (clk7_en),
  .reset(rst),
  .cck(cck),
  .aen(aen[1]),
  .dmaena(dmaena[1]),
  .reg_address_in(reg_address_in[3:1]),
  .data(data_in),
  .volume(vol1),
  .sample(sample1),
  .intreq(audint[1]),
  .intpen(audpen[1]),
  .dmareq(dmareq[1]),
  .dmas(dmaspc[1]),
  .strhor(strhor)
);
paula_audio_channel ach2
(
  .clk(clk),
  .clk7_en (clk7_en),
  .reset(rst),
  .cck(cck),
  .aen(aen[2]),
  .dmaena(dmaena[2]),
  .reg_address_in(reg_address_in[3:1]),
  .data(data_in),
  .volume(vol2),
  .sample(sample2),
  .intreq(audint[2]),
  .intpen(audpen[2]),
  .dmareq(dmareq[2]),
  .dmas(dmaspc[2]),
  .strhor(strhor)
);
paula_audio_channel ach3
(
  .clk(clk),
  .clk7_en (clk7_en),
  .reset(rst),
  .cck(cck),
  .aen(aen[3]),
  .dmaena(dmaena[3]),
  .reg_address_in(reg_address_in[3:1]),
  .data(data_in),
  .volume(vol3),
  .sample(sample3),
  .intreq(audint[3]),
  .intpen(audpen[3]),
  .dmareq(dmareq[3]),
  .dmas(dmaspc[3]),
  .strhor(strhor)
);
paula_audio_mixer mix (
  .clk      (clk),
  .clk7_en (clk7_en),
  .sample0  (sample0),
  .sample1  (sample1),
  .sample2  (sample2),
  .sample3  (sample3),
  .vol0     (vol0),
  .vol1     (vol1),
  .vol2     (vol2),
  .vol3     (vol3),
  .ldatasum (ldata),
  .rdatasum (rdata)
);
paula_audio_sigmadelta dac
(
  .clk(clk),
  .clk7_en (clk7_en),
  .ldatasum(ldata),
  .rdatasum(rdata),
  .left(left),
  .right(right)
);
endmodule
