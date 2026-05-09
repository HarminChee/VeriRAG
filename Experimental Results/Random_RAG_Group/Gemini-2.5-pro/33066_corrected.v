module bench (
  input clk_12MHz,
  input test_i,      // DFT control signal (test mode enable)
  input test_clk,    // DFT test clock
  input test_rst,    // DFT test reset (active high)
  output reg [4:0] LED);
  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;
  wire rdy, err;
  wire [HI:0] res;
  reg go;
  reg [HI:0] prime;
  reg [15:0] count;
  wire rst;
  wire por_rst;
  wire clk_rdy;
  wire clk;
  localparam F = 16;

  // DFT signals
  wire dft_clk;
  wire dft_rst; // Combined functional and test reset

  clk_gen #(.F(F)) clk_gen_inst (.clk_12MHz(clk_12MHz), .clk(clk), .ready(clk_rdy));

  // DFT clock mux
  assign dft_clk = test_i ? test_clk : clk;

  // Instantiate POR with the potentially muxed clock
  // Assuming POR should run off the selected clock domain. Reset logic inside POR might need DFT review.
  por por_inst(.clk(dft_clk), .rst(por_rst));

  // Functional reset logic
  assign rst = por_rst || !clk_rdy;

  // DFT reset logic: Use test reset in test mode, otherwise functional reset
  // This assumes test_rst is active high, matching the active-high usage of rst below.
  assign dft_rst = test_i ? test_rst : rst;

  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(dft_clk), // Use DFT clock
    .go(go),
    .rst(dft_rst), // Use DFT reset
    .ready(rdy),
    .error(err),
    .res(res));

  // Process for go, prime, count registers
  always @(posedge dft_clk or posedge dft_rst) begin // Sensitivity to DFT clock and async DFT reset
    if (dft_rst) begin // Use DFT reset
      go <= 1'b0;
      prime <= {W{1'b0}}; // Use parameter W for width
      count <= 16'b0;
    end else begin
      // Functional logic driven by DFT clock
      go <= 1'b0; // This assignment seems to override the conditional one below. Preserving original logic.
      if (rdy && !err && !go) begin
        go <= 1'b1;
        prime <= res;
        count <= count + 1'd1;
      end
      // If the condition is false, 'go' retains the 1'b0 assigned earlier in the else block.
    end
  end

  // Process for LED register
  always @(posedge dft_clk or posedge dft_rst) begin // Sensitivity to DFT clock and async DFT reset
    if (dft_rst) begin // Use DFT reset
      LED <= 5'b0;
    end else begin
      // Functional logic driven by DFT clock
      LED[4] <= err;
      if (!err && res > {LED[3:0], {(W-4){1'd1}}}) begin // Use parameter W
        LED[3:0] <= LED[3:0] + 1'd1;
      end
      // If the condition is false, LED[3:0] hold their previous value. LED[4] is always assigned.
    end
  end
endmodule