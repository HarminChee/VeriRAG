`timescale 1ns/1ns
`timescale 1ns/1ns
module tx (reset, rtcal_expired, txstopin, 
           clkin, bitin, violationin, m, 
           bitout, bitinclk, setupdone, txdoneout);
  input reset, rtcal_expired, txstopin, clkin, bitin, violationin;
  input [1:0] m;
  output bitout, bitinclk, setupdone, txdoneout;
  reg bitout;
  wire bitinclk;
  reg setupdone, txstop, txdone, txdoneout;
reg bitoutenable;
  reg currentbit, previousbit, phaseinvert;
  reg currentviolation;
  wire   millerphaseinvert;
  assign millerphaseinvert = phaseinvert ^ (setupdone & !(currentbit | previousbit) & !currentviolation);
  wire   nextphaseinvert;
  assign nextphaseinvert = phaseinvert ^ (currentbit & setupdone);
  reg clkphase;
  wire evalclk, evalclkby2;
  wire [3:0] clocks;
  wire   tempbit, bitgenclk, nextbitout;
  assign bitgenclk = ~clocks[0];
  assign tempbit = (bitgenclk ^ phaseinvert) & setupdone & !txdone;
  assign nextbitout = (m == 0) ? (tempbit & !currentviolation) : tempbit; 
  wire divreset;
  assign divreset = reset | !setupdone;
  divby2 U_DIV1 (clkin    , divreset, clocks[0]);
  divby2 U_DIV2 (clkin    , divreset, clocks[1]);
  divby2 U_DIV3 (clocks[1], divreset, clocks[2]);
  divby2 U_DIV4 (clocks[2], divreset, clocks[3]);
  assign evalclk = clocks[m] & setupdone;
  divby2 U_DIV5 (evalclk, reset, evalclkby2);
  reg    bitinclkoverride; 
  assign bitinclk  = ((m == 0) ? evalclk : evalclkby2) | bitinclkoverride;
  always @ (posedge clkin or posedge reset) begin
    if (reset) begin
      bitout <= 0;
    end else begin
      bitout <= nextbitout & bitoutenable;
    end
  end
  reg [5:0] subcarriers;
  always @ (posedge clkin or posedge reset) begin
    if (reset) begin
      subcarriers      <= 0;
      bitinclkoverride <= 0;
      txdone           <= 0;
      txdoneout        <= 0;
      setupdone        <= 0;
    end else if (subcarriers < 8) begin
      subcarriers      <= subcarriers + 6'd1;
      bitinclkoverride <= 1;
    end else if (subcarriers < 17) begin
      subcarriers      <= subcarriers + 6'd1;
      bitinclkoverride <= 0;
    end else if (subcarriers == 17) begin 
      if (rtcal_expired) begin
        subcarriers <= subcarriers + 6'd1;
        setupdone   <= 1;
      end
    end else if (txstop & !txdone & (m==0)) begin  
      txdone <= 1;
      subcarriers <= subcarriers + 6'd1;
    end else if (txstop & !txdone & (m==1) & (subcarriers >= 19)) begin
      txdone <= 1;
      subcarriers <= subcarriers + 6'd1;
    end else if (txstop & !txdone & (m==2) & (subcarriers >= 21)) begin
      txdone <= 1;
      subcarriers <= subcarriers + 6'd1;
    end else if (txstop & !txdone & (m==3) & (subcarriers >= 25)) begin
      txdone <= 1;
      subcarriers <= subcarriers + 6'd1;
    end else if (txstop & (subcarriers==6'b111111)) begin 
      txdone    <= 1;
      txdoneout <= 1;
    end else if (txdone) begin 
      txdoneout <= 1;
    end else if (txstop) begin 
      subcarriers <= subcarriers + 6'd1;
    end
  end
  always @ (posedge evalclk or posedge reset) begin
    if (reset) begin
      previousbit      <= 0;
      currentbit       <= 0;
      phaseinvert      <= 0;
      clkphase         <= 0;
      currentviolation <= 0;
      txstop           <= 0;
      bitoutenable     <= 0;
    end else begin
      if (clkphase == 0 | m == 0) begin
        clkphase         <= 1;
        phaseinvert      <= nextphaseinvert;
        currentbit       <= bitin;
        previousbit      <= currentbit;
        currentviolation <= violationin;
        txstop           <= txstopin;
        if(m==0) bitoutenable <= 1;
      end else begin
        clkphase    <= 0;
        phaseinvert <= millerphaseinvert;
        bitoutenable <= 1;
      end
    end
  end
endmodule
