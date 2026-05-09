module main_corrected_acn (
    input clk,
    input rst_in,  // Changed from output rst to input rst_in
    output c0,
    output c1,
    output c2,
    output c3,
    output c4,
    output c5,
    output c6,
    output c7
);
wire clk_in, clk2;
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
       .PACKAGE_PIN(rst_in),  // Changed from rst to rst_in
       .D_IN_0(rst2)
   );

assign clk_in = ~clk2;

reg [7:0] counter;
always @(posedge clk_in or posedge rst2) begin  // Changed from rst_in to rst2
    if (rst2 == 1'b1)
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