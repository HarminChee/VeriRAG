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

   reg disp_data_out_reg, disp_rs_reg, disp_ce_b_reg, disp_reset_b_reg;
   assign disp_data_out = disp_data_out_reg;
   assign disp_rs       = disp_rs_reg;
   assign disp_ce_b     = disp_ce_b_reg;
   assign disp_reset_b  = disp_reset_b_reg;

   reg [4:0] count;
   reg [7:0] reset_count;
   reg clock;
   wire dreset;

   // Generate 500 kHz display clock
   always @(posedge clock_27mhz) begin
      if (reset) begin
         count  <= 0;
         clock  <= 0;
      end
      else if (count == 26) begin
         clock <= ~clock;
         count <= 0;
      end
      else begin
         count <= count + 1;
      end
   end

   // Reset-once state machine
   always @(posedge clock_27mhz) begin
      if (reset) begin
         reset_count <= 100;
      end
      else begin
         reset_count <= (reset_count == 0) ? 0 : reset_count - 1;
      end
   end

   assign dreset     = (reset_count != 0);
   assign disp_clock = ~clock;
   assign disp_blank = 1'b0;

   reg [7:0]  state;
   reg [9:0]  dot_index;
   reg [31:0] control;
   reg [3:0]  char_index;
   reg [39:0] dots;
   reg [3:0]  nibble;

   always @(posedge clock) begin
      if (dreset) begin
         state      <= 8'h00;
         dot_index  <= 0;
         control    <= 32'h7F7F7F7F;
      end
      else begin
         casez (state)
           8'h00: begin
              // Reset displays
              disp_data_out_reg <= 1'b0;
              disp_rs_reg       <= 1'b0;  // dot register
              disp_ce_b_reg     <= 1'b1;
              disp_reset_b_reg  <= 1'b0;
              dot_index         <= 0;
              state             <= 8'h01;
           end

           8'h01: begin
              // End reset
              disp_reset_b_reg <= 1'b1;
              state            <= 8'h02;
           end

           8'h02: begin
              // Initialize dot register (zero all dots)
              disp_ce_b_reg     <= 1'b0;
              disp_data_out_reg <= 1'b0;
              if (dot_index == 639) begin
                 state <= 8'h03;
              end
              else begin
                 dot_index <= dot_index + 1;
              end
           end

           8'h03: begin
              // Latch dot data
              disp_ce_b_reg <= 1'b1;
              dot_index     <= 31;      // re-purpose to init ctrl reg
              disp_rs_reg   <= 1'b1;    // Select the control register
              state         <= 8'h04;
           end

           8'h04: begin
              // Setup the control register
              disp_ce_b_reg     <= 1'b0;
              disp_data_out_reg <= control[31];
              control           <= {control[30:0], 1'b0};
              if (dot_index == 0) begin
                 state <= 8'h05;
              end
              else begin
                 dot_index <= dot_index - 1;
              end
           end

           8'h05: begin
              // Latch control register data / dot data
              disp_ce_b_reg <= 1'b1;
              dot_index     <= 39;     // init for single char
              char_index    <= 15;     // start with MS char
              state         <= 8'h06;
              disp_rs_reg   <= 1'b0;   // Select the dot register
           end

           8'h06: begin
              // Load user's dot data into dot reg, char by char
              disp_ce_b_reg     <= 1'b0;
              disp_data_out_reg <= dots[dot_index];
              if (dot_index == 0) begin
                 if (char_index == 0) begin
                    // all done, latch data
                    state <= 8'h05;
                 end
                 else begin
                    char_index <= char_index - 1;
                    dot_index  <= 39;
                 end
              end
              else begin
                 dot_index <= dot_index - 1;
              end
           end

         endcase
      end
   end

   always @(*) begin
      case (char_index)
         4'h0:  nibble = data[  3:  0];
         4'h1:  nibble = data[  7:  4];
         4'h2:  nibble = data[ 11:  8];
         4'h3:  nibble = data[ 15: 12];
         4'h4:  nibble = data[ 19: 16];
         4'h5:  nibble = data[ 23: 20];
         4'h6:  nibble = data[ 27: 24];
         4'h7:  nibble = data[ 31: 28];
         4'h8:  nibble = data[ 35: 32];
         4'h9:  nibble = data[ 39: 36];
         4'hA:  nibble = data[ 43: 40];
         4'hB:  nibble = data[ 47: 44];
         4'hC:  nibble = data[ 51: 48];
         4'hD:  nibble = data[ 55: 52];
         4'hE:  nibble = data[ 59: 56];
         4'hF:  nibble = data[ 63: 60];
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