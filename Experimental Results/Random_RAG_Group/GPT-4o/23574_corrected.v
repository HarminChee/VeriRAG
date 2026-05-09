`timescale 1ns/1ns
module camera 
(
	input refclk,
	input reset_n,
	input test_i,
	input scan_pixclk,
	input scan_data_part,
	output pixclk,
	output vsync,
	output hsync,
	output [7:0] data
);
reg [12:0] hs_counter = 0;
reg [9:0] vs_counter = 0;
assign pixclk = test_i ? scan_pixclk : refclk;
always @(negedge refclk)
begin
	if(reset_n == 0)
		begin
			hs_counter <= 0;
			vs_counter <= 0;
		end
	else
		begin
			if(hs_counter == 1567)
			begin
				hs_counter <= 0;
				if(vs_counter == 510)
					vs_counter <= 0;
				else
					vs_counter <= vs_counter + 1;
			end
			else
			hs_counter <= hs_counter + 1;
		end
end
reg clk2 = 0;
always@(negedge refclk)
clk2 <= !clk2;
reg [16:0] pixel_counter = 0;
always@(posedge clk2)
begin
	if(hs_counter == 1566)
		pixel_counter <= 0;
	else
		pixel_counter <= pixel_counter + 1;
end
reg [7:0] temp_data;
always@(negedge refclk)
begin
if(reset_n == 0)
	begin
		temp_data <= 0;
	end
else
begin
	if(!clk2)
		temp_data[7:0] <= pixel_counter[15:8];
	else
		temp_data[7:0] <= pixel_counter[7:0];
end
end
wire dft_data_part;
assign dft_data_part = test_i ? scan_data_part : (hs_counter < 1280);
assign data = temp_data;
assign vsync = vs_counter < 3 && reset_n != 0 ? 1 : 0;
assign hsync = vs_counter > 19 && vs_counter < 500 && dft_data_part && reset_n != 0 ? 1 : 0;
endmodule