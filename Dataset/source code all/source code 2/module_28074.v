`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module lfsr_count64(
                    input i_sys_clk,
                    input i_sys_rst,
                    output reg o_lfsr_64_done);
    reg [5:0]                  lfsr_reg_i;
    wire                       lfsr_d0_i,lfsr_equal;
    xnor(lfsr_d0_i,lfsr_reg_i[5],lfsr_reg_i[4]);
    assign lfsr_equal = (lfsr_reg_i == 6'h20);
    always @(posedge i_sys_clk,posedge i_sys_rst)
    begin
        if(i_sys_rst) begin
            lfsr_reg_i <= 0;
            o_lfsr_64_done <= 0;
        end
        else begin
            lfsr_reg_i <= lfsr_equal ? 6'h0 : {lfsr_reg_i[4:0],lfsr_d0_i};
            o_lfsr_64_done <= lfsr_equal;
        end
    end
endmodule
