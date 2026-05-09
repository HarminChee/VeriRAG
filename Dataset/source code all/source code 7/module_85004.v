`timescale 1ns / 1ps
`timescale 1ns / 1ps
module AXI4CommandDriver
#
(
    parameter AddressWidth      = 32    ,
    parameter DataWidth         = 32
)
(
    ACLK        ,
    ARESETN     ,
    AXADDR      ,
    AXLEN       ,
    AXSIZE      ,
    AXBURST     ,
    AXCACHE     ,
    AXPROT      ,
    AXVALID     ,
    AXREADY     ,
    SRCADDR     ,
    SRCLEN      ,
    SRCVALID    ,
    SRCREADY    ,
    SRCFLUSH    ,
    SRCREADYCOND
);
    input                           ACLK        ;
    input                           ARESETN     ;
    output  [AddressWidth - 1:0]    AXADDR      ;
    output  [7:0]                   AXLEN       ;
    output  [2:0]                   AXSIZE      ;
    output  [1:0]                   AXBURST     ;
    output  [3:0]                   AXCACHE     ;
    output  [2:0]                   AXPROT      ;
    output                          AXVALID     ;
    input                           AXREADY     ;
    input   [AddressWidth - 1:0]    SRCADDR     ;
    input   [7:0]                   SRCLEN      ;
    input                           SRCVALID    ;
    output                          SRCREADY    ;
    input                           SRCFLUSH    ;
    input                           SRCREADYCOND;
    localparam  State_Idle       = 1'b0 ;
    localparam  State_Requesting = 1'b1 ;
    reg         rCurState               ;
    reg         rNextState              ;
    always @ (posedge ACLK)
        if (!ARESETN)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (SRCFLUSH)?State_Requesting:State_Idle;
        State_Requesting:
            rNextState <= (!SRCVALID)?State_Idle:State_Requesting;
        endcase
    assign AXADDR   = SRCADDR                   ;
    assign AXLEN    = SRCLEN                    ;
    assign AXSIZE   = $clog2(DataWidth / 8 - 1) ;
    assign AXBURST  = 2'b01                     ;
    assign AXCACHE  = 4'b0010                   ;
    assign AXPROT   = 3'b0                      ;
    assign AXVALID  = (rCurState == State_Requesting) && SRCVALID && SRCREADYCOND;
    assign SRCREADY = (rCurState == State_Requesting) && AXREADY && SRCREADYCOND;
endmodule
