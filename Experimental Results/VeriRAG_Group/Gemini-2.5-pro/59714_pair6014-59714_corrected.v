module shift4(
  input wire clk,
  input wire test_clk, // Added test clock input
  input wire test_i,   // Added test mode input
  output reg [3:0] data
);
  parameter NP = 21;
  parameter INI = 1;

  wire clk_pres;
  reg load_shift = 0;
  wire serin;

  // Instantiate prescaler (unchanged)
  prescaler #(.N(NP))
    pres1 (
      .clk_in(clk),
      .clk_out(clk_pres)
    );

  // DFT Clock Mux
  wire dft_clk;
  assign dft_clk = test_i ? test_clk : clk_pres; // Select test clock in test mode

  // Modified always block for load_shift
  always @(posedge(dft_clk)) begin // Use multiplexed clock
      load_shift <= 1;
  end

  // Modified always block for data
  always @(posedge(dft_clk)) begin // Use multiplexed clock
    if (load_shift == 0)
      data <= INI;
    else
      data <= {data[2:0], serin};
  end

  assign serin = data[3];

endmodule