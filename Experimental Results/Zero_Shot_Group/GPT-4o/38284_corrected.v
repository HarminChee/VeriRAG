`timescale 1ns / 1ps
module top_reloj_digital_v2
(
input wire clk, reset,
input wire ps2data, 
input wire ps2clk, 
inout [7:0] dato,
output wire AD, CS, WR, RD,
output wire alarma_sonora,
output wire [7:0] RGB,
output wire hsync, vsync
);
reg [7:0]in_port;
wire [7:0]out_port;
wire [7:0]port_id;
wire write_strobe;
wire k_write_strobe;
wire read_strobe;
wire interrupt;
wire [7:0]out_seg_hora,out_min_hora,out_hora_hora;
wire [7:0]out_dia_fecha,out_mes_fecha,out_jahr_fecha;
wire [7:0]out_seg_timer,out_min_timer,out_hora_timer;
wire fin_lectura_escritura;
wire [7:0] out_dato;
wire [7:0] ascii_code;
assign interrupt = 1'b0;
microcontrolador instancia_microcontrolador 
(
    .clk(clk), 
    .reset(reset), 
    .interrupt(interrupt), 
    .in_port(in_port), 
    .write_strobe(write_strobe), 
    .k_write_strobe(k_write_strobe), 
    .read_strobe(read_strobe), 
    .interrupt_ack(), 
    .port_id(port_id), 
    .out_port(out_port)
);
escritor_lector_rtc_2 instancia_escritor_lector_rtc_2 
(
    .clk(clk), 
    .reset(reset), 
    .in_dato(out_port),
    .port_id(port_id),
    .write_strobe(write_strobe), 
    .k_write_strobe(k_write_strobe),
    .read_strobe(read_strobe),
    .reg_a_d(AD), 
    .reg_cs(CS), 
    .reg_rd(RD), 
    .reg_wr(WR), 
    .out_dato(out_dato), 
    .flag_done(fin_lectura_escritura), 
    .dato(dato)
);
controlador_teclado_ps2 instancia_controlador_teclado_ps2 
(
    .clk(clk), 
    .reset(reset), 
    .ps2data(ps2data), 
    .ps2clk(ps2clk), 
    .port_id(port_id), 
    .read_strobe(read_strobe), 
    .ascii_code(ascii_code)
);
controlador_VGA instancia_controlador_VGA 
(
    .clock(clk), 
    .reset(reset), 
    .in_dato(out_port), 
    .port_id(port_id), 
    .write_strobe(write_strobe), 
    .k_write_strobe(k_write_strobe), 
    .out_seg_hora(out_seg_hora), 
    .out_min_hora(out_min_hora), 
    .out_hora_hora(out_hora_hora), 
    .out_dia_fecha(out_dia_fecha), 
    .out_mes_fecha(out_mes_fecha), 
    .out_jahr_fecha(out_jahr_fecha), 
    .out_seg_timer(out_seg_timer), 
    .out_min_timer(out_min_timer), 
    .out_hora_timer(out_hora_timer),
    .alarma_sonora(alarma_sonora),
    .hsync(hsync), 
    .vsync(vsync), 
    .RGB(RGB)
);
always@(posedge clk)
begin
    case (port_id) 
    8'h0F : in_port <= fin_lectura_escritura;
    8'h10 : in_port <= out_dato;
    8'h02 : in_port <= ascii_code;
    8'h12 : in_port <= out_seg_hora;
    8'h13 : in_port <= out_min_hora;
    8'h14 : in_port <= out_hora_hora;
    8'h15 : in_port <= out_dia_fecha;
    8'h16 : in_port <= out_mes_fecha;
    8'h17 : in_port <= out_jahr_fecha;
    8'h18 : in_port <= out_seg_timer;
    8'h19 : in_port <= out_min_timer;
    8'h1A : in_port <= out_hora_timer;
    default : in_port <= 8'b00000000;  
    endcase
end
endmodule