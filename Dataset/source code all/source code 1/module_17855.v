module dc_download(
                    clk,
                    rst,
                    IN_flit_dc,
                    v_IN_flit_dc,
                    In_flit_ctrl_dc,
                    dc_done_access,
                    v_dc_download,
                    dc_download_flits,
                    dc_download_state
                   );
parameter        wbrep_cmd=5'b10000;
parameter        C2Hinvrep_cmd=5'b10001;
parameter        flushrep_cmd=5'b10010;
parameter        ATflurep_cmd=5'b10011;
parameter        shrep_cmd=5'b11000;
parameter        exrep_cmd=5'b11001;
parameter        SH_exrep_cmd=5'b11010;
parameter        SCflurep_cmd=5'b11100;
parameter        instrep_cmd=5'b10100;
parameter        C2Cinvrep_cmd=5'b11011;
parameter        nackrep_cmd=5'b10101;
parameter        flushfail_rep_cmd=5'b10110;
parameter        wbfail_rep_cmd=5'b10111;
input                    clk;
input                    rst;
input      [15:0]        IN_flit_dc;  
input                    v_IN_flit_dc;
input      [1:0]         In_flit_ctrl_dc;
input                    dc_done_access; 
output                    v_dc_download;  
output     [143:0]        dc_download_flits;
output     [1:0]          dc_download_state; 
reg [1:0]    dc_download_nstate;
reg [1:0]    dc_download_cstate;
parameter    dc_download_idle=2'b00;
parameter    dc_download_busy=2'b01;
parameter    dc_download_rdy=2'b10;
reg   [15:0] flit_reg1;
reg   [15:0] flit_reg2;
reg   [15:0] flit_reg3;
reg   [15:0] flit_reg4;
reg   [15:0] flit_reg5;
reg   [15:0] flit_reg6;
reg   [15:0] flit_reg7;
reg   [15:0] flit_reg8;
reg   [15:0] flit_reg9;
assign dc_download_state=dc_download_cstate;
assign dc_download_flits={flit_reg9,flit_reg8,flit_reg7,flit_reg6,flit_reg5,flit_reg4,flit_reg3,flit_reg2,flit_reg1};
reg             v_dc_download;
reg             en_flit_dc;
reg             inc_cnt;
reg             fsm_rst;
always@(*)
begin
  dc_download_nstate=dc_download_cstate;
  v_dc_download=1'b0;
  en_flit_dc=1'b0;
  inc_cnt=1'b0;
  fsm_rst=1'b0;
  case(dc_download_cstate)
    dc_download_idle:
      begin
        if(v_IN_flit_dc)
          begin
            if(IN_flit_dc[9:5]==nackrep_cmd||IN_flit_dc[9:5]==SCflurep_cmd||IN_flit_dc[9:5]==C2Cinvrep_cmd)
                dc_download_nstate=dc_download_rdy;
            else
                dc_download_nstate=dc_download_busy;
            en_flit_dc=1'b1;
            inc_cnt=1'b1;
          end
      end
    dc_download_busy:
      begin
        if(v_IN_flit_dc)
          begin
            if(In_flit_ctrl_dc==2'b11)
              begin
                dc_download_nstate=dc_download_rdy;
              end
              en_flit_dc=1'b1;
              inc_cnt=1'b1;
          end
      end
    dc_download_rdy:
      begin
        v_dc_download=1'b1;
        if(dc_done_access)
          begin
             dc_download_nstate=dc_download_idle;
             fsm_rst=1'b1;
          end
      end
    endcase
end
reg  [3:0]  cnt;
reg  [8:0]  en_flits;
always@(*)
begin
  case(cnt)
    4'b0000:en_flits=9'b000000001;
    4'b0001:en_flits=9'b000000010;
    4'b0010:en_flits=9'b000000100;
    4'b0011:en_flits=9'b000001000;
    4'b0100:en_flits=9'b000010000;
    4'b0101:en_flits=9'b000100000;
    4'b0110:en_flits=9'b001000000;
    4'b0111:en_flits=9'b010000000;
    4'b1000:en_flits=9'b100000000;
    default:en_flits=9'b000000000;
  endcase
 end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg1<=16'h0000;
  else if(en_flits[0]&&en_flit_dc)
    flit_reg1<=IN_flit_dc;
end
 always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg2<=16'h0000;
  else if(en_flits[1]&&en_flit_dc)
    flit_reg2<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg3<=16'h0000;
  else if(en_flits[2]&&en_flit_dc)
    flit_reg3<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg4<=16'h0000;
  else if(en_flits[3]&&en_flit_dc)
    flit_reg4<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg5<=16'h0000;
  else if(en_flits[4]&&en_flit_dc)
    flit_reg5<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg6<=16'h0000;
  else if(en_flits[5]&&en_flit_dc)
    flit_reg6<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg7<=16'h0000;
  else if(en_flits[6]&&en_flit_dc)
    flit_reg7<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg8<=16'h0000;
  else if(en_flits[7]&&en_flit_dc)
    flit_reg8<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg9<=16'h0000;
  else if(en_flits[8]&&en_flit_dc)
    flit_reg9<=IN_flit_dc;
end
always@(posedge clk)
begin
  if(rst)
    dc_download_cstate<=2'b00;
  else
    dc_download_cstate<=dc_download_nstate;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    cnt<=4'b0000;
  else if(inc_cnt)
    cnt<=cnt+4'b0001;
end
endmodule
