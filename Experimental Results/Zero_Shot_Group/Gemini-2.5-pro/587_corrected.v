`timescale 1ns / 1ps
module Image_viewer_top(
    ClkPort,
    Hsync, Vsync, vgaRed, vgaGreen, vgaBlue,
    MemOE, MemWR, MemClk, RamCS, RamUB, RamLB, RamAdv, RamCRE,
    MemAdr, data,
    An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp, Led,
    btnC, btnR, btnL, btnU, btnD,
    readImage
);

    input ClkPort;
    output MemOE, MemWR, MemClk, RamCS, RamUB, RamLB, RamAdv, RamCRE;
    output [26:1] MemAdr;
    inout [15:0] data;
    input btnC, btnR, btnL, btnU, btnD;
    output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
    output Vsync, Hsync;
    output [2:0] vgaRed;
    output [2:0] vgaGreen;
    output [1:0] vgaBlue; // Corrected width
    output [1:0] Led;
    output [1:0] readImage; // Corrected type and width

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

    wire sys_clk, Reset; // Removed ClkPort redeclaration
    reg [26:0] DIV_CLK;
    assign sys_clk = ClkPort;
    assign MemClk = DIV_CLK[0];

    reg [22:0] address;
    reg [15:0] dataRegister[0:127];
    reg [22:0] imageRegister[0:3];

    // Initialize imageRegister on reset
    always @(posedge sys_clk, posedge Reset) begin
        if (Reset) begin
            imageRegister[2'b00] <= 23'b00000000000000000000000;
            imageRegister[2'b01] <= 23'b00000000000000010000000;
            imageRegister[2'b10] <= 23'b00000000000000100000000;
            imageRegister[2'b11] <= 23'b00000000000000110000000;
        end
        // Removed continuous assignment from here
    end

    wire [7:0] uByte;
    wire [7:0] lByte;
    // Removed redundant reg [1:0] readImage; declaration
    reg [6:0] readAddress;
    reg [6:0] writePointer;
    reg [6:0] readRow;

    // Assuming data is driven externally when MemOE is low and MemWR is high
    // These assignments are combinational based on the current value of 'data'
    assign uByte = data[15:8];
    assign lByte = data[7:0];

    wire BtnR_Pulse, BtnL_Pulse, BtnU_Pulse, BtnD_Pulse;
    assign Reset = btnC;

    // Clock Divider
    always @(posedge sys_clk, posedge Reset) begin : CLOCK_DIVIDER
        if (Reset)
            DIV_CLK <= 0;
        else
            DIV_CLK <= DIV_CLK + 1;
    end

    // Debouncers
    // Assuming ee201_debouncer module definition exists elsewhere
    ee201_debouncer #(.N_dc(20)) ee201_debouncer_left (
        .CLK(MemClk), .RESET(Reset), .PB(btnL), .DPB(),
        .SCEN(BtnL_Pulse), .MCEN(), .CCEN()
    );
    ee201_debouncer #(.N_dc(20)) ee201_debouncer_right (
        .CLK(MemClk), .RESET(Reset), .PB(btnR), .DPB(),
        .SCEN(BtnR_Pulse), .MCEN(), .CCEN()
    );
    ee201_debouncer #(.N_dc(20)) ee201_debouncer_up (
        .CLK(MemClk), .RESET(Reset), .PB(btnU), .DPB(),
        .SCEN(BtnU_Pulse), .MCEN(), .CCEN()
    );
    ee201_debouncer #(.N_dc(20)) ee201_debouncer_down (
        .CLK(MemClk), .RESET(Reset), .PB(btnD), .DPB(),
        .SCEN(BtnD_Pulse), .MCEN(), .CCEN()
    );

    // Assuming DisplayCtrl module definition exists elsewhere
    DisplayCtrl display (
        .Clk(sys_clk), // Changed clock source, verify if correct
        .reset(Reset),
        .memoryData(dataRegister[readRow]), // Corrected memory access
        .An0(An0), .An1(An1), .An2(An2), .An3(An3),
        .Ca(Ca), .Cb(Cb), .Cc(Cc), .Cd(Cd), .Ce(Ce), .Cf(Cf), .Cg(Cg), .Dp(Dp)
    );

    wire writeData; // Declare missing wire

    // Assuming MemoryCtrl module definition exists elsewhere
    MemoryCtrl memory (
        .Clk(MemClk), .Reset(Reset), .MemAdr(MemAdr), .MemOE(MemOE), .MemWR(MemWR),
        .RamCS(RamCS), .RamUB(RamUB), .RamLB(RamLB), .RamAdv(RamAdv), .RamCRE(RamCRE),
        .writeData(writeData), // Connect declared wire
        .AddressIn(address),
        .BtnU_Pulse(BtnU_Pulse), .BtnD_Pulse(BtnD_Pulse)
    );

    // Assuming VGACtrl module definition exists elsewhere
    VGACtrl vga (
        .clk(DIV_CLK[1]), .reset(Reset), .vga_h_sync(Hsync),
        .vga_v_sync(Vsync), .inDisplayArea(inDisplayArea),
        .CounterX(CounterX), .CounterY(CounterY)
    );

    reg toggleByte;
    reg [1:0] readImage_reg; // Internal register for readImage logic
    assign readImage = readImage_reg; // Assign internal reg to output

    // VGA Pixel Generation Logic
    always @(posedge DIV_CLK[1], posedge Reset) begin
        if (Reset) begin
            _vgaRed <= 3'b0;
            _vgaGreen <= 3'b0;
            _vgaBlue <= 2'b0;
            bitCounter <= 0;
            toggleByte <= 0;
            readAddress <= 0;
        end else begin
            if (inDisplayArea) begin // Check if within display area
                 // Simplified logic example, assuming 640x480 display area mapping
                 // Needs mapping from CounterX/Y to dataRegister index and pixel data
                 // The original logic seems complex and possibly incorrect mapping.
                 // Placeholder for corrected logic:
                 // Map CounterX, CounterY to an address in dataRegister
                 // Fetch pixel data (e.g., 8-bit color {R,G,B})
                 // Example: Fetching based on readAddress (like original, but corrected syntax)
                 if (CounterY >= 192 && CounterY < 288) begin // Example vertical slice
                     if (CounterX >= 284 && CounterX < (284 + 35 * 2)) begin // Example horizontal slice (assuming 35 words = 70 pixels)
                         // Calculate index based on CounterX relative position
                         // This part needs careful implementation based on image format
                         // Using original toggling logic for demonstration, but likely needs rework

                         // Simplified: Read sequentially using readAddress for demonstration
                         if (toggleByte == 1'b0) begin
                             {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][7:0]; // Corrected memory access
                             toggleByte <= 1'b1;
                         end else begin
                             {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][15:8]; // Corrected memory access
                             toggleByte <= 1'b0;
                             if (readAddress < 127) // Prevent overflow
                                readAddress <= readAddress + 1;
                         end
                         // The bitCounter logic from original seems misplaced here.
                         // Resetting readAddress based on CounterY might be needed at line start/end.
                     end else begin
                         {_vgaRed, _vgaGreen, _vgaBlue} <= 8'b0; // Outside horizontal slice
                     end
                 end else begin
                     {_vgaRed, _vgaGreen, _vgaBlue} <= 8'b0; // Outside vertical slice
                 end

                 // Reset readAddress at the start of a relevant display section if needed
                 // Example: Reset at the start of the displayed image area
                 if (CounterY == 192 && CounterX == 284) begin
                     readAddress <= 0;
                     toggleByte <= 0;
                 end

            end else begin // Blanking intervals
                _vgaRed <= 3'b0;
                _vgaGreen <= 3'b0;
                _vgaBlue <= 2'b0;
            end
        end
    end


    // Image Selection Logic
    always @(posedge MemClk, posedge Reset) begin
        if (Reset) begin
            readImage_reg <= 0;
            address <= imageRegister[0]; // Initialize address
        end else begin
            if (BtnU_Pulse) begin
                if (readImage_reg < 3) // Prevent wrap-around
                    readImage_reg <= readImage_reg + 1;
            end else if (BtnD_Pulse) begin
                if (readImage_reg > 0) // Prevent wrap-around
                    readImage_reg <= readImage_reg - 1;
            end
            // Update address based on the potentially changed readImage_reg
            address <= imageRegister[readImage_reg]; // Corrected memory access
        end
    end


    // Memory Write Logic (into dataRegister buffer)
    always @(posedge MemClk, posedge Reset) begin
        if (Reset) begin
            writePointer <= 0;
        end else begin
            if (writeData == 1'b1) begin // Check Memory Controller write signal
                if (writePointer < 128) begin // Prevent overflow
                    dataRegister[writePointer] <= {uByte, lByte}; // Corrected memory access and byte order
                    writePointer <= writePointer + 1;
                end
            end else begin
                 // Hold writePointer or reset? Original resets aggressively.
                 // Let's reset it similar to original logic, assuming it corresponds to end of a burst/transfer
                 writePointer <= 0;
            end
        end
    end


    // Row Selection Logic (for DisplayCtrl)
    always @(posedge MemClk, posedge Reset) begin
        if (Reset) begin
            readRow <= 0;
        end else begin
            if (BtnR_Pulse) begin
                if (readRow < 127) // Prevent overflow
                    readRow <= readRow + 1;
            end else if (BtnL_Pulse) begin
                 if (readRow > 0) // Prevent underflow
                    readRow <= readRow - 1;
            end
        end
    end

endmodule