`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module debounce_switch  #(
    parameter WIDTH=1, 
    parameter N=3, 
    parameter RATE=125000 
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);
reg [23:0] cnt_reg = 24'd0;
reg [N-1:0] debounce_reg[WIDTH-1:0];
reg [WIDTH-1:0] state;
assign out = state;
integer k;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cnt_reg <= 0;
        state <= 0;
        for (k = 0; k < WIDTH; k = k + 1) begin
            debounce_reg[k] <= 0;
        end
    end else begin
        if (cnt_reg < RATE) begin
            cnt_reg <= cnt_reg + 24'd1;
        end else begin
            cnt_reg <= 24'd0;
        end
        if (cnt_reg == 24'd0) begin
            for (k = 0; k < WIDTH; k = k + 1) begin
                debounce_reg[k] <= {debounce_reg[k][N-2:0], in[k]};
            end
        end
        for (k = 0; k < WIDTH; k = k + 1) begin
            if (|debounce_reg[k] == 0) begin
                state[k] <= 0;
            end else if (&debounce_reg[k] == 1) begin
                state[k] <= 1;
            end else begin
                state[k] <= state[k];
            end
        end
    end
end
endmodule
