module TXT (
input clk,                    
input reset,                     
output [9:0] pix_x,               
output [9:0] pix_y,               
output reg[11:0] ascii_address,  
input [7:0] char_line_data,      
output reg vga_out,              
output reg disp_mem_en,          
output reg font_mem_en,           
output hsync, output vsync
);
VGA vga0 (
		.clk (clk),
		.pixv (pix_x),
		.pixh (pix_y),
		.hsync(hsync),
		.vsync(vsync)
		);
reg [7:0] line_data;             
reg [11:0] xp = 0;                   
reg [11:0] yp = 0;                   
always @( posedge clk or negedge reset )
begin
   if (!reset) begin
      line_data <= 0;            
      ascii_address <= 0;
      disp_mem_en <= 0;
      font_mem_en <= 0;
   end else begin
      ascii_address <= 0;
      case (pix_x[2:0])
         3'b110:  begin
               xp[11:0] <= { 6'd0, pix_x[9:4] };
               yp[11:0] <= { 6'd0, pix_y[9:4] };
               ascii_address[11:0] <= (yp << 5) + (yp << 3) + xp;
               disp_mem_en <= 1;
               font_mem_en <= 1;         
            end
         3'b111:  begin
               line_data <= char_line_data;
            end
         3'b000:  begin
               font_mem_en <= 0;
               disp_mem_en <= 0;
            end
      endcase
   end
end
always @( posedge clk )
begin
   case (pix_x[2:0])
      3'b000:  vga_out <= line_data[7];
      3'b001:  vga_out <= line_data[6];
      3'b010:  vga_out <= line_data[5];
      3'b011:  vga_out <= line_data[4];
      3'b100:  vga_out <= line_data[3];
      3'b101:  vga_out <= line_data[2];
      3'b110:  vga_out <= line_data[1];
      3'b111:  vga_out <= line_data[0];
      endcase
end
endmodule
