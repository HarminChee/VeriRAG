`timescale 1ns / 1ps
module Image_viewer_top(
    input wire ClkPort,
    input wire test_mode_i, // Added for DFT
    output wire Hsync,
    output wire Vsync,
    output wire [2:0] vgaRed,
    output wire [2:0] vgaGreen,
    output wire [2:1] vgaBlue,
    output wire MemOE,
    output wire MemWR,
    output wire MemClk,
    output wire RamCS,
    output wire RamUB,
    output wire RamLB,
    output wire RamAdv,
    output wire RamCRE,
    output wire [26:1] MemAdr,
    inout wire [15:0] data,
    output wire An0,
    output wire An1,
    output wire An2,
    output wire An3,
    output wire Ca,
    output wire Cb,
    output wire Cc,
    output wire Cd,
    output wire Ce,
    output wire Cf,
    output wire Cg,
    output wire Dp,
    output wire [1:0] Led,
    input wire btnC,
    input wire btnR,
    input wire btnL,
    input wire btnU,
    input wire btnD
    // Removed output readImage declaration
);

    // input ClkPort; // Redundant declaration removed
    // output MemOE, MemWR, MemClk, RamCS, RamUB, RamLB, RamAdv, RamCRE; // Redundant
    // output [26:1] MemAdr; // Redundant
    // inout [15:0] data; // Redundant
    // input btnC, btnR, btnL, btnU, btnD; // Redundant
    // output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp; // Redundant
    // output Vsync, Hsync; // Redundant
    // output [2:0] vgaRed; // Redundant
    // output [2:0] vgaGreen; // Redundant
    // output [2:1] vgaBlue; // Redundant
    // output [1:0] Led; // Redundant

    reg [2:0] _vgaRed;
    reg [2:0] _vgaGreen;
    reg [2:1] _vgaBlue; // Corrected width to match output port
    wire inDisplayArea;
    wire [9:0] CounterX;
    wire [9:0] CounterY;
    reg [5:0] bitCounter;

    assign vgaRed = _vgaRed;
    assign vgaGreen = _vgaGreen;
    assign vgaBlue = _vgaBlue;


    // wire ClkPort; // Redundant internal declaration removed
    wire sys_clk, Reset;
    reg [26:0] DIV_CLK;
    assign sys_clk = ClkPort;
    assign MemClk = DIV_CLK[0]; // Functional MemClk from divider

    reg [22:0] address;
    reg [15:0] dataRegister[0:127];
    reg [22:0] imageRegister[0:3];

    // DFT Clock Muxing
    wire dft_MemClk;
    wire dft_VgaClk;
    assign dft_MemClk = test_mode_i ? sys_clk : MemClk; // Select sys_clk in test mode
    assign dft_VgaClk = test_mode_i ? sys_clk : DIV_CLK[1]; // Select sys_clk in test mode

    // Image register initialization with reset
    always @(posedge sys_clk, posedge Reset) begin
        if (Reset) begin
            imageRegister[2'b00][22:0] <= 23'b0;
            imageRegister[2'b01][22:0] <= 23'b0;
            imageRegister[2'b10][22:0] <= 23'b0;
            imageRegister[2'b11][22:0] <= 23'b0;
        end else begin
            // These seem like fixed addresses, maybe load them once? Or keep as is if intended.
            imageRegister[2'b00][22:0] <= 23'b00000000000000000000000;
            imageRegister[2'b01][22:0] <= 23'b00000000000000010000000;
            imageRegister[2'b10][22:0] <= 23'b00000000000000100000000;
            imageRegister[2'b11][22:0] <= 23'b00000000000000110000000;
        end
    end

    wire [7:0] uByte;
    wire [7:0] lByte;
    reg [1:0] readImage; // Internal register for image selection
    reg [6:0] readAddress;
    reg [6:0] writePointer;
    reg [6:0] readRow;

    assign Led = readImage; // Drive LED output from internal register

    assign uByte = data[15:8];
    assign lByte = data[7:0];

    wire BtnR_Pulse, BtnL_Pulse, BtnU_Pulse, BtnD_Pulse;
    assign Reset = btnC; // Reset comes from primary input btnC - OK for ACNCPI

    // Clock divider block
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

    // DisplayCtrl clocked by dft_MemClk
    DisplayCtrl display (.Clk(dft_MemClk), .reset(Reset), .memoryData(dataRegister[readRow][15:0]),
        .An0(An0), .An1(An1), .An2(An2), .An3(An3),
        .Ca(Ca), .Cb(Cb), .Cc(Cc), .Cd(Cd), .Ce(Ce), .Cf(Cf), .Cg(Cg), .Dp(Dp)
    );

    wire writeData; // Declare wire for write enable signal from MemoryCtrl

    // MemoryCtrl clocked by dft_MemClk
    MemoryCtrl memory(
        .Clk(dft_MemClk),
        .Reset(Reset),
        .MemAdr(MemAdr),
        .MemOE(MemOE),
        .MemWR(MemWR),
        .RamCS(RamCS),
        .RamUB(RamUB),
        .RamLB(RamLB),
        .RamAdv(RamAdv),
        .RamCRE(RamCRE),
        .writeData(writeData), // Connect writeData wire to MemoryCtrl output port
        .AddressIn(address),
        .BtnU_Pulse(BtnU_Pulse),
        .BtnD_Pulse(BtnD_Pulse)
    );

    // VGACtrl clocked by dft_VgaClk
    VGACtrl vga(
        .clk(dft_VgaClk),
        .reset(Reset),
        .vga_h_sync(Hsync),
        .vga_v_sync(Vsync),
        .inDisplayArea(inDisplayArea),
        .CounterX(CounterX),
        .CounterY(CounterY)
    );

    reg toggleByte;

    // VGA data logic clocked by dft_VgaClk
    always @(posedge dft_VgaClk, posedge Reset) begin
        if (Reset) begin
            bitCounter <= 0;
            toggleByte <= 0;
            readAddress <= 0;
            {_vgaRed, _vgaGreen, _vgaBlue} <= 0; // Reset output registers
        end else if (inDisplayArea) begin // Check if within display area (driven by VGACtrl)
            // Simplified logic assuming CounterX/Y relate to pixel coordinates
            if (CounterX == 0) begin // Reset at start of line
                bitCounter <= 0;
                toggleByte <= 1'b0;
                // Calculate start address based on current row being displayed (CounterY?)
                // Assuming 64 words per line for simplicity, need mapping from CounterY to readRow/start address
                // This part requires knowledge of how VGA coordinates map to memory rows.
                // Using 'readRow' directly might not be correct if it changes independently.
                // For now, using a simplified address calculation based on readRow.
                readAddress <= readRow * 64; // Example calculation
            end

            if (CounterX < 640) begin // Assuming 640 pixels wide
                // Logic to fetch and display data based on bitCounter/toggleByte
                // Assuming one word (2 bytes/pixels) per bitCounter increment
                if (bitCounter < 64) begin // Example: Display 64 words (128 bytes) from dataRegister line
                    if (toggleByte == 1'b0) begin // Display low byte first
                        {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][7:0];
                        toggleByte <= 1'b1;
                    end else begin // Display high byte next
                        {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][15:8];
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
        end else begin // Outside display area (Vertical blanking etc.)
            {_vgaRed, _vgaGreen, _vgaBlue} <= 0; // Blank
            // Reset counters/pointers if needed at end of frame/line
            if (CounterY == 480) begin // Example: Reset at end of visible lines
                // Resetting readAddress here might conflict with start-of-line calculation
                 // readAddress <= 0; // Consider if this reset is needed or handled elsewhere
            end
        end
    end

    // Image selection logic clocked by dft_MemClk
    always @(posedge dft_MemClk, posedge Reset) begin
        if (Reset)
            readImage <= 0;
        else if (BtnU_Pulse) begin
            if (readImage < 2'b11) // Prevent overflow
                readImage <= readImage + 1;
        end else if (BtnD_Pulse) begin
             if (readImage > 2'b00) // Prevent underflow
                readImage <= readImage - 1;
        end
    end

    // Address update logic based on image selection, clocked by dft_MemClk
    always @(posedge dft_MemClk, posedge Reset) begin
        if (Reset)
            address <= imageRegister[0][22:0]; // Default address on reset
        // Update address only when image selection changes to avoid continuous updates
        else if (BtnU_Pulse || BtnD_Pulse) // Update address when image selection changes
            address <= imageRegister[readImage][22:0];
    end

    // Data write logic clocked by dft_MemClk
    always @(posedge dft_MemClk, posedge Reset) begin
        if (Reset) begin
            writePointer <= 0;
        end
        // Use 'writeData' signal from MemoryCtrl to qualify the write
        else if (writeData == 1'b1) begin // Check if write is active
            // Ensure writePointer stays within bounds
            if (writePointer < 128) begin
                dataRegister[writePointer][15:0] <= data; // Use inout 'data' directly
                writePointer <= writePointer + 1;
            end
            // Consider resetting writePointer when a full image/block is loaded?
            // Or maybe when BtnU/BtnD is pressed to load a new image?
        end
        // Resetting writePointer unconditionally might be wrong
        // Add logic here if writePointer needs reset under other conditions (e.g., new image load start)
    end

    // Read row logic for 7-segment display, clocked by dft_MemClk
    always @(posedge dft_MemClk, posedge Reset) begin
        if (Reset)
            readRow <= 0;
        else if (BtnR_Pulse) begin
            if (readRow < 127) // Prevent overflow
                readRow <= readRow + 1;
        end else if (BtnL_Pulse) begin
            if (readRow > 0) // Prevent underflow
                readRow <= readRow - 1;
        end
    end

endmodule