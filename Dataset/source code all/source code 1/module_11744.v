module Test (
   clk, in
   );
   input clk;
   input [31:0] in;
   reg [31:0]   dly0;
   reg [31:0]   dly1;
   reg [31:0]   dly2;
   reg [31:0]   dly3;
   always @(posedge clk) begin
      dly0 <= in;
      dly1 <= dly0;
      dly2 <= dly1;
      dly3 <= dly2;
      if (dly0 != $past(in)) $stop;
      if (dly0 != $past(in,1)) $stop;
      if (dly1 != $past(in,2)) $stop;
   end
   assert property (@(posedge clk) dly0 == $past(in));
endmodule
module Test2 (
   clk, in
   );
   input clk;
   input [31:0] in;
   reg [31:0]   dly0;
   reg [31:0]   dly1;
   default clocking @(posedge clk); endclocking
   assert property (@(posedge clk) dly1 == $past(in, 2));
endmodule
module t (
   clk
   );
   input clk;
   integer      cyc=0;
   reg [63:0]   crc;
   reg [63:0]   sum;
   wire [31:0]  in = crc[31:0];
   Test test (
              .clk                      (clk),
              .in                       (in[31:0]));
   Test2 test2 (
                .clk                    (clk),
                .in                     (in[31:0]));
   always @ (posedge clk) begin
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63]^crc[2]^crc[0]};
      if (cyc==0) begin
         crc <= 64'h5aef0c8d_d70a4497;
      end
      else if (cyc<10) begin
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
module Test (
   clk, in
   );
   input clk;
   input [31:0] in;
   reg [31:0]   dly0;
   reg [31:0]   dly1;
   reg [31:0]   dly2;
   reg [31:0]   dly3;
   always @(posedge clk) begin
      dly0 <= in;
      dly1 <= dly0;
      dly2 <= dly1;
      dly3 <= dly2;
      if (dly0 != $past(in)) $stop;
      if (dly0 != $past(in,1)) $stop;
      if (dly1 != $past(in,2)) $stop;
   end
   assert property (@(posedge clk) dly0 == $past(in));
endmodule
module Test2 (
   clk, in
   );
   input clk;
   input [31:0] in;
   reg [31:0]   dly0;
   reg [31:0]   dly1;
   default clocking @(posedge clk); endclocking
   assert property (@(posedge clk) dly1 == $past(in, 2));
endmodule
