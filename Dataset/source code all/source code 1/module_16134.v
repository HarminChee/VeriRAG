primitive udp_mux2 (z, a, b, sel);
   output z;
   input  a, b, sel;
   table
      ?   1  1 : 1 ;
      ?   0  1 : 0 ;
      1   ?  0 : 1 ;
      0   ?  0 : 0 ;
      1   1  x : 1 ;
      0   0  x : 0 ;
   endtable
endprimitive
primitive udp_latch (q, clk, d);
   output q; reg q;
   input  clk, d;
   table
      0     1 : ? : 1;
      0     0 : ? : 0;
      1     ? : ? : -;
   endtable
endprimitive
primitive udp_dff (q, clk, d, set_l, clr_l);
   output q;
   input  clk, d, set_l, clr_l;
   reg    q;
   table
      r    0  1  ?  : ? : 0 ;
      r    1  ?  1  : ? : 1 ;
      *    1  ?  1  : 1 : 1 ;
      *    0  1  ?  : 0 : 0 ;
      f    ?  ?  ?  : ? : - ;
      b    *  ?  ?  : ? : - ;
      ?    ?  0  ?  : ? : 1 ;
      b    ?  *  1  : 1 : 1 ;
      x    1  *  1  : 1 : 1 ;
      ?    ?  1  0  : ? : 0 ;
      b    ?  1  *  : 0 : 0 ;
      x    0  1  *  : 0 : 0 ;
   endtable
endprimitive
module t (
   clk
   );
   input clk;
   integer      cyc=0;
   reg [63:0]   crc;
   reg [63:0]   sum;
   wire [31:0]  in = crc[31:0];
   reg          set_l = in[20];
   reg          clr_l = in[21];
   always @ (negedge clk) begin
      set_l <= in[20];
      clr_l <= in[21];
   end
   wire [1:0]           qm;
   udp_mux2 #(0.1) m0 (qm[0], in[0], in[2], in[4]);
   udp_mux2 #0.1   m1 (qm[1], in[1], in[3], in[4]);
`define verilatorxx
`ifdef verilatorxx
   reg [1:0]            ql;
   reg [1:0]            qd;
   always @(posedge clk or negedge set_l or negedge clr_l) begin
      if (!set_l) qd <= ~2'b0;
      else if (!clr_l) qd <= 2'b0;
      else qd <= in[17:16];
   end
`else
   wire [1:0]           qd;
   udp_dff   d0 (qd[0], in[8], in[16], set_l, clr_l);
   udp_dff   d2 (qd[1], in[8], in[17], set_l, clr_l);
`endif
   wire [63:0] result = {52'h0, 2'b0,qd, 4'b0, 2'b0,qm};
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n",$time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63]^crc[2]^crc[0]};
      sum <= result ^ {sum[62:0],sum[63]^sum[2]^sum[0]};
      if (cyc==0) begin
         crc <= 64'h5aef0c8d_d70a4497;
         sum <= 64'h0;
      end
      else if (cyc<10) begin
         sum <= 64'h0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
         $write("[%0t] cyc==%0d crc=%x sum=%x\n",$time, cyc, crc, sum);
         if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'hb73acf228acaeaa3
         if (sum !== `EXPECTED_SUM) $stop;
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
primitive udp_mux2 (z, a, b, sel);
   output z;
   input  a, b, sel;
   table
      ?   1  1 : 1 ;
      ?   0  1 : 0 ;
      1   ?  0 : 1 ;
      0   ?  0 : 0 ;
      1   1  x : 1 ;
      0   0  x : 0 ;
   endtable
endprimitive
primitive udp_latch (q, clk, d);
   output q; reg q;
   input  clk, d;
   table
      0     1 : ? : 1;
      0     0 : ? : 0;
      1     ? : ? : -;
   endtable
endprimitive
primitive udp_dff (q, clk, d, set_l, clr_l);
   output q;
   input  clk, d, set_l, clr_l;
   reg    q;
   table
      r    0  1  ?  : ? : 0 ;
      r    1  ?  1  : ? : 1 ;
      *    1  ?  1  : 1 : 1 ;
      *    0  1  ?  : 0 : 0 ;
      f    ?  ?  ?  : ? : - ;
      b    *  ?  ?  : ? : - ;
      ?    ?  0  ?  : ? : 1 ;
      b    ?  *  1  : 1 : 1 ;
      x    1  *  1  : 1 : 1 ;
      ?    ?  1  0  : ? : 0 ;
      b    ?  1  *  : 0 : 0 ;
      x    0  1  *  : 0 : 0 ;
   endtable
endprimitive
