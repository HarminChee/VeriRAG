module main (input clk,
             input rst,
             output c0,
             output c1,
             output c2,
             output c3,
             output c4,
             output c5,
             output c6,
             output c7,
			 input test_i);
wire clk_in,dft_clk_in,dft_rst_in, clk2;
wire rst_in, rst2;
assign dft_clk_in = test_i ? clk : clk_in ;
assign dft_rst_in = test_i ? rst : rst_in ;
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
assign rst_in = ~rst2;
assign clk_in = ~clk2;
reg [7:0] counter;
 always @(posedge dft_clk_in or posedge dft_rst_in) begin
   if (rst_in==1'b1)
     counter <= 7'b0;
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
