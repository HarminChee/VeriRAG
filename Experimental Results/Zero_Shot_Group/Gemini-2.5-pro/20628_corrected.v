module LED2Spartan3StarterKit(
    CLK50MHZ,
    SOCKET,
    SRAM_A,
    SRAM_WE_X,
    SRAM_OE_X,
    SRAM_IO_A,
    SRAM_CE_A_X,
    SRAM_LB_A_X,
    SRAM_UB_A_X,
    SRAM_IO_B,
    SRAM_CE_B_X,
    SRAM_LB_B_X,
    SRAM_UB_B_X,
    LED_AN,
    LED_A,
    LED_B,
    LED_C,
    LED_D,
    LED_E,
    LED_F,
    LED_G,
    LED_DP,
    SW,
    BTN,
    LD,
    VGA_R,
    VGA_G,
    VGA_B,
    VGA_HS,
    VGA_VS,
    PS2C,
    PS2D,
    RXD,
    TXD,
    RXDA,
    TXDA,
    DIN,
    INIT_B,
    RCLK);
  input         CLK50MHZ;
  input         SOCKET;
  output [17:0] SRAM_A;
  output        SRAM_WE_X;
  output        SRAM_OE_X;
  inout  [15:0] SRAM_IO_A;
  output        SRAM_CE_A_X;
  output        SRAM_LB_A_X;
  output        SRAM_UB_A_X;
  inout  [15:0] SRAM_IO_B;
  output        SRAM_CE_B_X;
  output        SRAM_LB_B_X;
  output        SRAM_UB_B_X;
  output [ 3:0] LED_AN;
  output        LED_A;
  output        LED_B;
  output        LED_C;
  output        LED_D;
  output        LED_E;
  output        LED_F;
  output        LED_G;
  output        LED_DP;
  input  [ 7:0] SW;
  input  [ 3:0] BTN;
  output [ 7:0] LD;
  output        VGA_R;
  output        VGA_G;
  output        VGA_B;
  output        VGA_HS;
  output        VGA_VS;
  input         PS2C;
  input         PS2D;
  input         RXD;
  output        TXD;
  input         RXDA;
  output        TXDA;
  input         DIN;
  output        INIT_B;
  output        RCLK;

  wire          clk;
  wire          rst_x;
  wire   [ 3:0] w_data0;
  wire   [ 3:0] w_data1;
  wire   [ 3:0] w_data2;
  wire   [ 3:0] w_data3;
  wire          w_dp0;
  wire          w_dp1;
  wire          w_dp2;
  wire          w_dp3;
  wire          w_clk3hz;
  // wire          w_clk49khz; // Not directly used for LED driver anymore

  reg    [24:0] r_clock;
  reg    [ 3:0] r_count;

  // Default assignments for unused or static outputs
  assign SRAM_A      = 18'h00000;
  assign SRAM_WE_X   = 1'b1; // Keep inactive
  assign SRAM_OE_X   = 1'b1; // Keep inactive
  assign SRAM_IO_A   = 16'hzzzz; // High-Z for inout
  assign SRAM_CE_A_X = 1'b1; // Keep inactive
  assign SRAM_LB_A_X = 1'b1; // Keep inactive
  assign SRAM_UB_A_X = 1'b1; // Keep inactive
  assign SRAM_IO_B   = 16'hzzzz; // High-Z for inout
  assign SRAM_CE_B_X = 1'b1; // Keep inactive
  assign SRAM_LB_B_X = 1'b1; // Keep inactive
  assign SRAM_UB_B_X = 1'b1; // Keep inactive
  assign LD          = SW | { 1'b0, BTN[2:0], PS2D, PS2C, SOCKET }; // Use BTN[3] for reset
  assign VGA_R       = 1'b0;
  assign VGA_G       = 1'b0;
  assign VGA_B       = 1'b0;
  assign VGA_HS      = 1'b1;
  assign VGA_VS      = 1'b1;
  assign TXD         = RXD;
  assign TXDA        = RXDA;
  assign INIT_B      = DIN;
  assign RCLK        = DIN;

  // Clock and Reset
  assign clk         = CLK50MHZ;
  assign rst_x       = !BTN[3]; // Active low reset from BTN[3]

  // Clock divider
  always @ (posedge clk or negedge rst_x) begin
    if (!rst_x) begin
      r_clock <= 25'h0000000;
    end else begin
      r_clock <= r_clock + 25'h0000001;
    end
  end

  // Slow clock generation (approx 3Hz)
  assign w_clk3hz    = r_clock[23]; // 50MHz / 2^24 = ~3Hz

  // Counter logic (counts 0-F repeatedly)
  always @ (posedge w_clk3hz or negedge rst_x) begin
    if (!rst_x) begin
      r_count <= 4'h0;
    end else begin
      r_count <= r_count + 4'h1;
    end
  end

  // Data for each digit (showing count N, N+1, N+2, N+3)
  assign w_data0     = r_count;
  assign w_data1     = r_count + 4'h1;
  assign w_data2     = r_count + 4'h2;
  assign w_data3     = r_count + 4'h3;

  // Decimal point logic (example: DP on if digit position matches lower 2 bits of count)
  assign w_dp0       = r_count[1:0] == 2'b00;
  assign w_dp1       = r_count[1:0] == 2'b01;
  assign w_dp2       = r_count[1:0] == 2'b10;
  assign w_dp3       = r_count[1:0] == 2'b11;

  //------------------------------------------------------------------
  // 7-Segment Display Driver Logic
  //------------------------------------------------------------------
  reg [1:0]  scan_cnt; // Counter to select which digit to display
  reg [3:0]  digit_data_mux; // Muxed data for the selected digit
  reg        digit_dp_mux;   // Muxed DP for the selected digit
  wire [6:0] segments;       // Segment data (A-G)
  reg [3:0]  anodes;         // Anode control (active low)

  // Combinational 7-segment decoder (Hex to 7-seg, common anode)
  // Output is active low: 0 = segment ON, 1 = segment OFF
  // Segments: A, B, C, D, E, F, G
  function [6:0] seven_seg_decoder (input [3:0] data);
    case (data)
      4'h0: seven_seg_decoder = 7'b1000000; // 0 - Corrected Common Anode
      4'h1: seven_seg_decoder = 7'b1111001; // 1
      4'h2: seven_seg_decoder = 7'b0100100; // 2
      4'h3: seven_seg_decoder = 7'b0110000; // 3
      4'h4: seven_seg_decoder = 7'b0011001; // 4
      4'h5: seven_seg_decoder = 7'b0010010; // 5
      4'h6: seven_seg_decoder = 7'b0000010; // 6
      4'h7: seven_seg_decoder = 7'b1111000; // 7
      4'h8: seven_seg_decoder = 7'b0000000; // 8
      4'h9: seven_seg_decoder = 7'b0010000; // 9
      4'hA: seven_seg_decoder = 7'b0001000; // A
      4'hB: seven_seg_decoder = 7'b0000011; // b
      4'hC: seven_seg_decoder = 7'b1000110; // C
      4'hD: seven_seg_decoder = 7'b0100001; // d
      4'hE: seven_seg_decoder = 7'b0000110; // E
      4'hF: seven_seg_decoder = 7'b0001110; // F
      default: seven_seg_decoder = 7'b1111111; // Off
    endcase
  endfunction

  // Scan counter for multiplexing - Use medium frequency bits from r_clock
  // r_clock[17:16] gives approx 763 Hz refresh rate per digit (50MHz / 2^18 cycle)
  always @(posedge clk or negedge rst_x) begin
    if (!rst_x) begin
      scan_cnt <= 2'b00;
    end else begin
      scan_cnt <= r_clock[17:16];
    end
  end

  // Multiplexer for data, DP, and Anodes based on scan_cnt
  always @(*) begin // Combinational block
    case (scan_cnt)
      2'b00: begin
        digit_data_mux = w_data0;
        digit_dp_mux   = w_dp0;
        anodes         = 4'b1110; // Select digit 0 (AN0 low)
      end
      2'b01: begin
        digit_data_mux = w_data1;
        digit_dp_mux   = w_dp1;
        anodes         = 4'b1101; // Select digit 1 (AN1 low)
      end
      2'b10: begin
        digit_data_mux = w_data2;
        digit_dp_mux   = w_dp2;
        anodes         = 4'b1011; // Select digit 2 (AN2 low)
      end
      2'b11: begin
        digit_data_mux = w_data3;
        digit_dp_mux   = w_dp3;
        anodes         = 4'b0111; // Select digit 3 (AN3 low)
      end
      default: begin // Should not happen
        digit_data_mux = 4'hF; // Display F
        digit_dp_mux   = 1'b0; // DP off
        anodes         = 4'b1111; // All digits off
      end
    endcase
  end

  // Decode selected digit data to segments
  assign segments = seven_seg_decoder(digit_data_mux);

  // Assign outputs to the physical LEDs
  assign LED_AN = anodes;
  assign {LED_G, LED_F, LED_E, LED_D, LED_C, LED_B, LED_A} = segments; // Assign segments A-G
  assign LED_DP = ~digit_dp_mux; // DP is active low (0=on)

endmodule