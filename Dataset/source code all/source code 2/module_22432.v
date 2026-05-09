`timescale 1ns / 1ps
`timescale 1ns / 1ps
module DPWM
(
input wire CLK_FPGA_BOARD,
input wire boton_aumentar,
input wire boton_disminuir,
input wire seleccion_funcion,
input wire seleccion_salida,
input wire reinicio,
output reg BUCK_Gate,
output reg Full_Bridge,
output wire [3:0] anodos_7seg,
output wire [7:0] catodos_7seg
);
wire boton_aumentar_sincronizado;
wire boton_disminuir_sincronizado;
wire seleccion_funcion_sincronizado;
wire seleccion_salida_sincronizado;
wire reinicio_sincronizado;
wire [3:0] OutCuenta_Modificacion_Frec_Conmu_In_Control_visualizador_numerico;
wire [3:0] OutCuenta_Modificacion_CT_In_Control_visualizador_numerico;
wire OutCLK1kHz_Modificacion_Frec_Conmu_In_Control_visualizador_numerico; 
wire OutCLKVar_Modificacion_Frec_Conmu_In_Modificacion_CT;
wire OutSignal_Modificacion_Ciclo_Trabajo_In_Distribucion_Salida; 
Sincronizador Instancia_Sincronizador(
.incambiarfuncion(seleccion_funcion),
.incambiarsalida(seleccion_salida),
.inrst(reinicio),
.inbtup(boton_aumentar),
.inbtdown(boton_disminuir),
.clk(CLK_FPGA_BOARD),
.outcambiarfuncion(seleccion_funcion_sincronizado),
.outcambiarsalida(seleccion_salida_sincronizado),
.outbtup(boton_aumentar_sincronizado),
.outbtdown(boton_disminuir_sincronizado),
.outrst(reinicio_sincronizado)
);
Modificacion_Frec_Conmu Instancia_Modificacion_Frec_Conmu
(
.CLK_100MHz(CLK_FPGA_BOARD),
.aumentar_Frec(boton_aumentar_sincronizado),
.disminuir_Frec(boton_disminuir_sincronizado),
.funct_select(~seleccion_funcion_sincronizado),
.reset(reinicio_sincronizado),
.CLK_dividido(OutCLKVar_Modificacion_Frec_Conmu_In_Modificacion_CT),
.CLK_1kHz(OutCLK1kHz_Modificacion_Frec_Conmu_In_Control_visualizador_numerico),
.OutContadorAD_InMDF(OutCuenta_Modificacion_Frec_Conmu_In_Control_visualizador_numerico) 
);
Modificacion_Ciclo_Trabajo Instancia_Modificacion_Ciclo_Trabajo (
    .clk_100MHz(CLK_FPGA_BOARD), 
    .clk_de_trabajo(OutCLKVar_Modificacion_Frec_Conmu_In_Modificacion_CT), 
    .rst(reinicio_sincronizado), 
    .up(boton_aumentar_sincronizado), 
    .down(boton_disminuir_sincronizado), 
    .chip_select(seleccion_funcion_sincronizado), 
    .signal_out(OutSignal_Modificacion_Ciclo_Trabajo_In_Distribucion_Salida), 
    .ciclo_actual(OutCuenta_Modificacion_CT_In_Control_visualizador_numerico)
    );
Control_visualizador_numerico Instancia_Control_visualizador_numerico
(
.cuenta_frec(OutCuenta_Modificacion_Frec_Conmu_In_Control_visualizador_numerico),
.cuenta_CT(OutCuenta_Modificacion_CT_In_Control_visualizador_numerico),
.clock(OutCLK1kHz_Modificacion_Frec_Conmu_In_Control_visualizador_numerico),
.reset(reinicio_sincronizado),
.funct_select(seleccion_funcion_sincronizado),
.code_digitos_decimal(catodos_7seg), 
.code_7seg(anodos_7seg) 
);
always @(posedge CLK_FPGA_BOARD)
begin
	if (seleccion_salida_sincronizado) begin
		Full_Bridge <= OutSignal_Modificacion_Ciclo_Trabajo_In_Distribucion_Salida;
		BUCK_Gate <= 0;
		end
	else begin
		Full_Bridge <= 0;
		BUCK_Gate <= OutSignal_Modificacion_Ciclo_Trabajo_In_Distribucion_Salida;
		end
end
endmodule
