module main (input clk,
             input rst,
             output c0,
             output c1,
             output c2,
             output c3,
             output c4,
             output c5,
             output c6,
             output c7);
wire clk2;
wire rst2;
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

reg [7:0] counter;
 always @(posedge clk2 or posedge rst2) begin // Use buffered primary inputs directly
   if (rst2==1'b1) // Use buffered primary input directly for reset
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