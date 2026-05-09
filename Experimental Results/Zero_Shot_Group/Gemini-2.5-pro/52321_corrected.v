`timescale 1ns / 1ps

module mccomp (
    input wire stp,
    input wire rst,
    input wire clk,
    input wire [1:0] dptype,
    input wire [4:0] regselect,
    output wire exec,
    output wire [5:0] initype,
    output wire [3:0] node,
    output wire [7:0] segment
);

    wire clock;
    wire reset;
    wire resetn;
    wire mem_clk;
    wire [31:0] a, b, alu, adr, tom, fromm, pc, ir, dpdata;
    wire [2:0] q;
    reg [15:0] digit; // Changed to reg for sequential assignment
    reg [15:0] count = 0;
    wire wmem;

    // Debounce inputs
    // Assuming pbdebounce module exists elsewhere
    pbdebounce p0 (
        .clk_in(clk),
        .button_in(stp),
        .signal_out(clock)
    );

    pbdebounce p1 (
        .clk_in(clk),
        .button_in(rst),
        .signal_out(reset)
    );

    // Generate active low reset
    assign resetn = ~reset;

    // Assign memory clock (can be different from main clock if needed)
    assign mem_clk = clock; // Using debounced clock

    // Instantiate CPU
    // Assuming mccpu module exists elsewhere
    mccpu mc_cpu (
        .clk(clock),
        .resetn(resetn),
        .fromm(fromm),
        .pc(pc),
        .ir(ir),
        .a(a),
        .b(b),
        .alu(alu),
        .wmem(wmem),
        .adr(adr),
        .tom(tom),
        .q(q),
        .regselect(regselect),
        .dpdata(dpdata)
    );

    // Instantiate Memory
    // Assuming mcmem module exists elsewhere
    mcmem memory (
        .adr(adr[7:2]), // Assuming address mapping
        .din(tom),
        .clk(mem_clk),
        .we(wmem),
        .dout(fromm)
    );

    // Instantiate Display Driver
    // Assuming display module exists elsewhere and drives node/segment outputs
    display dp (
        .clk(clock),
        .digit(digit), // Connect registered digit
        .node(node),     // Connect directly to module output
        .segment(segment) // Connect directly to module output
    );

    // Counter for display option
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            count <= 16'b0;
        end else begin
            count <= count + 1;
        end
    end

    // Logic to select data source for display
    // Changed to sequential logic (registered output)
    always @(posedge clock) begin
        case (dptype)
            2'b00: digit <= dpdata[15:0];
            2'b01: digit <= dpdata[31:16];
            2'b10: digit <= pc[15:0];
            2'b11: digit <= count;
            default: digit <= 16'hXXXX; // Default case
        endcase
    end

    // Assign outputs
    assign exec = clock; // Example: maybe reflects clock activity
    assign initype = ir[31:26]; // Instruction type/opcode field

endmodule

// Note: The definitions for pbdebounce, mccpu, mcmem, and display
// modules are assumed to exist in separate files or elsewhere in the project.
// Make sure the port names and widths match the actual module definitions.