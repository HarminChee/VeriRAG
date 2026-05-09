`timescale 1ns / 1ps
`timescale 1ns / 1ps
module memoria_registros_VGA
( 
	input clk, reset,
	input wire formato_hora,
	input cs_seg_hora,cs_min_hora,cs_hora_hora,
	input cs_dia_fecha,cs_mes_fecha,cs_jahr_fecha,
	input cs_seg_timer,cs_min_timer,cs_hora_timer,
	input hold_seg_hora,hold_min_hora,hold_hora_hora,
	input hold_dia_fecha,hold_mes_fecha,hold_jahr_fecha,
	input hold_seg_timer,hold_min_timer,hold_hora_timer,
	input hold_banderas_config,
	input [7:0] data_PicoBlaze,
	input [7:0] count_seg_hora,count_min_hora,count_hora_hora,
	input [7:0] count_dia_fecha,count_mes_fecha,count_jahr_fecha,
	input [7:0] count_seg_timer,count_min_timer,count_hora_timer,
	output wire[7:0] out_seg_hora,out_min_hora,out_hora_hora,
	output wire[7:0] out_dia_fecha,out_mes_fecha,out_jahr_fecha,
	output wire[7:0] out_seg_timer,out_min_timer,out_hora_timer,
	output[1:0] out_banderas_config,
	output reg AM_PM
);
reg flag_done_timer;
wire cs_banderas_config;
assign cs_banderas_config = 1'b0;
wire [7:0]data_HH;
reg [3:0]digit0_HH, digit1_HH;
Registro_Universal #(.N(8))
instancia_seg_hora (
	 .hold(hold_seg_hora),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_seg_hora), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_seg_hora), 
    .out_dato(out_seg_hora)
    );
Registro_Universal #(.N(8))
 instancia_min_hora (
	 .hold(hold_min_hora),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_min_hora), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_min_hora), 
    .out_dato(out_min_hora)
    );
Registro_Universal #(.N(8))
instancia_hora_hora (
	 .hold(hold_hora_hora),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_hora_hora), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_hora_hora), 
    .out_dato(data_HH)
    );
Registro_Universal #(.N(8))
instancia_dia_fecha (
	 .hold(hold_dia_fecha),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_dia_fecha), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_dia_fecha), 
    .out_dato(out_dia_fecha)
    );
Registro_Universal #(.N(8))
instancia_mes_fecha (
	 .hold(hold_mes_fecha),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_mes_fecha), 
    .clk(clk), 
    .reset(reset),  
    .chip_select(cs_mes_fecha), 
    .out_dato(out_mes_fecha)
    );
Registro_Universal #(.N(8))
instancia_jahr_fecha (
	 .hold(hold_jahr_fecha),	
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_jahr_fecha), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_jahr_fecha), 
    .out_dato(out_jahr_fecha)
    );
Registro_Universal #(.N(8))
instancia_seg_timer (
	 .hold(hold_seg_timer),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_seg_timer), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_seg_timer),
    .out_dato(out_seg_timer) 
    );
Registro_Universal #(.N(8))
instancia_min_timer (
	 .hold(hold_min_timer),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_min_timer), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_min_timer), 
    .out_dato(out_min_timer)
    );
Registro_Universal #(.N(8))
instancia_hora_timer(
	 .hold(hold_hora_timer),
    .in_rtc_dato(data_PicoBlaze), 
    .in_count_dato(count_hora_timer), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_hora_timer),
    .out_dato(out_hora_timer)
    );
Registro_Universal #(.N(2))
instancia_bandera_config(
	 .hold(hold_banderas_config),
    .in_rtc_dato(data_PicoBlaze[1:0]), 
    .in_count_dato(2'b0), 
    .clk(clk), 
    .reset(reset), 
    .chip_select(cs_banderas_config),
    .out_dato(out_banderas_config)
    );
always@*
begin
	if(formato_hora)
	begin
		case(data_HH)
		8'd0: begin digit1_HH = 4'b0001; digit0_HH = 4'b0010; AM_PM = 0; end
		8'd1: begin digit1_HH = 4'b0000; digit0_HH = 4'b0001; AM_PM = 0; end
		8'd2: begin digit1_HH = 4'b0000; digit0_HH = 4'b0010; AM_PM = 0; end
		8'd3: begin digit1_HH = 4'b0000; digit0_HH = 4'b0011; AM_PM = 0; end
		8'd4: begin digit1_HH = 4'b0000; digit0_HH = 4'b0100; AM_PM = 0; end
		8'd5: begin digit1_HH = 4'b0000; digit0_HH = 4'b0101; AM_PM = 0; end
		8'd6: begin digit1_HH = 4'b0000; digit0_HH = 4'b0110; AM_PM = 0; end
		8'd7: begin digit1_HH = 4'b0000; digit0_HH = 4'b0111; AM_PM = 0; end
		8'd8: begin digit1_HH = 4'b0000; digit0_HH = 4'b1000; AM_PM = 0; end
		8'd9: begin digit1_HH = 4'b0000; digit0_HH = 4'b1001; AM_PM = 0; end
		8'd16: begin digit1_HH = 4'b0001; digit0_HH = 4'b0000; AM_PM = 0; end
		8'd17: begin digit1_HH = 4'b0001; digit0_HH = 4'b0001; AM_PM = 0; end
		8'd18: begin digit1_HH = 4'b0001; digit0_HH = 4'b0010; AM_PM = 1; end
		8'd19: begin digit1_HH = 4'b0000; digit0_HH = 4'b0001; AM_PM = 1; end
		8'd20: begin digit1_HH = 4'b0000; digit0_HH = 4'b0010; AM_PM = 1; end
		8'd21: begin digit1_HH = 4'b0000; digit0_HH = 4'b0011; AM_PM = 1; end
		8'd22: begin digit1_HH = 4'b0000; digit0_HH = 4'b0100; AM_PM = 1; end
		8'd23: begin digit1_HH = 4'b0000; digit0_HH = 4'b0101; AM_PM = 1; end
		8'd24: begin digit1_HH = 4'b0000; digit0_HH = 4'b0110; AM_PM = 1; end
		8'd25: begin digit1_HH = 4'b0000; digit0_HH = 4'b0111; AM_PM = 1; end
		8'd32: begin digit1_HH = 4'b0000; digit0_HH = 4'b1000; AM_PM = 1; end
		8'd33: begin digit1_HH = 4'b0000; digit0_HH = 4'b1001; AM_PM = 1; end
		8'd34: begin digit1_HH = 4'b0001; digit0_HH = 4'b0000; AM_PM = 1; end
		8'd35: begin digit1_HH = 4'b0001; digit0_HH = 4'b0001; AM_PM = 1; end
		default:  begin digit1_HH = 0; digit0_HH = 0; AM_PM = 0; end
		endcase
	end
	else 
	begin
		digit1_HH = data_HH[7:4];
		digit0_HH = data_HH[3:0];
		AM_PM = 0;
	end
end
assign out_hora_hora = {digit1_HH,digit0_HH};
endmodule 
