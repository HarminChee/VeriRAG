`timescale 1ps/1ps
`timescale 1ps/1ps
module pcie_7x_v1_8_axi_basic_rx_pipeline #(
  parameter C_DATA_WIDTH = 128,           
  parameter C_FAMILY     = "X7",          
  parameter TCQ = 1,                      
  parameter REM_WIDTH  = (C_DATA_WIDTH == 128) ? 2 : 1, 
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8               
  ) (
  output reg [C_DATA_WIDTH-1:0] m_axis_rx_tdata,     
  output reg                    m_axis_rx_tvalid,    
  input                         m_axis_rx_tready,    
  output       [KEEP_WIDTH-1:0] m_axis_rx_tkeep,     
  output                        m_axis_rx_tlast,     
  output reg             [21:0] m_axis_rx_tuser,     
  input      [C_DATA_WIDTH-1:0] trn_rd,              
  input                         trn_rsof,            
  input                         trn_reof,            
  input                         trn_rsrc_rdy,        
  output reg                    trn_rdst_rdy,        
  input                         trn_rsrc_dsc,        
  input         [REM_WIDTH-1:0] trn_rrem,            
  input                         trn_rerrfwd,         
  input                   [6:0] trn_rbar_hit,        
  input                         trn_recrc_err,       
  input                         null_rx_tvalid,      
  input                         null_rx_tlast,       
  input        [KEEP_WIDTH-1:0] null_rx_tkeep,       
  input                         null_rdst_rdy,       
  input                   [4:0] null_is_eof,         
  output                  [2:0] np_counter,          
  input                         user_clk,            
  input                         user_rst             
);
wire              [4:0] is_sof;
wire              [4:0] is_sof_prev;
wire              [4:0] is_eof;
wire              [4:0] is_eof_prev;
reg    [KEEP_WIDTH-1:0] reg_tkeep;
wire   [KEEP_WIDTH-1:0] tkeep;
wire   [KEEP_WIDTH-1:0] tkeep_prev;
reg                     reg_tlast;
wire                    rsrc_rdy_filtered;
wire [C_DATA_WIDTH-1:0] trn_rd_DW_swapped;
reg  [C_DATA_WIDTH-1:0] trn_rd_prev;
wire                    data_hold;
reg                     data_prev;
reg                     trn_reof_prev;
reg     [REM_WIDTH-1:0] trn_rrem_prev;
reg                     trn_rsrc_rdy_prev;
reg                     trn_rsrc_dsc_prev;
reg                     trn_rsof_prev;
reg               [6:0] trn_rbar_hit_prev;
reg                     trn_rerrfwd_prev;
reg                     trn_recrc_err_prev;
reg                     null_mux_sel;
reg                     trn_in_packet;
wire                    dsc_flag;
wire                    dsc_detect;
reg                     reg_dsc_detect;
reg                     trn_rsrc_dsc_d;
assign rsrc_rdy_filtered = trn_rsrc_rdy &&
                                 (trn_in_packet || (trn_rsof && !trn_rsrc_dsc));
always @(posedge user_clk) begin
  if(user_rst) begin
    trn_rd_prev        <= #TCQ {C_DATA_WIDTH{1'b0}};
    trn_rsof_prev      <= #TCQ 1'b0;
    trn_rrem_prev      <= #TCQ {REM_WIDTH{1'b0}};
    trn_rsrc_rdy_prev  <= #TCQ 1'b0;
    trn_rbar_hit_prev  <= #TCQ 7'h00;
    trn_rerrfwd_prev   <= #TCQ 1'b0;
    trn_recrc_err_prev <= #TCQ 1'b0;
    trn_reof_prev      <= #TCQ 1'b0;
    trn_rsrc_dsc_prev  <= #TCQ 1'b0;
  end
  else begin
    if(trn_rdst_rdy) begin
      trn_rd_prev        <= #TCQ trn_rd_DW_swapped;
      trn_rsof_prev      <= #TCQ trn_rsof;
      trn_rrem_prev      <= #TCQ trn_rrem;
      trn_rbar_hit_prev  <= #TCQ trn_rbar_hit;
      trn_rerrfwd_prev   <= #TCQ trn_rerrfwd;
      trn_recrc_err_prev <= #TCQ trn_recrc_err;
      trn_rsrc_rdy_prev  <= #TCQ rsrc_rdy_filtered;
      trn_reof_prev      <= #TCQ trn_reof;
      trn_rsrc_dsc_prev  <= #TCQ trn_rsrc_dsc || dsc_flag;
    end
  end
end
generate
  if(C_DATA_WIDTH == 128) begin : rd_DW_swap_128
    assign trn_rd_DW_swapped = {trn_rd[31:0],
                                trn_rd[63:32],
                                trn_rd[95:64],
                                trn_rd[127:96]};
  end
  else if(C_DATA_WIDTH == 64) begin : rd_DW_swap_64
    assign trn_rd_DW_swapped = {trn_rd[31:0], trn_rd[63:32]};
  end
  else begin : rd_DW_swap_32
    assign trn_rd_DW_swapped = trn_rd;
  end
