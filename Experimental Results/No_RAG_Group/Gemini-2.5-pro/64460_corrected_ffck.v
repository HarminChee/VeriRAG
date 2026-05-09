module mux4_corrected_ffc (
    input wire clk,
    output reg [3:0] data
);
    parameter NP = 23;
    // Check if NP is valid (must be >= 1)
    initial begin
        if (NP < 1) begin
            $display("Error: Parameter NP must be >= 1. Found NP = %d", NP);
            $finish;
        end
    end

    parameter VAL0 = 4'b0000;
    parameter VAL1 = 4'b1010;
    parameter VAL2 = 4'b1111;
    parameter VAL3 = 4'b0101;

    // Use localparam for constants derived from parameters
    localparam [3:0] LVAL0 = VAL0;
    localparam [3:0] LVAL1 = VAL1;
    localparam [3:0] LVAL2 = VAL2;
    localparam [3:0] LVAL3 = VAL3;

    // Calculate width needed for the enable counter
    // Handle NP=1 case correctly for $clog2 which returns 0
    localparam CNT_WIDTH = (NP <= 1) ? 1 : $clog2(NP);

    reg [1:0] count = 2'b00; // Counter for mux select
    wire [1:0] sel;          // Mux select signal

    reg [CNT_WIDTH-1:0] enable_counter = 0; // Counter to generate enable
    reg count_enable = 1'b0;                // Enable signal for 'count' register

    // Clock enable generation logic: Generate a 1-cycle pulse every NP cycles
    // All sequential logic uses the primary clock 'clk'
    always @(posedge clk) begin
        if (enable_counter == NP - 1) begin
            enable_counter <= 0;
            count_enable <= 1'b1; // Assert enable for one clock cycle
        end else begin
            enable_counter <= enable_counter + 1;
            count_enable <= 1'b0; // Deassert enable otherwise
        end
    end

    // Counter logic for 'sel': Increments only when 'count_enable' is high
    // Clocked by the primary clock 'clk'
    always @(posedge clk) begin
        if (count_enable) begin
            count <= count + 1;
        end
        // No else needed, 'count' holds its value if not enabled
    end

    assign sel = count; // Connect counter output to mux select

    // Combinational logic for the 4-to-1 multiplexer
    // Output 'data' is assigned combinationally based on 'sel'
    always @* begin
        case (sel)
            2'b00 : data = LVAL0; // Use blocking assignments for combinational logic
            2'b01 : data = LVAL1;
            2'b10 : data = LVAL2;
            2'b11 : data = LVAL3;
            default : data = 4'b0000; // Default assignment for completeness
        endcase
    end

endmodule