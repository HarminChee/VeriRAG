`timescale 1ns / 1ps
`timescale 1ns / 1ps
module tcp_ip_wrapper #(
    parameter MAC_ADDRESS = 48'hE59D02350A00, 
    parameter IP_ADDRESS = 32'h00000000,
    parameter IP_SUBNET_MASK = 32'h00FFFFFF,
    parameter IP_DEFAULT_GATEWAY = 32'h00000000,
    parameter DHCP_EN   = 0
)(
    input       aclk,
    input       aresetn,
    output      AXI_M_Stream_TVALID,
    input       AXI_M_Stream_TREADY,
    output[63:0] AXI_M_Stream_TDATA,
    output[7:0] AXI_M_Stream_TKEEP,
    output      AXI_M_Stream_TLAST,
    input       AXI_S_Stream_TVALID,
    output      AXI_S_Stream_TREADY,
    input[63:0] AXI_S_Stream_TDATA,
    input[7:0]  AXI_S_Stream_TKEEP,
    input       AXI_S_Stream_TLAST,
    output          m_axis_rxread_cmd_TVALID,
    input           m_axis_rxread_cmd_TREADY,
    output[71:0]    m_axis_rxread_cmd_TDATA,
    output          m_axis_rxwrite_cmd_TVALID,
    input           m_axis_rxwrite_cmd_TREADY,
    output[71:0]    m_axis_rxwrite_cmd_TDATA,
    input           s_axis_rxread_sts_TVALID,
    output          s_axis_rxread_sts_TREADY,
    input[7:0]      s_axis_rxread_sts_TDATA,
    input           s_axis_rxwrite_sts_TVALID,
    output          s_axis_rxwrite_sts_TREADY,
    input[31:0]     s_axis_rxwrite_sts_TDATA,
    input           s_axis_rxread_data_TVALID,
    output          s_axis_rxread_data_TREADY,
    input[63:0]     s_axis_rxread_data_TDATA,
    input[7:0]      s_axis_rxread_data_TKEEP,
    input           s_axis_rxread_data_TLAST,
    output          m_axis_rxwrite_data_TVALID,
    input           m_axis_rxwrite_data_TREADY,
    output[63:0]    m_axis_rxwrite_data_TDATA,
    output[7:0]     m_axis_rxwrite_data_TKEEP,
    output          m_axis_rxwrite_data_TLAST,
    output          m_axis_txread_cmd_TVALID,
    input           m_axis_txread_cmd_TREADY,
    output[71:0]    m_axis_txread_cmd_TDATA,
    output          m_axis_txwrite_cmd_TVALID,
    input           m_axis_txwrite_cmd_TREADY,
    output[71:0]    m_axis_txwrite_cmd_TDATA,
    input           s_axis_txread_sts_TVALID,
    output          s_axis_txread_sts_TREADY,
    input[7:0]      s_axis_txread_sts_TDATA,
    input           s_axis_txwrite_sts_TVALID,
    output          s_axis_txwrite_sts_TREADY,
    input[63:0]     s_axis_txwrite_sts_TDATA,
    input           s_axis_txread_data_TVALID,
    output          s_axis_txread_data_TREADY,
    input[63:0]     s_axis_txread_data_TDATA,
    input[7:0]      s_axis_txread_data_TKEEP,
    input           s_axis_txread_data_TLAST,
    output          m_axis_txwrite_data_TVALID,
    input           m_axis_txwrite_data_TREADY,
    output[63:0]    m_axis_txwrite_data_TDATA,
    output[7:0]     m_axis_txwrite_data_TKEEP,
    output          m_axis_txwrite_data_TLAST,
    output          m_axis_listen_port_status_TVALID,
    input           m_axis_listen_port_status_TREADY,
    output[7:0]     m_axis_listen_port_status_TDATA,
    output          m_axis_notifications_TVALID,
    input           m_axis_notifications_TREADY,
    output[87:0]    m_axis_notifications_TDATA,
    output          m_axis_open_status_TVALID,
    input           m_axis_open_status_TREADY,
    output[23:0]    m_axis_open_status_TDATA,
    output          m_axis_rx_data_TVALID,
    input           m_axis_rx_data_TREADY,
    output[63:0]    m_axis_rx_data_TDATA,
    output[7:0]     m_axis_rx_data_TKEEP,
    output          m_axis_rx_data_TLAST,
    output          m_axis_rx_metadata_TVALID,
    input           m_axis_rx_metadata_TREADY,
    output[15:0]    m_axis_rx_metadata_TDATA,
    output          m_axis_tx_status_TVALID,
    input           m_axis_tx_status_TREADY,
    output[63:0]    m_axis_tx_status_TDATA,
    input           s_axis_listen_port_TVALID,
    output          s_axis_listen_port_TREADY,
    input[15:0]     s_axis_listen_port_TDATA,
    input           s_axis_close_connection_TVALID,
    output          s_axis_close_connection_TREADY,
    input[15:0]     s_axis_close_connection_TDATA,
    input           s_axis_open_connection_TVALID,
    output          s_axis_open_connection_TREADY,
    input[47:0]     s_axis_open_connection_TDATA,
    input           s_axis_read_package_TVALID,
    output          s_axis_read_package_TREADY,
    input[31:0]     s_axis_read_package_TDATA,
    input           s_axis_tx_data_TVALID,
    output          s_axis_tx_data_TREADY,
    input[63:0]     s_axis_tx_data_TDATA,
    input[7:0]      s_axis_tx_data_TKEEP,
    input           s_axis_tx_data_TLAST,
    input           s_axis_tx_metadata_TVALID,
    output          s_axis_tx_metadata_TREADY,
    input[31:0]     s_axis_tx_metadata_TDATA, 
    output debug_axi_intercon_to_mie_tready,
    output debug_axi_intercon_to_mie_tvalid,
    output debug_axi_slice_toe_mie_tvalid,
    output debug_axi_slice_toe_mie_tready,
    output [161:0] debug_out,
    output[31:0]    ip_address_out,
    output[15:0]    regSessionCount_V,
    output          regSessionCount_V_ap_vld,
    input[3:0]      board_number,
    input[1:0]      subnet_number
    );
