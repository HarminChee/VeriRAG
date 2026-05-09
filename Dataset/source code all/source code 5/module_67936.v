module interrupts(
	clk_24mhz,
	clk_z80,
	m1_n,
	iorq_n,
	int_n
);
	parameter MAX_INT_LEN = 100;
	input clk_24mhz;
	input clk_z80;
	input m1_n;
	input iorq_n;
	output reg int_n;
	reg [9:0] ctr640;
	reg int_24;
	reg int_sync1,int_sync2,int_sync3;
	reg int_ack_sync,int_ack;
	reg int_gen;
	always @(posedge clk_24mhz)
	begin
		if( ctr640 == 10'd639 )
			ctr640 <= 10'd0;
		else
			ctr640 <= ctr640 + 10'd1;
		if( ctr640 == 10'd0 )
			int_24 <= 1'b1;
		else if( ctr640 == MAX_INT_LEN )
			int_24 <= 1'b0;
	end
	always @(negedge clk_z80)
	begin
		int_sync3 <= int_sync2;
		int_sync2 <= int_sync1;
		int_sync1 <= int_24;    
		int_ack_sync <= ~(m1_n | iorq_n);
		int_ack <= int_ack_sync;          
		if( int_ack || ( int_sync3 && (!int_sync2) ) )
			int_gen <= 1'b0;
		else if( (!int_sync3) && int_sync2 )
			int_gen <= 1'b1;
	end
	always @(posedge clk_z80)
	begin
		int_n <= ~int_gen;
	end
endmodule
