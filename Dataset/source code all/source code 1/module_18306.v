module study_text
   (
    input wire clk, 
    input wire [9:0] pix_x, pix_y,
    output wire [3:0] study_on,
    output reg [2:0] study_rgb
   );
   wire [10:0] rom_addr;
   reg [6:0] char_addr, char_addr_r;
   reg [3:0] row_addr;
   reg [2:0] bit_addr;
   wire [7:0] font_word;
   wire word_on, font_bit;
   wire [5:0] word_rom_addr;
	wire [3:0] row_addr_r;
	wire [2:0] bit_addr_r;
   font_rom font_unit
      (.clk(clk), .addr(rom_addr), .data(font_word));
   assign word_on = (pix_x[9:7]==2) && (pix_y[9:6]==2);
   assign row_addr_r = pix_y[3:0];
   assign bit_addr_r = pix_x[2:0];
   assign word_rom_addr = {pix_y[5:4], pix_x[6:3]};
   always @*
      case (word_rom_addr)
         6'h00: char_addr_r = 7'h62;
         6'h01: char_addr_r = 7'h6f;
         6'h02: char_addr_r = 7'h79;
         6'h03: char_addr_r = 7'h20;
         6'h04: char_addr_r = 7'h20;
         6'h05: char_addr_r = 7'h20;
         6'h06: char_addr_r = 7'h20;
         6'h07: char_addr_r = 7'h20;
         6'h08: char_addr_r = 7'h20;
         6'h09: char_addr_r = 7'h20;
         6'h0A: char_addr_r = 7'h20;
         6'h0B: char_addr_r = 7'h20;
         6'h0C: char_addr_r = 7'h20;
         6'h0D: char_addr_r = 7'h20;
         6'h0E: char_addr_r = 7'h20;
         6'h0F: char_addr_r = 7'h20;
         6'h10: char_addr_r = 7'h67;
         6'h11: char_addr_r = 7'h69;
         6'h12: char_addr_r = 7'h72;
         6'h13: char_addr_r = 7'h6c;
         6'h14: char_addr_r = 7'h20;
         6'h15: char_addr_r = 7'h20;
         6'h16: char_addr_r = 7'h20;
         6'h17: char_addr_r = 7'h20;
         6'h18: char_addr_r = 7'h20;
         6'h19: char_addr_r = 7'h20;
         6'h1A: char_addr_r = 7'h20;
         6'h1B: char_addr_r = 7'h20;
         6'h1C: char_addr_r = 7'h20;
         6'h1D: char_addr_r = 7'h20;
         6'h1E: char_addr_r = 7'h20;
         6'h1F: char_addr_r = 7'h20;
         6'h20: char_addr_r = 7'h63;
         6'h21: char_addr_r = 7'h61;
         6'h22: char_addr_r = 7'h74;
         6'h23: char_addr_r = 7'h20;
         6'h24: char_addr_r = 7'h20;
         6'h25: char_addr_r = 7'h20;
         6'h26: char_addr_r = 7'h20;
         6'h27: char_addr_r = 7'h20;
         6'h28: char_addr_r = 7'h20;
         6'h29: char_addr_r = 7'h20;
         6'h2A: char_addr_r = 7'h20;
         6'h2B: char_addr_r = 7'h20;
         6'h2C: char_addr_r = 7'h20;
         6'h2D: char_addr_r = 7'h20;
         6'h2E: char_addr_r = 7'h20;
         6'h2F: char_addr_r = 7'h20;
         6'h30: char_addr_r = 7'h20;
         6'h31: char_addr_r = 7'h20;
         6'h32: char_addr_r = 7'h20;
         6'h33: char_addr_r = 7'h20;
         6'h34: char_addr_r = 7'h20;
         6'h35: char_addr_r = 7'h20;
         6'h36: char_addr_r = 7'h20;
         6'h37: char_addr_r = 7'h20;
         6'h38: char_addr_r = 7'h20;
         6'h39: char_addr_r = 7'h20;
         6'h3A: char_addr_r = 7'h20;
         6'h3B: char_addr_r = 7'h20;
         6'h3C: char_addr_r = 7'h20;
         6'h3D: char_addr_r = 7'h20;
         6'h3E: char_addr_r = 7'h20;
         6'h3F: char_addr_r = 7'h20;        
      endcase
   always @*
   begin
      study_rgb = 3'b110;  
		if (word_on)
         begin
            char_addr = char_addr_r;
				row_addr = row_addr_r;
				bit_addr = bit_addr_r;
            if (font_bit)
               study_rgb = 3'b001;
         end
   end
   assign study_on = word_on;
   assign rom_addr = {char_addr, row_addr};
   assign font_bit = font_word[~bit_addr];
endmodule
