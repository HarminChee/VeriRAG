`timescale 1ns/1ns
module c1_regs(
    input               clk,
    input               test_i,
    input               nICOM_ZONE,
    input               RW,
    inout      [15:8]   M68K_DATA,
    inout      [7:0]    SDD,
    input               nSDZ80R,
    input               nSDZ80W,
    input               nSDZ80CLR,
    output              nSDW
);

wire dft_clk = test_i ? clk : clk;

reg [7:0] SDD_LATCH_CMD;
reg [7:0] SDD_LATCH_REP;
reg       nSDZ80W_q1, nSDZ80W_q2;

always @(posedge dft_clk or negedge nSDZ80CLR) begin
    if (!nSDZ80CLR) begin
        nSDZ80W_q1      <= 1'b1;
        nSDZ80W_q2      <= 1'b1;
        SDD_LATCH_CMD   <= 8'b00000000;
        SDD_LATCH_REP   <= 8'b00000000;
    end
    else begin
        nSDZ80W_q1 <= nSDZ80W;
        nSDZ80W_q2 <= nSDZ80W_q1;

        if (nSDZ80W_q2 & ~nSDZ80W_q1) begin
            $display("Z80 -> 68K: %H", SDD);
            SDD_LATCH_REP <= SDD;
        end

        if (!RW && !nICOM_ZONE) begin
            SDD_LATCH_CMD <= M68K_DATA;
        end
    end
end

assign SDD = nSDZ80R ? 8'bz : SDD_LATCH_CMD;
assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bz;
assign nSDW = (RW | nICOM_ZONE);

always @(posedge dft_clk) begin
    if (!RW && !nICOM_ZONE) begin
        $display("68K -> Z80: %H", M68K_DATA);
    end
end

endmodule