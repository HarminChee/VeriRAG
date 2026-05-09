`timescale 1ns / 1ps
`timescale 1ns / 1ps
module AXI4LiteSlaveInterfaceReadChannel
#
(
    parameter AddressWidth = 32,
    parameter DataWidth = 32
)
(
    ACLK            ,
    ARESETN         ,
    ARVALID         ,
    ARREADY         ,
    ARADDR          ,
    ARPROT          ,
    RVALID          ,
    RREADY          ,
    RDATA           ,
    RRESP           ,
    oReadAddress    ,
    iReadData       ,
    oReadValid      ,
    iReadAck
);
    input                           ACLK            ;
    input                           ARESETN         ;
    input                           ARVALID         ;
    output                          ARREADY         ;
    input   [AddressWidth - 1:0]    ARADDR          ;
    input   [2:0]                   ARPROT          ;
    output                          RVALID          ;
    input                           RREADY          ;
    output  [DataWidth - 1:0]       RDATA           ;
    output  [1:0]                   RRESP           ;
    output  [AddressWidth - 1:0]    oReadAddress    ;
    input   [DataWidth - 1:0]       iReadData       ;
    output                          oReadValid      ;
    input                           iReadAck        ;
    reg     [AddressWidth - 1:0]    rReadAddress   ;
    reg     [DataWidth - 1:0]       rReadData      ;
    localparam  State_Idle          = 2'b00; 
    localparam  State_INCMDREQ      = 2'b01;
    localparam  State_AXIRRESP      = 2'b11;
    reg [1:0]   rCurState   ;
    reg [1:0]   rNextState  ;
    always @ (posedge ACLK)
        if (!ARESETN)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (ARVALID)?State_INCMDREQ:State_Idle;        
        State_INCMDREQ:
            rNextState <= (iReadAck)?State_AXIRRESP:State_INCMDREQ;
        State_AXIRRESP:
            rNextState <= (RREADY)?State_Idle:State_AXIRRESP;
        default:
            rNextState <= State_Idle;
        endcase
    assign ARREADY      = (rCurState == State_Idle);
    assign RVALID       = (rCurState == State_AXIRRESP);
    assign oReadValid   = (rCurState == State_INCMDREQ);
    always @ (posedge ACLK)
        if (!ARESETN)
            rReadAddress <= {(AddressWidth){1'b0}};
        else
            if (ARVALID)
                rReadAddress <= ARADDR;
    always @ (posedge ACLK)
        if (!ARESETN)
            rReadData <= {(DataWidth){1'b0}};
        else
            if ((rCurState == State_INCMDREQ) && iReadAck)
                rReadData <= iReadData;
    assign oReadAddress = rReadAddress;
    assign RDATA        = rReadData;
    assign RRESP = 2'b0;
endmodule
