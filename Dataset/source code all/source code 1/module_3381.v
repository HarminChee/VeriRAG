`timescale 1ns/1ps
`timescale 1ns/1ps
module  pulse_cross_clock#(
    parameter EXTRA_DLY=0 
)(
    input  rst,
    input  src_clk,
    input  dst_clk,
    input  in_pulse, 
    output out_pulse,
    output busy
);
    localparam EXTRA_DLY_SAFE=EXTRA_DLY ? 1 : 0;
`ifndef IGNORE_ATTR
    (* KEEP = "TRUE" *)
`endif    
    reg       in_reg = 0; 
`ifndef IGNORE_ATTR
    (* ASYNC_REG = "TRUE" *)
`endif    
    reg [2:0] out_reg = 0;
`ifndef IGNORE_ATTR
    (* ASYNC_REG = "TRUE" *)
`endif    
    reg       busy_r = 0;
    assign out_pulse=out_reg[2];
    assign busy=busy_r; 
    always @(posedge src_clk or posedge rst) begin
        if   (rst) in_reg <= 0;
        else       in_reg <= in_pulse || (in_reg && !out_reg[EXTRA_DLY_SAFE]);
        if   (rst) busy_r <= 0;
        else       busy_r <= in_pulse || in_reg || (busy_r && (|out_reg[EXTRA_DLY_SAFE:0]));
    end
    always @(posedge dst_clk) begin
        out_reg <= {out_reg[0] & ~out_reg[1],out_reg[0],in_reg};
    end
endmodule
