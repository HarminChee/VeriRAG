module VGA1Interface(clock,reset,test_i,framebuffer,vga_hsync,vga_vsync,vga_r,vga_g,vga_b);
   input wire         clock;
   input wire         reset;
   input wire         test_i; // Added test input
   input wire [63:0]  framebuffer;
   output wire        vga_hsync;
   output wire        vga_vsync;
   output wire        vga_r;
   output wire        vga_g;
   output wire        vga_b;
   reg [9:0]          CounterX;
   reg [8:0]          CounterY;
   wire               value;

   // Generate clock enable instead of internal clock
   reg                clk_enable_reg = 1'b0;
   wire               clk_enable = clk_enable_reg;

   always @ (posedge clock or posedge reset) begin
      if (reset) begin
         clk_enable_reg <= 1'b0;
      end
      else begin
         clk_enable_reg <= ~clk_enable_reg;
      end
   end

   reg         vga_HS;
   reg         vga_VS;
   // CounterXmaxed calculation needs CounterX which is synchronous to clock and clk_enable
   // Calculate based on the registered value
   wire        CounterXmaxed = (CounterX==767);
   wire        inDisplayArea = CounterX < 640 && CounterY < 480;

   always @ (posedge clock or posedge reset) begin // Changed clock, added reset
      if (reset) begin
         CounterX <= 0;
      end else if (clk_enable) begin // Gated with enable
         if(CounterXmaxed) begin
            CounterX <= 0;
         end
         else begin
            CounterX <= CounterX + 1;
         end
      end
   end

   always @ (posedge clock or posedge reset) begin // Changed clock, added reset
      if (reset) begin
         CounterY <= 0;
      end else if (clk_enable) begin // Gated with enable
         // Update CounterY only when CounterXmaxed becomes true on a clk_enable edge
         if(CounterXmaxed) begin
             if (CounterY == 499) // Assuming VGA 640x480 @ 60Hz timing (adjust if needed)
                 CounterY <= 0;
             else
                 CounterY <= CounterY + 1;
         end
      end
   end

   // VGA Timing logic - updated to run on primary clock + enable
   // Note: Precise VGA timing might need adjustments based on the exact spec
   // HSync: 96 clocks (active low) -> CounterX 656 to 751
   // VSync: 2 lines (active low) -> CounterY 490 to 491
   always @ (posedge clock or posedge reset) begin // Changed clock, added reset
      if (reset) begin
         vga_HS <= 1'b1; // Horizontal Sync inactive
         vga_VS <= 1'b1; // Vertical Sync inactive
      end else if (clk_enable) begin // Gated with enable
         // Update based on counter values
         vga_HS <= ~((CounterX >= 656) && (CounterX < 752)); // Active low HSync
         vga_VS <= ~((CounterY >= 490) && (CounterY < 492)); // Active low VSync
      end
   end

   assign vga_hsync = vga_HS; // Direct assignment from register
   assign vga_vsync = vga_VS; // Direct assignment from register

   reg [2:0] ix;
   reg [2:0] iy;

   // ix and iy logic updated to run on primary clock + enable
   always @ (posedge clock or posedge reset) begin // Changed clock, added reset
      if (reset) begin
         ix <= 0;
      end else if (clk_enable && inDisplayArea) begin // Gated with enable and valid display area
         // Simplified index calculation (integer division by block width/height)
         // Assumes 8x8 blocks (640/8 = 80, 480/8 = 60)
         ix <= CounterX / 80;
      end
      // Keep previous value if not enabled or outside display area
   end

   always @ (posedge clock or posedge reset) begin // Changed clock, added reset
      if (reset) begin
         iy <= 0;
      end else if (clk_enable && inDisplayArea) begin // Gated with enable and valid display area
         // Simplified index calculation
         iy <= CounterY / 60;
      end
       // Keep previous value if not enabled or outside display area
   end

   // Framebuffer lookup uses registered ix, iy values
   assign value = framebuffer[{iy,ix}];

   // VGA RGB output logic
   // Use registered values and gate with inDisplayArea
   // Register outputs to avoid combinatorial paths to top-level outputs if needed for timing
   reg vga_r_reg, vga_g_reg, vga_b_reg;
   always @(posedge clock or posedge reset) begin
       if (reset) begin
           vga_r_reg <= 1'b0;
           vga_g_reg <= 1'b0;
           vga_b_reg <= 1'b0;
       end else if (clk_enable) begin // Update on enabled clock edge
           if (inDisplayArea) begin
               vga_r_reg <= value;
               vga_g_reg <= value;
               vga_b_reg <= value;
           end else begin
               vga_r_reg <= 1'b0; // Black during blanking intervals
               vga_g_reg <= 1'b0;
               vga_b_reg <= 1'b0;
           end
       end
   end

   assign vga_r = vga_r_reg;
   assign vga_g = vga_g_reg;
   assign vga_b = vga_b_reg;

endmodule