wire axis_rxread_cmd_TVALID;
wire axis_rxread_cmd_TREADY;
wire[71:0] axis_rxread_cmd_TDATA;
wire axis_rxwrite_cmd_TVALID;
wire axis_rxwrite_cmd_TREADY;
wire[71:0] axis_rxwrite_cmd_TDATA;
wire axis_txread_cmd_TVALID;
wire axis_txread_cmd_TREADY;
wire[71:0] axis_txread_cmd_TDATA;
wire axis_txwrite_cmd_TVALID;
wire axis_txwrite_cmd_TREADY;
wire[71:0] axis_txwrite_cmd_TDATA;
wire axis_rxread_sts_TVALID;
wire axis_rxread_sts_TREADY;
wire[7:0] axis_rxread_sts_TDATA;
wire axis_rxwrite_sts_TVALID;
wire axis_rxwrite_sts_TREADY;
wire[7:0] axis_rxwrite_sts_TDATA;
wire axis_txread_sts_TVALID;
wire axis_txread_sts_TREADY;
wire[7:0] axis_txread_sts_TDATA;
wire axis_txwrite_sts_TVALID;
wire axis_txwrite_sts_TREADY;
wire[63:0] axis_txwrite_sts_TDATA;
wire axis_rxbuffer2app_TVALID;
wire axis_rxbuffer2app_TREADY;
wire[63:0] axis_rxbuffer2app_TDATA;
wire[7:0] axis_rxbuffer2app_TKEEP;
wire axis_rxbuffer2app_TLAST;
wire axis_tcp2rxbuffer_TVALID;
wire axis_tcp2rxbuffer_TREADY;
wire[63:0] axis_tcp2rxbuffer_TDATA;
wire[7:0] axis_tcp2rxbuffer_TKEEP;
wire axis_tcp2rxbuffer_TLAST;
wire axis_txbuffer2tcp_TVALID;
wire axis_txbuffer2tcp_TREADY;
wire[63:0] axis_txbuffer2tcp_TDATA;
wire[7:0] axis_txbuffer2tcp_TKEEP;
wire axis_txbuffer2tcp_TLAST;
wire axis_app2txbuffer_TVALID;
wire axis_app2txbuffer_TREADY;
wire[63:0] axis_app2txbuffer_TDATA;
wire[7:0] axis_app2txbuffer_TKEEP;
wire axis_app2txbuffer_TLAST;
wire        upd_req_TVALID;
wire        upd_req_TREADY;
wire[111:0] upd_req_TDATA; 
wire        upd_rsp_TVALID;
wire        upd_rsp_TREADY;
wire[15:0]  upd_rsp_TDATA;
wire        ins_req_TVALID;
wire        ins_req_TREADY;
wire[111:0] ins_req_TDATA;
wire        del_req_TVALID;
wire        del_req_TREADY;
wire[111:0] del_req_TDATA;
wire        lup_req_TVALID;
wire        lup_req_TREADY;
wire[97:0]  lup_req_TDATA; 
wire        lup_rsp_TVALID;
wire        lup_rsp_TREADY;
wire[15:0]  lup_rsp_TDATA;
wire            axi_iph_to_arp_slice_tvalid;
wire            axi_iph_to_arp_slice_tready;
wire[63:0]      axi_iph_to_arp_slice_tdata;
wire[7:0]       axi_iph_to_arp_slice_tkeep;
wire            axi_iph_to_arp_slice_tlast;
wire            axi_iph_to_icmp_slice_tvalid;
wire            axi_iph_to_icmp_slice_tready;
wire[63:0]      axi_iph_to_icmp_slice_tdata;
wire[7:0]       axi_iph_to_icmp_slice_tkeep;
wire            axi_iph_to_icmp_slice_tlast;
wire            axi_iph_to_udp_slice_tvalid;
wire            axi_iph_to_udp_slice_tready;
wire[63:0]      axi_iph_to_udp_slice_tdata;
wire[7:0]       axi_iph_to_udp_slice_tkeep;
wire            axi_iph_to_udp_slice_tlast;
wire            axi_iph_to_toe_slice_tvalid;
wire            axi_iph_to_toe_slice_tready;
wire[63:0]      axi_iph_to_toe_slice_tdata;
wire[7:0]       axi_iph_to_toe_slice_tkeep;
wire            axi_iph_to_toe_slice_tlast;
wire            axi_arp_slice_to_arp_tvalid;
wire            axi_arp_slice_to_arp_tready;
wire[63:0]      axi_arp_slice_to_arp_tdata;
wire[7:0]       axi_arp_slice_to_arp_tkeep;
wire            axi_arp_slice_to_arp_tlast;
wire            axi_icmp_slice_to_icmp_tvalid;
wire            axi_icmp_slice_to_icmp_tready;
wire[63:0]      axi_icmp_slice_to_icmp_tdata;
wire[7:0]       axi_icmp_slice_to_icmp_tkeep;
wire            axi_icmp_slice_to_icmp_tlast;
wire            axi_udp_slice_to_udp_tvalid;
wire            axi_udp_slice_to_udp_tready;
wire[63:0]      axi_udp_slice_to_udp_tdata;
wire[7:0]       axi_udp_slice_to_udp_tkeep;
wire            axi_udp_slice_to_udp_tlast;
wire            axi_toe_slice_to_toe_tvalid;
wire            axi_toe_slice_to_toe_tready;
wire[63:0]      axi_toe_slice_to_toe_tdata;
wire[7:0]       axi_toe_slice_to_toe_tkeep;
wire            axi_toe_slice_to_toe_tlast;
wire            axi_intercon_to_mie_tvalid;
wire            axi_intercon_to_mie_tready;
wire[63:0]      axi_intercon_to_mie_tdata;
wire[7:0]       axi_intercon_to_mie_tkeep;
wire            axi_intercon_to_mie_tlast;
wire            axi_mie_to_intercon_tvalid;
wire            axi_mie_to_intercon_tready;
wire[63:0]      axi_mie_to_intercon_tdata;
wire[7:0]       axi_mie_to_intercon_tkeep;
wire            axi_mie_to_intercon_tlast;
wire            axi_arp_to_arp_slice_tvalid;
wire            axi_arp_to_arp_slice_tready;
wire[63:0]      axi_arp_to_arp_slice_tdata;
wire[7:0]       axi_arp_to_arp_slice_tkeep;
wire            axi_arp_to_arp_slice_tlast;
wire            axi_icmp_to_icmp_slice_tvalid;
wire            axi_icmp_to_icmp_slice_tready;
wire[63:0]      axi_icmp_to_icmp_slice_tdata;
wire[7:0]       axi_icmp_to_icmp_slice_tkeep;
wire            axi_icmp_to_icmp_slice_tlast;
wire            axi_toe_to_toe_slice_tvalid;
wire            axi_toe_to_toe_slice_tready;
wire[63:0]      axi_toe_to_toe_slice_tdata;
wire[7:0]       axi_toe_to_toe_slice_tkeep;
wire            axi_toe_to_toe_slice_tlast;
wire        axi_udp_to_merge_tvalid;
wire        axi_udp_to_merge_tready;
wire[63:0]  axi_udp_to_merge_tdata;
wire[7:0]   axi_udp_to_merge_tkeep;
wire        axi_udp_to_merge_tlast;
wire cam_ready;
wire sc_led0;
wire sc_led1;
wire[255:0] sc_debug;
wire [157:0] debug_out_ips;
assign debug_axi_intercon_to_mie_tready = axi_intercon_to_mie_tready;
assign debug_axi_intercon_to_mie_tvalid = axi_intercon_to_mie_tvalid;
assign debug_axi_slice_toe_mie_tvalid = axi_mie_to_intercon_tvalid;
assign debug_axi_slice_toe_mie_tready = axi_mie_to_intercon_tready;
assign m_axis_rxread_cmd_TVALID       = axis_rxread_cmd_TVALID;
assign axis_rxread_cmd_TREADY       = m_axis_rxread_cmd_TREADY;
assign m_axis_rxread_cmd_TDATA        = axis_rxread_cmd_TDATA;
assign m_axis_rxwrite_cmd_TVALID      = axis_rxwrite_cmd_TVALID;
assign axis_rxwrite_cmd_TREADY      = m_axis_rxwrite_cmd_TREADY;
assign m_axis_rxwrite_cmd_TDATA       = axis_rxwrite_cmd_TDATA;
assign axis_rxread_sts_TVALID       = s_axis_rxread_sts_TVALID;
assign s_axis_rxread_sts_TREADY       = axis_rxread_sts_TREADY;
assign axis_rxread_sts_TDATA        = s_axis_rxread_sts_TDATA;
assign axis_rxwrite_sts_TVALID      = s_axis_rxwrite_sts_TVALID;
assign s_axis_rxwrite_sts_TREADY      = axis_rxwrite_sts_TREADY;
assign axis_rxwrite_sts_TDATA       = s_axis_rxwrite_sts_TDATA;
assign m_axis_txread_cmd_TVALID       = axis_txread_cmd_TVALID;
assign axis_txread_cmd_TREADY         = m_axis_txread_cmd_TREADY;
assign m_axis_txread_cmd_TDATA        = axis_txread_cmd_TDATA;
assign m_axis_txwrite_cmd_TVALID      = axis_txwrite_cmd_TVALID;
assign axis_txwrite_cmd_TREADY        = m_axis_txwrite_cmd_TREADY;
assign m_axis_txwrite_cmd_TDATA       = axis_txwrite_cmd_TDATA;
assign axis_txread_sts_TVALID         = s_axis_txread_sts_TVALID;
assign s_axis_txread_sts_TREADY       = axis_txread_sts_TREADY;
assign axis_txread_sts_TDATA          = s_axis_txread_sts_TDATA;
assign axis_txwrite_sts_TVALID        = s_axis_txwrite_sts_TVALID;
assign s_axis_txwrite_sts_TREADY      = axis_txwrite_sts_TREADY;
assign axis_txwrite_sts_TDATA         = s_axis_txwrite_sts_TDATA;
assign     axis_txbuffer2tcp_TVALID = s_axis_txread_data_TVALID;
assign     s_axis_txread_data_TREADY = axis_txbuffer2tcp_TREADY;
assign     axis_txbuffer2tcp_TDATA = s_axis_txread_data_TDATA;
assign     axis_txbuffer2tcp_TKEEP = s_axis_txread_data_TKEEP;
assign     axis_txbuffer2tcp_TLAST = s_axis_txread_data_TLAST;
assign     m_axis_txwrite_data_TVALID = axis_app2txbuffer_TVALID;
assign     axis_app2txbuffer_TREADY = m_axis_txwrite_data_TREADY;
assign     m_axis_txwrite_data_TDATA = axis_app2txbuffer_TDATA;
assign     m_axis_txwrite_data_TKEEP = axis_app2txbuffer_TKEEP;
assign     m_axis_txwrite_data_TLAST = axis_app2txbuffer_TLAST;
assign axis_rxread_sts_TREADY = 1'b1;
assign axis_txread_sts_TREADY = 1'b1;
wire[31:0]  dhcp_ip_address;
wire        dhcp_ip_address_en;
reg[47:0]   mie_mac_address;
reg[47:0]   arp_mac_address;
reg[31:0]   iph_ip_address;
reg[31:0]   arp_ip_address;
reg[31:0]   toe_ip_address;
reg[31:0]   ip_subnet_mask;
reg[31:0]   ip_default_gateway;
always @(posedge aclk)
begin
    if (aresetn == 0) begin
        mie_mac_address <= 48'h000000000000;
        arp_mac_address <= 48'h000000000000;
        iph_ip_address <= 32'h00000000;
        arp_ip_address <= 32'h00000000;
        toe_ip_address <= 32'h00000000;
        ip_subnet_mask <= 32'h00000000;
        ip_default_gateway <= 32'h00000000;
    end
    else begin
        mie_mac_address <= {MAC_ADDRESS[47:44], (MAC_ADDRESS[43:40]+board_number), MAC_ADDRESS[39:0]};
        arp_mac_address <= {MAC_ADDRESS[47:44], (MAC_ADDRESS[43:40]+board_number), MAC_ADDRESS[39:0]};
        if (DHCP_EN == 1) begin
            if (dhcp_ip_address_en == 1'b1) begin
                iph_ip_address <= dhcp_ip_address;
                arp_ip_address <= dhcp_ip_address;
                toe_ip_address <= dhcp_ip_address;
            end
        end
        else begin
            iph_ip_address <= {IP_ADDRESS[31:28], IP_ADDRESS[27:24]+board_number, IP_ADDRESS[23:4], IP_ADDRESS[3:0]+subnet_number};
            arp_ip_address <= {IP_ADDRESS[31:28], IP_ADDRESS[27:24]+board_number, IP_ADDRESS[23:4], IP_ADDRESS[3:0]+subnet_number};
            toe_ip_address <= {IP_ADDRESS[31:28], IP_ADDRESS[27:24]+board_number, IP_ADDRESS[23:4], IP_ADDRESS[3:0]+subnet_number};
            ip_subnet_mask <= IP_SUBNET_MASK;
            ip_default_gateway <= {IP_DEFAULT_GATEWAY[31:4], IP_DEFAULT_GATEWAY[3:0]+subnet_number};
        end
    end
end
assign ip_address_out = iph_ip_address;
wire [157:0] debug_out_tcp;
wire [7:0] aux;
assign axis_rxread_cmd_TVALID = 1'b0;
assign axis_rxwrite_cmd_TVALID = 1'b0;
assign axis_rxwrite_sts_TREADY = 1'b1;
wire[31:0] rx_buffer_data_count;
shortcut_toe_NODELAY_ip toe_inst (
.m_axis_tcp_data_TVALID(axi_toe_to_toe_slice_tvalid), 
.m_axis_tcp_data_TREADY(axi_toe_to_toe_slice_tready), 
.m_axis_tcp_data_TDATA(axi_toe_to_toe_slice_tdata), 
.m_axis_tcp_data_TKEEP(axi_toe_to_toe_slice_tkeep), 
.m_axis_tcp_data_TLAST(axi_toe_to_toe_slice_tlast), 
.s_axis_tcp_data_TVALID(axi_toe_slice_to_toe_tvalid), 
.s_axis_tcp_data_TREADY(axi_toe_slice_to_toe_tready), 
.s_axis_tcp_data_TDATA(axi_toe_slice_to_toe_tdata), 
.s_axis_tcp_data_TKEEP(axi_toe_slice_to_toe_tkeep), 
.s_axis_tcp_data_TLAST(axi_toe_slice_to_toe_tlast), 
.s_axis_rxread_data_TVALID(axis_rxbuffer2app_TVALID),
.s_axis_rxread_data_TREADY(axis_rxbuffer2app_TREADY),
.s_axis_rxread_data_TDATA(axis_rxbuffer2app_TDATA),
.s_axis_rxread_data_TKEEP(axis_rxbuffer2app_TKEEP),
.s_axis_rxread_data_TLAST(axis_rxbuffer2app_TLAST),
.m_axis_rxwrite_data_TVALID(axis_tcp2rxbuffer_TVALID),
.m_axis_rxwrite_data_TREADY(axis_tcp2rxbuffer_TREADY),
.m_axis_rxwrite_data_TDATA(axis_tcp2rxbuffer_TDATA),
.m_axis_rxwrite_data_TKEEP(axis_tcp2rxbuffer_TKEEP),
.m_axis_rxwrite_data_TLAST(axis_tcp2rxbuffer_TLAST),
.m_axis_txread_cmd_TVALID(axis_txread_cmd_TVALID),
.m_axis_txread_cmd_TREADY(axis_txread_cmd_TREADY),
.m_axis_txread_cmd_TDATA(axis_txread_cmd_TDATA),
.m_axis_txwrite_cmd_TVALID(axis_txwrite_cmd_TVALID),
.m_axis_txwrite_cmd_TREADY(axis_txwrite_cmd_TREADY),
.m_axis_txwrite_cmd_TDATA(axis_txwrite_cmd_TDATA),
.s_axis_txwrite_sts_TVALID(axis_txwrite_sts_TVALID),
.s_axis_txwrite_sts_TREADY(axis_txwrite_sts_TREADY),
.s_axis_txwrite_sts_TDATA(axis_txwrite_sts_TDATA),
.s_axis_txread_data_TVALID(axis_txbuffer2tcp_TVALID),
.s_axis_txread_data_TREADY(axis_txbuffer2tcp_TREADY),
.s_axis_txread_data_TDATA(axis_txbuffer2tcp_TDATA),
.s_axis_txread_data_TKEEP(axis_txbuffer2tcp_TKEEP),
.s_axis_txread_data_TLAST(axis_txbuffer2tcp_TLAST),
.m_axis_txwrite_data_TVALID(axis_app2txbuffer_TVALID),
.m_axis_txwrite_data_TREADY(axis_app2txbuffer_TREADY),
.m_axis_txwrite_data_TDATA(axis_app2txbuffer_TDATA),
.m_axis_txwrite_data_TKEEP(axis_app2txbuffer_TKEEP),
.m_axis_txwrite_data_TLAST(axis_app2txbuffer_TLAST),
.m_axis_session_upd_req_TVALID(upd_req_TVALID),
.m_axis_session_upd_req_TREADY(upd_req_TREADY),
.m_axis_session_upd_req_TDATA(upd_req_TDATA),
.s_axis_session_upd_rsp_TVALID(upd_rsp_TVALID),
.s_axis_session_upd_rsp_TREADY(upd_rsp_TREADY),
.s_axis_session_upd_rsp_TDATA(upd_rsp_TDATA),
.m_axis_session_lup_req_TVALID(lup_req_TVALID),
.m_axis_session_lup_req_TREADY(lup_req_TREADY),
.m_axis_session_lup_req_TDATA(lup_req_TDATA),
.s_axis_session_lup_rsp_TVALID(lup_rsp_TVALID),
.s_axis_session_lup_rsp_TREADY(lup_rsp_TREADY),
.s_axis_session_lup_rsp_TDATA(lup_rsp_TDATA),
.s_axis_listen_port_req_TVALID(s_axis_listen_port_TVALID),
.s_axis_listen_port_req_TREADY(s_axis_listen_port_TREADY),
.s_axis_listen_port_req_TDATA(s_axis_listen_port_TDATA),
.m_axis_listen_port_rsp_TVALID(m_axis_listen_port_status_TVALID),
.m_axis_listen_port_rsp_TREADY(m_axis_listen_port_status_TREADY),
.m_axis_listen_port_rsp_TDATA(m_axis_listen_port_status_TDATA),
.m_axis_notification_TVALID(m_axis_notifications_TVALID),
.m_axis_notification_TREADY(m_axis_notifications_TREADY),
.m_axis_notification_TDATA(m_axis_notifications_TDATA),
.s_axis_rx_data_req_TVALID(s_axis_read_package_TVALID),
.s_axis_rx_data_req_TREADY(s_axis_read_package_TREADY),
.s_axis_rx_data_req_TDATA(s_axis_read_package_TDATA),
.s_axis_open_conn_req_TVALID(s_axis_open_connection_TVALID),
.s_axis_open_conn_req_TREADY(s_axis_open_connection_TREADY),
.s_axis_open_conn_req_TDATA(s_axis_open_connection_TDATA),
.m_axis_open_conn_rsp_TVALID(m_axis_open_status_TVALID),
.m_axis_open_conn_rsp_TREADY(m_axis_open_status_TREADY),
.m_axis_open_conn_rsp_TDATA(m_axis_open_status_TDATA),
.s_axis_close_conn_req_TVALID(s_axis_close_connection_TVALID),
.s_axis_close_conn_req_TREADY(s_axis_close_connection_TREADY),
.s_axis_close_conn_req_TDATA(s_axis_close_connection_TDATA),
.m_axis_rx_data_rsp_metadata_TVALID(m_axis_rx_metadata_TVALID),
.m_axis_rx_data_rsp_metadata_TREADY(m_axis_rx_metadata_TREADY),
.m_axis_rx_data_rsp_metadata_TDATA(m_axis_rx_metadata_TDATA),
.m_axis_rx_data_rsp_TVALID(m_axis_rx_data_TVALID),
.m_axis_rx_data_rsp_TREADY(m_axis_rx_data_TREADY),
.m_axis_rx_data_rsp_TDATA(m_axis_rx_data_TDATA),
.m_axis_rx_data_rsp_TKEEP(m_axis_rx_data_TKEEP),
.m_axis_rx_data_rsp_TLAST(m_axis_rx_data_TLAST),
.s_axis_tx_data_req_metadata_TVALID(s_axis_tx_metadata_TVALID),
.s_axis_tx_data_req_metadata_TREADY(s_axis_tx_metadata_TREADY),
.s_axis_tx_data_req_metadata_TDATA(s_axis_tx_metadata_TDATA),
.s_axis_tx_data_req_TVALID(s_axis_tx_data_TVALID),
.s_axis_tx_data_req_TREADY(s_axis_tx_data_TREADY),
.s_axis_tx_data_req_TDATA(s_axis_tx_data_TDATA),
.s_axis_tx_data_req_TKEEP(s_axis_tx_data_TKEEP),
.s_axis_tx_data_req_TLAST(s_axis_tx_data_TLAST),
.m_axis_tx_data_rsp_TVALID(m_axis_tx_status_TVALID),
.m_axis_tx_data_rsp_TREADY(m_axis_tx_status_TREADY),
.m_axis_tx_data_rsp_TDATA(m_axis_tx_status_TDATA[63:0]),
.regIpAddress_V(toe_ip_address),
.regSessionCount_V(regSessionCount_V),
.regSessionCount_V_ap_vld(regSessionCount_V_ap_vld),
.axis_data_count_V(rx_buffer_data_count),
.axis_max_data_count_V(32'd2048),
.aclk(aclk), 
.aresetn(aresetn) 
);
assign debug_out = {debug_out_tcp[137:0], debug_out_ips[19:0]};
fifo_generator_0 rx_buffer_fifo (
  .s_aresetn(aresetn),          
  .s_aclk(aclk),                
  .s_axis_tvalid(axis_tcp2rxbuffer_TVALID),            
  .s_axis_tready(axis_tcp2rxbuffer_TREADY),            
  .s_axis_tdata(axis_tcp2rxbuffer_TDATA),              
  .s_axis_tkeep(axis_tcp2rxbuffer_TKEEP),              
  .s_axis_tlast(axis_tcp2rxbuffer_TLAST),              
  .m_axis_tvalid(axis_rxbuffer2app_TVALID),            
  .m_axis_tready(axis_rxbuffer2app_TREADY),            
  .m_axis_tdata(axis_rxbuffer2app_TDATA),              
  .m_axis_tkeep(axis_rxbuffer2app_TKEEP),              
  .m_axis_tlast(axis_rxbuffer2app_TLAST),              
  .axis_data_count(rx_buffer_data_count[11:0])
);
assign rx_buffer_data_count[31:12] = 20'h0;
SmartCamCtl SmartCamCtl_inst
(
.clk(aclk),
.rst(~aresetn),
.led0(sc_led0),
.led1(sc_led1),
.cam_ready(cam_ready),
.lup_req_valid(lup_req_TVALID),
.lup_req_ready(lup_req_TREADY),
.lup_req_din(lup_req_TDATA),
.lup_rsp_valid(lup_rsp_TVALID),
.lup_rsp_ready(lup_rsp_TREADY),
.lup_rsp_dout(lup_rsp_TDATA),
.upd_req_valid(upd_req_TVALID),
.upd_req_ready(upd_req_TREADY),
.upd_req_din(upd_req_TDATA),
.upd_rsp_valid(upd_rsp_TVALID),
.upd_rsp_ready(upd_rsp_TREADY),
.upd_rsp_dout(upd_rsp_TDATA),
.debug(sc_debug)
);
wire        axis_dhcp_open_port_tvalid;
wire        axis_dhcp_open_port_tready;
wire[15:0]  axis_dhcp_open_port_tdata;
wire        axis_dhcp_open_port_status_tvalid;
wire        axis_dhcp_open_port_status_tready;
wire[7:0]   axis_dhcp_open_port_status_tdata; 
wire        axis_dhcp_rx_data_tvalid;
wire        axis_dhcp_rx_data_tready;
wire[63:0]  axis_dhcp_rx_data_tdata;
wire[7:0]   axis_dhcp_rx_data_tkeep;
wire        axis_dhcp_rx_data_tlast;
wire        axis_dhcp_rx_metadata_tvalid;
wire        axis_dhcp_rx_metadata_tready;
wire[95:0]  axis_dhcp_rx_metadata_tdata;
wire        axis_dhcp_tx_data_tvalid;
wire        axis_dhcp_tx_data_tready;
wire[63:0]  axis_dhcp_tx_data_tdata;
wire[7:0]   axis_dhcp_tx_data_tkeep;
wire        axis_dhcp_tx_data_tlast;
wire        axis_dhcp_tx_metadata_tvalid;
wire        axis_dhcp_tx_metadata_tready;
wire[95:0]  axis_dhcp_tx_metadata_tdata;
wire        axis_dhcp_tx_length_tvalid;
wire        axis_dhcp_tx_length_tready;
wire[15:0]  axis_dhcp_tx_length_tdata;
assign axi_udp_slice_to_udp_tready = 1'b1;
assign axi_udp_to_merge_tvalid = 1'b0;
assign axi_udp_to_merge_tdata = 0;
assign axi_udp_to_merge_tkeep = 0;
assign axi_udp_to_merge_tlast = 0;
ip_handler_ip ip_handler_inst (
.m_axis_ARP_TVALID(axi_iph_to_arp_slice_tvalid), 
.m_axis_ARP_TREADY(axi_iph_to_arp_slice_tready), 
.m_axis_ARP_TDATA(axi_iph_to_arp_slice_tdata), 
.m_axis_ARP_TKEEP(axi_iph_to_arp_slice_tkeep), 
.m_axis_ARP_TLAST(axi_iph_to_arp_slice_tlast), 
.m_axis_ICMP_TVALID(axi_iph_to_icmp_slice_tvalid), 
.m_axis_ICMP_TREADY(axi_iph_to_icmp_slice_tready), 
.m_axis_ICMP_TDATA(axi_iph_to_icmp_slice_tdata), 
.m_axis_ICMP_TKEEP(axi_iph_to_icmp_slice_tkeep), 
.m_axis_ICMP_TLAST(axi_iph_to_icmp_slice_tlast), 
.m_axis_UDP_TVALID(axi_iph_to_udp_slice_tvalid),          
.m_axis_UDP_TREADY(axi_iph_to_udp_slice_tready),          
.m_axis_UDP_TDATA(axi_iph_to_udp_slice_tdata),            
.m_axis_UDP_TKEEP(axi_iph_to_udp_slice_tkeep),            
.m_axis_UDP_TLAST(axi_iph_to_udp_slice_tlast),            
.m_axis_TCP_TVALID(axi_iph_to_toe_slice_tvalid), 
.m_axis_TCP_TREADY(axi_iph_to_toe_slice_tready), 
.m_axis_TCP_TDATA(axi_iph_to_toe_slice_tdata), 
.m_axis_TCP_TKEEP(axi_iph_to_toe_slice_tkeep), 
.m_axis_TCP_TLAST(axi_iph_to_toe_slice_tlast), 
.s_axis_raw_TVALID(AXI_S_Stream_TVALID), 
.s_axis_raw_TREADY(AXI_S_Stream_TREADY), 
.s_axis_raw_TDATA(AXI_S_Stream_TDATA), 
.s_axis_raw_TKEEP(AXI_S_Stream_TKEEP), 
.s_axis_raw_TLAST(AXI_S_Stream_TLAST), 
.regIpAddress_V(iph_ip_address),
.aclk(aclk), 
.aresetn(aresetn) 
);
assign debug_out_ips[0] = axi_iph_to_arp_slice_tvalid;
assign debug_out_ips[1] = axi_iph_to_arp_slice_tready;
assign debug_out_ips[2] = axi_iph_to_arp_slice_tlast;
assign debug_out_ips[3] = axi_iph_to_icmp_slice_tvalid;
assign debug_out_ips[4] = axi_iph_to_icmp_slice_tready;
assign debug_out_ips[5] = axi_iph_to_icmp_slice_tlast;
assign debug_out_ips[6] = axi_iph_to_toe_slice_tvalid;
assign debug_out_ips[7] = axi_iph_to_toe_slice_tready;
assign debug_out_ips[8] = axi_iph_to_toe_slice_tlast;
assign debug_out_ips[9] = AXI_S_Stream_TVALID;
assign debug_out_ips[10] = AXI_S_Stream_TREADY;
assign debug_out_ips[11] = AXI_S_Stream_TLAST;
wire        axis_arp_lookup_request_TVALID;
wire        axis_arp_lookup_request_TREADY;
wire[31:0]  axis_arp_lookup_request_TDATA;
wire        axis_arp_lookup_reply_TVALID;
wire        axis_arp_lookup_reply_TREADY;
wire[55:0]  axis_arp_lookup_reply_TDATA;
mac_ip_encode_ip mac_ip_encode_inst (
.m_axis_ip_TVALID(axi_mie_to_intercon_tvalid),
.m_axis_ip_TREADY(axi_mie_to_intercon_tready),
.m_axis_ip_TDATA(axi_mie_to_intercon_tdata),
.m_axis_ip_TKEEP(axi_mie_to_intercon_tkeep),
.m_axis_ip_TLAST(axi_mie_to_intercon_tlast),
.m_axis_arp_lookup_request_TVALID(axis_arp_lookup_request_TVALID),
.m_axis_arp_lookup_request_TREADY(axis_arp_lookup_request_TREADY),
.m_axis_arp_lookup_request_TDATA(axis_arp_lookup_request_TDATA),
.s_axis_ip_TVALID(axi_intercon_to_mie_tvalid),
.s_axis_ip_TREADY(axi_intercon_to_mie_tready),
.s_axis_ip_TDATA(axi_intercon_to_mie_tdata),
.s_axis_ip_TKEEP(axi_intercon_to_mie_tkeep),
.s_axis_ip_TLAST(axi_intercon_to_mie_tlast),
.s_axis_arp_lookup_reply_TVALID(axis_arp_lookup_reply_TVALID),
.s_axis_arp_lookup_reply_TREADY(axis_arp_lookup_reply_TREADY),
.s_axis_arp_lookup_reply_TDATA(axis_arp_lookup_reply_TDATA),
.myMacAddress_V(mie_mac_address),                                    
.regSubNetMask_V(ip_subnet_mask),                                    
.regDefaultGateway_V(ip_default_gateway),                            
.aclk(aclk), 
.aresetn(aresetn) 
);
axis_interconnect_3to1 ip_merger (
  .ACLK(aclk), 
  .ARESETN(aresetn), 
  .S00_AXIS_ACLK(aclk), 
  .S00_AXIS_ARESETN(aresetn), 
  .S00_AXIS_TVALID(axi_icmp_to_icmp_slice_tvalid), 
  .S00_AXIS_TREADY(axi_icmp_to_icmp_slice_tready), 
  .S00_AXIS_TDATA(axi_icmp_to_icmp_slice_tdata), 
  .S00_AXIS_TKEEP(axi_icmp_to_icmp_slice_tkeep), 
  .S00_AXIS_TLAST(axi_icmp_to_icmp_slice_tlast), 
  .S01_AXIS_ACLK(aclk), 
  .S01_AXIS_ARESETN(aresetn), 
  .S01_AXIS_TVALID(axi_udp_to_merge_tvalid), 
  .S01_AXIS_TREADY(axi_udp_to_merge_tready), 
  .S01_AXIS_TDATA(axi_udp_to_merge_tdata), 
  .S01_AXIS_TKEEP(axi_udp_to_merge_tkeep), 
  .S01_AXIS_TLAST(axi_udp_to_merge_tlast), 
  .S02_AXIS_ACLK(aclk), 
  .S02_AXIS_ARESETN(aresetn), 
  .S02_AXIS_TVALID(axi_toe_to_toe_slice_tvalid), 
  .S02_AXIS_TREADY(axi_toe_to_toe_slice_tready), 
  .S02_AXIS_TDATA(axi_toe_to_toe_slice_tdata), 
  .S02_AXIS_TKEEP(axi_toe_to_toe_slice_tkeep), 
  .S02_AXIS_TLAST(axi_toe_to_toe_slice_tlast), 
  .M00_AXIS_ACLK(aclk), 
  .M00_AXIS_ARESETN(aresetn), 
  .M00_AXIS_TVALID(axi_intercon_to_mie_tvalid), 
  .M00_AXIS_TREADY(axi_intercon_to_mie_tready), 
  .M00_AXIS_TDATA(axi_intercon_to_mie_tdata), 
  .M00_AXIS_TKEEP(axi_intercon_to_mie_tkeep), 
  .M00_AXIS_TLAST(axi_intercon_to_mie_tlast), 
  .S00_ARB_REQ_SUPPRESS(1'b0), 
  .S01_ARB_REQ_SUPPRESS(1'b0), 
  .S02_ARB_REQ_SUPPRESS(1'b0) 
);
axis_interconnect_2to1 mac_merger (
  .ACLK(aclk), 
  .ARESETN(aresetn), 
  .S00_AXIS_ACLK(aclk), 
  .S01_AXIS_ACLK(aclk), 
  .S00_AXIS_ARESETN(aresetn), 
  .S01_AXIS_ARESETN(aresetn), 
  .S00_AXIS_TVALID(axi_arp_to_arp_slice_tvalid), 
  .S01_AXIS_TVALID(axi_mie_to_intercon_tvalid), 
  .S00_AXIS_TREADY(axi_arp_to_arp_slice_tready), 
  .S01_AXIS_TREADY(axi_mie_to_intercon_tready), 
  .S00_AXIS_TDATA(axi_arp_to_arp_slice_tdata), 
  .S01_AXIS_TDATA(axi_mie_to_intercon_tdata), 
  .S00_AXIS_TKEEP(axi_arp_to_arp_slice_tkeep), 
  .S01_AXIS_TKEEP(axi_mie_to_intercon_tkeep), 
  .S00_AXIS_TLAST(axi_arp_to_arp_slice_tlast), 
  .S01_AXIS_TLAST(axi_mie_to_intercon_tlast), 
  .M00_AXIS_ACLK(aclk), 
  .M00_AXIS_ARESETN(aresetn), 
  .M00_AXIS_TVALID(AXI_M_Stream_TVALID), 
  .M00_AXIS_TREADY(AXI_M_Stream_TREADY), 
  .M00_AXIS_TDATA(AXI_M_Stream_TDATA), 
  .M00_AXIS_TKEEP(AXI_M_Stream_TKEEP), 
  .M00_AXIS_TLAST(AXI_M_Stream_TLAST), 
  .S00_ARB_REQ_SUPPRESS(1'b0), 
  .S01_ARB_REQ_SUPPRESS(1'b0) 
);
assign debug_out_ips[12] = axi_arp_to_arp_slice_tvalid;
assign debug_out_ips[13] = axi_arp_to_arp_slice_tready;
assign debug_out_ips[14] = axi_mie_to_intercon_tvalid;
assign debug_out_ips[15] = axi_mie_to_intercon_tready;
assign debug_out_ips[16] = AXI_M_Stream_TVALID;
assign debug_out_ips[17] = AXI_M_Stream_TREADY;
assign debug_out_ips[18] = AXI_M_Stream_TLAST;
axis_register_slice_64 axis_register_arp_in_slice(
 .aclk(aclk),
 .aresetn(aresetn),
 .s_axis_tvalid(axi_iph_to_arp_slice_tvalid),
 .s_axis_tready(axi_iph_to_arp_slice_tready),
 .s_axis_tdata(axi_iph_to_arp_slice_tdata),
 .s_axis_tkeep(axi_iph_to_arp_slice_tkeep),
 .s_axis_tlast(axi_iph_to_arp_slice_tlast),
 .m_axis_tvalid(axi_arp_slice_to_arp_tvalid),
 .m_axis_tready(axi_arp_slice_to_arp_tready),
 .m_axis_tdata(axi_arp_slice_to_arp_tdata),
 .m_axis_tkeep(axi_arp_slice_to_arp_tkeep),
 .m_axis_tlast(axi_arp_slice_to_arp_tlast)
);
axis_register_slice_64 axis_register_icmp_in_slice(
  .aclk(aclk),
  .aresetn(aresetn),
  .s_axis_tvalid(axi_iph_to_icmp_slice_tvalid),
  .s_axis_tready(axi_iph_to_icmp_slice_tready),
  .s_axis_tdata(axi_iph_to_icmp_slice_tdata),
  .s_axis_tkeep(axi_iph_to_icmp_slice_tkeep),
  .s_axis_tlast(axi_iph_to_icmp_slice_tlast),
  .m_axis_tvalid(axi_icmp_slice_to_icmp_tvalid),
  .m_axis_tready(axi_icmp_slice_to_icmp_tready),
  .m_axis_tdata(axi_icmp_slice_to_icmp_tdata),
  .m_axis_tkeep(axi_icmp_slice_to_icmp_tkeep),
  .m_axis_tlast(axi_icmp_slice_to_icmp_tlast)
);
axis_register_slice_64 axis_register_udp_in_slice(
.aclk(aclk),
.aresetn(aresetn),
.s_axis_tvalid(axi_iph_to_udp_slice_tvalid),
.s_axis_tready(axi_iph_to_udp_slice_tready),
.s_axis_tdata(axi_iph_to_udp_slice_tdata),
.s_axis_tkeep(axi_iph_to_udp_slice_tkeep),
.s_axis_tlast(axi_iph_to_udp_slice_tlast),
.m_axis_tvalid(axi_udp_slice_to_udp_tvalid),
.m_axis_tready(axi_udp_slice_to_udp_tready),
.m_axis_tdata(axi_udp_slice_to_udp_tdata),
.m_axis_tkeep(axi_udp_slice_to_udp_tkeep),
.m_axis_tlast(axi_udp_slice_to_udp_tlast)
);
axis_register_slice_64 axis_register_toe_in_slice(
.aclk(aclk),
.aresetn(aresetn),
.s_axis_tvalid(axi_iph_to_toe_slice_tvalid),
.s_axis_tready(axi_iph_to_toe_slice_tready),
.s_axis_tdata(axi_iph_to_toe_slice_tdata),
.s_axis_tkeep(axi_iph_to_toe_slice_tkeep),
.s_axis_tlast(axi_iph_to_toe_slice_tlast),
.m_axis_tvalid(axi_toe_slice_to_toe_tvalid),
.m_axis_tready(axi_toe_slice_to_toe_tready),
.m_axis_tdata(axi_toe_slice_to_toe_tdata),
.m_axis_tkeep(axi_toe_slice_to_toe_tkeep),
.m_axis_tlast(axi_toe_slice_to_toe_tlast)
);
endmodule
