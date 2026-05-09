`timescale 1ns / 1ps
`timescale 1ns / 1ps
module lab5dpath(reset, clk, irdy, ordy, din, dout  );
 input reset, clk, irdy;
 input [9:0] din;
 output [9:0] dout;
 output ordy;
wire [11:0] k1, k2, k3, dmod, mmod, add; 
wire [23:0] m;
reg lda, ldb, s_ordy, c_ordy, ordy;
reg [1:0] nstate, pstate, s, sregb;
reg [11:0] k, aq, bq, bd;
assign k1 = 12'b110000000000;
assign k3 = 12'b110000000000;
assign k2 = 12'b010100000000;
`define STATE_S1  2'b00
`define STATE_S2  2'b01
`define STATE_S3  2'b10
`define STATE_S4  2'b11 
assign dmod = {din, 2'b00};
always @ (posedge clk) begin
k = k1;
	case (s)
		2'b01:
			k = k2;
		2'b10:
			k = k3;
		2'b11:
			k = 12'b000000000001;
	endcase
end
mult12x12 i1 (.a(k), .b(dmod), .p(m));
assign mmod = m[22:11];
assign add = bq + aq;
always @* begin
	case (sregb)
		2'b00:
			bd = mmod;
		2'b01:
			bd = add;
		2'b10:
			bd = 12'b000000000000;
	endcase
end
always @(posedge clk) begin
	if (lda) 
		aq <= mmod;
end
always @(posedge clk) begin
	if (ldb)
		bq <= bd;
end
always @(posedge clk or posedge reset) begin
	if (reset) begin
		ordy <= 0;
		end  
	else begin
		if (s_ordy) ordy <= 1;
		if (c_ordy) ordy <= 0;
	end
end
always @(posedge clk or posedge reset) begin
     if (reset) begin
    	  pstate <= `STATE_S1;
	  end  
	  else begin
		  pstate <= nstate;
	  end
end
always @* begin
	 lda = 0; ldb = 0; 
	 s_ordy = 0; c_ordy = 0;
	 sregb = 2'b00; s = 2'b00;
	 nstate = pstate;
	 case (pstate)
	  `STATE_S1:  begin	  
			lda = 1;
			if (irdy == 1)begin
				s = 2'b01;
				nstate = `STATE_S2;
				c_ordy = 1;
				end			 
			end
	  `STATE_S2: begin
				s = 2'b10;
				ldb = 1;
				sregb = 2'b00;
				nstate = `STATE_S3;
			end
	  `STATE_S3: begin
				lda = 1;
				sregb = 2'b01;
				ldb = 1;
				nstate = `STATE_S4;
			end 
	  `STATE_S4: begin
				sregb = 2'b01;
				ldb = 1;
				s_ordy = 1;
				nstate = `STATE_S1;
			end 
	endcase 		 
end
assign dout = bq[11:2];
endmodule
