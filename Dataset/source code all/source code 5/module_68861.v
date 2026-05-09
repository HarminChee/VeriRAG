module reg_1r1w
   #(
     parameter WIDTH=32,
     parameter ADRWID=10,
     parameter DEPTH=1024,
     parameter RST=0
     )
    (
   data_out,
   data_in, ra, wa, wr, rd, clk, rst_l
   );
    input [WIDTH-1:0] data_in;
    input [ADRWID-1:0] ra;
    input [ADRWID-1:0] wa;
    input wr;
    input rd;
    input clk;
    input rst_l;
    output [WIDTH-1:0] data_out;
    reg [WIDTH-1:0] array [0:DEPTH-1];
    reg [ADRWID-1:0] ra_r, wa_r;
    reg [WIDTH-1:0]  data_in_r;
    reg             wr_r;
    reg             rd_r;
    integer        x;
    always @(posedge clk) begin
       int tmp = x + 1;
       if (tmp !== x + 1) $stop;
    end
    always @(posedge clk or negedge rst_l) begin
       if (!rst_l) begin
	  for (x=0; x<DEPTH; x=x+1) begin 
             if (RST == 1) begin
		array[x] <= 0;
             end
	  end
	  ra_r <= 0;
	  wa_r <= 0;
	  wr_r <= 0;
	  rd_r <= 0;
	  data_in_r <= 0;
       end
       else begin
	  ra_r <= ra;
	  wa_r <= wa;
	  wr_r <= wr;
	  rd_r <= rd;
	  data_in_r <= data_in;
	  if (wr_r) array[wa_r] <= data_in_r;
       end
    end
endmodule
module t (
   data_out,
   wr, wa, rst_l, rd, ra, data_in, clk
   );
   input clk;
   input [31:0]		data_in;		
   input [7:0]		ra;			
   input		rd;			
   input		rst_l;			
   input [7:0]		wa;			
   input		wr;			
   output [31:0]	data_out;		
   reg_1r1w #(.WIDTH(32), .DEPTH(256), .ADRWID(8))
   sub 
     (
      .data_out				(data_out[31:0]),
      .data_in				(data_in[31:0]),
      .ra				(ra[7:0]),
      .wa				(wa[7:0]),
      .wr				(wr),
      .rd				(rd),
      .clk				(clk),
      .rst_l				(rst_l));
endmodule
module reg_1r1w
   #(
     parameter WIDTH=32,
     parameter ADRWID=10,
     parameter DEPTH=1024,
     parameter RST=0
     )
    (
   data_out,
   data_in, ra, wa, wr, rd, clk, rst_l
   );
    input [WIDTH-1:0] data_in;
    input [ADRWID-1:0] ra;
    input [ADRWID-1:0] wa;
    input wr;
    input rd;
    input clk;
    input rst_l;
    output [WIDTH-1:0] data_out;
    reg [WIDTH-1:0] array [0:DEPTH-1];
    reg [ADRWID-1:0] ra_r, wa_r;
    reg [WIDTH-1:0]  data_in_r;
    reg             wr_r;
    reg             rd_r;
    integer        x;
    always @(posedge clk) begin
       int tmp = x + 1;
       if (tmp !== x + 1) $stop;
    end
    always @(posedge clk or negedge rst_l) begin
       if (!rst_l) begin
	  for (x=0; x<DEPTH; x=x+1) begin 
             if (RST == 1) begin
		array[x] <= 0;
             end
	  end
	  ra_r <= 0;
	  wa_r <= 0;
	  wr_r <= 0;
	  rd_r <= 0;
	  data_in_r <= 0;
       end
       else begin
	  ra_r <= ra;
	  wa_r <= wa;
	  wr_r <= wr;
	  rd_r <= rd;
	  data_in_r <= data_in;
	  if (wr_r) array[wa_r] <= data_in_r;
       end
    end
endmodule
