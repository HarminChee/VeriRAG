`timescale 1ns / 1ps
module mem_inf #(
    parameter C0_SIMULATION          =  "FALSE",
    parameter C1_SIMULATION           = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL  = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF",
    // AXI Parameters (Example - Adjust based on actual MIG configuration)
    parameter C0_AXI_ID_WIDTH        = 4,
    parameter C0_AXI_ADDR_WIDTH      = 32,
    parameter C0_AXI_DATA_WIDTH      = 64,
    parameter C1_AXI_ID_WIDTH        = 4,
    parameter C1_AXI_ADDR_WIDTH      = 32,
    parameter C1_AXI_DATA_WIDTH      = 64
)
(
    // Clocks and Resets
    input               clk156_25, // Reference clock for DFT muxing
    input               reset156_25_n, // Not used directly in reset sync, sys_rst is used
    input               c0_sys_clk_p,
    input               c0_sys_clk_n,
    input               clk_ref_p,      // MIG Reference Clock
    input               clk_ref_n,      // MIG Reference Clock
    input               c1_sys_clk_p,
    input               c1_sys_clk_n,
    input               sys_rst,        // Primary System Reset (Active High)
    input               test_mode,      // DFT Test Mode enable

    // DDR3 Interface Controller 0
    inout [71:0]        c0_ddr3_dq,
    inout [8:0]         c0_ddr3_dqs_n,
    inout [8:0]         c0_ddr3_dqs_p,
    output [15:0]       c0_ddr3_addr,
    output [2:0]        c0_ddr3_ba,
    output              c0_ddr3_ras_n,
    output              c0_ddr3_cas_n,
    output              c0_ddr3_we_n,
    output              c0_ddr3_reset_n,
    output [1:0]        c0_ddr3_ck_p,
    output [1:0]        c0_ddr3_ck_n,
    output [1:0]        c0_ddr3_cke,
    output [1:0]        c0_ddr3_cs_n,
    output [1:0]        c0_ddr3_odt,
    output              c0_ui_clk,
    output              c0_init_calib_complete,

    // DDR3 Interface Controller 1
    inout [71:0]        c1_ddr3_dq,
    inout [8:0]         c1_ddr3_dqs_n,
    inout [8:0]         c1_ddr3_dqs_p,
    output [15:0]       c1_ddr3_addr,
    output [2:0]        c1_ddr3_ba,
    output              c1_ddr3_ras_n,
    output              c1_ddr3_cas_n,
    output              c1_ddr3_we_n,
    output              c1_ddr3_reset_n,
    output [1:0]        c1_ddr3_ck_p,
    output [1:0]        c1_ddr3_ck_n,
    output [1:0]        c1_ddr3_cke,
    output [1:0]        c1_ddr3_cs_n,
    output [1:0]        c1_ddr3_odt,
    output              c1_ui_clk,
    output              c1_init_calib_complete,

    // Application Interfaces (Mapped to AXI below)
    // ToeTX Interface (Example mapping to c0_s_axi)
    input               toeTX_s_axis_read_cmd_tvalid,
    output              toeTX_s_axis_read_cmd_tready, // c0_s_axi_arready
    input[71:0]         toeTX_s_axis_read_cmd_tdata,  // Contains address/len etc. for c0_s_axi_ar*
    output              toeTX_m_axis_read_sts_tvalid, // c0_s_axi_rvalid
    input               toeTX_m_axis_read_sts_tready, // c0_s_axi_rready
    output[7:0]         toeTX_m_axis_read_sts_tdata,  // c0_s_axi_rresp + potentially rid
    output[63:0]        toeTX_m_axis_read_tdata,      // c0_s_axi_rdata (lower 64 bits)
    output[7:0]         toeTX_m_axis_read_tkeep,      // Derived from c0_s_axi_rdata size/alignment
    output              toeTX_m_axis_read_tlast,      // c0_s_axi_rlast
    output              toeTX_m_axis_read_tvalid,     // c0_s_axi_rvalid
    input               toeTX_m_axis_read_tready,     // c0_s_axi_rready

    input               toeTX_s_axis_write_cmd_tvalid,
    output              toeTX_s_axis_write_cmd_tready,// c0_s_axi_awready
    input[71:0]         toeTX_s_axis_write_cmd_tdata, // Contains address/len etc. for c0_s_axi_aw*
    output              toeTX_m_axis_write_sts_tvalid,// c0_s_axi_bvalid
    input               toeTX_m_axis_write_sts_tready,// c0_s_axi_bready
    output[7:0]         toeTX_m_axis_write_sts_tdata, // c0_s_axi_bresp + potentially bid
    input[63:0]         toeTX_s_axis_write_tdata,     // c0_s_axi_wdata (lower 64 bits)
    input[7:0]          toeTX_s_axis_write_tkeep,     // c0_s_axi_wstrb (lower 8 bytes)
    input               toeTX_s_axis_write_tlast,     // c0_s_axi_wlast
    input               toeTX_s_axis_write_tvalid,    // c0_s_axi_wvalid
    output              toeTX_s_axis_write_tready,    // c0_s_axi_wready

    // ToeRX Interface (Example mapping to c1_s_axi)
    input               toeRX_s_axis_read_cmd_tvalid,
    output              toeRX_s_axis_read_cmd_tready, // c1_s_axi_arready
    input[71:0]         toeRX_s_axis_read_cmd_tdata,  // Contains address/len etc. for c1_s_axi_ar*
    output              toeRX_m_axis_read_sts_tvalid, // c1_s_axi_rvalid
    input               toeRX_m_axis_read_sts_tready, // c1_s_axi_rready
    output[7:0]         toeRX_m_axis_read_sts_tdata,  // c1_s_axi_rresp + potentially rid
    output[63:0]        toeRX_m_axis_read_tdata,      // c1_s_axi_rdata (lower 64 bits)
    output[7:0]         toeRX_m_axis_read_tkeep,      // Derived from c1_s_axi_rdata size/alignment
    output              toeRX_m_axis_read_tlast,      // c1_s_axi_rlast
    output              toeRX_m_axis_read_tvalid,     // c1_s_axi_rvalid
    input               toeRX_m_axis_read_tready,     // c1_s_axi_rready

    input               toeRX_s_axis_write_cmd_tvalid,
    output              toeRX_s_axis_write_cmd_tready,// c1_s_axi_awready
    input[71:0]         toeRX_s_axis_write_cmd_tdata, // Contains address/len etc. for c1_s_axi_aw*
    output              toeRX_m_axis_write_sts_tvalid,// c1_s_axi_bvalid
    input               toeRX_m_axis_write