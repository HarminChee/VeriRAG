`timescale 1ns/1ns
`default_nettype none
`timescale 1ns/1ns
`default_nettype none
module cache_byte (
	input wire clock_i,
	input wire reset_i,
	output wire	busy_o,
	input wire	 		benable_i,
	input wire			brd_i,
	input wire			bwr_i,
	output reg	 		bvalid_o,	
	input wire [23:0]	badr_i,		
	input wire [7:0]	bdat_i,
	output reg [7:0] 	bdat_o,
	output reg	 		wenable_o,
	input wire			wack_i,
	output reg			wrd_o,
	output reg			wwr_o,
	input wire	 		wvalid_i,	
	output reg [22:0]	wadr_o,		
	output wire	[15:0]	wdat_o,		
	input wire [15:0]	wdat_i		
	);
	parameter IDLE = 0, INIT1 = 1, INIT2 = 2, SEARCH = 3, READ1 = 4, READ2 = 5, READ3 = 6, OUTPUT1 = 7, 
				WRITE1 = 8, XXXXXX = 9, OUTPUT2 = 10, FLUSH1 = 11, FLUSH2 = 12, FLUSH3 = 13; 
	wire 	[12:0] 	calc_tag;		
	wire	[6:0]	calc_row;		
	wire	[3:0]	calc_index;		
	wire	[1:0]	way0_flag;		
	wire	[1:0]	way1_flag;		
	wire	[12:0]	way0_tag;		
	wire	[12:0]	way1_tag;		
	wire	[7:0]	bdato_wire;		
	wire	[15:0]	wdato_wire;		
	`ifdef SIM
		wire			calc_mru;		
		wire [15:0]		fifo0, fifo1;	
	`endif
	reg [12:0] 	way0_tags 	[0:127];	
	reg [12:0] 	way1_tags 	[0:127]; 	
	reg [1:0] 	way0_flags 	[0:127];	
	reg [1:0] 	way1_flags 	[0:127];	
	reg 		mru			[0:127];	
	reg			hit_way = 0;			
	reg			write_ctl = 0;			
	reg [3:0] 	state = INIT1;			
	reg		wenable = 0, wrd = 0, wwr = 0, bvalid = 0, wwe = 0;
	reg 	[22:0] 	wadr;
	reg		[7:0]	bdato;
	reg		[15:0]	wdat_fifo[0:1];
	reg		[15:0]	mem_dat_alt;
	reg		[23:0]	badr;			
	reg		[7:0]	bdati;			
	reg				brd, bwr;		
	reg		[2:0]	block_ptr;		
	reg		[7:0]	general_cntr;
	reg				advance_cntr = 0;	
	assign calc_tag = badr[23:11];
	assign calc_row = badr[10:4];
	assign calc_index = badr[3:0];
	assign way0_flag = way0_flags[calc_row];
	assign way1_flag = way1_flags[calc_row];
	assign way0_tag = way0_tags[calc_row];
	assign way1_tag = way1_tags[calc_row];
	assign wdat_o = wdat_fifo[0];
	`ifdef SIM
	assign calc_mru = mru[calc_row];	
	assign fifo1 = wdat_fifo[1];		
	assign fifo0 = wdat_fifo[0];		
	`endif
	assign busy_o = (state != IDLE);
	cache_d	cache_inst (
			.address_a ( {hit_way,calc_row,calc_index[3:1],~calc_index[0] } ),		
			.address_b ( {hit_way,calc_row,block_ptr} ),
			.clock_a ( clock_i ),
			.clock_b ( clock_i ),
			.data_a ( bdati ),
			.data_b ( mem_dat_alt),
			.wren_a ( write_ctl ),
			.wren_b ( wvalid_i & wwe ),
			.q_a ( bdato_wire ),
			.q_b ( wdato_wire )
		);
	always @(posedge clock_i)
	if( reset_i ) state <= INIT1;
	else case( state )
		INIT1: begin
			wenable <= 1'b0; wrd <= 1'b0; wwr <= 1'b0; bvalid <= 1'b0;
			wadr <= 23'd0; bdato <= 8'd0;
			state <= INIT2;
		end
		INIT2: begin
			way0_flags[general_cntr] <= 2'd0;
			way1_flags[general_cntr] <= 2'd0;
			mru[general_cntr] <= 1'b0;			
			if( ~general_cntr[6:0] == 7'd0 ) state <= IDLE;		
		end
		IDLE: begin
			advance_cntr <= 1'b0;
			wwe <= 1'b0;
			if( benable_i & (brd_i | bwr_i))
			begin
				brd <= brd_i;
				bwr <= bwr_i;
				badr <= badr_i;
				bdati <= bdat_i;
				bvalid <= 1'b0;		
				state <= SEARCH;
			end
		end
		SEARCH : begin
			if( ( way0_flag != 2'd0 ) && (way0_tag == calc_tag) ) 
			begin
				hit_way <= 1'b0;
				mru[calc_row] <= 1'b0;
				$display("Cache HIT! Way 0");		
				if( brd ) state <= OUTPUT1; 
				else
				if( bwr ) state <= WRITE1;
				else state <= IDLE;
			end
			else
			if( ( way1_flag != 2'd0 ) && (way1_tag == calc_tag) ) 
			begin
				hit_way <= 1'b1;
				mru[calc_row] <= 1'b1;
				$display("Cache HIT! Way 1");		
				if( brd ) state <= OUTPUT1;
				else
				if( bwr ) state <= WRITE1;
				else state <= IDLE;
			end
			else begin
				if( way0_flag == 2'd0 ) 
				begin
					hit_way <= 1'b0;
					state <= READ1;
				end
				else
				if ( way1_flag == 2'd0 )
				begin
					hit_way <= 1'b1;
					state <= READ1;
				end
				else begin 
					hit_way <= ~mru[calc_row];	
					$display("At %08d Row replacement for %d, 0x%06x, victim way %d, victim tag: 0x%04x", $time, calc_row, badr, ~mru[calc_row], ~mru[calc_row] ? way1_tags[calc_row] : way0_tags[calc_row]);
					if( ( way0_flag == 2'b01 ) && mru[calc_row] ) state <= READ1;
					else
					if( ( way1_flag == 2'b01 ) && ~mru[calc_row] ) state <= READ1;
					else begin
						$display("At %08d dirty flush for %d, 0x%06x, victim way %d", $time, calc_row, badr, ~mru[calc_row]);
						state = FLUSH1;
					end
				end
			end
		end
		READ1 : begin
			if( ~wack_i )					
			begin
				wenable <= 1'b1;			
				wrd <= 1'b1;				
				wadr <= badr[23:1];
				state <= READ2;
			end
		end
		READ2 : begin
			if( wack_i ) begin
				wwe <= 1'b1;			
				wenable <= 1'b0;		
				wrd <= 1'b0;			
				advance_cntr <= 0;		
				state <= READ3;
			end
		end
		READ3 : if( wvalid_i ) begin
			$display("Read %04x in to cache word memory location %x", mem_dat_alt, block_ptr);
			if( general_cntr == 3'd7 ) begin
				bdato <= badr[0] ? mem_dat_alt[7:0] : mem_dat_alt[15:8];	
				if( brd ) bvalid <= 1'b1;		
			end
			if( general_cntr == 0 ) begin
				if( hit_way == 1'b0 )
				begin
					way0_flags[calc_row] <= 2'b01;
					way0_tags[calc_row] <= calc_tag;
				end
				else 
				begin
					way1_flags[calc_row] <= 2'b01;
					way1_tags[calc_row] <= calc_tag;
				end
				mru[calc_row] <= hit_way;
				if( ~bwr ) state <= IDLE;
				else state <= WRITE1;
			end
			else advance_cntr <= 1;
		end
		OUTPUT1 : state <= OUTPUT2;
		OUTPUT2 : begin				
			bdato <= bdato_wire[7:0]; 
			bvalid <= 1;
			state <= IDLE;
		end
		WRITE1 : begin
			bvalid <= 1'b1;				
			if( hit_way == 1'b0 ) way0_flags[calc_row] <= 2'b11;
			else way1_flags[calc_row] <= 2'b11;
			state <= IDLE;
		end
		FLUSH1 : begin
			wwe <= 1'b0;
			wenable <= 1'b1;
			wwr <= 1'b1;
			wadr <= {(hit_way) ? way1_tag : way0_tag, calc_row, block_ptr }; 
			state <= FLUSH2;
		end
		FLUSH2 : begin
			if( wack_i ) begin
				wenable <= 1'b0;
				wwr <= 1'b0;
				advance_cntr <= 1'b0;
				state <= FLUSH3;
			end
		end
		FLUSH3 : begin
			advance_cntr <= wvalid_i;					
			if( general_cntr == 7'd0 ) state <= READ1;	
		end
		default: state <= INIT1;		
	endcase
	always @(negedge clock_i)
	begin
		mem_dat_alt <= wdat_i;
		case( state )
			INIT1: general_cntr <= ~8'd0;			
			INIT2: general_cntr <= general_cntr + 1'b1;
			IDLE: begin
				write_ctl <= 1'b0;
			end
			READ1: begin
				general_cntr <= 3'd7;
				wdat_fifo[0] <= wdat_fifo[1];			
			end
			READ2: block_ptr <= wadr[2:0];
			READ3: begin
				if( advance_cntr ) begin
					block_ptr <= block_ptr + 1'b1;
					general_cntr <= general_cntr - 1'b1;
				end
			end
			WRITE1 : write_ctl <= 1'b1;
			FLUSH1 : begin
				general_cntr <= 3'd6;
				block_ptr <= 0;
			end
			FLUSH2 : if(block_ptr != 3'd2) begin
				{wdat_fifo[0],wdat_fifo[1]} <= {wdat_fifo[1], wdato_wire}; 
				block_ptr <= block_ptr + 1'b1;
			end
			FLUSH3 : if( advance_cntr ) begin
				{wdat_fifo[0],wdat_fifo[1]} <= {wdat_fifo[1], wdato_wire}; 
				block_ptr <= block_ptr + 1'b1;
				general_cntr <= general_cntr - 1'b1;
			end
		endcase
		wenable_o 	<= wenable;
		wrd_o 		<= wrd;
		wwr_o 		<= wwr;
		wadr_o		<= wadr;
		bvalid_o	<= bvalid;
		bdat_o		<= bdato;
	end
endmodule
