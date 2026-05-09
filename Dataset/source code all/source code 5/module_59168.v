module sram_interface(rst, clk, addr, drw, din, dout, rdy, sram_clk, sram_adv, sram_cre, sram_ce, sram_oe, sram_we, sram_lb, sram_ub, sram_data, sram_addr);
        input clk, rst;
        input [31:0] addr;
        input drw;
        input [31:0] din;
        output reg [31:0] dout;
	output rdy;
	output sram_clk, sram_adv, sram_cre, sram_ce, sram_oe, sram_lb, sram_ub;
	output [23:1] sram_addr;
	output sram_we;
	inout [15:0] sram_data;
	assign sram_clk = 0;
	assign sram_adv = 0;
	assign sram_cre = 0;
	assign sram_ce  = 0;
	assign sram_oe  = 0; 
	assign sram_ub  = 0;
	assign sram_lb  = 0;
	reg [2:0] state = 3'b000;
	wire UL = (state == 3'b000 || state == 3'b001 || state == 3'b010) ? 0 : 1;
	assign sram_data = (!drw) ? 16'hzzzz : 
			   (state == 3'b000 || state == 3'b001 || state == 3'b010) ? din[31:16] : din[15:0];
	assign sram_addr = {addr[23:2],UL};
	assign sram_we   = !(drw && state != 3'b010 && state != 3'b100);
	assign rdy = (state == 3'b000);
	always @(posedge clk) begin
		if (!rst) begin
			if (state == 3'b010) dout[31:16] <= sram_data;
			if (state == 3'b100) dout[15:0]  <= sram_data;
			if ((state == 3'b101 && drw) || (state == 3'b100 && !drw))
				state <= 3'b000;
			else
				state <= state + 1;
		end else begin
			state <= 3'b000;
		end
	end
endmodule
module mod_sram(rst, clk, ie, de, iaddr, daddr, drw, din, iout, dout, cpu_stall, sram_clk, sram_adv, sram_cre, sram_ce, sram_oe, sram_we, sram_lb, sram_ub, sram_data, sram_addr, mod_vga_sram_data, mod_vga_sram_addr, mod_vga_sram_read, mod_vga_sram_rdy);
        input rst;
        input clk;
        input ie,de;
        input [31:0] iaddr, daddr;
        input [1:0] drw;
        input [31:0] din;
        output [31:0] iout, dout;
	output [31:0] mod_vga_sram_data;
	input [31:0] mod_vga_sram_addr;
	input mod_vga_sram_read;
	output mod_vga_sram_rdy;
	output cpu_stall, sram_clk, sram_adv, sram_cre, sram_ce, sram_oe, sram_we, sram_lb, sram_ub;
	output [23:1] sram_addr;
	inout [15:0] sram_data;
	wire [31:0] eff_addr;
	wire eff_drw;
	wire [31:0] sram_dout;
	wire rdy;
	wire eff_rst;
	sram_interface sram(eff_rst, clk, eff_addr, eff_drw, din, sram_dout, rdy, sram_clk, sram_adv, sram_cre, sram_ce, sram_oe, sram_we, sram_lb, sram_ub, sram_data, sram_addr);
        reg [31:0] idata, ddata;
        assign iout = idata;
        assign dout = ddata;
	reg [1:0] state = 2'b00;
	reg bypass_state = 1'b0;
	reg mod_vga_sram_rdy = 1'b0;
	assign eff_addr = bypass_state ? mod_vga_sram_addr :
			  (state[0] && !bypass_state) ? daddr : iaddr;
	assign eff_drw  = state[0] && de && drw[0] && !rst && !bypass_state;
	assign cpu_stall = (state != 2'b00);
	assign eff_rst = state == 2'b00 && !bypass_state;
	wire [1:0] next_state = (state == 2'b00 && ie)         ? 2'b10 : 
				(state == 2'b00 && !ie && de && drw != 2'b00)  ? 2'b11 : 
				(state == 2'b10 && de && drw != 2'b00 && rdy && !bypass_state) ? 2'b11 : 
				(state == 2'b10 && (drw == 2'b00 || !de) && rdy && !bypass_state) ? 2'b00 : 
				(state == 2'b11 && rdy && !bypass_state) ? 2'b00 : 
				state;					 
	wire vga_bypass_next_state = (state == 2'b00 && mod_vga_sram_read && !bypass_state) ? 1'b1 : 
				     (bypass_state && rdy && !mod_vga_sram_read)	    ? 1'b0 : 
				     bypass_state;						     
	assign mod_vga_sram_data = ddata;
        always @(negedge clk) begin
                if (state == 2'b10 && ie && rdy && !rst && !bypass_state)
			idata <= sram_dout;
		else if (state == 2'b11 && de && rdy && !rst && !bypass_state)
			ddata <= sram_dout;	
		if (bypass_state && !rst && rdy) begin
			ddata <= sram_dout;
			mod_vga_sram_rdy <= 1'b1;
		end else begin
			mod_vga_sram_rdy <= 1'b0;
		end
		if (rst) begin 
			state <= 2'b00;
			bypass_state <= 1'b0;
		end else begin
			state <= next_state;
			bypass_state <= vga_bypass_next_state;
		end
        end
endmodule
module sram_interface(rst, clk, addr, drw, din, dout, rdy, sram_clk, sram_adv, sram_cre, sram_ce, sram_oe, sram_we, sram_lb, sram_ub, sram_data, sram_addr);
        input clk, rst;
        input [31:0] addr;
        input drw;
        input [31:0] din;
        output reg [31:0] dout;
	output rdy;
	output sram_clk, sram_adv, sram_cre, sram_ce, sram_oe, sram_lb, sram_ub;
	output [23:1] sram_addr;
	output sram_we;
	inout [15:0] sram_data;
	assign sram_clk = 0;
	assign sram_adv = 0;
	assign sram_cre = 0;
	assign sram_ce  = 0;
	assign sram_oe  = 0; 
	assign sram_ub  = 0;
	assign sram_lb  = 0;
	reg [2:0] state = 3'b000;
	wire UL = (state == 3'b000 || state == 3'b001 || state == 3'b010) ? 0 : 1;
	assign sram_data = (!drw) ? 16'hzzzz : 
			   (state == 3'b000 || state == 3'b001 || state == 3'b010) ? din[31:16] : din[15:0];
	assign sram_addr = {addr[23:2],UL};
	assign sram_we   = !(drw && state != 3'b010 && state != 3'b100);
	assign rdy = (state == 3'b000);
	always @(posedge clk) begin
		if (!rst) begin
			if (state == 3'b010) dout[31:16] <= sram_data;
			if (state == 3'b100) dout[15:0]  <= sram_data;
			if ((state == 3'b101 && drw) || (state == 3'b100 && !drw))
				state <= 3'b000;
			else
				state <= state + 1;
		end else begin
			state <= 3'b000;
		end
	end
endmodule
