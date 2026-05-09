`timescale 1ns / 1ns
`default_nettype none
module bitec_reconfig_avalon_mm_master 
#(
  parameter XCVR = 1  
)
(
  input wire clk,
  input wire reset,
  input wire rcnf_req_cbus,               
  input wire rcnf_rel_cbus,               
  input wire rcnf_wcalib,                 
  input wire rcnf_scalib,                 
  input wire rcnf_lcalib,                 
  input wire rcnf_reconfig,               
  input wire rcnf_en,                     
  input wire [1:0] rcnf_logical_ch,       
  input wire [9:0] rcnf_address,          
  input wire [31:0] rcnf_data,            
  input wire [31:0] rcnf_mask,            
  input wire [1:0] rcnf_linkrate,         
  output wire rcnf_busy,                  
  output reg [1:0] mgmt_chnum,
  output reg [9:0] mgmt_address,
  output reg [31:0] mgmt_writedata,
  input wire [31:0] mgmt_readdata,
  output reg mgmt_write,
  output reg mgmt_read,
  input  wire mgmt_waitrequest,
  input  wire cal_busy
);
localparam ADDR_XCVR_BUS_ARB                = 10'h000,
           ADDR_XCVR_CDR_VCO_SPEED_FIX_7_6  = 10'h132,
           ADDR_XCVR_CHGPMP_PD_UP           = 10'h133,
           ADDR_XCVR_CDR_VCO_SPEED_FIX_4    = 10'h134,
           ADDR_XCVR_LF_PD_PFD              = 10'h135,  
           ADDR_XCVR_CDR_VCO_SPEED_FIX      = 10'h136,  
           ADDR_XCVR_CDR_VCO_SPEED          = 10'h137,
           ADDR_XCVR_CHGPMP_PD_DN           = 10'h139,
           ADDR_XCVR_CAL_BUSY               = 10'h281;
localparam  MASK_XCVR_LF_PD_PFD             = 32'h0000_004f,
            MASK_XCVR_CDR_VCO_SPEED_FIX_7_6 = 32'h0000_00F7,
            MASK_XCVR_CDR_VCO_SPEED_FIX_4   = 32'h0000_00F7,
            MASK_XCVR_CDR_VCO_SPEED_FIX     = 32'h0000_000f,
            MASK_XCVR_CDR_VCO_SPEED         = 32'h0000_007c,
            MASK_XCVR_CHGPMP_PD_UP          = 32'h0000_00E0,
            MASK_XCVR_CHGPMP_PD_DN          = 32'h0000_00BF;
localparam ADDR_TXPLL_BUS_ARB           = 10'h000,
           ADDR_TXPLL_VCO_BAND1         = 10'h10A,
           ADDR_TXPLL_VCO_BAND2         = 10'h10B,
           ADDR_TXPLL_CAL_BUSY          = 10'h280;
localparam  MASK_TXPLL_VCO_BAND1        = 32'h0000_001f,
            MASK_TXPLL_VCO_BAND2        = 32'h0000_00f8;
localparam  FSM_IDLE       = 6'd0,
            FSM_REQBUS_RD  = 6'd1,
            FSM_REQBUS_WR  = 6'd2,
            FSM_RELBUS_RD  = 6'd3,
            FSM_RELBUS_WR  = 6'd4,
            FSM_WCAL_RD    = 6'd5,
            FSM_WCAL_TST   = 6'd6,
            FSM_SCAL_RD1   = 6'd7,
            FSM_SCAL_RD2   = 6'd8,
            FSM_SCAL_RD3   = 6'd9,
            FSM_SCAL_RD4   = 6'd10,
            FSM_SCAL_RD5   = 6'd11,
            FSM_SCAL_RD6   = 6'd12,
            FSM_SCAL_RD7   = 6'd13,
            FSM_SCAL_RD8   = 6'd14,
            FSM_SCAL_RD9   = 6'd15,
            FSM_LCAL_RD1   = 6'd16,
            FSM_LCAL_WR1   = 6'd17,
            FSM_LCAL_RD2   = 6'd18,
            FSM_LCAL_WR2   = 6'd19,
            FSM_LCAL_RD3   = 6'd20,
            FSM_LCAL_WR3   = 6'd21,
            FSM_LCAL_RD4   = 6'd22,
            FSM_LCAL_WR4   = 6'd23,
            FSM_LCAL_RD5   = 6'd24,
            FSM_LCAL_WR5   = 6'd25,
            FSM_LCAL_RD6   = 6'd26,
            FSM_LCAL_WR6   = 6'd27,
            FSM_LCAL_RD7   = 6'd28,
            FSM_LCAL_WR7   = 6'd29,
            FSM_LCAL_RD8   = 6'd30,
            FSM_LCAL_WR8   = 6'd31,
            FSM_LCAL_RD9   = 6'd32,
            FSM_LCAL_WR9   = 6'd33,
            FSM_READ       = 6'd34,
            FSM_WRITE      = 6'd35,
            FSM_END        = 6'd36;
