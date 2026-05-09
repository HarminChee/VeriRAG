module fifo_SRAM(
	input wire clk,
	input wire rst_n,
	output wire [19:0] Addr,
	inout [15:0] IO,
	output reg  WE_n, 
	output reg  OE_n, 
	output wire CE_n, 
	output wire LB_n, 
	output wire UB_n, 
	input  wire [31:0] dataIn,
	output wire  [31:0] dataOut,
	input  wire user_we,
	input  wire user_re,
	output reg  data_r_rdy,
	output reg  busy,
	output reg  full,
	output reg  [21:0] available,
	output wire [7:0]  debug
);
	parameter S_RESET           = 4'd0;
	parameter S_IDLE            = 4'd1;
	parameter S_CATCH_WE_1      = 4'd2;
	parameter S_CATCH_WE_2      = 4'd3;
	parameter S_CATCH_RE_1      = 4'd4;
	parameter S_CATCH_RE_2      = 4'd5;
	parameter S_WRITE_UP_READY  = 4'd6;
	parameter S_WRITE_UP        = 4'd7;
	parameter S_WRITE_LOW_READY = 4'd8;
	parameter S_WRITE_LOW       = 4'd9;
	parameter S_READ_READY      = 4'd10;
	parameter S_READ_UP         = 4'd11;
	parameter S_READ_LOW        = 4'd12;
	parameter S_READ_DONE       = 4'd13;
	parameter MUX_FPGA_TO_SRAM = 1'b1; 
	parameter MUX_SRAM_TO_FPGA = 1'b0; 
	parameter BUFFER_SIZE = 21'b 1_0000_0000_0000_0000_0000; 
	reg [3:0]  	next_state;
	reg [19:0] 	read_addr;
	reg [19:0] 	write_addr;
	reg  		block;
	reg  		DAT_MUX;
	reg [31:0] 	data_IO_out_reg;
	reg [31:0] 	data_in_reg;	
	reg [15:0]  IO_to_SRAM;
	wire [15:0] IO_from_SRAM;
	wire [15:0] out_enable;
	reg 		read_write_reg;
	reg 	  	write_fifo;
	reg		  	read_fifo_start;
	reg		  	read_fifo;
	wire 		rollback_we;
	wire 		rollback_re;
	assign rollback_we = (write_addr == 20'hF_FFFF) ? 1'b1 : 1'b0;
	assign rollback_re = (read_addr  == 20'hF_FFFF) ? 1'b1 : 1'b0;
	assign debug = {2'b0, rollback_re, rollback_we, next_state};
	assign Addr = (DAT_MUX == MUX_FPGA_TO_SRAM) ? {write_addr} : {read_addr};
	assign IO   = (DAT_MUX == MUX_FPGA_TO_SRAM) ? IO_to_SRAM : 16'bzzzz_zzzz_zzzz_zzzz;
	assign IO_from_SRAM =  IO;
	assign CE_n = 0; 
	assign UB_n = 0; 
	assign LB_n = 0; 
	assign dataOut = data_IO_out_reg;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			full <= 0;
	    end
		else begin
			full <= (available > ((BUFFER_SIZE >> 1) - 21'd512) )  ? 1'b1 : 1'b0; 
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			available <= 0;
	    end
		else begin
			if (write_addr > read_addr)
				available <= (write_addr - read_addr) >> 1;
			else if (write_addr < read_addr)
				available <= (BUFFER_SIZE + write_addr - read_addr) >> 1;
			else
				available <= 0;
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) data_in_reg <= 0;	    
		else 
			if (user_we) data_in_reg <= dataIn;
			else 		 data_in_reg <= data_in_reg;
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			next_state <= S_RESET;
			DAT_MUX         <= MUX_SRAM_TO_FPGA;
			WE_n            <= 1; 
			busy            <= 0;
			data_r_rdy      <= 0;
			write_addr      <= 0;
			read_addr       <= 0;
			read_write_reg  <= 0;
			data_IO_out_reg <= 0;
	    end
		else begin
			case(next_state)
				S_RESET: begin  
					next_state      <= S_IDLE;
					DAT_MUX         <= MUX_SRAM_TO_FPGA;
					WE_n            <= 1; 
					busy            <= 0;
					data_r_rdy      <= 0;
					write_addr      <= 0;
					read_addr       <= 0;
					read_write_reg  <= 0;
					data_IO_out_reg <= 0;
				end
				S_IDLE: begin  
					data_r_rdy      <= 0;
					case ({user_re, user_we})
						2'b00: begin 
							next_state     <= S_IDLE; 
							busy           <= 0;
							read_write_reg <= 0;
						end
						2'b01: begin 
							next_state     <= S_CATCH_RE_1; 	
							busy           <= 1;
							read_write_reg <= 0;
						end
						2'b10: begin 
							next_state     <= S_CATCH_WE_1;   
							busy           <= 1;
							read_write_reg <= 0;
						end
						2'b11: begin 
							next_state     <= S_WRITE_UP_READY; 
							DAT_MUX = MUX_FPGA_TO_SRAM;
							busy           <= 1;
							read_write_reg <= 1;
						end
						default: begin 
							next_state     <= S_IDLE;
							busy           <= 1;
							read_write_reg <= 0;
						end
					endcase
				end
				S_CATCH_WE_1: begin  
					if (user_we) begin 
						next_state     <= S_WRITE_UP_READY;
						DAT_MUX = MUX_FPGA_TO_SRAM;
						read_write_reg <= 1;
					end
					else next_state <= S_CATCH_WE_2;
				end 
				S_CATCH_WE_2: begin  
					if (user_we) begin 
						next_state     <= S_WRITE_UP_READY;
						DAT_MUX = MUX_FPGA_TO_SRAM;
						read_write_reg <= 1;
					end
					else next_state <= S_READ_READY;
				end 
				S_CATCH_RE_1: begin  
					if (user_re) begin	
						next_state     <= S_WRITE_UP_READY;
						DAT_MUX = MUX_FPGA_TO_SRAM;
						read_write_reg <= 1;
					end
					else next_state <= S_CATCH_RE_2;
				end 
				S_CATCH_RE_2: begin  
					next_state <= S_WRITE_UP_READY;
					DAT_MUX = MUX_FPGA_TO_SRAM;
					if (user_re)  read_write_reg <= 1;
				end
				S_WRITE_UP_READY: begin  
					next_state <= S_WRITE_UP;
					DAT_MUX    <= MUX_FPGA_TO_SRAM;
					WE_n       <= 0;
					OE_n       <= 1;
					IO_to_SRAM <= data_in_reg[31:16];
				end 
				S_WRITE_UP: begin  
					next_state <= S_WRITE_LOW_READY;
					DAT_MUX    <= MUX_FPGA_TO_SRAM;
					WE_n       <= 1; 
					OE_n       <= 0; 
					write_addr <= write_addr + 20'd1;
				end 
				S_WRITE_LOW_READY: begin  
					next_state <= S_WRITE_LOW;
					DAT_MUX    <= MUX_FPGA_TO_SRAM;
					WE_n       <= 0;
					OE_n       <= 1;
					IO_to_SRAM <= data_in_reg[15:0];
				end 
				S_WRITE_LOW: begin  
					if (read_write_reg) next_state <= S_READ_READY;
					else 			   	next_state <= S_IDLE;
					DAT_MUX    <= MUX_SRAM_TO_FPGA;
					WE_n       <= 1; 
					OE_n       <= 0; 
					write_addr <= write_addr + 20'd1;
				end 
				S_READ_READY: begin  
					next_state <= S_READ_UP;
					WE_n       <= 1; 
					OE_n       <= 0; 
					DAT_MUX    <= MUX_SRAM_TO_FPGA;
				end 
				S_READ_UP: begin  
					next_state      <= S_READ_LOW;
					data_IO_out_reg <= {IO_from_SRAM, 16'b0};
					read_addr       <= read_addr + 20'd1;
				end 
				S_READ_LOW: begin  
					data_IO_out_reg <= {data_IO_out_reg[31:16], IO_from_SRAM};
					next_state      <= S_READ_DONE;
					read_addr       <= read_addr + 20'd1;
				end 
				S_READ_DONE: begin  
					next_state <= S_IDLE;
					data_r_rdy <= 1;
				end 
				default : begin
					next_state <= S_IDLE;
				end
			endcase
		end
	end	
endmodule
