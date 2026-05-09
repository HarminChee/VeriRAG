module VGA1Interface_corrected_ffc(clock,reset,framebuffer,vga_hsync,vga_vsync,vga_r,vga_g,vga_b);
   input wire         clock;
   input wire         reset;
   input wire [63:0]  framebuffer;
   output wire        vga_hsync;
   output wire        vga_vsync;
   output wire        vga_r;
   output wire        vga_g;
   output wire        vga_b;

   reg [9:0]  CounterX;
   reg [8:0]  CounterY;
   wire       value;
   reg        clock2;
   reg        vga_HS;
   reg        vga_VS;
   reg [2:0]  ix;
   reg [2:0]  iy;

   wire inDisplayArea = (CounterX < 640) && (CounterY < 480);
   wire CounterXmaxed = (CounterX == 767);

   // Generate clock2 as a toggle but keep the flip-flop on the primary clock
   always @ (posedge clock) begin
      if (reset) begin
         clock2 <= 1'b0;
      end
      else begin
         clock2 <= ~clock2;
      end
   end

   // CounterX update on primary clock, enabled by clock2
   always @ (posedge clock) begin
      if (reset) begin
         CounterX <= 10'd0;
      end
      else if (clock2) begin
         if (CounterXmaxed) begin
            CounterX <= 10'd0;
         end
         else begin
            CounterX <= CounterX + 10'd1;
         end
      end
   end

   // CounterY update on primary clock, enabled by clock2
   always @ (posedge clock) begin
      if (reset) begin
         CounterY <= 9'd0;
      end
      else if (clock2) begin
         if (CounterXmaxed) begin
            CounterY <= CounterY + 9'd1;
         end
      end
   end

   // HS and VS updates on primary clock, enabled by clock2
   always @ (posedge clock) begin
      if (reset) begin
         vga_HS <= 1'b0;
         vga_VS <= 1'b0;
      end
      else if (clock2) begin
         vga_HS <= (CounterX[9:4] == 0);
         vga_VS <= (CounterY == 0);
      end
   end

   assign vga_hsync = ~vga_HS;
   assign vga_vsync = ~vga_VS;

   // ix update on primary clock, enabled by clock2
   always @ (posedge clock) begin
      if (reset) begin
         ix <= 3'd0;
      end
      else if (clock2) begin
         if      (CounterX < 80)   ix <= 3'd0;
         else if (CounterX < 160)  ix <= 3'd1;
         else if (CounterX < 240)  ix <= 3'd2;
         else if (CounterX < 320)  ix <= 3'd3;
         else if (CounterX < 400)  ix <= 3'd4;
         else if (CounterX < 480)  ix <= 3'd5;
         else if (CounterX < 560)  ix <= 3'd6;
         else if (CounterX < 640)  ix <= 3'd7;
      end
   end

   // iy update on primary clock, enabled by clock2
   always @ (posedge clock) begin
      if (reset) begin
         iy <= 3'd0;
      end
      else if (clock2) begin
         if      (CounterY < 60)   iy <= 3'd0;
         else if (CounterY < 120)  iy <= 3'd1;
         else if (CounterY < 180)  iy <= 3'd2;
         else if (CounterY < 240)  iy <= 3'd3;
         else if (CounterY < 300)  iy <= 3'd4;
         else if (CounterY < 360)  iy <= 3'd5;
         else if (CounterY < 420)  iy <= 3'd6;
         else if (CounterY < 480)  iy <= 3'd7;
      end
   end

   assign value = framebuffer[{iy, ix}];
   assign vga_r = value & inDisplayArea;
   assign vga_g = value & inDisplayArea;
   assign vga_b = value & inDisplayArea;
endmodule