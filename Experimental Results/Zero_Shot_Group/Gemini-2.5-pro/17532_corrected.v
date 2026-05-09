module ps2lab1(
  input  CLOCK_50,
  input  [3:0]  KEY,
  input  [17:0]  SW,
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output  [8:0]  LEDG,
  output  [17:0]  LEDR,
  input  PS2_DAT,
  input  PS2_CLK,
  inout  [35:0]  GPIO_0, GPIO_1
);

  assign  GPIO_0    =  36'hzzzzzzzzz;
  assign  GPIO_1    =  36'hzzzzzzzzz;

  wire RST;
  assign RST = ~KEY[0]; // Assuming active-low reset from KEY[0]

  assign LEDR[17:0] = SW[17:0];
  assign LEDG = 9'b0; // Explicitly size the constant

  wire [7:0] scan_code;
  reg  [7:0] history [4:1]; // Correct array declaration [msb:lsb] or [size:index_start]
  wire read;
  wire scan_ready;

  // Assuming oneshot module generates a single pulse on 'read' when 'scan_ready' goes high
  // (Make sure the oneshot module definition exists and works correctly)
  // Example placeholder if oneshot is not defined elsewhere:
  /*
  reg read_reg = 1'b0;
  reg scan_ready_dly = 1'b0;
  always @(posedge CLOCK_50 or posedge RST) begin // Use async reset if needed
      if (RST) begin
          read_reg <= 1'b0;
          scan_ready_dly <= 1'b0;
      end else begin
          scan_ready_dly <= scan_ready;
          if (scan_ready && !scan_ready_dly) begin
              read_reg <= 1'b1; // Pulse high for one clock
          end else begin
              read_reg <= 1'b0;
          end
      end
  end
  assign read = read_reg;
  */
   // If you have a specific 'oneshot' module, instantiate it here.
   // This example uses a simple edge detector and pulse generator.
   reg scan_ready_prev;
   always @(posedge CLOCK_50 or posedge RST) begin
       if (RST) begin
           scan_ready_prev <= 1'b0;
       end else begin
           scan_ready_prev <= scan_ready;
       end
   end
   assign read = scan_ready & ~scan_ready_prev; // Generate read pulse on rising edge of scan_ready


  // Assuming keyboard module definition exists
  keyboard kbd(
    .keyboard_clk(PS2_CLK),
    .keyboard_data(PS2_DAT),
    .clock50(CLOCK_50),
    .reset(RST),       // Connect to actual reset signal RST
    .read(read),
    .scan_ready(scan_ready),
    .scan_code(scan_code)
  );

  // Assuming hex_7seg module definition exists
  hex_7seg dsp0(history[1][3:0], HEX0);
  hex_7seg dsp1(history[1][7:4], HEX1);
  hex_7seg dsp2(history[2][3:0], HEX2);
  hex_7seg dsp3(history[2][7:4], HEX3);
  hex_7seg dsp4(history[3][3:0], HEX4);
  hex_7seg dsp5(history[3][7:4], HEX5);
  hex_7seg dsp6(history[4][3:0], HEX6);
  hex_7seg dsp7(history[4][7:4], HEX7);

  // Update history synchronously on CLOCK_50 when scan_ready is high
  always @(posedge CLOCK_50 or posedge RST) begin
    if (RST) begin
      history[1] <= 8'b0;
      history[2] <= 8'b0;
      history[3] <= 8'b0;
      history[4] <= 8'b0;
    end else if (scan_ready) begin // Check scan_ready signal level
      history[4] <= history[3];
      history[3] <= history[2];
      history[2] <= history[1];
      history[1] <= scan_code;
    end
  end

endmodule

//--------------------------------------------------------------------------
// Placeholder for the hex_7seg module (replace with your actual module)
//--------------------------------------------------------------------------
module hex_7seg (
    input      [3:0]  hex_digit,
    output reg [6:0]  segments // Active low segments common anode
);
    always @(*) begin
        case (hex_digit)
            4'h0: segments = 7'b1000000; // 0
            4'h1: segments = 7'b1111001; // 1
            4'h2: segments = 7'b0100100; // 2
            4'h3: segments = 7'b0110000; // 3
            4'h4: segments = 7'b0011001; // 4
            4'h5: segments = 7'b0010010; // 5
            4'h6: segments = 7'b0000010; // 6
            4'h7: segments = 7'b1111000; // 7
            4'h8: segments = 7'b0000000; // 8
            4'h9: segments = 7'b0010000; // 9
            4'ha: segments = 7'b0001000; // A
            4'hb: segments = 7'b0000011; // b
            4'hc: segments = 7'b1000110; // C
            4'hd: segments = 7'b0100001; // d
            4'he: segments = 7'b0000110; // E
            4'hf: segments = 7'b0001110; // F
            default: segments = 7'b1111111; // Off or error
        endcase
    end
