`timescale 1ns / 1ps
`timescale 1ns / 1ps
module FP_Mul #(parameter P=32, biasSP=8'd127)(
	input wire clk,
	input wire [P-1:0] a,       
	input wire [P-1:0] b,       
	output wire [P-1:0] p       
	);
	wire [22:0] am, bm; 	    
	wire [7:0] ae,be;           
	assign am = a[22:0];
	assign bm = b[22:0];
	assign ae = a[30:23];
	assign be = b[30:23];
	reg [22:0] pm;		 	    
	reg [7:0] pe;			    
	reg [47:0] pmTemp;		    
	reg [7:0] peTemp;	      	    
	reg [23:0] xm;			    
    always@*
    begin
        pmTemp = {1'b1,am}*{1'b1,bm};                    
        peTemp = (ae+be)-biasSP;                         
        xm = pmTemp[47] ? pmTemp[46:24] : pmTemp[45:23]; 
        pe = pmTemp[47] ? peTemp+1 : peTemp;             
        pm = xm[22:0];                                   
        pe = xm[23] ? pe+1 : pe;                         
	end
	assign p = {(a[31]^b[31]),{pe,pm}};              
endmodule
