`timescale 1ns / 1ps
module controlador_VGA
(
input wire clock, reset,
input wire test_mode, // Added test mode input
input wire [7:0] in_dato, port_id,
input wire write_strobe, k_write_strobe,
output wire [7:0]out_seg_hora,out_min_hora,out_hora_hora,
output wire [7:0]out_dia_fecha,out_mes_fecha,out_jahr_fecha,
output wire [7:0]out_seg_timer,out_min_timer,out_hora_timer,
output reg alarma_sonora,
output wire hsync, vsync,
output wire [7:0] RGB
);

// ... existing code ...

wire clk_gated;
assign clk_gated = test_mode ? 1'b0 : clock; // Gate clock in test mode

always @(posedge clk_gated, posedge reset)
begin
    if (reset)begin blink_reg <= 0; blink <= 0; end
    else
    begin
        if (blink_reg == 24'd16666666)
            begin
            blink_reg <= 0;
            blink <= ~blink;
            end
        else
            blink_reg <= blink_reg + 1'b1;
    end
end

// ... existing code ...

always @(posedge clk_gated, posedge reset)
begin
    if (reset)begin blink_cursor_reg <= 0; blink_cursor <= 0; end
    else
    begin
        if (blink_cursor_reg == 25'd24999999)
            begin
            blink_cursor_reg <= 0;
            blink_cursor <= ~blink_cursor;
            end
        else
            blink_cursor_reg <= blink_cursor_reg + 1'b1;
    end
end        

// ... existing code ...

always @(posedge clk_gated)
if (pixel_tick) RGB_reg <= RGB_next;

// ... existing code ...

endmodule