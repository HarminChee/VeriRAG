`define VENDOR_FPGA
module generic_dpram(
	rclk, rrst, rce, oe, raddr, dout,
	wclk, wrst, wce, we, waddr, di
);
	parameter aw = 5;  
	parameter dw = 16; 
	input           rclk;  
	input           rrst;  
	input           rce;   
	input           oe;	   
	input  [aw-1:0] raddr; 
	output [dw-1:0] dout;    
	input          wclk;  
	input          wrst;  
	input          wce;   
	input          we;    
	input [aw-1:0] waddr; 
	input [dw-1:0] di;    
	reg [dw-1:0] mem [(1<<aw) -1:0] ;
	reg [aw-1:0] ra;                
	always @(posedge rclk)
	  if (rce)
	    ra <= #1 raddr;
    assign dout = mem[ra];
	always @(posedge wclk)
		if (we && wce)
			mem[waddr] <= #1 di;
endmodule
module smallfifo1(input rst,
		 input        clk_in,
		 input [7:0]  fifo_in,
		 input        fifo_en,
		 output       fifo_full,
		 input        clk_out,
		 output [7:0] fifo_out,
		 output       fifo_empty,
		 input        fifo_rd);
   vga_fifo_dc#(.AWIDTH(4),.DWIDTH(8)) 
   fifo0(.rclk (clk_out),
         .wclk (clk_in),
         .rclr (~rst),
         .wclr (~rst),
         .wreq (fifo_en),
         .d (fifo_in),
         .rreq (fifo_rd),
         .q (fifo_out),
         .empty (fifo_empty),
         .full (fifo_full));
endmodule
module vga_fifo_dc (rclk, wclk, rclr, wclr, wreq, d, rreq, q, empty, full);
	parameter AWIDTH = 7;  
	parameter DWIDTH = 16; 
	input rclk;             
	input wclk;             
	input rclr;             
	input wclr;             
	input wreq;             
	input [DWIDTH -1:0] d;  
	input rreq;             
	output [DWIDTH -1:0] q; 
	output empty;           
	reg empty;
	output full;            
	reg full;
	reg rrst, wrst, srclr, ssrclr, swclr, sswclr;
	reg [AWIDTH -1:0] rptr, wptr, rptr_gray, wptr_gray;
	function [AWIDTH:1] bin2gray;
		input [AWIDTH:1] bin;
		integer n;
	begin
		for (n=1; n<AWIDTH; n=n+1)
			bin2gray[n] = bin[n+1] ^ bin[n];
		bin2gray[AWIDTH] = bin[AWIDTH];
	end
	endfunction
	function [AWIDTH:1] gray2bin;
		input [AWIDTH:1] gray;
	begin
		gray2bin = bin2gray(gray);
	end
	endfunction
	always @(posedge rclk)
	begin
	    swclr  <= #1 wclr;
	    sswclr <= #1 swclr;
	    rrst   <= #1 rclr | sswclr;
	end
	always @(posedge wclk)
	begin
	    srclr  <= #1 rclr;
	    ssrclr <= #1 srclr;
	    wrst   <= #1 wclr | ssrclr;
	end
	always @(posedge rclk)
	  if (rrst) begin
	      rptr      <= #1 0;
	      rptr_gray <= #1 0;
	  end else if (rreq) begin
	      rptr      <= #1 rptr +1'h1;
	      rptr_gray <= #1 bin2gray(rptr +1'h1);
	  end
	always @(posedge wclk)
	  if (wrst) begin
	      wptr      <= #1 0;
	      wptr_gray <= #1 0;
	  end else if (wreq) begin
	      wptr      <= #1 wptr +1'h1;
	      wptr_gray <= #1 bin2gray(wptr +1'h1);
	  end
	reg [AWIDTH-1:0] srptr_gray, ssrptr_gray;
	reg [AWIDTH-1:0] swptr_gray, sswptr_gray;
	always @(posedge rclk)
	begin
	    swptr_gray  <= #1 wptr_gray;
	    sswptr_gray <= #1 swptr_gray;
	end
	always @(posedge wclk)
	begin
	    srptr_gray  <= #1 rptr_gray;
	    ssrptr_gray <= #1 srptr_gray;
	end
	always @(posedge rclk)
	  if (rrst)
	    empty <= #1 1'b1;
	  else if (rreq)
	    empty <= #1 bin2gray(rptr +1'h1) == sswptr_gray;
	  else
	    empty <= #1 empty & (rptr_gray == sswptr_gray);
	always @(posedge wclk)
	  if (wrst)
	    full <= #1 1'b0;
	  else if (wreq)
	    full <= #1 bin2gray(wptr +2'h2) == ssrptr_gray;
	  else
	    full <= #1 full & (bin2gray(wptr + 2'h1) == ssrptr_gray);
	generic_dpram #(AWIDTH, DWIDTH) fifo_dc_mem(
		.rclk(rclk),
		.rrst(1'b0),
		.rce(1'b1),
		.oe(1'b1),
		.raddr(rptr),
		.dout(q),
		.wclk(wclk),
		.wrst(1'b0),
		.wce(1'b1),
		.we(wreq),
		.waddr(wptr),
		.di(d)
	);
endmodule
`define VENDOR_FPGA
module generic_dpram(
	rclk, rrst, rce, oe, raddr, dout,
	wclk, wrst, wce, we, waddr, di
);
	parameter aw = 5;  
	parameter dw = 16; 
	input           rclk;  
	input           rrst;  
	input           rce;   
	input           oe;	   
	input  [aw-1:0] raddr; 
	output [dw-1:0] dout;    
	input          wclk;  
	input          wrst;  
	input          wce;   
	input          we;    
	input [aw-1:0] waddr; 
	input [dw-1:0] di;    
	reg [dw-1:0] mem [(1<<aw) -1:0] ;
	reg [aw-1:0] ra;                
	always @(posedge rclk)
	  if (rce)
	    ra <= #1 raddr;
    assign dout = mem[ra];
	always @(posedge wclk)
		if (we && wce)
			mem[waddr] <= #1 di;
endmodule
module smallfifo1(input rst,
		 input        clk_in,
		 input [7:0]  fifo_in,
		 input        fifo_en,
		 output       fifo_full,
		 input        clk_out,
		 output [7:0] fifo_out,
		 output       fifo_empty,
		 input        fifo_rd);
   vga_fifo_dc#(.AWIDTH(4),.DWIDTH(8)) 
   fifo0(.rclk (clk_out),
         .wclk (clk_in),
         .rclr (~rst),
         .wclr (~rst),
         .wreq (fifo_en),
         .d (fifo_in),
         .rreq (fifo_rd),
         .q (fifo_out),
         .empty (fifo_empty),
         .full (fifo_full));
endmodule
