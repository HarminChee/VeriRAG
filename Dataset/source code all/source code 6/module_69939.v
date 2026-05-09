`timescale 1ns / 1ns
`timescale 1ns / 1ns
module GTX_RX_VALID_FILTER_V6 #(
  parameter           CLK_COR_MIN_LAT    = 28,
  parameter           TCQ                = 1
)
(
  output  [1:0]       USER_RXCHARISK,
  output  [15:0]      USER_RXDATA,
  output              USER_RXVALID,
  output              USER_RXELECIDLE,
  output  [ 2:0]      USER_RX_STATUS,
  output              USER_RX_PHY_STATUS,
  input  [1:0]        GT_RXCHARISK,
  input  [15:0]       GT_RXDATA,
  input               GT_RXVALID,
  input               GT_RXELECIDLE,
  input  [ 2:0]       GT_RX_STATUS,
  input               GT_RX_PHY_STATUS,
  input               PLM_IN_L0,
  input               PLM_IN_RS,
  input               USER_CLK,
  input               RESET
);
  localparam EIOS_DET_IDL      = 5'b00001;
  localparam EIOS_DET_NO_STR0  = 5'b00010;
  localparam EIOS_DET_STR0     = 5'b00100;
  localparam EIOS_DET_STR1     = 5'b01000;
  localparam EIOS_DET_DONE     = 5'b10000;
  localparam EIOS_COM          = 8'hBC;
  localparam EIOS_IDL          = 8'h7C;
  localparam FTSOS_COM         = 8'hBC;
  localparam FTSOS_FTS         = 8'h3C;
  reg    [4:0]        reg_state_eios_det;
  wire   [4:0]        state_eios_det;
  reg                 reg_eios_detected;
  wire                eios_detected;
  reg                 reg_symbol_after_eios;
  wire                symbol_after_eios;
  localparam USER_RXVLD_IDL     = 4'b0001;
  localparam USER_RXVLD_EI      = 4'b0010;
  localparam USER_RXVLD_EI_DB0  = 4'b0100;
  localparam USER_RXVLD_EI_DB1  = 4'b1000;
  reg    [3:0]        reg_state_rxvld_ei;
  wire   [3:0]        state_rxvld_ei;
  reg    [4:0]        reg_rxvld_count;
  wire   [4:0]        rxvld_count;
  reg    [3:0]        reg_rxvld_fallback;
  wire   [3:0]        rxvld_fallback;
  reg    [1:0]        gt_rxcharisk_q;
  reg    [15:0]       gt_rxdata_q;
  reg                 gt_rxvalid_q;
  reg                 gt_rxelecidle_q;
  reg                 gt_rxelecidle_qq;
  reg    [ 2:0]       gt_rx_status_q;
  reg                 gt_rx_phy_status_q;
  reg                 gt_rx_is_skp0_q;
  reg                 gt_rx_is_skp1_q;
  always @(posedge USER_CLK) begin
    if (RESET) begin
      reg_eios_detected <= #TCQ 1'b0;
      reg_state_eios_det <= #TCQ EIOS_DET_IDL;
      reg_symbol_after_eios <= #TCQ 1'b0;
      gt_rxcharisk_q <= #TCQ 2'b00;
      gt_rxdata_q <= #TCQ 16'h0;
      gt_rxvalid_q <= #TCQ 1'b0;
      gt_rxelecidle_q <= #TCQ 1'b0;
      gt_rxelecidle_qq <= #TCQ 1'b0;
      gt_rx_status_q <= #TCQ 3'b000;
      gt_rx_phy_status_q <= #TCQ 1'b0;
      gt_rx_is_skp0_q <= #TCQ 1'b0;
      gt_rx_is_skp1_q <= #TCQ 1'b0;
    end else begin
      reg_eios_detected <= #TCQ 1'b0;
      reg_symbol_after_eios <= #TCQ 1'b0;
      gt_rxcharisk_q <= #TCQ GT_RXCHARISK;
      gt_rxdata_q <= #TCQ GT_RXDATA;
      gt_rxvalid_q <= #TCQ GT_RXVALID;
      gt_rxelecidle_q <= #TCQ GT_RXELECIDLE;
      gt_rxelecidle_qq <= #TCQ gt_rxelecidle_q;
      gt_rx_status_q <= #TCQ GT_RX_STATUS;
      gt_rx_phy_status_q <= #TCQ GT_RX_PHY_STATUS;
      if (GT_RXCHARISK[0] && GT_RXDATA[7:0] == FTSOS_FTS)
        gt_rx_is_skp0_q <= #TCQ 1'b1;
      else
        gt_rx_is_skp0_q <= #TCQ 1'b0;
      if (GT_RXCHARISK[1] && GT_RXDATA[15:8] == FTSOS_FTS)
        gt_rx_is_skp1_q <= #TCQ 1'b1;
      else
        gt_rx_is_skp1_q <= #TCQ 1'b0;
      case ( state_eios_det )
        EIOS_DET_IDL : begin
          if ((gt_rxcharisk_q[0]) && (gt_rxdata_q[7:0] == EIOS_COM) &&
              (gt_rxcharisk_q[1]) && (gt_rxdata_q[15:8] == EIOS_IDL)) begin
            reg_state_eios_det <= #TCQ EIOS_DET_NO_STR0;
            reg_eios_detected <= #TCQ 1'b1;
          end else if ((gt_rxcharisk_q[1]) && (gt_rxdata_q[15:8] == EIOS_COM))
            reg_state_eios_det <= #TCQ EIOS_DET_STR0;
          else
            reg_state_eios_det <= #TCQ EIOS_DET_IDL;
        end
        EIOS_DET_NO_STR0 : begin
          if ((gt_rxcharisk_q[0] && (gt_rxdata_q[7:0] == EIOS_IDL)) &&
              (gt_rxcharisk_q[1] && (gt_rxdata_q[15:8] == EIOS_IDL)))
            reg_state_eios_det <= #TCQ EIOS_DET_DONE;
          else
            reg_state_eios_det <= #TCQ EIOS_DET_IDL;
        end
        EIOS_DET_STR0 : begin
          if ((gt_rxcharisk_q[0] && (gt_rxdata_q[7:0] == EIOS_IDL)) &&
              (gt_rxcharisk_q[1] && (gt_rxdata_q[15:8] == EIOS_IDL))) begin
            reg_state_eios_det <= #TCQ EIOS_DET_STR1;
            reg_eios_detected <= #TCQ 1'b1;
            reg_symbol_after_eios <= #TCQ 1'b1;
          end else
            reg_state_eios_det <= #TCQ EIOS_DET_IDL;
        end
        EIOS_DET_STR1 : begin
          if ((gt_rxcharisk_q[0]) && (gt_rxdata_q[7:0] == EIOS_IDL))
            reg_state_eios_det <= #TCQ EIOS_DET_DONE;
          else
            reg_state_eios_det <= #TCQ EIOS_DET_IDL;
        end
        EIOS_DET_DONE : begin
          reg_state_eios_det <= #TCQ EIOS_DET_IDL;
        end
      endcase
    end
  end
  assign state_eios_det = reg_state_eios_det;
  assign eios_detected = reg_eios_detected;
  assign symbol_after_eios = reg_symbol_after_eios;
  always @(posedge USER_CLK) begin
    if (RESET) begin
      reg_state_rxvld_ei <= #TCQ USER_RXVLD_IDL;
    end else begin
      case ( state_rxvld_ei )
        USER_RXVLD_IDL : begin
          if (eios_detected)
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_EI;
          else
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_IDL;
        end
        USER_RXVLD_EI : begin
          if (!gt_rxvalid_q)
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_EI_DB0;
          else if (rxvld_fallback == 4'b1111)
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_IDL;
          else
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_EI;
        end
        USER_RXVLD_EI_DB0 : begin
          if (gt_rxvalid_q)
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_EI_DB1;
          else if (!PLM_IN_L0)
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_IDL;
          else
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_EI_DB0;
        end
        USER_RXVLD_EI_DB1 : begin
          if (rxvld_count > CLK_COR_MIN_LAT)
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_IDL;
          else
            reg_state_rxvld_ei <= #TCQ USER_RXVLD_EI_DB1;
        end
      endcase
    end
  end
  assign state_rxvld_ei = reg_state_rxvld_ei;
  always @(posedge USER_CLK) begin
    if (RESET) begin
      reg_rxvld_count <= #TCQ 5'b00000;
    end else begin
      if ((gt_rxvalid_q) &&  (state_rxvld_ei == USER_RXVLD_EI_DB1))
        reg_rxvld_count <= #TCQ reg_rxvld_count + 1'b1;
      else
        reg_rxvld_count <= #TCQ 5'b00000;
    end
  end
  assign rxvld_count = reg_rxvld_count;
  always @(posedge USER_CLK) begin
    if (RESET) begin
      reg_rxvld_fallback <= #TCQ 4'b0000;
    end else begin
      if (state_rxvld_ei == USER_RXVLD_EI)
        reg_rxvld_fallback <= #TCQ reg_rxvld_fallback + 1'b1;
      else
        reg_rxvld_fallback <= #TCQ 4'b0000;
    end
  end
  assign rxvld_fallback = reg_rxvld_fallback;
  SRL16E #(.INIT(0)) rx_elec_idle_delay (.Q(USER_RXELECIDLE),
                                         .D(gt_rxelecidle_q),
                                         .CLK(USER_CLK),
                                         .CE(1'b1), .A3(1'b1),.A2(1'b1),.A1(1'b1),.A0(1'b1));
reg      awake_in_progress_q = 1'b0;
reg      awake_see_com_q = 1'b0;
reg [3:0] awake_com_count_q = 4'b0000;
wire    awake_see_com_0 = gt_rxvalid_q & (gt_rxcharisk_q[0] && (gt_rxdata_q[7:0] == EIOS_COM));
wire    awake_see_com_1 = gt_rxvalid_q & (gt_rxcharisk_q[1] && (gt_rxdata_q[15:8] == EIOS_COM));
wire    awake_see_com = (awake_see_com_0 || awake_see_com_1) && ~awake_see_com_q;
wire    awake_done = awake_in_progress_q && (awake_com_count_q[3:0] >= 4'hb);
wire    awake_start = (~gt_rxelecidle_q && gt_rxelecidle_qq) || PLM_IN_RS;
wire    awake_in_progress = awake_start || (~awake_done && awake_in_progress_q);
wire [3:0] awake_com_count_inced = awake_com_count_q[3:0] + 4'b0001;
wire [3:0] awake_com_count = (~awake_in_progress_q) ? 4'b0000 :
                             (awake_start) ? 4'b0000 :
                             (awake_see_com_q) ? awake_com_count_inced[3:0] :
                                                 awake_com_count_q[3:0];
wire    rst_l = ~RESET;
always @(posedge USER_CLK) begin
  awake_see_com_q <= #TCQ (rst_l) ? awake_see_com : 1'b0;
  awake_in_progress_q <= #TCQ (rst_l) ? awake_in_progress : 1'b0;
  awake_com_count_q[3:0] <= #TCQ (rst_l) ? awake_com_count[3:0] : 4'h0;
end
  assign USER_RXVALID = ((state_rxvld_ei == USER_RXVLD_IDL) && ~awake_in_progress_q) ? gt_rxvalid_q : 1'b0;
  assign USER_RXCHARISK[0] = USER_RXVALID ? gt_rxcharisk_q[0] : 1'b0;
  assign USER_RXCHARISK[1] = (USER_RXVALID && !symbol_after_eios) ? gt_rxcharisk_q[1] : 1'b0;
  assign USER_RXDATA[7:0] = (gt_rx_is_skp0_q) ? FTSOS_COM : gt_rxdata_q[7:0];
  assign USER_RXDATA[15:8] = (gt_rx_is_skp1_q) ? FTSOS_COM : gt_rxdata_q[15:8];
  assign USER_RX_STATUS = (state_rxvld_ei == USER_RXVLD_IDL) ? gt_rx_status_q : 3'b000;
  assign USER_RX_PHY_STATUS = gt_rx_phy_status_q;
endmodule
