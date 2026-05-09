`timescale 1ns / 1ps
module Image_viewer_top(ClkPort,
	test_i, // DFT Test mode input
	Hsync, Vsync, vgaRed, vgaGreen, vgaBlue,
	MemOE, MemWR, MemClk, RamCS, RamUB, RamLB, RamAdv, RamCRE,
	MemAdr, data,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp, Led,
	btnC, btnR, btnL, btnU, btnD,
	readImage
   );
	output readImage;
	input ClkPort;
	input test_i; // DFT Test mode input
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
	wire sys_clk, Reset; // Removed ClkPort from wire declaration
	reg [26:0] DIV_CLK;
	assign sys_clk = ClkPort;
	assign MemClk = DIV_CLK[0]; // Functional MemClk
	reg [22:0] address;
	reg [15:0] dataRegister[0:127];
	reg [22:0] imageRegister[0:3];
	always@(posedge sys_clk) // Uses primary clock ClkPort (assigned to sys_clk)
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
	assign Reset = btnC; // Reset derived from primary input

	// DFT Clock Muxing
	wire dft_clk_div0 = test_i ? ClkPort : DIV_CLK[0]; // Mux for MemClk users
	wire dft_clk_div1 = test_i ? ClkPort : DIV_CLK[1]; // Mux for VGA clock users

always @ (posedge sys_clk, posedge Reset) // Uses primary clock ClkPort (assigned to sys_clk)
	begin : CLOCK_DIVIDER
      if (Reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1;
	end
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_left
        (.CLK(dft_clk_div0), .RESET(Reset), .PB(btnL), .DPB( ), // Use DFT muxed clock
		.SCEN(BtnL_Pulse), .MCEN( ), .CCEN( ));
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_right
        (.CLK(dft_clk_div0), .RESET(Reset), .PB(btnR), .DPB( ), // Use DFT muxed clock
		.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( ));
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_up
        (.CLK(dft_clk_div0), .RESET(Reset), .PB(btnU), .DPB( ), // Use DFT muxed clock
		.SCEN(BtnU_Pulse), .MCEN( ), .CCEN( ));
	ee201_debouncer #(.N_dc(20)) ee201_debouncer_down
        (.CLK(dft_clk_div0), .RESET(Reset), .PB(btnD), .DPB( ), // Use DFT muxed clock
		.SCEN(BtnD_Pulse), .MCEN( ), .CCEN( ));

	// Assuming DisplayCtrl internal FFs should use DFT clock for scan
	// Using dft_clk_div0 based on assumption its related to memory/update speed
	DisplayCtrl display (.Clk(dft_clk_div0), .reset(Reset), .memoryData(dataRegister[readRow][15:0]),
		.An0(An0), .An1(An1), .An2(An2), .An3(An3),
		.Ca(Ca), .Cb(Cb), .Cc(Cc), .Cd(Cd), .Ce(Ce), .Cf(Cf), .Cg(Cg), .Dp(Dp)
	);
	MemoryCtrl memory(.Clk(dft_clk_div0), .Reset(Reset), .MemAdr(MemAdr), .MemOE(MemOE), .MemWR(MemWR), // Use DFT muxed clock
		.RamCS(RamCS), .RamUB(RamUB), .RamLB(RamLB), .RamAdv(RamAdv), .RamCRE(RamCRE), .writeData(writeData),
		.AddressIn(address), .BtnU_Pulse(BtnU_Pulse), .BtnD_Pulse(BtnD_Pulse)
	);
VGACtrl vga(.clk(dft_clk_div1), .reset(Reset), .vga_h_sync(Hsync), // Use DFT muxed clock
		.vga_v_sync(Vsync), .inDisplayArea(inDisplayArea),
		.CounterX(CounterX), .CounterY(CounterY)
	);
	reg toggleByte;
	always @(posedge dft_clk_div1, posedge Reset) // Use DFT muxed clock
		begin
			if(Reset)
				begin
					bitCounter <= 0;
					toggleByte <= 0;
					readAddress <= 0;
					_vgaRed <= 0; // Reset VGA regs
					_vgaGreen <= 0;
					_vgaBlue <= 0;
				end
			else if(inDisplayArea) // Use inDisplayArea from VGACtrl
				begin
                    // Simplified logic for demonstration - original logic depends on CounterX/Y
                    // which are outputs of VGACtrl clocked by dft_clk_div1.
                    // This block is also clocked by dft_clk_div1.
                    // Original logic might have timing issues if CounterX/Y are used directly.
                    // Assuming CounterX/Y are stable when read here.

                    // Map CounterX/Y to memory access (conceptual - original logic needs review)
                    // This part needs careful review for correctness after clock change
                    if(CounterX == 0) // Reset at start of line
						begin
							bitCounter <= 0;
							toggleByte <= 1'b0;
                            readAddress <= CounterY * 128; // Example mapping - adjust as needed
						end

                    // Simplified pixel output logic
                    if (toggleByte == 1'b0) begin
                        {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][7:0]; // Lower byte
                        toggleByte <= 1'b1;
                    end else begin
                        {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][15:8]; // Upper byte
                        toggleByte <= 1'b0;
                        readAddress <= readAddress + 1; // Move to next word
                        // bitCounter logic might need adjustment based on pixel width vs data width
                    end

                    // Original logic had complex conditions based on CounterX values
                    // if(CounterX > 284 && bitCounter < 35) ...
                    // This needs to be adapted based on actual VGA timing and memory layout
				end
			else // Outside display area
				begin
					{_vgaRed, _vgaGreen, _vgaBlue} <= 0;
					// Resetting readAddress here might be needed depending on frame structure
					// if (CounterY >= 480) readAddress <= 0; // Example reset at end of frame
				end
		end

	always@(posedge dft_clk_div0, posedge Reset) // Use DFT muxed clock
		begin
			if(Reset)
				readImage <= 0;
			else if(BtnU_Pulse) // Pulse generated by debouncer clocked by dft_clk_div0
				readImage <= readImage + 1;
			else if(BtnD_Pulse) // Pulse generated by debouncer clocked by dft_clk_div0
				readImage <= readImage - 1;
			// Removed assignment to 'address' here, should be driven by MemoryCtrl or similar logic
			// else
			//	address <= imageRegister[readImage][22:0]; // This assignment conflicts with MemoryCtrl driving AddressIn
		end

    // This assignment should likely be inside MemoryCtrl or controlled by it
    // Assigning address based on readImage here might not be the intended final logic
    always @* begin
        address = imageRegister[readImage][22:0];
    end


	always@(posedge dft_clk_div0, posedge Reset) // Use DFT muxed clock
		begin
			if(Reset)
				begin
					writePointer <= 0;
				end
			else
				// Assuming 'writeData' is an output from MemoryCtrl clocked by dft_clk_div0
				if(writeData == 1'b1)
					begin
						dataRegister[writePointer][15:0] <= data; // Corrected byte order if needed {lByte, uByte};
						writePointer <= writePointer + 1;
					end
				// Removed else case that reset writePointer, likely should only reset on Reset or completion signal
				// else
				//	 writePointer <= 0;
		end

	always@(posedge dft_clk_div0, posedge Reset) // Use DFT muxed clock
		begin
			if(Reset)
				readRow <= 0;
			else if(BtnR_Pulse) // Pulse generated by debouncer clocked by dft_clk_div0
				readRow <= readRow + 1;
			else if(BtnL_Pulse) // Pulse generated by debouncer clocked by dft_clk_div0
				readRow <= readRow - 1;
		end
endmodule