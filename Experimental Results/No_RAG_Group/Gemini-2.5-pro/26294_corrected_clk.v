module digits_corrected_clk (
  mclk,
  enable,
  values,
  seg,
  digit
);
  input wire mclk;
  input wire[3:0] enable;
  input wire[15:0] values;
  output reg[6:0] seg = 7'b0000000; // Corrected initialization for active low
  output reg[3:0] digit = 4'b1111;

  reg[14:0] counter = 0;
  reg[1:0] index = 0; // Initialize index
  reg khz_enable_reg = 0; // Registered clock enable signal

  wire[3:0] number;

  // Combinational logic to select the number based on the current index
  assign number =
    (index == 0) ? values[3:0] :
    (index == 1) ? values[7:4] :
    (index == 2) ? values[11:8] :
    values[15:12];

  // Counter and clock enable generation, clocked by the primary clock mclk
  always @(posedge mclk) begin : khz_counter_and_enable
    if (counter == 15'd24999) begin // Generates enable pulse ~1kHz for 50MHz mclk
      counter <= 0;
      khz_enable_reg <= 1'b1; // Assert enable for one mclk cycle
    end else begin
      counter <= counter + 1;
      khz_enable_reg <= 1'b0; // Deassert enable otherwise
    end
  end

  // Segment display logic, clocked by mclk and enabled by khz_enable_reg
  always @(posedge mclk) begin : seg_display
    if (khz_enable_reg) begin // Update registers only when enabled
      index <= index + 1; // Update index on enable pulse

      // Update digit select based on the index value *before* this clock edge
      case (index)
        2'b00: digit <= {3'b111, ~enable[0]};
        2'b01: digit <= {2'b11, ~enable[1], 1'b1};
        2'b10: digit <= {1'b1, ~enable[2], 2'b11};
        2'b11: digit <= {~enable[3], 3'b111};
        default: digit <= 4'b1111;
      endcase

      // Update segment display based on the number selected by the index value *before* this clock edge
      case (number)
        4'h0: seg <= ~(7'b0111111); // 0
        4'h1: seg <= ~(7'b0000110); // 1
        4'h2: seg <= ~(7'b1011011); // 2
        4'h3: seg <= ~(7'b1001111); // 3
        4'h4: seg <= ~(7'b1100110); // 4
        4'h5: seg <= ~(7'b1101101); // 5
        4'h6: seg <= ~(7'b1111101); // 6
        4'h7: seg <= ~(7'b0000111); // 7
        4'h8: seg <= ~(7'b1111111); // 8
        4'h9: seg <= ~(7'b1101111); // 9
        4'hA: seg <= ~(7'b1110111); // A
        4'hB: seg <= ~(7'b1111100); // b
        4'hC: seg <= ~(7'b0111001); // C
        4'hD: seg <= ~(7'b1011110); // d
        4'hE: seg <= ~(7'b1111001); // E
        4'hF: seg <= ~(7'b1110001); // F
        default: seg <= ~(7'b0000000); // Blank or error indicator
      endcase
    end
  end

endmodule