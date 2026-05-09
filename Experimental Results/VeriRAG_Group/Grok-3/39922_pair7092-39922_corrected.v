`timescale 1ns/1ns
module c1_regs(
    input nICOM_ZONE,
    input RW,
    input test_i,
    inout [15:8] M68K_DATA,
    inout [7:0] SDD,
    input nSDZ80R, nSDZ80W, nSDZ80CLR,
    output nSDW
);
    reg [7:0] SDD_LATCH_CMD;
    reg [7:0] SDD_LATCH_REP;
    assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;
    wire dft_nSDZ80W;
    assign dft_nSDZ80W = test_i ? 1'b0 : nSDZ80W;
    always @(posedge dft_nSDZ80W)    
    begin
        $display("Z80 -> 68K: %H", SDD);        
        SDD_LATCH_REP <= SDD;
    end
    assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
    assign nSDW = (RW | nICOM_ZONE);        
    always @(negedge nSDW)
        $display("68K -> Z80: %H", M68K_DATA);
    wire dft_nICOM_ZONE;
    assign dft_nICOM_ZONE = test_i ? 1'b0 : nICOM_ZONE;
    always @(negedge dft_nICOM_ZONE or negedge nSDZ80CLR)        
    begin
        if (!nSDZ80CLR)
        begin
            SDD_LATCH_CMD <= 8'b00000000;
        end
        else
        begin
            if (!RW)
                SDD_LATCH_CMD <= M68K_DATA;
        end
    end
endmodule