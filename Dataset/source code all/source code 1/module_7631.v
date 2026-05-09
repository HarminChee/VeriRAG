`timescale 1ns/1ns
`timescale 1ns/1ns
module PIO_64_RX_ENGINE  #(
  parameter TCQ = 1,
  parameter C_DATA_WIDTH = 64,            
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8               
) (
  input                         clk,
  input                         rst_n,
  input  [C_DATA_WIDTH-1:0]     m_axis_rx_tdata,
  input  [KEEP_WIDTH-1:0]       m_axis_rx_tkeep,
  input                         m_axis_rx_tlast,
  input                         m_axis_rx_tvalid,
  output reg                    m_axis_rx_tready,
  input    [21:0]               m_axis_rx_tuser,
  output reg         req_compl_o,
  output reg         req_compl_wd_o,
  input              compl_done_i,
  output reg [2:0]   req_tc_o,                        
  output reg         req_td_o,                        
  output reg         req_ep_o,                        
  output reg [1:0]   req_attr_o,                      
  output reg [9:0]   req_len_o,                       
  output reg [15:0]  req_rid_o,                       
  output reg [7:0]   req_tag_o,                       
  output reg [7:0]   req_be_o,                        
  output reg [12:0]  req_addr_o,                      
  output reg [10:0]  wr_addr_o,                       
  output reg [7:0]   wr_be_o,                         
  output reg [31:0]  wr_data_o,                       
  output reg         wr_en_o,                         
  input              wr_busy_i                        
);
localparam PIO_64_RX_MEM_RD32_FMT_TYPE = 7'b00_00000;
localparam PIO_64_RX_MEM_WR32_FMT_TYPE = 7'b10_00000;
localparam PIO_64_RX_MEM_RD64_FMT_TYPE = 7'b01_00000;
localparam PIO_64_RX_MEM_WR64_FMT_TYPE = 7'b11_00000;
localparam PIO_64_RX_IO_RD32_FMT_TYPE  = 7'b00_00010;
localparam PIO_64_RX_IO_WR32_FMT_TYPE  = 7'b10_00010;
localparam PIO_64_RX_RST_STATE            = 8'b00000000;
localparam PIO_64_RX_MEM_RD32_DW1DW2      = 8'b00000001;
localparam PIO_64_RX_MEM_WR32_DW1DW2      = 8'b00000010;
localparam PIO_64_RX_MEM_RD64_DW1DW2      = 8'b00000100;
localparam PIO_64_RX_MEM_WR64_DW1DW2      = 8'b00001000;
localparam PIO_64_RX_MEM_WR64_DW3         = 8'b00010000;
localparam PIO_64_RX_WAIT_STATE           = 8'b00100000;
localparam PIO_64_RX_IO_WR_DW1DW2         = 8'b01000000;
localparam PIO_64_RX_IO_MEM_WR_WAIT_STATE = 8'b10000000;
    reg [7:0]          state;
    reg [7:0]          tlp_type;
    wire               io_bar_hit_n;
    wire               mem32_bar_hit_n;
    wire               mem64_bar_hit_n;
    wire               erom_bar_hit_n;
    reg [1:0]          region_select;
    wire               sop;                   
    reg                in_packet_q;
  always@(posedge clk)
    begin
      if(!rst_n)
        in_packet_q <= #   TCQ 1'b0;
      else if (m_axis_rx_tvalid && m_axis_rx_tready && m_axis_rx_tlast)
        in_packet_q <= #   TCQ 1'b0;
      else if (sop && m_axis_rx_tready)
        in_packet_q <= #   TCQ 1'b1;
    end
  assign sop = !in_packet_q && m_axis_rx_tvalid;
    always @ ( posedge clk ) begin
        if (!rst_n ) begin
          m_axis_rx_tready <= #TCQ 1'b0;
          req_compl_o    <= #TCQ 1'b0;
          req_compl_wd_o <= #TCQ 1'b1;
          req_tc_o       <= #TCQ 3'b0;
          req_td_o       <= #TCQ 1'b0;
          req_ep_o       <= #TCQ 1'b0;
          req_attr_o     <= #TCQ 2'b0;
          req_len_o      <= #TCQ 10'b0;
          req_rid_o      <= #TCQ 16'b0;
          req_tag_o      <= #TCQ 8'b0;
          req_be_o       <= #TCQ 8'b0;
          req_addr_o     <= #TCQ 13'b0;
          wr_be_o        <= #TCQ 8'b0;
          wr_addr_o      <= #TCQ 11'b0;
          wr_data_o      <= #TCQ 32'b0;
          wr_en_o        <= #TCQ 1'b0;
          state          <= #TCQ PIO_64_RX_RST_STATE;
          tlp_type       <= #TCQ 8'b0;
        end else begin
          wr_en_o        <= #TCQ 1'b0;
          req_compl_o    <= #TCQ 1'b0;
          case (state)
            PIO_64_RX_RST_STATE : begin
              m_axis_rx_tready <= #TCQ 1'b1;
              req_compl_wd_o   <= #TCQ 1'b1;
              if (sop) begin
                case (m_axis_rx_tdata[30:24])
                  PIO_64_RX_MEM_RD32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1) begin
                      req_tc_o     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td_o     <= #TCQ m_axis_rx_tdata[15];
                      req_ep_o     <= #TCQ m_axis_rx_tdata[14];
                      req_attr_o   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid_o    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag_o    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be_o     <= #TCQ m_axis_rx_tdata[39:32];
                      state        <= #TCQ PIO_64_RX_MEM_RD32_DW1DW2;
                    end else begin
                      state        <= #TCQ PIO_64_RX_RST_STATE;
                    end
                  end
                  PIO_64_RX_MEM_WR32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1) begin
                      wr_be_o      <= #TCQ m_axis_rx_tdata[39:32];
                      state        <= #TCQ PIO_64_RX_MEM_WR32_DW1DW2;
                    end else begin
                      state        <= #TCQ PIO_64_RX_RST_STATE;
                    end
                  end
                  PIO_64_RX_MEM_RD64_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1) begin
                      req_tc_o     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td_o     <= #TCQ m_axis_rx_tdata[15];
                      req_ep_o     <= #TCQ m_axis_rx_tdata[14];
                      req_attr_o   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid_o    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag_o    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be_o     <= #TCQ m_axis_rx_tdata[39:32];
                      state        <= #TCQ PIO_64_RX_MEM_RD64_DW1DW2;
                    end else begin
                      state        <= #TCQ PIO_64_RX_RST_STATE;
                    end
                  end
                  PIO_64_RX_MEM_WR64_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                    if (m_axis_rx_tdata[9:0] == 10'b1) begin
                      wr_be_o      <= #TCQ m_axis_rx_tdata[39:32];
                      state        <= #TCQ PIO_64_RX_MEM_WR64_DW1DW2;
                    end else begin
                      state        <= #TCQ PIO_64_RX_RST_STATE;
                    end
                  end
                  PIO_64_RX_IO_RD32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1) begin
                      req_tc_o     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td_o     <= #TCQ m_axis_rx_tdata[15];
                      req_ep_o     <= #TCQ m_axis_rx_tdata[14];
                      req_attr_o   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid_o    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag_o    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be_o     <= #TCQ m_axis_rx_tdata[39:32];
                      state        <= #TCQ PIO_64_RX_MEM_RD32_DW1DW2;
                    end else begin
                      state        <= #TCQ PIO_64_RX_RST_STATE;
                    end
                  end
                  PIO_64_RX_IO_WR32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1) begin
                      req_tc_o     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td_o     <= #TCQ m_axis_rx_tdata[15];
                      req_ep_o     <= #TCQ m_axis_rx_tdata[14];
                      req_attr_o   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len_o    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid_o    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag_o    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be_o     <= #TCQ m_axis_rx_tdata[39:32];
                      wr_be_o      <= #TCQ m_axis_rx_tdata[39:32];
                      state        <= #TCQ PIO_64_RX_IO_WR_DW1DW2;
                    end else begin
                      state        <= #TCQ PIO_64_RX_RST_STATE;
                    end
                  end
                  default : begin 
                    state        <= #TCQ PIO_64_RX_RST_STATE;
                  end
                endcase
              end else
                state <= #TCQ PIO_64_RX_RST_STATE;
            end
            PIO_64_RX_MEM_RD32_DW1DW2 : begin
              if (m_axis_rx_tvalid) begin
                m_axis_rx_tready <= #TCQ 1'b0;
                req_addr_o   <= #TCQ {region_select[1:0],m_axis_rx_tdata[10:2], 2'b00};
                req_compl_o  <= #TCQ 1'b1;
                req_compl_wd_o <= #TCQ 1'b1;
                state        <= #TCQ PIO_64_RX_WAIT_STATE;
              end else
                state        <= #TCQ PIO_64_RX_MEM_RD32_DW1DW2;
            end
            PIO_64_RX_MEM_WR32_DW1DW2 : begin
              if (m_axis_rx_tvalid) begin
                wr_data_o      <= #TCQ m_axis_rx_tdata[63:32];
                wr_en_o        <= #TCQ 1'b1;
                m_axis_rx_tready <= #TCQ 1'b0;
                wr_addr_o      <= #TCQ {region_select[1:0],m_axis_rx_tdata[10:2]};
                state          <= #TCQ  PIO_64_RX_WAIT_STATE;
              end else
                state          <= #TCQ PIO_64_RX_MEM_WR32_DW1DW2;
            end
            PIO_64_RX_MEM_RD64_DW1DW2 : begin
              if (m_axis_rx_tvalid) begin
                req_addr_o   <= #TCQ {region_select[1:0],m_axis_rx_tdata[42:34], 2'b00};
                req_compl_o  <= #TCQ 1'b1;
                req_compl_wd_o <= #TCQ 1'b1;
                m_axis_rx_tready <= #TCQ 1'b0;
                state        <= #TCQ PIO_64_RX_WAIT_STATE;
              end else
                state        <= #TCQ PIO_64_RX_MEM_RD64_DW1DW2;
            end
            PIO_64_RX_MEM_WR64_DW1DW2 : begin
              if (m_axis_rx_tvalid) begin
                m_axis_rx_tready <= #TCQ 1'b0;
                wr_addr_o      <= #TCQ {region_select[1:0],m_axis_rx_tdata[42:34]};
                state          <= #TCQ  PIO_64_RX_MEM_WR64_DW3;
              end else
                state          <= #TCQ PIO_64_RX_MEM_WR64_DW1DW2;
            end
            PIO_64_RX_MEM_WR64_DW3 : begin
              if (m_axis_rx_tvalid) begin
                wr_data_o      <= #TCQ m_axis_rx_tdata[31:0];
                wr_en_o        <= #TCQ 1'b1;
                m_axis_rx_tready <= #TCQ 1'b0;
                state        <= #TCQ PIO_64_RX_WAIT_STATE;
              end else
                 state        <= #TCQ PIO_64_RX_MEM_WR64_DW3;
            end
            PIO_64_RX_IO_WR_DW1DW2 : begin
              if (m_axis_rx_tvalid) begin
                wr_data_o         <= #TCQ m_axis_rx_tdata[63:32];
                wr_en_o           <= #TCQ 1'b1;
                m_axis_rx_tready  <= #TCQ 1'b0;
                wr_addr_o         <= #TCQ {region_select[1:0],m_axis_rx_tdata[10:2]};
                req_compl_o       <= #TCQ 1'b1;
                req_compl_wd_o    <= #TCQ 1'b0;
                state             <= #TCQ  PIO_64_RX_WAIT_STATE;
              end else
                state             <= #TCQ PIO_64_RX_IO_WR_DW1DW2;
            end
            PIO_64_RX_WAIT_STATE : begin
              wr_en_o      <= #TCQ 1'b0;
              req_compl_o  <= #TCQ 1'b0;
              if ((tlp_type == PIO_64_RX_MEM_WR32_FMT_TYPE) &&
                  (!wr_busy_i)) begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_64_RX_RST_STATE;
             end else if ((tlp_type == PIO_64_RX_IO_WR32_FMT_TYPE) &&
                  (!wr_busy_i)) begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_64_RX_RST_STATE;
              end else if ((tlp_type == PIO_64_RX_MEM_WR64_FMT_TYPE) &&
                  (!wr_busy_i)) begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_64_RX_RST_STATE;
              end else if ((tlp_type == PIO_64_RX_MEM_RD32_FMT_TYPE) &&
                           (compl_done_i)) begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_64_RX_RST_STATE;
              end else if ((tlp_type == PIO_64_RX_IO_RD32_FMT_TYPE) &&
                           (compl_done_i)) begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_64_RX_RST_STATE;
              end else if ((tlp_type == PIO_64_RX_MEM_RD64_FMT_TYPE) &&
                           (compl_done_i)) begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_64_RX_RST_STATE;
              end else
                state        <= #TCQ PIO_64_RX_WAIT_STATE;
            end
          endcase
        end
    end
    assign mem64_bar_hit_n = ~m_axis_rx_tuser[2];
    assign io_bar_hit_n = ~m_axis_rx_tuser[5];
    assign mem32_bar_hit_n = ~m_axis_rx_tuser[4];
    assign erom_bar_hit_n  = !m_axis_rx_tuser[8];
  always @*
  begin
     case ({io_bar_hit_n, mem32_bar_hit_n, mem64_bar_hit_n, erom_bar_hit_n})
        4'b0111 : begin
             region_select <= #TCQ 2'b00;    
        end
        4'b1011 : begin
             region_select <= #TCQ 2'b01;    
        end
        4'b1101 : begin
             region_select <= #TCQ 2'b10;    
        end
        4'b1110 : begin
             region_select <= #TCQ 2'b11;    
        end
        default : begin
             region_select <= #TCQ 2'b00;    
        end
     endcase
  end
  reg  [8*20:1] state_ascii;
  always @(state)
  begin
    case (state)
      PIO_64_RX_RST_STATE             : state_ascii <= #TCQ "RX_RST_STATE";
      PIO_64_RX_MEM_RD32_DW1DW2       : state_ascii <= #TCQ "RX_MEM_RD32_DW1DW2";
      PIO_64_RX_MEM_WR32_DW1DW2       : state_ascii <= #TCQ "RX_MEM_WR32_DW1DW2";
      PIO_64_RX_MEM_RD64_DW1DW2       : state_ascii <= #TCQ "RX_MEM_RD64_DW1DW2";
      PIO_64_RX_MEM_WR64_DW1DW2       : state_ascii <= #TCQ "RX_MEM_WR64_DW1DW2";
      PIO_64_RX_MEM_WR64_DW3          : state_ascii <= #TCQ "RX_MEM_WR64_DW3";
      PIO_64_RX_WAIT_STATE            : state_ascii <= #TCQ "RX_WAIT_STATE";
      PIO_64_RX_IO_WR_DW1DW2          : state_ascii <= #TCQ "PIO_64_RX_IO_WR_DW1DW2";
      PIO_64_RX_IO_MEM_WR_WAIT_STATE  : state_ascii <= #TCQ "PIO_64_RX_IO_MEM_WR_WAIT_STATE";
      default                         : state_ascii <= #TCQ "PIO 64 STATE ERR";
    endcase
  end
endmodule 
