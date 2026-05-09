module blink (
  input clk_12MHz,
  // Added DFT ports
  input test_mode_i,
  input test_clk_i,
  input test_rst_i, // Assuming active-high test reset
  output [4:0] LED);

  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;

  wire rdy, err;
  wire [HI:0] res;
  reg go;
  reg [31:0] clk_count;
  reg blink;
  wire rst;
  wire por_rst;
  wire clk;
  wire clk_rdy;
  wire dft_clk; // Muxed clock for FFs
  wire dft_rst; // Muxed reset for FFs

  localparam F = 16;

  // Instantiate clock generator (functional path)
  clk_gen #(.F(F)) clk_gen_inst (.clk_12MHz(clk_12MHz), .clk(clk), .ready(clk_rdy));

  // Instantiate power-on reset (functional path)
  por por_inst(.clk(clk), .rst(por_rst));

  // Functional reset logic
  assign rst = por_rst || !clk_rdy;

  // DFT Clock Mux for top-level FFs
  assign dft_clk = test_mode_i ? test_clk_i : clk;

  // DFT Reset Mux for top-level FFs (synchronous reset check)
  assign dft_rst = test_mode_i ? test_rst_i : rst;

  // Instantiate primogen (using functional clock/reset)
  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(clk),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res));

  localparam BLINK_COUNT = F * 1000000 * 5;

  // Blink counter logic - Use DFT clock and DFT reset
  always @(posedge dft_clk) begin // Use DFT clock
    if (dft_rst) begin           // Use DFT reset signal for synchronous reset check
      blink <= 1'b0;
      clk_count <= 32'b0;
    end else begin
      if (clk_count == BLINK_COUNT) begin
        blink <= 1'b1;
        clk_count <= 32'b0;
      end else begin
        blink <= 1'b0;
        clk_count <= clk_count + 1'd1;
      end
    end
  end

  // Go signal logic - Use DFT clock and DFT reset
  always @(posedge dft_clk) begin // Use DFT clock
    if (dft_rst) begin           // Use DFT reset signal for synchronous reset check
      go <= 1'b0;
    end else begin
      // Original logic structure
      go <= 1'b0;
      if (rdy && !err && !go && blink) begin
        go <= 1'b1;
      end
    end
  end

  // Assign outputs
  assign LED[3:0] = res[3:0];
  assign LED[4] = err;

endmodule