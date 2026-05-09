module ingress_buffer_manager #(
  parameter                 BUFFER_WIDTH              = 12,   
  parameter                 MAX_REQ_WIDTH             = 9
)(
  input                     clk,
  input                     rst,
  input                     i_hst_buf_rdy_stb,    
  input         [1:0]       i_hst_buf_rdy,        
  output  reg               o_hst_buf_fin_stb,    
  output  reg   [1:0]       o_hst_buf_fin,        
  input                     i_ctr_en,             
  input                     i_ctr_mem_rd_req_stb, 
  input                     i_ctr_dat_fin,        
  output  reg               o_ctr_tag_rdy,        
  output        [7:0]       o_ctr_tag,            
  output        [9:0]       o_ctr_dword_size,     
  output        [11:0]      o_ctr_start_addr,     
  output  reg               o_ctr_buf_sel,        
  output                    o_ctr_idle,           
  input                     i_ing_cplt_stb,       
  input         [9:0]       i_ing_cplt_pkt_cnt,   
  input         [7:0]       i_ing_cplt_tag,       
  input         [6:0]       i_ing_cplt_lwr_addr,  
  output        [12:0]      o_bld_mem_addr,       
  output  reg   [1:0]       o_bld_buf_en,         
  input                     i_bld_buf_fin,        
  output        [15:0]      o_dbg_tag_en,
  output        [15:0]      o_dbg_tag_ingress_fin,
  output  reg               o_dbg_reenable_stb,    
  output  reg               o_dbg_reenable_nzero_stb 
);
localparam      IDLE                  = 4'h0;
localparam      WAIT_FOR_COMPLETION   = 4'h1;
localparam      FINISHED              = 4'h2;
localparam      WAIT_FOR_HOST         = 4'h1;
localparam      CTRL_TAGS_INTERFACE   = 4'h2;
localparam      WAIT_FOR_FINISH       = 4'h3;
localparam      BB_SEND_DATA_0        = 4'h1;
localparam      BB_SEND_DATA_1        = 4'h2;
localparam      MAX_REQ_SIZE          = 2 ** MAX_REQ_WIDTH;
localparam      BUFFER_SIZE           = 2 ** BUFFER_WIDTH;
localparam      BIT_FIELD_WIDTH       = 2 ** (BUFFER_WIDTH - MAX_REQ_WIDTH);
localparam      DWORD_COUNT           = MAX_REQ_SIZE / 4;
localparam      NUM_TAGS              = (BUFFER_SIZE / MAX_REQ_SIZE) * 2;
localparam      BUF0_POS              = 0;
localparam      BUF1_POS              = (NUM_TAGS / 2);
localparam      TAG0_BITFIELD         = (2 ** BUF1_POS) - 1;
localparam      TAG1_BITFIELD         = TAG0_BITFIELD << (BUF1_POS);
reg             [3:0]               gen_state;
reg             [3:0]               rcv_state;
reg                                 r_delay_stb;
reg                                 r_toggle;
reg             [1:0]               r_buf_status;
reg             [1:0]               r_hst_buf_rdy_cnt;
reg             [3:0]               r_tag_rdy_pos;
reg             [NUM_TAGS - 1:0]    r_tag_sm_en;
wire            [1:0]               w_tag_sm_idle;
reg             [NUM_TAGS - 1:0]    r_tag_sm_fin;
wire            [7:0]               w_tag_map_min[1:0];
wire            [7:0]               w_tag_map_max[1:0];
wire            [NUM_TAGS - 1:0]    w_tag_bitfield[1:0];
wire            [1:0]               w_tag_ingress_done;
wire            [15:0]              w_tmp_bf        = BIT_FIELD_WIDTH;
wire            [15:0]              w_tmp_ttl_width = MAX_REQ_SIZE;
wire            [15:0]              w_tmp_buf_width = BUFFER_SIZE;
wire            [7:0]               w_max_tags      = NUM_TAGS;
wire            [7:0]               w_tag_map0;
wire            [7:0]               w_tag_map1;
wire            [NUM_TAGS - 1:0]    w_tag_bitfield0;
wire            [NUM_TAGS - 1:0]    w_tag_bitfield1;
reg             [3:0]               tag_state[0:NUM_TAGS];
reg             [11:0]              r_byte_cnt[0:NUM_TAGS];
wire            [11:0]              byte_cnt0;
wire            [11:0]              byte_cnt1;
wire            [11:0]              byte_cnt2;
wire            [11:0]              byte_cnt3;
wire            [11:0]              byte_cnt4;
wire            [11:0]              byte_cnt5;
wire            [11:0]              byte_cnt6;
wire            [11:0]              byte_cnt7;
wire            [11:0]              byte_cnt8;
wire            [11:0]              byte_cnt9;
wire            [11:0]              byte_cnt10;
wire            [11:0]              byte_cnt11;
wire            [11:0]              byte_cnt12;
wire            [11:0]              byte_cnt13;
wire            [11:0]              byte_cnt14;
wire            [11:0]              byte_cnt15;
wire            [3:0]               tag_state0;
wire            [3:0]               tag_state1;
wire            [3:0]               tag_state2;
wire            [3:0]               tag_state3;
wire            [3:0]               tag_state4;
wire            [3:0]               tag_state5;
wire            [3:0]               tag_state6;
wire            [3:0]               tag_state7;
wire            [3:0]               tag_state8;
wire            [3:0]               tag_state9;
wire            [3:0]               tag_state10;
wire            [3:0]               tag_state11;
wire            [3:0]               tag_state12;
wire            [3:0]               tag_state13;
wire            [3:0]               tag_state14;
wire            [3:0]               tag_state15;
assign  o_ctr_tag             = r_tag_rdy_pos;
assign  w_tag_map0            = w_tag_map_min[0];
assign  w_tag_map1            = w_tag_map_min[1];
assign  w_tag_map_min[0]      = BUF0_POS;
assign  w_tag_map_min[1]      = BUF1_POS;
assign  w_tag_map_max[0]      = BUF0_POS + ((NUM_TAGS / 2) - 1);
assign  w_tag_map_max[1]      = BUF1_POS + ((NUM_TAGS / 2) - 1);
assign  o_ctr_start_addr      = o_ctr_tag << MAX_REQ_WIDTH;
assign  w_tag_bitfield[0]     = TAG0_BITFIELD;
assign  w_tag_bitfield[1]     = TAG1_BITFIELD;
assign  w_tag_bitfield0       = w_tag_bitfield[0];
assign  w_tag_bitfield1       = w_tag_bitfield[1];
assign  w_tag_sm_idle[0]      = ((r_tag_sm_en & w_tag_bitfield[0]) == 0);
assign  w_tag_sm_idle[1]      = ((r_tag_sm_en & w_tag_bitfield[1]) == 0);
assign  w_tag_ingress_done[0] = i_ctr_dat_fin ? ((r_tag_sm_fin & w_tag_bitfield[0])   == (r_tag_sm_en & w_tag_bitfield[0]) &&
                                                  ((r_tag_sm_en & w_tag_bitfield[0])  > 0)):
                                                ((r_tag_sm_fin & w_tag_bitfield[0])   == (r_tag_sm_en & w_tag_bitfield[0]) &&
                                                  ((r_tag_sm_en & w_tag_bitfield[0])  == w_tag_bitfield[0]));
