//`include "utils.vh"
`define log2 
`define ARR1D2D
module mpram_lvt
 #(  parameter MEMD = 16, 
     parameter DATW = 32, 
     parameter nRPF = 2 , 
     parameter nWPF = 2 , 
     parameter nRPS = 2 , 
     parameter nWPS = 2 , 
     parameter LVTA = "", 
     parameter WAWB = 1 , 
     parameter RAWB = 1 , 
     parameter RDWB = 0 , 
     parameter FILE = ""  
  )( input                                    clk  ,  
     input                                    rdWr ,  
     input      [            (nWPF+nWPS)-1:0] WEnb ,  
     input      [`log2(MEMD)*(nWPF+nWPS)-1:0] WAddr,  
     input      [DATW       *(nWPF+nWPS)-1:0] WData,  
     input      [`log2(MEMD)*(nRPF+nRPS)-1:0] RAddr,  
     output reg [DATW       *(nRPF+nRPS)-1:0] RData); 
  localparam nWPT = nWPF+nWPS                 ; 
  localparam nRPT = nRPF+nRPS                 ; 
  localparam ADRW = `log2(MEMD)               ; 
  localparam LVTW = `log2(nWPT)               ; 
  localparam SELW = (LVTA=="LVT1HT")?nWPT:LVTW; 
  reg  [ADRW     -1:0] WAddr2D  [nWPT-1:0]          ; 
  reg  [DATW     -1:0] WData2D  [nWPT-1:0]          ; 
  wire [DATW*nRPT-1:0] RData2Di [nWPT-1:0]          ; 
  reg  [DATW     -1:0] RData3Di [nWPT-1:0][nRPT-1:0]; 
  wire [DATW     -1:0] RData2D  [nRPT-1:0]          ; 
  wire [SELW*nRPT-1:0] RBank                        ; 
  reg  [SELW     -1:0] RBank2D  [nRPT-1:0]          ; 
  `ARRINIT;
  always @* begin
    `ARR1D2D(nWPT,     ADRW,WAddr   ,WAddr2D );
    `ARR1D2D(nWPT,     DATW,WData   ,WData2D );
    `ARR2D3D(nWPT,nRPT,DATW,RData2Di,RData3Di);
    `ARR2D1D(nRPT,     DATW,RData2D ,RData   );
    `ARR1D2D(nRPT,     SELW,RBank   ,RBank2D );
  end
  generate
    if (LVTA=="LVTREG") begin
      lvt_reg  #( .MEMD  (MEMD    ),  
                  .nRP   (nRPT    ),  
                  .nWP   (nWPT    ),  
                  .RDWB  (RDWB    ),  
                  .ZERO  (FILE!=""),  
                  .FILE  (""      ))  
      lvt_reg_i ( .clk   (clk     ),  
                  .WEnb  (WEnb    ),  
                  .WAddr (WAddr   ),  
                  .RAddr (RAddr   ),  
                  .RBank (RBank   )); 
    end
    else if (LVTA=="LVTBIN") begin
      lvt_bin  #( .MEMD  (MEMD    ),  
                  .nRP   (nRPT    ),  
                  .nWP   (nWPT    ),  
                  .WAWB  (WAWB    ),  
                  .RAWB  (RAWB    ),  
                  .RDWB  (RDWB    ),  
                  .ZERO  (FILE!=""),  
                  .FILE  (""      ))  
      lvt_bin_i ( .clk   (clk     ),  
                  .WEnb  (WEnb    ),  
                  .WAddr (WAddr   ),  
                  .RAddr (RAddr   ),  
                  .RBank (RBank   )); 
    end
    else begin
      lvt_1ht  #( .MEMD  (MEMD    ),  
                  .nRP   (nRPT    ),  
                  .nWP   (nWPT    ),  
                  .WAWB  (WAWB    ),  
                  .RAWB  (RAWB    ),  
                  .RDWB  (RDWB    ),  
                  .ZERO  (FILE!=""),  
                  .FILE  (""      ))  
      lvt_1ht_i ( .clk   (clk     ),  
                  .WEnb  (WEnb    ),  
                  .WAddr (WAddr   ),  
                  .RAddr (RAddr   ),  
                  .RBank (RBank   )); 
    end
  endgenerate
  genvar wpi,rpi;
  generate
    for (wpi=0 ; wpi<nWPT ; wpi=wpi+1) begin: RPORTwpi
      if (wpi<nWPF)
        mrram      #( .MEMD  (MEMD         ),  
                      .DATW  (DATW         ),  
                      .nRP   (nRPT         ),  
                      .BYPS  (RDWB         ),  
                      .ZERO  (0            ),  
                      .FILE  (wpi?"":FILE  ))  
        mrram_i     ( .clk   (clk          ),  
                      .WEnb  (WEnb[wpi]    ),  
                      .WAddr (WAddr2D[wpi] ),  
                      .WData (WData2D[wpi] ),  
                      .RAddr (RAddr        ),  
                      .RData (RData2Di[wpi])); 
      else
        mrram_swt  #( .MEMD  (MEMD         ),  
                      .DATW  (DATW         ),  
                      .nRPF  (nRPF         ),  
                      .nRPS  (nRPS         ),  
                      .BYPS  (RDWB         ),  
                      .ZERO  (0            ),  
                      .FILE  (wpi?"":FILE  ))  
        mrram_swt_i ( .clk   (clk          ),  
                      .rdWr  (rdWr         ),  
                      .WEnb  (WEnb[wpi]    ),  
                      .WAddr (WAddr2D[wpi] ),  
                      .WData (WData2D[wpi] ),  
                      .RAddr (RAddr        ),  
                      .RData (RData2Di[wpi])); 
    end
    for (rpi=0 ; rpi<nRPT ; rpi=rpi+1) begin: PORTrpi
      if (LVTA=="LVT1HT") begin
        for (wpi=0 ; wpi<nWPT ; wpi=wpi+1) begin: PORTwpi
          assign RData2D[rpi] = RBank2D[rpi][wpi] ? RData3Di[wpi][rpi] : {DATW{1'bz}};
        end
      end
      else begin
        assign RData2D[rpi] = RData3Di[RBank2D[rpi]][rpi];
      end
    end
  endgenerate
endmodule