localparam CALIB_RATES = 4; 
localparam CALIB_LANES = XCVR ? 4 : 1; 
localparam CALIB_VALUES = XCVR ? 7 : 2; 
localparam CALIB_RES_SIZE = CALIB_RATES * CALIB_LANES * CALIB_VALUES;
reg [5:0] state;
reg [7:0] calib_res [CALIB_RES_SIZE-1:0];
always @ (posedge clk or posedge reset) 
  if(reset) 
  begin
    state <= FSM_IDLE;
    mgmt_chnum  <= 2'd0;
    mgmt_address  <= 10'd0;
    mgmt_write <= 1'b0;
    mgmt_read <= 1'b0;
    mgmt_writedata <= 32'd0;
  end
  else
  begin
    mgmt_write <= 1'b0;  
    mgmt_read <= 1'b0;
    case (state)
      FSM_IDLE:
        if(rcnf_en)
        begin
          if(rcnf_req_cbus)
            state <= FSM_REQBUS_RD;
          if(rcnf_reconfig)
            state <= FSM_READ;
          if(rcnf_rel_cbus)
            state <= FSM_RELBUS_RD;
          if(rcnf_wcalib)
            state <= FSM_WCAL_RD;
          if(rcnf_scalib)
            state <= XCVR ? FSM_SCAL_RD3 : FSM_SCAL_RD1;
          if(rcnf_lcalib)
            state <= XCVR ? FSM_LCAL_RD3 : FSM_LCAL_RD1;
        end
      FSM_REQBUS_RD: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_REQBUS_WR;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= XCVR ? ADDR_XCVR_BUS_ARB : ADDR_TXPLL_BUS_ARB;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_REQBUS_WR: 
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~32'h0000_0001) | 32'h0000_0000;
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_RELBUS_RD: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_RELBUS_WR;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= XCVR ? ADDR_XCVR_BUS_ARB : ADDR_TXPLL_BUS_ARB;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_RELBUS_WR: 
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~32'h0000_0001) | 32'h0000_0001;
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_WCAL_RD: 
        if(~cal_busy)
          state <= FSM_IDLE; 
        else
          state <= FSM_WCAL_RD; 
      FSM_SCAL_RD1: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+0] <= (mgmt_readdata[7:0] & MASK_TXPLL_VCO_BAND1[7:0]);
            state <= FSM_SCAL_RD2;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND1;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD2:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+1] <= (mgmt_readdata[7:0] & MASK_TXPLL_VCO_BAND2[7:0]);
            state <= FSM_IDLE;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND2;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD3: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+0] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED[7:0]);
            state <= FSM_SCAL_RD4;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD4:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+1] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED_FIX[7:0]);
            state <= FSM_SCAL_RD5;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD5:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+2] <= (mgmt_readdata[7:0] & MASK_XCVR_CHGPMP_PD_UP[7:0]);
            state <= FSM_SCAL_RD6;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_UP;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD6:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+3] <= (mgmt_readdata[7:0] & MASK_XCVR_CHGPMP_PD_DN[7:0]);
            state <= FSM_SCAL_RD7;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_DN;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD7:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+4] <= (mgmt_readdata[7:0] & MASK_XCVR_LF_PD_PFD[7:0]);
            state <= FSM_SCAL_RD8;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_LF_PD_PFD;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD8:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+5] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED_FIX_7_6[7:0]);
            state <= FSM_SCAL_RD9;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_7_6;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD9:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+6] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED_FIX_4[7:0]);
            state <= FSM_IDLE;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_4;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_RD1: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR1;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND1;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR1:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD2;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_TXPLL_VCO_BAND1) | calib_res[rcnf_linkrate*CALIB_VALUES+0];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD2:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR2;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND2;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR2:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_TXPLL_VCO_BAND2) | calib_res[rcnf_linkrate*CALIB_VALUES+1];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD3: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR3;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR3:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD4;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED) | calib_res[rcnf_linkrate*CALIB_VALUES+0];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD4:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR4;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR4:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD5;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED_FIX) | calib_res[rcnf_linkrate*CALIB_VALUES+1];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD5:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR5;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_UP;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR5:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD6;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CHGPMP_PD_UP) | calib_res[rcnf_linkrate*CALIB_VALUES+2];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD6:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR6;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_DN;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR6:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD7;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CHGPMP_PD_DN) | calib_res[rcnf_linkrate*CALIB_VALUES+3];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD7:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR7;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_LF_PD_PFD;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR7:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD8;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_LF_PD_PFD) | calib_res[rcnf_linkrate*CALIB_VALUES+4];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD8:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR8;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_7_6;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR8:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD9;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED_FIX_7_6) | calib_res[rcnf_linkrate*CALIB_VALUES+5];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD9:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR9;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_4;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR9:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED_FIX_4) | calib_res[rcnf_linkrate*CALIB_VALUES+6];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_READ: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_WRITE;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= rcnf_address;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_WRITE: 
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~rcnf_mask) | rcnf_data;
            mgmt_write      <= 1'b1;  
          end
        end
      endcase
    end
assign rcnf_busy = (state != FSM_IDLE) | rcnf_req_cbus | rcnf_rel_cbus | rcnf_reconfig | rcnf_wcalib | rcnf_scalib | rcnf_lcalib;
endmodule
module dp_analog_mappings 
(
  input  wire [1:0]   vod,  
  input  wire [1:0]   pree, 
  output reg  [4:0]   out_vod, 
  output reg  [5:0]   out_pree_post_tap1 
);
always @(*)
  case (vod)
    2'b00 :  
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd13;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd19;     
          out_pree_post_tap1 = {1'b1,5'd6};
        end
        2'b10 : 
        begin
          out_vod = 5'd25;     
          out_pree_post_tap1 = {1'b1,5'd12};
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd19};
        end
      endcase
    end
    2'b01 : 
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd19;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd28;     
          out_pree_post_tap1 = {1'b1,5'd9};
        end
        2'b10 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd14};
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd14};
        end
      endcase
    end
    2'b10 : 
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd25;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd6}; 
        end
        2'b10 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd6}; 
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd6}; 
        end
      endcase
    end
    2'b11 : 
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0}; 
        end
        2'b10 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0}; 
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0}; 
        end
      endcase
    end
  endcase