endgenerate
always @(posedge user_clk) begin
  if(user_rst) begin
    m_axis_rx_tdata <= #TCQ {C_DATA_WIDTH{1'b0}};
  end
  else begin
    if(!data_hold) begin
      if(data_prev) begin
        m_axis_rx_tdata <= #TCQ trn_rd_prev;
      end
      else begin
        m_axis_rx_tdata <= #TCQ trn_rd_DW_swapped;
      end
    end
  end
end
assign data_hold = (!m_axis_rx_tready && m_axis_rx_tvalid);
always @(posedge user_clk) begin
  if(user_rst) begin
    data_prev <= #TCQ 1'b0;
  end
  else begin
    data_prev <= #TCQ data_hold;
  end
end
always @(posedge user_clk) begin
  if(user_rst) begin
    m_axis_rx_tvalid <= #TCQ 1'b0;
    reg_tlast        <= #TCQ 1'b0;
    reg_tkeep        <= #TCQ {KEEP_WIDTH{1'b1}};
    m_axis_rx_tuser  <= #TCQ 22'h0;
  end
  else begin
    if(!data_hold) begin
      if(null_mux_sel) begin
        m_axis_rx_tvalid <= #TCQ null_rx_tvalid;
        reg_tlast        <= #TCQ null_rx_tlast;
        reg_tkeep        <= #TCQ null_rx_tkeep;
        m_axis_rx_tuser  <= #TCQ {null_is_eof, 17'h0000};
      end
      else if(data_prev) begin
        m_axis_rx_tvalid <= #TCQ (trn_rsrc_rdy_prev || dsc_flag);
        reg_tlast        <= #TCQ trn_reof_prev;
        reg_tkeep        <= #TCQ tkeep_prev;
        m_axis_rx_tuser  <= #TCQ {is_eof_prev,          
                                  2'b00,                
                                  is_sof_prev,          
                                  1'b0,                 
                                  trn_rbar_hit_prev,    
                                  trn_rerrfwd_prev,     
                                  trn_recrc_err_prev};  
      end
      else begin
        m_axis_rx_tvalid <= #TCQ (rsrc_rdy_filtered || dsc_flag);
        reg_tlast        <= #TCQ trn_reof;
        reg_tkeep        <= #TCQ tkeep;
        m_axis_rx_tuser  <= #TCQ {is_eof,               
                                  2'b00,                
                                  is_sof,               
                                  1'b0,                 
                                  trn_rbar_hit,         
                                  trn_rerrfwd,          
                                  trn_recrc_err};       
      end
    end
  end
