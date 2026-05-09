`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module RX_STREAM
(
    RX_D,
    RX_SRC_RDY_N,
    START_RX,
    RX_PAD,
    RX_PE_DATA,
    RX_PE_DATA_V,
    RX_SCP,
    RX_ECP,
    USER_CLK
);
`define DLY #1
    output  [0:31]     RX_D;
    output             RX_SRC_RDY_N;
    input              START_RX;
    input   [0:1]      RX_PAD;
    input   [0:31]     RX_PE_DATA;
    input   [0:1]      RX_PE_DATA_V;
    input   [0:1]      RX_SCP;
    input   [0:1]      RX_ECP;
    input              USER_CLK;
    reg                infinite_frame_started_r;
    always @(posedge USER_CLK)
        if(!START_RX)
            infinite_frame_started_r    <=  `DLY 1'b0;
        else if(RX_SCP > 2'd0)
            infinite_frame_started_r    <=  `DLY 1'b1;
    assign  RX_D     =   RX_PE_DATA;
    assign  RX_SRC_RDY_N   =   !(RX_PE_DATA_V[0] && infinite_frame_started_r);
endmodule
