`timescale 1ps/1ps
`timescale 1ps/1ps
module PIO_RX_ENGINE  #(
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
  output reg         req_compl,
  output reg         req_compl_wd,
  input              compl_done,
  output reg [2:0]   req_tc,                        
  output reg         req_td,                        
  output reg         req_ep,                        
  output reg [1:0]   req_attr,                      
  output reg [9:0]   req_len,                       
  output reg [15:0]  req_rid,                       
  output reg [7:0]   req_tag,                       
  output reg [7:0]   req_be,                        
  output reg [12:0]  req_addr,                      
  output reg [10:0]  wr_addr,                       
  output reg [7:0]   wr_be,                         
  output reg [31:0]  wr_data,                       
  output reg         wr_en,                         
  input              wr_busy                        
);
  localparam PIO_RX_MEM_RD32_FMT_TYPE = 7'b00_00000;
  localparam PIO_RX_MEM_WR32_FMT_TYPE = 7'b10_00000;
  localparam PIO_RX_MEM_RD64_FMT_TYPE = 7'b01_00000;
  localparam PIO_RX_MEM_WR64_FMT_TYPE = 7'b11_00000;
  localparam PIO_RX_IO_RD32_FMT_TYPE  = 7'b00_00010;
  localparam PIO_RX_IO_WR32_FMT_TYPE  = 7'b10_00010;
  localparam PIO_RX_RST_STATE            = 8'b00000000;
  localparam PIO_RX_MEM_RD32_DW1DW2      = 8'b00000001;
  localparam PIO_RX_MEM_WR32_DW1DW2      = 8'b00000010;
  localparam PIO_RX_MEM_RD64_DW1DW2      = 8'b00000100;
  localparam PIO_RX_MEM_WR64_DW1DW2      = 8'b00001000;
  localparam PIO_RX_MEM_WR64_DW3         = 8'b00010000;
  localparam PIO_RX_WAIT_STATE           = 8'b00100000;
  localparam PIO_RX_IO_WR_DW1DW2         = 8'b01000000;
  localparam PIO_RX_IO_MEM_WR_WAIT_STATE = 8'b10000000;
  reg [7:0]          state;
  reg [7:0]          tlp_type;
  wire               io_bar_hit_n;
  wire               mem32_bar_hit_n;
  wire               mem64_bar_hit_n;
  wire               erom_bar_hit_n;
  reg [1:0]          region_select;
  generate
    if (C_DATA_WIDTH == 64) begin : pio_rx_sm_64
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
        if (!rst_n )
        begin
          m_axis_rx_tready <= #TCQ 1'b0;
          req_compl    <= #TCQ 1'b0;
          req_compl_wd <= #TCQ 1'b1;
          req_tc       <= #TCQ 3'b0;
          req_td       <= #TCQ 1'b0;
          req_ep       <= #TCQ 1'b0;
          req_attr     <= #TCQ 2'b0;
          req_len      <= #TCQ 10'b0;
          req_rid      <= #TCQ 16'b0;
          req_tag      <= #TCQ 8'b0;
          req_be       <= #TCQ 8'b0;
          req_addr     <= #TCQ 13'b0;
          wr_be        <= #TCQ 8'b0;
          wr_addr      <= #TCQ 11'b0;
          wr_data      <= #TCQ 32'b0;
          wr_en        <= #TCQ 1'b0;
          state        <= #TCQ PIO_RX_RST_STATE;
          tlp_type     <= #TCQ 8'b0;
        end
        else
        begin
          wr_en        <= #TCQ 1'b0;
          req_compl    <= #TCQ 1'b0;
          case (state)
            PIO_RX_RST_STATE : begin
              m_axis_rx_tready <= #TCQ 1'b1;
              req_compl_wd     <= #TCQ 1'b1;
              if (sop)
              begin
                case (m_axis_rx_tdata[30:24])
                  PIO_RX_MEM_RD32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len      <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1)
                    begin
                      req_tc     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td     <= #TCQ m_axis_rx_tdata[15];
                      req_ep     <= #TCQ m_axis_rx_tdata[14];
                      req_attr   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be     <= #TCQ m_axis_rx_tdata[39:32];
                      state      <= #TCQ PIO_RX_MEM_RD32_DW1DW2;
                    end 
                    else
                    begin
                      state        <= #TCQ PIO_RX_RST_STATE;
                    end 
                  end 
                  PIO_RX_MEM_WR32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len      <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1)
                    begin
                      wr_be      <= #TCQ m_axis_rx_tdata[39:32];
                      state      <= #TCQ PIO_RX_MEM_WR32_DW1DW2;
                    end 
                    else
                    begin
                      state      <= #TCQ PIO_RX_RST_STATE;
                    end 
                  end 
                  PIO_RX_MEM_RD64_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len      <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1)
                    begin
                      req_tc     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td     <= #TCQ m_axis_rx_tdata[15];
                      req_ep     <= #TCQ m_axis_rx_tdata[14];
                      req_attr   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be     <= #TCQ m_axis_rx_tdata[39:32];
                      state        <= #TCQ PIO_RX_MEM_RD64_DW1DW2;
                    end 
                    else
                    begin
                      state      <= #TCQ PIO_RX_RST_STATE;
                    end 
                  end 
                  PIO_RX_MEM_WR64_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len      <= #TCQ m_axis_rx_tdata[9:0];
                    if (m_axis_rx_tdata[9:0] == 10'b1) begin
                      wr_be      <= #TCQ m_axis_rx_tdata[39:32];
                      state      <= #TCQ PIO_RX_MEM_WR64_DW1DW2;
                    end 
                    else
                    begin
                      state      <= #TCQ PIO_RX_RST_STATE;
                    end 
                  end 
                  PIO_RX_IO_RD32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len      <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1)
                    begin
                      req_tc     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td     <= #TCQ m_axis_rx_tdata[15];
                      req_ep     <= #TCQ m_axis_rx_tdata[14];
                      req_attr   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be     <= #TCQ m_axis_rx_tdata[39:32];
                      state      <= #TCQ PIO_RX_MEM_RD32_DW1DW2;
                    end 
                    else
                    begin
                      state      <= #TCQ PIO_RX_RST_STATE;
                    end 
                  end 
                  PIO_RX_IO_WR32_FMT_TYPE : begin
                    tlp_type     <= #TCQ m_axis_rx_tdata[31:24];
                    req_len      <= #TCQ m_axis_rx_tdata[9:0];
                    m_axis_rx_tready <= #TCQ 1'b0;
                    if (m_axis_rx_tdata[9:0] == 10'b1)
                    begin
                      req_tc     <= #TCQ m_axis_rx_tdata[22:20];
                      req_td     <= #TCQ m_axis_rx_tdata[15];
                      req_ep     <= #TCQ m_axis_rx_tdata[14];
                      req_attr   <= #TCQ m_axis_rx_tdata[13:12];
                      req_len    <= #TCQ m_axis_rx_tdata[9:0];
                      req_rid    <= #TCQ m_axis_rx_tdata[63:48];
                      req_tag    <= #TCQ m_axis_rx_tdata[47:40];
                      req_be     <= #TCQ m_axis_rx_tdata[39:32];
                      wr_be      <= #TCQ m_axis_rx_tdata[39:32];
                      state      <= #TCQ PIO_RX_IO_WR_DW1DW2;
                    end 
                    else
                    begin
                      state        <= #TCQ PIO_RX_RST_STATE;
                    end 
                  end 
                  default : begin 
                    state        <= #TCQ PIO_RX_RST_STATE;
                  end 
                endcase
              end 
              else
                  state <= #TCQ PIO_RX_RST_STATE;
            end 
            PIO_RX_MEM_RD32_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                m_axis_rx_tready <= #TCQ 1'b0;
                req_addr     <= #TCQ {region_select[1:0],m_axis_rx_tdata[10:2], 2'b00};
                req_compl    <= #TCQ 1'b1;
                req_compl_wd <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_WAIT_STATE;
              end 
              else
                state        <= #TCQ PIO_RX_MEM_RD32_DW1DW2;
            end 
            PIO_RX_MEM_WR32_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                wr_data      <= #TCQ m_axis_rx_tdata[63:32];
                wr_en        <= #TCQ 1'b1;
                m_axis_rx_tready <= #TCQ 1'b0;
                wr_addr      <= #TCQ {region_select[1:0],m_axis_rx_tdata[10:2]};
                state        <= #TCQ  PIO_RX_WAIT_STATE;
              end 
              else
                state        <= #TCQ PIO_RX_MEM_WR32_DW1DW2;
            end 
            PIO_RX_MEM_RD64_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                req_addr     <= #TCQ {region_select[1:0],m_axis_rx_tdata[42:34], 2'b00};
                req_compl    <= #TCQ 1'b1;
                req_compl_wd <= #TCQ 1'b1;
                m_axis_rx_tready <= #TCQ 1'b0;
                state        <= #TCQ PIO_RX_WAIT_STATE;
              end 
              else
                state        <= #TCQ PIO_RX_MEM_RD64_DW1DW2;
            end 
            PIO_RX_MEM_WR64_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                m_axis_rx_tready <= #TCQ 1'b0;
                wr_addr        <= #TCQ {region_select[1:0],m_axis_rx_tdata[42:34]};
                state          <= #TCQ  PIO_RX_MEM_WR64_DW3;
              end 
              else
                state          <= #TCQ PIO_RX_MEM_WR64_DW1DW2;
            end 
            PIO_RX_MEM_WR64_DW3 : begin
              if (m_axis_rx_tvalid)
              begin
                wr_data      <= #TCQ m_axis_rx_tdata[31:0];
                wr_en        <= #TCQ 1'b1;
                m_axis_rx_tready <= #TCQ 1'b0;
                state        <= #TCQ PIO_RX_WAIT_STATE;
              end 
              else
                 state        <= #TCQ PIO_RX_MEM_WR64_DW3;
            end 
            PIO_RX_IO_WR_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                wr_data         <= #TCQ m_axis_rx_tdata[63:32];
                wr_en           <= #TCQ 1'b1;
                m_axis_rx_tready  <= #TCQ 1'b0;
                wr_addr         <= #TCQ {region_select[1:0],m_axis_rx_tdata[10:2]};
                req_compl       <= #TCQ 1'b1;
                req_compl_wd    <= #TCQ 1'b0;
                state             <= #TCQ  PIO_RX_WAIT_STATE;
              end 
              else
                state             <= #TCQ PIO_RX_IO_WR_DW1DW2;
            end 
            PIO_RX_WAIT_STATE : begin
              wr_en      <= #TCQ 1'b0;
              req_compl  <= #TCQ 1'b0;
              if ((tlp_type == PIO_RX_MEM_WR32_FMT_TYPE) && (!wr_busy))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_IO_WR32_FMT_TYPE) && (!wr_busy))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_MEM_WR64_FMT_TYPE) && (!wr_busy))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_MEM_RD32_FMT_TYPE) && (compl_done))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_IO_RD32_FMT_TYPE) && (compl_done))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_MEM_RD64_FMT_TYPE) && (compl_done))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else
                state        <= #TCQ PIO_RX_WAIT_STATE;
            end 
            default : begin
              state        <= #TCQ PIO_RX_RST_STATE;
            end 
          endcase
        end
      end
    end
    else if (C_DATA_WIDTH == 128) begin : pio_rx_sm_128
      wire               sof_present = m_axis_rx_tuser[14];
      wire               sof_right = !m_axis_rx_tuser[13] && sof_present;
      wire               sof_mid = m_axis_rx_tuser[13] && sof_present;
      always @ ( posedge clk ) begin
        if (!rst_n )
        begin
          m_axis_rx_tready <= #TCQ 1'b0;
          req_compl    <= #TCQ 1'b0;
          req_compl_wd <= #TCQ 1'b1;
          req_tc       <= #TCQ 3'b0;
          req_td       <= #TCQ 1'b0;
          req_ep       <= #TCQ 1'b0;
          req_attr     <= #TCQ 2'b0;
          req_len      <= #TCQ 10'b0;
          req_rid      <= #TCQ 16'b0;
          req_tag      <= #TCQ 8'b0;
          req_be       <= #TCQ 8'b0;
          req_addr     <= #TCQ 13'b0;
          wr_be        <= #TCQ 8'b0;
          wr_addr      <= #TCQ 11'b0;
          wr_data      <= #TCQ 32'b0;
          wr_en        <= #TCQ 1'b0;
          state        <= #TCQ PIO_RX_RST_STATE;
          tlp_type     <= #TCQ 8'b0;
        end 
        else
        begin
          wr_en        <= #TCQ 1'b0;
          req_compl    <= #TCQ 1'b0;
          case (state)
            PIO_RX_RST_STATE : begin
              m_axis_rx_tready  <= #TCQ 1'b1;
              state             <= #TCQ PIO_RX_RST_STATE;
              req_compl_wd      <= #TCQ 1'b1;
              if ((m_axis_rx_tvalid) && (m_axis_rx_tready))
              begin
                if (sof_mid)
                begin
                  tlp_type          <= #TCQ m_axis_rx_tdata[95:88];
                  req_len           <= #TCQ m_axis_rx_tdata[73:64];
                  m_axis_rx_tready  <= #TCQ 1'b0;
                  case (m_axis_rx_tdata[94:88])
                    PIO_RX_MEM_RD32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[73:64] == 10'b1)
                      begin
                        req_tc       <= #TCQ m_axis_rx_tdata[86:84];
                        req_td       <= #TCQ m_axis_rx_tdata[79];
                        req_ep       <= #TCQ m_axis_rx_tdata[78];
                        req_attr     <= #TCQ m_axis_rx_tdata[77:76];
                        req_len      <= #TCQ m_axis_rx_tdata[73:64];
                        req_rid      <= #TCQ m_axis_rx_tdata[127:112];
                        req_tag      <= #TCQ m_axis_rx_tdata[111:104];
                        req_be       <= #TCQ m_axis_rx_tdata[103:96];
                        state        <= #TCQ PIO_RX_MEM_RD32_DW1DW2;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_MEM_WR32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[73:64] == 10'b1)
                      begin
                        wr_be        <= #TCQ m_axis_rx_tdata[103:96];
                        state        <= #TCQ PIO_RX_MEM_WR32_DW1DW2;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_MEM_RD64_FMT_TYPE : begin
                      if (m_axis_rx_tdata[73:64] == 10'b1)
                      begin
                        req_tc       <= #TCQ m_axis_rx_tdata[86:84];
                        req_td       <= #TCQ m_axis_rx_tdata[79];
                        req_ep       <= #TCQ m_axis_rx_tdata[78];
                        req_attr     <= #TCQ m_axis_rx_tdata[77:76];
                        req_len      <= #TCQ m_axis_rx_tdata[73:64];
                        req_rid      <= #TCQ m_axis_rx_tdata[127:112];
                        req_tag      <= #TCQ m_axis_rx_tdata[111:104];
                        req_be       <= #TCQ m_axis_rx_tdata[103:96];
                        state        <= #TCQ PIO_RX_MEM_RD64_DW1DW2;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_MEM_WR64_FMT_TYPE : begin
                      if (m_axis_rx_tdata[73:64] == 10'b1)
                      begin
                        wr_be        <= #TCQ m_axis_rx_tdata[103:96];
                        state        <= #TCQ PIO_RX_MEM_WR64_DW1DW2;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_IO_RD32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[73:64] == 10'b1)
                      begin
                        req_tc       <= #TCQ m_axis_rx_tdata[86:84];
                        req_td       <= #TCQ m_axis_rx_tdata[79];
                        req_ep       <= #TCQ m_axis_rx_tdata[78];
                        req_attr     <= #TCQ m_axis_rx_tdata[77:76];
                        req_len      <= #TCQ m_axis_rx_tdata[73:64];
                        req_rid      <= #TCQ m_axis_rx_tdata[127:112];
                        req_tag      <= #TCQ m_axis_rx_tdata[111:104];
                        req_be       <= #TCQ m_axis_rx_tdata[103:96];
                        state        <= #TCQ PIO_RX_MEM_RD32_DW1DW2;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_IO_WR32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[73:64] == 10'b1)
                      begin
                        req_tc       <= #TCQ m_axis_rx_tdata[86:84];
                        req_td       <= #TCQ m_axis_rx_tdata[79];
                        req_ep       <= #TCQ m_axis_rx_tdata[78];
                        req_attr     <= #TCQ m_axis_rx_tdata[77:76];
                        req_len      <= #TCQ m_axis_rx_tdata[73:64];
                        req_rid      <= #TCQ m_axis_rx_tdata[127:112];
                        req_tag      <= #TCQ m_axis_rx_tdata[111:104];
                        wr_be        <= #TCQ m_axis_rx_tdata[103:96];
                        state        <= #TCQ PIO_RX_MEM_WR32_DW1DW2;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    default : begin 
                      state        <= #TCQ PIO_RX_RST_STATE;
                    end 
                  endcase 
                end
                else if (sof_right)
                begin
                  tlp_type        <= #TCQ m_axis_rx_tdata[31:24];
                  req_len         <= #TCQ m_axis_rx_tdata[9:0];
                  m_axis_rx_tready  <= #TCQ 1'b0;
                  case (m_axis_rx_tdata[30:24])
                    PIO_RX_MEM_RD32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[9:0] == 10'b1)
                      begin
                        req_tc       <= #TCQ m_axis_rx_tdata[22:20];
                        req_td       <= #TCQ m_axis_rx_tdata[15];
                        req_ep       <= #TCQ m_axis_rx_tdata[14];
                        req_attr     <= #TCQ m_axis_rx_tdata[13:12];
                        req_len      <= #TCQ m_axis_rx_tdata[9:0];
                        req_rid      <= #TCQ m_axis_rx_tdata[63:48];
                        req_tag      <= #TCQ m_axis_rx_tdata[47:40];
                        req_be       <= #TCQ m_axis_rx_tdata[39:32];
                        req_addr     <= #TCQ {region_select[1:0],
                                                 m_axis_rx_tdata[74:66],2'b00};
                        req_compl    <= #TCQ 1'b1;
                        req_compl_wd <= #TCQ 1'b1;
                        state        <= #TCQ PIO_RX_WAIT_STATE;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_MEM_WR32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[9:0] == 10'b1)
                      begin
                        wr_be        <= #TCQ m_axis_rx_tdata[39:32];
                        wr_data      <= #TCQ m_axis_rx_tdata[127:96];
                        wr_en        <= #TCQ 1'b1;
                        wr_addr      <= #TCQ {region_select[1:0], m_axis_rx_tdata[74:66]};
                        wr_en        <= #TCQ 1'b1;
                        state        <= #TCQ PIO_RX_WAIT_STATE;
                      end 
                      else
                      begin
                          state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_MEM_RD64_FMT_TYPE : begin
                      if (m_axis_rx_tdata[9:0] == 10'b1)
                      begin
                        req_tc       <= #TCQ m_axis_rx_tdata[22:20];
                        req_td       <= #TCQ m_axis_rx_tdata[15];
                        req_ep       <= #TCQ m_axis_rx_tdata[14];
                        req_attr     <= #TCQ m_axis_rx_tdata[13:12];
                        req_len      <= #TCQ m_axis_rx_tdata[9:0];
                        req_rid      <= #TCQ m_axis_rx_tdata[63:48];
                        req_tag      <= #TCQ m_axis_rx_tdata[47:40];
                        req_be       <= #TCQ m_axis_rx_tdata[39:32];
                        req_addr     <= #TCQ {region_select[1:0], m_axis_rx_tdata[74:66],2'b00};
                        req_compl    <= #TCQ 1'b1;
                        req_compl_wd <= #TCQ 1'b1;
                        state        <= #TCQ PIO_RX_WAIT_STATE;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_MEM_WR64_FMT_TYPE : begin
                      if (m_axis_rx_tdata[9:0] == 10'b1)
                      begin
                        wr_be        <= #TCQ m_axis_rx_tdata[39:32];
                        wr_addr      <= #TCQ {region_select[1:0], m_axis_rx_tdata[74:66]};
                        state        <= #TCQ PIO_RX_MEM_WR64_DW3;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_WAIT_STATE;
                      end 
                    end 
                    PIO_RX_IO_RD32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[9:0] == 10'b1)
                      begin
                        req_tc       <= #TCQ m_axis_rx_tdata[22:20];
                        req_td       <= #TCQ m_axis_rx_tdata[15];
                        req_ep       <= #TCQ m_axis_rx_tdata[14];
                        req_attr     <= #TCQ m_axis_rx_tdata[13:12];
                        req_len      <= #TCQ m_axis_rx_tdata[9:0];
                        req_rid      <= #TCQ m_axis_rx_tdata[63:48];
                        req_tag      <= #TCQ m_axis_rx_tdata[47:40];
                        req_be       <= #TCQ m_axis_rx_tdata[39:32];
                        req_addr     <= #TCQ {region_select[1:0], m_axis_rx_tdata[74:66],2'b00};
                        req_compl    <= #TCQ 1'b1;
                        req_compl_wd <= #TCQ 1'b1;
                        state        <= #TCQ PIO_RX_WAIT_STATE;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                    PIO_RX_IO_WR32_FMT_TYPE : begin
                      if (m_axis_rx_tdata[9:0] == 10'b1)
                      begin
                        wr_be        <= #TCQ m_axis_rx_tdata[39:32];
                        req_tc       <= #TCQ m_axis_rx_tdata[22:20];
                        req_td       <= #TCQ m_axis_rx_tdata[15];
                        req_ep       <= #TCQ m_axis_rx_tdata[14];
                        req_attr     <= #TCQ m_axis_rx_tdata[13:12];
                        req_len      <= #TCQ m_axis_rx_tdata[9:0];
                        req_rid      <= #TCQ m_axis_rx_tdata[63:48];
                        req_tag      <= #TCQ m_axis_rx_tdata[47:40];
                        wr_data      <= #TCQ m_axis_rx_tdata[127:96];
                        wr_en        <= #TCQ 1'b1;
                        wr_addr      <= #TCQ {region_select[1:0], m_axis_rx_tdata[74:66]};
                        wr_en        <= #TCQ 1'b1;
                        req_compl    <= #TCQ 1'b1;
                        req_compl_wd <= #TCQ 1'b0;
                        state        <= #TCQ PIO_RX_WAIT_STATE;
                      end 
                      else
                      begin
                        state        <= #TCQ PIO_RX_RST_STATE;
                      end 
                    end 
                  endcase 
                end 
              end
              else 
                state <= #TCQ PIO_RX_RST_STATE;
            end 
            PIO_RX_MEM_WR64_DW3 : begin
              if (m_axis_rx_tvalid)
              begin
                wr_data        <= #TCQ m_axis_rx_tdata[31:0];
                wr_en          <= #TCQ 1'b1;
                state          <= #TCQ PIO_RX_WAIT_STATE;
              end 
              else
              begin
                state          <= #TCQ PIO_RX_MEM_WR64_DW3;
              end 
            end 
            PIO_RX_MEM_RD32_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                m_axis_rx_tready  <= #TCQ 1'b0;
                req_addr          <= #TCQ {region_select[1:0], m_axis_rx_tdata[10:2], 2'b00};
                req_compl         <= #TCQ 1'b1;
                req_compl_wd      <= #TCQ 1'b1;
                state             <= #TCQ PIO_RX_WAIT_STATE;
              end 
              else
              begin
                state             <= #TCQ PIO_RX_MEM_RD32_DW1DW2;
              end 
            end 
            PIO_RX_MEM_WR32_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                wr_data           <= #TCQ m_axis_rx_tdata[63:32];
                wr_en             <= #TCQ 1'b1;
                m_axis_rx_tready  <= #TCQ 1'b0;
                wr_addr           <= #TCQ {region_select[1:0], m_axis_rx_tdata[10:2]};
                state             <= #TCQ  PIO_RX_WAIT_STATE;
              end 
              else
              begin
                state             <= #TCQ PIO_RX_MEM_WR32_DW1DW2;
              end 
            end 
            PIO_RX_IO_WR_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                wr_data           <= #TCQ m_axis_rx_tdata[63:32];
                wr_en             <= #TCQ 1'b1;
                m_axis_rx_tready  <= #TCQ 1'b0;
                wr_addr           <= #TCQ {region_select[1:0], m_axis_rx_tdata[10:2]};
                req_compl         <= #TCQ 1'b1;
                req_compl_wd      <= #TCQ 1'b0;
                state             <= #TCQ  PIO_RX_WAIT_STATE;
              end 
              else
              begin
                state             <= #TCQ PIO_RX_MEM_WR32_DW1DW2;
              end 
            end 
            PIO_RX_MEM_RD64_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                req_addr         <= #TCQ {region_select[1:0], m_axis_rx_tdata[10:2], 2'b00};
                req_compl        <= #TCQ 1'b1;
                req_compl_wd     <= #TCQ 1'b1;
                m_axis_rx_tready <= #TCQ 1'b0;
                state            <= #TCQ PIO_RX_WAIT_STATE;
              end 
              else
              begin
                state        <= #TCQ PIO_RX_MEM_RD64_DW1DW2;
              end 
            end 
            PIO_RX_MEM_WR64_DW1DW2 : begin
              if (m_axis_rx_tvalid)
              begin
                m_axis_rx_tready  <= #TCQ 1'b0;
                wr_addr           <= #TCQ {region_select[1:0], m_axis_rx_tdata[10:2]};
                wr_data           <= #TCQ m_axis_rx_tdata[95:64];
                wr_en             <= #TCQ 1'b1;
                state             <= #TCQ PIO_RX_WAIT_STATE;
              end 
              else
              begin
                state            <= #TCQ PIO_RX_MEM_WR64_DW1DW2;
              end 
            end 
            PIO_RX_WAIT_STATE : begin
              wr_en      <= #TCQ 1'b0;
              req_compl  <= #TCQ 1'b0;
              if ((tlp_type == PIO_RX_MEM_WR32_FMT_TYPE) &&(!wr_busy))
              begin
                m_axis_rx_tready  <= #TCQ 1'b1;
                state             <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_IO_WR32_FMT_TYPE) && (!wr_busy))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_MEM_WR64_FMT_TYPE) && (!wr_busy))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_MEM_RD32_FMT_TYPE) && (compl_done))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_IO_RD32_FMT_TYPE) && (compl_done))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else if ((tlp_type == PIO_RX_MEM_RD64_FMT_TYPE) && (compl_done))
              begin
                m_axis_rx_tready <= #TCQ 1'b1;
                state        <= #TCQ PIO_RX_RST_STATE;
              end 
              else
              begin
                state        <= #TCQ PIO_RX_WAIT_STATE;
              end
            end 
            default : begin
              state        <= #TCQ PIO_RX_RST_STATE;
            end 
          endcase
        end 
      end 
    end 
  endgenerate
