`timescale 1ps/1ps
`timescale 1ps/1ps
module PCIeGen2x8If128_axi_basic_tx_pipeline #(
  parameter C_DATA_WIDTH = 128,           
  parameter C_PM_PRIORITY = "FALSE",      
  parameter TCQ = 1,                      
  parameter REM_WIDTH  = (C_DATA_WIDTH == 128) ? 2 : 1, 
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8               
  ) (
  input      [C_DATA_WIDTH-1:0] s_axis_tx_tdata,     
  input                         s_axis_tx_tvalid,    
  output                        s_axis_tx_tready,    
  input        [KEEP_WIDTH-1:0] s_axis_tx_tkeep,     
  input                         s_axis_tx_tlast,     
  input                   [3:0] s_axis_tx_tuser,     
  output     [C_DATA_WIDTH-1:0] trn_td,              
  output                        trn_tsof,            
  output                        trn_teof,            
  output                        trn_tsrc_rdy,        
  input                         trn_tdst_rdy,        
  output                        trn_tsrc_dsc,        
  output        [REM_WIDTH-1:0] trn_trem,            
  output                        trn_terrfwd,         
  output                        trn_tstr,            
  output                        trn_tecrc_gen,       
  input                         trn_lnk_up,          
  input                         tready_thrtl,        
  input                         user_clk,            
  input                         user_rst             
);
reg  [C_DATA_WIDTH-1:0] reg_tdata;
reg                     reg_tvalid;
reg    [KEEP_WIDTH-1:0] reg_tkeep;
reg               [3:0] reg_tuser;
reg                     reg_tlast;
reg                     reg_tready;
reg                     trn_in_packet;
reg                     axi_in_packet;
reg                     flush_axi;
wire                    disable_trn;
reg                     reg_disable_trn;
wire                    axi_beat_live  = s_axis_tx_tvalid && s_axis_tx_tready;
wire                    axi_end_packet = axi_beat_live && s_axis_tx_tlast;
generate
  if(C_DATA_WIDTH == 128) begin : td_DW_swap_128
    assign trn_td = {reg_tdata[31:0],
                     reg_tdata[63:32],
                     reg_tdata[95:64],
                     reg_tdata[127:96]};
  end
  else if(C_DATA_WIDTH == 64) begin : td_DW_swap_64
    assign trn_td = {reg_tdata[31:0], reg_tdata[63:32]};
  end
  else begin : td_DW_swap_32
    assign trn_td = reg_tdata;
  end
endgenerate
assign trn_tsof = reg_tvalid && !trn_in_packet;
always @(posedge user_clk) begin
  if(user_rst) begin
    trn_in_packet <= #TCQ 1'b0;
  end
  else begin
    if(trn_tsof && trn_tsrc_rdy && trn_tdst_rdy && !trn_teof) begin
      trn_in_packet <= #TCQ 1'b1;
    end
    else if((trn_in_packet && trn_teof && trn_tsrc_rdy) || !trn_lnk_up) begin
      trn_in_packet <= #TCQ 1'b0;
    end
  end
end
always @(posedge user_clk) begin
  if(user_rst) begin
    axi_in_packet <= #TCQ 1'b0;
  end
  else begin
    if(axi_beat_live && !s_axis_tx_tlast) begin
      axi_in_packet <= #TCQ 1'b1;
    end
    else if(axi_beat_live) begin
      axi_in_packet <= #TCQ 1'b0;
    end
  end
end
generate
  if(C_PM_PRIORITY == "TRUE") begin : pm_priority_trn_flush
    always @(posedge user_clk) begin
      if(user_rst) begin
        reg_disable_trn    <= #TCQ 1'b1;
      end
      else begin
        if(!trn_lnk_up)
        begin
          reg_disable_trn  <= #TCQ 1'b1;
        end
        else if(!flush_axi && s_axis_tx_tready) begin
          reg_disable_trn <= #TCQ 1'b0;
        end
      end
    end
    assign disable_trn = reg_disable_trn;
  end
  else begin : thrtl_ctl_trn_flush
    always @(posedge user_clk) begin
      if(user_rst) begin
        reg_disable_trn    <= #TCQ 1'b0;
      end
      else begin
        if(axi_in_packet && !trn_lnk_up && !axi_end_packet)
        begin
          reg_disable_trn  <= #TCQ 1'b1;
        end
        else if(axi_end_packet) begin
          reg_disable_trn <= #TCQ 1'b0;
        end
      end
    end
    assign disable_trn = reg_disable_trn || !trn_lnk_up;
  end
endgenerate
generate
  if(C_DATA_WIDTH == 128) begin : tkeep_to_trem_128
    wire   axi_DW_1    = reg_tkeep[7];
    wire   axi_DW_2    = reg_tkeep[11];
    wire   axi_DW_3    = reg_tkeep[15];
    assign trn_trem[1] = axi_DW_2;
    assign trn_trem[0] = axi_DW_3 || (axi_DW_1 && !axi_DW_2);
  end
  else if(C_DATA_WIDTH == 64) begin : tkeep_to_trem_64
    assign trn_trem    = reg_tkeep[7];
  end
  else begin : tkeep_to_trem_32
    assign trn_trem    = 1'b0;
  end
