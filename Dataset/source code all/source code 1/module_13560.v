module flash_manager(
	clock, reset, 
	dots, 
	writemode, 
	wdata, 
	dowrite, 
	raddr, 
	frdata, 
	doread, 
	busy, 
	flash_data, 
	flash_address, 
	flash_ce_b, 
	flash_oe_b, 
	flash_we_b, 
	flash_reset_b, 
	flash_sts, 
	flash_byte_b, 
	fsmstate);
	input reset, clock;			
	output [639:0] dots;		
	input writemode;			
	input [15:0] wdata;			
	input dowrite;				
	input [22:0] raddr;			
	output[15:0] frdata;		
	reg[15:0]    rdata;
	input doread;				
	output busy;				
	reg busy;
	inout [15:0] flash_data;					
    output [23:0] flash_address;
    output flash_ce_b, flash_oe_b, flash_we_b;
    output flash_reset_b, flash_byte_b;
    input  flash_sts;
	wire flash_busy;		
	wire[15:0] fwdata;
	wire[15:0] frdata;
	wire[22:0] address;							
	wire [1:0] op;	
	reg [1:0] mode;
	wire fsm_busy;
	reg[2:0] state;					
	output[11:0] fsmstate;
	wire [7:0] fsmstateinv;
	assign fsmstate = {state,flash_busy,fsm_busy,fsmstateinv[4:0],mode};	
	flash_int flash(reset, clock, op, address, fwdata, frdata, flash_busy, flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_sts, flash_byte_b);
	test_fsm  fsm  (reset, clock, op, address, fwdata, frdata, flash_busy, dots, mode, fsm_busy, wdata, raddr, fsmstateinv);
	parameter MODE_IDLE	= 0;
	parameter MODE_INIT	= 1;
	parameter MODE_WRITE = 2;
	parameter MODE_READ	= 3;
	parameter HOME 		= 3'd0;
	parameter MEM_INIT 	= 3'd1;
	parameter MEM_WAIT 	= 3'd2;
	parameter WRITE_READY= 3'd3;
	parameter WRITE_WAIT	= 3'd4;
	parameter READ_READY	= 3'd5;
	parameter READ_WAIT 	= 3'd6;
	always @ (posedge clock)
		if(reset)
			begin
				busy <= 1;
				state <= HOME;
				mode <= MODE_IDLE;
			end
		else begin		
			case(state)
				HOME:
					if(!fsm_busy)
						begin
							busy <= 0;
							if(writemode)
								begin
									busy <= 1;
									state <= MEM_INIT;
								end
							else
								begin
									busy <= 1;
									state <= READ_READY;
								end
						end
					else
						mode <= MODE_IDLE;
				MEM_INIT:
					begin
						busy <= 1;
						mode <= MODE_INIT;
						if(fsm_busy)					
							state <= MEM_WAIT;
					end
				MEM_WAIT:
					if(!fsm_busy)
						begin
							busy <= 0;
							state<= WRITE_READY;
						end
					else
						mode <= MODE_IDLE;
				WRITE_READY:
					if(dowrite)
						begin
							busy <= 1;
							mode <= MODE_WRITE;
						end
					else if(busy)
						state <= WRITE_WAIT;
					else if(!writemode)
						state <= READ_READY;
				WRITE_WAIT:
					if(!fsm_busy)
						begin
							busy <= 0;
							state <= WRITE_READY;
						end
					else
						mode <= MODE_IDLE;
				READ_READY:
					if(doread)
						begin
							busy <= 1;
							mode <= MODE_READ;
							if(busy)			
								state <= READ_WAIT;
						end
					else
						busy <= 0;
				READ_WAIT:
					if(!fsm_busy)
						begin
							busy <= 0;
							state <= READ_READY;
						end
					else
						mode <= MODE_IDLE;
				default: begin		
					state <= 3'd7;
				end
			endcase
	end
endmodule
