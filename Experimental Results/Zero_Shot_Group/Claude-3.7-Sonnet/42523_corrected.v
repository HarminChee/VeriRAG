`timescale 1ns / 1ps
`default_nettype none

module ethernet2BlockMem #(
    parameter INMEM_USER_BYTE_WIDTH = 1,
    parameter OUTMEM_USER_BYTE_WIDTH = 1,
    parameter INMEM_USER_ADDRESS_WIDTH = 17,
    parameter OUTMEM_USER_ADDRESS_WIDTH = 13,
    parameter INMEM_USER_REGISTER = 1,
    parameter MAC_ADDRESS = 48'hAAAAAAAAAAAA
)(
    input       wire            refClock,                                       
    input       wire            clockLock,                                     
    input       wire            hardResetLow,                                  
    input       wire            ethClock,                                      
    output      wire [7:0]      GMII_TXD,                                      
    output      wire            GMII_TX_EN,                                    
    output      wire            GMII_TX_ER,                                    
    output      wire            GMII_GTX_CLK,                                  
    input       wire [7:0]      GMII_RXD,                                      
    input       wire            GMII_RX_DV,                                    
    input       wire            GMII_RX_ER,                                    
    input       wire            GMII_RX_CLK,                                   
    output      wire            GMII_RESET_B,                                  
    input       wire            sysACE_CLK,                                    
    output      wire [6:0]      sysACE_MPADD,                                 
    inout       wire [15:0]     sysACE_MPDATA,                                
    output      wire            sysACE_MPCE,                                   
    output      wire            sysACE_MPWE,                                   
    output      wire            sysACE_MPOE,                                   
    input       wire            userInterfaceClk,                              
    output      wire            userLogicReset,                                
    output      wire            userRunValue,                                  
    input       wire            userRunClear,                                  
    input       wire            register32CmdReq,                              
    output      wire            register32CmdAck,                              
    input       wire [31:0]     register32WriteData,                           
    input       wire [7:0]      register32Address,                             
    input       wire            register32WriteEn,                             
    output      wire            register32ReadDataValid,                       
    output      wire [31:0]     register32ReadData,                            
    input       wire                                                inputMemoryReadReq,            
    output      wire                                                inputMemoryReadAck,            
    input       wire [(INMEM_USER_ADDRESS_WIDTH - 1):0]            inputMemoryReadAdd,            
    output      wire                                                inputMemoryReadDataValid,      
    output      wire [((INMEM_USER_BYTE_WIDTH * 8) - 1):0]        inputMemoryReadData,           
    input       wire                                                outputMemoryWriteReq,          
    output      wire                                                outputMemoryWriteAck,          
    input       wire [(OUTMEM_USER_ADDRESS_WIDTH - 1):0]           outputMemoryWriteAdd,          
    input       wire [((OUTMEM_USER_BYTE_WIDTH * 8) - 1):0]       outputMemoryWriteData,         
    input       wire [(OUTMEM_USER_BYTE_WIDTH - 1):0]             outputMemoryWriteByteMask      
);

    wire                hardResetClockLockLow;
    assign             hardResetClockLockLow = hardResetLow && clockLock;
    wire               hardResetClockLockLong;
    reg [12:0]         delayCtrl0Reset;
    wire               gmii_rx_clk_delay;

    always @(posedge refClock or negedge hardResetClockLockLow) begin
        if (!hardResetClockLockLow) begin
            delayCtrl0Reset <= 13'b1111111111111;
        end
        else begin
            delayCtrl0Reset <= {delayCtrl0Reset[11:0], 1'b0};
        end
    end

    assign hardResetClockLockLong = delayCtrl0Reset[12];

    IDELAYCTRL delayCtrl0(
        .RDY(),
        .REFCLK(refClock),
        .RST(hardResetClockLockLong)
    );

    IDELAY #(
        .IOBDELAY_TYPE("FIXED"),
        .IOBDELAY_VALUE(0)
    ) delayRXClk(
        .I(GMII_RX_CLK),
        .C(1'b0),
        .INC(1'b0),
        .CE(1'b0),
        .RST(1'b0),
        .O(gmii_rx_clk_delay)
    );

    assign GMII_RESET_B = hardResetLow;

    wire    [7:0]      tx_ll_data_out;
    wire               tx_ll_sof_out;
    wire               tx_ll_eof_out;
    wire               tx_ll_src_rdy_out;
    wire               tx_ll_dst_rdy_in;
    wire    [7:0]      rx_ll_data_in;
    wire               rx_ll_sof_in;
    wire               rx_ll_eof_in;
    wire               rx_ll_src_rdy_in;
    wire               rx_ll_dst_rdy_out;

    emac_single_locallink emac_ll(
        .TX_CLK_OUT                     (),             
        .TX_CLK_0                       (ethClock),
        .RX_LL_CLOCK_0                  (ethClock),
        .RX_LL_RESET_0                  (hardResetClockLockLong),
        .RX_LL_DATA_0                   (rx_ll_data_in),
        .RX_LL_SOF_N_0                  (rx_ll_sof_in),
        .RX_LL_EOF_N_0                  (rx_ll_eof_in),
        .RX_LL_SRC_RDY_N_0              (rx_ll_src_rdy_in),
        .RX_LL_DST_RDY_N_0              (rx_ll_dst_rdy_out),
        .RX_LL_FIFO_STATUS_0            (),
        .TX_LL_CLOCK_0                  (ethClock),
        .TX_LL_RESET_0                  (hardResetClockLockLong),
        .TX_LL_DATA_0                   (tx_ll_data_out),
        .TX_LL_SOF_N_0                  (tx_ll_sof_out),
        .TX_LL_EOF_N_0                  (tx_ll_eof_out),
        .TX_LL_SRC_RDY_N_0              (tx_ll_src_rdy_out),
        .TX_LL_DST_RDY_N_0              (tx_ll_dst_rdy_in),
        .CLIENTEMAC0TXIFGDELAY          (8'd0),
        .CLIENTEMAC0PAUSEREQ            (1'b0),
        .CLIENTEMAC0PAUSEVAL            (16'd0),
        .GTX_CLK_0                      (ethClock),
        .GMII_TXD_0                     (GMII_TXD),
        .GMII_TX_EN_0                   (GMII_TX_EN),
        .GMII_TX_ER_0                   (GMII_TX_ER),
        .GMII_TX_CLK_0                  (GMII_GTX_CLK),
        .GMII_RXD_0                     (GMII_RXD),
        .GMII_RX_DV_0                   (GMII_RX_DV),
        .GMII_RX_ER_0                   (GMII_RX_ER),
        .GMII_RX_CLK_0                  (gmii_rx_clk_delay),
        .RESET                          (hardResetClockLockLong)
    );

    ethernetController #(
        .INMEM_USER_BYTE_WIDTH(INMEM_USER_BYTE_WIDTH),
        .OUTMEM_USER_BYTE_WIDTH(OUTMEM_USER_BYTE_WIDTH),
        .INMEM_USER_ADDRESS_WIDTH(INMEM_USER_ADDRESS_WIDTH),
        .OUTMEM_USER_ADDRESS_WIDTH(OUTMEM_USER_ADDRESS_WIDTH),
        .INMEM_USER_REGISTER(INMEM_USER_REGISTER),
        .MAC_ADDRESS(MAC_ADDRESS)
    ) EC(
        .controllerSideClock(ethClock),
        .reset(hardResetClockLockLong),
        .rx_ll_data_in(rx_ll_data_in),
        .rx_ll_sof_in(rx_ll_sof_in),
        .rx_ll_eof_in(rx_ll_eof_in),
        .rx_ll_src_rdy_in(rx_ll_src_rdy_in),
        .rx_ll_dst_rdy_out(rx_ll_dst_rdy_out),
        .tx_ll_data_out(tx_ll_data_out),
        .tx_ll_sof_out(tx_ll_sof_out),
        .tx_ll_eof_out(tx_ll_eof_out),
        .tx_ll_src_rdy_out(tx_ll_src_rdy_out),
        .tx_ll_dst_rdy_in(tx_ll_dst_rdy_in),
        .sysACE_CLK(sysACE_CLK),
        .sysACE_MPADD(sysACE_MPADD),
        .sysACE_MPDATA(sysACE_MPDATA),
        .sysACE_MPCE(sysACE_MPCE),
        .sysACE_MPWE(sysACE_MPWE),
        .sysACE_MPOE(sysACE_MPOE),
        .userInterfaceClock(userInterfaceClk),
        .userLogicReset(userLogicReset),
        .userRunValue(userRunValue),
        .userRunClear(userRunClear),
        .register32CmdReq(register32CmdReq),
        .register32CmdAck(register32CmdAck),
        .register32WriteData(register32WriteData),
        .register32Address(register32Address),
        .register32WriteEn(register32WriteEn),
        .register32ReadDataValid(register32ReadDataValid),
        .register32ReadData(register32ReadData),
        .inputMemoryReadReq(inputMemoryReadReq),
        .inputMemoryReadAck(inputMemoryReadAck),
        .inputMemoryReadAdd(inputMemoryReadAdd),
        .inputMemoryReadDataValid(inputMemoryReadDataValid),
        .inputMemoryReadData(inputMemoryReadData),
        .outputMemoryWriteReq(outputMemoryWriteReq),
        .outputMemoryWriteAck(outputMemoryWriteAck),
        .outputMemoryWriteAdd(outputMemoryWriteAdd),
        .outputMemoryWriteData(outputMemoryWriteData),
        .outputMemoryWriteByteMask(outputMemoryWriteByteMask)
    );

endmodule