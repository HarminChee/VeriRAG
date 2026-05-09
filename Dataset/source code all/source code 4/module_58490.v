module dram_control(
	clk,
	start, 
	stop, 
	rnw, 
	ready, 
	wdat, 
	rdat, 
	DRAM_DQ,
	DRAM_MA,
	DRAM_RAS0_N,
	DRAM_RAS1_N,
	DRAM_LCAS_N,
	DRAM_UCAS_N,
	DRAM_WE_N
);
localparam DRAM_DATA_SIZE = 16;
localparam DRAM_MA_SIZE = 10;
localparam DRAM_ADDR_SIZE = 21;
	input clk;
	input start,rnw;
	output stop;
	reg    stop;
	output ready;
	reg    ready;
	input [DRAM_DATA_SIZE-1:0] wdat;
	output [DRAM_DATA_SIZE-1:0] rdat;
	inout [DRAM_DATA_SIZE-1:0] DRAM_DQ;
	output [DRAM_MA_SIZE-1:0] DRAM_MA;
	output DRAM_RAS0_N,DRAM_RAS1_N,DRAM_LCAS_N,DRAM_UCAS_N,DRAM_WE_N;
	reg  [DRAM_ADDR_SIZE:0] dram_addr_pre; 
	reg  [DRAM_ADDR_SIZE:0] dram_addr_out;
	wire [DRAM_ADDR_SIZE:0] dram_addr_nxt;
	assign dram_addr_nxt = dram_addr_pre + 1;
	always @(posedge clk) dram_addr_out <= dram_addr_pre;
	reg dram_req,dram_rnw;
	wire dram_cbeg,dram_rrdy;
	dram dramko( .clk(clk), .rst_n(1'b1), .ra(DRAM_MA), .rd(DRAM_DQ),
	             .rwe_n(DRAM_WE_N), .rucas_n(DRAM_UCAS_N), .rlcas_n(DRAM_LCAS_N),
	             .rras0_n(DRAM_RAS0_N), .rras1_n(DRAM_RAS1_N), .addr(dram_addr_out[DRAM_ADDR_SIZE-1:0]),
	             .rddata(rdat), .wrdata(wdat), .bsel(2'b11), .req(dram_req), .rnw(dram_rnw),
	             .cbeg(dram_cbeg), .rrdy(dram_rrdy) );
	reg [1:0] dram_ready_gen; 
	localparam NO_READY = 2'b00;
	localparam RD_READY = 2'b10;
	localparam WR_READY = 2'b11;
	always @*
	begin
		if( !dram_ready_gen[1] )
		begin
			ready = 1'b0;
		end
		else
		begin
			if( dram_ready_gen[0] ) 
			begin
				ready = dram_cbeg;
			end
			else 
			begin
				ready = dram_rrdy;
			end
		end
	end
	reg [3:0] curr_state,next_state;
	parameter START_STATE = 4'd00; 
	parameter INIT_STATE  = 4'd01; 
	parameter READ_BEG1 = 4'd02;
	parameter READ_BEG2 = 4'd03;
	parameter READ_CYC  = 4'd04;
	parameter READ_END1 = 4'd05;
	parameter READ_END2 = 4'd06;
	parameter WRITE_BEG = 4'd07;
	parameter WRITE_CYC = 4'd08;
	parameter WRITE_END = 4'd09;
	parameter STOP_STATE  = 4'd10; 
	always @*
	begin
		case( curr_state )
		START_STATE:
			next_state = INIT_STATE;
		INIT_STATE:
		begin
			if( rnw ) 
				next_state = READ_BEG1;
			else 
				next_state = WRITE_BEG;
		end
		READ_BEG1:
			next_state = READ_BEG2;
		READ_BEG2:
			next_state = READ_CYC;
		READ_CYC:
			if( !dram_addr_nxt[DRAM_ADDR_SIZE] )
				next_state = READ_CYC;
			else
				next_state = READ_END1;
		READ_END1:
			next_state = READ_END2;
		READ_END2:
			next_state = STOP_STATE;
		WRITE_BEG:
			next_state = WRITE_CYC;
		WRITE_CYC:
			if( !dram_addr_nxt[DRAM_ADDR_SIZE] )
				next_state = WRITE_CYC;
			else
				next_state = WRITE_END;
		WRITE_END:
			next_state = STOP_STATE;
		STOP_STATE:
			next_state = STOP_STATE;
		default:
			next_state = STOP_STATE;
		endcase
	end
	always @(posedge clk)
	begin
		if( start )
			curr_state <= START_STATE;
		else if( dram_cbeg )
			curr_state <= next_state;
	end
	always @(posedge clk) if( dram_cbeg )
	begin
		if( curr_state == INIT_STATE )
			dram_addr_pre <= 0;
		else
			dram_addr_pre <= dram_addr_nxt;
	end
	always @(posedge clk) if( dram_cbeg )
	begin
		case( curr_state )
		INIT_STATE:
		begin
			stop <= 1'b0;
			dram_req <= 1'b0;
			dram_ready_gen <= NO_READY;
		end
		READ_BEG1:
		begin
			dram_req <= 1'b1;
			dram_rnw <= 1'b1;
		end
		READ_BEG2:
		begin
			dram_ready_gen <= RD_READY;
		end
		READ_END1:
		begin
			dram_req <= 1'b0;
		end
		READ_END2:
		begin
			dram_ready_gen <= NO_READY;
		end
		WRITE_BEG:
		begin
			dram_req <= 1'b1;
			dram_rnw <= 1'b0;
			dram_ready_gen <= WR_READY;
		end
		WRITE_END:
		begin
			dram_req <= 1'b0;
			dram_ready_gen <= NO_READY;
		end
		STOP_STATE:
		begin
			stop <= 1'b1;
		end
		endcase
	end
endmodule
