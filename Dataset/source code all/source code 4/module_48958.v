`timescale 1ns/1ns
`timescale 1ns/1ns
module tx_engine_selector 
    #(
      parameter C_NUM_CHNL = 4'd12
      )
    (
     input                  CLK,
     input                  RST,
     input [C_NUM_CHNL-1:0] REQ_ALL, 
     output                 REQ, 
     output [3:0]           CHNL
     );
    reg [3:0]               rReqChnl=0, _rReqChnl=0;
    reg [3:0]               rReqChnlNext=0, _rReqChnlNext=0;
    reg                     rReqChnlsSame=0, _rReqChnlsSame=0;
    reg [3:0]               rChnlNext=0, _rChnlNext=0;
    reg [3:0]               rChnlNextNext=0, _rChnlNextNext=0;
    reg                     rChnlNextDfrnt=0, _rChnlNextDfrnt=0;
    reg                     rChnlNextNextOn=0, _rChnlNextNextOn=0;
    wire                    wChnlNextNextOn;
    reg                     rReq=0, _rReq=0;
    wire                    wReq;
    reg                     rReqChnlNextUpdated=0, _rReqChnlNextUpdated=0;
    assign wReq = REQ_ALL[rReqChnl];
    assign wChnlNextNextOn = REQ_ALL[rChnlNextNext];
    assign REQ = rReq;
    assign CHNL = rReqChnl;
    always @ (posedge CLK) begin
        rReq <= #1 (RST ? 1'd0 : _rReq);
        rReqChnl <= #1 (RST ? 4'd0 : _rReqChnl);
        rReqChnlNext <= #1 (RST ? 4'd0 : _rReqChnlNext);
        rChnlNext <= #1 (RST ? 4'd0 : _rChnlNext);
        rChnlNextNext <= #1 (RST ? 4'd0 : _rChnlNextNext);
        rChnlNextDfrnt <= #1 (RST ? 1'd0 : _rChnlNextDfrnt);
        rChnlNextNextOn <= #1 (RST ? 1'd0 : _rChnlNextNextOn);
        rReqChnlsSame <= #1 (RST ? 1'd0 : _rReqChnlsSame);
        rReqChnlNextUpdated <= #1 (RST ? 1'd1 : _rReqChnlNextUpdated);
    end
    always @ (*) begin
        _rChnlNextNextOn = wChnlNextNextOn;
        _rChnlNext = rChnlNextNext;
        _rChnlNextNext = (rChnlNextNext == C_NUM_CHNL - 1 ? 4'd0 : rChnlNextNext + 1'd1);
        _rChnlNextDfrnt = (rChnlNextNext != rReqChnl);
        _rReqChnlsSame = (rReqChnlNext == rReqChnl);
        if (rChnlNextNextOn & rChnlNextDfrnt & rReqChnlsSame & !rReqChnlNextUpdated) begin
            _rReqChnlNextUpdated = 1;
            _rReqChnlNext = rChnlNext;
        end
        else begin
            _rReqChnlNextUpdated = 0;
            _rReqChnlNext = rReqChnlNext;
        end
        _rReq = wReq;
        _rReqChnl = (!rReq ? rReqChnlNext : rReqChnl);
    end
endmodule
