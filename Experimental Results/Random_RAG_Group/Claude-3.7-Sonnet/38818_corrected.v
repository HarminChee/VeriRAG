`timescale 1ns / 1ps
`timescale 1ns / 1ps
module controlador_VGA
(
input wire clock, reset, test_mode,
input wire [7:0] in_dato, port_id,
input wire write_strobe, k_write_strobe,
output wire [7:0]out_seg_hora,out_min_hora,out_hora_hora,
output wire [7:0]out_dia_fecha,out_mes_fecha,out_jahr_fecha,
output wire [7:0]out_seg_timer,out_min_timer,out_hora_timer,
output reg alarma_sonora,
output wire hsync, vsync,
output wire [7:0] RGB
);
wire [9:0] pixel_x,pixel_y;
wire video_on; 
wire pixel_tick;
reg [7:0] RGB_reg, RGB_next;
wire text_on, graph_on, pic_on;
wire [7:0] fig_RGB, text_RGB, pic_RGB;
wire pic_ring_on;
wire pic_ringball_on, AMPM_on;
wire cs_seg_hora; 
wire cs_min_hora; 
wire cs_hora_hora; 
wire cs_dia_fecha; 
wire cs_mes_fecha; 
wire cs_jahr_fecha; 
wire cs_seg_timer;
wire cs_min_timer; 
wire cs_hora_timer;
wire hold_seg_hora; 
wire hold_min_hora; 
wire hold_hora_hora; 
wire hold_dia_fecha; 
wire hold_mes_fecha; 
wire hold_jahr_fecha; 
wire hold_seg_timer;
wire hold_min_timer; 
wire hold_hora_timer;
wire hold_banderas_config;
wire [7:0]count_seg_hora; 
wire [7:0]count_min_hora; 
wire [7:0]count_hora_hora; 
wire [7:0]count_dia_fecha; 
wire [7:0]count_mes_fecha; 
wire [7:0]count_jahr_fecha; 
wire [7:0]count_seg_timer;
wire [7:0]count_min_timer; 
wire [7:0]count_hora_timer;
wire [1:0]out_banderas_config;
wire [1:0] config_mode, cursor_location;
wire AM_PM;
localparam N =24;
reg [N-1:0] blink_reg;
reg blink;
localparam N_cursor = 25;
reg [N_cursor-1:0] blink_cursor_reg;
reg blink_cursor;
wire dft_clock;
assign dft_clock = test_mode ? reset : clock;

timing_generator_VGA instancia_timing_generator_VGA
(
.clk(dft_clock),
.reset(reset),
.hsync(hsync),
.vsync(vsync),
.video_on(video_on),
.p_tick(pixel_tick),
.pixel_x(pixel_x), 
.pixel_y(pixel_y)
);

generador_figuras instancia_generador_figuras
(
.video_on(video_on),
.pixel_x(pixel_x), 
.pixel_y(pixel_y),
.graph_on(graph_on),
.fig_RGB(fig_RGB) 
);

generador_caracteres instancia_generador_caracteres
(
.clk(dft_clock),
.digit0_HH(out_hora_hora[3:0]), .digit1_HH(out_hora_hora[7:4]), .digit0_MM(out_min_hora[3:0]), .digit1_MM(out_min_hora[7:4]), .digit0_SS(out_seg_hora[3:0]), .digit1_SS(out_seg_hora[7:4]),
.digit0_DAY(out_dia_fecha[3:0]), .digit1_DAY(out_dia_fecha[7:4]), .digit0_MES(out_mes_fecha[3:0]), .digit1_MES(out_mes_fecha[7:4]), .digit0_YEAR(out_jahr_fecha[3:0]), .digit1_YEAR(out_jahr_fecha[7:4]),
.digit0_HH_T(out_hora_timer[3:0]), .digit1_HH_T(out_hora_timer[7:4]), .digit0_MM_T(out_min_timer[3:0]), .digit1_MM_T(out_min_timer[7:4]), .digit0_SS_T(out_seg_timer[3:0]), .digit1_SS_T(out_seg_timer[7:4]),
.AM_PM(AM_PM),
.config_mode(config_mode),
.cursor_location(cursor_location),
.pixel_x(pixel_x), .pixel_y(pixel_y),
.parpadeo(blink_cursor),
.text_on(text_on),
.AMPM_on(AMPM_on), 
.text_RGB(text_RGB) 
);

generador_imagenes instancia_generador_imagenes
(
.video_on(video_on),
.pixel_x(pixel_x), 
.pixel_y(pixel_y),
.pic_ring_on(pic_ring_on),
.pic_ringball_on(pic_ringball_on),
.pic_on(pic_on),
.pic_RGB(pic_RGB)
);

