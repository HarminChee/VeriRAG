interface handshake #(
   parameter int unsigned WC = 32
)(
   input logic clk,
   input logic rst
);
   logic req;  
   logic grt;  
   logic inc;  
   integer cnt;  
   modport src (
      output req,
      input  grt
   );
   modport drn (
      input  req,
      output grt
   );
   assign inc = req & grt;
   always @ (posedge clk, posedge rst)
   if (rst) cnt <= '0;
   else     cnt <= cnt + {31'h0, inc};
endinterface : handshake
module source #(
   parameter int unsigned RW=1,   
   parameter bit [RW-1:0] RP='0,  
   parameter bit [RW-1:0] RR='1   
)(
   input logic    clk,
   input logic    rst,
   handshake.src  inf,
   output integer cnt
);
   logic [RW-1:0] rnd;
   always @ (posedge clk, posedge rst)
   if (rst) rnd <= RR;
   else     rnd <= {rnd[0], rnd[RW-1:1]} ^ ({RW{rnd[0]}} & RP);
   always @ (posedge clk, posedge rst)
   if (rst) cnt <= 32'd0;
   else     cnt <= cnt + {31'd0, (inf.req & inf.grt)};
   assign inf.req = rnd[0];
endmodule : source
module drain #(
   parameter int unsigned RW=1,   
   parameter bit [RW-1:0] RP='0,  
   parameter bit [RW-1:0] RR='1   
)(
   input logic    clk,
   input logic    rst,
   handshake.drn  inf,
   output integer cnt
);
   logic [RW-1:0] rnd;
   always @ (posedge clk, posedge rst)
   if (rst) rnd <= RR;
   else     rnd <= {rnd[0], rnd[RW-1:1]} ^ ({RW{rnd[0]}} & RP);
   always @ (posedge clk, posedge rst)
   if (rst) cnt <= 32'd0;
   else     cnt <= cnt + {31'd0, (inf.req & inf.grt)};
   assign inf.grt = rnd[0];
endmodule : drain
module t (
   clk
   );
   input clk;
   logic   rst = 1'b1;  
   integer rst_cnt = 0;
   always @ (posedge clk)
   begin
      rst_cnt <= rst_cnt + 1;
      rst     <= rst_cnt <= 3;
   end
   int cnt;
   int cnt_src;
   int cnt_drn;
   assign cnt = cnt_src + cnt_drn + inf.cnt;
   always @ (posedge clk)
   if (cnt == 3*16) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
   handshake inf (
      .clk (clk),
      .rst (rst)
   );
   source #(
      .RW  (8),
      .RP  (8'b11100001)
   ) source (
      .clk  (clk),
      .rst  (rst),
      .inf  (inf),
      .cnt  (cnt_src)
   );
   drain #(
      .RW  (8),
      .RP  (8'b11010100)
   ) drain (
      .clk  (clk),
      .rst  (rst),
      .inf  (inf),
      .cnt  (cnt_drn)
   );
endmodule : t
interface handshake #(
   parameter int unsigned WC = 32
)(
   input logic clk,
   input logic rst
);
   logic req;  
   logic grt;  
   logic inc;  
   integer cnt;  
   modport src (
      output req,
      input  grt
   );
   modport drn (
      input  req,
      output grt
   );
   assign inc = req & grt;
   always @ (posedge clk, posedge rst)
   if (rst) cnt <= '0;
   else     cnt <= cnt + {31'h0, inc};
endinterface : handshake
module source #(
   parameter int unsigned RW=1,   
   parameter bit [RW-1:0] RP='0,  
   parameter bit [RW-1:0] RR='1   
)(
   input logic    clk,
   input logic    rst,
   handshake.src  inf,
   output integer cnt
);
   logic [RW-1:0] rnd;
   always @ (posedge clk, posedge rst)
   if (rst) rnd <= RR;
   else     rnd <= {rnd[0], rnd[RW-1:1]} ^ ({RW{rnd[0]}} & RP);
   always @ (posedge clk, posedge rst)
   if (rst) cnt <= 32'd0;
   else     cnt <= cnt + {31'd0, (inf.req & inf.grt)};
   assign inf.req = rnd[0];
endmodule : source
module drain #(
   parameter int unsigned RW=1,   
   parameter bit [RW-1:0] RP='0,  
   parameter bit [RW-1:0] RR='1   
)(
   input logic    clk,
   input logic    rst,
   handshake.drn  inf,
   output integer cnt
);
   logic [RW-1:0] rnd;
   always @ (posedge clk, posedge rst)
   if (rst) rnd <= RR;
   else     rnd <= {rnd[0], rnd[RW-1:1]} ^ ({RW{rnd[0]}} & RP);
   always @ (posedge clk, posedge rst)
   if (rst) cnt <= 32'd0;
   else     cnt <= cnt + {31'd0, (inf.req & inf.grt)};
   assign inf.grt = rnd[0];
endmodule : drain
