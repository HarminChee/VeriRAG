module sd_crc_7(BITVAL, ENABLE, BITSTRB, CLEAR, CRC);
   input        BITVAL;                            
   input        ENABLE;                            
   input        BITSTRB;                           
   input        CLEAR;                             
   output [6:0] CRC;                               
   reg    [6:0] CRC;                               
   wire         inv;
   assign inv = BITVAL ^ CRC[6];                   
   always @(posedge BITSTRB or posedge CLEAR) begin
      if (CLEAR) begin
         CRC <= 0;                                  
         end
      else begin
         if (ENABLE == 1) begin
             CRC[6] <= CRC[5];
             CRC[5] <= CRC[4];
             CRC[4] <= CRC[3];
             CRC[3] <= CRC[2] ^ inv;
             CRC[2] <= CRC[1];
             CRC[1] <= CRC[0];
             CRC[0] <= inv;
             end
         end
      end
endmodule
