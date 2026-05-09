`timescale 1ns / 1ps
`timescale 1ns / 1ps
module BRAMPopControl
#
(
    parameter BRAMAddressWidth  =   8   ,
    parameter DataWidth         =   32
)
(
    iClock          ,
    iReset          ,
    iAddressInput   ,
    iAddressValid   ,
    oDataOut        ,
    oDataValid      ,
    iDataReady      ,
    oMemReadAddress ,
    iMemReadData    ,
    oMemDataReadSig
);
    input                               iClock          ;
    input                               iReset          ;
    input   [BRAMAddressWidth - 1:0]    iAddressInput   ;
    input                               iAddressValid   ;
    output  [DataWidth - 1:0]           oDataOut        ;
    output                              oDataValid      ;
    input                               iDataReady      ;
    output  [BRAMAddressWidth - 1:0]    oMemReadAddress ;
    input   [DataWidth - 1:0]           iMemReadData    ;
    output                              oMemDataReadSig ;
    reg     [BRAMAddressWidth - 1:0]    rReadAddress    ;
    reg                                 rValidSigOut    ;
    reg                                 rValidSigNextOut;
    assign oMemReadAddress  = rReadAddress;
    assign oMemDataReadSig  = (!rValidSigOut || iDataReady);
    always @ (posedge iClock)
        if (iReset)
            rReadAddress <= {(BRAMAddressWidth){1'b0}};
        else
            if (iAddressValid)
                rReadAddress <= iAddressInput;
            else if (oMemDataReadSig)
                rReadAddress <= rReadAddress + 1'b1;
    always @ (posedge iClock)
        if (iReset || iAddressValid)
        begin
            rValidSigOut        <= 1'b0;
            rValidSigNextOut    <= 1'b0;
        end
        else
        begin
            if (!rValidSigOut || iDataReady)
            begin
                rValidSigOut        <= rValidSigNextOut;
                rValidSigNextOut    <= oMemDataReadSig;
            end
        end
    assign oDataOut     = iMemReadData;
    assign oDataValid   = rValidSigOut;
endmodule
