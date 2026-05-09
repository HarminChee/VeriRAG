module main_corrected_acn (
             input clk,
             input rst, // Primary input for asynchronous reset
             output c0,
             output c1,
             output c2,
             output c3,
             output c4,
             output c5,
             output c6,
             output c7);

wire clk_in, clk2;
wire rst2; // Intermediate signal from rst IO buffer

   // IO buffer for clock input
   SB_IO #(
       .PIN_TYPE(6'b 1010_01),
       .PULLUP(1'b 1)
   ) io_pin_clk (
       .PACKAGE_PIN(clk),
       .D_IN_0(clk2)
   );

   // IO buffer for reset input
   SB_IO #(
       .PIN_TYPE(6'b 1010_01),
       .PULLUP(1'b 1)
   ) io_pin_rst (
       .PACKAGE_PIN(rst),
       .D_IN_0(rst2)
   );

// Internal clock signal generation (inverted clock from IO buffer)
assign clk_in = ~clk2;

// Counter register
reg [7:0] counter;

 // Asynchronous reset is now directly controlled by the primary input 'rst'
 always @(posedge clk_in or posedge rst) begin
   // Use the primary input 'rst' directly for the asynchronous reset condition
   if (rst == 1'b1)
     counter <= 8'b0; // Corrected width for 8-bit register
   else
     counter <= counter + 1;
 end

 // Output assignments
 assign c0 = counter[0];
 assign c1 = counter[1];
 assign c2 = counter[2];
 assign c3 = counter[3];
 assign c4 = counter[4];
 assign c5 = counter[5];
 assign c6 = counter[6];
 assign c7 = counter[7];

endmodule