endgenerate
assign trn_teof      = reg_tlast;
assign trn_tecrc_gen = reg_tuser[0];
assign trn_terrfwd   = reg_tuser[1];
assign trn_tstr      = reg_tuser[2];
assign trn_tsrc_dsc  = reg_tuser[3];
generate
  reg reg_tsrc_rdy;
  if(C_PM_PRIORITY == "FALSE") begin : throttle_ctl_pipeline
    always @(posedge user_clk) begin
      if(user_rst) begin
        reg_tdata        <= #TCQ {C_DATA_WIDTH{1'b0}};
        reg_tvalid       <= #TCQ 1'b0;
        reg_tkeep        <= #TCQ {KEEP_WIDTH{1'b0}};
        reg_tlast        <= #TCQ 1'b0;
        reg_tuser        <= #TCQ 4'h0;
        reg_tsrc_rdy     <= #TCQ 1'b0;
      end
      else begin
        reg_tdata        <= #TCQ s_axis_tx_tdata;
        reg_tvalid       <= #TCQ s_axis_tx_tvalid;
        reg_tkeep        <= #TCQ s_axis_tx_tkeep;
        reg_tlast        <= #TCQ s_axis_tx_tlast;
        reg_tuser        <= #TCQ s_axis_tx_tuser;
        reg_tsrc_rdy     <= #TCQ axi_beat_live && !disable_trn;
      end
    end
    assign trn_tsrc_rdy = reg_tsrc_rdy;
    assign s_axis_tx_tready = tready_thrtl;
  end
  else begin : pm_prioity_pipeline
    reg  [C_DATA_WIDTH-1:0] tdata_prev;
    reg                     tvalid_prev;
    reg    [KEEP_WIDTH-1:0] tkeep_prev;
    reg                     tlast_prev;
    reg               [3:0] tuser_prev;
    reg                     reg_tdst_rdy;
    wire                    data_hold;
    reg                     data_prev;
    always @(posedge user_clk) begin
      if(user_rst) begin
        tdata_prev   <= #TCQ {C_DATA_WIDTH{1'b0}};
        tvalid_prev  <= #TCQ 1'b0;
        tkeep_prev   <= #TCQ {KEEP_WIDTH{1'b0}};
        tlast_prev   <= #TCQ 1'b0;
        tuser_prev   <= #TCQ 4'h 0;
      end
      else begin
        if(!s_axis_tx_tready) begin
          tdata_prev   <= #TCQ tdata_prev;
          tvalid_prev  <= #TCQ tvalid_prev;
          tkeep_prev   <= #TCQ tkeep_prev;
          tlast_prev   <= #TCQ tlast_prev;
          tuser_prev   <= #TCQ tuser_prev;
        end
        else begin
          tdata_prev   <= #TCQ s_axis_tx_tdata;
          tvalid_prev  <= #TCQ s_axis_tx_tvalid;
          tkeep_prev   <= #TCQ s_axis_tx_tkeep;
          tlast_prev   <= #TCQ s_axis_tx_tlast;
          tuser_prev   <= #TCQ s_axis_tx_tuser;
        end
      end
    end
    always @(posedge user_clk) begin
      if(user_rst) begin
        reg_tdata  <= #TCQ {C_DATA_WIDTH{1'b0}};
        reg_tvalid <= #TCQ 1'b0;
        reg_tkeep  <= #TCQ {KEEP_WIDTH{1'b0}};
        reg_tlast  <= #TCQ 1'b0;
        reg_tuser  <= #TCQ 4'h0;
        reg_tdst_rdy <= #TCQ 1'b0;
      end
      else begin
        reg_tdst_rdy <= #TCQ trn_tdst_rdy;
        if(!data_hold) begin
          if(data_prev) begin
            reg_tdata  <= #TCQ tdata_prev;
            reg_tvalid <= #TCQ tvalid_prev;
            reg_tkeep  <= #TCQ tkeep_prev;
            reg_tlast  <= #TCQ tlast_prev;
            reg_tuser  <= #TCQ tuser_prev;
          end
          else begin
            reg_tdata  <= #TCQ s_axis_tx_tdata;
            reg_tvalid <= #TCQ s_axis_tx_tvalid;
            reg_tkeep  <= #TCQ s_axis_tx_tkeep;
            reg_tlast  <= #TCQ s_axis_tx_tlast;
            reg_tuser  <= #TCQ s_axis_tx_tuser;
          end
        end
      end
    end
    assign data_hold = trn_tsrc_rdy && !trn_tdst_rdy;
    always @(posedge user_clk) begin
      if(user_rst) begin
        data_prev <= #TCQ 1'b0;
      end
      else begin
        data_prev <= #TCQ data_hold;
      end
    end
    assign trn_tsrc_rdy = reg_tvalid && !disable_trn;
    always @(posedge user_clk) begin
      if(user_rst) begin
        reg_tready <= #TCQ 1'b0;
      end
      else begin
        if(flush_axi && !axi_end_packet) begin
          reg_tready <= #TCQ 1'b1;
        end
        else if(trn_lnk_up) begin
          reg_tready <= #TCQ trn_tdst_rdy || !trn_tsrc_rdy;
        end
        else begin
          reg_tready <= #TCQ 1'b0;
        end
      end
    end
    assign s_axis_tx_tready = reg_tready;
  end
  always @(posedge user_clk) begin
    if(user_rst) begin
      flush_axi    <= #TCQ 1'b0;
    end
    else begin
      if(axi_in_packet && !trn_lnk_up && !axi_end_packet) begin
        flush_axi <= #TCQ 1'b1;
      end
      else if(axi_end_packet) begin
        flush_axi <= #TCQ 1'b0;
      end
    end
  end
endgenerate
endmodule
