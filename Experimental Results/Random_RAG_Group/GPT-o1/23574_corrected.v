`timescale 1ns/1ns
module camera 
(
    input refclk,
    input reset_n,
    output pixclk,
    output vsync,
    output hsync,
    output [7:0] data
);

reg [12:0] hs_counter;
reg [9:0]  vs_counter;
reg        clk2_div;
reg [16:0] pixel_counter;
reg [7:0]  temp_data;
assign pixclk = refclk;

always @(posedge refclk or negedge reset_n) begin
    if(!reset_n) begin
        hs_counter <= 0;
        vs_counter <= 0;
        clk2_div   <= 1'b0;
    end 
    else begin
        clk2_div <= ~clk2_div;
        if(hs_counter == 1567) begin
            hs_counter <= 0;
            if(vs_counter == 510)
                vs_counter <= 0;
            else
                vs_counter <= vs_counter + 1'b1;
        end 
        else
            hs_counter <= hs_counter + 1'b1;
    end
end

always @(posedge refclk or negedge reset_n) begin
    if(!reset_n)
        pixel_counter <= 0;
    else if(clk2_div) begin
        if(hs_counter == 1566)
            pixel_counter <= 0;
        else
            pixel_counter <= pixel_counter + 1'b1;
    end
end

always @(posedge refclk or negedge reset_n) begin
    if(!reset_n) begin
        temp_data <= 8'b0;
    end 
    else begin
        if(!clk2_div)
            temp_data <= pixel_counter[15:8];
        else
            temp_data <= pixel_counter[7:0];
    end
end

assign data  = temp_data;
assign vsync = (vs_counter < 3) && reset_n ? 1'b1 : 1'b0;
assign hsync = (vs_counter > 19 && vs_counter < 500 && hs_counter < 1280 && reset_n) ? 1'b1 : 1'b0;

endmodule