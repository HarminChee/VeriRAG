module Image_viewer_top(
    input test_i,
    input ClkPort, 
    output readImage,
    output MemOE, 
    output MemWR, 
    output MemClk, 
    output RamCS, 
    output RamUB, 
    output RamLB, 
    output RamAdv, 
    output RamCRE,
    output [26:1] MemAdr,
    inout [15:0] data,
    input btnC, btnR, btnL, btnU, btnD,
    output An0, An1, An2, An3, 
    output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp, 
    output Vsync, Hsync,
    output [2:0] vgaRed,
    output [2:0] vgaGreen,
    output [2:1] vgaBlue,
    output [1:0] Led
   );
   
wire Reset;
wire sys_clk;
assign sys_clk = ClkPort;
reg [26:0] DIV_CLK;
assign Reset = btnC;

//------------------------------------------------------------------
// Create an internal clock divider
//------------------------------------------------------------------
always @ (posedge sys_clk or posedge Reset)  
begin
   if (Reset)
      DIV_CLK <= 0;
   else
      DIV_CLK <= DIV_CLK + 1;
end

//------------------------------------------------------------------
// Generate separate test-friendly clocks
//------------------------------------------------------------------
wire dft_mem_clk = test_i ? ClkPort : DIV_CLK[0];
wire dft_vga_clk = test_i ? ClkPort : DIV_CLK[1];

//------------------------------------------------------------------
// Map original outputs and signals
//------------------------------------------------------------------
assign MemClk = DIV_CLK[0];
reg [1:0] readImage_reg;
assign readImage = readImage_reg;
assign Led = readImage_reg;

//------------------------------------------------------------------
// Memory Data, Address and Control
//------------------------------------------------------------------
wire [7:0] uByte;
wire [7:0] lByte;
assign uByte = data[15:8];
assign lByte = data[7:0];

output wire [15:0] writeData;
assign writeData = 16'hzzzz; // Default tri-state or placeholder

reg [6:0] writePointer;
reg [15:0] dataRegister[0:127];
reg [22:0] imageRegister[0:3];
reg [22:0] address;

//------------------------------------------------------------------
// VGA signals
//------------------------------------------------------------------
wire inDisplayArea;
wire [9:0] CounterX;
wire [9:0] CounterY;
reg [2:0] _vgaRed;
reg [2:0] _vgaGreen;
reg [1:0] _vgaBlue;
assign vgaRed = _vgaRed;
assign vgaGreen = _vgaGreen;
assign vgaBlue = _vgaBlue;

//------------------------------------------------------------------
// Some row read logic
//------------------------------------------------------------------
reg [6:0] readRow;
reg [6:0] readAddress;
reg toggleByte;
reg [5:0] bitCounter;

//------------------------------------------------------------------
// Assigning memory data bus
//------------------------------------------------------------------
assign data = 16'hzzzz;

//------------------------------------------------------------------
// External Modules Instantiation
//------------------------------------------------------------------
ee201_debouncer #(.N_dc(20)) ee201_debouncer_left 
(
   .CLK(dft_mem_clk), 
   .RESET(Reset), 
   .PB(btnL), 
   .DPB(), 
   .SCEN(BtnL_Pulse), 
   .MCEN(), 
   .CCEN()
);

ee201_debouncer #(.N_dc(20)) ee201_debouncer_right 
(
   .CLK(dft_mem_clk), 
   .RESET(Reset), 
   .PB(btnR), 
   .DPB(), 
   .SCEN(BtnR_Pulse), 
   .MCEN(), 
   .CCEN()
);

ee201_debouncer #(.N_dc(20)) ee201_debouncer_up 
(
   .CLK(dft_mem_clk), 
   .RESET(Reset), 
   .PB(btnU), 
   .DPB(), 
   .SCEN(BtnU_Pulse), 
   .MCEN(), 
   .CCEN()
);

ee201_debouncer #(.N_dc(20)) ee201_debouncer_down 
(
   .CLK(dft_mem_clk), 
   .RESET(Reset), 
   .PB(btnD), 
   .DPB(), 
   .SCEN(BtnD_Pulse), 
   .MCEN(), 
   .CCEN()
);

DisplayCtrl display
(
   .Clk(DIV_CLK), 
   .reset(Reset), 
   .memoryData(dataRegister[readRow][15:0]),
   .An0(An0), 
   .An1(An1), 
   .An2(An2), 
   .An3(An3),
   .Ca(Ca), 
   .Cb(Cb), 
   .Cc(Cc), 
   .Cd(Cd), 
   .Ce(Ce), 
   .Cf(Cf), 
   .Cg(Cg), 
   .Dp(Dp)
);

MemoryCtrl memory
(
   .Clk(dft_mem_clk), 
   .Reset(Reset), 
   .MemAdr(MemAdr), 
   .MemOE(MemOE), 
   .MemWR(MemWR),
   .RamCS(RamCS), 
   .RamUB(RamUB), 
   .RamLB(RamLB), 
   .RamAdv(RamAdv), 
   .RamCRE(RamCRE), 
   .writeData(writeData),
   .AddressIn(address), 
   .BtnU_Pulse(BtnU_Pulse), 
   .BtnD_Pulse(BtnD_Pulse)
);

VGACtrl vga
(
   .clk(dft_vga_clk), 
   .reset(Reset), 
   .vga_h_sync(Hsync),
   .vga_v_sync(Vsync), 
   .inDisplayArea(inDisplayArea),
   .CounterX(CounterX), 
   .CounterY(CounterY)
);

//------------------------------------------------------------------
// Pre-load image base addresses
//------------------------------------------------------------------
always @(posedge sys_clk)
begin
   imageRegister[2'b00] <= 23'b00000000000000000000000;
   imageRegister[2'b01] <= 23'b00000000000000010000000;
   imageRegister[2'b10] <= 23'b00000000000000100000000;
   imageRegister[2'b11] <= 23'b00000000000000110000000;
end

//------------------------------------------------------------------
// VGA control for reading
//------------------------------------------------------------------
always @(posedge dft_vga_clk or posedge Reset)
begin
   if(Reset)
   begin
      bitCounter <= 0;
      toggleByte <= 0;
      readAddress <= 0;
   end
   else if(CounterY > 192 && CounterY < 288)
   begin
      if(CounterX == 0)
      begin
         bitCounter <= 0;
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
         {_vgaRed, _vgaGreen, _vgaBlue} <= 0;
      end
   end
   else if (CounterY == 288)
      readAddress <= 0;
end

//------------------------------------------------------------------
// Read image selection
//------------------------------------------------------------------
always @(posedge dft_mem_clk or posedge Reset)
begin
   if(Reset)
      readImage_reg <= 0;
   else if(BtnU_Pulse)
      readImage_reg <= readImage_reg + 1;
   else if(BtnD_Pulse)
      readImage_reg <= readImage_reg - 1;
   else
      address <= imageRegister[readImage_reg];
end

//------------------------------------------------------------------
// Write pointer logic
//------------------------------------------------------------------
always @(posedge dft_mem_clk or posedge Reset)
begin
   if(Reset)
      writePointer <= 0;
   else if(writeData == 1'b1)
   begin
      dataRegister[writePointer] <= {lByte, uByte};
      writePointer <= writePointer + 1;
   end
   else
      writePointer <= 0;
end

//------------------------------------------------------------------
// Read row logic
//------------------------------------------------------------------
always @(posedge dft_mem_clk or posedge Reset)
begin
   if(Reset)
      readRow <= 0;
   else if(BtnR_Pulse)
      readRow <= readRow + 1;
   else if(BtnL_Pulse)
      readRow <= readRow - 1;
end

endmodule