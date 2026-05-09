module main (input clk,
             input rst,
             input test_i, // Added test input
             output c0,
             output c1,
             output c2,
             output c3,
             output c4,
             output c5,
             output c6,
             output c7);

wire clk_in, clk2;
wire rst_in, rst2;
wire dft_clk, dft_rst; // Multiplexed signals

   SB_IO #(
       .PIN_TYPE(6'b 1010_01),
       .PULLUP(1'b 1)
   ) io_pin (
       .PACKAGE_PIN(clk),
       .D_IN_0(clk2)
   );

   SB_IO #(
       .PIN_TYPE(6'b 1010_01),
       .PULLUP(1'b 1)
   ) io_pin2 (
       .PACKAGE_PIN(rst),
       .D_IN_0(rst2)
   );

assign rst_in = ~rst2; // Functional active-high reset
assign clk_in = ~clk2; // Functional clock (inverted from buffered clk)

// DFT Muxing: Select direct primary inputs in test mode
assign dft_clk = test_i ? clk : clk_in;
assign dft_rst = test_i ? rst : rst_in; // Assuming primary input rst is active high

reg [7:0] counter;

 // Use DFT-muxed clock and reset
 always @(posedge dft_clk or posedge dft_rst) begin
   if (dft_rst == 1'b1) // Use active-high reset
     counter <= 8'b0; // Corrected width
   else
     counter <= counter + 1;
 end

 assign c0 = counter[0];
 assign c1 = counter[1];
 assign c2 = counter[2];
 assign c3 = counter[3];
 assign c4 = counter[4];
 assign c5 = counter[5];
 assign c6 = counter[6];
 assign c7 = counter[7];

endmodule