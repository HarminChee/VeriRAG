`timescale 1ns / 1ps
`timescale 1ns / 1ps
module eth_arb_mux #
(
    parameter S_COUNT = 4,
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    parameter ARB_TYPE_ROUND_ROBIN = 0,
    parameter ARB_LSB_HIGH_PRIORITY = 1
)
(
    input  wire                          clk,
    input  wire                          rst,
    input  wire [S_COUNT-1:0]            s_eth_hdr_valid,
    output wire [S_COUNT-1:0]            s_eth_hdr_ready,
    input  wire [S_COUNT*48-1:0]         s_eth_dest_mac,
    input  wire [S_COUNT*48-1:0]         s_eth_src_mac,
    input  wire [S_COUNT*16-1:0]         s_eth_type,
    input  wire [S_COUNT*DATA_WIDTH-1:0] s_eth_payload_axis_tdata,
    input  wire [S_COUNT*KEEP_WIDTH-1:0] s_eth_payload_axis_tkeep,
    input  wire [S_COUNT-1:0]            s_eth_payload_axis_tvalid,
    output wire [S_COUNT-1:0]            s_eth_payload_axis_tready,
    input  wire [S_COUNT-1:0]            s_eth_payload_axis_tlast,
    input  wire [S_COUNT*ID_WIDTH-1:0]   s_eth_payload_axis_tid,
    input  wire [S_COUNT*DEST_WIDTH-1:0] s_eth_payload_axis_tdest,
    input  wire [S_COUNT*USER_WIDTH-1:0] s_eth_payload_axis_tuser,
    output wire                          m_eth_hdr_valid,
    input  wire                          m_eth_hdr_ready,
    output wire [47:0]                   m_eth_dest_mac,
    output wire [47:0]                   m_eth_src_mac,
    output wire [15:0]                   m_eth_type,
    output wire [DATA_WIDTH-1:0]         m_eth_payload_axis_tdata,
    output wire [KEEP_WIDTH-1:0]         m_eth_payload_axis_tkeep,
    output wire                          m_eth_payload_axis_tvalid,
    input  wire                          m_eth_payload_axis_tready,
    output wire                          m_eth_payload_axis_tlast,
    output wire [ID_WIDTH-1:0]           m_eth_payload_axis_tid,
    output wire [DEST_WIDTH-1:0]         m_eth_payload_axis_tdest,
    output wire [USER_WIDTH-1:0]         m_eth_payload_axis_tuser
);
parameter CL_S_COUNT = $clog2(S_COUNT);
reg frame_reg = 1'b0, frame_next;
reg [S_COUNT-1:0] s_eth_hdr_ready_reg = {S_COUNT{1'b0}}, s_eth_hdr_ready_next;
reg m_eth_hdr_valid_reg = 1'b0, m_eth_hdr_valid_next;
reg [47:0] m_eth_dest_mac_reg = 48'd0, m_eth_dest_mac_next;
reg [47:0] m_eth_src_mac_reg = 48'd0, m_eth_src_mac_next;
reg [15:0] m_eth_type_reg = 16'd0, m_eth_type_next;
wire [S_COUNT-1:0] request_eth;
wire [S_COUNT-1:0] acknowledge_eth;
wire [S_COUNT-1:0] grant_eth;
wire grant_valid_eth;
wire [CL_S_COUNT-1:0] grant_encoded_eth;
reg  [DATA_WIDTH-1:0] m_eth_payload_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] m_eth_payload_axis_tkeep_int;
reg                   m_eth_payload_axis_tvalid_int;
reg                   m_eth_payload_axis_tready_int_reg = 1'b0;
reg                   m_eth_payload_axis_tlast_int;
reg  [ID_WIDTH-1:0]   m_eth_payload_axis_tid_int;
reg  [DEST_WIDTH-1:0] m_eth_payload_axis_tdest_int;
reg  [USER_WIDTH-1:0] m_eth_payload_axis_tuser_int;
wire                  m_eth_payload_axis_tready_int_early;
assign s_eth_hdr_ready = s_eth_hdr_ready_reg;
assign s_eth_payload_axis_tready = (m_eth_payload_axis_tready_int_reg && grant_valid_eth) << grant_encoded_eth;
assign m_eth_hdr_valid = m_eth_hdr_valid_reg;
assign m_eth_dest_mac = m_eth_dest_mac_reg;
assign m_eth_src_mac = m_eth_src_mac_reg;
assign m_eth_type = m_eth_type_reg;
wire [DATA_WIDTH-1:0] current_s_tdata  = s_eth_payload_axis_tdata[grant_encoded_eth*DATA_WIDTH +: DATA_WIDTH];
wire [KEEP_WIDTH-1:0] current_s_tkeep  = s_eth_payload_axis_tkeep[grant_encoded_eth*KEEP_WIDTH +: KEEP_WIDTH];
wire                  current_s_tvalid = s_eth_payload_axis_tvalid[grant_encoded_eth];
wire                  current_s_tready = s_eth_payload_axis_tready[grant_encoded_eth];
wire                  current_s_tlast  = s_eth_payload_axis_tlast[grant_encoded_eth];
wire [ID_WIDTH-1:0]   current_s_tid    = s_eth_payload_axis_tid[grant_encoded_eth*ID_WIDTH +: ID_WIDTH];
wire [DEST_WIDTH-1:0] current_s_tdest  = s_eth_payload_axis_tdest[grant_encoded_eth*DEST_WIDTH +: DEST_WIDTH];
wire [USER_WIDTH-1:0] current_s_tuser  = s_eth_payload_axis_tuser[grant_encoded_eth*USER_WIDTH +: USER_WIDTH];
assign request_eth = s_eth_hdr_valid & ~grant_eth;
assign acknowledge_eth = grant_eth & s_eth_payload_axis_tvalid & s_eth_payload_axis_tready & s_eth_payload_axis_tlast;

arbiter #(
    .PORTS(S_COUNT),
    .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
    .ARB_BLOCK(1),
    .ARB_BLOCK_ACK(1),
    .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
)
arb_inst_eth (
    .clk(clk),
    .rst(rst),
    .request(request_eth),
    //.acknowledge(acknowledge_eth),
    .grant(grant_eth)
    //.grant_valid(grant_valid_eth),
    //.grant_encoded(grant_encoded_eth)
);
always @* begin
    frame_next = frame_reg;
    s_eth_hdr_ready_next = {S_COUNT{1'b0}};
    m_eth_hdr_valid_next = m_eth_hdr_valid_reg && !m_eth_hdr_ready;
    m_eth_dest_mac_next = m_eth_dest_mac_reg;
    m_eth_src_mac_next = m_eth_src_mac_reg;
    m_eth_type_next = m_eth_type_reg;
    if (s_eth_payload_axis_tvalid[grant_encoded_eth] && s_eth_payload_axis_tready[grant_encoded_eth]) begin
        if (s_eth_payload_axis_tlast[grant_encoded_eth]) begin
            frame_next = 1'b0;
        end
    end
    if (!frame_reg && grant_valid_eth && (m_eth_hdr_ready || !m_eth_hdr_valid)) begin
        frame_next = 1'b1;
        s_eth_hdr_ready_next = grant_eth;
        m_eth_hdr_valid_next = 1'b1;
        m_eth_dest_mac_next = s_eth_dest_mac[grant_encoded_eth*48 +: 48];
        m_eth_src_mac_next = s_eth_src_mac[grant_encoded_eth*48 +: 48];
        m_eth_type_next = s_eth_type[grant_encoded_eth*16 +: 16];
    end
    m_eth_payload_axis_tdata_int  = current_s_tdata;
    m_eth_payload_axis_tkeep_int  = current_s_tkeep;
    m_eth_payload_axis_tvalid_int = current_s_tvalid && m_eth_payload_axis_tready_int_reg && grant_valid_eth;
    m_eth_payload_axis_tlast_int  = current_s_tlast;
    m_eth_payload_axis_tid_int    = current_s_tid;
    m_eth_payload_axis_tdest_int  = current_s_tdest;
    m_eth_payload_axis_tuser_int  = current_s_tuser;
end
always @(posedge clk) begin
    frame_reg <= frame_next;
    s_eth_hdr_ready_reg <= s_eth_hdr_ready_next;
    m_eth_hdr_valid_reg <= m_eth_hdr_valid_next;
    m_eth_dest_mac_reg <= m_eth_dest_mac_next;
    m_eth_src_mac_reg <= m_eth_src_mac_next;
    m_eth_type_reg <= m_eth_type_next;
    if (rst) begin
        frame_reg <= 1'b0;
        s_eth_hdr_ready_reg <= {S_COUNT{1'b0}};
        m_eth_hdr_valid_reg <= 1'b0;
    end
end
reg [DATA_WIDTH-1:0] m_eth_payload_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] m_eth_payload_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  m_eth_payload_axis_tvalid_reg = 1'b0, m_eth_payload_axis_tvalid_next;
reg                  m_eth_payload_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   m_eth_payload_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] m_eth_payload_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] m_eth_payload_axis_tuser_reg  = {USER_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] temp_m_eth_payload_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_m_eth_payload_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_m_eth_payload_axis_tvalid_reg = 1'b0, temp_m_eth_payload_axis_tvalid_next;
reg                  temp_m_eth_payload_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_m_eth_payload_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_m_eth_payload_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_m_eth_payload_axis_tuser_reg  = {USER_WIDTH{1'b0}};
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_eth_payload_axis_temp_to_output;
assign m_eth_payload_axis_tdata  = m_eth_payload_axis_tdata_reg;
assign m_eth_payload_axis_tkeep  = KEEP_ENABLE ? m_eth_payload_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign m_eth_payload_axis_tvalid = m_eth_payload_axis_tvalid_reg;
assign m_eth_payload_axis_tlast  = m_eth_payload_axis_tlast_reg;
assign m_eth_payload_axis_tid    = ID_ENABLE   ? m_eth_payload_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign m_eth_payload_axis_tdest  = DEST_ENABLE ? m_eth_payload_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign m_eth_payload_axis_tuser  = USER_ENABLE ? m_eth_payload_axis_tuser_reg : {USER_WIDTH{1'b0}};
assign m_eth_payload_axis_tready_int_early = m_eth_payload_axis_tready || (!temp_m_eth_payload_axis_tvalid_reg && (!m_eth_payload_axis_tvalid_reg || !m_eth_payload_axis_tvalid_int));
always @* begin
    m_eth_payload_axis_tvalid_next = m_eth_payload_axis_tvalid_reg;
    temp_m_eth_payload_axis_tvalid_next = temp_m_eth_payload_axis_tvalid_reg;
    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_eth_payload_axis_temp_to_output = 1'b0;
    if (m_eth_payload_axis_tready_int_reg) begin
        if (m_eth_payload_axis_tready || !m_eth_payload_axis_tvalid_reg) begin
            m_eth_payload_axis_tvalid_next = m_eth_payload_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            temp_m_eth_payload_axis_tvalid_next = m_eth_payload_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (m_eth_payload_axis_tready) begin
        m_eth_payload_axis_tvalid_next = temp_m_eth_payload_axis_tvalid_reg;
        temp_m_eth_payload_axis_tvalid_next = 1'b0;
        store_eth_payload_axis_temp_to_output = 1'b1;
    end
end
always @(posedge clk) begin
    if (rst) begin
        m_eth_payload_axis_tvalid_reg <= 1'b0;
        m_eth_payload_axis_tready_int_reg <= 1'b0;
        temp_m_eth_payload_axis_tvalid_reg <= 1'b0;
    end else begin
        m_eth_payload_axis_tvalid_reg <= m_eth_payload_axis_tvalid_next;
        m_eth_payload_axis_tready_int_reg <= m_eth_payload_axis_tready_int_early;
        temp_m_eth_payload_axis_tvalid_reg <= temp_m_eth_payload_axis_tvalid_next;
    end
    if (store_axis_int_to_output) begin
        m_eth_payload_axis_tdata_reg <= m_eth_payload_axis_tdata_int;
        m_eth_payload_axis_tkeep_reg <= m_eth_payload_axis_tkeep_int;
        m_eth_payload_axis_tlast_reg <= m_eth_payload_axis_tlast_int;
        m_eth_payload_axis_tid_reg   <= m_eth_payload_axis_tid_int;
        m_eth_payload_axis_tdest_reg <= m_eth_payload_axis_tdest_int;
        m_eth_payload_axis_tuser_reg <= m_eth_payload_axis_tuser_int;
    end else if (store_eth_payload_axis_temp_to_output) begin
        m_eth_payload_axis_tdata_reg <= temp_m_eth_payload_axis_tdata_reg;
        m_eth_payload_axis_tkeep_reg <= temp_m_eth_payload_axis_tkeep_reg;
        m_eth_payload_axis_tlast_reg <= temp_m_eth_payload_axis_tlast_reg;
        m_eth_payload_axis_tid_reg   <= temp_m_eth_payload_axis_tid_reg;
        m_eth_payload_axis_tdest_reg <= temp_m_eth_payload_axis_tdest_reg;
        m_eth_payload_axis_tuser_reg <= temp_m_eth_payload_axis_tuser_reg;
    end
    if (store_axis_int_to_temp) begin
        temp_m_eth_payload_axis_tdata_reg <= m_eth_payload_axis_tdata_int;
        temp_m_eth_payload_axis_tkeep_reg <= m_eth_payload_axis_tkeep_int;
        temp_m_eth_payload_axis_tlast_reg <= m_eth_payload_axis_tlast_int;
        temp_m_eth_payload_axis_tid_reg   <= m_eth_payload_axis_tid_int;
        temp_m_eth_payload_axis_tdest_reg <= m_eth_payload_axis_tdest_int;
        temp_m_eth_payload_axis_tuser_reg <= m_eth_payload_axis_tuser_int;
    end
end
endmodule
