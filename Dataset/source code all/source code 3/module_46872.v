`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module aurora_201_ERROR_DETECT
(
    ENABLE_ERROR_DETECT,
    HARD_ERROR_RESET,
    SOFT_ERROR,
    HARD_ERROR,
    RX_BUF_ERR,
    RX_DISP_ERR,
    RX_NOT_IN_TABLE,
    TX_BUF_ERR,
    RX_REALIGN,
    USER_CLK
);
`define DLY #1
    input           ENABLE_ERROR_DETECT;
    output          HARD_ERROR_RESET;
    output          SOFT_ERROR;
    output          HARD_ERROR;
    input           RX_BUF_ERR;
    input   [1:0]   RX_DISP_ERR;
    input   [1:0]   RX_NOT_IN_TABLE;
    input           TX_BUF_ERR;
    input           RX_REALIGN;
    input           USER_CLK;
    reg             HARD_ERROR;
    reg             SOFT_ERROR;
    reg     [0:1]   count_r;
    reg             bucket_full_r;
    reg     [0:1]   soft_error_r;
    reg     [0:1]   good_count_r;
    reg             soft_error_flop_r;  
    reg             hard_error_flop_r;  
    always @(posedge USER_CLK)
    if(ENABLE_ERROR_DETECT)
    begin
        soft_error_r[0] <=  `DLY   RX_DISP_ERR[1]|RX_NOT_IN_TABLE[1];
        soft_error_r[1] <=  `DLY   RX_DISP_ERR[0]|RX_NOT_IN_TABLE[0];
    end
    else
    begin
        soft_error_r[0] <=  `DLY   1'b0;
        soft_error_r[1] <=  `DLY   1'b0;
    end
    always @(posedge USER_CLK)
    begin
        soft_error_flop_r   <=  `DLY    |soft_error_r;
        SOFT_ERROR          <=  `DLY    soft_error_flop_r;
    end
    always @(posedge USER_CLK)
        if(ENABLE_ERROR_DETECT)
        begin
            hard_error_flop_r  <=  `DLY (RX_BUF_ERR | TX_BUF_ERR |
                                         RX_REALIGN | bucket_full_r);
            HARD_ERROR         <=  `DLY  hard_error_flop_r;
        end
        else
        begin
            hard_error_flop_r   <=  `DLY    1'b0;
            HARD_ERROR          <=  `DLY    1'b0;
        end
    assign HARD_ERROR_RESET =   hard_error_flop_r;
    always @(posedge USER_CLK)
        if(!ENABLE_ERROR_DETECT)    good_count_r    <=  `DLY    2'b00;
        else
        begin
            casez({soft_error_r, good_count_r})
                4'b0000 :   good_count_r    <=  `DLY    2'b10;
                4'b0001 :   good_count_r    <=  `DLY    2'b11;
                4'b0010 :   good_count_r    <=  `DLY    2'b00;
                4'b0011 :   good_count_r    <=  `DLY    2'b01;
                4'b?1?? :   good_count_r    <=  `DLY    2'b00;
                4'b10?? :   good_count_r    <=  `DLY    2'b01;
                default :   good_count_r    <=  `DLY    good_count_r;
            endcase
        end
    always @(posedge USER_CLK)
        if(!ENABLE_ERROR_DETECT)    count_r <=  `DLY    2'b00;
        else
        begin
            casez({soft_error_r,good_count_r,count_r})
                6'b000???    :   count_r <=  `DLY    count_r;
                6'b001?00    :   count_r <=  `DLY    2'b00;
                6'b001?01    :   count_r <=  `DLY    2'b00;
                6'b001?10    :   count_r <=  `DLY    2'b01;
                6'b001?11    :   count_r <=  `DLY    2'b10; 
                6'b010000    :   count_r <=  `DLY    2'b01;
                6'b010100    :   count_r <=  `DLY    2'b01;
                6'b011000    :   count_r <=  `DLY    2'b01;
                6'b011100    :   count_r <=  `DLY    2'b00;
                6'b010001    :   count_r <=  `DLY    2'b10;
                6'b010101    :   count_r <=  `DLY    2'b10;
                6'b011001    :   count_r <=  `DLY    2'b10;
                6'b011101    :   count_r <=  `DLY    2'b01;
                6'b010010    :   count_r <=  `DLY    2'b11;
                6'b010110    :   count_r <=  `DLY    2'b11;
                6'b011010    :   count_r <=  `DLY    2'b11;
                6'b011110    :   count_r <=  `DLY    2'b10;
                6'b01??11    :   count_r <=  `DLY    2'b11;
                6'b10??00    :   count_r <=  `DLY    2'b01;
                6'b10??01    :   count_r <=  `DLY    2'b10;
                6'b10??10    :   count_r <=  `DLY    2'b11;
                6'b10??11    :   count_r <=  `DLY    2'b11;
                6'b11??00    :   count_r <=  `DLY    2'b10;
                6'b11??01    :   count_r <=  `DLY    2'b11;
                6'b11??10    :   count_r <=  `DLY    2'b11;
                6'b11??11    :   count_r <=  `DLY    2'b11;
            endcase
        end
    always @(posedge USER_CLK)
        if(!ENABLE_ERROR_DETECT)    bucket_full_r    <=  `DLY    1'b0;
        else
        begin
            casez({soft_error_r, good_count_r, count_r})
                6'b010011 :   bucket_full_r    <=  `DLY    1'b1;
                6'b010111 :   bucket_full_r    <=  `DLY    1'b1;
                6'b011011 :   bucket_full_r    <=  `DLY    1'b1;
                6'b10??11 :   bucket_full_r    <=  `DLY    1'b1;
                6'b11??1? :   bucket_full_r    <=  `DLY    1'b1;
                default   :   bucket_full_r    <=  `DLY    1'b0;
            endcase
        end
endmodule
