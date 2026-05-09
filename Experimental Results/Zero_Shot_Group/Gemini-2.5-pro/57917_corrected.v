module mux4(input wire clk, output reg [3:0] data);
  parameter NP = 23;
  parameter VAL0 = 4'b0000;
  parameter VAL1 = 4'b1010;
  parameter VAL2 = 4'b1111;
  parameter VAL3 = 4'b0101;

  // Wires for constant values can be directly used or assigned as below
  wire [3:0] val0 = VAL0;
  wire [3:0] val1 = VAL1;
  wire [3:0] val2 = VAL2;
  wire [3:0] val3 = VAL3;

  // Internal signals
  reg [1:0] count = 2'b00; // Initial value often used in simulation/test
  wire [1:0] sel;
  wire clk_pres;

  // Assign select lines based on counter
  assign sel = count;

  // Combinational logic for the multiplexer
  // Use blocking assignment (=) in combinational always block
  always @* begin // Use begin/end for clarity, especially with multiple statements
    case (sel)
      2'b00: data = val0;
      2'b01: data = val1;
      2'b10: data = val2;
      2'b11: data = val3;
      default: data = 4'b0000; // Default assignment recommended
    endcase
  end

  // Sequential logic for the counter
  // Use non-blocking assignment (<=) in sequential always block
  always @(posedge clk_pres) begin // Use begin/end for clarity
    count <= count + 1;
  end

  // Instantiate the prescaler (assuming it's defined elsewhere)
  // The definition of 'prescaler' module is required for this code to work.
  prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

endmodule