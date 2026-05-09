module ps2_keyboard (
    output reg RESET_N,
    input CLK,
    input PS2_CLK,
    input PS2_DATA,
    output reg [7:0] RX_SCAN,
    output reg RX_PRESSED,
    output reg RX_EXTENDED
);

reg [7:0] shift_reg;
reg [3:0] bit_count;
reg ps2_clk_sync, ps2_clk_prev;

always @(posedge CLK) begin
    ps2_clk_sync <= PS2_CLK;
    ps2_clk_prev <= ps2_clk_sync;
end

always @(posedge CLK) begin
    if (!RESET_N) begin
        shift_reg <= 8'h00;
        bit_count <= 4'h0;
        RX_SCAN <= 8'h00;
        RX_PRESSED <= 1'b0;
        RX_EXTENDED <= 1'b0;
    end else begin
        if (ps2_clk_prev && !ps2_clk_sync) begin
            shift_reg <= {PS2_DATA, shift_reg[7:1]};
            bit_count <= bit_count + 1'b1;
            
            if (bit_count == 4'h8) begin
                RX_SCAN <= shift_reg;
                RX_PRESSED <= ~PS2_DATA;
                bit_count <= 4'h0;
            end
        end
    end
end

initial begin
    RESET_N = 1'b1;
end

endmodule