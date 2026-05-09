module mux4(input wire clk, output reg [3:0] data);
  parameter NP = 23;
  parameter VAL0 = 4'b0000;
  parameter VAL1 = 4'b1010;
  parameter VAL2 = 4'b1111;
  parameter VAL3 = 4'b0101;

  wire [1:0] sel;
  reg  [1:0] count = 2'b00; // Initial value specified
  wire clk_pres;

  // Combinational logic for the MUX
  // Use blocking assignments (=) inside combinational always block
  always @* begin
    case (sel)
      2'b00 : data = VAL0;
      2'b01 : data = VAL1;
      2'b10 : data = VAL2;
      2'b11 : data = VAL3;
      default : data = 4'b0000; // Assign a default value
    endcase
  end

  // Sequential logic for the counter
  // Use non-blocking assignments (<=) inside sequential always block
  always @(posedge clk_pres) begin
    count <= count + 1;
  end

  // Connect counter output to select signal
  assign sel = count;

  // Instantiate the prescaler (assuming 'prescaler' module is defined elsewhere)
  // Make sure the prescaler module definition exists in your project.
  prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

endmodule

// Note: The 'prescaler' module needs to be defined elsewhere for this code to compile and work.
// Example placeholder for prescaler:
/*
module prescaler #(parameter N = 23) (
    input wire clk_in,
    output reg clk_out
);
    reg [$clog2(N)-1:0] count = 0;
    parameter MAX_COUNT = N-1;

    always @(posedge clk_in) begin
        if (count == MAX_COUNT) begin
            count <= 0;
            clk_out <= ~clk_out; // Toggle output clock
        end else begin
            count <= count + 1;
        end
    end

    initial begin
        clk_out = 1'b0; // Initialize output clock
    end
endmodule
*/