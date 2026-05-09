`timescale 1ns / 1ps
`default_nettype none

module eth_mac_mii_fifo #
(
    parameter TARGET = "GENERIC",
    parameter CLOCK_INPUT_STYLE = "BUFIO2",
    parameter AXIS_DATA_WIDTH = 8,
    parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8),
    parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8),
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter TX_FIFO_DEPTH = 4096,
    parameter TX_FIFO_PIPELINE_OUTPUT = 2,
    parameter TX_FRAME_FIFO = 1,
    parameter TX_DROP_OVERSIZE_FRAME = TX_FRAME_FIFO,
    parameter TX_DROP_BAD_FRAME = TX_DROP_OVERSIZE_FRAME,
    parameter TX_DROP_WHEN_FULL = 0,
    parameter RX_FIFO_DEPTH = 4096,
    parameter RX_FIFO_PIPELINE_OUTPUT = 2,
    parameter RX_FRAME_FIFO = 1,
    parameter RX_DROP_OVERSIZE_FRAME = RX_FRAME_FIFO,
    parameter RX_DROP_BAD_FRAME = RX_DROP_OVERSIZE_FRAME,
    parameter RX_DROP_WHEN_FULL = RX_DROP_OVERSIZE_FRAME
)
(
    input  wire                       rst, // General reset, may not be needed if logic_rst covers all
    input  wire                       logic_clk,
    input  wire                       logic_rst,
    // TX AXI Stream Input (from logic)
    input  wire [AXIS_DATA_WIDTH-1:0] tx_axis_tdata,
    input  wire [AXIS_KEEP_WIDTH-1:0] tx_axis_tkeep,
    input  wire                       tx_axis_tvalid,
    output wire                       tx_axis_tready,
    input  wire                       tx_axis_tlast,
    input  wire                       tx_axis_tuser, // Can indicate bad frame
    // RX AXI Stream Output (to logic)
    output wire [AXIS_DATA_WIDTH-1:0] rx_axis_tdata,
    output wire [AXIS_KEEP_WIDTH-1:0] rx_axis_tkeep,
    output wire                       rx_axis_tvalid,
    input  wire                       rx_axis_tready,
    output wire                       rx_axis_tlast,
    output wire                       rx_axis_tuser, // Can indicate bad frame
    // MII PHY Interface
    input  wire                       mii_rx_clk,
    input  wire [3:0]                 mii_rxd,
    input  wire                       mii_rx_dv,
    input  wire                       mii_rx_er,
    input  wire                       mii_tx_clk,
    output wire [3:0]                 mii_txd,
    output wire                       mii_tx_en,
    output wire                       mii_tx_er, // MAC generated TX error
    // Status outputs (synchronized to logic_clk)
    output wire                       tx_error_underflow,
    output wire                       tx_fifo_overflow,
    output wire                       tx_fifo_bad_frame,
    output wire                       tx_fifo_good_frame,
    output wire                       rx_error_bad_frame, // MAC detected bad frame (CRC, length, etc.)
    output wire                       rx_error_bad_fcs,   // MAC detected bad FCS
    output wire                       rx_fifo_overflow,
    output wire                       rx_fifo_bad_frame,  // Frame marked as bad in RX FIFO
    output wire                       rx_fifo_good_frame,
    // Configuration
    input  wire [7:0]                 ifg_delay
);

// Internal signals
wire tx_clk; // Clock derived from mii_tx_clk
wire rx_clk; // Clock derived from mii_rx_clk
wire tx_rst; // Reset synchronized to tx_clk
wire rx_rst; // Reset synchronized to rx_clk

// TX FIFO -> MAC signals (tx_clk domain)
wire [7:0]  tx_fifo_axis_tdata;
wire        tx_fifo_axis_tvalid;
wire        tx_fifo_axis_tready;
wire        tx_fifo_axis_tlast;
wire        tx_fifo_axis_tuser; // Carries bad frame indication

// MAC -> RX FIFO signals (rx_clk domain)
wire [7:0]  rx_fifo_axis_tdata;
wire        rx_fifo_axis_tvalid;
wire        rx_fifo_axis_tready; // RX FIFO ready (connected internally)
wire        rx_fifo_axis_tlast;
wire        rx_fifo_axis_tuser; // Carries bad frame indication

// Internal status signals (unsynchronized)
wire tx_error_underflow_int;
wire rx_error_bad_frame_int;
wire rx_error_bad_fcs_int;

// TX error synchronizer (tx_clk -> logic_clk)
reg [0:0] tx_sync_reg_1 = 1'b0;
reg [0:0] tx_sync_reg_2 = 1'b0;
reg [0:0] tx_sync_reg_3 = 1'b0;
reg [0:0] tx_sync_reg_4 = 1'b0;

assign tx_error_underflow = tx_sync_reg_3[0] ^ tx_sync_reg_4[0];

always @(posedge tx_clk or posedge tx_rst) begin
    if (tx_rst) begin
        tx_sync_reg_1 <= 1'b0;
    end else begin
        // Toggle on the rising edge of the error signal
        if (tx_error_underflow_int) begin
            tx_sync_reg_1 <= ~tx_sync_reg_1;
        end
    end
