module uart_baud_generator(clk,baud,baud16,rst);
	input clk,rst;
	output baud;
	output baud16;
	parameter b_rate = 57600;
	parameter c_rate = 25000000; 
	parameter divider = c_rate / b_rate;
	parameter divider16 = c_rate / (16 * b_rate); 
	reg [31:0] count,count16;
	assign baud = (count == 0) ? 1 : 0;
	assign baud16 = (count16 == 0) ? 1 : 0;
	always @(negedge clk) begin
		count = count + 1;
		count16 = count16 + 1;
		if (count == divider)
			count = 0;
		if (count16 == divider16) 
			count16 = 0;
		if (rst) begin
			count = 0;
			count16 = 0;
		end
	end
endmodule
module uart_core(clk,rxd,txd,in_buffer,out_buffer,data_rdy,clear,cts,send,rst);
	input clk,rst;
	input rxd;
	input clear;
	output reg [7:0] in_buffer;
	output reg data_rdy;
	output cts;
	input [7:0] out_buffer;
	input send;
	output txd;
	wire baud;
	wire baud16;
	uart_baud_generator ubg(clk,baud,baud16,rst);
	reg [3:0] rxd_state;
	reg [3:0] baud16_space;
	wire baud16_mark = (baud16_space == 0) ? 1 : 0;
	always @(negedge clk) begin
		if (rst) begin
			data_rdy <= 0;
			rxd_state <= 0;
		end else if (baud16) begin
			if (rxd_state != 0) 
				baud16_space <= baud16_space + 1;
			else
				baud16_space <= 15;
			case (rxd_state)
				0: if (!rxd) rxd_state <= 1; 
				1: if (baud16_mark) rxd_state <= 2; 
				2: if (baud16_mark) begin rxd_state <= 3; in_buffer[0] <= rxd; end 
				3: if (baud16_mark) begin rxd_state <= 4; in_buffer[1] <= rxd; end 
				4: if (baud16_mark) begin rxd_state <= 5; in_buffer[2] <= rxd; end 
				5: if (baud16_mark) begin rxd_state <= 6; in_buffer[3] <= rxd; end 
				6: if (baud16_mark) begin rxd_state <= 7; in_buffer[4] <= rxd; end 
				7: if (baud16_mark) begin rxd_state <= 8; in_buffer[5] <= rxd; end 
				8: if (baud16_mark) begin rxd_state <= 9; in_buffer[6] <= rxd; end 
				9: if (baud16_mark) begin rxd_state <= 10; in_buffer[7] <= rxd; end 
				10: if (baud16_mark & rxd) begin rxd_state <= 0; data_rdy <= 1; end
				default: if (baud16_mark) rxd_state <= 0;
			endcase
		end
		if (clear)
			data_rdy <= 0;
	end
	reg [3:0] txd_state;
	assign cts = (txd_state == 0) ? 1 : 0;
	always @(negedge clk) begin
		if (baud) begin
			case (txd_state)
				1: txd_state = 2; 
				2: txd_state = 3; 
				3: txd_state = 4;
				4: txd_state = 5;
				5: txd_state = 6;
				6: txd_state = 7;
				7: txd_state = 8;
				8: txd_state = 9;
				9: txd_state = 10;
				10: txd_state = 0;
				default: txd_state = 0; 
			endcase
		end
		if (send)
			txd_state = 1;
	end
	assign txd = (txd_state == 0) ? 1 : 
					 (txd_state == 1) ? 1 : 
					 (txd_state == 2) ? 0 : 
					 (txd_state == 3) ? out_buffer[0] : 
					 (txd_state == 4) ? out_buffer[1] : 
					 (txd_state == 5) ? out_buffer[2] : 
					 (txd_state == 6) ? out_buffer[3] : 
					 (txd_state == 7) ? out_buffer[4] : 
					 (txd_state == 8) ? out_buffer[5] : 
					 (txd_state == 9) ? out_buffer[6] : 
					 (txd_state == 10) ? out_buffer[7] : 1;
