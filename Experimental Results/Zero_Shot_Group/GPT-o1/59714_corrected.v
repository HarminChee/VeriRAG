module prescaler #(parameter N = 21)(
    input  wire clk_in,
    output reg  clk_out
);
    reg [N-1:0] count = 0;
    always @(posedge clk_in) begin
        count <= count + 1;
        if (count == 0) clk_out <= ~clk_out;
    end
endmodule

module shift4(
    input  wire clk,
    output reg  [3:0] data
);
    parameter NP  = 21;
    parameter INI = 4'b0001;
    wire clk_pres;
    reg load_shift = 0;
    wire serin;

    prescaler #(.N(NP)) pres1 (
        .clk_in(clk),
        .clk_out(clk_pres)
    );

    always @(posedge clk_pres) begin
        load_shift <= 1;
    end

    always @(posedge clk_pres) begin
        if (load_shift == 0)
            data <= INI;
        else
            data <= {data[2:0], serin};
    end

    assign serin = data[3];
endmodule