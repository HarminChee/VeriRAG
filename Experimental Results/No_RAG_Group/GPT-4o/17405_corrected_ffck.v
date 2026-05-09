module top_SRAM_corrected_ffc (
	input 		   CLOCK_50,   
	input  [3:0]   KEY,       
	input  [17:0]  SW,		 
	output [6:0]   HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7, 
	output [7:0]   LEDG,   
	output [17:0]  LEDR,  
	inout [35:0]   GPIO, 
	inout  [15:0]  SRAM_DQ,    
	output [19:0]  SRAM_ADDR, 
	output SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N 
  	);
	parameter 	
	state_rst          = 4'd0, 		 
	state_idle         = 4'd1, 
	state_delay        = 4'd2,
	state_check_block  = 4'd3,
	state_start_send   = 4'd4,
	state_cnt_increase = 4'd5;
	parameter AVAIL     = 21'b 0_1000_0000_0000_0000_0000;
	parameter AVAIL_DIV = AVAIL/21'd18;
	wire clk;
	wire rst_n;
	wire locked;
	wire [7:0] sum_SW;
	wire [31:0] delay;
	wire SW_17_debounced;
	reg  fifo_block_read;
	wire pll_in_c0;
	wire pll_out_c0;
	wire dout;
	wire sck;
	wire ss;
	wire send_data;
	wire cc3200_flow_ctrl_n;
	wire fifo_busy;
	wire fifo_full;
	wire [31:0] din;
	reg  fifo_we;
	wire [31:0] fifo_debug;
	wire [21:0] available;
	wire [4:0]  number_0, number_1, number_2, number_3,
				number_4, number_5, number_6, number_7;
	wire [31:0] delay_cnt_plus_one;
	wire [31:0] data_cnt_plus_one;
	reg  [31:0] delay_cnt;
	reg  [31:0] data_cnt;
	reg  [3:0] current_state, next_state;
	DeBounce DeBounce_i_0 (CLOCK_50, rst_n, SW[17], SW_17_debounced);
	pll pll_0 (
		.areset (!rst_n),
		.inclk0 (pll_in_c0),
		.c0 	(pll_out_c0),
		.locked (locked)
		);
	fifo_spi_sram fifo_spi_i (
		.clk		 	(CLOCK_50),
		.nrst		 	(rst_n),
		.block  	 	(fifo_block_read),
		.we			 	(fifo_we),
		.din		 	(din),
		.fifo_busy 	 	(fifo_busy),
		.fifo_full 	 	(fifo_full),
		.dout 		 	(dout),
		.sck  		 	(sck),
		.ss   		 	(ss),
		.fifo_SRAM_ADDR (SRAM_ADDR),
		.fifo_SRAM_DQ 	(SRAM_DQ),		
		.fifo_SRAM_CE_N (SRAM_CE_N),
		.fifo_SRAM_OE_N (SRAM_OE_N),
		.fifo_SRAM_WE_N (SRAM_WE_N),
		.fifo_SRAM_LB_N (SRAM_LB_N),
		.fifo_SRAM_UB_N (SRAM_UB_N),
		.available		(available),
		.debug			(fifo_debug)
		);
	SSD seven_seg_0 (number_0, HEX0);
	SSD seven_seg_1 (number_1, HEX1);
	SSD seven_seg_2 (number_2, HEX2);
	SSD seven_seg_3 (number_3, HEX3);
	SSD seven_seg_4 (number_4, HEX4);
	SSD seven_seg_5 (number_5, HEX5);
	SSD seven_seg_6 (number_6, HEX6);
	SSD seven_seg_7 (number_7, HEX7);
	assign sum_SW = SW[0] + SW[1] + SW[2] + SW[3] + SW[4] + SW[5] + 
					SW[6] + SW[7] + SW[8] + SW[9] + SW[10] + SW[11];
	assign delay = 32'd128 + (1 << sum_SW);
	assign pll_in_c0 = CLOCK_50;
	assign clk = CLOCK_50;
	assign din       = data_cnt;
	assign rst_n     = KEY[0];
	assign send_data = KEY[1];
	assign GPIO[0]   = sck;
	assign GPIO[1]   = dout;
	assign GPIO[2]   = ss;
	assign GPIO[6]     = sck;
	assign GPIO[7]     = dout;
	assign GPIO[8]     = ss;
	assign GPIO[9]     = fifo_debug[8];
	assign GPIO[10]    = fifo_debug[9];
	assign GPIO[11]    = fifo_debug[10];
	assign GPIO[5:3]   = 0;
	assign GPIO[35:12] = {23{1'bz}}; 
	assign cc3200_flow_ctrl_n  = GPIO[35]; 
	assign delay_cnt_plus_one = delay_cnt + 32'b1;
	assign data_cnt_plus_one  = data_cnt +  32'b1;
	assign number_0 = {1'b0, fifo_debug[3:0]};
	assign number_1 = {1'b0, fifo_debug[7:4]};
	assign number_2 = {1'b0, current_state};
	assign number_3 = 5'h1_0;
	assign number_4 = 5'h1_0;
	assign number_5 = 5'h1_0;
	assign number_6 = 5'h1_0;
	assign number_7 = 5'h1_0;
	assign LEDG[0]  = fifo_busy;
	assign LEDG[1]  = fifo_full;
	assign LEDG[7:2] = 0;
	assign LEDR[0]  = available > (AVAIL_DIV * 21'd1)  ? 1'b1 : 1'b0;
	assign LEDR[1]  = available > (AVAIL_DIV * 21'd2)  ? 1'b1 : 1'b0;
	assign LEDR[2]  = available > (AVAIL_DIV * 21'd3)  ? 1'b1 : 1'b0;
	assign LEDR[3]  = available > (AVAIL_DIV * 21'd4)  ? 1'b1 : 1'b0;
	assign LEDR[4]  = available > (AVAIL_DIV * 21'd5)  ? 1'b1 : 1'b0;
	assign LEDR[5]  = available > (AVAIL_DIV * 21'd6)  ? 1'b1 : 1'b0;
	assign LEDR[6]  = available > (AVAIL_DIV * 21'd7)  ? 1'b1 : 1'b0;
	assign LEDR[7]  = available > (AVAIL_DIV * 21'd8)  ? 1'b1 : 1'b0;
	assign LEDR[8]  = available > (AVAIL_DIV * 21'd9)  ? 1'b1 : 1'b0;
	assign LEDR[9]  = available > (AVAIL_DIV * 21'd10) ? 1'b1 : 1'b0;
	assign LEDR[10] = available > (AVAIL_DIV * 21'd11) ? 1'b1 : 1'b0;
	assign LEDR[11] = available > (AVAIL_DIV * 21'd12) ? 1'b1 : 1'b0;
	assign LEDR[12] = available > (AVAIL_DIV * 21'd13) ? 1'b1 : 1'b0;
	assign LEDR[13] = available > (AVAIL_DIV * 21'd14) ? 1'b1 : 1'b0;
	assign LEDR[14] = available > (AVAIL_DIV * 21'd15) ? 1'b1 : 1'b0;
	assign LEDR[15] = available > (AVAIL_DIV * 21'd16) ? 1'b1 : 1'b0;
	assign LEDR[16] = available > (AVAIL_DIV * 21'd17) ? 1'b1 : 1'b0;
	assign LEDR[17] = available > (AVAIL_DIV * 21'd18) ? 1'b1 : 1'b0;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fifo_block_read <= 0;
		end
		else begin
			fifo_block_read <= cc3200_flow_ctrl_n;
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fifo_we <= 0;
		end
		else begin
			if (current_state == state_start_send)
				fifo_we <= 1'b1;
			else 
				fifo_we <= 1'b0;
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			delay_cnt     <= 0;
			data_cnt	  <= 0;
		end
		else begin
			case (current_state)
				state_idle : begin
					delay_cnt <= 0;
					data_cnt  <= data_cnt;
				end			
				state_delay : begin
					delay_cnt <= delay_cnt_plus_one;
					data_cnt  <= data_cnt;
				end
				state_cnt_increase : begin
					delay_cnt <= delay_cnt;
					data_cnt  <= data_cnt_plus_one;
				end
				default : begin
					delay_cnt <= delay_cnt;
					data_cnt  <= data_cnt;
				end
			endcase
		end
	end
	always @ (negedge clk or negedge rst_n) begin
		if (!rst_n) 
			current_state <= state_rst;
		else 
			current_state <= next_state;
	end
	always @ (*) begin
		next_state = current_state;
		case (current_state)
			state_rst : begin  
				if (!send_data) begin
					next_state = state_idle;
				end
			end 
			state_idle : begin  
				next_state = state_delay;
			end 
			state_delay : begin  
				if (delay_cnt >= delay) begin
					next_state = state_check_block;
				end
			end
			state_check_block : begin  
				if ( (!fifo_busy) && (!fifo_full)) begin
					next_state = state_start_send;
				end
			end
			state_start_send : begin  
				next_state = state_cnt_increase;
			end
			state_cnt_increase : begin  
				next_state = state_idle;
			end
			default : next_state = state_rst;
		endcase
	end
endmodule