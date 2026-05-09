`timescale 1ns/1ns
`ifndef MODEL_TECH
`default_nettype none
`endif
`define SIZE128M
`define LATENCY2
`timescale 1ns/1ns
`ifndef MODEL_TECH
`default_nettype none
`endif
`define SIZE128M
`define LATENCY2
module sdram (
	input			memclk_i,
	input			reset_i,
	input			enable_i,
	input 			rd_i,
	input 			wr_i,
	input [22:0] 	A_i,
	input [15:0] 	D_i,
	input [1:0]		Dm_i,
	output [15:0] 	D_o,
	output reg		D_valid,
   input 	  [15:0] 	Dq_in,	
   output     [15:0]	Dq_out,	
   output				Dq_oe,
   output reg [11:0] 	Addr, 
   output reg [1:0] 	Ba, 
   output      			Clk, 
   output 	     		Cke, 
   output reg     		Cs_n, 
   output reg     		Ras_n, 
   output reg     		Cas_n, 
   output reg     		We_n, 
   output [1 : 0] 		Dqm
);
	parameter INIT = 0, XXXXX = 1, IDLE = 2, PRECHARGE_ALL = 3, SET_MODE = 4, AUTO_REFRESH2 = 5,
				AUTO_REFRESH = 6, COUNT_DOWN = 7, FULL_COUNT_DOWN = 8, PRECHARGE_REFRESH = 9,
				CLOSE_ROW = 10, OPEN_ROW = 11, READ = 12, READOUT = 13, WRITE = 14, WRITEIN = 15, 
				WRITE_SETTLE = 16, STARTUP_REFRESH1 = 17, STARTUP_REFRESH2 = 18;
	wire [3:0] wait_timeout;	
	wire refresh_pending;		
	wire op_pending;			
	wire [1:0] op_bank;
	wire [11:0] op_row;
	wire [8:0] op_col;
	reg [4:0] state = INIT, next_state = IDLE;
	reg [15:0] counter;			
	reg [11:0] refresh_ticker;
	reg refresh_due, refresh_done; 
	reg [11:0] lastrow[0:3];	
	reg [3:0] bank_open;		
	reg [3:0] startup_cycles = 0;
	reg if_rd, if_wr;
	reg [22:0] if_A;
	reg if_rd_alt, if_wr_alt, op_pending_alt;
	reg [22:0] if_A_alt;
	reg op_due, op_done;
	reg data_proc_cycle;
	reg fsm_busy;
	assign Clk = memclk_i;
	assign Cke = 1'b1;			
	assign wait_timeout[0] = (counter[3:0] == 0);		
	assign wait_timeout[1] = (counter[7:4] == 0);		
	assign wait_timeout[2] = (counter[11:8] == 0); 		
	assign wait_timeout[3] = (counter[15:12] == 0); 	
	assign refresh_pending = refresh_due ^ refresh_done;	
	assign op_pending = op_due ^ op_done;				
	assign op_bank = if_A_alt[22:21];
	assign op_row = if_A_alt[20:9];
	assign op_col = if_A_alt[8:0];
	assign D_o = Dq_in;
	assign Dq_out = D_i;
	assign Dq_oe = (D_valid & if_wr_alt);	
	assign Dqm = Dm_i;
	`ifdef SIM
		wire [11:0] debug_bankrow0=lastrow[0];	
		wire [11:0] debug_bankrow1=lastrow[1];	
		wire [11:0] debug_bankrow2=lastrow[2];	
		wire [11:0] debug_bankrow3=lastrow[3];	
	`endif
	function [0:5] param_table (
		input [3:0] cmd
		);
		case( cmd )
			4'd00: param_table = { 1'b1,       1'b1, 1'b1, 1'b1, 1'b1, 1'b0}; 
			4'd01: param_table = { 1'b1,       1'b0, 1'b0, 1'b1, 1'b0, 1'b0}; 
			4'd02: param_table = { 1'b0,       1'b0, 1'b0, 1'b0, 1'b0, 1'b0}; 
			4'd03: param_table = { 1'b0,       1'b0, 1'b0, 1'b0, 1'b1, 1'b0}; 
			4'd04: param_table = { 1'b0,       1'b0, 1'b0, 1'b1, 1'b0, 1'b0}; 
			4'd05: param_table = { op_row[10], 1'b0, 1'b0, 1'b1, 1'b1, 1'b0}; 
			4'd06: param_table = { 1'b0,       1'b0, 1'b1, 1'b0, 1'b1, 1'b1}; 
			4'd07: param_table = { 1'b0,       1'b0, 1'b1, 1'b0, 1'b0, 1'b1}; 
			default: param_table = -6'd1;	
		endcase
	endfunction
	task set_signals ( input [0:5] data );
		{Cs_n, Ras_n, Cas_n, We_n, Ba, Addr[11:0]} <= 
			{data[1:4], op_bank, (~data[5]) ? op_row[11] : 1'b0, data[0], (data[5]) ? {1'b0, op_col} : op_row[9:0]};		
	endtask	
	task set_bank_timeout ( input [1:0] bank, input [3:0] data );
		case(bank)
			2'd0: counter[3:0] <= data;
			2'd1: counter[7:4] <= data;
			2'd2: counter[11:8] <= data;
			2'd3: counter[15:12] <= data;
		endcase
	endtask	
	function bank_timeout( input [1:0] bank );
		case(bank)
			2'd0: bank_timeout = (counter[3:0] == 4'd0); 
			2'd1: bank_timeout = (counter[7:4] == 4'd0); 
			2'd2: bank_timeout = (counter[11:8] == 4'd0); 
			2'd3: bank_timeout = (counter[15:12] == 4'd0);
			default: bank_timeout = 0;
		endcase
	endfunction
	always @(posedge memclk_i)
	if( reset_i ) begin
		op_due <= 0;
		if_rd <= 0;
		if_wr <= 0;
		if_A <= 0;
	end
	else
	if( enable_i && ~fsm_busy ) begin	
		if_rd <= rd_i;
		if_wr <= wr_i;
		if_A <= A_i;
		if( ~op_pending ) op_due <= ~op_due;
	end
	always @(negedge memclk_i)
	begin
		if_rd_alt <= if_rd;
		if_wr_alt <= if_wr;
		if_A_alt <= if_A;
		op_pending_alt <= op_pending;
	end
	always @(posedge memclk_i)
	begin
		if( reset_i ) begin
			refresh_done <= 0;
			op_done <= 0;
			lastrow[0] <= 0;
			lastrow[1] <= 0;
			lastrow[2] <= 0;
			lastrow[3] <= 0;
			bank_open <= 0;
			state <= INIT;
			fsm_busy <= 0;
		end
		else begin
			case( state )
				COUNT_DOWN: begin
					if( bank_timeout(op_bank) ) state <= next_state;
					if( ~wait_timeout[0] ) counter[3:0] <= counter[3:0] - 1'b1;
					if( ~wait_timeout[1] ) counter[7:4] <= counter[7:4] - 1'b1;
					if( ~wait_timeout[2] ) counter[11:8] <= counter[11:8] - 1'b1;
					if( ~wait_timeout[3] ) counter[15:12] <= counter[15:12] - 1'b1;
				end
				FULL_COUNT_DOWN: begin
					if( counter == 0 )
						state <= next_state;
					else
						counter <= counter - 1'b1;
				end
				INIT: begin
					data_proc_cycle <= 0;
					counter <= -16'd1; 				
					state <= FULL_COUNT_DOWN;
					next_state <= PRECHARGE_ALL;
				end
				PRECHARGE_ALL: begin
					counter <= 16'h1111;	
					bank_open <= 0;			
					state <= COUNT_DOWN;
					startup_cycles <= 7;	
					next_state <= STARTUP_REFRESH1; 
				end
				STARTUP_REFRESH1: begin
					state <= STARTUP_REFRESH2;
				end
				STARTUP_REFRESH2: begin
					counter <= 16'h7777;
					state <= COUNT_DOWN;
					if( startup_cycles == 0 ) next_state <= SET_MODE;
					else begin
						startup_cycles <= startup_cycles - 1'b1;
						next_state <= STARTUP_REFRESH1;
					end
				end
				PRECHARGE_REFRESH: begin
					if( counter == 0 ) begin
						bank_open <= 0;			
						counter <= 16'h1111;	
						state <= COUNT_DOWN;
						next_state <= AUTO_REFRESH;
					end
				end
				SET_MODE: begin
					counter <= 4'd0;
					state <= COUNT_DOWN;
					next_state <= AUTO_REFRESH2;
				end
				AUTO_REFRESH2: begin
					counter <= 16'h8888;
					state <= COUNT_DOWN;
					next_state <= AUTO_REFRESH;
				end
				AUTO_REFRESH: begin
					counter <= 16'h8888;
					state <= COUNT_DOWN;
					next_state <= IDLE;
					if( refresh_pending ) refresh_done <= ~refresh_done;
				end
				IDLE: begin
					if( refresh_pending ) begin
						state <= PRECHARGE_REFRESH;
						fsm_busy <= 0;
					end
					else if( op_pending_alt ) begin
						if( op_pending ) op_done <= ~op_done;
						fsm_busy <= 1'b1;
						if( bank_open[op_bank] )
						begin
							if( lastrow[op_bank] != op_row ) begin
								state <= CLOSE_ROW;
							end
							else state <= (if_rd_alt) ? READ : (if_wr_alt) ? WRITE : IDLE; 
						end
						else state <= OPEN_ROW;			
					end
					else begin
						state <= IDLE;
						fsm_busy <= 0;
					end
					data_proc_cycle <= 0;
				end
				CLOSE_ROW: begin
					set_bank_timeout(op_bank, 1);
					bank_open[op_bank] <= 0;			
					state <= COUNT_DOWN;
					next_state <= OPEN_ROW;
				end
				OPEN_ROW: begin
					set_bank_timeout(op_bank, 1);
					state <= COUNT_DOWN;
					next_state <= (if_rd_alt) ? READ : (if_wr_alt) ? WRITE : IDLE; 
					bank_open[op_bank] <= 1;			
					lastrow[op_bank] <= op_row;			
				end
				READ: begin
					`ifdef LATENCY2
						set_bank_timeout(op_bank, 0);
					`else	
						set_bank_timeout(op_bank, 1);
					`endif
					state <= COUNT_DOWN;
					next_state <= READOUT;
				end
				READOUT: begin
					data_proc_cycle <= 1'b1;
					set_bank_timeout(op_bank, 6);
					state <= COUNT_DOWN;
					next_state <= IDLE;
				end
				WRITE: begin
					state <= WRITEIN;
					data_proc_cycle <= 1'b1;
				end
				WRITEIN: begin
					set_bank_timeout(op_bank, 5);
					state <= COUNT_DOWN;
					next_state <= WRITE_SETTLE;
				end
				WRITE_SETTLE: begin
					`ifdef LATENCY2
						set_bank_timeout(op_bank, 0);
					`else	
						set_bank_timeout(op_bank, 1);
					`endif
					data_proc_cycle <= 0;
					state <= COUNT_DOWN;
					next_state <= IDLE;
					fsm_busy <= 0;
				end
				default: state <= INIT;		
			endcase		
		end
	end
	always @(negedge memclk_i)
	begin
		if( reset_i ) begin
			refresh_ticker <= 0;
			refresh_due <= 0;
		end
		else begin
			`ifdef SIZE128M
			if(refresh_ticker[11:7] == 5'b10011)
			`else
			if(refresh_ticker[9:8] == 2'b11)
			`endif
			begin
				refresh_ticker <= 12'd0;
				if( ~refresh_pending ) refresh_due <= ~refresh_due;
			end
			else refresh_ticker <= (refresh_ticker + 1'b1);
			D_valid <= (data_proc_cycle || (state == READOUT) || (state == WRITE)) && (state != IDLE) && (state != WRITE_SETTLE);
			case( state )
				IDLE: 				set_signals(param_table(0));
				INIT: 				set_signals(param_table(0));
				COUNT_DOWN:			set_signals(param_table(0));
				FULL_COUNT_DOWN:	set_signals(param_table(0));
				STARTUP_REFRESH2:	set_signals(param_table(0));
				PRECHARGE_ALL: 		set_signals(param_table(1));
				PRECHARGE_REFRESH:	set_signals(param_table(1));
				AUTO_REFRESH2:		set_signals(param_table(3));
				AUTO_REFRESH:		set_signals(param_table(3));
				STARTUP_REFRESH1:	set_signals(param_table(3));
				CLOSE_ROW:			set_signals(param_table(4));
				OPEN_ROW:			set_signals(param_table(5));
				READ:				set_signals(param_table(6));
				READOUT:			set_signals(param_table(0));
				WRITE:				set_signals(param_table(7));
				WRITEIN:			set_signals(param_table(0));
				WRITE_SETTLE:		set_signals(param_table(0));
				SET_MODE: begin
					set_signals(param_table(2));
					Addr <= 12'h23;	
				end
				default:			set_signals(param_table(0));	
			endcase
		end
	end
endmodule
