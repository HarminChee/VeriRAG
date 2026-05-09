`timescale 1ns / 1ps
`define DLY #1
`timescale 1ns / 1ps
`define DLY #1
module ROCKETIO_WRAPPER_TILE_GT_FRAME_GEN #
(
    parameter   WORDS_IN_BRAM =   512
)
(
    output reg  [79:0]  TX_DATA_OUT,
    output reg  [7:0]   TXCTRL_OUT,
    input  wire         USER_CLK,
    input  wire         SYSTEM_RESET 
); 
    wire            tied_to_ground_i;
    wire    [31:0]  tied_to_ground_vec_i;
    wire    [63:0]  tx_data_bram_i;
    wire    [7:0]   tx_ctrl_i;
    reg     [8:0]   read_counter_i;
    reg     [79:0] rom [0:511];
    reg     [79:0]  tx_data_ram_r;
    reg     system_reset_r; 
    assign tied_to_ground_vec_i  =   32'h00000000;
    assign tied_to_ground_i      =   1'b0;
    assign tied_to_vcc_i         =   1'b1;
    always@(posedge USER_CLK)
       system_reset_r <= `DLY SYSTEM_RESET;
    always @(posedge USER_CLK)
        if(system_reset_r || (read_counter_i == "111111111"))  
        begin
             read_counter_i   <=  `DLY    9'd0;
        end
        else read_counter_i   <=  `DLY    read_counter_i + 9'd1;
    always @(posedge USER_CLK)
        if(system_reset_r) TX_DATA_OUT <= `DLY 80'h0000000000; 
        else             TX_DATA_OUT <= `DLY {tx_data_bram_i,tx_data_ram_r[15:0]};   
    always @(posedge USER_CLK)
        if(system_reset_r) TXCTRL_OUT <= `DLY 8'h0; 
        else             TXCTRL_OUT <= `DLY tx_ctrl_i;  
    assign tx_data_bram_i      = tx_data_ram_r[79:16];
    assign tx_ctrl_i           = tx_data_ram_r[15:8];
    always @(posedge USER_CLK)
           tx_data_ram_r <= `DLY rom[read_counter_i];
endmodule 
