`timescale 1 ns / 100 ps
`timescale 1 ns / 100 ps
module plb_if(
  clk,               
  rst,               
  PLB_MnAddrAck,     
  Mn_request,        
  Mn_priority,       
  Mn_RNW,            
  Mn_BE,             
  Mn_size,           
  Mn_type,           
  Mn_MSize,          
  Mn_ABus,           
  PLB_MnRdDAck,      
  PLB_MnRdWdAddr,    
  PLB_MnRdDBus,      
  PLB_BRAM_data,     
  PLB_BRAM_addr_lsb, 
  PLB_BRAM_addr_en,  
  PLB_BRAM_we,       
  get_line,          
  tft_base_addr,     
  tft_on_reg         
  );
  input          clk;
  input          rst;
  input          PLB_MnAddrAck;
  output         Mn_request;
  output [0:1]   Mn_priority;
  output         Mn_RNW;
  output [0:7]   Mn_BE;
  output [0:3]   Mn_size;        
  output [0:2]   Mn_type;
  output [0:1]   Mn_MSize;                 
  output [0:31]  Mn_ABus;
  input          PLB_MnRdDAck;     
  input [0:3]    PLB_MnRdWdAddr;
  input [0:63]   PLB_MnRdDBus;        
  output [0:63]  PLB_BRAM_data;
  output [0:1]   PLB_BRAM_addr_lsb;
  output         PLB_BRAM_addr_en;
  output         PLB_BRAM_we;
  input          get_line;
  input [0:10]   tft_base_addr;
  input          tft_on_reg;
  reg  [0:6]  trans_cnt;
  reg  [0:6]  trans_cnt_i;
  wire        trans_cnt_ce;
  wire        trans_cnt_tc;
  reg  [0:8]  line_cnt;
  reg  [0:8]  line_cnt_i;
  wire        line_cnt_ce;
  wire        end_xfer;
  wire        end_xfer_p1;
  reg  [0:63] PLB_BRAM_data;
  reg  [0:1]  PLB_BRAM_addr_lsb;
  reg         PLB_BRAM_we;
  reg  [0:10] tft_base_addr_i;
  wire        skip_line;
  reg         skip_line_d1;
  reg         skip_plb_xfer;
  reg         skip_plb_xfer_d1;
  reg         skip_plb_xfer_d2;
  reg         skip_plb_xfer_d3;
  reg         skip_plb_xfer_d4;
  reg         dummy_rd_ack;
  wire        mn_request_set;
  reg  [0:3]  data_xfer_shreg;
  reg         data_xfer_shreg1_d1;
  assign Mn_MSize     = 2'b01;             
  assign Mn_priority  = 2'b11;             
  assign Mn_size      = 4'b0010;           
  assign Mn_type      = 3'b000;            
  assign Mn_RNW       = 1'b1;              
  assign Mn_BE        = 8'b00000000;       
  assign Mn_ABus[0:10]  = tft_base_addr_i; 
  assign Mn_ABus[11:19] = line_cnt_i;
  assign Mn_ABus[20:26] = trans_cnt_i;
  assign Mn_ABus[27:31] = 5'b00000;
  assign mn_request_set = tft_on_reg & (  (get_line & (trans_cnt == 0))
                                        | (end_xfer & (trans_cnt != 0)));
  FDRSE FDRS_MN_REQUEST_DLY (.Q(Mn_request),.CE(1'b0),.C(clk),.D(1'b0),
                             .R(PLB_MnAddrAck | rst), .S(mn_request_set));
  always @(posedge clk)
     begin
       skip_plb_xfer <= ~tft_on_reg & (  (get_line & (trans_cnt == 0))
                                       | (end_xfer & (trans_cnt != 0)));
       skip_plb_xfer_d1 <= skip_plb_xfer;
       skip_plb_xfer_d2 <= skip_plb_xfer_d1;
       skip_plb_xfer_d3 <= skip_plb_xfer_d2;
       skip_plb_xfer_d4 <= skip_plb_xfer_d3;
       dummy_rd_ack     <= skip_plb_xfer_d4 | skip_plb_xfer_d3 | skip_plb_xfer_d2 | skip_plb_xfer_d1;
     end
  always @(posedge clk)
    if (mn_request_set) begin
      tft_base_addr_i <= tft_base_addr;
      line_cnt_i      <= line_cnt;
      trans_cnt_i     <= trans_cnt;
    end             
  always @(posedge clk)
  begin
    PLB_BRAM_data     <= PLB_MnRdDBus;
    PLB_BRAM_addr_lsb <= PLB_MnRdWdAddr[1:2];
    PLB_BRAM_we       <= PLB_MnRdDAck | dummy_rd_ack;
  end
  assign PLB_BRAM_addr_en = end_xfer;
  always @(posedge clk)
    if (rst | end_xfer)
      data_xfer_shreg <= (end_xfer & (PLB_MnRdDAck | dummy_rd_ack))? 4'b0001 : 4'b0000;
    else if (PLB_MnRdDAck | dummy_rd_ack)
      data_xfer_shreg <= {data_xfer_shreg[1:3], 1'b1};
  assign end_xfer = data_xfer_shreg[0];
  always @(posedge clk)
    data_xfer_shreg1_d1 <= data_xfer_shreg[1];
  assign end_xfer_p1 = data_xfer_shreg[1] & ~data_xfer_shreg1_d1;
  assign trans_cnt_ce = end_xfer_p1;
  assign trans_cnt_tc = (trans_cnt == 7'd79);
  always @(posedge clk)
    if(rst)
      trans_cnt = 7'b0;
    else if (trans_cnt_ce) begin
      if (trans_cnt_tc)
        trans_cnt = 7'b0;
      else 
        trans_cnt = trans_cnt + 1;
      end
  assign skip_line = get_line & (trans_cnt != 0);
  always @(posedge clk)
    skip_line_d1 <= skip_line & line_cnt_ce;
  assign line_cnt_ce = end_xfer_p1 & trans_cnt_tc;
  always @(posedge clk)
    if (rst)
      line_cnt = 9'b0;
    else if (line_cnt_ce | skip_line | skip_line_d1) begin
      if (line_cnt == 9'd479)
        line_cnt = 9'b0;
      else
        line_cnt = line_cnt + 1;
    end
endmodule