end
generate
  if(C_DATA_WIDTH == 128) begin : tlast_tkeep_hookup_128
    assign m_axis_rx_tlast = 1'b0;
    assign m_axis_rx_tkeep = {KEEP_WIDTH{1'b1}};
  end
  else begin : tlast_tkeep_hookup_64_32
    assign m_axis_rx_tlast = reg_tlast;
    assign m_axis_rx_tkeep = reg_tkeep;
  end
endgenerate
generate
  if(C_DATA_WIDTH == 128) begin : rrem_to_tkeep_128
    assign tkeep      = 16'h0000;
    assign tkeep_prev = 16'h0000;
  end
  else if(C_DATA_WIDTH == 64) begin : rrem_to_tkeep_64
    assign tkeep      = trn_rrem      ? 8'hFF : 8'h0F;
    assign tkeep_prev = trn_rrem_prev ? 8'hFF : 8'h0F;
  end
  else begin : rrem_to_tkeep_32
    assign tkeep      = 4'hF;
    assign tkeep_prev = 4'hF;
  end
endgenerate
generate
  if(C_DATA_WIDTH == 128) begin : is_sof_128
    assign is_sof      = {(trn_rsof && !trn_rsrc_dsc), 
                          (trn_rsof && !trn_rrem[1]),  
                          3'b000};                     
    assign is_sof_prev = {(trn_rsof_prev && !trn_rsrc_dsc_prev), 
                          (trn_rsof_prev && !trn_rrem_prev[1]),  
                          3'b000};                               
  end
  else begin : is_sof_64_32
    assign is_sof      = {(trn_rsof && !trn_rsrc_dsc), 
                          4'b0000};                    
    assign is_sof_prev = {(trn_rsof_prev && !trn_rsrc_dsc_prev), 
                          4'b0000};                              
  end
endgenerate
generate
  if(C_DATA_WIDTH == 128) begin : is_eof_128
    assign is_eof      = {trn_reof,      
                          trn_rrem,      
                          2'b11};        
    assign is_eof_prev = {trn_reof_prev, 
                          trn_rrem_prev, 
                          2'b11};        
  end
  else if(C_DATA_WIDTH == 64) begin : is_eof_64
    assign is_eof      = {trn_reof,      
                          1'b0,          
                          trn_rrem,      
                          2'b11};        
    assign is_eof_prev = {trn_reof_prev, 
                          1'b0,          
                          trn_rrem_prev, 
                          2'b11};        
  end
  else begin : is_eof_32
    assign is_eof      = {trn_reof,      
                          4'b0011};      
    assign is_eof_prev = {trn_reof_prev, 
                          4'b0011};      
  end
endgenerate
always @(posedge user_clk) begin
  if(user_rst) begin
    trn_rdst_rdy <= #TCQ 1'b0;
  end
  else begin
    if(null_mux_sel && m_axis_rx_tready) begin
      trn_rdst_rdy <= #TCQ null_rdst_rdy;
    end
    else if(dsc_flag) begin
      trn_rdst_rdy <= #TCQ 1'b0;
    end
    else if(m_axis_rx_tvalid) begin
      trn_rdst_rdy <= #TCQ m_axis_rx_tready;
    end
    else begin
      trn_rdst_rdy <= #TCQ 1'b1;
    end
  end
end
always @(posedge user_clk) begin
  if(user_rst) begin
    null_mux_sel <= #TCQ 1'b0;
  end
  else begin
    if(null_mux_sel && null_rx_tlast && m_axis_rx_tready)
    begin
      null_mux_sel <= #TCQ 1'b0;
    end
    else if(dsc_flag && !data_hold) begin
      null_mux_sel <= #TCQ 1'b1;
    end
  end
end
always @(posedge user_clk) begin
  if(user_rst) begin
    trn_in_packet <= #TCQ 1'b0;
  end
  else begin
    if(trn_rsof && !trn_reof && rsrc_rdy_filtered && trn_rdst_rdy)
    begin
      trn_in_packet <= #TCQ 1'b1;
    end
    else if(trn_rsrc_dsc) begin
      trn_in_packet <= #TCQ 1'b0;
    end
    else if(trn_reof && !trn_rsof && trn_rsrc_rdy && trn_rdst_rdy) begin
      trn_in_packet <= #TCQ 1'b0;
    end
  end
end
assign dsc_detect = trn_rsrc_dsc && !trn_rsrc_dsc_d && trn_in_packet &&
                         (!trn_rsof || trn_reof) && !(trn_rdst_rdy && trn_reof);
always @(posedge user_clk) begin
  if(user_rst) begin
    reg_dsc_detect <= #TCQ 1'b0;
    trn_rsrc_dsc_d <= #TCQ 1'b0;
  end
  else begin
    if(dsc_detect) begin
      reg_dsc_detect <= #TCQ 1'b1;
    end
    else if(null_mux_sel) begin
      reg_dsc_detect <= #TCQ 1'b0;
    end
    trn_rsrc_dsc_d <= #TCQ trn_rsrc_dsc;
  end
end
assign dsc_flag = dsc_detect || reg_dsc_detect;
generate
  if(C_FAMILY == "V6" && C_DATA_WIDTH == 128) begin : np_cntr_to_128_enabled
    reg [2:0] reg_np_counter;
    wire mrd_lower      = (!(|m_axis_rx_tdata[92:88]) && !m_axis_rx_tdata[94]);
    wire mrd_lk_lower   = (m_axis_rx_tdata[92:88] == 5'b00001);
    wire io_rdwr_lower  = (m_axis_rx_tdata[92:88] == 5'b00010);
    wire cfg_rdwr_lower = (m_axis_rx_tdata[92:89] == 4'b0010);
    wire atomic_lower   = ((&m_axis_rx_tdata[91:90]) && m_axis_rx_tdata[94]);
    wire np_pkt_lower = (mrd_lower      ||
                         mrd_lk_lower   ||
                         io_rdwr_lower  ||
                         cfg_rdwr_lower ||
                         atomic_lower) && m_axis_rx_tuser[13];
    wire mrd_upper      = (!(|m_axis_rx_tdata[28:24]) && !m_axis_rx_tdata[30]);
    wire mrd_lk_upper   = (m_axis_rx_tdata[28:24] == 5'b00001);
    wire io_rdwr_upper  = (m_axis_rx_tdata[28:24] == 5'b00010);
    wire cfg_rdwr_upper = (m_axis_rx_tdata[28:25] == 4'b0010);
    wire atomic_upper   = ((&m_axis_rx_tdata[27:26]) && m_axis_rx_tdata[30]);
    wire np_pkt_upper = (mrd_upper      ||
                         mrd_lk_upper   ||
                         io_rdwr_upper  ||
                         cfg_rdwr_upper ||
                         atomic_upper) && !m_axis_rx_tuser[13];
    wire pkt_accepted =
                    m_axis_rx_tuser[14] && m_axis_rx_tready && m_axis_rx_tvalid;
    always @(posedge user_clk)  begin
      if (user_rst) begin
        reg_np_counter <= #TCQ 0;
      end
      else begin
        if((np_pkt_lower || np_pkt_upper) && pkt_accepted)
        begin
          reg_np_counter <= #TCQ reg_np_counter + 3'h1;
        end
      end
    end
    assign np_counter = reg_np_counter;
  end
  else begin : np_cntr_to_128_disabled
    assign np_counter = 3'h0;
  end
endgenerate
endmodule
