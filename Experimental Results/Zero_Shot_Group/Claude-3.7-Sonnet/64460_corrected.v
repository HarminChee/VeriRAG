module mux4(
    input wire clk, 
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

    assign val0 = VAL0;
    assign val1 = VAL1;
    assign val2 = VAL2;
    assign val3 = VAL3;

    always @(*) 
    begin
        case (sel)
            2'b00 : data <= val0;
            2'b01 : data <= val1;
            2'b10 : data <= val2;
            2'b11 : data <= val3;
            default : data <= 4'b0000;
        endcase
    end

    always @(posedge clk_pres) 
    begin
        count <= count + 1;
    end

    assign sel = count;

    prescaler #(.N(NP)) PRES (
        .clk_in(clk),
        .clk_out(clk_pres)
    );

endmodule

module prescaler(
    input wire clk_in,
    output reg clk_out
);
    parameter N = 23;
    reg [31:0] count = 0;

    always @(posedge clk_in) begin
        if (count == N-1) begin
            count <= 0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1;
        end
    end

endmodule