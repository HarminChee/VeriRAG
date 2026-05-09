module game_text
   (
    input wire clk, 
    input wire [1:0] ball,
    input wire [3:0] dig0, dig1,
    input wire [9:0] pix_x, pix_y,
    output wire [3:0] text_on,
    output reg [2:0] text_rgb
   );
   wire [10:0] rom_addr;
   reg [6:0] char_addr, char_addr_s, char_addr_l,
             char_addr_r, char_addr_o;
   reg [3:0] row_addr;
   wire [3:0] row_addr_s, row_addr_l, row_addr_r, row_addr_o;
   reg [2:0] bit_addr;
   wire [2:0] bit_addr_s, bit_addr_l,bit_addr_r, bit_addr_o;
   wire [7:0] font_word;
   wire font_bit, score_on, logo_on, registration_on, over_on;
   wire [5:0] registration_rom_addr;
   font_rom font_unit
      (.clk(clk), .addr(rom_addr), .data(font_word));
   assign score_on = (pix_y[9:5]==0) && (pix_x[9:4]<16);
   assign row_addr_s = pix_y[4:1];
   assign bit_addr_s = pix_x[3:1];
   always @*
      case (pix_x[7:4])
         4'h0: char_addr_s = 7'h53; 
         4'h1: char_addr_s = 7'h63; 
         4'h2: char_addr_s = 7'h6f; 
         4'h3: char_addr_s = 7'h72; 
         4'h4: char_addr_s = 7'h65; 
         4'h5: char_addr_s = 7'h3a; 
          4'h6: char_addr_s = {3'b011, dig1}; 
          4'h7: char_addr_s = {3'b011, dig0}; 
          4'h8: char_addr_s = 7'h00; 
          4'h9: char_addr_s = 7'h00; 
          4'ha: char_addr_s = 7'h42; 
          4'hb: char_addr_s = 7'h61; 
          4'hc: char_addr_s = 7'h6c; 
          4'hd: char_addr_s = 7'h6c; 
          4'he: char_addr_s = 7'h3a; 
          4'hf: char_addr_s = {5'b01100, ball};
      endcase
   assign logo_on = (pix_y[9:7]==2) &&
                    (3<=pix_x[9:6]) && (pix_x[9:6]<=6);
   assign row_addr_l = pix_y[6:3];
   assign bit_addr_l = pix_x[5:3];
   always @*
      case (pix_x[8:6])
         3'o3: char_addr_l = 7'h57; 
         3'o4: char_addr_l = 7'h50; 
         3'o5: char_addr_l = 7'h50; 
         default: char_addr_l = 7'h57; 
      endcase
   assign registration_on = (pix_x[9:7]==2) && (pix_y[9:6]==2);
   assign row_addr_r = pix_y[3:0];
   assign bit_addr_r = pix_x[2:0];
   assign registration_rom_addr = {pix_y[5:4], pix_x[6:3]};
   always @*
      case (registration_rom_addr)
         6'h00: char_addr_r = 7'h33;
         6'h01: char_addr_r = 7'h31;
         6'h02: char_addr_r = 7'h32;
         6'h03: char_addr_r = 7'h30;
         6'h04: char_addr_r = 7'h31;
         6'h05: char_addr_r = 7'h30;
         6'h06: char_addr_r = 7'h33;
         6'h07: char_addr_r = 7'h37;
         6'h08: char_addr_r = 7'h39;
         6'h09: char_addr_r = 7'h35;
         6'h0A: char_addr_r = 7'h20;
         6'h0B: char_addr_r = 7'h20;
         6'h0C: char_addr_r = 7'h20;
         6'h0D: char_addr_r = 7'h20;
         6'h0E: char_addr_r = 7'h20;
         6'h0F: char_addr_r = 7'h20;
         6'h10: char_addr_r = 7'h50;
         6'h11: char_addr_r = 7'h65;
         6'h12: char_addr_r = 7'h6E;
         6'h13: char_addr_r = 7'h67;
         6'h14: char_addr_r = 7'h77;
         6'h15: char_addr_r = 7'h65;
         6'h16: char_addr_r = 7'h69;
         6'h17: char_addr_r = 7'h20;
         6'h18: char_addr_r = 7'h57;
         6'h19: char_addr_r = 7'h75;
         6'h1A: char_addr_r = 7'h20;
         6'h1B: char_addr_r = 7'h20;
         6'h1C: char_addr_r = 7'h20;
         6'h1D: char_addr_r = 7'h20;
         6'h1E: char_addr_r = 7'h20;
         6'h1F: char_addr_r = 7'h20;
         6'h20: char_addr_r = 7'h33;
         6'h21: char_addr_r = 7'h31;
         6'h22: char_addr_r = 7'h32;
         6'h23: char_addr_r = 7'h30;
         6'h24: char_addr_r = 7'h31;
         6'h25: char_addr_r = 7'h30;
         6'h26: char_addr_r = 7'h32;
         6'h27: char_addr_r = 7'h33;
         6'h28: char_addr_r = 7'h35;
         6'h29: char_addr_r = 7'h38;
         6'h2A: char_addr_r = 7'h20;
         6'h2B: char_addr_r = 7'h20;
         6'h2C: char_addr_r = 7'h20;
         6'h2D: char_addr_r = 7'h20;
         6'h2E: char_addr_r = 7'h20;
         6'h2F: char_addr_r = 7'h20;
         6'h30: char_addr_r = 7'h57;
         6'h31: char_addr_r = 7'h65;
         6'h32: char_addr_r = 7'h69;
         6'h33: char_addr_r = 7'h20;
         6'h34: char_addr_r = 7'h43;
         6'h35: char_addr_r = 7'h68;
         6'h36: char_addr_r = 7'h65;
         6'h37: char_addr_r = 7'h6E;
         6'h38: char_addr_r = 7'h67;
         6'h39: char_addr_r = 7'h20;
         6'h3A: char_addr_r = 7'h20;
         6'h3B: char_addr_r = 7'h20;
         6'h3C: char_addr_r = 7'h20;
         6'h3D: char_addr_r = 7'h20;
         6'h3E: char_addr_r = 7'h20;
         6'h3F: char_addr_r = 7'h20;        
      endcase
   assign over_on = (pix_y[9:6]==3) &&
                    (5<=pix_x[9:5]) && (pix_x[9:5]<=13);
   assign row_addr_o = pix_y[5:2];
   assign bit_addr_o = pix_x[4:2];
   always @*
      case(pix_x[8:5])
         4'h5: char_addr_o = 7'h47; 
         4'h6: char_addr_o = 7'h61; 
         4'h7: char_addr_o = 7'h6d; 
         4'h8: char_addr_o = 7'h65; 
         4'h9: char_addr_o = 7'h00; 
         4'ha: char_addr_o = 7'h4f; 
         4'hb: char_addr_o = 7'h76; 
         4'hc: char_addr_o = 7'h65; 
         default: char_addr_o = 7'h72; 
      endcase
   always @*
   begin
      text_rgb = 3'b110;  
      if (score_on)
         begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
            if (font_bit)
               text_rgb = 3'b001;
         end
      else if (registration_on)
         begin
            char_addr = char_addr_r;
            row_addr = row_addr_r;
            bit_addr = bit_addr_r;
            if (font_bit)
               text_rgb = 3'b001;
         end
      else if (logo_on)
         begin
            char_addr = char_addr_l;
            row_addr = row_addr_l;
            bit_addr = bit_addr_l;
            if (font_bit)
               text_rgb = 3'b011;
         end
      else 
         begin
            char_addr = char_addr_o;
            row_addr = row_addr_o;
            bit_addr = bit_addr_o;
            if (font_bit)
               text_rgb = 3'b001;
         end
   end
   assign text_on = {score_on, logo_on, registration_on, over_on};
   assign rom_addr = {char_addr, row_addr};
   assign font_bit = font_word[~bit_addr];
endmodule
