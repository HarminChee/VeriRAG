module JTAG_TRANS (
                   iTxD_DATA, iTxD_Start, oTxD_Done,
                   TDO, TCK, TCS);
input       [7:0] iTxD_DATA;
input             iTxD_Start;
output reg        oTxD_Done;
input             TCK, TCS;
output reg        TDO;
reg         [2:0] rCont;
always@(posedge TCK or posedge TCS)
begin
  if (TCS)
  begin
    oTxD_Done   <= 1'b0;
    rCont       <= 3'b000;
    TDO         <= 1'b0;
  end
  else
  begin
    if (iTxD_Start)
    begin
      rCont     <= rCont + 3'b001;
      TDO       <= iTxD_DATA[rCont];
    end
    else
    begin
      rCont     <= 3'b000;
      TDO       <= 1'b0;
    end
    if (rCont == 3'b111)
    begin
      oTxD_Done <= 1'b1;
    end
    else
    begin
      oTxD_Done <= 1'b0;
    end
  end
end
endmodule
module USB_JTAG (
                 iTxD_DATA, oTxD_Done,  iTxD_Start,
                 oRxD_DATA, oRxD_Ready, iRST_n,iCLK,
                 TDO, TDI, TCS, TCK);
input       [7:0] iTxD_DATA;
input             iTxD_Start, iRST_n, iCLK;
output reg  [7:0] oRxD_DATA;
output reg        oTxD_Done, oRxD_Ready;
input             TDI, TCS, TCK;
output            TDO;
wire  [7:0] mRxD_DATA;
wire        mTxD_Done, mRxD_Ready;                      
reg         Pre_TxD_Done, Pre_RxD_Ready;
reg         mTCK;
  JTAG_REC u0 (mRxD_DATA, mRxD_Ready, TDI, TCS, mTCK);
  JTAG_TRANS u1 (iTxD_DATA, iTxD_Start, mTxD_Done, TDO, TCK, TCS);
always @(posedge iCLK)
begin
  mTCK <= TCK;
end
always @(posedge iCLK or negedge iRST_n)
begin
  if(!iRST_n)
  begin
    oRxD_Ready    <= 1'b0;
    Pre_RxD_Ready <= 1'b0;
  end
  else
  begin
    Pre_RxD_Ready <= mRxD_Ready;
    if ({Pre_RxD_Ready, mRxD_Ready} == 2'b01 && ~iTxD_Start)
    begin
      oRxD_Ready <= 1'b1;
      oRxD_DATA  <= mRxD_DATA;
    end
    else
    begin
      oRxD_Ready <= 1'b0;
    end
  end
end
always @(posedge iCLK or negedge iRST_n)
begin
  if(!iRST_n)
  begin
    oTxD_Done    <= 1'b0;
    Pre_TxD_Done <= 1'b0;
  end
  else
  begin
    Pre_TxD_Done <= mTxD_Done;
    if ({Pre_TxD_Done,mTxD_Done} == 2'b01)
    begin
      oTxD_Done  <= 1'b1;
    end
    else
    begin
      oTxD_Done  <= 1'b0;
    end
  end
end
endmodule
module JTAG_REC (
                 oRxD_DATA, oRxD_Ready,
                 TDI, TCS, TCK);
input             TDI, TCS, TCK;
output reg  [7:0] oRxD_DATA;
output reg        oRxD_Ready;
reg         [7:0] rDATA;
reg         [2:0] rCont;
always@(posedge TCK or posedge TCS)
begin
  if(TCS)
  begin
    oRxD_Ready <= 1'b0;
    rCont      <= 3'b000;
  end
  else
  begin
    rCont        <= rCont + 3'b001;
    rDATA        <= {TDI, rDATA[7:1]};
    if (rCont == 3'b000)
    begin
      oRxD_DATA  <= {TDI, rDATA[7:1]};
      oRxD_Ready <= 1'b1;
    end
    else
    begin
      oRxD_Ready <= 1'b0;
    end
  end
end             
endmodule
module JTAG_TRANS (
                   iTxD_DATA, iTxD_Start, oTxD_Done,
                   TDO, TCK, TCS);
input       [7:0] iTxD_DATA;
input             iTxD_Start;
output reg        oTxD_Done;
input             TCK, TCS;
output reg        TDO;
reg         [2:0] rCont;
always@(posedge TCK or posedge TCS)
begin
  if (TCS)
  begin
    oTxD_Done   <= 1'b0;
    rCont       <= 3'b000;
    TDO         <= 1'b0;
  end
  else
  begin
    if (iTxD_Start)
    begin
      rCont     <= rCont + 3'b001;
      TDO       <= iTxD_DATA[rCont];
    end
    else
    begin
      rCont     <= 3'b000;
      TDO       <= 1'b0;
    end
    if (rCont == 3'b111)
    begin
      oTxD_Done <= 1'b1;
    end
    else
    begin
      oTxD_Done <= 1'b0;
    end
  end
end
endmodule
