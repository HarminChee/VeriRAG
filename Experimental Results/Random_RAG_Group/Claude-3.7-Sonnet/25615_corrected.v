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
	input                                  test_mode,
	input 	[31:0]  						WR1_DATA,         
	input										WR1,					
	input		[ADDR_WIDTH-1:0]			WR1_ADDR,			
	input		[ADDR_WIDTH-1:0]			WR1_MAX_ADDR,		
	input		[31:0]						WR1_LENGTH,			
	input										WR1_LOAD,			
	input										WR1_CLK,				
	output									WR1_FULL,			
	output	[31:0]						WR1_USE,				
	output									WR1_EMPTY,
	input   	[31:0]      				WR2_DATA,         
	input										WR2,					
	input		[ADDR_WIDTH-1:0]			WR2_ADDR,			
	input		[ADDR_WIDTH-1:0]			WR2_MAX_ADDR,		
	input		[31:0]						WR2_LENGTH,			
	input										WR2_LOAD,			
	input										WR2_CLK,				
	output									WR2_FULL,			
	output	[31:0]						WR2_USE,				
	output									WR2_EMPTY,
	output  	[C_DBUS_WIDTH-1:0]      RD1_DATA,         
	input										RD1,					
	input		[ADDR_WIDTH-1:0]			RD1_ADDR,			
	input		[ADDR_WIDTH-1:0]			RD1_MAX_ADDR,		
	input		[31:0]						RD1_LENGTH,			
	input										RD1_LOAD,			
	input										RD1_CLK,				
	output									RD1_EMPTY,			
	output	[31:0]						RD1_USE,				
	input										RD1_DMA,
	output									RD1_FULL,
	output  	[C_DBUS_WIDTH-1:0]      RD2_DATA,          
	input										RD2,					
	input		[ADDR_WIDTH-1:0]			RD2_ADDR,			
	input		[ADDR_WIDTH-1:0]			RD2_MAX_ADDR,		
	input		[31:0]						RD2_LENGTH,			
	input										RD2_LOAD,			
	input										RD2_CLK,				
	output									RD2_EMPTY,			
	output	[31:0]						RD2_USE,				
	input										RD2_DMA,	
	output									RD2_FULL,
	output									WR1_RDEN,WR2_RDEN,RD1_WREN,RD2_WREN,
	output	reg	[1:0]					WR_MASK,				
	output	reg	[1:0]					RD_MASK,				
	output	reg							mWR_DONE,			
	output	reg							mRD_DONE,			
	output	reg							mWR,					
	output	reg							mRD,					
	input		[C_DBUS_WIDTH-1:0]		DMA_us_Length,
	input		[31:0]						CH0_DMA_SIZE,CH1_DMA_SIZE,
	output	reg	[ADDR_WIDTH-1:0]			mADDR,					
   inout [DQ_WIDTH-1:0]                   ddr3_dq,
   inout [DQS_WIDTH-1:0]                  ddr3_dqs_n,
   inout [DQS_WIDTH-1:0]                  ddr3_dqs_p,
   output [ROW_WIDTH-1:0]                 ddr3_addr,
   output [BANK_WIDTH-1:0]                ddr3_ba,
   output                                 ddr3_ras_n,
   output                                 ddr3_cas_n,
   output                                 ddr3_we_n,
   output                                 ddr3_reset_n,
   output [CK_WIDTH-1:0]                  ddr3_ck_p,
   output [CK_WIDTH-1:0]                  ddr3_ck_n,
   output [CKE_WIDTH-1:0]                 ddr3_cke,
   output [CS_WIDTH*nCS_PER_RANK-1:0]     ddr3_cs_n,
   output [DM_WIDTH-1:0]                  ddr3_dm,
   output [ODT_WIDTH-1:0]                 ddr3_odt,
	input                                  sys_clk_i,
	input             							sys_clk_p,
	input             							sys_clk_n,
   input                                  sys_rst_n,
	input												eb_rst,
	input												pcie_clk,
	output	[31:0]								ch0_ddr3_use,ch1_ddr3_use,		
	output	reg									ch0_ddr3_full,ch1_ddr3_full,	
	output	reg									ch0_valid,ch1_valid,				
	output											init_calib_complete,
	output											ui_clk,								
	output											ui_clk_sync_rst,
	output											sys_clk_o								
	);

// ... existing code ...

wire clk_mux;
assign clk_mux = test_mode ? sys_clk_i : ui_clk;

// ... existing code ...

always @ (posedge clk_mux or posedge rst)
begin
	if(rst) begin
		// ... existing code ...
	end
	else begin
		// ... existing code ...
	end
end

// ... existing code ...

endmodule