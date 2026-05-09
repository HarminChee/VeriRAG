module LCD_Driver(
	input LCLK,
	input RST_n,
	input test_i, // Added test mode input
	output reg HS,
	output reg VS,
	output DE, // Note: DE is declared but never assigned in the original code.
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
	reg HS_prev; // Register to detect HS rising edge

	// Synchronous logic for Column, clocked by LCLK with synchronous reset
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			Column <= 10'd0;
		end else begin
			if (VS & HS) begin // Logic depends on HS and VS, which are registered outputs
				Column <= Column_Reg;
			end else begin
				Column <= 10'd0;
			end
		end
	end

	// Synchronous logic for Column counters and HS signal, clocked by LCLK with synchronous reset
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			Column_Counter <= 10'd0;
			Column_Reg <= 10'd0;
			HS <= 1'b0; // Reset HS to inactive
		end else begin
			if (Column_Counter < 10'd1) begin
				Column_Counter <= Column_Counter + 1'b1;
				Column_Reg <= 10'd0;
				HS <= 1'b0;
			end else if (Column_Counter <= 10'd56) begin
				Column_Counter <= Column_Counter + 1'b1;
				Column_Reg <= 10'd0;
				HS <= 1'b1;
			end else if (Column_Counter <= 10'd70) begin
				Column_Counter <= Column_Counter + 1'b1;
				Column_Reg <= Column_Reg + 1'b1;
				HS <= 1'b1;
			end else if (Column_Counter < 10'd390) begin
				Column_Counter <= Column_Counter + 1'b1;
				Column_Reg <= Column_Reg + 1'b1;
				HS <= 1'b1;
			end else if (Column_Counter < 10'd408) begin
				Column_Counter <= Column_Counter + 1'b1;
				Column_Reg <= 10'd334;
				HS <= 1'b1;
			end else begin
				Column_Counter <= 10'd0;
				// HS state depends on the next cycle's Column_Counter value (0), so HS becomes 0
			end
		end
	end

	// Register HS to detect rising edge synchronously with LCLK
	always @(posedge LCLK or negedge RST_n) begin
	   if (!RST_n) begin
	       HS_prev <= 1'b0;
	   end else begin
	       HS_prev <= HS;
	   end
	end

	// Synchronous logic for Row counters and VS signal, clocked by LCLK with synchronous reset
	// Uses rising edge of HS (HS && !HS_prev) as enable condition
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			Row_Counter <= 10'd0;
			Row <= 10'd0;
			VS <= 1'b0; // Reset VS to inactive
		end else if (HS && !HS_prev) begin // Trigger on rising edge of HS
			if (Row_Counter < 10'd1) begin
				Row_Counter <= Row_Counter + 1'b1;
				Row <= 10'd0;
				VS <= 1'b0;
			end else if (Row_Counter <= 10'd13) begin
				Row_Counter <= Row_Counter + 1'b1;
				Row <= 10'd0;
				VS <= 1'b1;
			end else if (Row_Counter < 10'd253) begin
				Row_Counter <= Row_Counter + 1'b1;
				Row <= Row + 1'b1;
				VS <= 1'b1;
			end else if (Row_Counter < 10'd263) begin
				Row_Counter <= Row_Counter + 1'b1;
				Row <= 10'd239;
				VS <= 1'b1;
			end else begin
				Row_Counter <= 10'd0;
				VS <= 1'b0;
			end
		end
		// Note: If HS is high for multiple LCLK cycles, this logic only triggers on the first cycle.
	end

	reg [7:0] SPCK_Counter;
	wire SPCK_tmp;

	// Synchronous logic for SPCK_Counter, clocked by LCLK with synchronous reset
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			SPCK_Counter <= 8'd0;
		end else begin
			SPCK_Counter <= SPCK_Counter + 1'b1;
		end
	end

	assign SPCK_tmp = SPCK_Counter[4]; // Internal clock source derived from FF

	reg [7:0] SP_Counter;
	parameter
		WAKEUP = 16'b00000010_00000011;
	wire [15:0] Snd_Data1;
	wire [15:0] Snd_Data2;
	assign Snd_Data1 = {8'h26, {1'b0, Brightness[7:1]}};
	assign Snd_Data2 = {8'h22, {3'b0, Contrast[7:3]}};
	reg [16:0] SP_DATA; // Increased size to hold shifted data
	reg [15:0] Snd_Old1;
	reg [15:0] Snd_Old2;

	// Synchronous logic for SPCK generation, clocked by LCLK with synchronous reset
	always @(posedge LCLK or negedge RST_n) begin
		if (!RST_n) begin
			SPCK <= 1'b1; // Reset based on SPENA reset state (1)
		end else begin
			SPCK <= (~SPCK_tmp) | SPENA;
		end
	end

	// DFT clock selection for the SPI logic
	wire dft_SPCK_clk;
	assign dft_SPCK_clk = test_i ? LCLK : SPCK_tmp; // Use LCLK in test mode

	// SPI Logic: Clocked by DFT-muxed clock (dft_SPCK_clk) with asynchronous reset
	always @ (posedge dft_SPCK_clk or negedge RST_n) begin
		if (~RST_n) begin
			SP_Counter <= 8'd0;
			SP_DATA <= {WAKEUP, 1'b0}; // Initialize SP_DATA (17 bits)
			SPENA <= 1'b1;
			Snd_Old1 <= {8'h26, 8'd0};
			Snd_Old2 <= {8'h22, 8'd0};
			WrEn <= 1'b1;
			SPDA_OUT <= 1'b0; // Define reset state for SPDA_OUT
		end else begin
			// Note: SP_DATA is 17 bits to handle the shift {SP_DATA[14:0],1'b0} correctly.
			// SPDA_OUT gets the MSB which is SP_DATA[16] before the shift or SP_DATA[15] after the shift.
			// The original code used SP_DATA[15] which implies the value *before* the shift. Let's keep that interpretation.
			if (SP_Counter < 8'd6) begin
				SP_Counter <= SP_Counter + 1'b1;
				SPDA_OUT <= SP_DATA[16]; // Output MSB before shift
				SP_DATA <= {SP_DATA[15:0], 1'b0}; // Shift left
				SPENA <= 1'b0;
				WrEn <= 1'b1;
			end else if (SP_Counter == 8'd6) begin
				SP_Counter <= SP_Counter + 1'b1;
				SPENA <= 1'b0;
				SPDA_OUT <= SP_DATA[16]; // Output MSB before shift
				SP_DATA <= {SP_DATA[15:0], 1'b0}; // Shift left
				if (SP_DATA[16] == 1'b1) begin // Check MSB before shift
					WrEn <= 1'b1;
				end else begin
					WrEn <= 1'b0;
				end
			end else if (SP_Counter < 8'd16) begin
				SP_Counter <= SP_Counter + 1'b1;
				SPDA_OUT <= SP_DATA[16]; // Output MSB before shift
				SP_DATA <= {SP_DATA[15:0], 1'b0}; // Shift left
				SPENA <= 1'b0;
			end else if (SP_Counter < 8'd32) begin // Idle cycles?
				SPENA <= 1'b1; // Deactivate SPI chip select?
				SP_Counter <= SP_Counter + 1'b1;
				// SPDA_OUT is not assigned here, retains previous value
			end else begin // Load next data
				if (Snd_Data1 != Snd_Old1) begin
					Snd_Old1 <= Snd_Data1;
					SP_DATA <= {Snd_Data1, 1'b0}; // Load new data (17 bits)
					SP_Counter <= 8'd0;
					WrEn <= 1'b1;
				end else if (Snd_Data2 != Snd_Old2) begin
					Snd_Old2 <= Snd_Data2;
					SP_DATA <= {Snd_Data2, 1'b0}; // Load new data (17 bits)
					SP_Counter <= 8'd0;
					WrEn <= 1'b1;
				end else begin
					WrEn <= 1'b0; // No new data to send
                    // Keep SP_Counter >= 32, SPENA=1
				end
			end
		end
	end

endmodule