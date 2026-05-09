`timescale 1 ns / 1ps
`timescale 1 ns / 1ps
module phsaligner # (
  parameter OPENEYE_CNT_WD = 3, 
  parameter CTKNCNTWD      = 7, 
  parameter SRCHTIMERWD    = 12 
)
(
  input  wire       rst,
  input  wire       clk,
  input  wire [9:0] sdata,       
  output reg        flipgear,
  output reg        bitslip,
  output reg        psaligned    
);  
  parameter CTRLTOKEN0 = 10'b1101010100;
  parameter CTRLTOKEN1 = 10'b0010101011;
  parameter CTRLTOKEN2 = 10'b0101010100;
  parameter CTRLTOKEN3 = 10'b1010101011;
  reg rcvd_ctkn, rcvd_ctkn_q;
  reg blnkbgn; 
  always @ (posedge clk) begin
    rcvd_ctkn <=#1 ((sdata == CTRLTOKEN0) || (sdata == CTRLTOKEN1) || 
                    (sdata == CTRLTOKEN2) || (sdata == CTRLTOKEN3));
    rcvd_ctkn_q <=#1 rcvd_ctkn;
    blnkbgn <=#1 !rcvd_ctkn_q & rcvd_ctkn;
  end
  reg [(SRCHTIMERWD-1):0] ctkn_srh_timer;
  reg ctkn_srh_rst;  
  always @ (posedge clk) begin
    if (ctkn_srh_rst)
      ctkn_srh_timer <=#1 {SRCHTIMERWD{1'b0}};
    else
      ctkn_srh_timer <=#1 ctkn_srh_timer + 1'b1;
  end
  reg ctkn_srh_tout;
  always @ (posedge clk) begin
    ctkn_srh_tout <=#1 (ctkn_srh_timer == {SRCHTIMERWD{1'b1}});
  end
  reg [(CTKNCNTWD-1):0] ctkn_counter;
  reg ctkn_cnt_rst; 
  always @ (posedge clk) begin
    if(ctkn_cnt_rst)
      ctkn_counter <=#1 {CTKNCNTWD{1'b0}};
    else
      ctkn_counter <=#1 ctkn_counter + 1'b1;
  end
  reg ctkn_cnt_tout;
  always @ (posedge clk) begin
    ctkn_cnt_tout <=#1 (ctkn_counter == {CTKNCNTWD{1'b1}});
  end
  parameter INIT        = 6'b1 << 0;
  parameter SEARCH      = 6'b1 << 1;  
  parameter BITSLIP     = 6'b1 << 2;
  parameter RCVDCTKN    = 6'b1 << 3;  
  parameter BLNKPRD     = 6'b1 << 4;
  parameter PSALGND     = 6'b1 << 5;  
  parameter nSTATES     = 6;
  reg [(nSTATES-1):0] cstate = {{(nSTATES-1){1'b0}}, 1'b1};  
  reg [(nSTATES-1):0] nstate;
`ifdef SIMULATION
  reg  [8*20:1] state_ascii = "INIT               ";
  always @(cstate) begin
    if      (cstate == INIT     ) state_ascii <= "INIT               ";
    else if (cstate == SEARCH   ) state_ascii <= "SEARCH             ";
    else if (cstate == BITSLIP  ) state_ascii <= "BITSLIP            ";
    else if (cstate == RCVDCTKN ) state_ascii <= "RCVDCTKN           ";
    else if (cstate == BLNKPRD  ) state_ascii <= "BLNKPRD            ";
    else state_ascii                          <= "PSALGND            ";
  end
`endif
  always @ (posedge clk or posedge rst) begin
    if (rst)
      cstate <= INIT;
    else
      cstate <=#1 nstate;
  end
  parameter BLNKPRD_CNT_WD = 1;
  reg [(BLNKPRD_CNT_WD-1):0] blnkprd_cnt = {BLNKPRD_CNT_WD{1'b0}};
  always @ (*) begin
    case (cstate) 
      INIT: begin
        nstate = (ctkn_srh_tout) ? SEARCH : INIT;
      end
      SEARCH: begin
        if(blnkbgn)
          nstate = RCVDCTKN;
        else
          nstate = (ctkn_srh_tout) ? BITSLIP : SEARCH;
      end
      BITSLIP: begin
        nstate = SEARCH;
      end
      RCVDCTKN: begin
        if(rcvd_ctkn)
          nstate = (ctkn_cnt_tout) ? BLNKPRD : RCVDCTKN;
        else
          nstate = SEARCH;
      end
      BLNKPRD: begin
        nstate = (blnkprd_cnt == {BLNKPRD_CNT_WD{1'b1}}) ? PSALGND : SEARCH;
      end
      PSALGND: begin
        nstate = PSALGND; 
      end
    endcase
  end
  reg [2:0] bitslip_cnt;
  always @ (posedge clk or posedge rst) begin
    if(rst) begin
      psaligned          <=#1 1'b0; 
      bitslip            <=#1 1'b0;
      ctkn_srh_rst       <=#1 1'b1; 
      ctkn_cnt_rst       <=#1 1'b1; 
      bitslip            <=#1 1'b0;
      bitslip_cnt        <=#1 3'h0;
      flipgear           <=#1 1'b0;
      blnkprd_cnt        <=#1 {BLNKPRD_CNT_WD{1'b0}};
    end else begin
      case (cstate) 
        INIT: begin
          ctkn_srh_rst       <=#1 1'b0;
          ctkn_cnt_rst       <=#1 1'b1;
          bitslip            <=#1 1'b0;
          psaligned          <=#1 1'b0;
          bitslip            <=#1 1'b0;
          bitslip_cnt        <=#1 3'h0;
          flipgear           <=#1 1'b0;
          blnkprd_cnt        <=#1 {BLNKPRD_CNT_WD{1'b0}};
        end
        SEARCH: begin
          ctkn_srh_rst       <=#1 1'b0;
          ctkn_cnt_rst       <=#1 1'b1;
          bitslip            <=#1 1'b0;
          psaligned          <=#1 1'b0;
        end
        BITSLIP: begin
          ctkn_srh_rst       <=#1 1'b1;
          bitslip            <=#1 1'b1;
          bitslip_cnt        <=#1 bitslip_cnt + 1'b1;
          flipgear           <=#1 bitslip_cnt[2]; 
        end
        RCVDCTKN: begin
          ctkn_srh_rst       <=#1 1'b0;
          ctkn_cnt_rst       <=#1 1'b0;
        end
        BLNKPRD: begin
          blnkprd_cnt        <=#1 blnkprd_cnt + 1'b1;
        end
        PSALGND: begin
          psaligned <=#1 1'b1;
        end
      endcase
    end
  end
endmodule
