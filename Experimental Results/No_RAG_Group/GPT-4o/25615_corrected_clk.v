module MIG_4Port	#(
	parameter C_DBUS_WIDTH           = 64,		
   parameter BANK_WIDTH            	= 3,	
   parameter CK_WIDTH              	= 2,	
   parameter CS_WIDTH              	= 2,	
   parameter nCS_PER_RANK          	= 1,	
   parameter CKE_WIDTH             	= 2,	
	parameter DM_WIDTH              	= 8, 	
   parameter DQ_WIDTH              	= 64,	
	parameter DQS_WIDTH             	= 8,
   parameter ODT_WIDTH             	= 2,	
   parameter ROW_WIDTH             	= 15,	
	parameter ADDR_WIDTH            	= 29,
	parameter PAYLOAD_WIDTH         	= 64,
	parameter nCK_PER_CLK				= 2,
	parameter RANKS                 	= 2
)
(
	input                                  sys_clk_i,
	input                                  sys_rst_n,
	output											ui_clk,								
	output											ui_clk_sync_rst,
	output											init_calib_complete
);

	localparam		BURST_BYTE 				= 8*1024;
	localparam		BURST_UIDATA_LEN		= BURST_BYTE>>5;
	localparam	 	BURST_ADDR_LEN			= BURST_UIDATA_LEN >> 1;

	wire	rst = (ui_clk_sync_rst | ~init_calib_complete);
	wire	app_rdy;
	reg	app_en;
	reg	[2:0]	app_cmd;
	wire	[ADDR_WIDTH-1:0]	app_addr;
	wire	app_wdf_rdy;
	reg	app_wdf_wren;
	reg	app_wdf_end;
	wire	[(4*PAYLOAD_WIDTH)-1:0]	app_wdf_data;
	wire	[(4*PAYLOAD_WIDTH)/8-1:0]	app_wdf_mask = 32'd0;
	wire	app_rd_data_valid;
	wire	[(4*PAYLOAD_WIDTH)-1:0]	app_rd_data;
	reg	[31:0]	mDATA_LENGTH;			
	reg	[31:0]	mADDR_LENGTH;			
	reg	[ADDR_WIDTH-1:0]	mADDR;					

  ddr3_ip #(
   .BANK_WIDTH            	(BANK_WIDTH),	
   .CK_WIDTH              	(CK_WIDTH),	
   .CS_WIDTH              	(CS_WIDTH),	
   .nCS_PER_RANK          	(nCS_PER_RANK),	
   .CKE_WIDTH             	(CKE_WIDTH),	
	.DM_WIDTH              	(DM_WIDTH), 	
   .DQ_WIDTH              	(DQ_WIDTH),	
	.DQS_WIDTH             	(DQS_WIDTH),
   .ODT_WIDTH             	(ODT_WIDTH),	
   .ROW_WIDTH             	(ROW_WIDTH),	
	.ADDR_WIDTH            	(ADDR_WIDTH),
	.PAYLOAD_WIDTH         	(PAYLOAD_WIDTH),
	.nCK_PER_CLK				(nCK_PER_CLK),
	.RANKS						(RANKS)
)	u_ddr3_ip
      (
       .init_calib_complete            (init_calib_complete),
       .app_addr                       (app_addr),
       .app_cmd                        (app_cmd),
       .app_en                         (app_en),
       .app_wdf_data                   (app_wdf_data),
       .app_wdf_end                    (app_wdf_end),
       .app_wdf_wren                   (app_wdf_wren),
       .app_rd_data                    (app_rd_data),
       .app_rd_data_valid              (app_rd_data_valid),
       .app_rdy                        (app_rdy),
       .app_wdf_rdy                    (app_wdf_rdy),
       .ui_clk                         (ui_clk),
       .ui_clk_sync_rst                (ui_clk_sync_rst),
       .app_wdf_mask                   (app_wdf_mask),
       .sys_clk_i                      (sys_clk_i),
       .sys_rst                        (sys_rst_n)
       );

endmodule