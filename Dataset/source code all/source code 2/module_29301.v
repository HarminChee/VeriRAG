`timescale 1 ns / 1 ps
`define DLY #1
`timescale 1 ns / 1 ps
`define DLY #1
module aur1_FRAME_CHECK
(
    RX_D,  
    RX_SRC_RDY_N,
    USER_CLK,       
    RESET,
    CHANNEL_UP,
    ERR_COUNT
);
    input   [0:63]     RX_D;
    input              RX_SRC_RDY_N;
    input              USER_CLK;
    input              RESET; 
    input              CHANNEL_UP;
    output  [0:7]      ERR_COUNT;
    reg     [0:7]      ERR_COUNT;
    reg     [0:15]     data_lfsr_r;
    wire               reset_c;
    wire    [0:63]     data_lfsr_concat_w;
    wire               data_valid_c;
    wire               data_error_detected_c;
  assign reset_c = RESET || !CHANNEL_UP;
    assign  data_valid_c    =   !RX_SRC_RDY_N;
    always @(posedge USER_CLK)
        if(reset_c)
        begin
            data_lfsr_r          <=  `DLY    16'hD5E6;  
        end
        else if(data_valid_c)
        begin
            data_lfsr_r          <=  `DLY    {!{data_lfsr_r[3]^data_lfsr_r[12]^data_lfsr_r[14]^data_lfsr_r[15]}, 
                                data_lfsr_r[0:14]};
        end  
    assign data_lfsr_concat_w = {4{data_lfsr_r}}; 
    assign  data_error_detected_c    = (data_valid_c && (RX_D != data_lfsr_concat_w));
    always @(posedge USER_CLK)
        if(reset_c)
            ERR_COUNT       <=  `DLY    8'd0;
        else if(&ERR_COUNT)
            ERR_COUNT       <=  `DLY    ERR_COUNT;
        else if(data_error_detected_c)
            ERR_COUNT       <=  `DLY    ERR_COUNT + 1;    
endmodule           
