1_corrected_ffc.v
module LCD_Driver(
	input LCLK,
	input RST_n,
	output reg HS,
	output reg VS,
	output DE, // Assuming DE is combinational or driven elsewhere, not shown here.
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

	// Column logic clocked by LCLK
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			Column <= 10'd0;
		end else begin
			if(VS & HS) begin // This condition depends on VS and HS, which are also changing
				Column <= Column_Reg;
			end
			else begin
				Column <= 10'd0;
			end
		end
	end

	// Column counter and HS logic clocked by LCLK
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			Column_Counter <= 10'd0;
			Column_Reg <= 10'd0;
			HS <= 1'b0;
		end else begin
			if(Column_Counter <10'd1) begin
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
				// HS should probably go low here or be handled by the <1 case
				HS <= 1'b0; // Assuming HS goes low when counter resets
			end
		end
	end

	// Generate enable signal for HS posedge
	reg HS_d;
	wire hs_posedge_en;

	always @(posedge LCLK or negedge RST_n) begin
	    if (!RST_n) begin
	        HS_d <= 1'b0;
	    end else begin
	        HS_d <= HS;
	    end
	end
	assign hs_posedge_en = ~HS_d & HS;

	// Row logic clocked by LCLK with HS posedge enable
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			Row_Counter <= 10'd0;
			Row <= 10'd0;
			VS <= 1'b0;
		end else if (hs_posedge_en) begin // Enabled by HS posedge
			if( Row_Counter < 10'd1) begin
				Row_Counter <= Row_Counter + 1'b1;
				Row <= 10'd0;
				VS <= 1'b0;
			end
			else if( Row_Counter <= 10'd13) begin
				Row_Counter <= Row_Counter + 1'b1;
				Row <= 10'd0;
				VS <= 1'b1;
			end
			else if( Row_Counter < 10'd253) begin
				Row_Counter <= Row_Counter + 1'b1;
				Row <= Row + 1'b1;
				VS <= 1'b1;
			end
			else if( Row_Counter < 10'd263) begin
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

	// SPCK generation logic
	reg [7:0] SPCK_Counter;
	wire SPCK_tmp;

	always @(posedge LCLK or negedge RST_n) begin
	    if (!RST_n) begin
	        SPCK_Counter <= 8'd0;
	    end else begin
		    SPCK_Counter <= SPCK_Counter + 1'b1;
		end
	end
	assign SPCK_tmp = SPCK_Counter[4];

	// Generate enable signal for SPCK_tmp posedge
	reg SPCK_tmp_d;
	wire spck_tmp_posedge_en;

	always @(posedge LCLK or negedge RST_n) begin
	    if (!RST_n) begin
	        SPCK_tmp_d <= 1'b0;
	    end else begin
	        SPCK_tmp_d <= SPCK_tmp;
	    end
	end
	assign spck_tmp_posedge_en = ~SPCK_tmp_d & SPCK_tmp;

	// SPI control logic
	reg [7:0] SP_Counter;
	parameter
		WAKEUP = 16'b00000010_00000011;
	wire [15:0] Snd_Data1;
	wire [15:0] Snd_Data2;
	assign Snd_Data1 ={8'h26,{1'b0,Brightness[7:1]}};
	assign Snd_Data2 = {8'h22,{3'b0,Contrast[7:3]}};
	reg [16:0] SP_DATA; // Increased size for shift
	reg [15:0] Snd_Old1;
	reg [15:0] Snd_Old2;

	// SPCK output logic (combinational part depends on SPENA)
	// The sequential part driving SPCK_tmp is above.
	// Let's make SPCK itself a register clocked by LCLK if needed, or keep it combinational.
	// Original: always @(posedge LCLK) SPCK <= (~SPCK_tmp) | SPENA;
	// Let's keep it clocked by LCLK for consistency.
	always @(posedge LCLK or negedge RST_n) begin
	    if (!RST_n) begin
	        SPCK <= 1'b1; // Assuming default high state due to SPENA likely high at reset
	    end else begin
	        SPCK <= (~SPCK_tmp) | SPENA;
	    end
	end

	// SPI state machine clocked by LCLK with SPCK_tmp posedge enable
	always @(posedge LCLK or negedge RST_n) begin
		if(~RST_n) begin
			SP_Counter <= 8'd0;
			SP_DATA <= {1'b0, WAKEUP}; // Adjust for 17 bits if needed, or ensure WAKEUP fits target
			SPENA  <= 1'b1;
			Snd_Old1 <= {8'h26,8'd0};
			Snd_Old2 <= {8'h22,8'd0};
			WrEn <= 1'b1;
			SPDA_OUT <= 1'b0; // Reset output register
		end
		else if (spck_tmp_posedge_en) begin // Enabled by SPCK_tmp posedge
			// Note: SP_DATA is 17 bits, WAKEUP is 16 bits. Assuming MSB is command/data flag?
			// Original logic shifted SP_DATA[15:0]. Let's assume SP_DATA[16] is unused or handled implicitly.
			// Using SP_DATA[15] for output as per original logic.
			if(SP_Counter < 8'd6) begin
				SP_Counter 	<= SP_Counter + 1'b1;
				SPDA_OUT 	<= SP_DATA[15];
				SP_DATA     <= {SP_DATA[14:0],1'b0}; // Shift 16 bits
				SPENA 		<= 1'b0;
				WrEn <= 1'b1; // WrEn seems active during transmission
			end
			else if(SP_Counter == 8'd6) begin
				SP_Counter <= SP_Counter + 1'b1;
				SPENA <= 1'b0;
				SPDA_OUT 	<= SP_DATA[15];
				SP_DATA     <= {SP_DATA[14:0],1'b0};
				if(SP_DATA[15] == 1'b1) begin // Check bit before shifting? Check bit being shifted out.
					WrEn <= 1'b1; // WrEn depends on the last data bit? Seems odd. Assuming original intent.
				end
				else begin
					WrEn <= 1'b0;
				end
			end
			else if(SP_Counter < 8'd16) begin // Transmitting bits 7 to 15
				SP_Counter <= SP_Counter + 1'b1;
				SPDA_OUT 	<= SP_DATA[15];
				SP_DATA     <= {SP_DATA[14:0],1'b0};
				SPENA <= 1'b0;
				// WrEn state seems held from previous state based on original logic
			end
			else if(SP_Counter < 8'd32)begin // Idle/wait phase?
				SPENA <= 1'b1; // Deactivate SPI?
				SP_Counter <= SP_Counter + 1'b1;
				// WrEn state held?
                // SPDA_OUT state held?
			end
			else begin // Check if new data needs to be sent
				SPENA <= 1'b1; // Keep SPI inactive until new data loaded
				if(Snd_Data1 != Snd_Old1) begin
				    Snd_Old1 <= Snd_Data1;
					SP_DATA <= {1'b0, Snd_Data1}; // Load new data (assuming 17 bits)
					SP_Counter <= 8'd0; // Start new transmission
					WrEn <= 1'b1; // Activate Write Enable for new command
					SPENA <= 1'b1; // Keep inactive until first bit cycle
				end
				else if(Snd_Data2 != Snd_Old2) begin
				    Snd_Old2 <= Snd_Data2;
					SP_DATA <= {1'b0, Snd_Data2}; // Load new data
					SP_Counter <= 8'd0; // Start new transmission
					WrEn <= 1'b1; // Activate Write Enable
					SPENA <= 1'b1;
				end
				else begin
					// No new data, keep WrEn low?
					WrEn <= 1'b0;
                    SPENA <= 1'b1;
                    // SP_Counter remains > 32, effectively idle
				end
			end
		end
        // Add else case for registers if they should hold value when not enabled
        // else begin
            // SP_Counter <= SP_Counter; // Hold value (implicit)
            // SP_DATA <= SP_DATA;       // Hold value (implicit)
            // SPENA <= SPENA;           // Hold value (implicit)
            // Snd_Old1 <= Snd_Old1;     // Hold value (implicit)
            // Snd_Old2 <= Snd_Old2;     // Hold value (implicit)
            // WrEn <= WrEn;             // Hold value (implicit)
            // SPDA_OUT <= SPDA_OUT;     // Hold value (implicit)
        // end
	end

    // Assuming DE is driven based on HS/VS or other logic, not shown/affected by FFCKNP
    assign DE = (HS & VS); // Example assignment, actual logic might differ

endmodule