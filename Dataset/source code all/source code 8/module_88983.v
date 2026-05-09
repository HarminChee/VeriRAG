`timescale 1ns/1ps
//`ifndef _arbiter_ `define _arbiter_

module arbiter
  #(parameter
    NUM_PORTS = 6,
    SEL_WIDTH = ((NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1))
   (input                       clk,
    input                       rst,
    input      [NUM_PORTS-1:0]  request,
    output reg [NUM_PORTS-1:0]  grant,
    output reg [SEL_WIDTH-1:0]  select,
    output reg                  active
);
    localparam WRAP_LENGTH = 2*NUM_PORTS;
    function [SEL_WIDTH-1:0] ff1 (
        input [NUM_PORTS-1:0] in
    );
        reg     set;
        integer i;

        begin
            set = 1'b0;
            ff1 = 'b0;

            for (i = 0; i < NUM_PORTS; i = i + 1) begin
                if (in[i] & ~set) begin
                    set = 1'b1;
                    ff1 = i[0 +: SEL_WIDTH];
                end
            end
        end
    endfunction

    integer                 yy;
    wire                    next;
    wire [NUM_PORTS-1:0]    order;
    reg  [NUM_PORTS-1:0]    token;
    wire [NUM_PORTS-1:0]    token_lookahead [NUM_PORTS-1:0];
    wire [WRAP_LENGTH-1:0]  token_wrap;
    assign token_wrap   = {token, token};
    assign next         = ~|(token & request);
    always @(posedge clk)
        grant <= token & request;
    always @(posedge clk)
        select <= ff1(token & request);
    always @(posedge clk)
        active <= |(token & request);
    always @(posedge clk)
        if (rst) token <= 'b1;
        else if (next) begin
            for (yy = 0; yy < NUM_PORTS; yy = yy + 1) begin : TOKEN_
                if (order[yy]) begin
                    token <= token_lookahead[yy];
                end
            end
        end
    genvar xx;
    generate
        for (xx = 0; xx < NUM_PORTS; xx = xx + 1) begin : ORDER_

            assign token_lookahead[xx]  = token_wrap[xx +: NUM_PORTS];

            assign order[xx]            = |(token_lookahead[xx] & request);

        end
    endgenerate
endmodule


/*
module arbiter (
  clk,    
  rst,    
  req3,   
  req2,   
  req1,   
  req0,   
  gnt3,   
  gnt2,   
  gnt1,   
  gnt0   
);
input           clk;    
input           rst;    
input           req3;   
input           req2;   
input           req1;   
input           req0;   
output          gnt3;   
output          gnt2;   
output          gnt1;   
output          gnt0;   
wire    [1:0]   gnt       ;   
wire            comreq    ; 
wire            beg       ;
wire   [1:0]    lgnt      ;
wire            lcomreq   ;
reg             lgnt0     ;
reg             lgnt1     ;
reg             lgnt2     ;
reg             lgnt3     ;
reg             lasmask   ;
reg             lmask0    ;
reg             lmask1    ;
reg             ledge     ;
always @ (posedge clk)
if (rst) begin
  lgnt0 <= 0;
  lgnt1 <= 0;
  lgnt2 <= 0;
  lgnt3 <= 0;
end else begin                                     
  lgnt0 <=(~lcomreq & ~lmask1 & ~lmask0 & ~req3 & ~req2 & ~req1 & req0)
        | (~lcomreq & ~lmask1 &  lmask0 & ~req3 & ~req2 &  req0)
        | (~lcomreq &  lmask1 & ~lmask0 & ~req3 &  req0)
        | (~lcomreq &  lmask1 &  lmask0 & req0  )
        | ( lcomreq & lgnt0 );
  lgnt1 <=(~lcomreq & ~lmask1 & ~lmask0 &  req1)
        | (~lcomreq & ~lmask1 &  lmask0 & ~req3 & ~req2 &  req1 & ~req0)
        | (~lcomreq &  lmask1 & ~lmask0 & ~req3 &  req1 & ~req0)
        | (~lcomreq &  lmask1 &  lmask0 &  req1 & ~req0)
        | ( lcomreq &  lgnt1);
  lgnt2 <=(~lcomreq & ~lmask1 & ~lmask0 &  req2  & ~req1)
        | (~lcomreq & ~lmask1 &  lmask0 &  req2)
        | (~lcomreq &  lmask1 & ~lmask0 & ~req3 &  req2  & ~req1 & ~req0)
        | (~lcomreq &  lmask1 &  lmask0 &  req2 & ~req1 & ~req0)
        | ( lcomreq &  lgnt2);
  lgnt3 <=(~lcomreq & ~lmask1 & ~lmask0 & req3  & ~req2 & ~req1)
        | (~lcomreq & ~lmask1 &  lmask0 & req3  & ~req2)
        | (~lcomreq &  lmask1 & ~lmask0 & req3)
        | (~lcomreq &  lmask1 &  lmask0 & req3  & ~req2 & ~req1 & ~req0)
        | ( lcomreq & lgnt3);
end 
assign beg = (req3 | req2 | req1 | req0) & ~lcomreq;
always @ (posedge clk)
begin                                     
  lasmask <= (beg & ~ledge & ~lasmask);
  ledge   <= (beg & ~ledge &  lasmask) 
          |  (beg &  ledge & ~lasmask);
end 
assign lcomreq = ( req3 & lgnt3 )
                | ( req2 & lgnt2 )
                | ( req1 & lgnt1 )
                | ( req0 & lgnt0 );
assign  lgnt =  {(lgnt3 | lgnt2),(lgnt3 | lgnt1)};
always @ (posedge clk )
if( rst ) begin
  lmask1 <= 0;
  lmask0 <= 0;
end else if(lasmask) begin
  lmask1 <= lgnt[1];
  lmask0 <= lgnt[0];
end else begin
  lmask1 <= lmask1;
  lmask0 <= lmask0;
end 
assign comreq = lcomreq;
assign gnt    = lgnt;
assign gnt3   = lgnt3;
assign gnt2   = lgnt2;
assign gnt1   = lgnt1;
assign gnt0   = lgnt0;
endmodule
*/
