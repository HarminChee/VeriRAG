`timescale 1ns / 1ps
`timescale 1ns / 1ps
module uart_tx (
	input reset,
	input clk,
	input [1:0] baud_rate,
	input ld_tx_data,
	input [7:0] tx_data,
	input tx_enable,
	(* IOB = "TRUE" *) output reg tx_out,
	output reg tx_empty
);
parameter ML505 = 0; 
reg [7:0] tx_reg;
reg [3:0] tx_cnt;
reg [9:0] baud_cnt;
reg baud_clk;
always @ (posedge clk) begin
	if (reset) begin
		baud_clk <= 1'b0;
		baud_cnt <= 10'b0;
		tx_reg        <= 8'd0;
		tx_empty      <= 1'b1;
		tx_out        <= 1'b1;
		tx_cnt        <= 4'd0;
	end else begin 
		if (ML505) begin
			if (baud_cnt == 10'd868) begin
				baud_clk <= 1'b1;
				baud_cnt <= 10'd0;
			end else begin
				baud_clk <= 1'b0;
				baud_cnt <= baud_cnt + 1;
			end 
		end else begin
			case(baud_rate)
				2'd0: begin 
					if (baud_cnt == 10'd347) begin
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
				2'd1: begin
					if (baud_cnt == 10'd174) begin 
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
				2'd2: begin	
					if (baud_cnt == 10'd87) begin 
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
				default: begin 
					if (baud_cnt == 10'd347) begin
						baud_clk <= 1'b1;
						baud_cnt <= 10'd0;
					end else begin
						baud_clk <= 1'b0;
						baud_cnt <= baud_cnt + 1;
					end 
				end
			endcase
		end 
		if (tx_enable && baud_clk) begin
			if (ld_tx_data && tx_empty) begin
				tx_reg   <= tx_data;
				tx_empty <= 1'b0;
				tx_out <= 1'b0; 
				tx_cnt <= tx_cnt;
			end else if (!tx_empty) begin
				tx_reg <= tx_reg;
				if (tx_cnt == 4'd8) begin
					tx_cnt <= 4'd0;
					tx_out <= 1'b1;
					tx_empty <= 1'b1;
				end else begin
					tx_cnt <= tx_cnt + 1;
					tx_out <= tx_reg[tx_cnt];
					tx_empty <= tx_empty;
				end
			end else begin
				tx_reg <= tx_reg;
				tx_cnt <= tx_cnt;
				tx_out <= tx_out;
				tx_empty <= tx_empty;
			end
		end else begin
			tx_reg <= tx_reg;
			tx_cnt <= tx_cnt;
			tx_out <= tx_out;
			tx_empty <= tx_empty;
		end 
	end 
end 
endmodule
