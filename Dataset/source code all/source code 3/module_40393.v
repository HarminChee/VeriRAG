module mips_memory2 (clk, addr, din, dout, pc, access_size, rw, busy, enable);
parameter MEMSIZE = 1024;
parameter START_ADDR = 32'h8002_0000;
	input         clk;
	input [31:0]  addr;
	input [31:0]  din;
	input [2:0]   access_size;
	input 	      rw; 
	input	      enable;
	output reg        busy;
	output reg [31:0] dout;
	output reg [31:0] pc;
	reg    [7:0]  mem[0:MEMSIZE];
	reg  [31:0]   reg_cur_addr	= 'hffff; 
	reg  [5:0]		reg_counter	= 0;  
	reg	      		reg_rw		= 0;	    
	reg  [31:0]   reg_din		= 'hffff; 
	wire	      wire_busy;    
	wire	      wire_output;  
	assign wire_busy = (reg_counter > 1);
	assign wire_output = (reg_counter != 0);
	always @(posedge clk)
	begin
		if (wire_busy == 'b1)
		begin
			reg_cur_addr <= reg_cur_addr + 4;
		end
		else if (enable == 'b1) 
		begin
			reg_cur_addr <= addr - START_ADDR;
		end
		else
		begin
			reg_cur_addr <= reg_cur_addr; 
		end
		if (wire_busy == 'b0 && enable == 'b1)
		begin
			case (access_size)
				3'b000 : reg_counter <= 'd1;	
				3'b001 : reg_counter <= 'd4;	
				3'b010 : reg_counter <= 'd8;	
				3'b011 : reg_counter <= 'd16;	
				3'b100 : reg_counter <= 'd1;	
				3'b101 : reg_counter <= 'd1;	
				default : reg_counter <= 'd0;
			endcase
			reg_rw <= rw;
		end
		else
		begin
			reg_counter <= reg_counter == 0 ? 0 : reg_counter - 1;
			reg_rw <= reg_rw;
		end
		if (wire_output == 'b1 && reg_rw == 'b0)
		begin
			if (access_size == 3'b100)
				begin
					dout[31:24] <= 0;
					dout[23:16] <= 0;
					dout[15:8]  <= 0;
					dout[7:0]   <= mem[reg_cur_addr]; 
				end
			else if  (access_size == 3'b101)
				begin
					dout[31:24] <= 0;
					dout[23:16] <= 0;
					dout[15:8]  <= mem[reg_cur_addr];
					dout[7:0]   <= mem[reg_cur_addr+1]; 
				end
			else
				begin
					dout[31:24] <= mem[reg_cur_addr];   
					dout[23:16] <= mem[reg_cur_addr+1];
					dout[15:8]  <= mem[reg_cur_addr+2];
					dout[7:0]   <= mem[reg_cur_addr+3]; 
				end
			pc <= reg_cur_addr + START_ADDR;
		end
		else
		begin
			dout[31:0] <= 'bx;
		end
		if (wire_output == 'b1 && reg_rw == 'b1)
		begin
			if (access_size == 3'b100)
				begin
					mem[reg_cur_addr]   <= reg_din[7:0];
				end
			else if  (access_size == 3'b101)
				begin
					mem[reg_cur_addr]   <= reg_din[15:8];   
					mem[reg_cur_addr+1] <= reg_din[7:0];
				end
			else
				begin
					mem[reg_cur_addr]   <= reg_din[31:24];   
					mem[reg_cur_addr+1] <= reg_din[23:16];
					mem[reg_cur_addr+2] <= reg_din[15:8];
					mem[reg_cur_addr+3] <= reg_din[7:0]; 
				end
		end
	busy <= wire_busy;
	reg_din <= din;
	end
endmodule
