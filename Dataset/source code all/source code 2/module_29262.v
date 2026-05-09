module RAM_Nx1(clkA, clkB, weA, reB, addrA, addrB, diA, doB);
  parameter WIDTHA      = 72;
  parameter SIZEA       = 512;
  parameter ADDRWIDTHA  = 9;
  parameter WIDTHB      = 18;
  parameter SIZEB       = 2048;
  parameter ADDRWIDTHB  = 11;
  input                         clkA;
  input                         clkB;
  input                         weA;
  input                         reB;
  input       [ADDRWIDTHA-1:0]  addrA;
  input       [ADDRWIDTHB-1:0]  addrB;
  input       [WIDTHA-1:0]      diA;
  output reg  [WIDTHB-1:0]      doB;
  reg [WIDTHA-1:0] mux;
  reg [WIDTHA-1:0] RAM [SIZEA-1:0]  ;
  always @(posedge clkA)
  begin
    if(weA)
      RAM[addrA] <= diA;
  end
  always @(posedge clkB)
  begin
    mux = RAM[addrB[ADDRWIDTHB-1:1]];
    if(reB)
    begin
      if (addrB[0])
        doB <= mux[WIDTHA-1:WIDTHB];
      else
        doB <= mux[WIDTHB-1:0];
    end
  end
endmodule
