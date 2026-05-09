module 1_corrected_cdf (
    osc, rstn,
    test_mode, scan_in, // Added DFT ports
    led, gpio, scan_out, // Added DFT ports
    perstn, refclkp, refclkn, hdinp0, hdinn0, hdoutp0, hdoutn0
);

// Port Declarations
input osc;
input rstn;
input test_mode; // DFT control
input scan_in;   // DFT scan data input

output [7:0] led;
output [23:0] gpio;
output scan_out; // DFT scan data output

input perstn;
input refclkp;
input refclkn;
input hdinp0;
input hdinn0;
output hdoutp0;
output hdoutn0;

// Internal Signals
reg [23:0] count;
reg [7:0] sreg;
reg shift;
wire rst;
wire clk;

// Intermediate functional next-state signals
reg [23:0] count_next;
reg shift_next;
reg [7:0] sreg_next;


// Assignments
assign rst = ~rstn;
assign clk = osc;
assign led = sreg;
assign gpio = count;

// Combinational logic for next states
// This block calculates the next state based on current state and inputs
always @* begin
    // Default assignments (hold current value if no condition met)
    count_next = count;
    shift_next = shift;
    sreg_next = sreg;

    // Count logic
    count_next = count + 1;

    // Shift logic
    // Use current count value to determine next shift value
    if (count == 24'd3) begin // Specify width for comparison
        shift_next = 1'b1;
    end else begin
        shift_next = 1'b0;
    end

    // Sreg logic
    // Use current shift value to determine next sreg value
    if (shift == 1'b1) begin
        sreg_next = sreg << 1;
        sreg_next[0] = sreg[7];
    end
    // Note: If shift is not 1, sreg_next retains its default assignment (current sreg)
end

// Sequential logic (Flip-Flops with Scan Mux)
// This block describes the flip-flop behavior including reset and scan logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 24'b0;
        shift <= 1'b0;
        sreg  <= 8'b1111_1110;
    end else begin
        if (test_mode) begin // Test Mode: Shift data through scan chain
            // Scan chain order: scan_in -> count -> shift -> sreg -> scan_out
            count <= {count[22:0], scan_in}; // Scan into LSB of count
            shift <= count[23];              // Shift data from MSB of count into shift FF
            sreg  <= {sreg[6:0], shift};     // Shift data from shift FF into LSB of sreg
        end else begin // Functional Mode: Load calculated next state values
            count <= count_next;
            shift <= shift_next;
            sreg  <= sreg_next;
        end
    end
end

// Assign scan out from the last FF in the chain (MSB of sreg)
assign scan_out = sreg[7];

// Instantiate claritycores (unchanged as it's likely a pre-verified IP)
claritycores _inst (
	.refclk_refclkp(refclkp),
	.refclk_refclkn(refclkn),
	.pcie_x1_hdinp0(hdinp0),
	.pcie_x1_hdinn0(hdinn0),
	.pcie_x1_hdoutp0(hdoutp0),
	.pcie_x1_hdoutn0(hdoutn0),
	.pcie_x1_rst_n(perstn),
	.pcie_x1_sys_clk_125(),
	.pcie_x1_tx_data_vc0(16'd0),
	.pcie_x1_tx_req_vc0(1'b0),
	.pcie_x1_tx_rdy_vc0(),
	.pcie_x1_tx_st_vc0(1'b0),
	.pcie_x1_tx_end_vc0(1'b0),
	.pcie_x1_tx_nlfy_vc0(1'b0),
	.pcie_x1_tx_ca_ph_vc0(),
	.pcie_x1_tx_ca_nph_vc0(),
	.pcie_x1_tx_ca_cplh_vc0(),
	.pcie_x1_tx_ca_pd_vc0(),
	.pcie_x1_tx_ca_npd_vc0(),
	.pcie_x1_tx_ca_cpld_vc0(),
	.pcie_x1_tx_ca_p_recheck_vc0(),
	.pcie_x1_tx_ca_cpl_recheck_vc0(),
	.pcie_x1_rx_data_vc0(),
	.pcie_x1_rx_st_vc0(),
	.pcie_x1_rx_end_vc0(),
	.pcie_x1_rx_us_req_vc0(),
	.pcie_x1_rx_malf_tlp_vc0(),
	.pcie_x1_rx_bar_hit( ),
	.pcie_x1_ur_np_ext(1'b0),
	.pcie_x1_ur_p_ext(1'b0),
	.pcie_x1_ph_buf_status_vc0(1'b0),
	.pcie_x1_pd_buf_status_vc0(1'b0),
	.pcie_x1_nph_buf_status_vc0(1'b0),
	.pcie_x1_npd_buf_status_vc0(1'b0),
	.pcie_x1_ph_processed_vc0(1'b0),
	.pcie_x1_nph_processed_vc0(1'b0),
	.pcie_x1_pd_processed_vc0(1'b0),
	.pcie_x1_npd_processed_vc0(1'b0),
	.pcie_x1_pd_num_vc0(1'b0),
	.pcie_x1_npd_num_vc0(1'b0),
	.pcie_x1_no_pcie_train(1'b0),
	.pcie_x1_force_lsm_active(1'b0),
	.pcie_x1_force_rec_ei(1'b0),
	.pcie_x1_force_phy_status(1'b0),
	.pcie_x1_force_disable_scr(1'b0),
	.pcie_x1_hl_snd_beacon(1'b0),
	.pcie_x1_hl_disable_scr(1'b0),
	.pcie_x1_hl_gto_dis(1'b0),
	.pcie_x1_hl_gto_det(1'b0),
	.pcie_x1_hl_gto_hrst(1'b0),
	.pcie_x1_hl_gto_l0stx(1'b0),
	.pcie_x1_hl_gto_l0stxfts(1'b0),
	.pcie_x1_hl_gto_l1(1'b0),
	.pcie_x1_hl_gto_l2(1'b0),
	.pcie_x1_hl_gto_lbk(4'd0),
	.pcie_x1_hl_gto_rcvry(1'b0),
	.pcie_x1_hl_gto_cfg(1'b0),
	.pcie_x1_phy_ltssm_state(),
	.pcie_x1_phy_pol_compliance(),
	.pcie_x1_tx_lbk_rdy(),
	.pcie_x1_tx_lbk_kcntl(2'd0),
	.pcie_x1_tx_lbk_data(16'd0),
	.pcie_x1_rx_lbk_kcntl(),
	.pcie_x1_rx_lbk_data(),
	.pcie_x1_flip_lanes(1'b0),
	.pcie_x1_dl_inactive( ),
	.pcie_x1_dl_init( ),
	.pcie_x1_dl_active( ),
	.pcie_x1_dl_up(),
	.pcie_x1_tx_dllp_val(2'd0),
	.pcie_x1_tx_pmtype(3'd0),
	.pcie_x1_tx_vsd_data(24'd0),
	.pcie_x1_tx_dllp_sent(),
	.pcie_x1_rxdp_pmd_type(),
	.pcie_x1_rxdp_vsd_data(),
	.pcie_x1_rxdp_dllp_val(),
	.pcie_x1_cmpln_tout(),
	.pcie_x1_cmpltr_abort_np(),
	.pcie_x1_cmpltr_abort_p(1'd0),
	.pcie_x1_unexp_cmpln(1'd0),
	.pcie_x1_np_req_pend(1'd0),
	.pcie_x1_bus_num( ),
	.pcie_x1_dev_num( ),
	.pcie_x1_func_num( ),
	.pcie_x1_cmd_reg_out( ),
	.pcie_x1_dev_cntl_out( ),
	.pcie_x1_lnk_cntl_out( ),
	.pcie_x1_inta_n(1'b1),
	.pcie_x1_msi(8'd0),
	.pcie_x1_mm_enable( ),
	.pcie_x1_msi_enable( ),
	.pcie_x1_pme_status(1'b0),
	.pcie_x1_pme_en(),
	.pcie_x1_pm_power_state( ));

endmodule