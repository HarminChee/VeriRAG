`timescale 1ns / 1ps
`timescale 1ns / 1ps
module CommandChannelMux
#
(
    parameter AddressWidth          = 32    ,
    parameter InnerIFLengthWidth    = 16
)
(
    iClock          ,
    iReset          ,
    oDstWOpcode     ,
    oDstWTargetID   ,
    oDstWSourceID   ,
    oDstWAddress    ,
    oDstWLength     ,
    oDstWCmdValid   ,
    iDstWCmdReady   ,
    oDstROpcode     ,
    oDstRTargetID   ,
    oDstRSourceID   ,
    oDstRAddress    ,
    oDstRLength     ,
    oDstRCmdValid   ,
    iDstRCmdReady   ,
    oPCGWOpcode     ,
    oPCGWTargetID   ,
    oPCGWSourceID   ,
    oPCGWAddress    ,
    oPCGWLength     ,
    oPCGWCmdValid   ,
    iPCGWCmdReady   ,
    oPCGROpcode     ,
    oPCGRTargetID   ,
    oPCGRSourceID   ,
    oPCGRAddress    ,
    oPCGRLength     ,
    oPCGRCmdValid   ,
    iPCGRCmdReady   ,
    iMuxSelect      ,
    iMuxedWOpcode   ,
    iMuxedWTargetID ,
    iMuxedWSourceID ,
    iMuxedWAddress  ,
    iMuxedWLength   ,
    iMuxedWCmdValid ,
    oMuxedWCmdReady ,
    iMuxedROpcode   ,
    iMuxedRTargetID ,
    iMuxedRSourceID ,
    iMuxedRAddress  ,
    iMuxedRLength   ,
    iMuxedRCmdValid ,
    oMuxedRCmdReady
);
    input                               iClock          ;
    input                               iReset          ;
    output  [5:0]                       oDstWOpcode     ;
    output  [4:0]                       oDstWTargetID   ;
    output  [4:0]                       oDstWSourceID   ;
    output  [AddressWidth - 1:0]        oDstWAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oDstWLength     ;
    output                              oDstWCmdValid   ;
    input                               iDstWCmdReady   ;
    output  [5:0]                       oDstROpcode     ;
    output  [4:0]                       oDstRTargetID   ;
    output  [4:0]                       oDstRSourceID   ;
    output  [AddressWidth - 1:0]        oDstRAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oDstRLength     ;
    output                              oDstRCmdValid   ;
    input                               iDstRCmdReady   ;
    output  [5:0]                       oPCGWOpcode     ;
    output  [4:0]                       oPCGWTargetID   ;
    output  [4:0]                       oPCGWSourceID   ;
    output  [39:0]                      oPCGWAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oPCGWLength     ;
    output                              oPCGWCmdValid   ;
    input                               iPCGWCmdReady   ;
    output  [5:0]                       oPCGROpcode     ;
    output  [4:0]                       oPCGRTargetID   ;
    output  [4:0]                       oPCGRSourceID   ;
    output  [39:0]                      oPCGRAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oPCGRLength     ;
    output                              oPCGRCmdValid   ;
    input                               iPCGRCmdReady   ;
    input                               iMuxSelect      ;
    input   [5:0]                       iMuxedWOpcode   ;
    input   [4:0]                       iMuxedWTargetID ;
    input   [4:0]                       iMuxedWSourceID ;
    input   [39:0]                      iMuxedWAddress  ;
    input   [InnerIFLengthWidth - 1:0]  iMuxedWLength   ;
    input                               iMuxedWCmdValid ;
    output                              oMuxedWCmdReady ;
    input   [5:0]                       iMuxedROpcode   ;
    input   [4:0]                       iMuxedRTargetID ;
    input   [4:0]                       iMuxedRSourceID ;
    input   [39:0]                      iMuxedRAddress  ;
    input   [InnerIFLengthWidth - 1:0]  iMuxedRLength   ;
    input                               iMuxedRCmdValid ;
    output                              oMuxedRCmdReady ;
    reg     [5:0]                       rDstWOpcode     ;
    reg     [4:0]                       rDstWTargetID   ;
    reg     [4:0]                       rDstWSourceID   ;
    reg     [AddressWidth - 1:0]        rDstWAddress    ;
    reg     [InnerIFLengthWidth - 1:0]  rDstWLength     ;
    reg                                 rDstWCmdValid   ;
    reg     [5:0]                       rDstROpcode     ;
    reg     [4:0]                       rDstRTargetID   ;
    reg     [4:0]                       rDstRSourceID   ;
    reg     [AddressWidth - 1:0]        rDstRAddress    ;
    reg     [InnerIFLengthWidth - 1:0]  rDstRLength     ;
    reg                                 rDstRCmdValid   ;
    reg     [5:0]                       rPCGWOpcode     ;
    reg     [4:0]                       rPCGWTargetID   ;
    reg     [4:0]                       rPCGWSourceID   ;
    reg     [39:0]                      rPCGWAddress    ;
    reg     [InnerIFLengthWidth - 1:0]  rPCGWLength     ;
    reg                                 rPCGWCmdValid   ;
    reg     [5:0]                       rPCGROpcode     ;
    reg     [4:0]                       rPCGRTargetID   ;
    reg     [4:0]                       rPCGRSourceID   ;
    reg     [39:0]                      rPCGRAddress    ;
    reg     [InnerIFLengthWidth - 1:0]  rPCGRLength     ;
    reg                                 rPCGRCmdValid   ;
    reg                                 rMuxedWCmdReady ;
    reg                                 rMuxedRCmdReady ;
    assign oDstWOpcode      = rDstWOpcode       ;
    assign oDstWTargetID    = rDstWTargetID     ;
    assign oDstWSourceID    = rDstWSourceID     ;
    assign oDstWAddress     = rDstWAddress      ;
    assign oDstWLength      = rDstWLength       ;
    assign oDstWCmdValid    = rDstWCmdValid     ;
    assign oDstROpcode      = rDstROpcode       ;
    assign oDstRTargetID    = rDstRTargetID     ;
    assign oDstRSourceID    = rDstRSourceID     ;
    assign oDstRAddress     = rDstRAddress      ;
    assign oDstRLength      = rDstRLength       ;
    assign oDstRCmdValid    = rDstRCmdValid     ;
    assign oPCGWOpcode      = rPCGWOpcode       ;
    assign oPCGWTargetID    = rPCGWTargetID     ;
    assign oPCGWSourceID    = rPCGWSourceID     ;
    assign oPCGWAddress     = rPCGWAddress      ;
    assign oPCGWLength      = rPCGWLength       ;
    assign oPCGWCmdValid    = rPCGWCmdValid     ;
    assign oPCGROpcode      = rPCGROpcode       ;
    assign oPCGRTargetID    = rPCGRTargetID     ;
    assign oPCGRSourceID    = rPCGRSourceID     ;
    assign oPCGRAddress     = rPCGRAddress      ;
    assign oPCGRLength      = rPCGRLength       ;
    assign oPCGRCmdValid    = rPCGRCmdValid     ;
    assign oMuxedWCmdReady  = rMuxedWCmdReady   ;
    assign oMuxedRCmdReady  = rMuxedRCmdReady   ;
    always @ (*)
        case (iMuxSelect)
        0:
        begin
            rDstWOpcode     <= iMuxedWOpcode    ;
            rDstWTargetID   <= iMuxedWTargetID  ;
            rDstWSourceID   <= iMuxedWSourceID  ;
            rDstWAddress    <= iMuxedWAddress   ;
            rDstWLength     <= iMuxedWLength    ;
            rDstWCmdValid   <= iMuxedWCmdValid  ;
            rMuxedWCmdReady <= iDstWCmdReady    ;
            rDstROpcode     <= iMuxedROpcode    ;
            rDstRTargetID   <= iMuxedRTargetID  ;
            rDstRSourceID   <= iMuxedRSourceID  ;
            rDstRAddress    <= iMuxedRAddress   ;
            rDstRLength     <= iMuxedRLength    ;
            rDstRCmdValid   <= iMuxedRCmdValid  ;
            rMuxedRCmdReady <= iDstRCmdReady    ;
            rPCGWOpcode     <= 6'b0                         ;
            rPCGWTargetID   <= 5'b0                         ;
            rPCGWSourceID   <= 5'b0                         ;
            rPCGWAddress    <= {(AddressWidth){1'b0}}       ;
            rPCGWLength     <= {(InnerIFLengthWidth){1'b0}} ;
            rPCGWCmdValid   <= 1'b0                         ;
            rPCGROpcode     <= 6'b0                         ;
            rPCGRTargetID   <= 5'b0                         ;
            rPCGRSourceID   <= 5'b0                         ;
            rPCGRAddress    <= {(AddressWidth){1'b0}}       ;
            rPCGRLength     <= {(InnerIFLengthWidth){1'b0}} ;
            rPCGRCmdValid   <= 1'b0                         ;
        end
        default:
        begin
            rDstWOpcode     <= 6'b0                         ;
            rDstWTargetID   <= 5'b0                         ;
            rDstWSourceID   <= 5'b0                         ;
            rDstWAddress    <= {(AddressWidth){1'b0}}       ;
            rDstWLength     <= {(InnerIFLengthWidth){1'b0}} ;
            rDstWCmdValid   <= 1'b0                         ;
            rDstROpcode     <= 6'b0                         ;
            rDstRTargetID   <= 5'b0                         ;
            rDstRSourceID   <= 5'b0                         ;
            rDstRAddress    <= {(AddressWidth){1'b0}}       ;
            rDstRLength     <= {(InnerIFLengthWidth){1'b0}} ;
            rDstRCmdValid   <= 1'b0                         ;
            rPCGWOpcode     <= iMuxedWOpcode    ;
            rPCGWTargetID   <= iMuxedWTargetID  ;
            rPCGWSourceID   <= iMuxedWSourceID  ;
            rPCGWAddress    <= iMuxedWAddress   ;
            rPCGWLength     <= iMuxedWLength    ;
            rPCGWCmdValid   <= iMuxedWCmdValid  ;
            rMuxedWCmdReady <= iPCGWCmdReady    ;
            rPCGROpcode     <= iMuxedROpcode    ;
            rPCGRTargetID   <= iMuxedRTargetID  ;
            rPCGRSourceID   <= iMuxedRSourceID  ;
            rPCGRAddress    <= iMuxedRAddress   ;
            rPCGRLength     <= iMuxedRLength    ;
            rPCGRCmdValid   <= iMuxedRCmdValid  ;
            rMuxedRCmdReady <= iPCGRCmdReady    ;
        end
        endcase
endmodule
