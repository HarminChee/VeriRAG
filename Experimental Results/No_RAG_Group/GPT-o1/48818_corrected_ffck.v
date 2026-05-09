(1)_corrected_ffc.v

module LCD_Driver(
	input LCLK,  
	input RST_n,
	output reg HS,
	output reg VS,
	output DE,
	output reg [9:0] Column,
	output reg [9:0] Row,
	output reg SPENA,
	output reg SPDA_OUT,
	input SPDA_IN,
	output reg WrEn,
	output reg SPCK,
	input [7:0] Brightness,
	input [7:0] Contrast
);
	reg [9:0] Column_Counter;
	reg [9:0] Row_Counter;
	reg [9:0] Column_Reg;
	reg HS_dly;
	reg SPCK_tmp_dly;

	always @(posedge LCLK) begin
		if(VS & HS) begin
			Column <= Column_Reg;
		end
		else begin
			Column <= 10'd0;
		end
	end

	always @(posedge LCLK) begin
		if(Column_Counter < 10'd1) begin
			Column_Counter <= Column_Counter + 1'b1;
			Column_Reg <= 10'd0;
		    HS <= 1'b0;
		end
		else if(Column_Counter <=10'd56) begin
			Column_Counter <= Column_Counter + 1'b1;
			Column_Reg <= 10'd0;
		    HS <= 1'b1;
		end		
		else if(Column_Counter <=10'd70) begin
			Column_Counter <= Column_Counter + 1'b1;
			Column_Reg <= Column_Reg + 1'b1;
		    HS <= 1'b1;
		end
		else if(Column_Counter <10'd390) begin
			Column_Counter <= Column_Counter + 1'b1;
			Column_Reg <= Column_Reg + 1'b1;
		    HS <= 1'b1;
		end
		else if(Column_Counter <10'd408) begin            
			Column_Counter <= Column_Counter + 1'b1;
			Column_Reg <= 10'd334;
		    HS <= 1'b1;
		end
		else begin
			Column_Counter <= 10'd0;
		end
	end

	always @(posedge LCLK or negedge RST_n) begin
		if(!RST_n) begin
			HS_dly <= 1'b0;
			Row_Counter <= 10'd0;
			Row <= 10'd0;
			VS <= 1'b0;
		end
		else begin
			HS_dly <= HS;
			if((HS == 1'b1) && (HS_dly == 1'b0)) begin
				if(Row_Counter < 10'd1) begin
					Row_Counter <= Row_Counter + 1'b1;
					Row <= 10'd0;
					VS <= 1'b0;
				end
				else if(Row_Counter <= 10'd13) begin
					Row_Counter <= Row_Counter + 1'b1;
					Row <= 10'd0;
					VS <= 1'b1;
				end
				else if(Row_Counter < 10'd253) begin
					Row_Counter <= Row_Counter + 1'b1;
					Row <= Row + 1'b1;
					VS <= 1'b1;
				end
				else if(Row_Counter < 10'd263) begin
					Row_Counter <= Row_Counter + 1'b1;
					Row <= 10'd239;
					VS <= 1'b1;
				end
				else begin
					Row_Counter <= 10'd0;
					VS <= 1'b0;
				end
			end
		end
	end

	reg [7:0] SPCK_Counter;
	wire SPCK_tmp;
	always @(posedge LCLK) begin
		SPCK_Counter <= SPCK_Counter + 1'b1;
	end
	assign SPCK_tmp = SPCK_Counter[4];

	always @(posedge LCLK) begin
		SPCK <= (~SPCK_tmp) | SPENA;
	end

	reg SP_Counter [7:0];
	parameter WAKEUP = 16'b00000010_00000011;
	wire [15:0] Snd_Data1;
	wire [15:0] Snd_Data2;
	assign Snd_Data1 ={8'h26,{1'b0,Brightness[7:1]}};
	assign Snd_Data2 = {8'h22,{3'b0,Contrast[7:3]}};
	reg [16:0] SP_DATA;
	reg [15:0] Snd_Old1;
	reg [15:0] Snd_Old2;

	always @(posedge LCLK or negedge RST_n) begin
		if(!RST_n) begin
			SPCK_tmp_dly <= 1'b0;
		end
		else begin
			SPCK_tmp_dly <= SPCK_tmp;
		end
	end

	always @(posedge LCLK or negedge RST_n) begin
		if(!RST_n) begin
			SP_Counter <= 8'd0;
			SP_DATA <= WAKEUP;
			SPENA  <= 1'b1;
			Snd_Old1 <= {8'h26,8'd0};
			Snd_Old2 <= {8'h22,8'd0};
			WrEn <= 1'b1;
			SPDA_OUT <= 1'b0;
		end
		else begin
			if(SPCK_tmp == 1'b1 && (SPCK_tmp_dly == 1'b0)) begin
				if(SP_Counter < 8'd6) begin
					SP_Counter 	<= SP_Counter + 1'b1;
					SPDA_OUT 	<= SP_DATA[15];
					SP_DATA     <= {SP_DATA[14:0],1'b0};
					SPENA 		<= 1'b0;
					WrEn 		<= 1'b1;
				end	
				else if(SP_Counter == 8'd6) begin
					SP_Counter <= SP_Counter + 1'b1;
					SPENA <= 1'b0;
					SPDA_OUT <= SP_DATA[15];
					SP_DATA  <= {SP_DATA[14:0],1'b0};
					if(SP_DATA[15] == 1'b1) begin
						WrEn <= 1'b1;
					end
					else begin
						WrEn <= 1'b0;
					end
				end	
				else if(SP_Counter < 8'd16) begin
					SP_Counter <= SP_Counter + 1'b1;
					SPDA_OUT <= SP_DATA[15];
					SP_DATA  <= {SP_DATA[14:0],1'b0};
					SPENA <= 1'b0;
				end	
				else if(SP_Counter < 8'd32) begin
					SPENA <= 1'b1;
					SP_Counter <= SP_Counter + 1'b1;
				end
				else begin
					if(Snd_Data1 != Snd_Old1) begin
						Snd_Old1 <= Snd_Data1;
						SP_DATA <= Snd_Data1;
						SP_Counter <= 8'd0;
						WrEn <= 1'b1;
					end
					else if(Snd_Data2 != Snd_Old2) begin
						Snd_Old2 <= Snd_Data2;
						SP_DATA <= Snd_Data2;
						SP_Counter <= 8'd0;
						WrEn <= 1'b1;
					end
					else begin
						WrEn <= 1'b0;
					end
				end
			end
		end
	end
endmodule