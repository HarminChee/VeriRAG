// Added prescaler module definition
module prescaler #(parameter N = 1) (
  input wire clk_in,
  output reg clk_out
);
  // Simple counter to create a slower clock signal
  // Toggles clk_out every N cycles of clk_in
  // Resulting clk_out period = 2 * N * clk_in period
  parameter CNT_WIDTH = $clog2(N);
  reg [CNT_WIDTH-1:0] count = 0;

  initial begin
    clk_out = 1'b0; // Initialize output clock
  end

  always @(posedge clk_in) begin
    if (count == N-1) begin
      count <= 0;
      clk_out <= ~clk_out; // Toggle output clock
    end else begin
      count <= count + 1;
    end
  end
endmodule


// Original module with corrections/adjustments if any (none needed in logic itself)
module reginit(input wire clk, output wire [3:0] data);
parameter NP = 23;        // Prescaler division factor (approx N)
parameter INI = 4'b1100;  // Initial value to load
wire clk_pres;            // Prescaled clock signal
reg [3:0] dout;           // Internal register holding the data
wire [3:0] din;           // Input to the internal register
reg sel;                  // Selection signal for initial load vs toggle

// Initialize sel to 0
initial begin
    sel = 1'b0;
    // Optional: Initialize dout to avoid X at time 0 before first clock
    // dout = 4'bxxxx; or dout = 4'b0000;
end

// Register updates on the prescaled clock edge
always @(posedge(clk_pres))
  dout <= din;

// Assign internal register value to the output port
assign data = dout;

// Combinational logic to determine the next value for the register
// Load INI on the first cycle (when sel is 0), then load inverted value
assign din = (sel == 0) ? INI : ~dout;

// Control logic for sel: set sel to 1 after the first prescaled clock edge
always @(posedge(clk_pres))
  sel <= 1'b1;

// Instantiate the prescaler
prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

endmodule