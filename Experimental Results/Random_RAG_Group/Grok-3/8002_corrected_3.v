module display_16hex (
    input wire reset, 
    input wire clock_27mhz, 
    input wire [63:0] data, 
    input wire test_mode,
    output wire disp_blank, 
    output wire disp_clock, 
    output wire disp_data_out, 
    output wire disp_rs, 
    output wire disp_ce_b,
    output wire disp_reset_b
);

   reg disp_data_out, disp_rs, disp_ce_b, disp_reset_b;
   
   reg [4:0] count;
   reg [7:0] reset_count;
   reg clock;
   wire dreset;
   wire dft_clock;
   wire dft_reset;

   always @(posedge clock_27mhz or posedge reset)
     begin
        if (reset)
          begin
             count <= 0;
             clock <= 0;
          end
        else if (count == 26)
          begin
             clock <= ~clock;
             count <= 5'h00;
          end
        else
          count <= count + 1;
     end
   
   always @(posedge clock_27mhz or posedge reset)
     if (reset)
       reset_count <= 100;
     else
       reset_count <= (reset_count == 0) ? 0 : reset_count - 1;

   assign dreset = (reset_count != 0);
   assign dft_reset = test_mode ? reset : dreset;
   assign dft_clock = test_mode ? clock_27mhz : clock;
   assign disp_clock = ~dft_clock;

   reg [7:0] state;
   reg [9:0] dot_index;
   reg [31:0] control;
   reg [3:0] char_index;
   reg [39:0] dots;
   reg [3:0] nibble;
   
   assign disp_blank = 1'b0;
   
   always @(posedge dft_clock or posedge dft_reset)
     if (dft_reset)
       begin
          state <= 0;
          dot_index <= 0;
          control <= 32'h7F7F7F7F;
          disp_data_out <= 1'b0;
          disp_rs <= 1'b0;
          disp_ce_b <= 1'b1;
          disp_reset_b <= 1'b0;
       end
     else
       case (state)
         8'h00:
           begin
              disp_data_out <= 1'b0; 
              disp_rs <= 1'b0;
              disp_ce_b <= 1'b1;
              disp_reset_b <= 1'b0;        
              dot_index <= 0;
              state <= state + 1;
           end
         
         8'h01:
           begin
              disp_reset_b <= 1'b1;
              state <= state + 1;
           end
         
         8'h02:
           begin
              disp_ce_b <= 1'b0;
              disp_data_out <= 1'b0;
              if (dot_index == 639)
                state <= state + 1;
              else
                dot_index <= dot_index + 1;
           end
         
         8'h03:
           begin
              disp_ce_b <= 1'b1;
              dot_index <= 31;
              disp_rs <= 1'b1;
              state <= state + 1;
           end
         
         8'h04:
           begin
              disp_ce_b <= 1'b0;
              disp_data_out <= control[31];
              control <= {control[30:0], 1'b0};
              if (dot_index == 0)
                state <= state + 1;
              else
                dot_index <= dot_index - 1;
           end
          
         8'h05:
           begin
              disp_ce_b <= 1'b1;
              dot_index <= 39;
              char_index <= 15;
              state <= state + 1;
              disp_rs <= 1'b0;
           end
         
         8'h06:
           begin
              disp_ce_b <= 1'b0;
              disp_data_out <= dots[dot_index];
              if (dot_index == 0)
                if (char_index == 0)
                  state <= 8'h05;
                else
                  begin
                    char_index <= char_index - 1;
                    dot_index <= 39;
                  end
              else
                dot_index <= dot_index - 1;
           end

         default:
           state <= 8'h00;

       endcase

   always @ (data or char_index)
     case (char_index)
       4'h0:     nibble <= data[3:0];
       4'h1:     nibble <= data[7:4];
       4'h2:     nibble <= data[11:8];
       4'h3:     nibble <= data[15:12];
       4'h4:     nibble <= data[19:16];
       4'h5:     nibble <= data[23:20];
       4'h6:     nibble <= data[27:24];
       4'h7:     nibble <= data[31:28];
       4'h8:     nibble <= data[35:32];
       4'h9:     nibble <= data[39:36];
       4'hA:     nibble <= data[43:40];
       4'hB:     nibble <= data[47:44];
       4'hC:     nibble <= data[51:48];
       4'hD:     nibble <= data[55:52];
       4'hE:     nibble <= data[59:56];
       4'hF:     nibble <= data[63:60];
       default:  nibble <= 4'h0;
     endcase
      
   always @(nibble)
     case (nibble)
       4'h0: dots <= 40'b00111110_01010001_01001001_01000101_00111110;
       4'h1: dots <= 40'b00000000_01000010_01111111_01000000_00000000;
       4'h2: dots <= 40'b01100010_01010001_01001001_01001001_01000110;
       4'h3: dots <= 40'b00100010_01000001_01001001_01001001_00110110;
       4'h4: dots <= 40'b00011000_00010100_00010010_01111111_00010000;
       4'h5: dots <= 40'b00100111_01000101_01000101_01000101_00111001;
       4'h6: dots <= 40'b00111100_01001010_01001001_01001001_00110000;
       4'h7: dots <= 40'b00000001_01110001_00001001_00000101_00000011;
       4'h8: dots <= 40'b00110110_01001001_01001001_01001001_00110110;
       4'h9: dots <= 40'b00000110_01001001_01001001_00101001_00011110;
       4'hA: dots <= 40'b01111110_00001001_00001001_00001001_01111110;
       4'hB: dots <= 40'b01111111_01001001_01001001_01001001_00110110;
       4'hC: dots <= 40'b00111110_01000001_01000001_01000001_00100010;
       4'hD: dots <= 40'b01111111_01000001_01000001_01000001_00111110;
       4'hE: dots <= 40'b01111111_01001001_01001001_01001001_01000001;
       4'hF: dots <= 40'b01111111_00001001_00001001_00001001_00000001;
       default: dots <= 40'b00111110_01010001_01001001_01000101_00111110;
     endcase
   
endmodule