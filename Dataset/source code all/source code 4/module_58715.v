module Test(
   a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, o1, o2, o3, o4, o5,
   o6, o7, o8, o9, o10, o11, x1, x2, x3, x4, x5, x6, x7, x8, x9, z1,
   z2, z3, z4, z5, z6, z7,
   clk, i
   );
   input clk;
   input [31:0] i;
   output logic a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11;
   output logic o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11;
   output logic x1, x2, x3, x4, x5, x6, x7, x8, x9;
   output logic z1, z2, z3, z4, z5, z6, z7;
   logic [127:0] d;
   logic [17:0]  e;
   always_ff @(posedge clk) d <= {i, ~i, ~i, i};
   always_ff @(posedge clk) e <= i[17:00];
   always_ff @(posedge clk) begin
      a1 <= (i[5] & ~i[3] & i[1]);
      a2 <= (i[5]==1 & i[3]==0 & i[1]==1);
      a3 <= &{i[5], ~i[3], i[1]};
      a4 <= ((i & 32'b101010) == 32'b100010);
      a5 <= ((i & 32'b001010) == 32'b000010) & i[5];
      a6 <= &i[5:3];
      a7 <= i[5] & i[4] & i[3] & i[5] & i[4];
      a8 <= &(~i[5:3]);
      a9 <= ~i[5] & !i[4] & !i[3] && ~i[5] && !i[4];
      a10 <= ~(i[5] & ~d[3]) & (!i[5] & d[1]);  
      a11 <= d[0] & d[33] & d[66] & d[99] & !d[31] & !d[62] & !d[93] & !d[124] & e[0] & !e[1] & e[2];
      o1 <= (~i[5] | i[3] | ~i[1]);
      o2 <= (i[5]!=1 | i[3]!=0 | i[1]!=1);
      o3 <= |{~i[5], i[3], ~i[1]};
      o4 <= ((i & 32'b101010) != 32'b100010);
      o5 <= ((i & 32'b001010) != 32'b000010) | !i[5];
      o6 <= |i[5:3];
      o7 <= i[5] | i[4] | i[3] | i[5] | i[4];
      o8 <= |(~i[5:3]);
      o9 <= ~i[5] | !i[4] | ~i[3] || !i[5] || ~i[4];
      o10 <= ~(~i[5] | d[3]) | (i[5] | ~d[1]);  
      o11 <= d[0] | d[33] | d[66] | d[99] | !d[31] | !d[62] | !d[93] | !d[124] | e[0] | !e[1] | e[2];
      x1 <= (i[5] ^ ~i[3] ^ i[1]);
      x2 <= (i[5]==1 ^ i[3]==0 ^ i[1]==1);
      x3 <= ^{i[5], ~i[3], i[1]};
      x4 <= ^((i & 32'b101010) ^ 32'b001000);
      x5 <= ^((i & 32'b001010) ^ 32'b001000) ^ i[5];
      x6 <= i[5] ^ ~i[3] ^ i[1] ^ i[3] ^ !i[1] ^ i[3] ^ ~i[1];
      x7 <= i[5] ^ (^((i & 32'b001010) ^ 32'b001000));
      x8 <= ~(~i[5] ^ d[3]) ^ (i[5] ^ ~d[1]);
      x9 <= d[0] ^ d[33] ^ d[66] ^ d[99] ^ !d[31] ^ !d[62] ^ !d[93] ^ !d[124] ^ e[0] ^ !e[1] ^ e[2];
      z1 <= (i[5] & ~i[3] & ~i[5]);
      z2 <= (~i[5] | i[3] | i[5]);
      z3 <= (i[5] ^ ~i[3] ^ ~i[5] ^ i[3]);
      z4 <= &(i[0] && !i[0]);
      z5 <= |(i[1] || !i[1]);
      z6 <= ^(i[2] ^ !i[2]);
      z7 <= ^(i[2] ^ i[2]);
   end
endmodule
module match
  (
   input logic [15:0] vec_i,
   input logic        b8_i,
   input logic        b12_i,
   output logic       match1_o,
   output logic       match2_o
   );
   always_comb
     begin
        match1_o = 1'b0;
        if (
            (vec_i[1:0] == 2'b0)
            &&
            (vec_i[4] == 1'b0)
            &&
            (vec_i[8] == b8_i)
            &&
            (vec_i[12] == b12_i)
            )
          begin
             match1_o = 1'b1;
          end
     end
   always_comb
     begin
        match2_o = 1'b0;
        if (
            (vec_i[1:0] == 2'b0)
            &&
            (vec_i[8] == b8_i)
            &&
            (vec_i[12] == b12_i)
            &&
            (vec_i[4] == 1'b0)
            )
          begin
             match2_o = 1'b1;
          end
     end
endmodule
module t(
   clk
   );
   input clk;
   integer cyc = 0;
   reg [63:0] crc;
   reg [63:0] sum;
   wire [31:0] in = crc[31:0];
   logic                a1;                     
   logic                a10;                    
   logic                a11;                    
   logic                a2;                     
   logic                a3;                     
   logic                a4;                     
   logic                a5;                     
   logic                a6;                     
   logic                a7;                     
   logic                a8;                     
   logic                a9;                     
   logic                o1;                     
   logic                o10;                    
   logic                o11;                    
   logic                o2;                     
   logic                o3;                     
   logic                o4;                     
   logic                o5;                     
   logic                o6;                     
   logic                o7;                     
   logic                o8;                     
   logic                o9;                     
   logic                x1;                     
   logic                x2;                     
   logic                x3;                     
   logic                x4;                     
   logic                x5;                     
   logic                x6;                     
   logic                x7;                     
   logic                x8;                     
   logic                x9;                     
   logic                z1;                     
   logic                z2;                     
   logic                z3;                     
   logic                z4;                     
   logic                z5;                     
   logic                z6;                     
   logic                z7;                     
   wire [15:0] vec_i = crc[15:0];
   wire [31:0] i = crc[31:0];
   logic       b8_i;
   logic       b12_i;
   logic       match1_o;
   logic       match2_o;
   Test test(
             .a1                        (a1),
             .a2                        (a2),
             .a3                        (a3),
             .a4                        (a4),
             .a5                        (a5),
             .a6                        (a6),
             .a7                        (a7),
             .a8                        (a8),
             .a9                        (a9),
             .a10                       (a10),
             .a11                       (a11),
             .o1                        (o1),
             .o2                        (o2),
             .o3                        (o3),
             .o4                        (o4),
             .o5                        (o5),
             .o6                        (o6),
             .o7                        (o7),
             .o8                        (o8),
             .o9                        (o9),
             .o10                       (o10),
             .o11                       (o11),
             .x1                        (x1),
             .x2                        (x2),
             .x3                        (x3),
             .x4                        (x4),
             .x5                        (x5),
             .x6                        (x6),
             .x7                        (x7),
             .x8                        (x8),
             .x9                        (x9),
             .z1                        (z1),
             .z2                        (z2),
             .z3                        (z3),
             .z4                        (z4),
             .z5                        (z5),
             .z6                        (z6),
             .z7                        (z7),
             .clk                       (clk),
             .i                         (i[31:0]));
   match i_match(
                 .vec_i ( i[15:0] ),
                 .b8_i ( b8_i ),
                 .b12_i ( b12_i ),
                 .match1_o ( match1_o ),
                 .match2_o ( match2_o )
                 );
   wire [63:0] result = {a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,
                         o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,
                         x1,x2,x3,x4,x5,x6,x7,x8,x9};
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n", $time, cyc, crc, result);
      $display("a %b %b %b %b %b %b %b %b %b %b %b", a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11);
      $display("o %b %b %b %b %b %b %b %b %b %b %b", o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11);
      $display("x %b %b %b %b %b %b %b %b %b", x1, x2, x3, x4, x5, x6, x7, x8, x9);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63] ^ crc[2] ^ crc[0]};
      sum <= result ^ {sum[62:0], sum[63] ^ sum[2] ^ sum[0]};
      if (cyc == 0) begin
         crc <= 64'h5aef0c8d_d70a4497;
         sum <= '0;
         b8_i <= 1'b0;
         b12_i <= 1'b0;
      end
      else if (cyc < 10) begin
         sum <= '0;
      end
      else if (cyc < 99) begin
         if (a1 != a2) $stop;
         if (a1 != a3) $stop;
         if (a1 != a4) $stop;
         if (a1 != a5) $stop;
         if (a6 != a7) $stop;
         if (a8 != a9) $stop;
         if (o1 != o2) $stop;
         if (o1 != o3) $stop;
         if (o1 != o4) $stop;
         if (o1 != o5) $stop;
         if (o6 != o7) $stop;
         if (o8 != o9) $stop;
         if (x1 != x2) $stop;
         if (x1 != x3) $stop;
         if (x1 != x4) $stop;
         if (x1 != x5) $stop;
         if (x1 != x6) $stop;
         if (x1 != x7) $stop;
         if (z1 != '0) $stop;
         if (z2 != '1) $stop;
         if (z3 != '0) $stop;
         if (z4 != '0) $stop;
         if (z5 != '1) $stop;
         if (z6 != '1) $stop;
         if (z7 != '0) $stop;
         if (match1_o != match2_o) begin
            $write("[%0t] cyc==%0d m1=%d != m2=%d\n", $time, cyc, match1_o, match2_o);
            $stop;
         end
      end
      else begin
         $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
         if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'h727fb78d09c1981e
         if (sum !== `EXPECTED_SUM) $stop;
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
module Test(
   a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, o1, o2, o3, o4, o5,
   o6, o7, o8, o9, o10, o11, x1, x2, x3, x4, x5, x6, x7, x8, x9, z1,
   z2, z3, z4, z5, z6, z7,
   clk, i
   );
   input clk;
   input [31:0] i;
   output logic a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11;
   output logic o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11;
   output logic x1, x2, x3, x4, x5, x6, x7, x8, x9;
   output logic z1, z2, z3, z4, z5, z6, z7;
   logic [127:0] d;
   logic [17:0]  e;
   always_ff @(posedge clk) d <= {i, ~i, ~i, i};
   always_ff @(posedge clk) e <= i[17:00];
   always_ff @(posedge clk) begin
      a1 <= (i[5] & ~i[3] & i[1]);
      a2 <= (i[5]==1 & i[3]==0 & i[1]==1);
      a3 <= &{i[5], ~i[3], i[1]};
      a4 <= ((i & 32'b101010) == 32'b100010);
      a5 <= ((i & 32'b001010) == 32'b000010) & i[5];
      a6 <= &i[5:3];
      a7 <= i[5] & i[4] & i[3] & i[5] & i[4];
      a8 <= &(~i[5:3]);
      a9 <= ~i[5] & !i[4] & !i[3] && ~i[5] && !i[4];
      a10 <= ~(i[5] & ~d[3]) & (!i[5] & d[1]);  
      a11 <= d[0] & d[33] & d[66] & d[99] & !d[31] & !d[62] & !d[93] & !d[124] & e[0] & !e[1] & e[2];
      o1 <= (~i[5] | i[3] | ~i[1]);
      o2 <= (i[5]!=1 | i[3]!=0 | i[1]!=1);
      o3 <= |{~i[5], i[3], ~i[1]};
      o4 <= ((i & 32'b101010) != 32'b100010);
      o5 <= ((i & 32'b001010) != 32'b000010) | !i[5];
      o6 <= |i[5:3];
      o7 <= i[5] | i[4] | i[3] | i[5] | i[4];
      o8 <= |(~i[5:3]);
      o9 <= ~i[5] | !i[4] | ~i[3] || !i[5] || ~i[4];
      o10 <= ~(~i[5] | d[3]) | (i[5] | ~d[1]);  
      o11 <= d[0] | d[33] | d[66] | d[99] | !d[31] | !d[62] | !d[93] | !d[124] | e[0] | !e[1] | e[2];
      x1 <= (i[5] ^ ~i[3] ^ i[1]);
      x2 <= (i[5]==1 ^ i[3]==0 ^ i[1]==1);
      x3 <= ^{i[5], ~i[3], i[1]};
      x4 <= ^((i & 32'b101010) ^ 32'b001000);
      x5 <= ^((i & 32'b001010) ^ 32'b001000) ^ i[5];
      x6 <= i[5] ^ ~i[3] ^ i[1] ^ i[3] ^ !i[1] ^ i[3] ^ ~i[1];
      x7 <= i[5] ^ (^((i & 32'b001010) ^ 32'b001000));
      x8 <= ~(~i[5] ^ d[3]) ^ (i[5] ^ ~d[1]);
      x9 <= d[0] ^ d[33] ^ d[66] ^ d[99] ^ !d[31] ^ !d[62] ^ !d[93] ^ !d[124] ^ e[0] ^ !e[1] ^ e[2];
      z1 <= (i[5] & ~i[3] & ~i[5]);
      z2 <= (~i[5] | i[3] | i[5]);
      z3 <= (i[5] ^ ~i[3] ^ ~i[5] ^ i[3]);
      z4 <= &(i[0] && !i[0]);
      z5 <= |(i[1] || !i[1]);
      z6 <= ^(i[2] ^ !i[2]);
      z7 <= ^(i[2] ^ i[2]);
   end
endmodule
module match
  (
   input logic [15:0] vec_i,
   input logic        b8_i,
   input logic        b12_i,
   output logic       match1_o,
   output logic       match2_o
   );
   always_comb
     begin
        match1_o = 1'b0;
        if (
            (vec_i[1:0] == 2'b0)
            &&
            (vec_i[4] == 1'b0)
            &&
            (vec_i[8] == b8_i)
            &&
            (vec_i[12] == b12_i)
            )
          begin
             match1_o = 1'b1;
          end
     end
   always_comb
     begin
        match2_o = 1'b0;
        if (
            (vec_i[1:0] == 2'b0)
            &&
            (vec_i[8] == b8_i)
            &&
            (vec_i[12] == b12_i)
            &&
            (vec_i[4] == 1'b0)
            )
          begin
             match2_o = 1'b1;
          end
     end
endmodule
