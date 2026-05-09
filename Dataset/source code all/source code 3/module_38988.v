`timescale 1ns / 1ps
`timescale 1ns / 1ps
module network_module(
    input   clk156,
    input   reset,
    input   aresetn,
    input   dclk,
    input   txusrclk,
    input   txusrclk2,
    output  txclk322,
    input   areset_refclk_bufh,
    input   areset_clk156,
    input   mmcm_locked_clk156,
    input   gttxreset_txusrclk2,
    input   gttxreset,
    input   gtrxreset,
    input   txuserrdy,
    input   qplllock,
    input   qplloutclk,
    input   qplloutrefclk,
    input   reset_counter_done,
    output   tx_resetdone,
    output  txp,
    output  txn,
    input   rxp,
    input   rxn,
    input[63:0]     tx_axis_tdata,
    input           tx_axis_tvalid,
    input           tx_axis_tlast,
    input           tx_axis_tuser,
    input[7:0]      tx_axis_tkeep,
    output          tx_axis_tready,
    output[63:0]    rx_axis_tdata,
    output          rx_axis_tvalid,
    output          rx_axis_tlast,
    output          rx_axis_tuser,
    output[7:0]     rx_axis_tkeep,
    input           rx_axis_tready,
    input           core_reset, 
    input           tx_fault,
    input           signal_detect,
    input[7:0]      tx_ifg_delay,
    output          tx_disable,
    output          rx_fifo_overflow,
    output [29:0]   rx_statistics_vector,
    output          rx_statistics_valid,
    output[7:0]     core_status
);
wire[535:0] configuration_vector;
assign configuration_vector = 0;
wire[63:0] xgmii_txd;
wire[7:0] xgmii_txc;
wire[63:0] xgmii_rxd;
wire[7:0] xgmii_rxc;
reg[63:0] xgmii_txd_reg;
reg[7:0] xgmii_txc_reg;
reg[63:0] xgmii_rxd_reg;
reg[7:0] xgmii_rxc_reg;
reg[63:0] xgmii_txd_reg2;
reg[7:0] xgmii_txc_reg2;
reg[63:0] xgmii_rxd_reg2;
reg[7:0] xgmii_rxc_reg2;
reg[63:0] xgmii_txd_reg3;
reg[7:0] xgmii_txc_reg3;
reg[63:0] xgmii_rxd_reg3;
reg[7:0] xgmii_rxc_reg3;
wire[63:0]      axi_str_tdata_to_xgmac;
wire[7:0]       axi_str_tkeep_to_xgmac;
wire            axi_str_tvalid_to_xgmac;
wire            axi_str_tlast_to_xgmac;
wire            axi_str_tready_to_xgmac;
wire[63:0]      axi_str_rd_tdata_to_fifo;
wire[7:0]       axi_str_rd_tkeep_to_fifo;
wire[0:0]       axi_str_rd_tuser_to_fifo;
wire            axi_str_rd_tvalid_to_fifo;
wire            axi_str_rd_tlast_to_fifo;
wire        tx_axis_slice2interface_tvalid;
wire        tx_axis_slice2interface_tready;
wire[63:0]  tx_axis_slice2interface_tdata;
wire[7:0]   tx_axis_slice2interface_tkeep;
wire        tx_axis_slice2interface_tlast;
wire        rx_axis_interface2slice_tvalid;
wire        rx_axis_interface2slice_tready;
wire[63:0]  rx_axis_interface2slice_tdata;
wire[7:0]   rx_axis_interface2slice_tkeep;
wire        rx_axis_interface2slice_tlast;
always @(posedge clk156) begin
    xgmii_rxd_reg   <= xgmii_rxd;
    xgmii_rxc_reg   <= xgmii_rxc;
    xgmii_txd_reg   <= xgmii_txd;
    xgmii_txc_reg   <= xgmii_txc;
    xgmii_rxd_reg2  <= xgmii_rxd_reg;
    xgmii_rxc_reg2  <= xgmii_rxc_reg;
    xgmii_txd_reg2  <= xgmii_txd_reg;
    xgmii_txc_reg2  <= xgmii_txc_reg;
    xgmii_rxd_reg3  <= xgmii_rxd_reg2;
    xgmii_rxc_reg3  <= xgmii_rxc_reg2;
    xgmii_txd_reg3  <= xgmii_txd_reg2;
    xgmii_txc_reg3  <= xgmii_txc_reg2;
