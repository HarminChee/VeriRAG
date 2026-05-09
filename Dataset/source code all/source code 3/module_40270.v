module vendingmachine(clock, enable, reset, coin, mode, quarter_counter, dime_counter, nickel_counter, dimenickelLEDon, dimeLEDon, nickelLEDon, vendLEDon);
	input clock;			
	input enable;			
	input reset;			
	input[1:0] coin;		
	input mode;				
	output reg [7:0] quarter_counter, dime_counter, nickel_counter;	            
	output reg dimeLEDon, nickelLEDon, vendLEDon;							
	output dimenickelLEDon;
	reg [7:0] count;         		
	reg [27:0] LEDcounter;					
	reg nickelLED, nickelLED2, nickelLED3, nickelLED4, dimeLED, dimeLED2, vendLED, LEDon;	
	reg countreset;
	reg nickelinc, dimeinc, quarterinc;		
	reg dispense;
	reg venddec, nickeldec, nickeldec2, nickeldec3, nickeldec4, dimedec, dimedec2;	
	always @(posedge clock or negedge reset) begin
		if(!reset)
			nickel_counter <= 8'd0;
		else if(nickelinc)
			nickel_counter <= nickel_counter + 8'd1;
		else if(nickeldec)
			nickel_counter <= nickel_counter - 8'd1;
		else if(nickeldec2)
			nickel_counter <= nickel_counter - 8'd2;
		else if(nickeldec3)
			nickel_counter <= nickel_counter - 8'd3;
		else if(nickeldec4)
			nickel_counter <= nickel_counter - 8'd4;
		else
			nickel_counter <= nickel_counter;
	end
	always @(posedge clock or negedge reset) begin
		if(!reset)			dime_counter <= 8'd0;
		else if(dimeinc)
			dime_counter <= dime_counter + 8'd1;
		else if(dimedec)
			dime_counter <= dime_counter - 8'd1;
		else if(dimedec2)
			dime_counter <= dime_counter - 8'd2;
		else
			dime_counter <= dime_counter;
	end
	always @(posedge clock or negedge reset) begin
		if(!reset)
			quarter_counter <= 8'd0;
		else if(quarterinc)
			quarter_counter <= quarter_counter + 8'd1;
		else
			quarter_counter <= quarter_counter;
	end
	always @(posedge clock or negedge reset) begin
		if(!reset)
			count <= 8'd0;
		else if(countreset)
			count <= 8'd0;
		else if(nickelinc && mode)
			count <= count + 8'd5;
		else if(dimeinc && mode)
			count <= count + 8'd10;
		else if(quarterinc && mode)
			count <= count + 8'd25;
		else if(venddec) begin
			if(dimedec && nickeldec)
				count <= count - 8'd75;
			else if(dimedec && nickeldec2)
				count <= count - 8'd80;
			else if(nickeldec)
				count <= count - 8'd65;
			else if(nickeldec2)
				count <= count - 8'd70;
			else if(dimedec)
				count <= count - 8'd70;
			else if(nickeldec3)
				count <= count - 8'd75;
			else if(dimedec2)
				count <= count - 8'd80;
			else if(nickeldec4)
				count <= count - 8'd80;
			else begin
				count <= count - 8'd60;
			end
		end
		else
			count <= count;
	end
	always @(posedge clock) begin
		if(enable) begin
			case(coin)
				2'b01: begin
					nickelinc <= 1'b1;
				end
				2'b10: begin
					dimeinc <= 1'b1;
				end
				2'b11: begin
					quarterinc <= 1'b1;
				end
				default: begin
					nickelinc <= 1'b0;
					dimeinc <= 1'b0;
					quarterinc <= 1'b0;
				end
			endcase
		end
		else begin
			nickelinc <= 1'b0;
			dimeinc <= 1'b0;
			quarterinc <= 1'b0;
		end
		if(count > 60) begin
			dispense <= 1;
		end
		else begin
			dispense <= 0;
		end
	end
	always @(dispense) begin
		if(count == 60) begin
			venddec <= 1'b1;
			dimedec <= 1'b0;
			dimedec2 <= 1'b0;
			nickeldec <= 1'b0;
			nickeldec2 <= 1'b0;
			nickeldec3 <= 1'b0;
			nickeldec4 <= 1'b0;
			dispense <= 0;
		end
		else if(count > 60) begin
			venddec <= 1'b1;
			dispense <= 0;
			if((count == 65) && (nickel_counter > 0))
				nickeldec <= 1'b1;
			if(count == 70) begin
				if(dime_counter > 0)
					dimedec <= 1'b1;
				else if(nickel_counter > 1)
					nickeldec2 <= 1'b1;
				else if(nickel_counter == 1)
					nickeldec <= 1'b1;
			end
			if(count == 75) begin
				if(dime_counter > 0) begin
					dimedec <= 1'b1;
					if(nickel_counter > 0)
						nickeldec <= 1'b1;
				end
				else if(nickel_counter > 2)
					nickeldec3 <= 1'b1;
				else if(nickel_counter > 1)
					nickeldec2 <= 1'b1;
				else if(nickel_counter == 1)
					nickeldec <= 1'b1;
			end
			if(count == 80) begin
				if(dime_counter > 1)
					dimedec2 <= 1'b1;
				else if(dime_counter > 0) begin
					dimedec <= 1'b1;
					if(nickel_counter > 1)
						nickeldec2 <= 1'b1;
					else if(nickel_counter > 0)
						nickeldec <= 1'b1;
				end
				else if(nickel_counter > 1)
					nickeldec4 <= 1'b1;
				else if(nickel_counter > 1)
					nickeldec2 <= 1'b1;
				else if(nickel_counter == 1)
					nickeldec <= 1'b1;
			end
		end
		else begin
			dimedec <= 1'b0;
			dimedec2 <= 1'b0;
			nickeldec <= 1'b0;
			nickeldec2 <= 1'b0;
			nickeldec3 <= 1'b0;
			nickeldec4 <= 1'b0;
			venddec <= 1'b0;
		end
	end
	always @(posedge clock) begin
		if(nickeldec || nickeldec2 || nickeldec3 || nickeldec4 || dimedec || dimedec2 || venddec) begin
			if(nickeldec || nickeldec2 || nickeldec3 || nickeldec4) begin
				if(nickeldec)
					nickelLED <= 1;
				else if(nickeldec2)
					nickelLED2 <= 1;
				else if(nickeldec3)
					nickelLED3 <= 1;
				else if(nickeldec4)
					nickelLED4 <= 1;
			end
			if(dimedec)
				dimeLED <= 1;
			if(dimedec2)
				dimeLED2 <= 1;
			if(venddec)
				vendLED <= 1;
			countreset <= 1;
		end
		else if(LEDon) begin
			nickelLED <= nickelLED;
			nickelLED2 <= nickelLED2;
			nickelLED3 <= nickelLED3;
			nickelLED4 <= nickelLED4;
			dimeLED <= dimeLED;
			vendLED <= vendLED;
			LEDcounter <= LEDcounter + 28'd1;
		end
		else begin
			nickelLED <= 0;
			nickelLED2 <= 0;
			nickelLED3 <= 0;
			nickelLED4 <= 0;
			dimeLED <= 0;
			dimeLED2 <= 0;
			vendLED <= 0;
			LEDcounter = 28'd0;
			countreset <= 0;
		end
	end
	always @(nickelLED or nickelLED2 or nickelLED3 or nickelLED4 or dimeLED or dimeLED2 or vendLED or LEDcounter or LEDon) begin
		LEDon = 1;
		if(dimeLED2) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 150000000) begin
					dimeLEDon = 0;
					LEDon = 0;
				end
			end
		end
		else if(dimeLED && nickelLED2) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 100000000) begin
					dimeLEDon = 0;
					nickelLEDon = 1;
					if(LEDcounter >= 200000000) begin
						nickelLEDon = 0;
						LEDon = 0;
					end
				end
			end
		end
		else if(dimeLED && nickelLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 100000000) begin
					dimeLEDon = 0;
					nickelLEDon = 1;
					if(LEDcounter >= 150000000) begin
						nickelLEDon = 0;
						LEDon = 0;
					end
				end
			end
		end
		else if(dimeLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 100000000) begin
					dimeLEDon = 0;
					LEDon = 0;
				end
			end
		end
		else if(nickelLED4) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter >= 250000000) begin
					nickelLEDon = 0;
					LEDon = 0;
				end
			end
		end
		else if(nickelLED3) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter >= 200000000) begin
					nickelLEDon = 0;
					LEDon = 0;
				end
			end
		end
		else if(nickelLED2) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter == 150000000) begin
					nickelLEDon	= 0;
					LEDon = 0;
				end
			end
		end
		else if(nickelLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter >= 100000000) begin
					nickelLEDon = 0;
					LEDon = 0;
				end
			end
		end
		else if(vendLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				LEDon = 0;
			end
		end
		else begin
			nickelLEDon = 0;
			dimeLEDon = 0;
			vendLEDon = 0;
			LEDon = 0;
		end
	end
	assign dimenickelLEDon = (dime_counter == 0) && (nickel_counter == 0);
endmodule
