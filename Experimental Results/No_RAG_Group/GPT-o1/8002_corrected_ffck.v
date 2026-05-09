(6)_corrected_ffc.v

////////////////////////////////////////////////////////////////////////////////
// Corrected Verilog Code
////////////////////////////////////////////////////////////////////////////////

module display_16hex (
    input reset,
    input clock_27mhz,
    input [63:0] data, 
    output disp_blank,
    output disp_clock,
    output disp_rs,
    output disp_ce_b,
    output disp_reset_b,
    output disp_data_out
);

   reg disp_data_out, disp_rs, disp_ce_b, disp_reset_b;
   reg [4:0] count;
   reg [7:0] reset_count;
   reg clock;
   wire dreset;

   // Generate a 500kHz-like signal for driving the displays (but do not use it as a clock for flip-flops).
   always @(posedge clock_27mhz) begin
      if (reset) begin
         count <= 0;
         clock <= 0;
      end
      else if (count == 26) begin
         clock <= ~clock;
         count <= 0;
      end
      else begin
         count <= count + 1;
      end
   end

   always @(posedge clock_27mhz) begin
      if (reset)
         reset_count <= 100;
      else
         reset_count <= (reset_count == 0) ? 0 : (reset_count - 1);
   end

   assign dreset = (reset_count != 0);
   assign disp_clock = ~clock;
   assign disp_blank = 1'b0; // not blanked

   reg [7:0] state;
   reg [9:0] dot_index;
   reg [31:0] control;
   reg [3:0] char_index;
   reg [39:0] dots;
   reg [3:0] nibble;

   // State machine now clocked by the primary input clock
   always @(posedge clock_27mhz) begin
      if (dreset) begin
         state <= 8'h00;
         dot_index <= 10'h000;
         control <= 32'h7F7F7F7F;
      end
      else begin
         case (state)
           8'h00: begin
              disp_data_out <= 1'b0; 
              disp_rs       <= 1'b0;
              disp_ce_b     <= 1'b1;
              disp_reset_b  <= 1'b0;
              dot_index     <= 10'h000;
              state         <= 8'h01;
           end

           8'h01: begin
              disp_reset_b <= 1'b1;
              state        <= 8'h02;
           end

           8'h02: begin
              disp_ce_b     <= 1'b0;
              disp_data_out <= 1'b0;
              if (dot_index == 639)
                 state <= 8'h03;
              else
                 dot_index <= dot_index + 1;
           end

           8'h03: begin
              disp_ce_b <= 1'b1;
              dot_index <= 10'd31;
              disp_rs   <= 1'b1;
              state     <= 8'h04;
           end

           8'h04: begin
              disp_ce_b     <= 1'b0;
              disp_data_out <= control[31];
              control       <= {control[30:0], 1'b0};
              if (dot_index == 0)
                 state <= 8'h05;
              else
                 dot_index <= dot_index - 1;
           end

           8'h05: begin
              disp_ce_b <= 1'b1;
              dot_index <= 10'd39;
              char_index <= 4'hF;
              state <= 8'h06;
              disp_rs <= 1'b0;
           end

           8'h06: begin
              disp_ce_b <= 1'b0;
              disp_data_out <= dots[dot_index];
              if (dot_index == 0) begin
                 if (char_index == 0)
                    state <= 8'h05;
                 else begin
                    char_index <= char_index - 1;
                    dot_index <= 10'd39;
                 end
              end
              else
                 dot_index <= dot_index - 1;
           end

           default: ;
         endcase
      end
   end

   always @(*) begin
      case (char_index)
         4'h0:   nibble = data[3:0];
         4'h1:   nibble = data[7:4];
         4'h2:   nibble = data[11:8];
         4'h3:   nibble = data[15:12];
         4'h4:   nibble = data[19:16];
         4'h5:   nibble = data[23:20];
         4'h6:   nibble = data[27:24];
         4'h7:   nibble = data[31:28];
         4'h8:   nibble = data[35:32];
         4'h9:   nibble = data[39:36];
         4'hA:   nibble = data[43:40];
         4'hB:   nibble = data[47:44];
         4'hC:   nibble = data[51:48];
         4'hD:   nibble = data[55:52];
         4'hE:   nibble = data[59:56];
         4'hF:   nibble = data[63:60];
      endcase
   end

   always @(*) begin
      case (nibble)
         4'h0: dots = 40'b00111110_01010001_01001001_01000101_00111110;
         4'h1: dots = 40'b00000000_01000010_01111111_01000000_00000000;
         4'h2: dots = 40'b01100010_01010001_01001001_01001001_01000110;
         4'h3: dots = 40'b00100010_01000001_01001001_01001001_00110110;
         4'h4: dots = 40'b00011000_00010100_00010010_01111111_00010000;
         4'h5: dots = 40'b00100111_01000101_01000101_01000101_00111001;
         4'h6: dots = 40'b00111100_01001010_01001001_01001001_00110000;
         4'h7: dots = 40'b00000001_01110001_00001001_00000101_00000011;
         4'h8: dots = 40'b00110110_01001001_01001001_01001001_00110110;
         4'h9: dots = 40'b00000110_01001001_01001001_00101001_00011110;
         4'hA: dots = 40'b01111110_00001001_00001001_00001001_01111110;
         4'hB: dots = 40'b01111111_01001001_01001001_01001001_00110110;
         4'hC: dots = 40'b00111110_01000001_01000001_01000001_00100010;
         4'hD: dots = 40'b01111111_01000001_01000001_01000001_00111110;
         4'hE: dots = 40'b01111111_01001001_01001001_01001001_01000001;
         4'hF: dots = 40'b01111111_00001001_00001001_00001001_00000001;
      endcase
   end

endmodule


////////////////////////////////////////////////////////////////////////////////
// Second module with the same corrections
////////////////////////////////////////////////////////////////////////////////

module display_16hex_2 (
    input reset,
    input clock_27mhz,
    input [63:0] data, 
    output disp_blank,
    output disp_clock,
    output disp_rs,
    output disp_ce_b,
    output disp_reset_b,
    output disp_data_out
);

   reg disp_data_out, disp_rs, disp_ce_b, disp_reset_b;
   reg [4:0] count;
   reg [7:0] reset_count;
   reg clock;
   wire dreset;

   // Generate a 500kHz-like signal for driving the displays (but do not use it as a clock for flip-flops).
   always @(posedge clock_27mhz) begin
      if (reset) begin
         count <= 0;
         clock <= 0;
      end
      else if (count == 26) begin
         clock <= ~clock;
         count <= 0;
      end
      else begin
         count <= count + 1;
      end
   end

   always @(posedge clock_27mhz) begin
      if (reset)
         reset_count <= 100;
      else
         reset_count <= (reset_count == 0) ? 0 : (reset_count - 1);
   end

   assign dreset = (reset_count != 0);
   assign disp_clock = ~clock;
   assign disp_blank = 1'b0; // not blanked

   reg [7:0] state;
   reg [9:0] dot_index;
   reg [31:0] control;
   reg [3:0] char_index;
   reg [39:0] dots;
   reg [3:0] nibble;

   // State machine now clocked by the primary input clock
   always @(posedge clock_27mhz) begin
      if (dreset) begin
         state <= 8'h00;
         dot_index <= 10'h000;
         control <= 32'h7F7F7F7F;
      end
      else begin
         case (state)
           8'h00: begin
              disp_data_out <= 1'b0; 
              disp_rs       <= 1'b0;
              disp_ce_b     <= 1'b1;
              disp_reset_b  <= 1'b0;
              dot_index     <= 10'h000;
              state         <= 8'h01;
           end

           8'h01: begin
              disp_reset_b <= 1'b1;
              state        <= 8'h02;
           end

           8'h02: begin
              disp_ce_b     <= 1'b0;
              disp_data_out <= 1'b0;
              if (dot_index == 639)
                 state <= 8'h03;
              else
                 dot_index <= dot_index + 1;
           end

           8'h03: begin
              disp_ce_b <= 1'b1;
              dot_index <= 10'd31;
              disp_rs   <= 1'b1;
              state     <= 8'h04;
           end

           8'h04: begin
              disp_ce_b     <= 1'b0;
              disp_data_out <= control[31];
              control       <= {control[30:0], 1'b0};
              if (dot_index == 0)
                 state <= 8'h05;
              else
                 dot_index <= dot_index - 1;
           end

           8'h05: begin
              disp_ce_b <= 1'b1;
              dot_index <= 10'd39;
              char_index <= 4'hF;
              state <= 8'h06;
              disp_rs <= 1'b0;
           end

           8'h06: begin
              disp_ce_b <= 1'b0;
              disp_data_out <= dots[dot_index];
              if (dot_index == 0) begin
                 if (char_index == 0)
                    state <= 8'h05;
                 else begin
                    char_index <= char_index - 1;
                    dot_index <= 10'd39;
                 end
              end
              else
                 dot_index <= dot_index - 1;
           end

           default: ;
         endcase
      end
   end

   always @(*) begin
      case (char_index)
         4'h0:   nibble = data[3:0];
         4'h1:   nibble = data[7:4];
         4'h2:   nibble = data[11:8];
         4'h3:   nibble = data[15:12];
         4'h4:   nibble = data[19:16];
         4'h5:   nibble = data[23:20];
         4'h6:   nibble = data[27:24];
         4'h7:   nibble = data[31:28];
         4'h8:   nibble = data[35:32];
         4'h9:   nibble = data[39:36];
         4'hA:   nibble = data[43:40];
         4'hB:   nibble = data[47:44];
         4'hC:   nibble = data[51:48];
         4'hD:   nibble = data[55:52];
         4'hE:   nibble = data[59:56];
         4'hF:   nibble = data[63:60];
      endcase
   end

   always @(*) begin
      case (nibble)
         4'h0: dots = 40'b00111110_01010001_01001001_01000101_00111110;
         4'h1: dots = 40'b00000000_01000010_01111111_01000000_00000000;
         4'h2: dots = 40'b01100010_01010001_01001001_01001001_01000110;
         4'h3: dots = 40'b00100010_01000001_01001001_01001001_00110110;
         4'h4: dots = 40'b00011000_00010100_00010010_01111111_00010000;
         4'h5: dots = 40'b00100111_01000101_01000101_01000101_00111001;
         4'h6: dots = 40'b00111100_01001010_01001001_01001001_00110000;
         4'h7: dots = 40'b00000001_01110001_00001001_00000101_00000011;
         4'h8: dots = 40'b00110110_01001001_01001001_01001001_00110110;
         4'h9: dots = 40'b00000110_01001001_01001001_00101001_00011110;
         4'hA: dots = 40'b01111110_00001001_00001001_00001001_01111110;
         4'hB: dots = 40'b01111111_01001001_01001001_01001001_00110110;
         4'hC: dots = 40'b00111110_01000001_01000001_01000001_00100010;
         4'hD: dots = 40'b01111111_01000001_01000001_01000001_00111110;
         4'hE: dots = 40'b01111111_01001001_01001001_01001001_01000001;
         4'hF: dots = 40'b01111111_00001001_00001001_00001001_00000001;
      endcase
   end

endmodule