`timescale 1ns / 1ps
`timescale 1ns / 1ps
module AXI4DataDriver
#
(
    parameter AddressWidth      = 32    ,
    parameter DataWidth         = 32    ,
    parameter LengthWidth       = 8
)
(
    ACLK        ,
    ARESETN     ,
    SRCLEN      ,
    SRCVALID    ,
    SRCREADY    ,
    DATA        ,
    DVALID      ,
    DREADY      ,
    XDATA       ,
    XDVALID     ,
    XDREADY     ,
    XDLAST
);
    input                           ACLK        ;
    input                           ARESETN     ;
    input   [LengthWidth - 1:0]     SRCLEN      ;
    input                           SRCVALID    ;
    output                          SRCREADY    ;
    input   [DataWidth - 1:0]       DATA        ;
    input                           DVALID      ;
    output                          DREADY      ;
    output  [DataWidth - 1:0]       XDATA       ;
    output                          XDVALID     ;
    input                           XDREADY     ;
    output                          XDLAST      ;
    localparam  State_Idle          = 1'b0  ;
    localparam  State_Requesting    = 1'b1  ;
    reg         rCurState                   ;
    reg         rNextState                  ;
    reg [LengthWidth - 1:0]         rLength ;
    reg [LengthWidth - 1:0]         rCount  ;                      
    always @ (posedge ACLK)
        if (!ARESETN)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (SRCVALID)?State_Requesting:State_Idle;
        State_Requesting:
            rNextState <= (rCount == rLength && DVALID && XDREADY)?State_Idle:State_Requesting;
        endcase
    assign SRCREADY = (rCurState == State_Idle);
    always @ (posedge ACLK)
        if (!ARESETN)
            rLength <= {(LengthWidth){1'b0}};
        else
            case (rCurState)
            State_Idle:
                if (SRCVALID)
                    rLength <= SRCLEN;
            endcase
    always @ (posedge ACLK)
        if (!ARESETN)
            rCount <= {(LengthWidth){1'b0}};
        else
            case (rCurState)
            State_Idle:
                if (SRCVALID)
                    rCount <= {(LengthWidth){1'b0}};
            State_Requesting:
                if (DVALID && XDREADY)
                    rCount <= rCount + 1'b1;
            endcase
    assign XDATA   = DATA;
    assign XDVALID = (rCurState == State_Requesting) && DVALID  ;
    assign DREADY  = (rCurState == State_Requesting) && XDREADY ;
    assign XDLAST  = (rCount == rLength);
endmodule
