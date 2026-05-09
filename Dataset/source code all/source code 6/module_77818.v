`timescale 1ns / 1ps
`timescale 1ns / 1ps
module AXI4MasterInterfaceWriteChannel
#
(
	parameter AddressWidth          = 32    ,
	parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter MaxDivider            = 16
)
(
    ACLK                ,
    ARESETN             ,
    OUTER_AWADDR        ,
    OUTER_AWLEN         ,
    OUTER_AWSIZE        ,
    OUTER_AWBURST       ,
    OUTER_AWCACHE       ,
    OUTER_AWPROT        ,
    OUTER_AWVALID       ,
    OUTER_AWREADY       ,
    OUTER_WDATA         ,
    OUTER_WSTRB         ,
    OUTER_WLAST         ,
    OUTER_WVALID        ,
    OUTER_WREADY        ,
    OUTER_BRESP         ,
    OUTER_BVALID        ,
    OUTER_BREADY        ,
    INNER_AWADDR        ,
    INNER_AWLEN         ,
    INNER_AWVALID       ,
    INNER_AWREADY       ,
    INNER_WDATA         ,
    INNER_WLAST         ,
    INNER_WVALID        ,
    INNER_WREADY
);
    input                               ACLK            ;
    input                               ARESETN         ;
    output  [AddressWidth - 1:0]        OUTER_AWADDR    ;
    output  [7:0]                       OUTER_AWLEN     ;
    output  [2:0]                       OUTER_AWSIZE    ;
    output  [1:0]                       OUTER_AWBURST   ;
    output  [3:0]                       OUTER_AWCACHE   ;
    output  [2:0]                       OUTER_AWPROT    ;
    output                              OUTER_AWVALID   ;
    input                               OUTER_AWREADY   ;
    output  [DataWidth - 1:0]           OUTER_WDATA     ;
    output  [(DataWidth/8) - 1:0]       OUTER_WSTRB     ;
    output                              OUTER_WLAST     ;
    output                              OUTER_WVALID    ;
    input                               OUTER_WREADY    ;
    input   [1:0]                       OUTER_BRESP     ;
    input                               OUTER_BVALID    ;
    output                              OUTER_BREADY    ;
    input   [AddressWidth - 1:0]        INNER_AWADDR    ;
    input   [InnerIFLengthWidth - 1:0]  INNER_AWLEN     ;
    input                               INNER_AWVALID   ;
    output                              INNER_AWREADY   ;
    input   [DataWidth - 1:0]           INNER_WDATA     ;
    input                               INNER_WLAST     ;
    input                               INNER_WVALID    ;
    output                              INNER_WREADY    ;
    wire    [AddressWidth - 1:0]        wDivAddress     ;
    wire    [7:0]                       wDivLength      ;
    wire                                wDivValid       ;
    wire                                wDivReady       ;
    wire                                wDivFlush       ;
    wire                                wWCmdQPopSignal ;
    wire                                wIsWCmdQFull    ;
    wire                                wIsWCmdQEmpty   ;
    wire    [AddressWidth - 1:0]        wQdDivAddress   ;
    wire    [7:0]                       wQdDivLength    ;
    wire                                wQdDivValid     ;
    wire                                wQdDivReady     ;
    wire                                wDivReadyCond   ;
    reg                                 rBREADY         ;
    reg     [15:0]                      rBREADYCount    ;
    assign OUTER_BREADY = rBREADY;
    always @ (posedge ACLK)
        if (!ARESETN)
            rBREADYCount <= 16'b0;
        else
            if ((OUTER_AWVALID & OUTER_AWREADY) && !(OUTER_BVALID & OUTER_BREADY))
                rBREADYCount <= rBREADYCount + 1'b1;
            else if (!(OUTER_AWVALID & OUTER_AWREADY) && (OUTER_BVALID & OUTER_BREADY))
                rBREADYCount <= rBREADYCount - 1'b1;
    always @ (*)
        if (OUTER_BVALID && (rBREADYCount != 16'b0))
            rBREADY <= 1'b1;
        else
            rBREADY <= 1'b0;
    AXI4CommandDivider
    #
    (
        .AddressWidth       (AddressWidth       ),
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .MaxDivider         (MaxDivider         )
    )
    Inst_AXI4WriteCommandDivider
    (
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .SRCADDR        (INNER_AWADDR   ),
        .SRCLEN         (INNER_AWLEN    ),
        .SRCVALID       (INNER_AWVALID  ),
        .SRCREADY       (INNER_AWREADY  ),
        .SRCREADYCOND   (1'b1           ),
        .DIVADDR        (wDivAddress    ),
        .DIVLEN         (wDivLength     ),
        .DIVVALID       (wDivValid      ),
        .DIVREADY       (wDivReady      ),
        .DIVFLUSH       (wDivFlush      )
    );
    assign wDivReady = !wIsWCmdQFull;
    SCFIFO_80x64_withCount
    Inst_AXI4WriteCommandQ
    (
        .iClock         (ACLK                           ),
        .iReset         (!ARESETN                       ),
        .iPushData      ({wDivAddress, wDivLength}      ),
        .iPushEnable    (wDivValid & wDivReady          ),
        .oIsFull        (wIsWCmdQFull                   ),
        .oPopData       ({wQdDivAddress, wQdDivLength}  ),
        .iPopEnable     (wWCmdQPopSignal                ),
        .oIsEmpty       (wIsWCmdQEmpty                  ),
        .oDataCount     (                               )
    );
    AutoFIFOPopControl
    Inst_AXI4WriteCommandQPopControl
    (
        .iClock         (ACLK           ),
        .iReset         (!ARESETN       ),
        .oPopSignal     (wWCmdQPopSignal),
        .iEmpty         (wIsWCmdQEmpty  ),
        .oValid         (wQdDivValid    ),
        .iReady         (wQdDivReady    )
    );
    AXI4CommandDriver
    #
    (
        .AddressWidth   (AddressWidth   ),
        .DataWidth      (DataWidth      )
    )
    Inst_AXI4WriteCommandDriver
    (
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .AXADDR         (OUTER_AWADDR   ),
        .AXLEN          (OUTER_AWLEN    ),
        .AXSIZE         (OUTER_AWSIZE   ),
        .AXBURST        (OUTER_AWBURST  ),
        .AXCACHE        (OUTER_AWCACHE  ),
        .AXPROT         (OUTER_AWPROT   ),
        .AXVALID        (OUTER_AWVALID  ),
        .AXREADY        (OUTER_AWREADY  ),
        .SRCADDR        (wQdDivAddress  ),
        .SRCLEN         (wQdDivLength   ),
        .SRCVALID       (wQdDivValid    ),
        .SRCREADY       (wQdDivReady    ),
        .SRCFLUSH       (wDivFlush      ),
        .SRCREADYCOND   (wDivReadyCond  )
    );
    wire    [InnerIFLengthWidth - 1:0]  wQdWLen         ;
    wire                                wIsWLenQFull    ;
    wire                                wIsWLenQEmpty   ;
    wire                                wWLenQPopSignal ;
    wire                                wQdWLenValid    ;
    wire                                wQdWLenReady    ;
    assign  wDivReadyCond = !wIsWLenQFull;
    SCFIFO_40x64_withCount
    Inst_AXI4WriteLengthQ
    (
        .iClock         (ACLK                       ),
        .iReset         (!ARESETN                   ),
        .iPushData      (wQdDivLength               ),
        .iPushEnable    (wQdDivValid && wQdDivReady ),
        .oIsFull        (wIsWLenQFull               ),
        .oPopData       (wQdWLen                    ),
        .iPopEnable     (wWLenQPopSignal            ),
        .oIsEmpty       (wIsWLenQEmpty              ),
        .oDataCount     (                           )
    );
    AutoFIFOPopControl
    Inst_AXI4WriteLengthQPopControl
    (
        .iClock         (ACLK           ),
        .iReset         (!ARESETN       ),
        .oPopSignal     (wWLenQPopSignal),
        .iEmpty         (wIsWLenQEmpty  ),
        .oValid         (wQdWLenValid   ),
        .iReady         (wQdWLenReady   )
    );
    wire    [DataWidth - 1:0]           wQdWData        ;
    wire                                wIsWDataQFull   ;
    wire                                wIsWDataQEmpty  ;
    wire                                wWDataQPopSignal;
    wire                                wQdWDataValid   ;
    wire                                wQdWDataReady   ;
    assign INNER_WREADY = !wIsWDataQFull;
    SCFIFO_64x64_withCount
    Inst_AXI4WriteDataQ
    (
        .iClock         (ACLK                           ),
        .iReset         (!ARESETN                       ),
        .iPushData      (INNER_WDATA                    ),
        .iPushEnable    (INNER_WVALID && INNER_WREADY   ),
        .oIsFull        (wIsWDataQFull                  ),
        .oPopData       (wQdWData                       ),
        .iPopEnable     (wWDataQPopSignal               ),
        .oIsEmpty       (wIsWDataQEmpty                 ),
        .oDataCount     (                               )
    );
    AutoFIFOPopControl
    Inst_AXI4WriteDataQPopControl
    (
        .iClock         (ACLK               ),
        .iReset         (!ARESETN           ),
        .oPopSignal     (wWDataQPopSignal   ),
        .iEmpty         (wIsWDataQEmpty     ),
        .oValid         (wQdWDataValid      ),
        .iReady         (wQdWDataReady      )
    );
    AXI4DataDriver
    #
    (
        .AddressWidth   (AddressWidth   ),
        .DataWidth      (DataWidth      ),
        .LengthWidth    (8              )
    )
    Inst_AXI4WriteDataDriver
    (
        .ACLK       (ACLK           ),
        .ARESETN    (ARESETN        ),
        .SRCLEN     (wQdWLen        ),
        .SRCVALID   (wQdWLenValid   ),
        .SRCREADY   (wQdWLenReady   ),
        .DATA       (wQdWData       ),
        .DVALID     (wQdWDataValid  ),
        .DREADY     (wQdWDataReady  ),
        .XDATA      (OUTER_WDATA    ),
        .XDVALID    (OUTER_WVALID   ),
        .XDREADY    (OUTER_WREADY   ),
        .XDLAST     (OUTER_WLAST    )
    );
    assign OUTER_WSTRB = {(DataWidth/8){1'b1}};
endmodule
