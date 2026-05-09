module altera_tse_mac_pcs_pma  (
    address,
    clk,
    ff_rx_clk,
    ff_rx_rdy,
    ff_tx_clk,
    ff_tx_crc_fwd,
    ff_tx_data,
    ff_tx_mod,
    ff_tx_eop,
    ff_tx_err,
    ff_tx_sop,
    ff_tx_wren,
    gxb_cal_blk_clk,
    gxb_pwrdn_in,
    magic_sleep_n,
    mdio_in,
    read,
    ref_clk,
    reset,
    rxp,
    write,
    writedata,
    xoff_gen,
    xon_gen,
    ff_rx_a_empty,
    ff_rx_a_full,
    ff_rx_data,
    ff_rx_mod,
    ff_rx_dsav,
    ff_rx_dval,
    ff_rx_eop,
    ff_rx_sop,
    ff_tx_a_empty,
    ff_tx_a_full,
    ff_tx_rdy,
    ff_tx_septy,
    led_an,
    led_char_err,
    led_col,
    led_crs,
    led_disp_err,
    led_link,
    magic_wakeup,
    mdc,
    mdio_oen,
    mdio_out,
    pcs_pwrdn_out,
    readdata,
    rx_err,
    rx_err_stat,
    rx_frm_type,
    tx_ff_uflow,
    txp,
    rx_recovclkout,
    waitrequest
);
parameter ENABLE_ENA            = 8;            
parameter ENABLE_GMII_LOOPBACK  = 1;            
parameter ENABLE_HD_LOGIC       = 1;            
parameter USE_SYNC_RESET        = 1;            
parameter ENABLE_SUP_ADDR       = 1;            
parameter ENA_HASH              = 1;            
parameter STAT_CNT_ENA          = 1;            
parameter ENABLE_EXTENDED_STAT_REG = 0;         
parameter EG_FIFO               = 256 ;         
parameter EG_ADDR               = 8 ;           
parameter ING_FIFO              = 256 ;         
parameter ING_ADDR              = 8 ;           
parameter RESET_LEVEL           = 1'b 1 ;       
parameter MDIO_CLK_DIV          = 40 ;          
parameter CORE_VERSION          = 16'h3;        
parameter CUST_VERSION          = 1 ;           
parameter REDUCED_INTERFACE_ENA = 1;            
parameter ENABLE_MDIO           = 1;            
parameter ENABLE_MAGIC_DETECT   = 1;            
parameter ENABLE_MACLITE        = 0;            
parameter MACLITE_GIGE          = 0;            
parameter CRC32DWIDTH           = 4'b 1000;     
parameter CRC32GENDELAY         = 3'b 110;      
parameter CRC32CHECK16BIT       = 1'b 0;        
parameter CRC32S1L2_EXTERN      = 1'b0;         
parameter ENABLE_SHIFT16        = 0;            
parameter RAM_TYPE              = "AUTO";       
parameter INSERT_TA             = 0;            
parameter PHY_IDENTIFIER        = 32'h 00000000;
parameter DEV_VERSION           = 16'h 0001 ;   
parameter ENABLE_SGMII          = 1;            
parameter ENABLE_MAC_FLOW_CTRL  = 1'b1;         
parameter ENABLE_MAC_TXADDR_SET = 1'b1;         
parameter ENABLE_MAC_RX_VLAN    = 1'b1;         
parameter ENABLE_MAC_TX_VLAN    = 1'b1;         
parameter EXPORT_PWRDN          = 1'b0;         
parameter DEVICE_FAMILY         = "ARRIAGX";    
parameter TRANSCEIVER_OPTION    = 1'b1;         
parameter ENABLE_ALT_RECONFIG   = 0;            
parameter SYNCHRONIZER_DEPTH 	= 3;	  	
  output  ff_rx_a_empty;
  output  ff_rx_a_full;
  output  [ENABLE_ENA-1:0] ff_rx_data;
  output  [1:0] ff_rx_mod;
  output  ff_rx_dsav;
  output  ff_rx_dval;
  output  ff_rx_eop;
  output  ff_rx_sop;
  output  ff_tx_a_empty;
  output  ff_tx_a_full;
  output  ff_tx_rdy;
  output  ff_tx_septy;
  output  led_an;
  output  led_char_err;
  output  led_col;
  output  led_crs;
  output  led_disp_err;
  output  led_link;
  output  magic_wakeup;
  output  mdc;
  output  mdio_oen;
  output  mdio_out;
  output  pcs_pwrdn_out;
  output  [31: 0] readdata;
  output  [5: 0] rx_err;
  output  [17: 0] rx_err_stat;
  output  [3: 0] rx_frm_type;
  output  tx_ff_uflow;
  output  txp;
  output  rx_recovclkout;
  output  waitrequest;
  input   [7: 0] address;
  input   clk;
  input   ff_rx_clk;
  input   ff_rx_rdy;
  input   ff_tx_clk;
  input   ff_tx_crc_fwd;
  input   [ENABLE_ENA-1:0] ff_tx_data;
  input   [1:0] ff_tx_mod;
  input   ff_tx_eop;
  input   ff_tx_err;
  input   ff_tx_sop;
  input   ff_tx_wren;
  input   gxb_cal_blk_clk;
  input   gxb_pwrdn_in;
  input   magic_sleep_n;
  input   mdio_in;
  input   read;
  input   ref_clk;
  input   reset;
  input   rxp;
  input   write;
  input   [31:0] writedata;
  input   xoff_gen;
  input   xon_gen;
  wire    MAC_PCS_reset;
  wire    ff_rx_a_empty;
  wire    ff_rx_a_full;
  wire    [ENABLE_ENA-1:0] ff_rx_data;
  wire    [1:0] ff_rx_mod;
  wire    ff_rx_dsav;
  wire    ff_rx_dval;
  wire    ff_rx_eop;
  wire    ff_rx_sop;
  wire    ff_tx_a_empty;
  wire    ff_tx_a_full;
  wire    ff_tx_rdy;
  wire    ff_tx_septy;
  wire    led_an;
  wire    led_char_err;
  wire    led_col;
  wire    led_crs;
  wire    led_disp_err;
  wire    led_link;
  wire    magic_wakeup;
  wire    mdc;
  wire    mdio_oen;
  wire    mdio_out;
  wire    pcs_pwrdn_out_sig;
  wire    gxb_pwrdn_in_sig;
  wire    gxb_cal_blk_clk_sig;
  wire    [31:0] readdata;
  wire    [5:0] rx_err;
  wire    [17: 0] rx_err_stat;
  wire    [3:0] rx_frm_type;
  wire    sd_loopback;
  wire    tbi_rx_clk;
  wire    [9:0] tbi_rx_d;
  wire    tbi_tx_clk;
  wire    [9:0] tbi_tx_d;
  wire    tx_ff_uflow;
  wire    txp;
  wire    waitrequest;
  wire    [9:0] tbi_rx_d_lvds;
  reg     [9:0] tbi_rx_d_flip;
  reg     [9:0] tbi_tx_d_flip;
  wire    reset_ref_clk_int;
  wire    reset_tbi_rx_clk_int;
  wire    pll_areset,rx_cda_reset,rx_channel_data_align,rx_locked;
  wire    rx_reset;
  assign rx_recovclkout = tbi_rx_clk;
  assign MAC_PCS_reset = rx_reset;
  altera_tse_mac_pcs_pma_ena altera_tse_mac_pcs_pma_ena_inst
    (
       .address (address),
       .clk (clk),
       .ff_rx_a_empty (ff_rx_a_empty),
       .ff_rx_a_full (ff_rx_a_full),
       .ff_rx_clk (ff_rx_clk),
       .ff_rx_data (ff_rx_data),
       .ff_rx_mod (ff_rx_mod),
       .ff_rx_dsav (ff_rx_dsav),
       .ff_rx_dval (ff_rx_dval),
       .ff_rx_eop (ff_rx_eop),
       .ff_rx_rdy (ff_rx_rdy),
       .ff_rx_sop (ff_rx_sop),
       .ff_tx_a_empty (ff_tx_a_empty),
       .ff_tx_a_full (ff_tx_a_full),
       .ff_tx_clk (ff_tx_clk),
       .ff_tx_crc_fwd (ff_tx_crc_fwd),
       .ff_tx_data (ff_tx_data),
       .ff_tx_mod (ff_tx_mod),
       .ff_tx_eop (ff_tx_eop),
       .ff_tx_err (ff_tx_err),
       .ff_tx_rdy (ff_tx_rdy),
       .ff_tx_septy (ff_tx_septy),
       .ff_tx_sop (ff_tx_sop),
       .ff_tx_wren (ff_tx_wren),
       .led_an (led_an),
       .led_char_err (led_char_err),
       .led_col (led_col),
       .led_crs (led_crs),
       .led_disp_err (led_disp_err),
       .led_link (led_link),
       .magic_sleep_n (magic_sleep_n),
       .magic_wakeup (magic_wakeup),
       .mdc (mdc),
       .mdio_in (mdio_in),
       .mdio_oen (mdio_oen),
       .mdio_out (mdio_out),
       .powerdown (pcs_pwrdn_out_sig),
       .read (read),
       .readdata (readdata),
       .reset (MAC_PCS_reset),
       .rx_err (rx_err),
       .rx_err_stat (rx_err_stat),
       .rx_frm_type (rx_frm_type),
       .sd_loopback (sd_loopback),
       .tbi_rx_clk (tbi_rx_clk),
       .tbi_rx_d (tbi_rx_d),
       .tbi_tx_clk (tbi_tx_clk),
       .tbi_tx_d (tbi_tx_d),
       .tx_ff_uflow (tx_ff_uflow),
       .waitrequest (waitrequest),
       .write (write),
       .writedata (writedata),
       .xoff_gen (xoff_gen),
       .xon_gen (xon_gen)
    );
    defparam
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_ENA = ENABLE_ENA,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_HD_LOGIC = ENABLE_HD_LOGIC,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_GMII_LOOPBACK = ENABLE_GMII_LOOPBACK,
        altera_tse_mac_pcs_pma_ena_inst.USE_SYNC_RESET = USE_SYNC_RESET,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_SUP_ADDR = ENABLE_SUP_ADDR,
        altera_tse_mac_pcs_pma_ena_inst.ENA_HASH = ENA_HASH,        
        altera_tse_mac_pcs_pma_ena_inst.STAT_CNT_ENA = STAT_CNT_ENA,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_EXTENDED_STAT_REG = ENABLE_EXTENDED_STAT_REG,
        altera_tse_mac_pcs_pma_ena_inst.EG_FIFO = EG_FIFO,
        altera_tse_mac_pcs_pma_ena_inst.EG_ADDR = EG_ADDR,
        altera_tse_mac_pcs_pma_ena_inst.ING_FIFO = ING_FIFO,
        altera_tse_mac_pcs_pma_ena_inst.ING_ADDR = ING_ADDR,
        altera_tse_mac_pcs_pma_ena_inst.RESET_LEVEL = RESET_LEVEL,
        altera_tse_mac_pcs_pma_ena_inst.MDIO_CLK_DIV = MDIO_CLK_DIV,
        altera_tse_mac_pcs_pma_ena_inst.CORE_VERSION = CORE_VERSION,
        altera_tse_mac_pcs_pma_ena_inst.CUST_VERSION = CUST_VERSION,
        altera_tse_mac_pcs_pma_ena_inst.REDUCED_INTERFACE_ENA = REDUCED_INTERFACE_ENA,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_MDIO = ENABLE_MDIO,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_MAGIC_DETECT = ENABLE_MAGIC_DETECT,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_MACLITE = ENABLE_MACLITE,
        altera_tse_mac_pcs_pma_ena_inst.MACLITE_GIGE = MACLITE_GIGE,
        altera_tse_mac_pcs_pma_ena_inst.CRC32S1L2_EXTERN = CRC32S1L2_EXTERN,
        altera_tse_mac_pcs_pma_ena_inst.CRC32DWIDTH = CRC32DWIDTH,     
        altera_tse_mac_pcs_pma_ena_inst.CRC32CHECK16BIT = CRC32CHECK16BIT,               
        altera_tse_mac_pcs_pma_ena_inst.CRC32GENDELAY = CRC32GENDELAY,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_SHIFT16 = ENABLE_SHIFT16,
        altera_tse_mac_pcs_pma_ena_inst.INSERT_TA = INSERT_TA,
        altera_tse_mac_pcs_pma_ena_inst.RAM_TYPE = RAM_TYPE,        
        altera_tse_mac_pcs_pma_ena_inst.PHY_IDENTIFIER = PHY_IDENTIFIER,
        altera_tse_mac_pcs_pma_ena_inst.DEV_VERSION = DEV_VERSION,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_SGMII = ENABLE_SGMII,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_MAC_FLOW_CTRL = ENABLE_MAC_FLOW_CTRL, 
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_MAC_TXADDR_SET = ENABLE_MAC_TXADDR_SET,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_MAC_RX_VLAN = ENABLE_MAC_RX_VLAN,
		altera_tse_mac_pcs_pma_ena_inst.SYNCHRONIZER_DEPTH = SYNCHRONIZER_DEPTH,
        altera_tse_mac_pcs_pma_ena_inst.ENABLE_MAC_TX_VLAN = ENABLE_MAC_TX_VLAN;