endmodule
module mod_uart(rst, clk, ie, de, iaddr, daddr, drw, din, iout, dout, txd, rxd, i_uart, pmc_uart_recv, pmc_uart_send);
        input rst;
        input clk;
        input ie,de;
        input [31:0] iaddr, daddr;
        input [1:0] drw;
        input [31:0] din;
        output [31:0] iout, dout;
	output txd;
	input rxd;
	output i_uart;
	output pmc_uart_recv, pmc_uart_send;
        wire [31:0] idata, ddata;
        assign iout = idata;
        assign dout = ddata;
	assign idata = 32'h00000000;
	wire data_rdy,cts,send,clear;
	wire [7:0] in_buffer;
	reg [7:0] out_buffer;
	uart_core uart(clk,rxd,txd,in_buffer,out_buffer,data_rdy,clear,cts,send,rst);
	assign send = (de && drw[0] && daddr == 32'h0) ? din[0] : 0;
	assign clear = (de && drw[0] && daddr == 32'h0) ? din[1] : 0;
	assign pmc_uart_recv = clear;
	assign pmc_uart_send = send;
	assign ddata = (daddr == 32'h0) ? 0 : 
			  (daddr == 32'h4) ? {30'h0,data_rdy,cts} : 
			  (daddr == 32'h8) ? {24'h0,in_buffer} : 
			  (daddr == 32'hc) ? {24'h0,out_buffer} : 0; 
	assign i_uart = data_rdy;	
	always @(negedge clk) begin
		if (de && drw[0] && daddr == 32'hc) 
			out_buffer = din[7:0];
	end
endmodule
module uart_baud_generator(clk,baud,baud16,rst);
	input clk,rst;
	output baud;
	output baud16;
	parameter b_rate = 57600;
	parameter c_rate = 25000000; 
	parameter divider = c_rate / b_rate;
	parameter divider16 = c_rate / (16 * b_rate); 
	reg [31:0] count,count16;
	assign baud = (count == 0) ? 1 : 0;
	assign baud16 = (count16 == 0) ? 1 : 0;
	always @(negedge clk) begin
		count = count + 1;
		count16 = count16 + 1;
		if (count == divider)
			count = 0;
		if (count16 == divider16) 
			count16 = 0;
		if (rst) begin
			count = 0;
			count16 = 0;
		end
	end
endmodule
module uart_core(clk,rxd,txd,in_buffer,out_buffer,data_rdy,clear,cts,send,rst);
	input clk,rst;
	input rxd;
	input clear;
	output reg [7:0] in_buffer;
	output reg data_rdy;
	output cts;
	input [7:0] out_buffer;
	input send;
	output txd;
	wire baud;
	wire baud16;
	uart_baud_generator ubg(clk,baud,baud16,rst);
	reg [3:0] rxd_state;
	reg [3:0] baud16_space;
	wire baud16_mark = (baud16_space == 0) ? 1 : 0;
	always @(negedge clk) begin
		if (rst) begin
			data_rdy <= 0;
			rxd_state <= 0;
		end else if (baud16) begin
			if (rxd_state != 0) 
				baud16_space <= baud16_space + 1;
			else
				baud16_space <= 15;
			case (rxd_state)
				0: if (!rxd) rxd_state <= 1; 
				1: if (baud16_mark) rxd_state <= 2; 
				2: if (baud16_mark) begin rxd_state <= 3; in_buffer[0] <= rxd; end 
				3: if (baud16_mark) begin rxd_state <= 4; in_buffer[1] <= rxd; end 
				4: if (baud16_mark) begin rxd_state <= 5; in_buffer[2] <= rxd; end 
				5: if (baud16_mark) begin rxd_state <= 6; in_buffer[3] <= rxd; end 
				6: if (baud16_mark) begin rxd_state <= 7; in_buffer[4] <= rxd; end 
				7: if (baud16_mark) begin rxd_state <= 8; in_buffer[5] <= rxd; end 
				8: if (baud16_mark) begin rxd_state <= 9; in_buffer[6] <= rxd; end 
				9: if (baud16_mark) begin rxd_state <= 10; in_buffer[7] <= rxd; end 
				10: if (baud16_mark & rxd) begin rxd_state <= 0; data_rdy <= 1; end
				default: if (baud16_mark) rxd_state <= 0;
			endcase
		end
		if (clear)
			data_rdy <= 0;
	end
	reg [3:0] txd_state;
	assign cts = (txd_state == 0) ? 1 : 0;
	always @(negedge clk) begin
		if (baud) begin
			case (txd_state)
				1: txd_state = 2; 
				2: txd_state = 3; 
				3: txd_state = 4;
				4: txd_state = 5;
				5: txd_state = 6;
				6: txd_state = 7;
				7: txd_state = 8;
				8: txd_state = 9;
				9: txd_state = 10;
				10: txd_state = 0;
				default: txd_state = 0; 
			endcase
		end
		if (send)
			txd_state = 1;
	end
	assign txd = (txd_state == 0) ? 1 : 
					 (txd_state == 1) ? 1 : 
					 (txd_state == 2) ? 0 : 
					 (txd_state == 3) ? out_buffer[0] : 
					 (txd_state == 4) ? out_buffer[1] : 
					 (txd_state == 5) ? out_buffer[2] : 
					 (txd_state == 6) ? out_buffer[3] : 
					 (txd_state == 7) ? out_buffer[4] : 
					 (txd_state == 8) ? out_buffer[5] : 
					 (txd_state == 9) ? out_buffer[6] : 
					 (txd_state == 10) ? out_buffer[7] : 1;
endmodule
