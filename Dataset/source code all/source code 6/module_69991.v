module cf_fir_3_8_8_1 (clock_c, i1, i2, i3, i4, i5, i6, o1);
input  clock_c;
input  i1;
input  [7:0] i2;
input  [7:0] i3;
input  [7:0] i4;
input  [7:0] i5;
input  [7:0] i6;
output [17:0] o1;
wire   n1;
wire   n2;
wire   [17:0] s3_1;
assign n1 = 1'b1;
assign n2 = 1'b0;
cf_fir_3_8_8_2 s3 (clock_c, n1, n2, i1, i2, i3, i4, i5, i6, s3_1);
assign o1 = s3_1;
endmodule
module cf_fir_3_8_8_2 (clock_c, i1, i2, i3, i4, i5, i6, i7, i8, o1);
input  clock_c;
input  i1;
input  i2;
input  i3;
input  [7:0] i4;
input  [7:0] i5;
input  [7:0] i6;
input  [7:0] i7;
input  [7:0] i8;
output [17:0] o1;
reg    [7:0] n1;
reg    [7:0] n2;
reg    [7:0] n3;
reg    [7:0] n4;
wire   n5;
wire   [17:0] n6;
wire   n7;
wire   [17:0] n8;
wire   [17:0] n9;
reg    [17:0] n10;
wire   [16:0] s11_1;
wire   [16:0] s11_2;
wire   [15:0] s12_1;
wire   [15:0] s12_2;
wire   [15:0] s12_3;
wire   [15:0] s12_4;
always @ (posedge clock_c)
begin
  if (i3 == 1'b1)
    n1 <= 8'b00000000;
  else if (i1 == 1'b1)
    n1 <= i8;
  if (i3 == 1'b1)
    n2 <= 8'b00000000;
  else if (i1 == 1'b1)
    n2 <= n1;
  if (i3 == 1'b1)
    n3 <= 8'b00000000;
  else if (i1 == 1'b1)
    n3 <= n2;
  if (i3 == 1'b1)
    n4 <= 8'b00000000;
  else if (i1 == 1'b1)
    n4 <= n3;
  if (i2 == 1'b1)
    n10 <= 18'b000000000000000000;
  else if (i1 == 1'b1)
    n10 <= n9;
end
assign n5 = s11_1[16];
assign n6 = {n5, s11_1};
assign n7 = s11_2[16];
assign n8 = {n7, s11_2};
assign n9 = n6 + n8;
cf_fir_3_8_8_4 s11 (clock_c, i1, i2, s12_1, s12_2, s12_3, s12_4, s11_1, s11_2);
cf_fir_3_8_8_3 s12 (clock_c, i1, i2, i4, i5, i6, i7, n1, n2, n3, n4, s12_1, s12_2, s12_3, s12_4);
assign o1 = n10;
endmodule
module cf_fir_3_8_8_3 (clock_c, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, o1, o2, o3, o4);
input  clock_c;
input  i1;
input  i2;
input  [7:0] i3;
input  [7:0] i4;
input  [7:0] i5;
input  [7:0] i6;
input  [7:0] i7;
input  [7:0] i8;
input  [7:0] i9;
input  [7:0] i10;
output [15:0] o1;
output [15:0] o2;
output [15:0] o3;
output [15:0] o4;
wire   [15:0] n1;
reg    [15:0] n2;
wire   [15:0] n3;
reg    [15:0] n4;
wire   [15:0] n5;
reg    [15:0] n6;
wire   [15:0] n7;
reg    [15:0] n8;
assign n1 = {8'b00000000, i3} * {8'b00000000, i7};
always @ (posedge clock_c)
begin
  if (i2 == 1'b1)
    n2 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n2 <= n1;
  if (i2 == 1'b1)
    n4 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n4 <= n3;
  if (i2 == 1'b1)
    n6 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n6 <= n5;
  if (i2 == 1'b1)
    n8 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n8 <= n7;
end
assign n3 = {8'b00000000, i4} * {8'b00000000, i8};
assign n5 = {8'b00000000, i5} * {8'b00000000, i9};
assign n7 = {8'b00000000, i6} * {8'b00000000, i10};
assign o4 = n8;
assign o3 = n6;
assign o2 = n4;
assign o1 = n2;
endmodule
module cf_fir_3_8_8_4 (clock_c, i1, i2, i3, i4, i5, i6, o1, o2);
input  clock_c;
input  i1;
input  i2;
input  [15:0] i3;
input  [15:0] i4;
input  [15:0] i5;
input  [15:0] i6;
output [16:0] o1;
output [16:0] o2;
wire   n1;
wire   [16:0] n2;
wire   n3;
wire   [16:0] n4;
wire   [16:0] n5;
reg    [16:0] n6;
wire   n7;
wire   [16:0] n8;
wire   n9;
wire   [16:0] n10;
wire   [16:0] n11;
reg    [16:0] n12;
assign n1 = i3[15];
assign n2 = {n1, i3};
assign n3 = i4[15];
assign n4 = {n3, i4};
assign n5 = n2 + n4;
always @ (posedge clock_c)
begin
  if (i2 == 1'b1)
    n6 <= 17'b00000000000000000;
  else if (i1 == 1'b1)
    n6 <= n5;
  if (i2 == 1'b1)
    n12 <= 17'b00000000000000000;
  else if (i1 == 1'b1)
    n12 <= n11;
end
assign n7 = i5[15];
assign n8 = {n7, i5};
assign n9 = i6[15];
assign n10 = {n9, i6};
assign n11 = n8 + n10;
assign o2 = n12;
assign o1 = n6;
endmodule
module cf_fir_3_8_8 (clock_c, reset_i, data_i, k0_i, k1_i, k2_i, k3_i, data_o);
input  clock_c;
input  reset_i;
input  [7:0] data_i;
input  [7:0] k0_i;
input  [7:0] k1_i;
input  [7:0] k2_i;
input  [7:0] k3_i;
output [17:0] data_o;
wire   [17:0] n1;
cf_fir_3_8_8_1 s1 (clock_c, reset_i, k0_i, k1_i, k2_i, k3_i, data_i, n1);
assign data_o = n1;
endmodule
module cf_fir_3_8_8_1 (clock_c, i1, i2, i3, i4, i5, i6, o1);
input  clock_c;
input  i1;
input  [7:0] i2;
input  [7:0] i3;
input  [7:0] i4;
input  [7:0] i5;
input  [7:0] i6;
output [17:0] o1;
wire   n1;
wire   n2;
wire   [17:0] s3_1;
assign n1 = 1'b1;
assign n2 = 1'b0;
cf_fir_3_8_8_2 s3 (clock_c, n1, n2, i1, i2, i3, i4, i5, i6, s3_1);
assign o1 = s3_1;
endmodule
module cf_fir_3_8_8_2 (clock_c, i1, i2, i3, i4, i5, i6, i7, i8, o1);
input  clock_c;
input  i1;
input  i2;
input  i3;
input  [7:0] i4;
input  [7:0] i5;
input  [7:0] i6;
input  [7:0] i7;
input  [7:0] i8;
output [17:0] o1;
reg    [7:0] n1;
reg    [7:0] n2;
reg    [7:0] n3;
reg    [7:0] n4;
wire   n5;
wire   [17:0] n6;
wire   n7;
wire   [17:0] n8;
wire   [17:0] n9;
reg    [17:0] n10;
wire   [16:0] s11_1;
wire   [16:0] s11_2;
wire   [15:0] s12_1;
wire   [15:0] s12_2;
wire   [15:0] s12_3;
wire   [15:0] s12_4;
always @ (posedge clock_c)
begin
  if (i3 == 1'b1)
    n1 <= 8'b00000000;
  else if (i1 == 1'b1)
    n1 <= i8;
  if (i3 == 1'b1)
    n2 <= 8'b00000000;
  else if (i1 == 1'b1)
    n2 <= n1;
  if (i3 == 1'b1)
    n3 <= 8'b00000000;
  else if (i1 == 1'b1)
    n3 <= n2;
  if (i3 == 1'b1)
    n4 <= 8'b00000000;
  else if (i1 == 1'b1)
    n4 <= n3;
  if (i2 == 1'b1)
    n10 <= 18'b000000000000000000;
  else if (i1 == 1'b1)
    n10 <= n9;
end
assign n5 = s11_1[16];
assign n6 = {n5, s11_1};
assign n7 = s11_2[16];
assign n8 = {n7, s11_2};
assign n9 = n6 + n8;
cf_fir_3_8_8_4 s11 (clock_c, i1, i2, s12_1, s12_2, s12_3, s12_4, s11_1, s11_2);
cf_fir_3_8_8_3 s12 (clock_c, i1, i2, i4, i5, i6, i7, n1, n2, n3, n4, s12_1, s12_2, s12_3, s12_4);
assign o1 = n10;
endmodule
module cf_fir_3_8_8_3 (clock_c, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, o1, o2, o3, o4);
input  clock_c;
input  i1;
input  i2;
input  [7:0] i3;
input  [7:0] i4;
input  [7:0] i5;
input  [7:0] i6;
input  [7:0] i7;
input  [7:0] i8;
input  [7:0] i9;
input  [7:0] i10;
output [15:0] o1;
output [15:0] o2;
output [15:0] o3;
output [15:0] o4;
wire   [15:0] n1;
reg    [15:0] n2;
wire   [15:0] n3;
reg    [15:0] n4;
wire   [15:0] n5;
reg    [15:0] n6;
wire   [15:0] n7;
reg    [15:0] n8;
assign n1 = {8'b00000000, i3} * {8'b00000000, i7};
always @ (posedge clock_c)
begin
  if (i2 == 1'b1)
    n2 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n2 <= n1;
  if (i2 == 1'b1)
    n4 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n4 <= n3;
  if (i2 == 1'b1)
    n6 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n6 <= n5;
  if (i2 == 1'b1)
    n8 <= 16'b0000000000000000;
  else if (i1 == 1'b1)
    n8 <= n7;
end
assign n3 = {8'b00000000, i4} * {8'b00000000, i8};
assign n5 = {8'b00000000, i5} * {8'b00000000, i9};
assign n7 = {8'b00000000, i6} * {8'b00000000, i10};
assign o4 = n8;
assign o3 = n6;
assign o2 = n4;
assign o1 = n2;
endmodule
module cf_fir_3_8_8_4 (clock_c, i1, i2, i3, i4, i5, i6, o1, o2);
input  clock_c;
input  i1;
input  i2;
input  [15:0] i3;
input  [15:0] i4;
input  [15:0] i5;
input  [15:0] i6;
output [16:0] o1;
output [16:0] o2;
wire   n1;
wire   [16:0] n2;
wire   n3;
wire   [16:0] n4;
wire   [16:0] n5;
reg    [16:0] n6;
wire   n7;
wire   [16:0] n8;
wire   n9;
wire   [16:0] n10;
wire   [16:0] n11;
reg    [16:0] n12;
assign n1 = i3[15];
assign n2 = {n1, i3};
assign n3 = i4[15];
assign n4 = {n3, i4};
assign n5 = n2 + n4;
always @ (posedge clock_c)
begin
  if (i2 == 1'b1)
    n6 <= 17'b00000000000000000;
  else if (i1 == 1'b1)
    n6 <= n5;
  if (i2 == 1'b1)
    n12 <= 17'b00000000000000000;
  else if (i1 == 1'b1)
    n12 <= n11;
end
assign n7 = i5[15];
assign n8 = {n7, i5};
assign n9 = i6[15];
assign n10 = {n9, i6};
assign n11 = n8 + n10;
assign o2 = n12;
assign o1 = n6;
endmodule