memoria_registros_VGA instancia_memoria_registros_VGA 
(
    .clk(dft_clock), 
    .reset(reset),
    .formato_hora(out_banderas_config[1]),
    .cs_seg_hora(cs_seg_hora), 
    .cs_min_hora(cs_min_hora), 
    .cs_hora_hora(cs_hora_hora), 
    .cs_dia_fecha(cs_dia_fecha), 
    .cs_mes_fecha(cs_mes_fecha), 
    .cs_jahr_fecha(cs_jahr_fecha), 
    .cs_seg_timer(cs_seg_timer), 
    .cs_min_timer(cs_min_timer), 
    .cs_hora_timer(cs_hora_timer), 
    .hold_seg_hora(hold_seg_hora), 
    .hold_min_hora(hold_min_hora), 
    .hold_hora_hora(hold_hora_hora), 
    .hold_dia_fecha(hold_dia_fecha), 
    .hold_mes_fecha(hold_mes_fecha), 
    .hold_jahr_fecha(hold_jahr_fecha), 
    .hold_seg_timer(hold_seg_timer), 
    .hold_min_timer(hold_min_timer), 
    .hold_hora_timer(hold_hora_timer), 
    .hold_banderas_config(hold_banderas_config), 
    .data_PicoBlaze(in_dato), 
    .count_seg_hora(count_seg_hora), 
    .count_min_hora(count_min_hora), 
    .count_hora_hora(count_hora_hora), 
    .count_dia_fecha(count_dia_fecha), 
    .count_mes_fecha(count_mes_fecha), 
    .count_jahr_fecha(count_jahr_fecha), 
    .count_seg_timer(count_seg_timer), 
    .count_min_timer(count_min_timer), 
    .count_hora_timer(count_hora_timer), 
    .out_seg_hora(out_seg_hora), 
    .out_min_hora(out_min_hora), 
    .out_hora_hora(out_hora_hora), 
    .out_dia_fecha(out_dia_fecha), 
    .out_mes_fecha(out_mes_fecha), 
    .out_jahr_fecha(out_jahr_fecha), 
    .out_seg_timer(out_seg_timer), 
    .out_min_timer(out_min_timer), 
    .out_hora_timer(out_hora_timer), 
    .out_banderas_config(out_banderas_config),
    .AM_PM(AM_PM)
);

contadores_configuracion instancia_contadores_configuracion (
    .clk(dft_clock), 
    .reset(reset), 
    .in_dato(in_dato), 
    .port_id(port_id), 
    .write_strobe(write_strobe), 
    .k_write_strobe(k_write_strobe), 
    .btn_data_SS(count_seg_hora), 
    .btn_data_MM(count_min_hora), 
    .btn_data_HH(count_hora_hora), 
    .btn_data_YEAR(count_jahr_fecha), 
    .btn_data_MES(count_mes_fecha), 
    .btn_data_DAY(count_dia_fecha), 
    .btn_data_SS_T(count_seg_timer), 
    .btn_data_MM_T(count_min_timer), 
    .btn_data_HH_T(count_hora_timer), 
    .cursor_location(cursor_location), 
    .config_mode(config_mode)
    );

deco_hold_registros instancia_deco_hold_registros (
    .write_strobe(write_strobe), 
    .port_id(port_id),
    .config_mode(config_mode),
    .hold_seg_hora(hold_seg_hora), 
    .hold_min_hora(hold_min_hora), 
    .hold_hora_hora(hold_hora_hora), 
    .hold_dia_fecha(hold_dia_fecha), 
    .hold_mes_fecha(hold_mes_fecha), 
    .hold_jahr_fecha(hold_jahr_fecha), 
    .hold_seg_timer(hold_seg_timer), 
    .hold_min_timer(hold_min_timer), 
    .hold_hora_timer(hold_hora_timer),
    .hold_banderas_config(hold_banderas_config)
    );

decodificador_cs_registros instancia_decodificador_cs_registros (
    .funcion_conf(config_mode), 
    .cs_seg_hora(cs_seg_hora), 
    .cs_min_hora(cs_min_hora), 
    .cs_hora_hora(cs_hora_hora), 
    .cs_dia_fecha(cs_dia_fecha), 
    .cs_mes_fecha(cs_mes_fecha), 
    .cs_jahr_fecha(cs_jahr_fecha), 
    .cs_seg_timer(cs_seg_timer), 
    .cs_min_timer(cs_min_timer), 
    .cs_hora_timer(cs_hora_timer)
    );

always @(posedge dft_clock, posedge reset)
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

always@*
begin
    if (out_banderas_config[0] && blink) alarma_sonora = 1'b1;
    else alarma_sonora = 1'b0;
end

always @(posedge dft_clock, posedge reset)
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

always@*
begin
    if(~video_on)
    RGB_next = "0";
    else
        if(text_on) RGB_next = text_RGB;
        else if (AMPM_on && out_banderas_config[1]) RGB_next = text_RGB;
        else if (graph_on) RGB_next = fig_RGB;
        else if (pic_on) RGB_next = pic_RGB;
        else if (pic_ringball_on && out_banderas_config[0] && blink) RGB_next = pic_RGB;
        else if (pic_ring_on && out_banderas_config[0] && blink) RGB_next = pic_RGB;
        else RGB_next = 8'h00;
end

always @(posedge dft_clock)
if (pixel_tick) RGB_reg <= RGB_next;

assign RGB = RGB_reg;

endmodule