generate if (EXPORT_PWRDN == 1)
    begin          
        assign gxb_pwrdn_in_sig = gxb_pwrdn_in;
        assign pcs_pwrdn_out = pcs_pwrdn_out_sig;
    end
else
    begin
        assign gxb_pwrdn_in_sig = pcs_pwrdn_out_sig;
    end      
endgenerate
generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1)
    begin          
    assign tbi_tx_clk = ref_clk;
    assign tbi_rx_d = tbi_rx_d_flip;
    altera_tse_reset_synchronizer reset_sync_0 (
        .clk(ref_clk),
        .reset_in(reset),
        .reset_out(reset_ref_clk_int)
        );
    altera_tse_reset_synchronizer reset_sync_1 (
        .clk(tbi_rx_clk),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_int)
        );    
    always @(posedge tbi_rx_clk or posedge reset_tbi_rx_clk_int)
        begin
        if (reset_tbi_rx_clk_int == 1)
            tbi_rx_d_flip <= 0;
        else 
            begin
            tbi_rx_d_flip[0] <= tbi_rx_d_lvds[9];
            tbi_rx_d_flip[1] <= tbi_rx_d_lvds[8];
            tbi_rx_d_flip[2] <= tbi_rx_d_lvds[7];
            tbi_rx_d_flip[3] <= tbi_rx_d_lvds[6];
            tbi_rx_d_flip[4] <= tbi_rx_d_lvds[5];
            tbi_rx_d_flip[5] <= tbi_rx_d_lvds[4];
            tbi_rx_d_flip[6] <= tbi_rx_d_lvds[3];
            tbi_rx_d_flip[7] <= tbi_rx_d_lvds[2];
            tbi_rx_d_flip[8] <= tbi_rx_d_lvds[1];
            tbi_rx_d_flip[9] <= tbi_rx_d_lvds[0];
            end
        end
    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip <= 0;
        else 
            begin
            tbi_tx_d_flip[0] <= tbi_tx_d[9];
            tbi_tx_d_flip[1] <= tbi_tx_d[8];
            tbi_tx_d_flip[2] <= tbi_tx_d[7];
            tbi_tx_d_flip[3] <= tbi_tx_d[6];
            tbi_tx_d_flip[4] <= tbi_tx_d[5];
            tbi_tx_d_flip[5] <= tbi_tx_d[4];
            tbi_tx_d_flip[6] <= tbi_tx_d[3];
            tbi_tx_d_flip[7] <= tbi_tx_d[2];
            tbi_tx_d_flip[8] <= tbi_tx_d[1];
            tbi_tx_d_flip[9] <= tbi_tx_d[0];
            end
        end
     altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset ),
         .rx_channel_data_align ( rx_channel_data_align ),
         .rx_locked ( rx_locked ),
         .rx_divfwdclk (tbi_rx_clk),
         .rx_in (rxp),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds),
         .rx_outclock (),
         .rx_reset (rx_reset)
     );
    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer (
		.clk ( clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked ),
		.rx_channel_data_align ( rx_channel_data_align ),
		.pll_areset ( pll_areset ),
		.rx_reset (rx_reset),
		.rx_cda_reset ( rx_cda_reset )
	);    
    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx
    (
        .tx_in (tbi_tx_d_flip),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp)
    );
    end    
endgenerate
endmodule
