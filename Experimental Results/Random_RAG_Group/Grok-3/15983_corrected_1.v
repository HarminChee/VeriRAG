module VGA1Interface(
    input wire         clock,
    input wire         reset,
    input wire         test_i,
    input wire [63:0]  framebuffer,
    output wire        vga_hsync,
    output wire        vga_vsync,
    output wire        vga_r,
    output wire        vga_g,
    output wire        vga_b
);
   reg [9:0]          CounterX;
   reg [8:0]          CounterY;
   wire               value;
   wire               clock2;
   wire               dft_clock2;
   wire               dft_reset;
   assign dft_clock2 = test_i ? clock : clock2;
   assign dft_reset = test_i ? reset : reset;

   reg                clock2_reg = 0;
   assign clock2 = clock2_reg;

   always @(posedge clock or posedge reset) begin
      if (reset) begin
         clock2_reg <= 0;
      end else begin
         clock2_reg <= ~clock2_reg;
      end
   end

   reg         vga_HS;
   reg         vga_VS;
   wire        inDisplayArea = CounterX < 640 && CounterY < 480;
   wire        CounterXmaxed = (CounterX == 767);

   always @(posedge dft_clock2 or posedge dft_reset) begin
      if (dft_reset) begin
         CounterX <= 0;
      end else if (CounterXmaxed) begin
         CounterX <= 0;
      end else begin
         CounterX <= CounterX + 1;
      end
   end

   always @(posedge dft_clock2 or posedge dft_reset) begin
      if (dft_reset) begin
         CounterY <= 0;
      end else if (CounterXmaxed) begin
         CounterY <= CounterY + 1;
      end
   end

   always @(posedge dft_clock2 or posedge dft_reset) begin
      if (dft_reset) begin
         vga_HS <= 0;
         vga_VS <= 0;
      end else begin
         vga_HS <= (CounterX[9:4] == 0);
         vga_VS <= (CounterY == 0);
      end
   end

   assign vga_hsync = ~vga_HS;
   assign vga_vsync = ~vga_VS;

   reg [2:0] ix;
   reg [2:0] iy;

   always @(posedge dft_clock2 or posedge dft_reset) begin
      if (dft_reset) begin
         ix <= 0;
      end else begin
         if (CounterX < 80) begin
            ix <= 0;
         end else if (CounterX < 160) begin
            ix <= 1;
         end else if (CounterX < 240) begin
            ix <= 2;
         end else if (CounterX < 320) begin
            ix <= 3;
         end else if (CounterX < 400) begin
            ix <= 4;
         end else if (CounterX < 480) begin
            ix <= 5;
         end else if (CounterX < 560) begin
            ix <= 6;
         end else begin
            ix <= 7;
         end
      end
   end

   always @(posedge dft_clock2 or posedge dft_reset) begin
      if (dft_reset) begin
         iy <= 0;
      end else begin
         if (CounterY < 60) begin
            iy <= 0;
         end else if (CounterY < 120) begin
            iy <= 1;
         end else if (CounterY < 180) begin
            iy <= 2;
         end else if (CounterY < 240) begin
            iy <= 3;
         end else if (CounterY < 300) begin
            iy <= 4;
         end else if (CounterY < 360) begin
            iy <= 5;
         end else if (CounterY < 420) begin
            iy <= 6;
         end else if (CounterY < 480) begin
            iy <= 7;
         end
      end
   end

   assign value = framebuffer[{iy, ix}];
   assign vga_r = value & inDisplayArea;
   assign vga_g = value & inDisplayArea;
   assign vga_b = value & inDisplayArea;

endmodule