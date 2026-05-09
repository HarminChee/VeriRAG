`timescale 1ns / 1ps
`timescale 1ns / 1ps
module TOP
    (
	 input clk, 
	 input reset,
	 input [7:0] RTC_out,
	 input ps2d,
	 input ps2c,
	 output [7:0] RTC_in,
	 output A_D,CS,RD,WR, hsync, vsync,
	 output [7:0] rgb,
	 output reg Flag_Alarma_VGA_1
	 );
	 wire write_strobe, interrupt,sleep, k_write_strobe, read_strobe, interrupt_ack,PB_in, Pulso_Listo,listo,contro_listo,contro_lee,contro_escribe;
	 wire Dato_Dir,HI;
	 wire [7:0] Dato;
	 wire [7:0] Dir;
	 wire [7:0] salida_bus;
	 wire [2:0]estado_m;
    wire [3:0]c_5;
	 wire [3:0] direccion; 
	 wire [7:0] port_id;
	 wire [7:0]in_port;
	 wire [7:0]out_port, RG1, RG2, RG3,VGA_1,VGA_2,VGA_3, seg_Ti, min_Ti, hor_Ti;
	 wire [3:0] d_seg,u_seg;
	 wire en_out, Flag_Alarma_VGA;
	 wire am_pm;
	 wire escribiendo;
	 wire off_alarma;
	 wire on_alarma;
	 wire [7:0]tecla;
	 wire [7:0]tecla2;
	 wire [7:0]tecla3;
	 wire [7:0] Salida_G;
	 assign interrupt=0;
	 assign d_seg[3:0] = RTC_out [7:4];
    assign u_seg[3:0] = RTC_out [3:0];
    assign am_pm=0;
	 assign sleep=0;
	 assign off_alarma=~Flag_Alarma_VGA;
	 assign on_alarma=Flag_Alarma_VGA;
	 PICOBLAZE f2(
    .interrupt(interrupt),
    .sleep(sleep), 
    .clk(clk), 
    .in_port(in_port), 
    .rst(reset), 
    .write_strobe(write_strobe), 
    .k_write_strobe(k_write_strobe), 
    .read_strobe(read_strobe), 
    .out_port(out_port), 
    .port_id(port_id), 
    .interrupt_ack(interrupt_ack)
    );
    MUX_DECO_FF f1 (
	 .tecla(tecla),
	 .tecla2(tecla2),
	 .tecla3(tecla3),
    .rst(reset), 
    .clk(clk), 
    .listo(listo), 
    .listo_lee(listo), 
    .listo_escribe(listo), 
    .seleccion(port_id), 
    .salida_picoblaze(in_port),
	 .RG1(VGA_1),
    .RG2(VGA_2),
    .RG3(VGA_3)
    );
	registros_salida f3 (
    .Write_Strobe(write_strobe), 
    .Out_Port(out_port), 
    .Port_ID(port_id), 
	 .bandera(estado_m),
    .rst(reset), 
    .reset(reset), 
    .clk(clk), 
    .Dir(Dir), 
    .Dato(Dato), 
	 .direccion(direccion),
    .contro_listo(contro_listo), 
    .contro_lee(contro_lee), 
    .contro_escribe(contro_escribe)
    );
	 assign PB_in=1;
	 Contador_Control_de_Tiempos f4 (
    .reset(reset), 
    .clk(clk), 
    .PB_in(PB_in), 
    .enable_inicio(contro_listo), 
    .enable_escribir(contro_escribe), 
    .enable_leer(contro_lee), 
    .estado_m(estado_m), 
    .c_5(c_5)
    );
	 Control_de_Tiempos f5 (
    .enable_inicio(contro_listo), 
    .enable_escribir(contro_escribe), 
    .clk(clk), 
    .enable_leer(contro_lee), 
    .estado(c_5), 
    .Estado_m(estado_m), 
    .A_D(A_D), 
    .CS(CS), 
    .RD(RD), 
    .WR(WR), 
    .HI(HI), 
    .Dato_Dir(Dato_Dir), 
    .listo(listo), 
    .en_out(en_out)
    );
	 Buffer_Triestado_Salida f7 (
    .Deco_out(salida_bus), 
    .en(~HI), 
    .RTC_in(RTC_in)
    );
	 MUX_SALIDA f6 (
    .direccion(Dir), 
    .dato(Dato), 
    .seleccion(Dato_Dir), 
    .salida_bus(salida_bus)
    );
	 MainActivity  f8 (
	 .estado(tecla),
	 .RG1_P(VGA_1),
    .RG2_P(VGA_2),
    .RG3_P(VGA_3),
	 .escribiendo(escribiendo),
	 .en_out(en_out),
    .dig0(d_seg), 
    .dig1(u_seg), 
    .direccion(direccion), 
    .clk(clk), 
    .reset(reset), 
    .off_alarma(off_alarma), 
    .on_alarma(on_alarma), 
    .COLOUR_OUT(rgb), 
    .HS(hsync), 
    .VS(vsync), 
    .seg_Ti(seg_Ti), 
    .min_Ti(min_Ti), 
    .hor_Ti(hor_Ti)
    );
 Deteccion_Tecla f9 (
    .clk(clk), 
    .reset(reset), 
    .ps2d(ps2d), 
    .ps2c(ps2c), 
    .reset_escritura(contro_escribe), 
    .Segundos_RTC(seg_Ti),
    .Minutos_RTC(min_Ti), 
    .Horas_RTC(hor_Ti),	 
    .Senal(tecla2), 
    .Senal_2_ren(escribiendo), 
    .Parametro(tecla), 
    .Salida_1(RG1), 
    .Salida_2(RG2), 
    .Salida_3(RG3), 
    .VGA_1(VGA_1), 
    .VGA_2(VGA_2), 
    .VGA_3(VGA_3), 
    .Flag_VGA(Flag_Alarma_VGA), 
    .Flag_Pico(tecla3),
	 .Salida_G (Salida_G)
    );
	 always @(posedge clk)
	 begin
	    if (!seg_Ti && !min_Ti && !hor_Ti && tecla == 8'h75 && Salida_G == 8'h70) 
		    Flag_Alarma_VGA_1 = 1;
		 else 
		    Flag_Alarma_VGA_1 = 0;
	 end 
endmodule
