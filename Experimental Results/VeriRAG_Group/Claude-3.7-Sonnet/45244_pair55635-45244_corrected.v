module GE_patch (
    input        SYS_CLK,
    input        GMII_TXCLK,
    output       GMII_GTXCLK,
    input        GMII_GE_IND,
    output       ENET0_GMII_TX_CLK,
    output       ENET0_MDIO_I,
    input        ENET0_MDIO_O,
    input        ENET0_MDIO_T,
    inout        GMII_MDIO
);

wire clk_125M;
wire pll_locked;
wire pll_reset;
reg GMII_GE_IND_reg;
reg [27:0] GMII_GE_TIMER;

clk_wiz_0 pll (
    .clk_in1(SYS_CLK),
    .clk_out1(clk_125M),
    .locked(pll_locked)
);

IOBUF GMII_MDIO_BUF (
    .I(ENET0_MDIO_O),
    .IO(GMII_MDIO),
    .O(ENET0_MDIO_I),
    .T(ENET0_MDIO_T)
);

reg clk_sel;
wire clk_mux;

always @(posedge clk_125M or negedge pll_locked) begin
    if (!pll_locked) begin
        GMII_GE_IND_reg <= 1'b0;
        GMII_GE_TIMER <= 28'h0000000;
        clk_sel <= 1'b0;
    end else begin
        if (GMII_GE_IND == 1'b1) begin
            GMII_GE_IND_reg <= 1'b1;
            GMII_GE_TIMER <= 28'h0000000;
            clk_sel <= 1'b1;
        end else begin
            if (GMII_GE_TIMER == 28'hffffff) begin
                GMII_GE_IND_reg <= 1'b0;
                clk_sel <= 1'b0;
            end else begin
                GMII_GE_TIMER <= GMII_GE_TIMER + 1'b1;
            end
        end
    end
end

BUFGMUX clk_switch (
    .I0(GMII_TXCLK),
    .I1(clk_125M),
    .S(clk_sel),
    .O(clk_mux)
);

assign GMII_GTXCLK = clk_125M;
assign ENET0_GMII_TX_CLK = clk_mux;

endmodule