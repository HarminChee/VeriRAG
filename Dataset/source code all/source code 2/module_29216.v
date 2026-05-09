module appendix2 (
                  z,
                  i
                  );
   input          i; 
   output [11:10] z;                    
   appendix1 apx10 (
                    .z                  (z[10]),                 
                    .i                  (i));
   appendix1 apx11 (
                    .z                  (z[11]),                 
                    .i                  (i));
endmodule
module appendix1 (
                  z,
                  i
                  );
   input  i;
   output z;
   reg    z;
   always @ (i) begin
      z  = i;
   end
endmodule
module appendix2 (
                  z,
                  i
                  );
   input          i; 
   output [11:10] z;                    
   appendix1 apx10 (
                    .z                  (z[10]),                 
                    .i                  (i));
   appendix1 apx11 (
                    .z                  (z[11]),                 
                    .i                  (i));
endmodule
