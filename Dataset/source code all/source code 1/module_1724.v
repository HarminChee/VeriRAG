module   m_download(
                    clk,
                    rst,
                    IN_flit_mem,
                    v_IN_flit_mem,
                    In_flit_ctrl,
                    mem_done_access,
                    v_m_download,
                    m_download_flits,
                    m_download_state
                    );
input                    clk;
input                    rst;
input     [15:0]         IN_flit_mem;
input                    v_IN_flit_mem;
input     [1:0]          In_flit_ctrl;
input                    mem_done_access;
output                    v_m_download;
output    [175:0]         m_download_flits;
output    [1:0]           m_download_state;
reg [1:0]    m_download_nstate;
reg [1:0]    m_download_cstate;
parameter    m_download_idle=2'b00;
parameter    m_download_busy=2'b01;
parameter    m_download_rdy=2'b10;
reg   [15:0] flit_reg1;
reg   [15:0] flit_reg2;
reg   [15:0] flit_reg3;
reg   [15:0] flit_reg4;
reg   [15:0] flit_reg5;
reg   [15:0] flit_reg6;
reg   [15:0] flit_reg7;
reg   [15:0] flit_reg8;
reg   [15:0] flit_reg9;
reg   [15:0] flit_reg10;
reg   [15:0] flit_reg11;  
assign m_download_state=m_download_cstate;
assign m_download_flits={flit_reg11,flit_reg10,flit_reg9,flit_reg8,flit_reg7,flit_reg6,flit_reg5,flit_reg4,flit_reg3,flit_reg2,flit_reg1};
reg             v_m_download;
reg             en_flit_m;
reg             inc_cnt;
reg             fsm_rst;
always@(*)
begin
  m_download_nstate=m_download_cstate;
  v_m_download=1'b0;
  en_flit_m=1'b0;
  inc_cnt=1'b0;
  fsm_rst=1'b0;
  case(m_download_cstate)
    m_download_idle:
      begin
        if(v_IN_flit_mem)
          begin
            m_download_nstate=m_download_busy;
            en_flit_m=1'b1;
          end
      end
    m_download_busy:
      begin
        if(v_IN_flit_mem)
          begin
            if(In_flit_ctrl==2'b11)
              begin
                en_flit_m=1'b1;
                m_download_nstate=m_download_rdy;
              end
              en_flit_m=1'b1;
              inc_cnt=1'b1;
          end
      end
    m_download_rdy:
      begin
        v_m_download=1'b1;
        if(mem_done_access)
          begin
             m_download_nstate=m_download_idle;
             fsm_rst=1'b1;
          end
      end
    endcase
end
reg  [3:0]  cnt;
reg  [10:0]  en_flits;
always@(*)
begin
  case(cnt)
    4'b0000:en_flits=11'b00000000001;
    4'b0001:en_flits=11'b00000000010;
    4'b0010:en_flits=11'b00000000100;
    4'b0011:en_flits=11'b00000001000;
    4'b0100:en_flits=11'b00000010000;
    4'b0101:en_flits=11'b00000100000;
    4'b0110:en_flits=11'b00001000000;
    4'b0111:en_flits=11'b00010000000;
    4'b1000:en_flits=11'b00100000000;
    4'b1001:en_flits=11'b01000000000;
    4'b1010:en_flits=11'b10000000000;
    default:en_flits=11'b00000000000;
  endcase
 end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg1<=16'h0000;
  else if(en_flits[0]&&en_flit_m)
    flit_reg1<=IN_flit_mem;
end
 always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg2<=16'h0000;
  else if(en_flits[1]&&en_flit_m)
    flit_reg2<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg3<=16'h0000;
  else if(en_flits[2]&&en_flit_m)
    flit_reg3<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg4<=16'h0000;
  else if(en_flits[3]&&en_flit_m)
    flit_reg4<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg5<=16'h0000;
  else if(en_flits[4]&&en_flit_m)
    flit_reg5<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg6<=16'h0000;
  else if(en_flits[5]&&en_flit_m)
    flit_reg6<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg7<=16'h0000;
  else if(en_flits[6]&&en_flit_m)
    flit_reg7<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg8<=16'h0000;
  else if(en_flits[7]&&en_flit_m)
    flit_reg8<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg9<=16'h0000;
  else if(en_flits[8]&&en_flit_m)
    flit_reg9<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg10<=16'h0000;
  else if(en_flits[9]&&en_flit_m)
    flit_reg10<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    flit_reg11<=16'h0000;
  else if(en_flits[10]&&en_flit_m)
    flit_reg11<=IN_flit_mem;
end
always@(posedge clk)
begin
  if(rst)
    m_download_cstate<=2'b00;
  else
    m_download_cstate<=m_download_nstate;
end
always@(posedge clk)
begin
  if(rst||fsm_rst)
    cnt<=3'b000;
  else if(inc_cnt)
    cnt<=cnt+3'b001;
end
endmodule
