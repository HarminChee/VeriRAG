module tail_offset (ir, toff_0_0, toff_1_0, toff_2_0, toff_3_0, toff_4_0, toff_5_0, toff_6_0, toff_7_0, toff_8_0, toff_9_0, toff_10_0, toff_11_0, toff_12_0, toff_13_0, toff_14_0, toff_15_0);
input  [63:0] ir;
output [3:0] toff_0_0, toff_1_0, toff_2_0, toff_3_0, toff_4_0, toff_5_0, toff_6_0, toff_7_0, toff_8_0, toff_9_0, toff_10_0, toff_11_0, toff_12_0, toff_13_0, toff_14_0, toff_15_0;
reg [3:0] toff_0_0, toff_1_1, toff_2_2, toff_3_3, toff_4_4, toff_5_5, toff_6_6, toff_7_7, toff_8_8, toff_9_9, toff_10_10, toff_11_11, toff_12_12, toff_13_13, toff_14_14, toff_15_15;
reg [3:0] ir0, ir1, ir2, ir3, ir4, ir5, ir6, ir7, ir8, ir9, ir10, ir11, ir12, ir13, ir14, ir15;
reg [3:0] toff_1_0, toff_3_2, toff_2_0, toff_3_0, toff_5_4, toff_7_6, toff_6_4, toff_7_4, toff_4_0, toff_5_0, toff_6_0, toff_7_0, toff_9_8, toff_11_10, toff_10_8, toff_11_8, toff_8_0, toff_9_0, toff_10_0, toff_11_0;
wire [3:0] tlen_1, tlen_2, tlen_3, tlen_4, tlen_5, tlen_6, tlen_7, tlen_8, tlen_9, tlen_10, tlen_11, tlen_12, tlen_13, tlen_14;
tail_length u_len1 (.ir(ir1), .len(tlen_1));
tail_length u_len2 (.ir(ir2), .len(tlen_2));
tail_length u_len3 (.ir(ir3), .len(tlen_3));
tail_length u_len4 (.ir(ir4), .len(tlen_4));
tail_length u_len5 (.ir(ir5), .len(tlen_5));
tail_length u_len6 (.ir(ir6), .len(tlen_6));
tail_length u_len7 (.ir(ir7), .len(tlen_7));
tail_length u_len8 (.ir(ir8), .len(tlen_8));
tail_length u_len9 (.ir(ir9), .len(tlen_9));
tail_length u_len10 (.ir(ir10), .len(tlen_10));
tail_length u_len11 (.ir(ir11), .len(tlen_11));
tail_length u_len12 (.ir(ir12), .len(tlen_12));
tail_length u_len13 (.ir(ir13), .len(tlen_13));
always @ (ir) { ir15, ir14, ir13, ir12, ir11, ir10, ir9, ir8, ir7, ir6, ir5, ir4, ir3, ir2, ir1, ir0 } = ir;
always @ ( toff_0_0, toff_1_1, toff_2_2, toff_3_3, toff_4_4, toff_5_5, toff_6_6, toff_7_7, toff_8_8, toff_9_9, toff_10_10, toff_11_11 )
begin
  toff_1_0 = toff_1_1 + toff_0_0;
  toff_3_2 = toff_3_3 + toff_2_2;
  toff_2_0 = toff_2_2 + toff_1_0;
  toff_3_0 = toff_3_2 + toff_1_0;
  toff_5_4 = toff_5_5 + toff_4_4;
  toff_7_6 = toff_7_7 + toff_6_6;
  toff_6_4 = toff_6_6 + toff_5_4;
  toff_7_4 = toff_7_6 + toff_5_4;
  toff_4_0 = toff_4_4 + toff_3_0;
  toff_5_0 = toff_5_4 + toff_3_0;
  toff_6_0 = toff_6_4 + toff_3_0;
  toff_7_0 = toff_7_4 + toff_3_0;
  toff_9_8 = toff_9_9 + toff_8_8;
  toff_11_10 = toff_11_11 + toff_10_10;
  toff_10_8 = toff_10_10 + toff_9_8;
  toff_11_8 = toff_11_10 + toff_9_8;
  toff_8_0 = toff_8_8 + toff_7_0;
  toff_9_0 = toff_9_8 + toff_7_0;
  toff_10_0 = toff_10_8 + toff_7_0;
  toff_11_0 = toff_11_8 + toff_7_0;;
end
endmodule
