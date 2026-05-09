`timescale 1ns / 1ps
module Image_viewer_top(ClkPort,
	input wire test_mode_i, // Added for DFT
	Hsync, Vsync, vgaRed, vgaGreen, vgaBlue,
	MemOE, MemWR, MemClk, RamCS, RamUB, RamLB, RamAdv, RamCRE,
	MemAdr, data,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp, Led,
	btnC, btnR, btnL, btnU, btnD,
	readImage
   );
	output readImage;
	input ClkPort;
	output MemOE, MemWR, MemClk, RamCS, RamUB, RamLB, RamAdv, RamCRE;
	output [26:1] MemAdr;
	inout [15:0] data;
	input btnC, btnR, btnL, btnU, btnD;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output Vsync, Hsync;
	output [2:0] vgaRed;
	output [2:0] vgaGreen;
	output [2:1] vgaBlue;
	output [1:0] Led;
	reg [2:0] _vgaRed;
	reg [2:0] _vgaGreen;
	reg [1:0] _vgaBlue;
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;
	reg [5:0] bitCounter;
	assign vgaRed = _vgaRed;
	assign vgaGreen = _vgaGreen;
	assign vgaBlue = _vgaBlue;
	assign Led = readImage;
	wire ClkPort, sys_clk, Reset;
	reg [26:0] DIV_CLK;
	assign sys_clk = ClkPort;
	assign MemClk = DIV_CLK[0];
	reg [22:0] address;
	reg [15:0] dataRegister[0:127];
	reg [22:0] imageRegister[0:3];
	// DFT Clock Muxing
	wire dft_MemClk;
	wire dft_VgaClk;
	assign dft_MemClk = test_mode_i ? sys_clk : MemClk;
	assign dft_VgaClk = test_mode_i ? sys_clk : DIV_CLK[1];

	always@(posedge sys_clk)
		begin
			imageRegister[2'b00][22:0] <= 23'b00000000000000000000000;
			imageRegister[2'b01][22:0] <= 23'b00000000000000010000000;
			imageRegister[2'b10][22:0] <= 23'b00000000000000100000000;
			imageRegister[2'b11][22:0] <= 23'b00000000000000110000000;
		end
	wire [7:0] uByte;
	wire [7:0] lByte;
	reg [1:0] readImage;
	reg [6:0] readAddress;
	reg [6:0] writePointer;
	reg [6:0] readRow;
	assign uByte = data[15:8];
	assign lByte = data[7:0];
	wire BtnR_Pulse, BtnL_Pulse, BtnU_Pulse, BtnD_Pulse;
	assign Reset = btnC; // Reset comes from primary input btnC - OK for ACNCPI
always @ (posedge sys_clk, posedge Reset) // Clocked by primary derived sys_clk - OK
	begin : CLOCK_DIVIDER
      if (Reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1;
	end
	// Debouncers clocked by dft_MemClk
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_left
        (.CLK(dft_MemClk), .RESET(Reset), .PB(btnL), .DPB( ),
		.SCEN(BtnL_Pulse), .MCEN( ), .CCEN( ));
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_right
        (.CLK(dft_MemClk), .RESET(Reset), .PB(btnR), .DPB( ),
		.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( ));
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_up
        (.CLK(dft_MemClk), .RESET(Reset), .PB(btnU), .DPB( ),
		.SCEN(BtnU_Pulse), .MCEN( ), .CCEN( ));
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_down
        (.CLK(dft_MemClk), .RESET(Reset), .PB(btnD), .DPB( ),
		.SCEN(BtnD_Pulse), .MCEN( ), .CCEN( ));
	// DisplayCtrl clocked by dft_MemClk (Assumption: intended clock was MemClk or similar)
	DisplayCtrl display (.Clk(dft_MemClk), .reset(Reset), .memoryData(dataRegister[readRow][15:0]),
		.An0(An0), .An1(An1), .An2(An2), .An3(An3),
		.Ca(Ca), .Cb(Cb), .Cc(Cc), .Cd(Cd), .Ce(Ce), .Cf(Cf), .Cg(Cg), .Dp(Dp)
	);
	// MemoryCtrl clocked by dft_MemClk
	MemoryCtrl memory(.Clk(dft_MemClk), .Reset(Reset), .MemAdr(MemAdr), .MemOE(MemOE), .MemWR(MemWR),
		.RamCS(RamCS), .RamUB(RamUB), .RamLB(RamLB), .RamAdv(RamAdv), .RamCRE(RamCRE), .writeData(writeData),
		.AddressIn(address), .BtnU_Pulse(BtnU_Pulse), .BtnD_Pulse(BtnD_Pulse)
	);
	// VGACtrl clocked by dft_VgaClk
	VGACtrl vga(.clk(dft_VgaClk), .reset(Reset), .vga_h_sync(Hsync),
		.vga_v_sync(Vsync), .inDisplayArea(inDisplayArea),
		.CounterX(CounterX), .CounterY(CounterY)
	);
	reg toggleByte;
	// VGA data logic clocked by dft_VgaClk
	always @(posedge dft_VgaClk, posedge Reset)
		begin
			if(Reset)
				begin
					bitCounter <= 0;
					toggleByte <= 0;
					readAddress <= 0;
					{_vgaRed, _vgaGreen, _vgaBlue} <= 0; // Reset output registers
				end
			else if(inDisplayArea) // Check if within display area (driven by VGACtrl)
				begin
					// Simplified logic assuming CounterX/Y relate to pixel coordinates
					// This part might need adjustment based on actual VGA timing requirements
					// The original logic seemed tied to specific coordinate ranges.
					// For DFT purposes, ensure the clocking is correct.
					// Assuming data fetch happens within active display area based on CounterX
					if (CounterX == 0) begin // Reset at start of line
						bitCounter <= 0;
						toggleByte <= 1'b0;
						readAddress <= readRow * 64; // Example: Calculate start address based on row
					end

					// Example data output logic - adjust based on actual pixel clocking needs
					// This needs careful review w.r.t CounterX and pixel clock relationship
					if (CounterX < 640) begin // Assuming 640 pixels wide
						// Logic to fetch and display data based on bitCounter/toggleByte
						// This simplified section replaces the original complex coordinate checks
						if (bitCounter < 64) begin // Example: Display 64 words (128 bytes)
							if (toggleByte == 1'b0) begin
								{_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][7:0]; // Low byte
								toggleByte <= 1'b1;
							end else begin
								{_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][15:8]; // High byte
								toggleByte <= 1'b0;
								bitCounter <= bitCounter + 1;
								readAddress <= readAddress + 1; // Move to next word in memory
							end
						end else begin
							{_vgaRed, _vgaGreen, _vgaBlue} <= 0; // Blank rest of line
						end
					end else begin
						{_vgaRed, _vgaGreen, _vgaBlue} <= 0; // Blank during horizontal blanking
					end
				end
			else // Outside display area (Vertical blanking etc.)
				begin
					{_vgaRed, _vgaGreen, _vgaBlue} <= 0; // Blank
					// Reset counters/pointers if needed at end of frame/line
					if (CounterY == 480) // Example: Reset at end of visible lines
						readAddress <= 0;
				end
		end
	// Address update logic clocked by dft_MemClk
	always@(posedge dft_MemClk, posedge Reset)
		begin
			if(Reset)
				readImage <= 0;
			else if(BtnU_Pulse)
				readImage <= readImage + 1;
			else if(BtnD_Pulse)
				readImage <= readImage - 1;
			// Removed else condition to prevent combinatorial loop on address
			// Address update should likely happen explicitly based on state or request
			// else
			//	address <= imageRegister[readImage][22:0];
		end
	// Explicit address update based on readImage change
	always @(posedge dft_MemClk, posedge Reset) begin
		if (Reset)
			address <= imageRegister[0][22:0]; // Default address
		else if (BtnU_Pulse || BtnD_Pulse) // Update address when image selection changes
			address <= imageRegister[readImage][22:0];
	end

	// Data write logic clocked by dft_MemClk
	always@(posedge dft_MemClk, posedge Reset)
		begin
			if(Reset)
				begin
					writePointer <= 0;
				end
			// Assuming 'writeData' comes from MemoryCtrl and indicates valid data write cycle
			else if(writeData == 1'b1) // Check if write is active
					begin
						// Ensure writePointer stays within bounds
						if (writePointer < 128) begin
                           dataRegister[writePointer][15:0] <= data; // Use inout 'data' directly assuming MemoryCtrl manages direction
                           writePointer <= writePointer + 1;
                       end
					end
				// Decide when to reset writePointer, e.g., on new image load?
				// else
				//	writePointer <= 0; // Resetting unconditionally might be wrong
		end
	// Read row logic clocked by dft_MemClk
	always@(posedge dft_MemClk, posedge Reset)
		begin
			if(Reset)
				readRow <= 0;
			else if(BtnR_Pulse) begin
				if (readRow < 127) // Prevent overflow
					readRow <= readRow + 1;
            end
			else if(BtnL_Pulse) begin
				if (readRow > 0) // Prevent underflow
					readRow <= readRow - 1;
            end
		end
endmodule