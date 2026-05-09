(1)_corrected_ffc.v

----------------------------------BEGIN CODE----------------------------------
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

   wire Reset;
   wire sys_clk;
   reg [26:0] DIV_CLK;
   // Directly assign sys_clk from primary input
   assign sys_clk = ClkPort;
   // Ensure MemClk comes directly from primary input (no internally generated clock)
   assign MemClk = sys_clk;

   reg [22:0] address;
   reg [15:0] dataRegister[0:127];
   reg [22:0] imageRegister[0:3];   
   always@(posedge sys_clk) begin
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
   assign Reset = btnC;

   // Clock divider still generated, but not used as a direct clock
   always @ (posedge sys_clk or posedge Reset) begin
      if (Reset)
         DIV_CLK <= 0;
      else
         DIV_CLK <= DIV_CLK + 1;
   end

   // Debouncers now use sys_clk (MemClk is driven by sys_clk)
   ee201_debouncer #(.N_dc(20)) ee201_debouncer_left 
   (
      .CLK(MemClk),
      .RESET(Reset),
      .PB(btnL),
      .DPB(),
      .SCEN(BtnL_Pulse),
      .MCEN(),
      .CCEN()
   );

   ee201_debouncer #(.N_dc(20)) ee201_debouncer_right 
   (
      .CLK(MemClk),
      .RESET(Reset),
      .PB(btnR),
      .DPB(),
      .SCEN(BtnR_Pulse),
      .MCEN(),
      .CCEN()
   );

   ee201_debouncer #(.N_dc(20)) ee201_debouncer_up 
   (
      .CLK(MemClk),
      .RESET(Reset),
      .PB(btnU),
      .DPB(),
      .SCEN(BtnU_Pulse),
      .MCEN(),
      .CCEN()
   );

   ee201_debouncer #(.N_dc(20)) ee201_debouncer_down 
   (
      .CLK(MemClk),
      .RESET(Reset),
      .PB(btnD),
      .DPB(),
      .SCEN(BtnD_Pulse),
      .MCEN(),
      .CCEN()
   );

   // DisplayCtrl uses sys_clk instead of derived clock
   DisplayCtrl display (
      .Clk(sys_clk),
      .reset(Reset),
      .memoryData(dataRegister[readRow][15:0]),
      .An0(An0), .An1(An1), .An2(An2), .An3(An3),
      .Ca(Ca), .Cb(Cb), .Cc(Cc), .Cd(Cd), .Ce(Ce), .Cf(Cf), .Cg(Cg), .Dp(Dp)
   );

   // MemoryCtrl uses sys_clk
   MemoryCtrl memory(
      .Clk(MemClk),
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

   // VGACtrl now uses sys_clk; internal enable from DIV_CLK if needed
   VGACtrl vga(
      .clk(sys_clk),
      .reset(Reset),
      .vga_h_sync(Hsync),
      .vga_v_sync(Vsync),
      .inDisplayArea(inDisplayArea),
      .CounterX(CounterX),
      .CounterY(CounterY)
   );

   reg toggleByte;

   // Use sys_clk, enable on DIV_CLK[1] if needed
   always @(posedge sys_clk or posedge Reset) begin
      if (Reset) begin
         bitCounter <= 0;
         toggleByte <= 0;
         readAddress <= 0;
      end
      else if (DIV_CLK[1]) begin
         if(CounterY > 192 && CounterY < 288) begin
            if(CounterX == 0) begin
               bitCounter <= 0;
               toggleByte <= 1'b0;
            end
            else if(CounterX > 284 && bitCounter < 35) begin
               if(toggleByte == 1'b0) begin
                  {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][7:0];
                  toggleByte <= 1'b1;
               end
               else begin
                  {_vgaRed, _vgaGreen, _vgaBlue} <= dataRegister[readAddress][15:8];
                  toggleByte <= 1'b0;
                  bitCounter <= bitCounter + 1;
                  readAddress <= readAddress + 1;
               end
            end
            else begin
               {_vgaRed, _vgaGreen, _vgaBlue} <= 0;
            end
         end
         else if (CounterY == 288) begin
            readAddress <= 0;
         end
      end
   end

   always@(posedge sys_clk or posedge Reset) begin
      if(Reset)
         readImage <= 0;
      else if(BtnU_Pulse)
         readImage <= readImage + 1;
      else if(BtnD_Pulse)
         readImage <= readImage - 1;
      else
         address <= imageRegister[readImage][22:0];
   end

   always@(posedge sys_clk or posedge Reset) begin
      if(Reset) begin
         writePointer <= 0;
      end
      else if(writeData == 1'b1) begin
         dataRegister[writePointer][15:0] <= {lByte, uByte};
         writePointer <= writePointer + 1;
      end
      else begin
         writePointer <= 0;
      end
   end

   always@(posedge sys_clk or posedge Reset) begin
      if(Reset) begin
         readRow <= 0;
      end
      else if(BtnR_Pulse) begin
         readRow <= readRow + 1;
      end
      else if(BtnL_Pulse) begin
         readRow <= readRow - 1;
      end
   end

endmodule
----------------------------------END CODE----------------------------------