`timescale 1ns/1ps
`timescale 1ns/1ps
module figuras_Gato(
	input wire video_mostrar, 
	input wire [3:0] selector_entrada,
	input wire [1:0] linea_h, linea_v, linea_c,
	input wire [2:0] c1_in,c2_in,c3_in,c4_in,c5_in,c6_in,c7_in,c8_in,c9_in,
	input wire [9:0] pixel_x, pixel_y,
	output reg [2:0] salida_rgb
    );
	 localparam cuadrante1 = 4'd1;
	 localparam cuadrante2 = 4'd2;
	 localparam cuadrante3 = 4'd3;
	 localparam cuadrante4 = 4'd4;
	 localparam cuadrante5 = 4'd5;
	 localparam cuadrante6 = 4'd6;
	 localparam cuadrante7 = 4'd7;
	 localparam cuadrante8 = 4'd8;
	 localparam cuadrante9 = 4'd9;
	 reg [3:0] cuadranteActual;
	reg [2:0] lineaGato_rgb=3'b111;
	localparam lineaV_Y_Size=240;
	localparam lineaH_X_Size=180;
	localparam lim_bar_V_Y_Sup = 120;
	localparam lim_bar_V_Y_Inf= 300;
	localparam lim_bar_H_X_Izq = 160;
	localparam lim_bar_H_X_Der= 400;
	localparam lim_head_V_Y_Sup = 20;
	localparam lim_head_V_Y_Inf = 75;
	localparam lim_head_H_X_Izq = 140;
	localparam lim_head_H_X_2= lim_head_H_X_Izq+45;
	localparam lim_head_H_X_3= lim_head_H_X_2+45;
	localparam lim_head_H_X_4= lim_head_H_X_3+90;
	localparam lim_head_H_X_5= lim_head_H_X_4+45;
	localparam lim_head_H_X_Der = lim_head_H_X_5+45;
	localparam lineaV1_X_Der = 242;
	localparam lineaV1_X_Izq= 238;
	localparam lineaV2_X_Der = 322;
	localparam lineaV2_X_Izq= 318;
	localparam lineaH1_Y_Sup = 178;
	localparam lineaH1_Y_Inf= 182;
	localparam lineaH2_Y_Sup = 238;
	localparam lineaH2_Y_Inf= 242;;
	wire lineaV1_mostrar;
	assign lineaV1_mostrar = (lineaV1_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Der) &&
							  (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <=lim_bar_V_Y_Inf);
	wire lineaV2_mostrar;
	assign lineaV2_mostrar = (lineaV2_X_Izq<=pixel_x) && (pixel_x <= lineaV2_X_Der) &&
							  (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <=lim_bar_V_Y_Inf);
	wire lineaH1_mostrar;
	assign lineaH1_mostrar = (lineaH1_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Inf) &&
							  (lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lim_bar_H_X_Der);
	wire lineaH2_mostrar;
	assign lineaH2_mostrar = (lineaH2_Y_Sup<=pixel_y) && (pixel_y <= lineaH2_Y_Inf) &&
							  (lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lim_bar_H_X_Der);
	reg[8:0] p_mostrar;
	reg [3:0] rom_p_addr;
	reg [17:0] rom_p_data;
	always @ (*) begin
		case (rom_p_addr)
			4'd0:
				rom_p_data = 18'b000000000000000000;
			4'd1:
				rom_p_data = 18'b000000000000000000;
			4'd2:
				rom_p_data = 18'b000000001111111100;
			4'd3:
				rom_p_data = 18'b000000001111111100;
			4'd4:
				rom_p_data = 18'b000000001100001100;
			4'd5:
				rom_p_data = 18'b000000001100001100;
			4'd6:
				rom_p_data = 18'b000000001100001100;
			4'd7:
				rom_p_data = 18'b000000001111111100;
			4'd8:
				rom_p_data = 18'b000000001111111100;
			4'd9:
				rom_p_data = 18'b000000000000001100;
			4'd10:
				rom_p_data = 18'b000000000000001100;
			4'd11:
				rom_p_data = 18'b000000000000001100;
			4'd12:
				rom_p_data = 18'b000000000000001100;
			4'd13:
				rom_p_data = 18'b000000000000000000;
			4'd14:
				rom_p_data = 18'b000000000000000000;
		endcase
	end
	reg[8:0] uno_mostrar;
	reg [3:0] rom_uno_addr;
	reg [17:0] rom_uno_data;
	always @ (*) begin
		case (rom_uno_addr)
			4'd0:
				rom_uno_data = 18'b000000000000000000;
			4'd1:
				rom_uno_data = 18'b000000000000000000;
			4'd2:
				rom_uno_data = 18'b000000000011110000;
			4'd3:
				rom_uno_data = 18'b000000000011110000;
			4'd4:
				rom_uno_data = 18'b000000000011000000;
			4'd5:
				rom_uno_data = 18'b000000000011000000;
			4'd6:
				rom_uno_data = 18'b000000000011000000;
			4'd7:
				rom_uno_data = 18'b000000000011000000;
			4'd8:
				rom_uno_data = 18'b000000000011000000;
			4'd9:
				rom_uno_data = 18'b000000000011000000;
			4'd10:
				rom_uno_data = 18'b000000000011000000;
			4'd11:
				rom_uno_data = 18'b000000001111110000;
			4'd12:
				rom_uno_data = 18'b000000001111110000;
			4'd13:
				rom_uno_data = 18'b000000000000000000;
			4'd14:
				rom_uno_data = 18'b000000000000000000;
		endcase
	end
	reg[8:0] dos_mostrar;
	reg [3:0] rom_dos_addr;
	reg [17:0] rom_dos_data;
	always @ (*) begin
		case (rom_dos_addr)
			4'd0:
				rom_dos_data = 18'b000000000000000000;
			4'd1:
				rom_dos_data = 18'b000000000000000000;
			4'd2:
				rom_dos_data = 18'b000000001111110000;
			4'd3:
				rom_dos_data = 18'b000000001111110000;
			4'd4:
				rom_dos_data = 18'b000000001100000000;
			4'd5:
				rom_dos_data = 18'b000000001100000000;
			4'd6:
				rom_dos_data = 18'b000000001111110000;
			4'd7:
				rom_dos_data = 18'b000000001111110000;
			4'd8:
				rom_dos_data = 18'b000000000000110000;
			4'd9:
				rom_dos_data = 18'b000000000000110000;
			4'd10:
				rom_dos_data = 18'b000000000000110000;
			4'd11:
				rom_dos_data = 18'b000000001111110000;
			4'd12:
				rom_dos_data = 18'b000000001111110000;
			4'd13:
				rom_dos_data = 18'b000000000000000000;
			4'd14:
				rom_dos_data = 18'b000000000000000000;
		endcase
	end
	reg[3:0] rom_p1_col, rom_uno_col;
	reg rom_p1_bit,rom_uno_bit;
	reg cuadrante_p1_on, cuadrante_uno_on;
	reg p1_mostrar;
	always @ (*) begin
		cuadrante_p1_on =(lim_head_V_Y_Sup<=pixel_y) && (pixel_y <= lim_head_V_Y_Inf) &&
							  (lim_head_H_X_Izq<=pixel_x) && (pixel_x <= lim_head_H_X_2) ;
		cuadrante_uno_on=(lim_head_V_Y_Sup<=pixel_y) && (pixel_y <= lim_head_V_Y_Inf) &&
							  (lim_head_H_X_2<=pixel_x) && (pixel_x <= lim_head_H_X_3);
		rom_p_addr = pixel_y[5:2] - lim_head_V_Y_Sup[5:2];
		rom_p1_col = pixel_x[5:2] - lim_head_H_X_Izq[5:2];
		rom_uno_addr = pixel_y[5:2] - lim_head_V_Y_Sup[5:2];
		rom_uno_col = pixel_x[5:2] - lim_head_H_X_2[5:2];
		rom_p1_bit = rom_p_data[rom_p1_col];
		p1_mostrar= cuadrante_p1_on & rom_p1_bit;
		rom_uno_bit = rom_uno_data[rom_uno_col];
		uno_mostrar= cuadrante_uno_on & rom_uno_bit;
	end
	reg[3:0] rom_p2_col, rom_dos_col;
	reg rom_p2_bit,rom_dos_bit;
	reg cuadrante_p2_on, cuadrante_dos_on;
	reg p2_mostrar;
	always @ (*) begin
		cuadrante_p2_on =(lim_head_V_Y_Sup<=pixel_y) && (pixel_y <= lim_head_V_Y_Inf) &&
							  (lim_head_H_X_4<=pixel_x) && (pixel_x <= lim_head_H_X_5) ;
		cuadrante_dos_on=(lim_head_V_Y_Sup<=pixel_y) && (pixel_y <= lim_head_V_Y_Inf) &&
							  (lim_head_H_X_5<=pixel_x) && (pixel_x <= lim_head_H_X_Der);
		rom_p_addr = pixel_y[5:2] - lim_head_V_Y_Sup[5:2];
		rom_p2_col = pixel_x[5:2] - lim_head_H_X_4[5:2];
		rom_dos_addr = pixel_y[5:2] - lim_head_V_Y_Sup[5:2];
		rom_dos_col = pixel_x[5:2] - lim_head_H_X_5[5:2];
		rom_p2_bit = rom_p_data[rom_p2_col];
		p2_mostrar= cuadrante_p2_on & rom_p2_bit;
		rom_dos_bit = rom_dos_data[rom_dos_col];
		dos_mostrar= cuadrante_dos_on & rom_dos_bit;
	end
	reg[8:0] cuadro_mostrar;
	always @ (*) begin
		cuadranteActual= selector_entrada;
		case(cuadranteActual) 
			cuadrante1: begin
							cuadro_mostrar[0] = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
																	(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq);
							end
			cuadrante2: begin
							cuadro_mostrar[1] = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
																	(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq);
							end
			cuadrante3: begin
							cuadro_mostrar[2] = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
																	(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der);
							end
			cuadrante4: begin
							cuadro_mostrar[3] = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
																	(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq);
							end
			cuadrante5: begin
							cuadro_mostrar[4] = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
																	(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq);
							end
			cuadrante6: begin
							cuadro_mostrar[5] = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
																	(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der);
							end
			cuadrante7: begin
							cuadro_mostrar[6] = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf) &&
																	(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq);
							end
			cuadrante8: begin
							cuadro_mostrar[7] = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf) &&
																	(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq);
							end
			cuadrante9: begin
							cuadro_mostrar[8] = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf) &&
																	(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der);
							end
			default: 	begin
							cuadro_mostrar= 4'b0000;			
							end
		endcase
	end
	reg[8:0] equis_mostrar;
	reg [3:0] rom_equis_addr;
	reg [17:0] rom_equis_data;
	always @ (*) begin
		case (rom_equis_addr)
			4'd0:
				rom_equis_data = 18'b000000000000000000;
			4'd1:
				rom_equis_data = 18'b000000000000000000;
			4'd2:
				rom_equis_data = 18'b001100000000000110;
			4'd3:
				rom_equis_data = 18'b001110000000001110;
			4'd4:
				rom_equis_data = 18'b000111100000111100;
			4'd5:
				rom_equis_data = 18'b000001111011110000;
			4'd6:
				rom_equis_data = 18'b000000011111000000;
			4'd7:
				rom_equis_data = 18'b000000001110000000;
			4'd8:
				rom_equis_data = 18'b000000011111000000;
			4'd9:
				rom_equis_data = 18'b000001111011110000;
			4'd10:
				rom_equis_data = 18'b000111100000111100;
			4'd11:
				rom_equis_data = 18'b001110000000001110;
			4'd12:
				rom_equis_data = 18'b001100000000000110;
			4'd13:
				rom_equis_data = 18'b000000000000000000;
			4'd14:
				rom_equis_data = 18'b000000000000000000;
		endcase
	end
	reg[8:0] circulo_mostrar;
	reg [3:0] rom_circulo_addr;
	reg [17:0] rom_circulo_data;
	always @ (*) begin
		case (rom_circulo_addr)
			4'd0:
				rom_circulo_data = 18'b000000000000000000;
			4'd1:
				rom_circulo_data = 18'b000000000000000000;
			4'd2:
				rom_circulo_data = 18'b000000111111100000;
			4'd3:
				rom_circulo_data = 18'b000001000000010000;
			4'd4:
				rom_circulo_data = 18'b000110000000001100;
			4'd5:
				rom_circulo_data = 18'b000100000000000100;
			4'd6:
				rom_circulo_data = 18'b001000000000000010;
			4'd7:
				rom_circulo_data = 18'b001000000000000010;
			4'd8:
				rom_circulo_data = 18'b001000000000000010;
			4'd9:
				rom_circulo_data = 18'b000100000000000100;
			4'd10:
				rom_circulo_data = 18'b000110000000001100;
			4'd11:
				rom_circulo_data = 18'b000001000000010000;
			4'd12:
				rom_circulo_data = 18'b000000111111100000;
			4'd13:
				rom_circulo_data = 18'b000000000000000000;
			4'd14:
				rom_circulo_data = 18'b000000000000000000;
		endcase
	end
	reg[3:0] rom_equis_col;
	reg rom_equis_bit;
	reg cuadrante_on;
	reg cuadrante_circ_on;
	reg[3:0] rom_circulo_col;
	reg rom_circulo_bit;
	always @ (*) begin
		case(c1_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
										  (lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq-14);
				rom_circulo_addr = pixel_y[5:2] - lim_bar_V_Y_Sup[5:2];
				rom_circulo_col = pixel_x[7:2] - lim_bar_H_X_Izq[7:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[0]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
									(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq-14);
				rom_equis_addr = pixel_y[6:2] - lim_bar_V_Y_Sup[6:2];
				rom_equis_col = pixel_x[6:2] - lim_bar_H_X_Izq[6:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[0]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c2_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
									(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq-14);
				rom_circulo_addr = pixel_y[5:2] - lim_bar_V_Y_Sup[5:2];
				rom_circulo_col = pixel_x[7:2] - lineaV1_X_Der[7:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[1]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
									(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq-14);
				rom_equis_addr = pixel_y[5:2] - lim_bar_V_Y_Sup[5:2];
				rom_equis_col = pixel_x[5:2] - lineaV1_X_Der[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[1]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c3_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
									(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der-16);
				rom_circulo_addr = pixel_y[5:2] - lim_bar_V_Y_Sup[5:2];
				rom_circulo_col = pixel_x[7:2] - lineaV2_X_Der[7:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[2]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lim_bar_V_Y_Sup<=pixel_y) && (pixel_y <= lineaH1_Y_Sup) &&
									(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der-16);
				rom_equis_addr = pixel_y[5:2] - lim_bar_V_Y_Sup[5:2];
				rom_equis_col = pixel_x[5:2] - lineaV2_X_Der[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[2]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c4_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
				(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq-14);
				rom_circulo_addr = pixel_y[5:2] - lineaH1_Y_Inf[5:2];
				rom_circulo_col = pixel_x[8:2] - lim_bar_H_X_Izq[8:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[3]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
									(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq-14);
				rom_equis_addr = pixel_y[5:2] - lineaH1_Y_Inf[5:2];
				rom_equis_col = pixel_x[5:2] - lim_bar_H_X_Izq[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[3]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c5_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
									(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq-14);
				rom_circulo_addr = pixel_y[5:2] - lineaH1_Y_Inf[5:2];
				rom_circulo_col = pixel_x[8:2] - lineaV1_X_Der[8:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[4]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
									(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq-14);
				rom_equis_addr = pixel_y[5:2] - lineaH1_Y_Inf[5:2];
				rom_equis_col = pixel_x[5:2] - lineaV1_X_Der[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[4]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c6_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
									(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der-16);
				rom_circulo_addr = pixel_y[5:2] - lineaH1_Y_Inf[5:2];
				rom_circulo_col = pixel_x[8:2] - lineaV2_X_Der[8:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[5]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lineaH1_Y_Inf<=pixel_y) && (pixel_y <= lineaH2_Y_Sup) &&
									(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der-16);
				rom_equis_addr = pixel_y[5:2] - lineaH1_Y_Inf[5:2];
				rom_equis_col = pixel_x[5:2] - lineaV2_X_Der[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[5]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c7_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf-5) &&
									(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq-14);
				rom_circulo_addr = pixel_y[5:2] - lineaH2_Y_Inf[5:2];
				rom_circulo_col = pixel_x[8:2] - lim_bar_H_X_Izq[8:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[6]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf) &&
									(lim_bar_H_X_Izq<=pixel_x) && (pixel_x <= lineaV1_X_Izq-14);
				rom_equis_addr = pixel_y[5:2] - lineaH2_Y_Inf[5:2];
				rom_equis_col = pixel_x[5:2] - lim_bar_H_X_Izq[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[6]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c8_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf-5) &&
									(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq-14);
				rom_circulo_addr = pixel_y[5:2] - lineaH2_Y_Inf[5:2];
				rom_circulo_col = pixel_x[8:2] - lineaV1_X_Der[8:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[7]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf) &&
									(lineaV1_X_Der<=pixel_x) && (pixel_x <= lineaV2_X_Izq-14);
				rom_equis_addr = pixel_y[5:2] - lineaH2_Y_Inf[5:2];
				rom_equis_col = pixel_x[5:2] - lineaV1_X_Der[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[7]= cuadrante_on & rom_equis_bit;
			end
		endcase
			case(c9_in)
			2'b00: begin	
			end
			2'b01: begin	
				cuadrante_circ_on = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf-5) &&
									(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der-16);
				rom_circulo_addr = pixel_y[5:2] - lineaH2_Y_Inf[5:2];
				rom_circulo_col = pixel_x[7:2] - lineaV2_X_Der[7:2];
				rom_circulo_bit = rom_circulo_data[rom_circulo_col];
				circulo_mostrar[8]= cuadrante_circ_on & rom_circulo_bit;
			end
			2'b10: begin	
			end
			2'b11: begin	
				cuadrante_on = (lineaH2_Y_Inf<=pixel_y) && (pixel_y <= lim_bar_V_Y_Inf) &&
									(lineaV2_X_Der<=pixel_x) && (pixel_x <= lim_bar_H_X_Der-16);
				rom_equis_addr = pixel_y[5:2] - lineaH2_Y_Inf[5:2];
				rom_equis_col = pixel_x[5:2] - lineaV2_X_Der[5:2];
				rom_equis_bit = rom_equis_data[rom_equis_col];
				equis_mostrar[8]= cuadrante_on & rom_equis_bit;
			end
		endcase
	end
	always @ (*) begin
		if(~video_mostrar)
			salida_rgb = 3'b000; 
		else if (lineaV1_mostrar||lineaV2_mostrar||lineaH1_mostrar||lineaH2_mostrar)
			salida_rgb = lineaGato_rgb;
		else if (p1_mostrar || uno_mostrar)
			salida_rgb=3'b001;
		else if (p2_mostrar || dos_mostrar)
			salida_rgb=3'b100;
		else if (equis_mostrar[0] || equis_mostrar[1] || equis_mostrar[2] || 
					equis_mostrar[3] || equis_mostrar[4] || equis_mostrar[5] || 
					equis_mostrar[6] || equis_mostrar[7] || equis_mostrar[8])
			salida_rgb= 3'b100;
		else if (circulo_mostrar[0] || circulo_mostrar[1] || circulo_mostrar[2] || 
					circulo_mostrar[3] || circulo_mostrar[4] || circulo_mostrar[5] || 
					circulo_mostrar[6] || circulo_mostrar[7] || circulo_mostrar[8])
			salida_rgb= 3'b001;
		else if (cuadro_mostrar[0] || cuadro_mostrar[1] || cuadro_mostrar[2] || 
					cuadro_mostrar[3] || cuadro_mostrar[4] || cuadro_mostrar[5] || 
					cuadro_mostrar[6] || cuadro_mostrar[7] || cuadro_mostrar[8])
			salida_rgb= 3'b110;
		else
			salida_rgb = 3'b000; 
	end
endmodule