endmodule

//--------------------------------------------------------------------------
// Placeholder for the keyboard module (replace with your actual module)
//--------------------------------------------------------------------------
module keyboard (
    input keyboard_clk,
    input keyboard_data,
    input clock50,
    input reset,
    input read, // Signal to read the scan_code buffer
    output reg scan_ready, // Indicates new scan code is available
    output reg [7:0] scan_code // Last valid scan code received
);

    // Internal state and registers for PS/2 receiver logic
    // This is a simplified placeholder - a real implementation is more complex
    reg [9:0] ps2_buffer = 0;
    reg [3:0] bit_count = 0;
    reg receiving = 0;
    reg received = 0;
    reg ps2_clk_sync1 = 1'b1;
    reg ps2_clk_sync2 = 1'b1;
    reg ps2_clk_sync3 = 1'b1;
    reg ps2_data_sync1 = 1'b1;
    reg ps2_data_sync2 = 1'b1;

    // Synchronize PS/2 signals to system clock
    always @(posedge clock50 or posedge reset) begin
        if (reset) begin
            ps2_clk_sync1 <= 1'b1;
            ps2_clk_sync2 <= 1'b1;
            ps2_clk_sync3 <= 1'b1;
            ps2_data_sync1 <= 1'b1;
            ps2_data_sync2 <= 1'b1;
        end else begin
            ps2_clk_sync1 <= keyboard_clk;
            ps2_clk_sync2 <= ps2_clk_sync1;
            ps2_clk_sync3 <= ps2_clk_sync2;
            ps2_data_sync1 <= keyboard_data;
            ps2_data_sync2 <= ps2_data_sync1;
        end
    end

    wire ps2_clk_negedge = ps2_clk_sync2 & ~ps2_clk_sync3; // Detect falling edge of synchronized PS/2 clock

    always @(posedge clock50 or posedge reset) begin
        if (reset) begin
            receiving <= 1'b0;
            received <= 1'b0;
            bit_count <= 4'd0;
            scan_ready <= 1'b0;
            scan_code <= 8'b0;
            ps2_buffer <= 10'b0;
        end else begin
            if (scan_ready && read) begin // Clear scan_ready when read
                scan_ready <= 1'b0;
            end

            if (ps2_clk_negedge) begin // Sample data on PS/2 clock falling edge
                if (!receiving && !ps2_data_sync2) begin // Start bit (0)
                    receiving <= 1'b1;
                    received <= 1'b0;
                    bit_count <= 4'd0;
                    ps2_buffer <= 10'b0; // Clear buffer for new data
                end else if (receiving) begin
                    if (bit_count < 8) begin // Data bits D0-D7
                        ps2_buffer[bit_count] <= ps2_data_sync2;
                        bit_count <= bit_count + 1;
                    end else if (bit_count == 8) begin // Parity bit
                        ps2_buffer[8] <= ps2_data_sync2; // Store parity
                        bit_count <= bit_count + 1;
                    end else if (bit_count == 9) begin // Stop bit (must be 1)
                        if (ps2_data_sync2) begin // Check stop bit
                           // Basic Parity check (odd parity for data bits) - can be enhanced
                           // wire parity_ok = (^ps2_buffer[7:0] != ps2_buffer[8]);
                           // if (parity_ok) begin
                                scan_code <= ps2_buffer[7:0];
                                scan_ready <= 1'b1; // Signal data ready
                                received <= 1'b1;
                           // end
                        end
                        // Else: Framing error (stop bit not 1)
                        receiving <= 1'b0; // End reception regardless of error for simplicity
                        bit_count <= 4'd0;
                    end
                end
            end // end if ps2_clk_negedge
        end // end else not reset
    end // end always

endmodule

//--------------------------------------------------------------------------
// Placeholder for the oneshot module (replace with your actual module if needed)
// This module is no longer directly used if the edge detector logic is used above.
//--------------------------------------------------------------------------
/*
module oneshot (
    input wire clk,
    input wire trigger_in,
    output reg pulse_out
);
    reg trigger_dly;

    always @(posedge clk) begin
        trigger_dly <= trigger_in;
        if (trigger_in && !trigger_dly) begin
            pulse_out <= 1'b1;
        end else begin
            pulse_out <= 1'b0;
        end
    end
endmodule
*/