assign  w_tag_ingress_done[1] = i_ctr_dat_fin ? ((r_tag_sm_fin & w_tag_bitfield[1])   == (r_tag_sm_en & w_tag_bitfield[1]) &&
                                                  ((r_tag_sm_en & w_tag_bitfield[1])  > 0)):
                                                ((r_tag_sm_fin & w_tag_bitfield[1])   == (r_tag_sm_en & w_tag_bitfield[1]) &&
                                                  ((r_tag_sm_en & w_tag_bitfield[1])  == w_tag_bitfield[1]));
assign  o_bld_mem_addr        = (i_ing_cplt_tag << (MAX_REQ_WIDTH - 2)) + r_byte_cnt[i_ing_cplt_tag][11:2];
assign  o_ctr_dword_size      = DWORD_COUNT;
assign  o_ctr_idle            = (r_tag_sm_en == 0);
assign  tag_state0            = tag_state[0];
assign  tag_state1            = tag_state[1];
assign  tag_state2            = tag_state[2];
assign  tag_state3            = tag_state[3];
assign  tag_state4            = tag_state[4];
assign  tag_state5            = tag_state[5];
assign  tag_state6            = tag_state[6];
assign  tag_state7            = tag_state[7];
assign  tag_state8            = tag_state[8];
assign  tag_state9            = tag_state[9];
assign  tag_state10           = tag_state[10];
assign  tag_state11           = tag_state[11];
assign  tag_state12           = tag_state[12];
assign  tag_state13           = tag_state[13];
assign  tag_state14           = tag_state[14];
assign  tag_state15           = tag_state[15];
assign  byte_cnt0             = r_byte_cnt[0];
assign  byte_cnt1             = r_byte_cnt[1];
assign  byte_cnt2             = r_byte_cnt[2];
assign  byte_cnt3             = r_byte_cnt[3];
assign  byte_cnt4             = r_byte_cnt[4];
assign  byte_cnt5             = r_byte_cnt[5];
assign  byte_cnt6             = r_byte_cnt[6];
assign  byte_cnt7             = r_byte_cnt[7];
assign  byte_cnt8             = r_byte_cnt[8];
assign  byte_cnt9             = r_byte_cnt[9];
assign  byte_cnt10            = r_byte_cnt[10];
assign  byte_cnt11            = r_byte_cnt[11];
assign  byte_cnt12            = r_byte_cnt[12];
assign  byte_cnt13            = r_byte_cnt[13];
assign  byte_cnt14            = r_byte_cnt[14];
assign  byte_cnt15            = r_byte_cnt[15];
assign  o_dbg_tag_en          = r_tag_sm_en;
assign  o_dbg_tag_ingress_fin = r_tag_sm_fin;
integer x;
always @ (posedge clk) begin
  o_hst_buf_fin_stb   <=  0;
  o_bld_buf_en        <=  0;
  o_hst_buf_fin       <=  2'b00;
  r_delay_stb         <=  0;
  o_dbg_reenable_stb  <=  0;
  o_dbg_reenable_nzero_stb  <=  0;
  if (rst || !i_ctr_en) begin
    r_tag_rdy_pos                       <=  0;
    r_tag_sm_en                         <=  0;
    o_ctr_buf_sel                       <=  0;
    o_ctr_tag_rdy                       <=  0;
    r_hst_buf_rdy_cnt                   <=  0;
    r_buf_status                        <=  0;
    gen_state                           <=  IDLE;
    rcv_state                           <=  IDLE;
    r_toggle                            <=  0;
  end
  else begin
    case (gen_state)
      IDLE: begin
        o_hst_buf_fin_stb               <=  1;
        r_toggle                        <=  0;            
        gen_state                       <=  WAIT_FOR_HOST;
      end
      WAIT_FOR_HOST: begin
        if (!i_hst_buf_rdy_stb && !r_delay_stb && (r_hst_buf_rdy_cnt > 0))  begin
          o_ctr_buf_sel                 <=  r_buf_status[0];
          r_buf_status[0]               <=  r_buf_status[1];
          r_tag_rdy_pos                 <=  w_tag_map_min[r_buf_status[0]];
          r_hst_buf_rdy_cnt             <=  r_hst_buf_rdy_cnt - 1;
          gen_state                     <=  CTRL_TAGS_INTERFACE;
        end
      end
      CTRL_TAGS_INTERFACE: begin
        o_ctr_tag_rdy                   <=  1;
        if (i_ctr_mem_rd_req_stb) begin
          if (r_tag_sm_en[r_tag_rdy_pos]) begin
            o_dbg_reenable_stb          <=  1;
            if (r_byte_cnt[r_tag_rdy_pos] > 0) begin
              o_dbg_reenable_nzero_stb  <=  1;
            end
          end
          r_tag_sm_en[r_tag_rdy_pos]    <=  1;
          if (r_tag_rdy_pos < w_tag_map_max[o_ctr_buf_sel]) begin
            r_tag_rdy_pos               <=  r_tag_rdy_pos + 1;
          end
          else begin
            gen_state                   <= WAIT_FOR_FINISH;
            o_ctr_tag_rdy               <=  0;
          end
        end
      end
      WAIT_FOR_FINISH: begin
        if (o_hst_buf_fin_stb) begin
          gen_state                     <= WAIT_FOR_HOST;
        end
      end
      default: begin
        gen_state                       <= IDLE;
      end
    endcase
    case (rcv_state)
      IDLE: begin
        if (w_tag_ingress_done[0]) begin
          rcv_state                   <=  BB_SEND_DATA_0;
        end
        else if (w_tag_ingress_done[1]) begin
          rcv_state                   <=  BB_SEND_DATA_1;
        end
      end
      BB_SEND_DATA_0: begin
        o_bld_buf_en[0]               <=  1;
        if (i_bld_buf_fin) begin
          o_hst_buf_fin[0]            <=  1;
          o_hst_buf_fin_stb           <=  1;
          r_tag_sm_en                 <=  r_tag_sm_en & ~TAG0_BITFIELD;
          rcv_state                   <=  IDLE;
        end
      end
      BB_SEND_DATA_1: begin
        o_bld_buf_en[1]               <=  1;
        if (i_bld_buf_fin) begin
          o_hst_buf_fin[1]            <=  1;
          o_hst_buf_fin_stb           <=  1;
          r_tag_sm_en                 <=  r_tag_sm_en & ~TAG1_BITFIELD;
          rcv_state                   <=  IDLE;
        end
      end
      default: begin
        rcv_state                     <=  IDLE;
      end
    endcase
    if (i_hst_buf_rdy_stb && (i_hst_buf_rdy > 0)) begin
      r_buf_status[r_hst_buf_rdy_cnt]   <=  i_hst_buf_rdy[1];
      r_hst_buf_rdy_cnt                 <=  r_hst_buf_rdy_cnt + 1;
      r_delay_stb                       <=  1;
    end
  end
