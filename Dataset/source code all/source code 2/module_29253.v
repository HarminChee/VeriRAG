`timescale 1ns / 1ps
`timescale 1ns / 1ps
module OledInit(
    CLK,
    EN,
    RST,
    CS,
    DC,
    FIN,
    RES,
    SCLK,
    SDO,
    VBAT,
    VDD
    );
    input CLK;
    input EN;
    input RST;
    output CS;
    output DC;
    output FIN;
    output RES;
    output SCLK;
    output SDO;
    output VBAT;
    output VDD;
	wire DC, RES, VBAT, VDD, FIN;
	wire CS, SCLK, SDO;
	reg [103:0] current_state = "Idle";
	reg [103:0] after_state = "Idle";
	reg temp_dc = 1'b0;
	reg temp_res = 1'b1;
	reg temp_vbat = 1'b1;
	reg temp_vdd = 1'b1;
	reg temp_fin = 1'b0;
	wire [11:0] temp_delay_ms;
	reg temp_delay_en = 1'b0;
	wire temp_delay_fin;
	reg temp_spi_en = 1'b0;
	reg [7:0] temp_spi_data = 8'h00;
	wire temp_spi_fin;
	SpiCtrl_OLED SPI_COMP_init(
			.CLK(CLK),
			.RST(RST),
			.SPI_EN(temp_spi_en),
			.SPI_DATA(temp_spi_data),
			.CS(CS),
			.SDO(SDO),
			.SCLK(SCLK),
			.SPI_FIN(temp_spi_fin)
	);
	Delay DELAY_COMP(
			.CLK(CLK),
			.RST(RST),
			.DELAY_MS(temp_delay_ms),
			.DELAY_EN(temp_delay_en),
			.DELAY_FIN(temp_delay_fin)
	);
	assign DC = temp_dc;
	assign RES = temp_res;
	assign VBAT = temp_vbat;
	assign VDD = temp_vdd;
	assign FIN = temp_fin;
	assign temp_delay_ms = (after_state == "DispContrast1") ? 12'h064 : 12'h001;
	always @(posedge CLK) begin
			if(RST == 1'b1) begin
					current_state <= "Idle";
					temp_res <= 1'b0;
			end
			else begin
					temp_res <= 1'b1;
					case(current_state)
							"Idle" : begin
									if(EN == 1'b1) begin
										temp_dc <= 1'b0;
										current_state <= "VddOn";
									end
							end
							"VddOn" : begin
								temp_vdd <= 1'b0;
								current_state <= "Wait1";
							end
							"Wait1" : begin
								after_state <= "DispOff";
								current_state <= "Transition3";
							end
							"DispOff" : begin
								temp_spi_data <= 8'hAE; 
								after_state <= "ResetOn";
								current_state <= "Transition1";
							end
							"ResetOn" : begin
								temp_res <= 1'b0;
								current_state <= "Wait2";
							end
							"Wait2" : begin
								after_state <= "ResetOff";
								current_state <= "Transition3";
							end
							"ResetOff" : begin
								temp_res <= 1'b1;
								after_state <= "ChargePump1";
								current_state <= "Transition3";
							end
							"ChargePump1" : begin
								temp_spi_data <= 8'h8D; 
								after_state <= "ChargePump2";
								current_state <= "Transition1";
							end
							"ChargePump2" : begin
								temp_spi_data <= 8'h14; 
								after_state <= "PreCharge1";
								current_state <= "Transition1";
							end
							"PreCharge1" : begin
								temp_spi_data <= 8'hD9; 
								after_state <= "PreCharge2";
								current_state <= "Transition1";
							end
							"PreCharge2" : begin
								temp_spi_data <= 8'hF1; 
								after_state <= "VbatOn";
								current_state <= "Transition1";
							end
							"VbatOn" : begin
								temp_vbat <= 1'b0;
								current_state <= "Wait3";
							end
							"Wait3" : begin
								after_state <= "DispContrast1";
								current_state <= "Transition3";
							end
							"DispContrast1" : begin
								temp_spi_data <= 8'h81; 
								after_state <= "DispContrast2";
								current_state <= "Transition1";
							end
							"DispContrast2" : begin
								temp_spi_data <= 8'h0F; 
								after_state <= "InvertDisp1";
								current_state <= "Transition1";
							end
							"InvertDisp1" : begin
								temp_spi_data <= 8'hA1; 
								after_state <= "InvertDisp2";
								current_state <= "Transition1";
							end
							"InvertDisp2" : begin
								temp_spi_data <= 8'hC8; 
								after_state <= "ComConfig1";
								current_state <= "Transition1";
							end
							"ComConfig1" : begin
								temp_spi_data <= 8'hDA; 
								after_state <= "ComConfig2";
								current_state <= "Transition1";
							end
							"ComConfig2" : begin
								temp_spi_data <= 8'h20; 
								after_state <= "DispOn";
								current_state <= "Transition1";
							end
							"DispOn" : begin
								temp_spi_data <= 8'hAF; 
								after_state <= "Done";
								current_state <= "Transition1";
							end
							"FullDisp" : begin
								temp_spi_data <= 8'hA5; 
								after_state <= "Done";
								current_state <= "Transition1";
							end
							"Done" : begin
								if(EN == 1'b0) begin
									temp_fin <= 1'b0;
									current_state <= "Idle";
								end
								else begin
									temp_fin <= 1'b1;
								end
							end
							"Transition1" : begin
								temp_spi_en <= 1'b1;
								current_state <= "Transition2";
							end
							"Transition2" : begin
								if(temp_spi_fin == 1'b1) begin
									current_state <= "Transition5";
								end
							end
							"Transition3" : begin
								temp_delay_en <= 1'b1;
								current_state <= "Transition4";
							end
							"Transition4" : begin
								if(temp_delay_fin == 1'b1) begin
									current_state <= "Transition5";
								end
							end
							"Transition5" : begin
								temp_spi_en <= 1'b0;
								temp_delay_en <= 1'b0;
								current_state <= after_state;
							end
							default : current_state <= "Idle";
					endcase
			end
	end
endmodule
