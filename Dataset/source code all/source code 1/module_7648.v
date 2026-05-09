`timescale 1ns / 1ps
module lens_flat_line(
          pclk,   
          first,  
          next,   
          F0,     
          ERR0,   
          A0,     
          B0,
          F,
          ERR);     
 parameter F_WIDTH= 18; 
 parameter F_SHIFT=22; 
 parameter B_SHIFT=12; 
 parameter A_WIDTH=18; 
 parameter B_WIDTH=21; 
 parameter DF_WIDTH=B_WIDTH-F_SHIFT+B_SHIFT; 
    input                pclk;
    input                first;
    input                next;
    input  [F_WIDTH-1:0] F0;
    input  [F_SHIFT+1:0] ERR0;
    input  [A_WIDTH-1:0] A0;
    input  [B_WIDTH-1:0] B0;
    output [F_WIDTH-1:0] F;
    output [F_SHIFT+1:0] ERR;
    reg    [F_SHIFT+1:0] ERR; 
    reg    [F_SHIFT+1:0] ApB; 
    reg    [F_SHIFT+1:1] A2X; 
    reg    [(DF_WIDTH)-1:0] dF;  
    reg    [F_WIDTH-1:0] F;   
    reg                  next_d, first_d; 
    reg    [F_WIDTH-1:0] F1;
    reg    [A_WIDTH-1:0] A;
    wire   [F_SHIFT+1:0] preERR={A2X[F_SHIFT+1:1],1'b0}+ApB[F_SHIFT+1:0]-{dF[1:0],{F_SHIFT{1'b0}}};
    wire           [1:0] inc=   {preERR[F_SHIFT+1] & (~preERR[F_SHIFT] |  ~preERR[F_SHIFT-1]),
                                (preERR[F_SHIFT+1:F_SHIFT-1] != 3'h0)  & 
                                (preERR[F_SHIFT+1:F_SHIFT-1] != 3'h7)};
    always @(posedge pclk) begin
     first_d <=first;
     next_d  <=next;
      if         (first) begin
        F1 [F_WIDTH-1:0] <=  F0[ F_WIDTH-1:0];
        dF[(DF_WIDTH)-1:0] <= B0[B_WIDTH-1: (F_SHIFT-B_SHIFT)];
        ERR[F_SHIFT+1:0] <= ERR0[F_SHIFT+1:0];
        ApB[F_SHIFT+1:0] <= {{F_SHIFT+2-A_WIDTH{A0[A_WIDTH-1]}},A0[A_WIDTH-1:0]}+{B0[B_WIDTH-1:0],{F_SHIFT-B_SHIFT{1'b0}}}; 
        A  [A_WIDTH-1:0] <= A0[A_WIDTH-1:0];
      end else if (next) begin
        dF[(DF_WIDTH)-1:0] <= dF[(DF_WIDTH)-1:0]+{{((DF_WIDTH)-1){inc[1]}},inc[1:0]};
        ERR[F_SHIFT-1:0]<= preERR[F_SHIFT-1:0];
        ERR[F_SHIFT+1:F_SHIFT]<= preERR[F_SHIFT+1:F_SHIFT]-inc[1:0];
      end
      if     (first_d)   F[F_WIDTH-1:0] <=  F1[ F_WIDTH-1:0];
      else if (next_d)   F[F_WIDTH-1:0] <=  F[F_WIDTH-1:0]+{{(F_WIDTH-(DF_WIDTH)){dF[(DF_WIDTH)-1]}},dF[(DF_WIDTH)-1:0]};
      if     (first_d) A2X[F_SHIFT+1:1] <=                     {{F_SHIFT+2-A_WIDTH{A[A_WIDTH-1]}},A[A_WIDTH-1:0]};
      else if (next)   A2X[F_SHIFT+1:1] <=  A2X[F_SHIFT+1:1] + {{F_SHIFT+2-A_WIDTH{A[A_WIDTH-1]}},A[A_WIDTH-1:0]};
    end 
endmodule
`timescale 1ns / 1ps
module lens_flat (sclk,      
                  wen,       
                  di,        
                  pclk,      
                  fstart,    
                  newline,   
                  linerun,   
                  bayer,
                  pixdi,     
                  pixdo      
                  );
    input         sclk;
    input         wen;
    input  [15:0] di;
    input         pclk;
    input         fstart;
    input         newline;
    input         linerun;
    input  [1:0]  bayer;
    input [15:0]  pixdi;
    output[15:0]  pixdo;
    reg    [ 1:0]  wen_d;
    reg    [23:0] did;
    reg    [23:0] didd;
    reg           we_AX,we_BX,we_AY,we_BY,we_C;
    reg           we_scales;
    reg           we_fatzero_in,we_fatzero_out; 
    reg           we_post_scale;
    reg    [18:0] AX; 
    reg    [18:0] AY; 
    reg    [20:0] BX; 
    reg    [20:0] BY; 
    reg    [18:0] C;  
    reg    [16:0] scales[0:3]; 
    reg    [15:0] fatzero_in;     
    reg    [15:0] fatzero_out;    
    reg    [ 3:0] post_scale;     
    wire   [18:0] FY;    
    wire   [23:0] ERR_Y; 
    wire   [18:0] FXY;   
    reg   [ 4:0] lens_corr_out; 
    reg           bayer_nset; 
    reg           bayer0_latched;
    reg    [1:0]  color;
    wire  [35:0]  mult_first_res;
    reg   [17:0]  mult_first_scaled; 
    wire  [35:0]  mult_second_res;
    reg   [15:0]  pixdo;           
    wire  [20:0]  pre_pixdo_with_zero= mult_second_res[35:15] + {{5{fatzero_out[15]}},fatzero_out[15:0]};
    wire          sync_bayer=linerun && ~lens_corr_out[0];
    wire   [17:0] pix_zero = {2'b0,pixdi[15:0]}-{{2{fatzero_in [15]}},fatzero_in [15:0]};
    always @ (negedge sclk) begin
      wen_d[1:0]   <= {wen_d[0],wen};
      if (wen)      did[15: 0] <= di[15:0];
      if (wen_d[0]) did[23:16] <= di[ 7:0];
      didd[23:0] <= did[23:0];
      we_AX          <= wen_d[1] && (did[23:19]==5'h00); 
      we_AY          <= wen_d[1] && (did[23:19]==5'h01); 
      we_C           <= wen_d[1] && (did[23:19]==5'h02); 
      we_BX          <= wen_d[1] && (did[23:21]==3'h1 ); 
      we_BY          <= wen_d[1] && (did[23:21]==3'h2 ); 
      we_scales      <= wen_d[1] && (did[23:19]==5'h0c); 
      we_fatzero_in  <= wen_d[1] && (did[23:16]==8'h68); 
      we_fatzero_out <= wen_d[1] && (did[23:16]==8'h69); 
      we_post_scale  <= wen_d[1] && (did[23:16]==8'h6a); 
      if (we_AX)  AX[18:0] <= didd[18:0];
      if (we_AY)  AY[18:0] <= didd[18:0];
      if (we_BX)  BX[20:0] <= didd[20:0];
      if (we_BY)  BY[20:0] <= didd[20:0];
      if (we_C)    C[18:0] <= didd[18:0];
      if (we_scales) scales[didd[18:17]] <= didd[16:0];
      if (we_fatzero_in)  fatzero_in [15:0] <= didd[15:0];
      if (we_fatzero_out) fatzero_out[15:0] <= didd[15:0];
      if (we_post_scale)  post_scale [ 3:0] <= didd[ 3:0];
    end
    always @ (posedge pclk) begin
      lens_corr_out[4:0]<={lens_corr_out[3:0],linerun};
      bayer_nset <= !fstart && (bayer_nset || linerun);
      bayer0_latched<= bayer_nset? bayer0_latched:bayer[0];
      color[1:0] <=  { bayer_nset? (sync_bayer ^ color[1]):bayer[1] ,
                   (bayer_nset &&(~sync_bayer))?~color[0]:bayer0_latched };
      case (post_scale [2:0])
        3'h0:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:33]) ? 18'h1ffff:mult_first_res[33:16]; 
        3'h1:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:32]) ? 18'h1ffff:mult_first_res[32:15];
        3'h2:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:31]) ? 18'h1ffff:mult_first_res[31:14];
        3'h3:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:30]) ? 18'h1ffff:mult_first_res[30:13];
        3'h4:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:29]) ? 18'h1ffff:mult_first_res[29:12];
        3'h5:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:28]) ? 18'h1ffff:mult_first_res[28:11];
        3'h6:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:27]) ? 18'h1ffff:mult_first_res[27:10];
        3'h7:mult_first_scaled[17:0]<=  (~mult_first_res[35] & |mult_first_res[34:26]) ? 18'h1ffff:mult_first_res[26: 9];
      endcase
      if (lens_corr_out[4]) pixdo[15:0] <= pre_pixdo_with_zero[20]? 16'h0:   
                                        ((|pre_pixdo_with_zero[19:16])?16'hffff: 
                                                                       pre_pixdo_with_zero[15:0]);
    end
  MULT18X18SIO #(
      .AREG(1), 
      .BREG(1), 
      .B_INPUT("DIRECT"), 
      .PREG(1)  
   ) i_mult_first (
      .BCOUT(), 
      .P(mult_first_res[35:0]),    
      .A((FXY[18]==FXY[17])?FXY[17:0]:(FXY[18]?18'h20000:18'h1ffff)),    
      .B({1'b0,scales[~color[1:0]]}),    
      .BCIN(18'b0), 
      .CEA(lens_corr_out[0]), 
      .CEB(lens_corr_out[0]), 
      .CEP(lens_corr_out[1]), 
      .CLK(pclk), 
      .RSTA(1'b0), 
      .RSTB(1'b0), 
      .RSTP(1'b0)  
   );
  MULT18X18SIO #(
      .AREG(1), 
      .BREG(0), 
      .B_INPUT("DIRECT"), 
      .PREG(1)  
   ) i_mult_second (
      .BCOUT(), 
      .P(mult_second_res[35:0]),    
      .A(pix_zero[17:0]),    
      .B(mult_first_scaled[17:0]),    
      .BCIN(18'b0), 
      .CEA(lens_corr_out[2]), 
      .CEB(lens_corr_out[0]), 
      .CEP(lens_corr_out[3]), 
      .CLK(pclk), 
      .RSTA(1'b0), 
      .RSTB(1'b0), 
      .RSTP(1'b0)  
   );
lens_flat_line #(.F_WIDTH(19), 
                 .F_SHIFT(22), 
                 .B_SHIFT(12), 
                 .A_WIDTH(19), 
                 .B_WIDTH(21))  
     i_fy( .pclk(pclk),    
           .first(fstart), 
           .next(newline), 
           .F0(C[18:0]),   
           .ERR0(24'b0),       
           .A0(AY[18:0]),  
           .B0(BY[20:0]),  
           .F(FY[18:0]),
           .ERR(ERR_Y[23:0]));
lens_flat_line #(.F_WIDTH(19), 
                 .F_SHIFT(22), 
                 .B_SHIFT(12), 
                 .A_WIDTH(19), 
                 .B_WIDTH(21))  
     i_fxy( .pclk(pclk),    
           .first(newline), 
           .next(linerun), 
           .F0(FY[18:0]),  
           .ERR0(ERR_Y[23:0]),       
           .A0(AX[18:0]),  
           .B0(BX[20:0]),  
           .F(FXY[18:0]),
           .ERR());
endmodule
module lens_flat_line(
          pclk,   
          first,  
          next,   
          F0,     
          ERR0,   
          A0,     
          B0,
          F,
          ERR);     
 parameter F_WIDTH= 18; 
 parameter F_SHIFT=22; 
 parameter B_SHIFT=12; 
 parameter A_WIDTH=18; 
 parameter B_WIDTH=21; 
 parameter DF_WIDTH=B_WIDTH-F_SHIFT+B_SHIFT; 
    input                pclk;
    input                first;
    input                next;
    input  [F_WIDTH-1:0] F0;
    input  [F_SHIFT+1:0] ERR0;
    input  [A_WIDTH-1:0] A0;
    input  [B_WIDTH-1:0] B0;
    output [F_WIDTH-1:0] F;
    output [F_SHIFT+1:0] ERR;
    reg    [F_SHIFT+1:0] ERR; 
    reg    [F_SHIFT+1:0] ApB; 
    reg    [F_SHIFT+1:1] A2X; 
    reg    [(DF_WIDTH)-1:0] dF;  
    reg    [F_WIDTH-1:0] F;   
    reg                  next_d, first_d; 
    reg    [F_WIDTH-1:0] F1;
    reg    [A_WIDTH-1:0] A;
    wire   [F_SHIFT+1:0] preERR={A2X[F_SHIFT+1:1],1'b0}+ApB[F_SHIFT+1:0]-{dF[1:0],{F_SHIFT{1'b0}}};
    wire           [1:0] inc=   {preERR[F_SHIFT+1] & (~preERR[F_SHIFT] |  ~preERR[F_SHIFT-1]),
                                (preERR[F_SHIFT+1:F_SHIFT-1] != 3'h0)  & 
                                (preERR[F_SHIFT+1:F_SHIFT-1] != 3'h7)};
    always @(posedge pclk) begin
     first_d <=first;
     next_d  <=next;
      if         (first) begin
        F1 [F_WIDTH-1:0] <=  F0[ F_WIDTH-1:0];
        dF[(DF_WIDTH)-1:0] <= B0[B_WIDTH-1: (F_SHIFT-B_SHIFT)];
        ERR[F_SHIFT+1:0] <= ERR0[F_SHIFT+1:0];
        ApB[F_SHIFT+1:0] <= {{F_SHIFT+2-A_WIDTH{A0[A_WIDTH-1]}},A0[A_WIDTH-1:0]}+{B0[B_WIDTH-1:0],{F_SHIFT-B_SHIFT{1'b0}}}; 
        A  [A_WIDTH-1:0] <= A0[A_WIDTH-1:0];
      end else if (next) begin
        dF[(DF_WIDTH)-1:0] <= dF[(DF_WIDTH)-1:0]+{{((DF_WIDTH)-1){inc[1]}},inc[1:0]};
        ERR[F_SHIFT-1:0]<= preERR[F_SHIFT-1:0];
        ERR[F_SHIFT+1:F_SHIFT]<= preERR[F_SHIFT+1:F_SHIFT]-inc[1:0];
      end
      if     (first_d)   F[F_WIDTH-1:0] <=  F1[ F_WIDTH-1:0];
      else if (next_d)   F[F_WIDTH-1:0] <=  F[F_WIDTH-1:0]+{{(F_WIDTH-(DF_WIDTH)){dF[(DF_WIDTH)-1]}},dF[(DF_WIDTH)-1:0]};
      if     (first_d) A2X[F_SHIFT+1:1] <=                     {{F_SHIFT+2-A_WIDTH{A[A_WIDTH-1]}},A[A_WIDTH-1:0]};
      else if (next)   A2X[F_SHIFT+1:1] <=  A2X[F_SHIFT+1:1] + {{F_SHIFT+2-A_WIDTH{A[A_WIDTH-1]}},A[A_WIDTH-1:0]};
    end 
endmodule
