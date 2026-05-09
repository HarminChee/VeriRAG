`timescale 1ns/1ns
`define TCQ 1
`define PIO_64_RX_MEM_RD32_FMT_TYPE 7'b00_00000
`define PIO_64_RX_MEM_WR32_FMT_TYPE 7'b10_00000
`define PIO_64_RX_MEM_RD64_FMT_TYPE 7'b01_00000
`define PIO_64_RX_MEM_WR64_FMT_TYPE 7'b11_00000
`define PIO_64_RX_IO_RD32_FMT_TYPE  7'b00_00010
`define PIO_64_RX_IO_WR32_FMT_TYPE  7'b10_00010
`define PIO_64_RX_RST_STATE         8'b00000000
`define PIO_64_RX_MEM_RD32_DW1DW2   8'b00000001
`define PIO_64_RX_MEM_WR32_DW1DW2   8'b00000100
`define PIO_64_RX_MEM_RD64_DW1DW2   8'b01000001
`define PIO_64_RX_MEM_RD64_DW3      8'b01000011
`define PIO_64_RX_MEM_WR64_DW1DW2   8'b01000100
`define PIO_64_RX_MEM_WR64_DW3      8'b01010000
`define PIO_64_RX_WAIT_STATE        8'b10000000
`timescale 1ns/1ns
`define TCQ 1
`define PIO_64_RX_MEM_RD32_FMT_TYPE 7'b00_00000
`define PIO_64_RX_MEM_WR32_FMT_TYPE 7'b10_00000
`define PIO_64_RX_MEM_RD64_FMT_TYPE 7'b01_00000
`define PIO_64_RX_MEM_WR64_FMT_TYPE 7'b11_00000
`define PIO_64_RX_IO_RD32_FMT_TYPE  7'b00_00010
`define PIO_64_RX_IO_WR32_FMT_TYPE  7'b10_00010
`define PIO_64_RX_RST_STATE         8'b00000000
`define PIO_64_RX_MEM_RD32_DW1DW2   8'b00000001
`define PIO_64_RX_MEM_WR32_DW1DW2   8'b00000100
`define PIO_64_RX_MEM_RD64_DW1DW2   8'b01000001
`define PIO_64_RX_MEM_RD64_DW3      8'b01000011
`define PIO_64_RX_MEM_WR64_DW1DW2   8'b01000100
`define PIO_64_RX_MEM_WR64_DW3      8'b01010000
`define PIO_64_RX_WAIT_STATE        8'b10000000
module PIO_64_RX_ENGINE (
                        clk,
                        rst_n,
                        trn_rd,
                        trn_rrem_n,
                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rbar_hit_n,
                        trn_rdst_rdy_n,
                        req_compl_o,
                        compl_done_i,
                        req_tc_o,                  
                        req_td_o,                  
                        req_ep_o,                  
                        req_attr_o,                
                        req_len_o,                 
                        req_rid_o,                 
                        req_tag_o,                 
                        req_be_o,                  
                        req_addr_o,                
                        wr_addr_o,                 
                        wr_be_o,                   
                        wr_data_o,                 
                        wr_en_o,                   
                        wr_busy_i                  
                       );
    input              clk;
    input              rst_n;
    input [63:0]       trn_rd;
    input [7:0]        trn_rrem_n;
    input              trn_rsof_n;
    input              trn_reof_n;
    input              trn_rsrc_rdy_n;
    input              trn_rsrc_dsc_n;
    input [6:0]        trn_rbar_hit_n;
    output             trn_rdst_rdy_n;
    output             req_compl_o;
    input              compl_done_i;
    output [2:0]       req_tc_o;
    output             req_td_o;
    output             req_ep_o;
    output [1:0]       req_attr_o;
    output [9:0]       req_len_o;
    output [15:0]      req_rid_o;
    output [7:0]       req_tag_o;
    output [7:0]       req_be_o;
    output [12:0]      req_addr_o;
    output [10:0]      wr_addr_o;
    output [7:0]       wr_be_o;
    output [31:0]      wr_data_o;
    output             wr_en_o;
    input              wr_busy_i;
    reg                trn_rdst_rdy_n;
    reg                req_compl_o;
    reg [2:0]          req_tc_o;
    reg                req_td_o;
    reg                req_ep_o;
    reg [1:0]          req_attr_o;
    reg [9:0]          req_len_o;
    reg [15:0]         req_rid_o;
    reg [7:0]          req_tag_o;
    reg [7:0]          req_be_o;
    reg [12:0]         req_addr_o;
    reg [10:0]         wr_addr_o;
    reg [7:0]          wr_be_o;
    reg [31:0]         wr_data_o;
    reg                wr_en_o;
    reg [7:0]          state;
    reg [7:0]          tlp_type;
    wire               io_bar_hit_n;
    wire               mem32_bar_hit_n;
    wire               mem64_bar_hit_n;
    wire               erom_bar_hit_n;
    reg [1:0]          region_select;
    always @ ( posedge clk ) begin
        if (!rst_n ) begin
          trn_rdst_rdy_n <= #`TCQ 1'b0;
          req_compl_o    <= #`TCQ 1'b0;
          req_tc_o       <= #`TCQ 2'b0;
          req_td_o       <= #`TCQ 1'b0;
          req_ep_o       <= #`TCQ 1'b0;
          req_attr_o     <= #`TCQ 2'b0;
          req_len_o      <= #`TCQ 10'b0;
          req_rid_o      <= #`TCQ 16'b0;
          req_tag_o      <= #`TCQ 8'b0;
          req_be_o       <= #`TCQ 8'b0;
          req_addr_o     <= #`TCQ 13'b0;
          wr_be_o        <= #`TCQ 8'b0;
          wr_addr_o      <= #`TCQ 11'b0;
          wr_data_o      <= #`TCQ 31'b0;
          wr_en_o        <= #`TCQ 1'b0;
          state          <= #`TCQ `PIO_64_RX_RST_STATE;
          tlp_type       <= #`TCQ 7'b0;
        end else begin
          wr_en_o        <= #`TCQ 1'b0;
          req_compl_o    <= #`TCQ 1'b0;
          case (state)
            `PIO_64_RX_RST_STATE : begin
              trn_rdst_rdy_n <= #`TCQ 1'b0;
              if ((!trn_rsof_n) &&
                  (!trn_rsrc_rdy_n) && 
                  (!trn_rdst_rdy_n)) begin
                case (trn_rd[62:56])
                  `PIO_64_RX_MEM_RD32_FMT_TYPE : begin
                    tlp_type     <= #`TCQ trn_rd[63:56];
                    req_len_o    <= #`TCQ trn_rd[41:32];
                    trn_rdst_rdy_n <= #`TCQ 1'b1;
                    if (trn_rd[41:32] == 10'b1) begin
                      req_tc_o     <= #`TCQ trn_rd[54:52];  
                      req_td_o     <= #`TCQ trn_rd[47];
                      req_ep_o     <= #`TCQ trn_rd[46]; 
                      req_attr_o   <= #`TCQ trn_rd[45:44];
                      req_len_o    <= #`TCQ trn_rd[41:32];
                      req_rid_o    <= #`TCQ trn_rd[31:16];
                      req_tag_o    <= #`TCQ trn_rd[15:08]; 
                      req_be_o     <= #`TCQ trn_rd[07:00];
                      state        <= #`TCQ `PIO_64_RX_MEM_RD32_DW1DW2;
                    end else begin
                      state        <= #`TCQ `PIO_64_RX_RST_STATE;
                    end
                  end
                  `PIO_64_RX_MEM_WR32_FMT_TYPE : begin
                    tlp_type     <= #`TCQ trn_rd[63:56];
                    req_len_o    <= #`TCQ trn_rd[41:32]; 
                    trn_rdst_rdy_n <= #`TCQ 1'b1;
                    if (trn_rd[41:32] == 10'b1) begin
                      wr_be_o      <= #`TCQ trn_rd[07:00];
                      state        <= #`TCQ `PIO_64_RX_MEM_WR32_DW1DW2;
                    end else begin
                      state        <= #`TCQ `PIO_64_RX_RST_STATE;
                    end
                  end
                  `PIO_64_RX_MEM_RD64_FMT_TYPE : begin
                    tlp_type     <= #`TCQ trn_rd[63:56];
                    req_len_o    <= #`TCQ trn_rd[41:32];
                    trn_rdst_rdy_n <= #`TCQ 1'b1;
                    if (trn_rd[41:32] == 10'b1) begin
                      req_tc_o     <= #`TCQ trn_rd[54:52];  
                      req_td_o     <= #`TCQ trn_rd[47];
                      req_ep_o     <= #`TCQ trn_rd[46]; 
                      req_attr_o   <= #`TCQ trn_rd[45:44];
                      req_len_o    <= #`TCQ trn_rd[41:32];
                      req_rid_o    <= #`TCQ trn_rd[31:16];
                      req_tag_o    <= #`TCQ trn_rd[15:08]; 
                      req_be_o     <= #`TCQ trn_rd[07:00];
                      state        <= #`TCQ `PIO_64_RX_MEM_RD64_DW1DW2;
                    end else begin
                      state        <= #`TCQ `PIO_64_RX_RST_STATE;
                    end
                  end
                  `PIO_64_RX_MEM_WR64_FMT_TYPE : begin
                    tlp_type     <= #`TCQ trn_rd[63:56];
                    req_len_o    <= #`TCQ trn_rd[41:32]; 
                    if (trn_rd[41:32] == 10'b1) begin
                      wr_be_o      <= #`TCQ trn_rd[07:00];
                      state        <= #`TCQ `PIO_64_RX_MEM_WR64_DW1DW2;
                    end else begin
                      state        <= #`TCQ `PIO_64_RX_RST_STATE; 
                    end
                  end 
                  `PIO_64_RX_IO_RD32_FMT_TYPE : begin
                    tlp_type     <= #`TCQ trn_rd[63:56];
                    req_len_o    <= #`TCQ trn_rd[41:32];
                    trn_rdst_rdy_n <= #`TCQ 1'b1;
                    if (trn_rd[41:32] == 10'b1) begin
                      req_tc_o     <= #`TCQ trn_rd[54:52];  
                      req_td_o     <= #`TCQ trn_rd[47];
                      req_ep_o     <= #`TCQ trn_rd[46]; 
                      req_attr_o   <= #`TCQ trn_rd[45:44]; 
                      req_len_o    <= #`TCQ trn_rd[41:32];
                      req_rid_o    <= #`TCQ trn_rd[31:16]; 
                      req_tag_o    <= #`TCQ trn_rd[15:08];
                      req_be_o     <= #`TCQ trn_rd[07:00]; 
                      state        <= #`TCQ `PIO_64_RX_MEM_RD32_DW1DW2;
                    end else begin
                      state        <= #`TCQ `PIO_64_RX_RST_STATE; 
                    end
                  end
                  `PIO_64_RX_IO_WR32_FMT_TYPE : begin
                    tlp_type     <= #`TCQ trn_rd[63:56];
                    req_len_o    <= #`TCQ trn_rd[41:32];
                    trn_rdst_rdy_n <= #`TCQ 1'b1;
                    if (trn_rd[41:32] == 10'b1) begin
                      wr_be_o      <= #`TCQ trn_rd[07:00];
                      state        <= #`TCQ `PIO_64_RX_MEM_WR32_DW1DW2; 
                    end else begin
                      state        <= #`TCQ `PIO_64_RX_RST_STATE;
                    end
                  end
                  default : begin 
                    state        <= #`TCQ `PIO_64_RX_RST_STATE; 
                  end
                endcase
              end else
                state <= #`TCQ `PIO_64_RX_RST_STATE;
            end
            `PIO_64_RX_MEM_RD32_DW1DW2 : begin
              if (!trn_rsrc_rdy_n) begin
                trn_rdst_rdy_n <= #`TCQ 1'b1;
                req_addr_o   <= #`TCQ {region_select[1:0],trn_rd[42:34], 2'b00};
                req_compl_o  <= #`TCQ 1'b1;
                state        <= #`TCQ `PIO_64_RX_WAIT_STATE;
              end else
                state        <= #`TCQ `PIO_64_RX_MEM_RD32_DW1DW2; 
            end
            `PIO_64_RX_MEM_WR32_DW1DW2 : begin
              if (!trn_rsrc_rdy_n) begin
                wr_data_o      <= #`TCQ trn_rd[31:0];
                wr_en_o        <= #`TCQ 1'b1;
                trn_rdst_rdy_n <= #`TCQ 1'b1;
                wr_addr_o      <= #`TCQ {region_select[1:0],trn_rd[42:34]};
                state          <= #`TCQ  `PIO_64_RX_WAIT_STATE;
              end else
                state          <= #`TCQ `PIO_64_RX_MEM_WR32_DW1DW2;
            end
            `PIO_64_RX_MEM_RD64_DW1DW2 : begin
              if (!trn_rsrc_rdy_n) begin
                req_addr_o   <= #`TCQ {region_select[1:0],trn_rd[10:2], 2'b00};
                req_compl_o  <= #`TCQ 1'b1;
                trn_rdst_rdy_n <= #`TCQ 1'b1;
                state        <= #`TCQ `PIO_64_RX_WAIT_STATE; 
              end else
                state        <= #`TCQ `PIO_64_RX_MEM_RD64_DW1DW2;
            end
            `PIO_64_RX_MEM_WR64_DW1DW2 : begin
              if (!trn_rsrc_rdy_n) begin
                trn_rdst_rdy_n <= #`TCQ 1'b1;
                wr_addr_o      <= #`TCQ {region_select[1:0],trn_rd[10:2]};
                state          <= #`TCQ  `PIO_64_RX_MEM_WR64_DW3;
              end else
                state          <= #`TCQ `PIO_64_RX_MEM_WR64_DW1DW2; 
            end
            `PIO_64_RX_MEM_WR64_DW3 : begin
              if (!trn_rsrc_rdy_n) begin
                wr_data_o      <= #`TCQ trn_rd[63:32];
                wr_en_o        <= #`TCQ 1'b1;
                trn_rdst_rdy_n <= #`TCQ 1'b1;
                state        <= #`TCQ `PIO_64_RX_WAIT_STATE; 
              end else 
                 state        <= #`TCQ `PIO_64_RX_MEM_WR64_DW3;
            end
            `PIO_64_RX_WAIT_STATE : begin
              wr_en_o      <= #`TCQ 1'b0;
              req_compl_o  <= #`TCQ 1'b0;
              if ((tlp_type == `PIO_64_RX_MEM_WR32_FMT_TYPE) &&
                  (!wr_busy_i)) begin
                trn_rdst_rdy_n <= #`TCQ 1'b0;
                state        <= #`TCQ `PIO_64_RX_RST_STATE; 
             end else if ((tlp_type == `PIO_64_RX_IO_WR32_FMT_TYPE) &&
                  (!wr_busy_i)) begin
                trn_rdst_rdy_n <= #`TCQ 1'b0;
                state        <= #`TCQ `PIO_64_RX_RST_STATE;
              end else if ((tlp_type == `PIO_64_RX_MEM_WR64_FMT_TYPE) &&
                  (!wr_busy_i)) begin
                trn_rdst_rdy_n <= #`TCQ 1'b0;
                state        <= #`TCQ `PIO_64_RX_RST_STATE; 
              end else if ((tlp_type == `PIO_64_RX_MEM_RD32_FMT_TYPE) &&
                           (compl_done_i)) begin
                trn_rdst_rdy_n <= #`TCQ 1'b0;
                state        <= #`TCQ `PIO_64_RX_RST_STATE;
              end else if ((tlp_type == `PIO_64_RX_IO_RD32_FMT_TYPE) &&
                           (compl_done_i)) begin
                trn_rdst_rdy_n <= #`TCQ 1'b0;
                state        <= #`TCQ `PIO_64_RX_RST_STATE; 
              end else if ((tlp_type == `PIO_64_RX_MEM_RD64_FMT_TYPE) &&
                           (compl_done_i)) begin
                trn_rdst_rdy_n <= #`TCQ 1'b0;
                state        <= #`TCQ `PIO_64_RX_RST_STATE; 
              end else
                state        <= #`TCQ `PIO_64_RX_WAIT_STATE;
            end
          endcase
        end
    end
     assign mem64_bar_hit_n = 1'b1;
    assign io_bar_hit_n = 1'b1;
    assign mem32_bar_hit_n = trn_rbar_hit_n[0];
    assign erom_bar_hit_n  = trn_rbar_hit_n[6];
  always @*
  begin
     case ({io_bar_hit_n, mem32_bar_hit_n, mem64_bar_hit_n, erom_bar_hit_n})
        4'b0111 : begin
             region_select <= #`TCQ 2'b00;    
        end
        4'b1011 : begin
             region_select <= #`TCQ 2'b01;    
        end
        4'b1101 : begin
             region_select <= #`TCQ 2'b10;    
        end
        4'b1110 : begin
             region_select <= #`TCQ 2'b11;    
        end
        default : begin
             region_select <= #`TCQ 2'b00;    
        end
     endcase
  end
  reg  [8*20:1] state_ascii;
  always @(state)
  begin
    if      (state==`PIO_64_RX_RST_STATE)         state_ascii <= #`TCQ "RX_RST_STATE";
    else if (state==`PIO_64_RX_MEM_RD32_DW1DW2)   state_ascii <= #`TCQ "RX_MEM_RD32_DW1DW2";
    else if (state==`PIO_64_RX_MEM_WR32_DW1DW2)   state_ascii <= #`TCQ "RX_MEM_WR32_DW1DW2";
    else if (state==`PIO_64_RX_MEM_RD64_DW1DW2)   state_ascii <= #`TCQ "RX_MEM_RD64_DW1DW2";
    else if (state==`PIO_64_RX_MEM_RD64_DW3)      state_ascii <= #`TCQ "RX_MEM_RD64_DW3";
    else if (state==`PIO_64_RX_MEM_WR64_DW1DW2)   state_ascii <= #`TCQ "RX_MEM_WR64_DW1DW2";
    else if (state==`PIO_64_RX_MEM_WR64_DW3)      state_ascii <= #`TCQ "RX_MEM_WR64_DW3";
    else if (state==`PIO_64_RX_WAIT_STATE)        state_ascii <= #`TCQ "RX_WAIT_STATE";
    else                                          state_ascii <= #`TCQ "PIO 64 STATE ERR";
  end
endmodule 
