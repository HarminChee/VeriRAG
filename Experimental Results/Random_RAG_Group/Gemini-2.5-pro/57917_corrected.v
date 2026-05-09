module mux4(
    input wire clk,
    // DFT inputs
    input wire rst_n,     // Asynchronous reset
    input wire test_mode, // Test mode enable
    output reg [3:0] data
);
parameter NP = 23;
parameter VAL0 = 4'b0000;
parameter VAL1 = 4'b1010;
parameter VAL2 = 4'b1111;
parameter VAL3 = 4'b0101;

wire [3:0] val0;
wire [3:0] val1;
wire [3:0] val2;
wire [3:0] val3;
wire [1:0] sel;
reg [1:0] count = 0;
wire clk_pres;
wire count_enable; // Enable signal for functional counting

assign val0 = VAL0;
assign val1 = VAL1;
assign val2 = VAL2;
assign val3 = VAL3;

// Combinational logic for output mux
always@* begin // Changed sensitivity list to '*' for combinational logic
  case (sel)
     2'b00 : data = val0; // Use explicit bit-width
     2'b01 : data = val1;
     2'b10 : data = val2;
     2'b11 : data = val3;
     default : data = 4'b0000; // Use explicit bit-width
  endcase
end

// Generate enable signal based on rising edge of clk_pres during functional mode
reg clk_pres_dly;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_pres_dly <= 1'b0;
    end else begin
        clk_pres_dly <= clk_pres;
    end
end
// Enable is active for one 'clk' cycle after clk_pres rises, only in functional mode
assign count_enable = !test_mode && clk_pres && !clk_pres_dly;

// Counter logic - now clocked by primary clock 'clk' and reset by 'rst_n'
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    count <= 2'b0;
  // During test mode, count behaves as a standard scan flop (update controlled by scan enable, not shown here but implied)
  // During functional mode, count increments only when count_enable is high.
  end else if (count_enable) begin // Functional increment condition
    count <= count + 1;
  end
  // Note: For actual scan chain insertion, DFT tools would modify this FF description
  // or replace it with a scan equivalent cell. The key DFT requirements are
  // using the main clock (clk) and having a controllable reset (rst_n).
end

// Select signal driven by the counter
assign sel = count;

// Instantiate the prescaler (unchanged, assuming it's DFT-clean or handled separately)
// The prescaler itself would need DFT modifications (reset, scan chain for internal FFs)
prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
    // Assuming prescaler also needs rst_n if it contains state elements
    // .rst_n(rst_n) // Example if prescaler needs reset
  );

endmodule