end
genvar i;
generate
for (i = 0; i < NUM_TAGS; i = i + 1) begin : tag_sm
always @ (posedge clk) begin
  r_tag_sm_fin[i]           <=  0;
  if (rst || !i_ctr_en) begin
    tag_state[i]            <=  IDLE;
    r_tag_sm_fin[i]         <=  0;
    r_byte_cnt[i]           <=  0;
  end
  else begin
    case (tag_state[i])
      IDLE: begin
        r_byte_cnt[i]       <=  0;
        if (r_tag_sm_en[i]) begin
          tag_state[i]      <=  WAIT_FOR_COMPLETION;
        end
      end
      WAIT_FOR_COMPLETION: begin
        if (i_ing_cplt_stb && (i_ing_cplt_tag == i)) begin
          r_byte_cnt[i]       <=  r_byte_cnt[i] + {i_ing_cplt_pkt_cnt, 2'b00};
        end
        if (r_byte_cnt[i] >= MAX_REQ_SIZE) begin
          tag_state[i]        <=  FINISHED;
        end
      end
      FINISHED: begin
        r_tag_sm_fin[i]     <=  1;
        if (!r_tag_sm_en[i]) begin
          tag_state[i]      <=  IDLE;
        end
      end
    endcase
  end
end
end
endgenerate
endmodule
