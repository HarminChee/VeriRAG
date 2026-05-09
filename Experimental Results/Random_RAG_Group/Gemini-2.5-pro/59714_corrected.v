module shift4(
    input wire clk,
    input wire rst_n,       // Added reset controlled by PI
    input wire test_mode,   // Added test_mode controlled by PI
    output reg [3:0] data
);
parameter NP = 21;
parameter INI = 1;

wire clk_pres;
reg load_shift = 0;
wire serin;

// Instantiate prescaler
// NOTE: The prescaler module itself must also be DFT compliant.
// Assuming it has a reset input.
prescaler #(.N(NP))
  pres1 (
    .clk_in(clk),
    .rst_n(rst_n), // Connect reset to prescaler
    .clk_out(clk_pres)
  );

// Muxed clock for FFs in this module
wire ff_clk;
assign ff_clk = test_mode ? clk : clk_pres; // Select primary clock in test mode

// Control logic FF (load_shift)
// Replicates original behavior: sets high on first clock edge after reset release
always @(posedge ff_clk or negedge rst_n) begin
    if (!rst_n) begin
        load_shift <= 1'b0; // Asynchronous reset
    end else begin
        // Set load_shift high on the first clock edge after reset release and keep it high.
        // This matches the original behavior where load_shift becomes 1 on the first clk_pres edge.
        load_shift <= 1'b1;
    end
end

// Data register FF (data)
// Replicates original behavior: Load INI on first clock edge, then shift.
always @(posedge ff_clk or negedge rst_n) begin
  if (!rst_n) begin
    data <= INI; // Asynchronous reset to initial value
  end else begin
    // Use the value of load_shift *before* the current clock edge to decide operation
    // This requires using a non-blocking assignment for load_shift update.
    // On the first clock edge after reset release, load_shift is still 0 (its value before the edge).
    // On subsequent edges, load_shift will be 1.
    if (load_shift == 1'b0) begin // Condition true for the first clock edge after reset release
        data <= INI; // Load INI
    end else begin // load_shift is 1 (from previous cycle)
        data <= {data[2:0], serin}; // Shift data
    end
  end
end

assign serin = data[3]; // Feedback path

endmodule