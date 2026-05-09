// Prescaler module (assuming this was intended but missing)
// Provides a slower clock (clk_out) derived from clk_in
module prescaler #(parameter N = 1) (
    input wire clk_in,
    output reg clk_out
);
    // Ensure N is at least 1 to avoid issues with $clog2(0) or zero width counter
    localparam COUNT_WIDTH = (N < 2) ? 1 : $clog2(N);
    reg [COUNT_WIDTH-1:0] count = 0;

    // Initialize clk_out to known state
    initial clk_out = 1'b0;

    always @(posedge clk_in) begin
        if (count == N - 1) begin
            count <= 0;
            clk_out <= ~clk_out; // Toggle output clock
        end else begin
            count <= count + 1;
        end
    end
endmodule


// Corrected shift4 module
module shift4 (
    input wire clk,
    input wire rst_n, // Added active-low reset input
    output reg [3:0] data
);
    parameter NP = 21;
    // Explicitly define INI as 4 bits for clarity
    parameter INI = 4'b0001;

    wire clk_pres;
    wire serin;

    // Instantiate Prescaler
    // Check if NP is valid for the prescaler implementation (e.g., >= 1)
    prescaler #(.N(NP)) pres1 (
        .clk_in(clk),
        .clk_out(clk_pres)
    );

    // Feedback wire for shift operation (ring counter style)
    assign serin = data[3];

    // Shift register logic with synchronous active-low reset
    always @(posedge clk_pres or negedge rst_n) begin
        if (!rst_n) begin // Reset condition
            data <= INI; // Load initial value on reset
        end else begin
            // Shift operation: LSB gets serin, other bits shift left
            data <= {data[2:0], serin};
        end
    end

endmodule