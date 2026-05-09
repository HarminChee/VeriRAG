module blink (
  input clk_12MHz,
  input rst_n, // Added primary asynchronous reset (active low)
  input test_mode, // Added test mode signal
  output [4:0] LED);

  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;

  wire rdy, err;
  wire [HI:0] res;
  reg go;
  reg [31:0] clk_count;
  reg blink;

  // Internal signals
  wire func_rst; // Functional reset (active high)
  wire por_rst;
  wire clk;
  wire clk_rdy;
  localparam F = 16;

  // DFT signals
  wire dft_clk;
  wire dft_rst; // Active high reset for modules needing it

  // Clock Generation - Assuming rst_n resets the generator
  clk_gen #(.F(F)) clk_gen_inst (
    .clk_12MHz(clk_12MHz),
    // .rst_n(rst_n), // Assuming clk_gen has an async reset input
    .clk(clk),
    .ready(clk_rdy)
  );

  // Power-on Reset Generation - Clocked by dft_clk, reset by rst_n
  // Assuming por module has active low reset input rst_n
  por por_inst(
    .clk(dft_clk), // Use testable clock
    .rst_n(rst_n), // Use primary reset
    .por_rst(por_rst) // Output functional POR
  );

  // Functional Reset Logic (Original) - Active High
  assign func_rst = por_rst || !clk_rdy;

  // DFT Clock Mux: Selects primary clock in test mode
  assign dft_clk = test_mode ? clk_12MHz : clk;

  // DFT Reset for modules needing active high reset: Selects primary reset (inverted) in test mode
  assign dft_rst = test_mode ? !rst_n : func_rst;

  // Primogen Instance - Use DFT clock and reset
  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(dft_clk),
    .go(go),
    .rst(dft_rst), // Use muxed reset (active high)
    .ready(rdy),
    .error(err),
    .res(res)
  );

  localparam BLINK_COUNT = F * 1000000 * 5;

  // Blink counter logic - Use DFT clock and primary reset
  always @(posedge dft_clk or negedge rst_n) begin
    if (!rst_n) begin // Primary asynchronous reset (active low)
      blink <= 1'b0;
      clk_count <= 32'd0;
    // Optional: include functional reset only when not in test mode
    // else if (!test_mode && func_rst) begin // Functional asynchronous reset (active high)
    //   blink <= 1'b0;
    //   clk_count <= 32'd0;
    // end
    end else begin // Clocked logic
      if (clk_count == BLINK_COUNT) begin
        blink <= 1'b1;
        clk_count <= 32'd0;
      end else begin
        blink <= 1'b0;
        clk_count <= clk_count + 1'd1;
      end
    end
  end

  // Go signal logic - Use DFT clock and primary reset
  always @(posedge dft_clk or negedge rst_n) begin
    if (!rst_n) begin // Primary asynchronous reset (active low)
      go <= 1'b0;
    // Optional: include functional reset only when not in test mode
    // else if (!test_mode && func_rst) begin // Functional asynchronous reset (active high)
    //   go <= 1'b0;
    // end
    end else begin // Clocked logic
      go <= 1'b0; // Default assignment
      if (rdy && !err && !go && blink) begin
        go <= 1'b1;
      end
    end
  end

  assign LED[3:0] = res[3:0];
  assign LED[4] = err;

endmodule

// Note: Assumed clk_gen and por modules exist and have interfaces
// compatible with the connections (e.g., reset polarity).
// If clk_gen or por do not have reset inputs, their internal state
// might not be controllable during test, potentially reducing coverage.
// The handling of the functional reset 'func_rst' during normal operation
// might need further refinement based on specific requirements, but the
// DFT violations (ACNCPI, CLKNPI) related to test controllability
// are addressed by muxing the clock and using the primary reset in test mode.

// Placeholder for clk_gen module if needed for completeness
// module clk_gen #(parameter F=16) (input clk_12MHz, output clk, output ready /*, input rst_n */);
//   // Internal logic to generate clk and ready based on clk_12MHz
//   assign clk = clk_12MHz; // Simplistic example
//   assign ready = 1'b1;    // Simplistic example
// endmodule

// Placeholder for por module if needed for completeness
// module por (input clk, input rst_n, output reg por_rst);
//   // Internal logic for power-on reset generation
//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) por_rst <= 1'b1; // Assert reset on primary reset
//     // Add logic to deassert por_rst after some cycles
//     else por_rst <= 1'b0; // Simplistic example
//   end
// endmodule

// Placeholder for primogen module if needed for completeness
// module primogen #(parameter WIDTH_LOG=4) (input clk, input go, input rst, output ready, output error, output [ (1<<WIDTH_LOG)-1 : 0 ] res);
//   // Internal logic
//   assign ready = 1'b0; // Simplistic example
//   assign error = 1'b0; // Simplistic example
//   assign res = 0;      // Simplistic example
// endmodule