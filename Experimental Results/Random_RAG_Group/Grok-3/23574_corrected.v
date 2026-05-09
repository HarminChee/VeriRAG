`timescale 1ns/1ns
module camera 
(
    input  wire test_i,
    input  wire refclk,
    input  wire reset_n,
    output wire pixclk,
    output wire vsync,
    output wire hsync,
    output wire [7:0] data
);

reg [12:0] hs_counter = 0;
reg [9:0]  vs_counter = 0;
wire       dft_refclk;
assign pixclk = refclk;
assign dft_refclk = test_i ? refclk : refclk;

always @(negedge dft_refclk or negedge reset_n)
begin
    if (reset_n == 0)
    begin
        hs_counter <= 0;
        vs_counter <= 0;
    end
    else
    begin
        if (hs_counter == 1567)
        begin
            hs_counter <= 0;
            if (vs_counter == 510)
                vs_counter <= 0;
            else
                vs_counter <= vs_counter + 1;
        end
        else
            hs_counter <= hs_counter + 1;
    end
end

reg clk2 = 0;
always @(negedge dft_refclk or negedge reset_n)
begin
    if (reset_n == 0)
        clk2 <= 0;
    else
        clk2 <= !clk2;
end

reg [16:0] pixel_counter = 0;
always @(posedge clk2 or negedge reset_n)
begin
    if (reset_n == 0)
        pixel_counter <= 0;
    else if (hs_counter == 1566)
        pixel_counter <= 0;
    else
        pixel_counter <= pixel_counter + 1;
end

reg [7:0] temp_data;
wire [15:0] line_counter;
reg [15:0] line_counter_2;
reg data_part = 0;

always @(negedge dft_refclk or negedge reset_n)
begin
    if (reset_n == 0)
    begin
        data_part <= 0;
        temp_data <= 0;
    end
    else
    begin
        if (!clk2)
            temp_data[7:0] <= pixel_counter[15:8];
        else
            temp_data[7:0] <= pixel_counter[7:0];
    end
end

assign data = temp_data;
assign vsync = (vs_counter < 3 && reset_n != 0) ? 1 : 0;
assign hsync = (vs_counter > 19 && vs_counter < 500 && hs_counter < 1280 && reset_n != 0) ? 1 : 0;

endmodule