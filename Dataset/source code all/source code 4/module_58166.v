module ps2mouse_ctrl (
  input wire clk,
  input wire reset,
  inout wire mclk,
  inout wire mdat
);
reg  [ 8-1:0] ycount;
reg  [ 8-1:0] xcount;
reg  [ 8-1:0] zcount;
reg           _mleft;
reg           _mthird;
reg           _mright;
reg           mclkout;
wire          mdatout;
reg  [ 2-1:0] mdatr;
reg  [ 3-1:0] mclkr;
reg  [11-1:0] mreceive;
reg  [12-1:0] msend;
reg  [16-1:0] mtimer;
reg  [ 3-1:0] mstate;
reg  [ 3-1:0] mnext;
wire          mclkneg;
reg           mrreset;
wire          mrready;
reg           msreset;
wire          msready;
reg           mtreset;
wire          mtready;
wire          mthalf;
reg  [ 3-1:0] mpacket;
reg           intellimouse=0;
wire          mcmd_done;
reg  [ 4-1:0] mcmd_cnt=1;
reg           mcmd_inc=0;
reg  [12-1:0] mcmd;
assign mclk = (mclkout) ? 1'bz : 1'b0;
assign mdat = (mdatout) ? 1'bz : 1'b0;
always @ (posedge clk) begin
  mdatr[1:0] <= #1 {mdatr[0],   mdat};
  mclkr[2:0] <= #1 {mclkr[1:0], mclk};
end
assign mclkneg = mclkr[2] & !mclkr[1];
always @ (posedge clk) begin
  if (mrreset)
    mreceive[10:0] <= #1 11'b11111111111;
  else if (mclkneg)
    mreceive[10:0] <= #1 {mdatr[1],mreceive[10:1]};
end
assign mrready = !mreceive[0];
always @ (posedge clk) begin
  if (reset)
    mcmd_cnt <= #1 4'd0;
  else if (mcmd_inc && !mcmd_done)
    mcmd_cnt <= #1 mcmd_cnt + 4'd1;
end
assign mcmd_done = (mcmd_cnt == 4'd9);
always @ (*) begin
  case (mcmd_cnt)
    4'h0    : mcmd = {1'b1, 1'b1, 1'b1,  8'hff, 1'b0}; 
    4'h1    : mcmd = {1'b1, 1'b1, 1'b1,  8'hf3, 1'b0}; 
    4'h2    : mcmd = {1'b1, 1'b1, 1'b0,  8'hc8, 1'b0}; 
    4'h3    : mcmd = {1'b1, 1'b1, 1'b1,  8'hf3, 1'b0}; 
    4'h4    : mcmd = {1'b1, 1'b1, 1'b0,  8'h64, 1'b0}; 
    4'h5    : mcmd = {1'b1, 1'b1, 1'b1,  8'hf3, 1'b0}; 
    4'h6    : mcmd = {1'b1, 1'b1, 1'b1,  8'h50, 1'b0}; 
    4'h7    : mcmd = {1'b1, 1'b1, 1'b0,  8'hf2, 1'b0}; 
    4'h8    : mcmd = {1'b1, 1'b1, 1'b0,  8'hf4, 1'b0}; 
    default : mcmd = {1'b1, 1'b1, 1'b0,  8'hf4, 1'b0}; 
  endcase
end
always @ (posedge clk) begin
  if (msreset)
    msend[11:0] <= #1 mcmd;
  else if (!msready && mclkneg)
    msend[11:0] <= #1 {1'b0,msend[11:1]};
end
assign msready = (msend[11:0]==12'b000000000001);
assign mdatout = msend[0];
always @(posedge clk) begin
  if (mtreset)
    mtimer[15:0] <= #1 16'h0000;
  else
    mtimer[15:0] <= #1 mtimer[15:0] + 16'd1;
end
assign mtready = (mtimer[15:0]==16'hffff);
assign mthalf = mtimer[11];
always @ (posedge clk) begin
  if (reset) begin
    {_mthird,_mright,_mleft} <= #1 3'b111;
    xcount[7:0] <= #1 8'h00;
    ycount[7:0] <= #1 8'h00;
    zcount[7:0] <= #1 8'h00;
  end else  begin
    if (mpacket == 3'd1) 
      {_mthird,_mright,_mleft} <= #1 ~mreceive[3:1];
    else if (mpacket == 3'd2) 
      xcount[7:0] <= #1 xcount[7:0] +  mreceive[8:1];
    else if (mpacket == 3'd3) 
      ycount[7:0] <= #1 ycount[7:0] - mreceive[8:1];
    else if (mpacket == 3'd4) 
      zcount[7:0] <= #1 zcount[7:0] + {{4{mreceive[4]}}, mreceive[4:1]};
  end
end
always @ (posedge clk) begin
  if (reset)
    intellimouse <= #1 1'b0;
  else if ((mpacket==5) && (mreceive[2:1] == 2'b11))
    intellimouse <= #1 1'b1;
end
always @ (posedge clk) begin
  if (reset || mtready)
    mstate <= #1 0;
  else
    mstate <= #1 mnext;
end
always @ (*) begin
  mclkout  = 1'b1;
  mtreset  = 1'b1;
  mrreset  = 1'b0;
  msreset  = 1'b0;
  mpacket  = 3'd0;
  mcmd_inc = 1'b0;
  case(mstate)
    0 : begin
      mtreset=1;
      mnext=1;
    end
    1 : begin
      mclkout=0;
      mtreset=0;
      msreset=1;
      if (mthalf) begin
        mnext=2;
      end else begin
        mnext=1;
      end
    end
    2 : begin
      mrreset=1;
      mtreset=0;
      if (msready) begin
        mcmd_inc = 1;
        case (mcmd_cnt)
          0 : mnext = 4;
          1 : mnext = 6;
          2 : mnext = 6;
          3 : mnext = 6;
          4 : mnext = 6;
          5 : mnext = 6;
          6 : mnext = 6;
          7 : mnext = 5;
          8 : mnext = 6;
          default : mnext = 6;
        endcase
      end else begin
        mnext=2;
      end
    end
    3 : begin
      mtreset=1;
      if (mrready) begin
        mpacket=1;
        mrreset=1;
        mnext=4;
      end else begin
        mnext=3;
      end
    end
    4 : begin
      mtreset=1;
      if (mrready) begin
        mpacket=2;
        mrreset=1;
        mnext=5;
      end else begin
        mnext=4;
      end
    end
    5 : begin
      mtreset=1;
      if (mrready) begin
        mpacket=3;
        mrreset=1;
        mnext = (intellimouse || !mcmd_done) ? 6 : 3;
      end else begin
        mnext=5;
      end
    end
    6 : begin
      mtreset=1;
      if (mrready) begin
        mpacket = (mcmd_cnt == 8) ? 5 : 4;
        mrreset=1;
        mnext = !mcmd_done ? 0 : 3;
      end else begin
        mnext=6;
      end
    end
    default : begin
      mclkout=1'bx;
      mrreset=1'bx;
      mtreset=1'bx;
      msreset=1'bx;
      mpacket=2'bxx;
      mnext=0;
    end
  endcase
end
endmodule
