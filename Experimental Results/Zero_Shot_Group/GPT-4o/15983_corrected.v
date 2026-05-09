module VGA1Interface(clock,reset,framebuffer,vga_hsync,vga_vsync,vga_r,vga_g,vga_b);
   input wire         clock;
   input wire         reset;
   input wire [63:0]  framebuffer;
   output wire        vga_hsync;
   output wire        vga_vsync;
   output wire        vga_r;
   output wire        vga_g;
   output wire        vga_b;
   reg [9:0]          CounterX;
   reg [8:0]          CounterY;
   wire               value;
   reg                clock2 = 0;
   
   always @ (posedge clock) begin
      if (reset) begin
         clock2 <= 0;
      end
      else begin
         clock2 <= ~clock2;
      end
   end
   
   reg         vga_HS;
   reg         vga_VS;
   wire        inDisplayArea = CounterX < 640 && CounterY < 480;
   wire        CounterXmaxed = (CounterX == 799);
   
   always @ (posedge clock2) begin
      if (CounterXmaxed) begin
         CounterX <= 0;
      end
      else begin
         CounterX <= CounterX + 1;
      end
   end
   
   always @ (posedge clock2) begin
      if (CounterXmaxed) begin
         if (CounterY == 524) begin
            CounterY <= 0;
         end
         else begin
            CounterY <= CounterY + 1;
         end
      end
   end
   
   always @ (posedge clock2) begin
      vga_HS <= (CounterX >= 656 && CounterX < 752);
      vga_VS <= (CounterY >= 490 && CounterY < 492);
   end
   
   assign vga_hsync = ~vga_HS;
   assign vga_vsync = ~vga_VS;
   
   reg [2:0] ix;
   reg [2:0] iy;
   
   always @ (posedge clock2) begin
      case (CounterX[9:7])
         3'b000: ix = 0;
         3'b001: ix = 1;
         3'b010: ix = 2;
         3'b011: ix = 3;
         3'b100: ix = 4;
         3'b101: ix = 5;
         3'b110: ix = 6;
         3'b111: ix = 7;
      endcase
   end
   
   always @ (posedge clock2) begin
      case (CounterY[8:6])
         3'b000: iy = 0;
         3'b001: iy = 1;
         3'b010: iy = 2;
         3'b011: iy = 3;
         3'b100: iy = 4;
         3'b101: iy = 5;
         3'b110: iy = 6;
         3'b111: iy = 7;
      endcase
   end
   
   assign value = framebuffer[{iy,ix}];
   assign vga_r = value & inDisplayArea;
   assign vga_g = value & inDisplayArea;
   assign vga_b = value & inDisplayArea;
endmodule