module ps2_keyboard (
    input   RESET_N,
    input   CLK,
    input   PS2_CLK,
    input   PS2_DATA,
    output  reg RX_SCAN,
    output  reg RX_PRESSED,
    output  reg RX_EXTENDED,
    input   test_i
);

reg [7:0] ps2_data_reg;
reg [3:0] bit_count;
reg ps2_clk_sync1, ps2_clk_sync2;
wire ps2_clk_negedge;

always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N) begin
        ps2_clk_sync1 <= 1'b1;
        ps2_clk_sync2 <= 1'b1;
    end else begin
        ps2_clk_sync1 <= PS2_CLK;
        ps2_clk_sync2 <= ps2_clk_sync1;
    end
end

assign ps2_clk_negedge = ps2_clk_sync2 & ~ps2_clk_sync1;

always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N) begin
        bit_count <= 4'd0;
        ps2_data_reg <= 8'd0;
        RX_SCAN <= 8'd0;
        RX_PRESSED <= 1'b0;
        RX_EXTENDED <= 1'b0;
    end else begin
        if (ps2_clk_negedge) begin
            if (bit_count < 8) begin
                ps2_data_reg[bit_count] <= PS2_DATA;
                bit_count <= bit_count + 1'b1;
            end else begin
                bit_count <= 4'd0;
                RX_SCAN <= ps2_data_reg;
                RX_PRESSED <= ~PS2_DATA;
                RX_EXTENDED <= (ps2_data_reg == 8'hE0);
            end
        end
    end
end

endmodule