end
wire drp_req;                            
wire drp_den_o;                        
wire drp_dwe_o;                        
wire[15:0] drp_daddr_o;                    
wire[15:0] drp_di_o;                          
wire drp_drdy_o;                      
wire[15:0] drp_drpdo_o;                    
ten_gig_eth_pcs_pma_ip 
ten_gig_eth_pcs_pma_inst
(
.rxrecclk_out(),
.coreclk(clk156),
.dclk(dclk),
.txusrclk(txusrclk),
.txusrclk2(txusrclk2),
.areset(reset),
.txoutclk(txclk322),
.areset_coreclk(areset_clk156),
.gttxreset(gttxreset),
.gtrxreset(gtrxreset),
.txuserrdy(txuserrdy),
.qplllock(qplllock),
.qplloutclk(qplloutclk),
.qplloutrefclk(qplloutrefclk),
.reset_counter_done(reset_counter_done),
.txp(txp),
.txn(txn),
.rxp(rxp),
.rxn(rxn),
.sim_speedup_control(1'b0),    
.xgmii_txd(xgmii_txd_reg3),
.xgmii_txc(xgmii_txc_reg3),
.xgmii_rxd(xgmii_rxd),
.xgmii_rxc(xgmii_rxc),
.configuration_vector(configuration_vector),
.status_vector(),
.core_status(core_status),
.tx_resetdone(tx_resetdone),
.rx_resetdone(),
.signal_detect(signal_detect),
.tx_fault(tx_fault),
.drp_req(drp_req),                            
.drp_gnt(drp_req),                            
.drp_den_o(drp_den_o),                        
.drp_dwe_o(drp_dwe_o),                        
.drp_daddr_o(drp_daddr_o),                    
.drp_di_o(drp_di_o),                          
.drp_drdy_o(drp_drdy_o),                      
.drp_drpdo_o(drp_drpdo_o),                    
.drp_den_i(drp_den_o),                        
.drp_dwe_i(drp_dwe_o),                        
.drp_daddr_i(drp_daddr_o),                    
.drp_di_i(drp_di_o),                          
.drp_drdy_i(drp_drdy_o),                      
.drp_drpdo_i(drp_drpdo_o),
.tx_disable(tx_disable),
.pma_pmd_type(3'b101)
);
ten_gig_eth_mac_ip ten_gig_eth_mac_inst
(
.reset(reset),
.tx_axis_aresetn(~reset),
.tx_axis_tdata(axi_str_tdata_to_xgmac),
.tx_axis_tvalid(axi_str_tvalid_to_xgmac),
.tx_axis_tlast(axi_str_tlast_to_xgmac),
.tx_axis_tuser(1'b0),
.tx_ifg_delay(tx_ifg_delay),
.tx_axis_tkeep(axi_str_tkeep_to_xgmac),
.tx_axis_tready(axi_str_tready_from_xgmac),
.tx_statistics_vector(),
.tx_statistics_valid(),
.rx_axis_aresetn(~reset),
.rx_axis_tdata(axi_str_rd_tdata_to_fifo),
.rx_axis_tvalid(axi_str_rd_tvalid_to_fifo),
.rx_axis_tuser(axi_str_rd_tuser_to_fifo),
.rx_axis_tlast(axi_str_rd_tlast_to_fifo),
.rx_axis_tkeep(axi_str_rd_tkeep_to_fifo),
.rx_statistics_vector(rx_statistics_vector),
.rx_statistics_valid(rx_statistics_valid),
.pause_val(16'b0),
.pause_req(1'b0),
.tx_configuration_vector(80'h00000000000000000016),
.rx_configuration_vector(80'h00000000000000000016),
.status_vector(),
.tx_clk0(clk156),
.tx_dcm_locked(mmcm_locked_clk156),
.xgmii_txd(xgmii_txd),
.xgmii_txc(xgmii_txc),
.rx_clk0(clk156),
.rx_dcm_locked(mmcm_locked_clk156),
.xgmii_rxd(xgmii_rxd_reg3),
.xgmii_rxc(xgmii_rxc_reg3)
);
rx_isolation
rx_interface_i (
.axi_str_tdata_from_xgmac   (axi_str_rd_tdata_to_fifo     ),
.axi_str_tkeep_from_xgmac   (axi_str_rd_tkeep_to_fifo     ),
.axi_str_tvalid_from_xgmac  (axi_str_rd_tvalid_to_fifo    ),
.axi_str_tlast_from_xgmac   (axi_str_rd_tlast_to_fifo     ),
.axi_str_tready_from_fifo   (rx_axis_interface2slice_tready),
.axi_str_tdata_to_fifo      (rx_axis_interface2slice_tdata),
.axi_str_tkeep_to_fifo      (rx_axis_interface2slice_tkeep),
.axi_str_tvalid_to_fifo     (rx_axis_interface2slice_tvalid),
.axi_str_tlast_to_fifo      (rx_axis_interface2slice_tlast),
.user_clk                   (clk156),
.reset                      (reset)
);
tx_interface tx_interface_i (
.axi_str_tdata_to_xgmac   (axi_str_tdata_to_xgmac     ),
.axi_str_tkeep_to_xgmac   (axi_str_tkeep_to_xgmac     ),
.axi_str_tvalid_to_xgmac  (axi_str_tvalid_to_xgmac    ),
.axi_str_tlast_to_xgmac   (axi_str_tlast_to_xgmac     ),
.axi_str_tuser_to_xgmac   (axi_str_tuser_to_xgmac     ),
.axi_str_tready_from_xgmac(axi_str_tready_from_xgmac     ),
.axi_str_tready_to_fifo       (tx_axis_slice2interface_tready),
.axi_str_tdata_from_fifo      (tx_axis_slice2interface_tdata),
.axi_str_tkeep_from_fifo      (tx_axis_slice2interface_tkeep),
.axi_str_tvalid_from_fifo     (tx_axis_slice2interface_tvalid),
.axi_str_tlast_from_fifo      (tx_axis_slice2interface_tlast),
.user_clk                   (clk156),
.reset                      (reset)
);
axis_register_slice_64 axis_register_input_slice(
.aclk(clk156),
.aresetn(aresetn),
.s_axis_tvalid(tx_axis_tvalid),
.s_axis_tready(tx_axis_tready),
.s_axis_tdata(tx_axis_tdata),
.s_axis_tkeep(tx_axis_tkeep),
.s_axis_tlast(tx_axis_tlast),
.m_axis_tvalid(tx_axis_slice2interface_tvalid),
.m_axis_tready(tx_axis_slice2interface_tready),
.m_axis_tdata(tx_axis_slice2interface_tdata),
.m_axis_tkeep(tx_axis_slice2interface_tkeep),
.m_axis_tlast(tx_axis_slice2interface_tlast)
);
axis_register_slice_64 axis_register_output_slice(
.aclk(clk156),
.aresetn(aresetn),
.s_axis_tvalid(rx_axis_interface2slice_tvalid),
.s_axis_tready(rx_axis_interface2slice_tready),
.s_axis_tdata(rx_axis_interface2slice_tdata),
.s_axis_tkeep(rx_axis_interface2slice_tkeep),
.s_axis_tlast(rx_axis_interface2slice_tlast),
.m_axis_tvalid(rx_axis_tvalid),
.m_axis_tready(rx_axis_tready),
.m_axis_tdata(rx_axis_tdata),
.m_axis_tkeep(rx_axis_tkeep),
.m_axis_tlast(rx_axis_tlast)
);
endmodule
