module pcie_core_gt_rx_valid_filter_7x #
(
  parameter CLK_COR_MIN_LAT = 28
)
(
  input  wire [1:0]  USER_RXCHARISK,
  input  wire [15:0] USER_RXDATA,
  input  wire        USER_RXVALID,
  input  wire        USER_RXELECIDLE,
  input  wire [2:0]  USER_RX_STATUS,
  input  wire        USER_RX_PHY_STATUS,
  
  output wire [1:0]  GT_RXCHARISK,
  output wire [15:0] GT_RXDATA,
  output wire        GT_RXVALID,
  output wire        GT_RXELECIDLE,
  output wire [2:0]  GT_RX_STATUS,
  output wire        GT_RX_PHY_STATUS,
  
  input  wire        PLM_IN_L0,
  input  wire        PLM_IN_RS,
  input  wire        USER_CLK,
  input  wire        RESET
);

// Register outputs
reg [1:0]  rxcharisk_r;
reg [15:0] rxdata_r;
reg        rxvalid_r;
reg        rxelecidle_r; 
reg [2:0]  rx_status_r;
reg        rx_phy_status_r;

// Filter logic
always @(posedge USER_CLK) begin
  if (RESET) begin
    rxcharisk_r <= 2'b0;
    rxdata_r <= 16'b0;
    rxvalid_r <= 1'b0;
    rxelecidle_r <= 1'b1;
    rx_status_r <= 3'b0;
    rx_phy_status_r <= 1'b0;
  end
  else begin
    if (PLM_IN_L0 || PLM_IN_RS) begin
      rxcharisk_r <= USER_RXCHARISK;
      rxdata_r <= USER_RXDATA;
      rxvalid_r <= USER_RXVALID;
      rxelecidle_r <= USER_RXELECIDLE;
      rx_status_r <= USER_RX_STATUS;
      rx_phy_status_r <= USER_RX_PHY_STATUS;
    end
  end
end

// Assign outputs
assign GT_RXCHARISK = rxcharisk_r;
assign GT_RXDATA = rxdata_r;
assign GT_RXVALID = rxvalid_r;
assign GT_RXELECIDLE = rxelecidle_r;
assign GT_RX_STATUS = rx_status_r;
assign GT_RX_PHY_STATUS = rx_phy_status_r;

endmodule