end

always @(posedge logic_clk or posedge logic_rst) begin
    if (logic_rst) begin
        tx_sync_reg_2 <= 1'b0;
        tx_sync_reg_3 <= 1'b0;
        tx_sync_reg_4 <= 1'b0;
    end else begin
        tx_sync_reg_2 <= tx_sync_reg_1;
        tx_sync_reg_3 <= tx_sync_reg_2;
        tx_sync_reg_4 <= tx_sync_reg_3;
    end
end

// RX error synchronizer (rx_clk -> logic_clk)
reg [1:0] rx_sync_reg_1 = 2'd0;
reg [1:0] rx_sync_reg_2 = 2'd0;
reg [1:0] rx_sync_reg_3 = 2'd0;
reg [1:0] rx_sync_reg_4 = 2'd0;

assign rx_error_bad_frame = rx_sync_reg_3[0] ^ rx_sync_reg_4[0];
assign rx_error_bad_fcs   = rx_sync_reg_3[1] ^ rx_sync_reg_4[1];

always @(posedge rx_clk or posedge rx_rst) begin
    if (rx_rst) begin
        rx_sync_reg_1 <= 2'd0;
    end else begin
        // Toggle respective bits on the rising edge of error signals
        rx_sync_reg_1[0] <= rx_error_bad_frame_int ? ~rx_sync_reg_1[0] : rx_sync_reg_1[0];
        rx_sync_reg_1[1] <= rx_error_bad_fcs_int   ? ~rx_sync_reg_1[1] : rx_sync_reg_1[1];
        // Alternative: simultaneous toggle based on XOR
        // rx_sync_reg_1 <= rx_sync_reg_1 ^ {rx_error_bad_fcs_int, rx_error_bad_frame_int};
    end
end

always @(posedge logic_clk or posedge logic_rst) begin
    if (logic_rst) begin
        rx_sync_reg_2 <= 2'd0;
        rx_sync_reg_3 <= 2'd0;
        rx_sync_reg_4 <= 2'd0;
    end else begin
        rx_sync_reg_2 <= rx_sync_reg_1;
        rx_sync_reg_3 <= rx_sync_reg_2;
        rx_sync_reg_4 <= rx_sync_reg_3;
    end
end

// Instantiate the MAC Core
// Assuming eth_mac_mii provides tx_clk, rx_clk, tx_rst, rx_rst outputs
eth_mac_mii #(
    .TARGET(TARGET),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
eth_mac_1g_mii_inst (
    .rst(rst), // Use the global reset for MAC core if needed
    // Clock and Reset Outputs (driven by MAC based on MII clocks/rst)
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    // TX AXI Stream Input (from TX FIFO)
    .tx_axis_tdata(tx_fifo_axis_tdata),
    .tx_axis_tvalid(tx_fifo_axis_tvalid),
    .tx_axis_tready(tx_fifo_axis_tready),
    .tx_axis_tlast(tx_fifo_axis_tlast),
    .tx_axis_tuser(tx_fifo_axis_tuser), // MAC uses this to know if frame is bad
    // RX AXI Stream Output (to RX FIFO)
    .rx_axis_tdata(rx_fifo_axis_tdata),
    .rx_axis_tvalid(rx_fifo_axis_tvalid),
    // .rx_axis_tready(rx_fifo_axis_tready), // MAC doesn't need ready from RX FIFO
    .rx_axis_tlast(rx_fifo_axis_tlast),
    .rx_axis_tuser(rx_fifo_axis_tuser), // MAC generates this for bad frames
    // MII PHY Interface
    .mii_rx_clk(mii_rx_clk),
    .mii_rxd(mii_rxd),
    .mii_rx_dv(mii_rx_dv),
    .mii_rx_er(mii_rx_er),
    .mii_tx_clk(mii_tx_clk),
    .mii_txd(mii_txd),
    .mii_tx_en(mii_tx_en),
    .mii_tx_er(mii_tx_er),
    // Status outputs (unsynchronized)
    .tx_error_underflow(tx_error_underflow_int),
    .rx_error_bad_frame(rx_error_bad_frame_int),
    .rx_error_bad_fcs(rx_error_bad_fcs_int),
    // Configuration
    .ifg_delay(ifg_delay)
);