endmodule
`default_nettype wire
`timescale 1ns / 1ns
`default_nettype none
module bitec_reconfig_alt_a10 
#(
  parameter [3:0] TX_LANES = 4,
  parameter [3:0] RX_LANES = 4,
  parameter [2:0] TX_RATES_NUM = 3, 
  parameter [2:0] RX_RATES_NUM = 3, 
  parameter A10_ES2 = 0             
)
(
  input  wire clk,                        
  input  wire reset,                      
  input  wire [7:0] rx_link_rate,         
  input  wire rx_link_rate_strobe,        
  output wire rx_xcvr_busy,               
  output reg rx_xcvr_reset,
  input  wire [7:0] tx_link_rate,         
  input  wire [(TX_LANES*2)-1:0] tx_vod,  
  input  wire [(TX_LANES*2)-1:0] tx_emp,  
  input  wire tx_link_rate_strobe,        
  input  wire tx_vodemp_strobe,           
  output wire tx_xcvr_busy,               
  output reg tx_xcvr_reset,              
  input  wire rx_analogreset_ack,
  output wire [1:0] rx_mgmt_chnum,
  output wire [9:0] rx_mgmt_address,
  output wire [31:0] rx_mgmt_writedata,
  input  wire [31:0] rx_mgmt_readdata,
  output wire rx_mgmt_write,
  output wire rx_mgmt_read,
  input  wire rx_mgmt_waitrequest,
  input  wire tx_analogreset_ack,
  output wire [1:0] tx_mgmt_chnum,
  output wire [9:0] tx_mgmt_address,
  output wire [31:0] tx_mgmt_writedata,
  input  wire [31:0] tx_mgmt_readdata,
  output wire tx_mgmt_write,
  output wire tx_mgmt_read,
  input  wire tx_mgmt_waitrequest,
  output wire [9:0] txpll_mgmt_address,
  output wire [31:0] txpll_mgmt_writedata,
  input  wire [31:0] txpll_mgmt_readdata,
  output wire txpll_mgmt_write,
  output wire txpll_mgmt_read,
  input  wire txpll_mgmt_waitrequest,
  input  wire rx_xcvr_cal_busy,
  input  wire tx_xcvr_cal_busy,
  input  wire tx_pll_cal_busy
);
localparam  FSM_CNF_TXPLL1              = 5'd0,
            FSM_CNF_TXPLL2              = 5'd1,
            FSM_CAL_TXPLL1              = 5'd2,
            FSM_CAL_TXPLL2              = 5'd3,
            FSM_CAL_TXPLL3              = 5'd4,
            FSM_CAL_TXPLL4              = 5'd5,
            FSM_MEM_TXPLL1              = 5'd6,
            FSM_MEM_TXPLL2              = 5'd7,
            FSM_CNF_RXGXB1              = 5'd8,
            FSM_CNF_RXGXB2              = 5'd9,
            FSM_CNF_RXGXB3              = 5'd10,
            FSM_CNF_RXGXB_NEXTLANE      = 5'd11,
            FSM_CAL_RXGXB1              = 5'd12,
            FSM_CAL_RXGXB2              = 5'd13,
            FSM_CAL_RXGXB3              = 5'd14,
            FSM_CAL_RXGXB4              = 5'd15,
            FSM_CAL_RXGXB5              = 5'd16,
            FSM_MEM_RXGXB               = 5'd17,
            FSM_CAL_RXGXB_NEXTLANE      = 5'd18,
            FSM_IDLE                    = 5'd19,
            FSM_START_RX_LINKRATE       = 5'd20,
            FSM_START_TX_LINKRATE       = 5'd21,
            FSM_START_TX_ANALOG         = 5'd22,
            FSM_FEAT_RECONFIG           = 5'd23,
            FSM_WAIT_FOR_BUSY_LOW       = 5'd24,
            FSM_NEXT_RX_LRATE_FEATURE   = 5'd25,
            FSM_NEXT_TX_LRATE_FEATURE   = 5'd26,
            FSM_NEXT_TX_ANALOG_FEATURE  = 5'd27,
            FSM_END_RECONFIG            = 5'd28,
            FSM_NEXT_LANE               = 5'd29,
            FSM_END                     = 5'd30;
localparam  FEAT_RX_REFCLK1 = 4'd0,
            FEAT_RX_REFCLK2 = 4'd1,
            FEAT_RX_REFCLK3 = 4'd2,
            FEAT_RX_REFCLK4 = 4'd3,
            FEAT_TX_VOD     = 4'd4,
            FEAT_TX_EMP1    = 4'd5,
            FEAT_TX_EMP2    = 4'd6,
            FEAT_TX_EMP3    = 4'd7,
            FEAT_TX_EMP4    = 4'd8,
            FEAT_TX_REFCLK1 = 4'd9,
            FEAT_TX_REFCLK2 = 4'd10,
            FEAT_TX_REFCLK3 = 4'd11;
localparam  ADDR_CALIB                                  = 10'h100,
            ADDR_PRE_EMP_SWITCHING_CTRL_1ST_POST_TAP    = 10'h105,
            ADDR_PRE_EMP_SWITCHING_CTRL_2ND_POST_TAP    = 10'h106,
            ADDR_PRE_EMP_SWITCHING_CTRL_PRE_TAP_1T      = 10'h107,
            ADDR_PRE_EMP_SWITCHING_CTRL_PRE_TAP_2T      = 10'h108,
            ADDR_VOD_OUTPUT_SWING_CTRL                  = 10'h109,
            ADDR_L_PFD_COUNTER                          = 10'h13a,
            ADDR_L_PD_COUNTER                           = 10'h13a,
            ADDR_M_COUNTER                              = 10'h13b,
            ADDR_CP_CALIB                               = 10'h166;
localparam  MASK_CALIB                                  = 32'h0000_0006,
            MASK_PRE_EMP_SWITCHING_CTRL_1ST_POST_TAP    = 32'h0000_005f,
            MASK_PRE_EMP_SWITCHING_CTRL_2ND_POST_TAP    = 32'h0000_002f,
            MASK_PRE_EMP_SWITCHING_CTRL_PRE_TAP_1T      = 32'h0000_003f,
            MASK_PRE_EMP_SWITCHING_CTRL_PRE_TAP_2T      = 32'h0000_0017,
            MASK_VOD_OUTPUT_SWING_CTRL                  = 32'h0000_001f,
            MASK_L_PFD_COUNTER                          = 32'h0000_0007,
            MASK_L_PD_COUNTER                           = 32'h0000_0038,
            MASK_M_COUNTER                              = 32'h0000_00ff,
            MASK_CP_CALIB                               = 32'h0000_0080;
localparam  ADDR_TXPLL_CALIB                           = 10'h100,  
            ADDR_TXPLL_M_CNT                           = 10'h12b,
            ADDR_TXPLL_L_CNT                           = 10'h12c;
localparam  MASK_TXPLL_CALIB                           = 32'h0000_0002,
            MASK_TXPLL_M_CNT                           = 32'h0000_00ff,
            MASK_TXPLL_L_CNT                           = 32'h0000_0006;
wire [2:0] COUNTER_L_PFD [3:0];
wire [2:0] COUNTER_L_PD [3:0];
wire [7:0] COUNTER_M [3:0];
assign COUNTER_L_PFD[0] = A10_ES2 ? 3'h3  : 3'h3;  
assign COUNTER_L_PFD[1] = A10_ES2 ? 3'h3  : 3'h3;  
assign COUNTER_L_PFD[2] = A10_ES2 ? 3'h4  : 3'h3;  
assign COUNTER_L_PFD[3] = A10_ES2 ? 3'h3  : 3'h3;  
assign COUNTER_L_PD[0]  = A10_ES2 ? 3'h5  : 3'h5;  
assign COUNTER_L_PD[1]  = A10_ES2 ? 3'h4  : 3'h4;  
assign COUNTER_L_PD[2]  = A10_ES2 ? 3'h4  : 3'h3;  
assign COUNTER_L_PD[3]  = A10_ES2 ? 3'h3  : 3'h3;  
assign COUNTER_M[0]     = A10_ES2 ? 8'h18 : 8'hC; 
assign COUNTER_M[1]     = A10_ES2 ? 8'h14 : 8'h14; 
assign COUNTER_M[2]     = A10_ES2 ? 8'h14 : 8'h14; 
assign COUNTER_M[3]     = A10_ES2 ? 8'h1E : 8'hF; 
wire [1:0] L_COUNTER_FPLL [3:0];
wire [7:0] M_COUNTER_FPLL [3:0];
assign L_COUNTER_FPLL[0] = A10_ES2 ? 2'h3  : 2'h2;  
assign L_COUNTER_FPLL[1] = A10_ES2 ? 2'h2  : 2'h2;  
assign L_COUNTER_FPLL[2] = A10_ES2 ? 2'h1  : 2'h1;  
assign L_COUNTER_FPLL[3] = A10_ES2 ? 2'h0  : 2'h0;  
assign M_COUNTER_FPLL[0] = A10_ES2 ? 8'h315 : 8'hC; 
assign M_COUNTER_FPLL[1] = A10_ES2 ? 8'h14 : 8'h14; 
assign M_COUNTER_FPLL[2] = A10_ES2 ? 8'h14 : 8'h14; 
assign M_COUNTER_FPLL[3] = A10_ES2 ? 8'hF : 8'hF; 
reg [4:0] fsm_state; 
reg [3:0] feature_idx; 
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*bitec_reconfig_alt_a10:*|rx_reset_ack_r}]\" "} *) reg rx_reset_ack_r ;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg rx_reset_ack_rr ;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg rx_reset_ack_rrr ;
always @(posedge clk or posedge reset)
  if (reset) 
    {rx_reset_ack_r, rx_reset_ack_rr, rx_reset_ack_rrr} <= 3'b000;
  else
    {rx_reset_ack_r, rx_reset_ack_rr, rx_reset_ack_rrr} <= {rx_analogreset_ack, rx_reset_ack_r, rx_reset_ack_rr};
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*bitec_reconfig_alt_a10:*|tx_reset_ack_r}]\" "} *) reg tx_reset_ack_r ;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg tx_reset_ack_rr ;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg tx_reset_ack_rrr ;
always @(posedge clk or posedge reset)
  if (reset) 
    {tx_reset_ack_r, tx_reset_ack_rr, tx_reset_ack_rrr} <= 3'b000;
  else
    {tx_reset_ack_r, tx_reset_ack_rr, tx_reset_ack_rrr} <= {tx_analogreset_ack, tx_reset_ack_r, tx_reset_ack_rr};
wire [TX_LANES*5-1:0] vod_mapped;
wire [TX_LANES*6-1:0] emp_mapped;   
generate 
begin      
  genvar tx_lane;
  for (tx_lane=0; tx_lane < TX_LANES; tx_lane = tx_lane + 1) 
  begin:lane
    dp_analog_mappings dp_analog_mappings_i
    (
      .vod                  (tx_vod[(tx_lane*2) +:2]), 
      .pree                 (tx_emp[(tx_lane*2) +:2]),
      .out_vod              (vod_mapped[(tx_lane*5) +:5]), 
      .out_pree_post_tap1   (emp_mapped[(tx_lane*6) +:6])
    );
  end 
end 
endgenerate
reg [2:0] rx_link_rate_strobe_d,tx_link_rate_strobe_d,tx_vodemp_strobe_d;
reg rx_new_linkrate; 
reg tx_new_linkrate; 
reg tx_new_analog;   
always @ (posedge clk or posedge reset) 
begin
  if(reset) 
  begin
    rx_link_rate_strobe_d <= 3'h0;
    tx_link_rate_strobe_d <= 3'h0;
    tx_vodemp_strobe_d <= 3'h0;
    rx_xcvr_reset <= 1'b0;
    tx_xcvr_reset <= 1'b0;
    rx_new_linkrate <= 1'b0;
    tx_new_linkrate <= 1'b0;
    tx_new_analog <= 1'b0;
  end
  else
  begin
    rx_link_rate_strobe_d <= {rx_link_rate_strobe_d[1:0],rx_link_rate_strobe};
    tx_link_rate_strobe_d <= {tx_link_rate_strobe_d[1:0],tx_link_rate_strobe};
    tx_vodemp_strobe_d <= {tx_vodemp_strobe_d[1:0],tx_vodemp_strobe};
    rx_xcvr_reset <= (fsm_state == FSM_END) ? 1'b0 : (rx_new_linkrate ?  1'b1 : rx_xcvr_reset);
    tx_xcvr_reset <= (fsm_state == FSM_END) ? 1'b0 : (tx_new_linkrate ?  1'b1 : (tx_new_analog ? 1'b1 : tx_xcvr_reset));
    rx_new_linkrate <= rx_new_linkrate ? ~(fsm_state == FSM_START_RX_LINKRATE) : (~rx_link_rate_strobe_d[2] & rx_link_rate_strobe_d[1]);
    tx_new_linkrate <= tx_new_linkrate ? ~(fsm_state == FSM_START_TX_LINKRATE) : (~tx_link_rate_strobe_d[2] & tx_link_rate_strobe_d[1]);
    tx_new_analog <= tx_new_analog ? ~(fsm_state == FSM_START_TX_ANALOG) : (~tx_vodemp_strobe_d[2] & tx_vodemp_strobe_d[1]);
  end
end
reg [TX_LANES*5-1:0] vod_mem;
reg [TX_LANES*6-1:0] emp_mem;
reg [1:0] tx_link_rate_mem;
reg [1:0] rx_link_rate_mem;
reg [1:0] lane_idx; 
reg [2:0] write_cnt; 
reg rcnf_reconfig;      
reg [9:0] rcnf_address; 
reg [31:0] rcnf_data;   
reg [31:0] rcnf_mask;   
reg rcnf_req_cbus;      
reg rcnf_rel_cbus;      
reg rcnf_wcalib;        
reg rcnf_scalib;        
reg rcnf_lcalib;        
wire rcnf_busy;
reg rx_lrate_busy;  
reg tx_lrate_busy;  
reg tx_analog_busy; 
wire rx_cal_busy;
wire tx_cal_busy;
assign rx_cal_busy = rx_xcvr_cal_busy;
assign tx_cal_busy = tx_pll_cal_busy | tx_xcvr_cal_busy;
assign rx_xcvr_busy = rx_lrate_busy | rx_cal_busy;
assign tx_xcvr_busy = tx_lrate_busy | tx_cal_busy | tx_analog_busy;
always @ (posedge clk or posedge reset) 
begin
  if(reset) 
  begin
    fsm_state <= FSM_CNF_TXPLL1;
    vod_mem <= 0;
    emp_mem <= 0;
    tx_link_rate_mem <= 2'h0;
    rx_link_rate_mem <= 2'h0;
    rcnf_req_cbus <= 1'b0;
    rcnf_rel_cbus <= 1'b0;
    rcnf_wcalib <= 1'b0;
    rcnf_scalib <= 1'b0;
    rcnf_lcalib <= 1'b0;
    rcnf_reconfig <= 1'b0;
    rcnf_address <= 10'h0;
    rcnf_data <= 32'h0;
    rcnf_mask <= 32'h0;
    feature_idx <= FEAT_RX_REFCLK1;
    write_cnt <= 3'h0;
    lane_idx <= 2'h0;
    rx_lrate_busy <= 1'b0;
    tx_lrate_busy <= 1'b0;
    tx_analog_busy <= 1'b0;
  end
  else
  begin
    rcnf_req_cbus <= 1'b0;
    rcnf_rel_cbus <= 1'b0;
    rcnf_wcalib <= 1'b0;
    rcnf_scalib <= 1'b0;
    rcnf_lcalib <= 1'b0;
    rcnf_reconfig <= 1'b0;
    case(fsm_state)
      FSM_CNF_TXPLL1: 
        if(tx_link_rate_mem < TX_RATES_NUM[1:0])
        begin
          if(~rx_cal_busy & ~tx_cal_busy)
          begin
            tx_lrate_busy <= 1'b1;
            rcnf_address <= ADDR_TXPLL_M_CNT;
            rcnf_mask <= MASK_TXPLL_M_CNT;
            rcnf_data <= {24'd0,M_COUNTER_FPLL[tx_link_rate_mem]};
            rcnf_reconfig <= 1'b1;
            fsm_state <= FSM_CNF_TXPLL2;
          end
        end
        else
        begin
          tx_lrate_busy <= 1'b0;
          fsm_state <= FSM_CNF_RXGXB1;
        end
      FSM_CNF_TXPLL2: 
        if(!rcnf_busy) 
        begin
          rcnf_address <= ADDR_TXPLL_L_CNT;
          rcnf_mask <= MASK_TXPLL_L_CNT;
          rcnf_data <= {29'd0,L_COUNTER_FPLL[tx_link_rate_mem],1'b0};
          rcnf_reconfig <= 1'b1;
          fsm_state <= FSM_CAL_TXPLL1;
        end
      FSM_CAL_TXPLL1: 
        if(!rcnf_busy) 
        begin
          rcnf_req_cbus <= 1'b1;
          fsm_state <= FSM_CAL_TXPLL2;
        end
      FSM_CAL_TXPLL2: 
        if(!rcnf_busy) 
        begin
          rcnf_address <= ADDR_TXPLL_CALIB;
          rcnf_mask <= MASK_TXPLL_CALIB;
          rcnf_data <= 32'h2;
          rcnf_reconfig <= 1'b1;
          fsm_state <= FSM_CAL_TXPLL3;
        end
      FSM_CAL_TXPLL3: 
        if(!rcnf_busy) 
        begin
          rcnf_rel_cbus <= 1'b1;
          fsm_state <= FSM_CAL_TXPLL4;
        end
      FSM_CAL_TXPLL4: 
        if(!rcnf_busy) 
        begin
          rcnf_wcalib <= 1'b1;
          fsm_state <= FSM_MEM_TXPLL1;
        end
      FSM_MEM_TXPLL1: 
        if(!rcnf_busy) 
        begin
          rcnf_scalib <= 1'b1;
          fsm_state <= FSM_MEM_TXPLL2;
        end
      FSM_MEM_TXPLL2: 
        if(!rcnf_busy) 
        begin
          tx_link_rate_mem <= tx_link_rate_mem + 1'd1;
          fsm_state <= FSM_CNF_TXPLL1;
        end
      FSM_CNF_RXGXB1: 
        if(rx_link_rate_mem < RX_RATES_NUM[1:0])
        begin
          if(~rx_cal_busy & ~tx_cal_busy)
          begin
            rx_lrate_busy <= 1'b1;
            rcnf_address <= ADDR_L_PFD_COUNTER;
            rcnf_mask <= MASK_L_PFD_COUNTER;
            rcnf_data <= {29'd0,COUNTER_L_PFD[rx_link_rate_mem]};
            rcnf_reconfig <= 1'b1;
            fsm_state <= FSM_CNF_RXGXB2;
          end
        end
        else
        begin
          rx_lrate_busy <= 1'b0;
          fsm_state <= FSM_IDLE;
        end
      FSM_CNF_RXGXB2: 
        if(!rcnf_busy) 
        begin
          rcnf_address <= ADDR_L_PD_COUNTER;
          rcnf_mask <= MASK_L_PD_COUNTER;
          rcnf_data <= {26'd0,COUNTER_L_PD[rx_link_rate_mem],3'd0};
          rcnf_reconfig <= 1'b1;
          fsm_state <= FSM_CNF_RXGXB3;
        end
      FSM_CNF_RXGXB3: 
        if(!rcnf_busy) 
        begin
          rcnf_address <= ADDR_M_COUNTER;
          rcnf_mask <= MASK_M_COUNTER;
          rcnf_data <= {24'd0,COUNTER_M[rx_link_rate_mem]};
          rcnf_reconfig <= 1'b1;
          fsm_state <= FSM_CNF_RXGXB_NEXTLANE;
        end
      FSM_CNF_RXGXB_NEXTLANE:
        if(!rcnf_busy) 
        begin
          if(lane_idx + 1'd1 < RX_LANES)
          begin
            lane_idx <= lane_idx + 2'd1;
            fsm_state <= FSM_CNF_RXGXB1;
          end
          else
          begin
            lane_idx <= 2'd0;
            fsm_state <= FSM_CAL_RXGXB1;
          end
        end      
      FSM_CAL_RXGXB1: 
        if(!rcnf_busy) 
        begin
          rcnf_req_cbus <= 1'b1;
          fsm_state <= FSM_CAL_RXGXB2;
        end
      FSM_CAL_RXGXB2: 
        if(!rcnf_busy) 
        begin
          rcnf_address <= ADDR_CALIB;
          rcnf_mask <= MASK_CALIB;
          rcnf_data <= 32'h6; 
          rcnf_reconfig <= 1'b1;
          fsm_state <= FSM_CAL_RXGXB3;
        end
      FSM_CAL_RXGXB3: 
        if(!rcnf_busy) 
        begin
          rcnf_address <= ADDR_CP_CALIB;
          rcnf_mask <= MASK_CP_CALIB;
          rcnf_data <= {24'd0,1'd0,7'd0};
          rcnf_reconfig <= 1'b1;
          fsm_state <= FSM_CAL_RXGXB4;
        end
      FSM_CAL_RXGXB4: 
        if(!rcnf_busy) 
        begin
          rcnf_rel_cbus <= 1'b1;
          fsm_state <= FSM_CAL_RXGXB5;
        end
      FSM_CAL_RXGXB5: 
        if(!rcnf_busy) 
        begin
          rcnf_wcalib <= 1'b1;
          fsm_state <= FSM_MEM_RXGXB;
        end
      FSM_MEM_RXGXB: 
        if(!rcnf_busy) 
        begin
          rcnf_scalib <= 1'b1;
          fsm_state <= FSM_CAL_RXGXB_NEXTLANE;
        end
      FSM_CAL_RXGXB_NEXTLANE:
        if(!rcnf_busy) 
        begin
          if(lane_idx + 1'd1 < RX_LANES)
          begin
            lane_idx <= lane_idx + 2'd1;
            fsm_state <= FSM_CAL_RXGXB1;
          end
          else
          begin
            lane_idx <= 2'd0;
            rx_link_rate_mem <= rx_link_rate_mem + 1'd1;
            fsm_state <= FSM_CNF_RXGXB1;
          end
        end      
      FSM_IDLE: 
      begin
        write_cnt <= 3'h0;
        lane_idx <= 2'h0;
        if(~rx_xcvr_busy & ~tx_xcvr_busy)
        begin
          if(rx_new_linkrate & rx_reset_ack_rrr)
          begin
            rx_lrate_busy  <= 1'b1;
            fsm_state <= FSM_START_RX_LINKRATE;
            if(rx_link_rate == 8'h06)
              rx_link_rate_mem <= 2'b00; 
            else if(rx_link_rate == 8'h0a)
              rx_link_rate_mem <= 2'b01; 
            else if(rx_link_rate == 8'h14)
              rx_link_rate_mem <= 2'b10; 
            else
            begin
              rx_lrate_busy  <= 1'b0;
              fsm_state <= FSM_IDLE;
            end
          end
          else if(tx_new_linkrate & tx_reset_ack_rrr)
          begin
            tx_lrate_busy  <= 1'b1;
            fsm_state <= FSM_START_TX_LINKRATE;
            if(tx_link_rate == 8'h06)
              tx_link_rate_mem <= 2'b00; 
            else if(tx_link_rate == 8'h0a)
              tx_link_rate_mem <= 2'b01; 
            else if(tx_link_rate == 8'h14)
              tx_link_rate_mem <= 2'b10; 
            else
            begin
              tx_lrate_busy  <= 1'b0;
              fsm_state <= FSM_IDLE;
            end
          end
          else if(tx_new_analog & tx_reset_ack_rrr)
          begin
            vod_mem <= vod_mapped;
            emp_mem <= emp_mapped;
            tx_analog_busy  <= 1'b1;
            rcnf_req_cbus <= 1'b1; 
            fsm_state <= FSM_START_TX_ANALOG;
          end
        end
      end
      FSM_START_RX_LINKRATE: 
      begin
        feature_idx <= FEAT_RX_REFCLK1; 
        if(!rcnf_busy) 
          fsm_state <= FSM_FEAT_RECONFIG;
      end
      FSM_START_TX_LINKRATE: 
      begin
        feature_idx <= FEAT_TX_REFCLK1; 
        if(!rcnf_busy) 
          fsm_state <= FSM_FEAT_RECONFIG;
      end
      FSM_START_TX_ANALOG: 
      begin
        feature_idx <= FEAT_TX_VOD; 
        if(!rcnf_busy) 
          fsm_state <= FSM_FEAT_RECONFIG;
      end
      FSM_FEAT_RECONFIG: 
      begin
        rcnf_reconfig <= 1'b1;
        write_cnt <= write_cnt + 1'd1;
        fsm_state <= FSM_WAIT_FOR_BUSY_LOW;
        case(feature_idx)
          FEAT_RX_REFCLK1: 
          begin
            rcnf_address <= ADDR_L_PFD_COUNTER;
            rcnf_mask <= MASK_L_PFD_COUNTER;
            rcnf_data <= {29'd0,COUNTER_L_PFD[rx_link_rate_mem]};
          end
          FEAT_RX_REFCLK2: 
          begin
            rcnf_address <= ADDR_L_PD_COUNTER;
            rcnf_mask <= MASK_L_PD_COUNTER;
            rcnf_data <= {26'd0,COUNTER_L_PD[rx_link_rate_mem],3'd0};
          end
          FEAT_RX_REFCLK3: 
          begin
            rcnf_address <= ADDR_M_COUNTER;
            rcnf_mask <= MASK_M_COUNTER;
            rcnf_data <= {24'd0,COUNTER_M[rx_link_rate_mem]};
          end
          FEAT_RX_REFCLK4: 
          begin
            rcnf_reconfig <= 1'b0;
            rcnf_lcalib <= 1'b1; 
          end
          FEAT_TX_VOD: 
          begin
            rcnf_address        <= ADDR_VOD_OUTPUT_SWING_CTRL;
            rcnf_mask           <= MASK_VOD_OUTPUT_SWING_CTRL;
            rcnf_data           <= {27'd0,vod_mem[5*lane_idx +:5]};
          end
          FEAT_TX_EMP1: 
          begin
            rcnf_address        <= ADDR_PRE_EMP_SWITCHING_CTRL_1ST_POST_TAP;
            rcnf_mask           <= MASK_PRE_EMP_SWITCHING_CTRL_1ST_POST_TAP;
            rcnf_data           <= {25'd0,emp_mem[6*lane_idx+5],1'b0,emp_mem[6*lane_idx +:5]};
          end
          FEAT_TX_EMP2: 
          begin
            rcnf_address        <= ADDR_PRE_EMP_SWITCHING_CTRL_2ND_POST_TAP;
            rcnf_mask           <= MASK_PRE_EMP_SWITCHING_CTRL_2ND_POST_TAP;
            rcnf_data           <= {26'd0,1'b1,1'b0,4'd0};
          end
          FEAT_TX_EMP3: 
          begin
            rcnf_address        <= ADDR_PRE_EMP_SWITCHING_CTRL_PRE_TAP_1T;
            rcnf_mask           <= MASK_PRE_EMP_SWITCHING_CTRL_PRE_TAP_1T;
            rcnf_data           <= {26'd0,1'b1,5'd0};
          end
          FEAT_TX_EMP4: 
          begin
            rcnf_address        <= ADDR_PRE_EMP_SWITCHING_CTRL_PRE_TAP_2T;
            rcnf_mask           <= MASK_PRE_EMP_SWITCHING_CTRL_PRE_TAP_2T;
            rcnf_data           <= {27'd0,1'b1,1'b0,3'd0};
          end
          FEAT_TX_REFCLK1: 
          begin
            rcnf_address        <= ADDR_TXPLL_M_CNT;
            rcnf_mask           <= MASK_TXPLL_M_CNT;
            rcnf_data           <= {24'd0,M_COUNTER_FPLL[tx_link_rate_mem]};
          end
          FEAT_TX_REFCLK2: 
          begin
            rcnf_address        <= ADDR_TXPLL_L_CNT;
            rcnf_mask           <= MASK_TXPLL_L_CNT;
            rcnf_data           <= {29'd0,L_COUNTER_FPLL[tx_link_rate_mem],1'b0};
          end
          FEAT_TX_REFCLK3: 
          begin
            rcnf_reconfig <= 1'b0;
            rcnf_lcalib <= 1'b1; 
          end
        endcase
      end
      FSM_WAIT_FOR_BUSY_LOW:
        if(!rcnf_busy) 
        begin
          if(rx_lrate_busy)
            fsm_state <= FSM_NEXT_RX_LRATE_FEATURE;
          else if(tx_lrate_busy)
            fsm_state <= FSM_NEXT_TX_LRATE_FEATURE;
          else
            fsm_state <= FSM_NEXT_TX_ANALOG_FEATURE;
        end
      FSM_NEXT_RX_LRATE_FEATURE:
      begin
        if(write_cnt == 3'd4)
          fsm_state <= FSM_END_RECONFIG;
        else
        begin
          feature_idx <= feature_idx + 4'd1;
          fsm_state <= FSM_FEAT_RECONFIG;
        end
      end
      FSM_NEXT_TX_LRATE_FEATURE:
      begin
        if(write_cnt == 3'd3) 
          fsm_state <= FSM_END_RECONFIG;
        else
        begin
          feature_idx <= feature_idx + 4'd1;
          fsm_state <= FSM_FEAT_RECONFIG;
        end
      end
      FSM_NEXT_TX_ANALOG_FEATURE:
      begin
        if(write_cnt == 3'd5) 
          fsm_state <= FSM_END_RECONFIG;
        else
        begin
          feature_idx <= feature_idx + 4'd1;
          fsm_state <= FSM_FEAT_RECONFIG;
        end
      end
      FSM_END_RECONFIG:
        if(!rcnf_busy) 
          fsm_state <= FSM_NEXT_LANE;
      FSM_NEXT_LANE: 
      begin
        if((rx_lrate_busy  & (lane_idx + 1 < RX_LANES)) |
           (tx_analog_busy & (lane_idx + 1 < TX_LANES)))
        begin
          lane_idx <= lane_idx + 2'd1;
          write_cnt <= 3'd0;
          if(rx_lrate_busy)
            fsm_state <= FSM_START_RX_LINKRATE;
          else
          begin
            rcnf_req_cbus <= 1'b1;
            fsm_state <= FSM_START_TX_ANALOG;
          end
        end
        else
          fsm_state <= FSM_END;        
      end
      FSM_END:
      begin
        rx_lrate_busy <= 1'b0;
        tx_lrate_busy <= 1'b0;
        tx_analog_busy <= 1'b0;
        fsm_state <= FSM_IDLE;
      end
      default:
        fsm_state <= FSM_END;
    endcase
  end 
end 
wire rx_rcnf_busy, tx_rcnf_busy;
bitec_reconfig_avalon_mm_master 
#(
  .XCVR (1) 
)
bitec_reconfig_avalon_mm_master_rx
(
  .clk          (clk),
  .reset        (reset),
  .rcnf_req_cbus      (rcnf_req_cbus),
  .rcnf_rel_cbus      (rcnf_rel_cbus),
  .rcnf_wcalib        (rcnf_wcalib),
  .rcnf_scalib        (rcnf_scalib),
  .rcnf_lcalib        (rcnf_lcalib),
  .rcnf_reconfig      (rcnf_reconfig),
  .rcnf_en            (rx_lrate_busy),
  .rcnf_logical_ch    (lane_idx),
  .rcnf_address       (rcnf_address),
  .rcnf_data          (rcnf_data),
  .rcnf_mask          (rcnf_mask),
  .rcnf_linkrate      (rx_link_rate_mem),
  .rcnf_busy          (rx_rcnf_busy),
  .mgmt_chnum         (rx_mgmt_chnum),
  .mgmt_address       (rx_mgmt_address), 
  .mgmt_writedata     (rx_mgmt_writedata),    
  .mgmt_readdata      (rx_mgmt_readdata),    
  .mgmt_write         (rx_mgmt_write),      
  .mgmt_read          (rx_mgmt_read),      
  .mgmt_waitrequest   (rx_mgmt_waitrequest),
  .cal_busy           (rx_xcvr_cal_busy)
);
bitec_reconfig_avalon_mm_master 
#(
  .XCVR (1) 
)
bitec_reconfig_avalon_mm_master_tx
(
  .clk          (clk),
  .reset        (reset),
  .rcnf_req_cbus      (rcnf_req_cbus),
  .rcnf_rel_cbus      (rcnf_rel_cbus),
  .rcnf_wcalib        (rcnf_wcalib),
  .rcnf_scalib        (rcnf_scalib),
  .rcnf_lcalib        (rcnf_lcalib),
  .rcnf_reconfig      (rcnf_reconfig),
  .rcnf_en            (tx_analog_busy),
  .rcnf_logical_ch    (lane_idx),
  .rcnf_address       (rcnf_address),
  .rcnf_data          (rcnf_data),
  .rcnf_mask          (rcnf_mask),
  .rcnf_linkrate      (tx_link_rate_mem),
  .rcnf_busy          (tx_rcnf_busy),
  .mgmt_chnum         (tx_mgmt_chnum),
  .mgmt_address       (tx_mgmt_address), 
  .mgmt_writedata     (tx_mgmt_writedata),    
  .mgmt_readdata      (tx_mgmt_readdata),    
  .mgmt_write         (tx_mgmt_write),      
  .mgmt_read          (tx_mgmt_read),      
  .mgmt_waitrequest   (tx_mgmt_waitrequest),
  .cal_busy           (tx_xcvr_cal_busy)
);
wire txpll_rcnf_busy;
bitec_reconfig_avalon_mm_master 
#(
  .XCVR (0) 
)
bitec_reconfig_avalon_mm_master_txpll
(
  .clk          (clk),
  .reset        (reset),
  .rcnf_req_cbus      (rcnf_req_cbus),
  .rcnf_rel_cbus      (rcnf_rel_cbus),
  .rcnf_wcalib        (rcnf_wcalib),
  .rcnf_scalib        (rcnf_scalib),
  .rcnf_lcalib        (rcnf_lcalib),
  .rcnf_reconfig      (rcnf_reconfig),
  .rcnf_en            (tx_lrate_busy),
  .rcnf_logical_ch    (2'b00),
  .rcnf_address       (rcnf_address),
  .rcnf_data          (rcnf_data),
  .rcnf_mask          (rcnf_mask),
  .rcnf_linkrate      (tx_link_rate_mem),
  .rcnf_busy          (txpll_rcnf_busy),
  .mgmt_chnum         (),
  .mgmt_address       (txpll_mgmt_address), 
  .mgmt_writedata     (txpll_mgmt_writedata),    
  .mgmt_readdata      (txpll_mgmt_readdata),    
  .mgmt_write         (txpll_mgmt_write),      
  .mgmt_read          (txpll_mgmt_read),      
  .mgmt_waitrequest   (txpll_mgmt_waitrequest),
  .cal_busy           (tx_pll_cal_busy)
);
assign rcnf_busy = tx_lrate_busy ? txpll_rcnf_busy : (rx_rcnf_busy | tx_rcnf_busy);
endmodule
module bitec_reconfig_avalon_mm_master 
#(
  parameter XCVR = 1  
)
(
  input wire clk,
  input wire reset,
  input wire rcnf_req_cbus,               
  input wire rcnf_rel_cbus,               
  input wire rcnf_wcalib,                 
  input wire rcnf_scalib,                 
  input wire rcnf_lcalib,                 
  input wire rcnf_reconfig,               
  input wire rcnf_en,                     
  input wire [1:0] rcnf_logical_ch,       
  input wire [9:0] rcnf_address,          
  input wire [31:0] rcnf_data,            
  input wire [31:0] rcnf_mask,            
  input wire [1:0] rcnf_linkrate,         
  output wire rcnf_busy,                  
  output reg [1:0] mgmt_chnum,
  output reg [9:0] mgmt_address,
  output reg [31:0] mgmt_writedata,
  input wire [31:0] mgmt_readdata,
  output reg mgmt_write,
  output reg mgmt_read,
  input  wire mgmt_waitrequest,
  input  wire cal_busy
);
localparam ADDR_XCVR_BUS_ARB                = 10'h000,
           ADDR_XCVR_CDR_VCO_SPEED_FIX_7_6  = 10'h132,
           ADDR_XCVR_CHGPMP_PD_UP           = 10'h133,
           ADDR_XCVR_CDR_VCO_SPEED_FIX_4    = 10'h134,
           ADDR_XCVR_LF_PD_PFD              = 10'h135,  
           ADDR_XCVR_CDR_VCO_SPEED_FIX      = 10'h136,  
           ADDR_XCVR_CDR_VCO_SPEED          = 10'h137,
           ADDR_XCVR_CHGPMP_PD_DN           = 10'h139,
           ADDR_XCVR_CAL_BUSY               = 10'h281;
localparam  MASK_XCVR_LF_PD_PFD             = 32'h0000_004f,
            MASK_XCVR_CDR_VCO_SPEED_FIX_7_6 = 32'h0000_00F7,
            MASK_XCVR_CDR_VCO_SPEED_FIX_4   = 32'h0000_00F7,
            MASK_XCVR_CDR_VCO_SPEED_FIX     = 32'h0000_000f,
            MASK_XCVR_CDR_VCO_SPEED         = 32'h0000_007c,
            MASK_XCVR_CHGPMP_PD_UP          = 32'h0000_00E0,
            MASK_XCVR_CHGPMP_PD_DN          = 32'h0000_00BF;
localparam ADDR_TXPLL_BUS_ARB           = 10'h000,
           ADDR_TXPLL_VCO_BAND1         = 10'h10A,
           ADDR_TXPLL_VCO_BAND2         = 10'h10B,
           ADDR_TXPLL_CAL_BUSY          = 10'h280;
localparam  MASK_TXPLL_VCO_BAND1        = 32'h0000_001f,
            MASK_TXPLL_VCO_BAND2        = 32'h0000_00f8;
localparam  FSM_IDLE       = 6'd0,
            FSM_REQBUS_RD  = 6'd1,
            FSM_REQBUS_WR  = 6'd2,
            FSM_RELBUS_RD  = 6'd3,
            FSM_RELBUS_WR  = 6'd4,
            FSM_WCAL_RD    = 6'd5,
            FSM_WCAL_TST   = 6'd6,
            FSM_SCAL_RD1   = 6'd7,
            FSM_SCAL_RD2   = 6'd8,
            FSM_SCAL_RD3   = 6'd9,
            FSM_SCAL_RD4   = 6'd10,
            FSM_SCAL_RD5   = 6'd11,
            FSM_SCAL_RD6   = 6'd12,
            FSM_SCAL_RD7   = 6'd13,
            FSM_SCAL_RD8   = 6'd14,
            FSM_SCAL_RD9   = 6'd15,
            FSM_LCAL_RD1   = 6'd16,
            FSM_LCAL_WR1   = 6'd17,
            FSM_LCAL_RD2   = 6'd18,
            FSM_LCAL_WR2   = 6'd19,
            FSM_LCAL_RD3   = 6'd20,
            FSM_LCAL_WR3   = 6'd21,
            FSM_LCAL_RD4   = 6'd22,
            FSM_LCAL_WR4   = 6'd23,
            FSM_LCAL_RD5   = 6'd24,
            FSM_LCAL_WR5   = 6'd25,
            FSM_LCAL_RD6   = 6'd26,
            FSM_LCAL_WR6   = 6'd27,
            FSM_LCAL_RD7   = 6'd28,
            FSM_LCAL_WR7   = 6'd29,
            FSM_LCAL_RD8   = 6'd30,
            FSM_LCAL_WR8   = 6'd31,
            FSM_LCAL_RD9   = 6'd32,
            FSM_LCAL_WR9   = 6'd33,
            FSM_READ       = 6'd34,
            FSM_WRITE      = 6'd35,
            FSM_END        = 6'd36;
localparam CALIB_RATES = 4; 
localparam CALIB_LANES = XCVR ? 4 : 1; 
localparam CALIB_VALUES = XCVR ? 7 : 2; 
localparam CALIB_RES_SIZE = CALIB_RATES * CALIB_LANES * CALIB_VALUES;
reg [5:0] state;
reg [7:0] calib_res [CALIB_RES_SIZE-1:0];
always @ (posedge clk or posedge reset) 
  if(reset) 
  begin
    state <= FSM_IDLE;
    mgmt_chnum  <= 2'd0;
    mgmt_address  <= 10'd0;
    mgmt_write <= 1'b0;
    mgmt_read <= 1'b0;
    mgmt_writedata <= 32'd0;
  end
  else
  begin
    mgmt_write <= 1'b0;  
    mgmt_read <= 1'b0;
    case (state)
      FSM_IDLE:
        if(rcnf_en)
        begin
          if(rcnf_req_cbus)
            state <= FSM_REQBUS_RD;
          if(rcnf_reconfig)
            state <= FSM_READ;
          if(rcnf_rel_cbus)
            state <= FSM_RELBUS_RD;
          if(rcnf_wcalib)
            state <= FSM_WCAL_RD;
          if(rcnf_scalib)
            state <= XCVR ? FSM_SCAL_RD3 : FSM_SCAL_RD1;
          if(rcnf_lcalib)
            state <= XCVR ? FSM_LCAL_RD3 : FSM_LCAL_RD1;
        end
      FSM_REQBUS_RD: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_REQBUS_WR;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= XCVR ? ADDR_XCVR_BUS_ARB : ADDR_TXPLL_BUS_ARB;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_REQBUS_WR: 
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~32'h0000_0001) | 32'h0000_0000;
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_RELBUS_RD: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_RELBUS_WR;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= XCVR ? ADDR_XCVR_BUS_ARB : ADDR_TXPLL_BUS_ARB;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_RELBUS_WR: 
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~32'h0000_0001) | 32'h0000_0001;
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_WCAL_RD: 
        if(~cal_busy)
          state <= FSM_IDLE; 
        else
          state <= FSM_WCAL_RD; 
      FSM_SCAL_RD1: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+0] <= (mgmt_readdata[7:0] & MASK_TXPLL_VCO_BAND1[7:0]);
            state <= FSM_SCAL_RD2;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND1;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD2:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+1] <= (mgmt_readdata[7:0] & MASK_TXPLL_VCO_BAND2[7:0]);
            state <= FSM_IDLE;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND2;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD3: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+0] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED[7:0]);
            state <= FSM_SCAL_RD4;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD4:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+1] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED_FIX[7:0]);
            state <= FSM_SCAL_RD5;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD5:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+2] <= (mgmt_readdata[7:0] & MASK_XCVR_CHGPMP_PD_UP[7:0]);
            state <= FSM_SCAL_RD6;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_UP;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD6:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+3] <= (mgmt_readdata[7:0] & MASK_XCVR_CHGPMP_PD_DN[7:0]);
            state <= FSM_SCAL_RD7;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_DN;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD7:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+4] <= (mgmt_readdata[7:0] & MASK_XCVR_LF_PD_PFD[7:0]);
            state <= FSM_SCAL_RD8;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_LF_PD_PFD;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD8:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+5] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED_FIX_7_6[7:0]);
            state <= FSM_SCAL_RD9;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_7_6;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_SCAL_RD9:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
          begin
            calib_res[rcnf_linkrate*CALIB_VALUES+rcnf_logical_ch*CALIB_RATES*CALIB_VALUES+6] <= (mgmt_readdata[7:0] & MASK_XCVR_CDR_VCO_SPEED_FIX_4[7:0]);
            state <= FSM_IDLE;
          end
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_4;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_RD1: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR1;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND1;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR1:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD2;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_TXPLL_VCO_BAND1) | calib_res[rcnf_linkrate*CALIB_VALUES+0];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD2:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR2;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_TXPLL_VCO_BAND2;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR2:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_TXPLL_VCO_BAND2) | calib_res[rcnf_linkrate*CALIB_VALUES+1];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD3: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR3;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR3:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD4;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED) | calib_res[rcnf_linkrate*CALIB_VALUES+0];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD4:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR4;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR4:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD5;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED_FIX) | calib_res[rcnf_linkrate*CALIB_VALUES+1];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD5:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR5;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_UP;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR5:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD6;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CHGPMP_PD_UP) | calib_res[rcnf_linkrate*CALIB_VALUES+2];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD6:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR6;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CHGPMP_PD_DN;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR6:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD7;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CHGPMP_PD_DN) | calib_res[rcnf_linkrate*CALIB_VALUES+3];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD7:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR7;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_LF_PD_PFD;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR7:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD8;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_LF_PD_PFD) | calib_res[rcnf_linkrate*CALIB_VALUES+4];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD8:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR8;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_7_6;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR8:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_LCAL_RD9;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED_FIX_7_6) | calib_res[rcnf_linkrate*CALIB_VALUES+5];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_LCAL_RD9:
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_LCAL_WR9;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= ADDR_XCVR_CDR_VCO_SPEED_FIX_4;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_LCAL_WR9:
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~MASK_XCVR_CDR_VCO_SPEED_FIX_4) | calib_res[rcnf_linkrate*CALIB_VALUES+6];
            mgmt_write      <= 1'b1;  
          end
        end
      FSM_READ: 
        begin
          if(mgmt_read & !mgmt_waitrequest) 
            state <= FSM_WRITE;
          else
          begin
            mgmt_chnum     <= rcnf_logical_ch;
            mgmt_address   <= rcnf_address;
            mgmt_read      <= 1'b1;  
          end
        end
      FSM_WRITE: 
        begin
          if(mgmt_write & !mgmt_waitrequest) 
            state <= FSM_IDLE;
          else
          begin
            mgmt_writedata  <= (mgmt_readdata & ~rcnf_mask) | rcnf_data;
            mgmt_write      <= 1'b1;  
          end
        end
      endcase
    end
assign rcnf_busy = (state != FSM_IDLE) | rcnf_req_cbus | rcnf_rel_cbus | rcnf_reconfig | rcnf_wcalib | rcnf_scalib | rcnf_lcalib;
endmodule
module dp_analog_mappings 
(
  input  wire [1:0]   vod,  
  input  wire [1:0]   pree, 
  output reg  [4:0]   out_vod, 
  output reg  [5:0]   out_pree_post_tap1 
);
always @(*)
  case (vod)
    2'b00 :  
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd13;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd19;     
          out_pree_post_tap1 = {1'b1,5'd6};
        end
        2'b10 : 
        begin
          out_vod = 5'd25;     
          out_pree_post_tap1 = {1'b1,5'd12};
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd19};
        end
      endcase
    end
    2'b01 : 
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd19;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd28;     
          out_pree_post_tap1 = {1'b1,5'd9};
        end
        2'b10 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd14};
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd14};
        end
      endcase
    end
    2'b10 : 
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd25;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd6}; 
        end
        2'b10 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd6}; 
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd6}; 
        end
      endcase
    end
    2'b11 : 
    begin
      case(pree) 
        2'b00 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0};
        end
        2'b01 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0}; 
        end
        2'b10 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0}; 
        end
        2'b11 : 
        begin
          out_vod = 5'd31;     
          out_pree_post_tap1 = {1'b1,5'd0}; 
        end
      endcase
    end
  endcase
endmodule
`default_nettype wire
