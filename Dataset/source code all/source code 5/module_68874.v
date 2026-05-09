`timescale 1ns/10ps
`timescale 1ns/10ps
module IS61LV6416L (A, IO, CE_, OE_, WE_, LB_, UB_);
parameter dqbits = 16;
parameter memdepth = 65535;
parameter addbits = 16;
parameter Taa   = 10;
parameter Toha  = 3;
parameter Thzce = 4;
parameter Tsa   = 0;
parameter Thzwe = 5;
input wire CE_, OE_, WE_, LB_, UB_;
input wire [(addbits - 1) : 0] A;
inout wire [(dqbits - 1) : 0] IO;
wire [(dqbits - 1) : 0] dout;
reg  [(dqbits/2 - 1) : 0] bank0 [0 : memdepth];
reg  [(dqbits/2 - 1) : 0] bank1 [0 : memdepth];
wire r_en = WE_ & (~CE_) & (~OE_);
wire w_en = (~WE_) & (~CE_) & ((~LB_) | (~UB_));
assign #(r_en ? Taa : Thzce) IO = r_en ? dout : 16'bz;   
assign dout [(dqbits/2 - 1) : 0]        = LB_ ? 8'bz : bank0[A];
assign dout [(dqbits - 1) : (dqbits/2)] = UB_ ? 8'bz : bank1[A];
always @(A or w_en)
  begin
    #Tsa
    if (w_en)
      #Thzwe
      begin
        bank0[A] = LB_ ? bank0[A] : IO [(dqbits/2 - 1) : 0];
        bank1[A] = UB_ ? bank1[A] : IO [(dqbits - 1)   : (dqbits/2)];
      end
  end
specify
  specparam
    tSA   = 0,
    tAW   = 8,
    tSCE  = 8,
    tSD   = 6,
    tPWE2 = 10,
    tPWE1 = 8,
    tPBW  = 8;
  $setup (A, negedge CE_, tSA);
  $setup (A, posedge CE_, tAW);
  $setup (IO, posedge CE_, tSD);
  $setup (A, negedge WE_, tSA);
  $setup (IO, posedge WE_, tSD);
  $setup (A, negedge LB_, tSA);
  $setup (A, negedge UB_, tSA);
  $width (negedge CE_, tSCE);
  $width (negedge LB_, tPBW);
  $width (negedge UB_, tPBW);
  `ifdef OEb
  $width (negedge WE_, tPWE1);
  `else
  $width (negedge WE_, tPWE2);
  `endif 
endspecify
endmodule