// Instantiate the TX asynchronous FIFO (logic_clk -> tx_clk)
// Adapts data width if necessary
axis_async_fifo_adapter #(
    .DEPTH(TX_FIFO_DEPTH),
    .S_DATA_WIDTH(AXIS_DATA_WIDTH),
    .S_KEEP_ENABLE(AXIS_KEEP_ENABLE),
    .S_KEEP_WIDTH(AXIS_KEEP_WIDTH),
    .M_DATA_WIDTH(8), // MAC interface is 8-bit
    .M_KEEP_ENABLE(0), // MAC interface has no keep
    .M_KEEP_WIDTH(1),  // Parameter required, but M_KEEP_ENABLE=0
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),   // Pass tuser signal
    .USER_WIDTH(1),
    .PIPELINE_OUTPUT(TX_FIFO_PIPELINE_OUTPUT),
    .FRAME_FIFO(TX_FRAME_FIFO),
    .USER_BAD_FRAME_VALUE(1'b1), // Assuming tuser=1 indicates bad frame
    .USER_BAD_FRAME_MASK(1'b1),
    .DROP_OVERSIZE_FRAME(TX_DROP_OVERSIZE_FRAME),
    .DROP_BAD_FRAME(TX_DROP_BAD_FRAME), // Drop frames marked bad by input tuser
    .DROP_WHEN_FULL(TX_DROP_WHEN_FULL)
)
tx_fifo (
    // Slave side (logic domain)
    .s_clk(logic_clk),
    .s_rst(logic_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(AXIS_KEEP_ENABLE ? tx_axis_tkeep : {AXIS_KEEP_WIDTH{1'b1}}), // Provide keep if enabled
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tid(0),    // Not used
    .s_axis_tdest(0), // Not used
    .s_axis_tuser(tx_axis_tuser),
    // Master side (MAC TX domain)
    .m_clk(tx_clk),
    .m_rst(tx_rst),
    .m_axis_tdata(tx_fifo_axis_tdata),
    .m_axis_tkeep(),   // Not used by MAC
    .m_axis_tvalid(tx_fifo_axis_tvalid),
    .m_axis_tready(tx_fifo_axis_tready), // From MAC
    .m_axis_tlast(tx_fifo_axis_tlast),
    .m_axis_tid(),     // Not used
    .m_axis_tdest(),   // Not used
    .m_axis_tuser(tx_fifo_axis_tuser),
    // Status signals (logic domain)
    .s_status_overflow(tx_fifo_overflow),
    .s_status_bad_frame(tx_fifo_bad_frame), // Frames dropped due to s_axis_tuser=1
    .s_status_good_frame(tx_fifo_good_frame),
    // Status signals (MAC TX domain) - unused
    .m_status_overflow(),
    .m_status_bad_frame(),
    .m_status_good_frame()
);

// Instantiate the RX asynchronous FIFO (rx_clk -> logic_clk)
// Adapts data width if necessary
axis_async_fifo_adapter #(
    .DEPTH(RX_FIFO_DEPTH),
    .S_DATA_WIDTH(8), // MAC interface is 8-bit
    .S_KEEP_ENABLE(0), // MAC interface has no keep
    .S_KEEP_WIDTH(1),  // Parameter required, but S_KEEP_ENABLE=0
    .M_DATA_WIDTH(AXIS_DATA_WIDTH),
    .M_KEEP_ENABLE(AXIS_KEEP_ENABLE),
    .M_KEEP_WIDTH(AXIS_KEEP_WIDTH),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),   // Pass tuser signal
    .USER_WIDTH(1),
    .PIPELINE_OUTPUT(RX_FIFO_PIPELINE_OUTPUT),
    .FRAME_FIFO(RX_FRAME_FIFO),
    .USER_BAD_FRAME_VALUE(1'b1), // tuser=1 indicates bad frame from MAC
    .USER_BAD_FRAME_MASK(1'b1),
    .DROP_OVERSIZE_FRAME(RX_DROP_OVERSIZE_FRAME),
    .DROP_BAD_FRAME(RX_DROP_BAD_FRAME), // Drop frames marked bad by MAC tuser
    .DROP_WHEN_FULL(RX_DROP_WHEN_FULL)
)
rx_fifo (
    // Slave side (MAC RX domain)
    .s_clk(rx_clk),
    .s_rst(rx_rst),
    .s_axis_tdata(rx_fifo_axis_tdata), // From MAC
    .s_axis_tkeep(1'b1), // Not used
    .s_axis_tvalid(rx_fifo_axis_tvalid), // From MAC
    .s_axis_tready(rx_fifo_axis_tready), // To MAC (internally generated by FIFO)
    .s_axis_tlast(rx_fifo_axis_tlast),   // From MAC
    .s_axis_tid(0),    // Not used
    .s_axis_tdest(0), // Not used
    .s_axis_tuser(rx_fifo_axis_tuser),   // From MAC
    // Master side (logic domain)
    .m_clk(logic_clk),
    .m_rst(logic_rst),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep), // Generate keep if enabled
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tready(rx_axis_tready), // From logic
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tid(),     // Not used
    .m_axis_tdest(),   // Not used
    .m_axis_tuser(rx_axis_tuser),
    // Status signals (MAC RX domain) - unused
    .s_status_overflow(),
    .s_status_bad_frame(),
    .s_status_good_frame(),
    // Status signals (logic domain)
    .m_status_overflow(rx_fifo_overflow),
    .m_status_bad_frame(rx_fifo_bad_frame), // Frames dropped due to s_axis_tuser=1
    .m_status_good_frame(rx_fifo_good_frame)
);

endmodule
`default_nettype wire // Revert to default