`timescale 1ns/1ns
module c1_regs(
    input nICOM_ZONE,
    input RW,
    input clk,           // Added clock input
    input test_mode,     // Added test mode signal
    inout [15:8] M68K_DATA,
    inout [7:0] SDD,
    input nSDZ80R, nSDZ80W, nSDZ80CLR,
    output nSDW
);
    reg [7:0] SDD_LATCH_CMD;
    reg [7:0] SDD_LATCH_REP;
    
    assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;
    
    // Synchronous data capture using main clock
    always @(posedge clk)
    begin
        if (!nSDZ80W)
        begin
            $display("Z80 -> 68K: %H", SDD);
            SDD_LATCH_REP <= SDD;
        end
    end

    assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
    assign nSDW = (RW | nICOM_ZONE);

    // Synchronous data capture using main clock
    always @(posedge clk)
    begin
        if (!nSDZ80CLR)
        begin
            SDD_LATCH_CMD <= 8'b00000000;
        end
        else if (!nICOM_ZONE && !RW)
        begin
            SDD_LATCH_CMD <= M68K_DATA;
        end
    end

endmodule