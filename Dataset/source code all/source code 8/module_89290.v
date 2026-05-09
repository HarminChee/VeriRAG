`timescale 1 ns/ 100 ps
`timescale 1 ns/ 100 ps
module rgb_bram(
        tft_on_reg,  
  tft_clk,           
  tft_rst,           
  plb_clk,           
  plb_rst,           
  BRAM_TFT_rd,       
  BRAM_TFT_oe,       
  PLB_BRAM_data,     
  PLB_BRAM_addr_en,  
  PLB_BRAM_addr_lsb, 
  PLB_BRAM_we,       
  R0,R1,R2,R3,R4,R5, 
  G0,G1,G2,G3,G4,G5, 
  B0,B1,B2,B3,B4,B5  
);
  input        tft_on_reg;
  input        tft_clk;
  input        tft_rst;
  input        plb_clk;
  input        plb_rst;
  input        BRAM_TFT_rd;
  input        BRAM_TFT_oe;
  input [0:63] PLB_BRAM_data;
  input [0:1]  PLB_BRAM_addr_lsb;
  input        PLB_BRAM_addr_en;
  input        PLB_BRAM_we;
  output       R0,R1,R2,R3,R4,R5;
  output       G0,G1,G2,G3,G4,G5;
  output       B0,B1,B2,B3,B4,B5;
  wire [0:1]  nc0,nc1,nc2,nc3,nc4,nc5;
  wire [5:0]  BRAM_TFT_R_data;
  wire [5:0]  BRAM_TFT_G_data;
  wire [5:0]  BRAM_TFT_B_data;  
  reg         R0,R1,R2,R3,R4,R5;
  reg         G0,G1,G2,G3,G4,G5;
  reg         B0,B1,B2,B3,B4,B5;
  reg  [0:9]  BRAM_TFT_addr;
  reg  [0:6]  PLB_BRAM_addr;
  reg         tc;
  always @(posedge tft_clk)
  begin
    if (tft_rst | ~BRAM_TFT_rd) begin
      BRAM_TFT_addr = 10'b0;
      tc = 1'b0;
    end
    else begin
      if (BRAM_TFT_rd & tc == 0) begin
        if (BRAM_TFT_addr == 10'd639) begin
          BRAM_TFT_addr = 10'b0;
          tc = 1'b1;
        end
        else begin
          BRAM_TFT_addr = BRAM_TFT_addr + 1;
          tc = 1'b0;
        end
      end
    end
  end
  always @(posedge plb_clk)
  begin
    if (plb_rst) begin
      PLB_BRAM_addr = 7'b0;
    end
    else begin
      if (PLB_BRAM_addr_en) begin
        if (PLB_BRAM_addr == 7'd79) begin
          PLB_BRAM_addr = 7'b0;
        end
        else begin
          PLB_BRAM_addr = PLB_BRAM_addr + 1;
        end
      end
    end
  end
RAMB16_S18_S36 RGB_BRAM (
  .ADDRA (BRAM_TFT_addr),                                            
  .CLKA  (tft_clk),                                                  
  .DIA   (16'b0),                                                    
  .DIPA  (2'b0),                                                     
  .DOA   ({BRAM_TFT_R_data, BRAM_TFT_G_data, BRAM_TFT_B_data[5:2]}), 
  .DOPA  (BRAM_TFT_B_data[1:0]),                                     
  .ENA   (BRAM_TFT_rd),                                              
  .SSRA  (~tft_on_reg | tft_rst | ~BRAM_TFT_rd), 
  .WEA   (1'b0),                                                     
  .ADDRB ({PLB_BRAM_addr,PLB_BRAM_addr_lsb}), 
  .CLKB  (plb_clk),                           
  .DIB   ({PLB_BRAM_data[40:45], PLB_BRAM_data[48:53], PLB_BRAM_data[56:59],
           PLB_BRAM_data[8:13],  PLB_BRAM_data[16:21], PLB_BRAM_data[24:27]}), 
  .DIPB  ({PLB_BRAM_data[60:61], PLB_BRAM_data[28:29]}),                       
  .DOB   (),             
  .DOPB  (),             
  .ENB   (PLB_BRAM_we),  
  .SSRB  (1'b0),         
  .WEB   (PLB_BRAM_we)   
  );
  always @(posedge tft_clk)
    if (!BRAM_TFT_oe)
    begin
      R0 = 1'b0;
      R1 = 1'b0;
      R2 = 1'b0;
      R3 = 1'b0;
      R4 = 1'b0;
      R5 = 1'b0;
      G0 = 1'b0;
      G1 = 1'b0;
      G2 = 1'b0;
      G3 = 1'b0;
      G4 = 1'b0;
      G5 = 1'b0;
      B0 = 1'b0;
      B1 = 1'b0;
      B2 = 1'b0;
      B3 = 1'b0;
      B4 = 1'b0;
      B5 = 1'b0;
    end
    else
    begin
      R0 = BRAM_TFT_R_data[0];
      R1 = BRAM_TFT_R_data[1];
      R2 = BRAM_TFT_R_data[2];
      R3 = BRAM_TFT_R_data[3];
      R4 = BRAM_TFT_R_data[4];
      R5 = BRAM_TFT_R_data[5];
      G0 = BRAM_TFT_G_data[0];
      G1 = BRAM_TFT_G_data[1];
      G2 = BRAM_TFT_G_data[2];
      G3 = BRAM_TFT_G_data[3];
      G4 = BRAM_TFT_G_data[4];
      G5 = BRAM_TFT_G_data[5];
      B0 = BRAM_TFT_B_data[0];
      B1 = BRAM_TFT_B_data[1];
      B2 = BRAM_TFT_B_data[2];
      B3 = BRAM_TFT_B_data[3];
      B4 = BRAM_TFT_B_data[4];
      B5 = BRAM_TFT_B_data[5];
    end      
endmodule
