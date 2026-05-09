`timescale 1ns / 1ps
module Image_viewer_top(
    input wire ClkPort, 
    output wire Hsync, Vsync,
    output wire [2:0] vgaRed,
    output wire [2:0] vgaGreen,
    output wire [2:1] vgaBlue,
    output wire MemOE, MemWR, MemClk, RamCS, RamUB, RamLB, RamAdv, RamCRE,
    output wire [26:1] MemAdr,
    inout wire [15:0] data,
    output wire An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
    output wire [1:0] Led,
    input wire btnC, btnR, btnL, btnU, btnD,
    output wire readImage,
    input wire test_i
);
    wire sys_clk, Reset;
    wire dft_sys_clk, dft_reset;
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
    assign sys_clk = ClkPort;
    assign MemClk = DIV_CLK[0];
    assign Reset = btnC;
    assign dft_sys_clk = test_i ? ClkPort : sys_clk;
    assign dft_reset = test_i ? btnC : Reset;

    reg [26:0] DIV_CLK;
    reg [22:0] address;
    reg [15:0] dataRegister [0:127];
    reg [22:0] imageRegister [0:3];    
    always @(posedge dft_sys_clk)
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
    wire writeData;

    always @(posedge dft_sys_clk or posedge dft_reset)  
    begin
        if (dft_reset)
            DIV_CLK <= 0;
        else
            DIV_CLK <= DIV_CLK + 1;
    end

    ee201_debouncer #(.N_dc(20)) ee201_debouncer_left 
        (.CLK(MemClk), .RESET(dft_reset), .PB(btnL), .DPB(), 
         .SCEN(BtnL_Pulse), .MCEN(), .CCEN());
    ee201_debouncer #(.N_dc(20)) ee201_debouncer_right 
        (.CLK(MemClk), .RESET(dft_reset), .PB(btnR), .DPB(), 
         .SCEN(BtnR_Pulse), .MCEN(), .CCEN());
    ee201_debouncer #(.N_dc(20)) ee201_debouncer_up 
        (.CLK(MemClk), .RESET(dft_reset), .PB(btnU), .DPB(), 
         .SCEN(BtnU_Pulse), .MCEN(), .CCEN());
    ee201_debouncer #(.N_dc(20)) ee201_debouncer_down 
        (.CLK(MemClk), .RESET(dft_reset), .PB(btnD), .DPB(), 
         .SCEN(BtnD_Pulse), .MCEN(), .CCEN());

    DisplayCtrl display (.Clk(DIV_CLK), .reset(dft_reset), .memoryData(dataRegister[readRow][15:0]),
        .An0(An0), .An1(An1), .An2(An2), .An3(An3),
        .Ca(Ca), .Cb(Cb), .Cc(Cc), .Cd(Cd), .Ce(Ce), .Cf(Cf), .Cg(Cg), .Dp(Dp)
    );

    MemoryCtrl memory(.Clk(MemClk), .Reset(dft_reset), .MemAdr(MemAdr), .MemOE(MemOE), .MemWR(MemWR),
        .RamCS(RamCS), .RamUB(RamUB), .RamLB(RamLB), .RamAdv(RamAdv), .RamCRE(RamCRE), .writeData(writeData),
        .AddressIn(address), .BtnU_Pulse(BtnU_Pulse), .BtnD_Pulse(BtnD_Pulse)
    );

    VGACtrl vga(.clk(DIV_CLK[1]), .reset(dft_reset), .vga_h_sync(Hsync),
        .vga_v_sync(Vsync), .inDisplayArea(inDisplayArea),
        .CounterX(CounterX), .CounterY(CounterY)
    );

    reg toggleByte;
    always @(posedge DIV_CLK[1] or posedge dft_reset)
    begin
        if(dft_reset)
        begin
            bitCounter <= 6'b0;
            toggleByte <= 1'b0;
            readAddress <= 7'b0;
        end
        else if(CounterY > 192 && CounterY < 288)
        begin
            if(CounterX == 10'b0)
            begin
                bitCounter <= 6'b0;
                toggleByte <= 1'b0;
            end
            else if(CounterX > 284 && bitCounter < 35)
            begin
                if(toggleByte == 1'b0)
                begin
                    {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][7:0];
                    toggleByte <= 1'b1;
                end
                else
                begin
                    {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][15:8];
                    toggleByte <= 1'b0;
                    bitCounter <= bitCounter + 1;
                    readAddress <= readAddress + 1;
                end
            end
            else
            begin
                {_vgaRed, _vgaGreen, _vgaBlue} <= 8'b0;
            end
        end
        else if (CounterY == 288)
            readAddress <= 7'b0;
    end

    always @(posedge MemClk or posedge dft_reset)
    begin
        if(dft_reset)
            readImage <= 2'b00;
        else if(BtnU_Pulse)
            readImage <= readImage + 1;
        else if(BtnD_Pulse)
            readImage <= readImage - 1;
        else
            address <= imageRegister[readImage][22:0];
    end

    always @(posedge MemClk or posedge dft_reset)
    begin
        if(dft_reset)
        begin
            writePointer <= 7'b0;
        end
        else    
            if(writeData == 1'b1)
            begin
                dataRegister[writePointer][15:0] <= {uByte, lByte};
                writePointer <= writePointer + 1;
            end
            else
                writePointer <= 7'b0;
    end

    always @(posedge MemClk or posedge dft_reset)
    begin
        if(dft_reset)
            readRow <= 7'b0;
        else if(BtnR_Pulse)
            readRow <= readRow + 1;
        else if(BtnL_Pulse)
            readRow <= readRow - 1;
    end
endmodule