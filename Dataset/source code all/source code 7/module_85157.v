`timescale 1ns / 1ps
`timescale 1ns / 1ps
module AXI4LiteSlaveInterfaceWriteChannel
#
(
    parameter AddressWidth = 32,
    parameter DataWidth = 32
)
(
    ACLK            ,
    ARESETN         ,
    AWVALID         ,
    AWREADY         ,
    AWADDR          ,
    AWPROT          ,
    WVALID          ,
    WREADY          ,
    WDATA           ,
    WSTRB           ,
    BVALID          ,
    BREADY          ,
    BRESP           ,
    oWriteAddress   ,
    oWriteData      ,
    oWriteValid     ,
    iWriteAck
);
    input                           ACLK            ;
    input                           ARESETN         ;
    input                           AWVALID         ;
    output                          AWREADY         ;
    input   [AddressWidth - 1:0]    AWADDR          ;
    input   [2:0]                   AWPROT          ;
    input                           WVALID          ;
    output                          WREADY          ;
    input   [DataWidth - 1:0]       WDATA           ;
    input   [DataWidth/8 - 1:0]     WSTRB           ;
    output                          BVALID          ;
    input                           BREADY          ;
    output  [1:0]                   BRESP           ;
    output  [AddressWidth - 1:0]    oWriteAddress   ;
    output  [DataWidth - 1:0]       oWriteData      ;
    output                          oWriteValid     ;
    input                           iWriteAck       ;
    reg     [AddressWidth - 1:0]    rWriteAddress   ;
    reg     [DataWidth - 1:0]       rWriteData      ;
    localparam  State_Idle          = 2'b00; 
    localparam  State_INCMDREQ      = 2'b01;
    localparam  State_AXIWRESP      = 2'b11;
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
            rNextState <= (AWVALID && WVALID)?State_INCMDREQ:State_Idle;        
        State_INCMDREQ:
            rNextState <= (iWriteAck)?State_AXIWRESP:State_INCMDREQ;
        State_AXIWRESP:
            rNextState <= (BREADY)?State_Idle:State_AXIWRESP;
        default:
            rNextState <= State_Idle;
        endcase
    assign AWREADY      = ((rCurState == State_INCMDREQ) && iWriteAck);
    assign WREADY       = ((rCurState == State_INCMDREQ) && iWriteAck);
    assign oWriteValid  = (rCurState == State_INCMDREQ);
    always @ (posedge ACLK)
        if (!ARESETN)
            rWriteAddress <= {(AddressWidth){1'b0}};
        else
            if (AWVALID)
                rWriteAddress <= AWADDR;
    always @ (posedge ACLK)
        if (!ARESETN)
            rWriteData <= {(DataWidth){1'b0}};
        else
            if (WVALID)
                rWriteData <= WDATA;
    assign oWriteAddress = rWriteAddress;
    assign oWriteData = rWriteData;
    assign BVALID = (rCurState == State_AXIWRESP);
    assign BRESP = 2'b0;
endmodule
