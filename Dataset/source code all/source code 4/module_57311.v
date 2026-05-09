`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module aurora_201_TX_STREAM
(
    TX_D,
    TX_SRC_RDY_N,
    TX_DST_RDY_N,
    CHANNEL_UP,
    DO_CC,
    WARN_CC,
    GEN_SCP,
    GEN_ECP,
    TX_PE_DATA_V,
    GEN_PAD,
    TX_PE_DATA,
    GEN_CC,
    USER_CLK
);
`define DLY #1
    input   [0:15]     TX_D;
    input              TX_SRC_RDY_N;
    output             TX_DST_RDY_N;
    input              CHANNEL_UP;
    input              DO_CC;
    input              WARN_CC;
    output             GEN_SCP;
    output             GEN_ECP;
    output             TX_PE_DATA_V;
    output             GEN_PAD;
    output  [0:15]     TX_PE_DATA;
    output             GEN_CC;
    input              USER_CLK;
    reg                GEN_CC;
    reg                rst_r;
    reg                start_r;
    reg                run_r;
    reg                tx_dst_rdy_n_r;        
    wire               next_start_c;
    wire               next_run_c;
    always @(posedge USER_CLK)
        tx_dst_rdy_n_r  <= `DLY !CHANNEL_UP || !run_r || DO_CC;
     assign  TX_DST_RDY_N           =   tx_dst_rdy_n_r;   
    always @(posedge USER_CLK)
        GEN_CC  <=  DO_CC;                                
    assign  GEN_SCP         =   start_r;
    assign  GEN_ECP         =   1'b0;
    assign  GEN_PAD         =   1'd0;
    assign  TX_PE_DATA      =   TX_D;
    assign  TX_PE_DATA_V    =   !tx_dst_rdy_n_r && !TX_SRC_RDY_N;
    always @(posedge USER_CLK)
        if(!CHANNEL_UP) 
        begin
            rst_r       <=  `DLY    1'b1;
            start_r     <=  `DLY    1'b0;
            run_r       <=  `DLY    1'b0;
        end
        else
        begin
            rst_r       <=  `DLY    1'b0;
            start_r     <=  `DLY    next_start_c;
            run_r       <=  `DLY    next_run_c;
        end
    assign  next_start_c    =   rst_r;
    assign  next_run_c      =   start_r ||
                                run_r;
endmodule
