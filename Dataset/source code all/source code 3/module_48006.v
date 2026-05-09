`timescale 1ps/1ps
`timescale 1ps/1ps
module PIO_TX_ENGINE    #(
  parameter C_DATA_WIDTH = 64,
  parameter TCQ = 1,
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8
)(
  input             clk,
  input             rst_n,
  input                           s_axis_tx_tready,
  output  reg [C_DATA_WIDTH-1:0]  s_axis_tx_tdata,
  output  reg [KEEP_WIDTH-1:0]    s_axis_tx_tkeep,
  output  reg                     s_axis_tx_tlast,
  output  reg                     s_axis_tx_tvalid,
  output                          tx_src_dsc,
  input                           req_compl,
  input                           req_compl_wd,
  output reg                      compl_done,
  input [2:0]                     req_tc,
  input                           req_td,
  input                           req_ep,
  input [1:0]                     req_attr,
  input [9:0]                     req_len,
  input [15:0]                    req_rid,
  input [7:0]                     req_tag,
  input [7:0]                     req_be,
  input [12:0]                    req_addr,
  output [10:0]                   rd_addr,
  output [3:0]                    rd_be,
  input  [31:0]                   rd_data,
  input [15:0]                    completer_id
);
localparam PIO_CPLD_FMT_TYPE = 7'b10_01010;
localparam PIO_CPL_FMT_TYPE  = 7'b00_01010;
localparam PIO_TX_RST_STATE  = 1'b0;
localparam PIO_TX_CPLD_QW1   = 1'b1;
  reg [11:0]              byte_count;
  reg [6:0]               lower_addr;
  reg                     req_compl_q;
  reg                     req_compl_wd_q;
  reg                     req_compl_q2;
  reg                     req_compl_wd_q2;
  wire                    compl_wd;
  assign tx_src_dsc = 1'b0;
  assign rd_addr = req_addr[12:2];
  assign rd_be =   req_be[3:0];
  always @ (rd_be) begin
    casex (rd_be[3:0])
      4'b1xx1 : byte_count = 12'h004;
      4'b01x1 : byte_count = 12'h003;
      4'b1x10 : byte_count = 12'h003;
      4'b0011 : byte_count = 12'h002;
      4'b0110 : byte_count = 12'h002;
      4'b1100 : byte_count = 12'h002;
      4'b0001 : byte_count = 12'h001;
      4'b0010 : byte_count = 12'h001;
      4'b0100 : byte_count = 12'h001;
      4'b1000 : byte_count = 12'h001;
      4'b0000 : byte_count = 12'h001;
    endcase
  end
  always @ ( posedge clk ) begin
    if (!rst_n ) 
    begin
      req_compl_q      <= #TCQ 1'b0;
      req_compl_wd_q   <= #TCQ 1'b1;
    end 
    else
    begin
      req_compl_q      <= #TCQ req_compl;
      req_compl_wd_q   <= #TCQ req_compl_wd;
    end 
  end
  generate
    if (C_DATA_WIDTH == 128) begin : init_128
      always @ ( posedge clk ) begin
        if (!rst_n ) 
        begin
          req_compl_q2      <= #TCQ 1'b0;
          req_compl_wd_q2   <= #TCQ 1'b0;
        end 
        else
        begin
          req_compl_q2      <= #TCQ req_compl_q;
          req_compl_wd_q2   <= #TCQ req_compl_wd_q;
        end 
      end
    end
  endgenerate
  generate
    if (C_DATA_WIDTH == 64) begin : cd_64
      assign compl_wd = req_compl_wd_q;
    end
    else if (C_DATA_WIDTH == 128) begin : cd_128
      assign compl_wd = req_compl_wd_q2;
    end
  endgenerate
  always @ (rd_be or req_addr or compl_wd) begin
    casex ({compl_wd, rd_be[3:0]})
      5'b0_xxxx : lower_addr = 8'h0;
      5'bx_0000 : lower_addr = {req_addr[6:2], 2'b00};
      5'bx_xxx1 : lower_addr = {req_addr[6:2], 2'b00};
      5'bx_xx10 : lower_addr = {req_addr[6:2], 2'b01};
      5'bx_x100 : lower_addr = {req_addr[6:2], 2'b10};
      5'bx_1000 : lower_addr = {req_addr[6:2], 2'b11};
    endcase 
  end
  generate
    if (C_DATA_WIDTH == 64) begin : gen_cpl_64
      reg                     state;
      always @ ( posedge clk ) begin
        if (!rst_n ) 
        begin
          s_axis_tx_tlast   <= #TCQ 1'b0;
          s_axis_tx_tvalid  <= #TCQ 1'b0;
          s_axis_tx_tdata   <= #TCQ {C_DATA_WIDTH{1'b0}};
          s_axis_tx_tkeep   <= #TCQ {KEEP_WIDTH{1'b1}};
          compl_done        <= #TCQ 1'b0;
          state             <= #TCQ PIO_TX_RST_STATE;
        end 
        else
        begin
          case ( state )
            PIO_TX_RST_STATE : begin
              if (req_compl_q) 
              begin
                s_axis_tx_tlast  <= #TCQ 1'b0;
                s_axis_tx_tvalid <= #TCQ 1'b1;
                s_axis_tx_tdata  <= #TCQ {                      
                                      completer_id,             
                                      {3'b0},                   
                                      {1'b0},                   
                                      byte_count,               
                                      {1'b0},                   
                                      (req_compl_wd_q ?
                                      PIO_CPLD_FMT_TYPE :
                                      PIO_CPL_FMT_TYPE),        
                                      {1'b0},                   
                                      req_tc,                   
                                      {4'b0},                   
                                      req_td,                   
                                      req_ep,                   
                                      req_attr,                 
                                      {2'b0},                   
                                      req_len                   
                                      };
                s_axis_tx_tkeep   <= #TCQ 8'hFF;
                if (s_axis_tx_tready)
                  state             <= #TCQ PIO_TX_CPLD_QW1;
                else
                  state             <= #TCQ PIO_TX_RST_STATE;
              end 
              else
              begin
                s_axis_tx_tlast   <= #TCQ 1'b0;
                s_axis_tx_tvalid  <= #TCQ 1'b0;
                s_axis_tx_tdata   <= #TCQ 64'b0;
                s_axis_tx_tkeep   <= #TCQ 8'hFF;
                compl_done        <= #TCQ 1'b0;
                state             <= #TCQ PIO_TX_RST_STATE;
              end 
            end 
            PIO_TX_CPLD_QW1 : begin
              if (s_axis_tx_tready)
              begin
                s_axis_tx_tlast  <= #TCQ 1'b1;
                s_axis_tx_tvalid <= #TCQ 1'b1;
                s_axis_tx_tdata  <= #TCQ {        
                                      rd_data,    
                                      req_rid,    
                                      req_tag,    
                                      {1'b0},     
                                      lower_addr  
                                      };
                if (req_compl_wd_q)
                  s_axis_tx_tkeep <= #TCQ 8'hFF;
                else
                  s_axis_tx_tkeep <= #TCQ 8'h0F;
                compl_done        <= #TCQ 1'b1;
                state             <= #TCQ PIO_TX_RST_STATE;
              end 
              else
                state             <= #TCQ PIO_TX_CPLD_QW1;
            end 
            default : begin
              state             <= #TCQ PIO_TX_RST_STATE;
            end
          endcase
        end 
      end
    end
    else if (C_DATA_WIDTH == 128) begin : gen_cpl_128
      reg                     hold_state;
      always @ ( posedge clk ) begin
        if (!rst_n ) 
        begin
          s_axis_tx_tlast   <= #TCQ 1'b0;
          s_axis_tx_tvalid  <= #TCQ 1'b0;
          s_axis_tx_tdata   <= #TCQ {C_DATA_WIDTH{1'b0}};
          s_axis_tx_tkeep   <= #TCQ {KEEP_WIDTH{1'b1}};
          compl_done        <= #TCQ 1'b0;
          hold_state        <= #TCQ 1'b0;
        end 
        else
        begin
          if (req_compl_q2 | hold_state)
          begin
            if (s_axis_tx_tready) 
            begin
              s_axis_tx_tlast   <= #TCQ 1'b1;
              s_axis_tx_tvalid  <= #TCQ 1'b1;
              s_axis_tx_tdata   <= #TCQ {                   
                                  rd_data,                  
                                  req_rid,                  
                                  req_tag,                  
                                  {1'b0},                   
                                  lower_addr,               
                                  completer_id,             
                                  {3'b0},                   
                                  {1'b0},                   
                                  byte_count,               
                                  {1'b0},                   
                                  (req_compl_wd_q2 ?
                                  PIO_CPLD_FMT_TYPE :
                                  PIO_CPL_FMT_TYPE),        
                                  {1'b0},                   
                                  req_tc,                   
                                  {4'b0},                   
                                  req_td,                   
                                  req_ep,                   
                                  req_attr,                 
                                  {2'b0},                   
                                  req_len                   
                                  };
              if (req_compl_wd_q2)
                s_axis_tx_tkeep   <= #TCQ 16'hFFFF;
              else
                s_axis_tx_tkeep   <= #TCQ 16'h0FFF;
              compl_done        <= #TCQ 1'b1;
              hold_state        <= #TCQ 1'b0;
            end 
            else
              hold_state        <= #TCQ 1'b1;
          end 
          else
          begin
            s_axis_tx_tlast   <= #TCQ 1'b0;
            s_axis_tx_tvalid  <= #TCQ 1'b0;
            s_axis_tx_tdata   <= #TCQ {C_DATA_WIDTH{1'b0}};
            s_axis_tx_tkeep   <= #TCQ {KEEP_WIDTH{1'b1}};
            compl_done        <= #TCQ 1'b0;
          end 
        end 
      end
    end
  endgenerate
endmodule 