assign  mem64_bar_hit_n = 1'b1;
assign  io_bar_hit_n = 1'b1;
assign  mem32_bar_hit_n = ~(m_axis_rx_tuser[2]);
assign  erom_bar_hit_n  = ~(m_axis_rx_tuser[8]);
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
      PIO_RX_RST_STATE              : state_ascii <= #TCQ "RX_RST_STATE";
      PIO_RX_MEM_RD32_DW1DW2        : state_ascii <= #TCQ "RX_MEM_RD32_DW1DW2";
      PIO_RX_MEM_WR32_DW1DW2        : state_ascii <= #TCQ "RX_MEM_WR32_DW1DW2";
      PIO_RX_MEM_RD64_DW1DW2        : state_ascii <= #TCQ "RX_MEM_RD64_DW1DW2";
      PIO_RX_MEM_WR64_DW1DW2        : state_ascii <= #TCQ "RX_MEM_WR64_DW1DW2";
      PIO_RX_MEM_WR64_DW3           : state_ascii <= #TCQ "RX_MEM_WR64_DW3";
      PIO_RX_WAIT_STATE             : state_ascii <= #TCQ "RX_WAIT_STATE";
      PIO_RX_IO_WR_DW1DW2           : state_ascii <= #TCQ "RX_IO_WR_DW1DW2";
      PIO_RX_IO_MEM_WR_WAIT_STATE   : state_ascii <= #TCQ "RX_IO_MEM_WR_WAIT_STATE";
      default                       : state_ascii <= #TCQ "PIO 128 STATE ERR";
    endcase
  end
endmodule 
