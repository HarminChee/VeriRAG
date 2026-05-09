`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pc_ctrl #(
  parameter DATA_W_IN_BYTES       = 4,
  parameter ADDR_W_IN_BITS        = (8 + 2),
  parameter DCADDR_LOW_BIT_W      = 8,
  parameter DCADDR_STROBE_MEM_SEG = 2 
) (
   input  wire [31:0]      pm0_accum_low_period,
   input  wire [15:0]      pm0_pulse_per_second,
   input  wire             pm0_ready_to_read   ,
   input  wire [31:0]      pm1_accum_low_period,
   input  wire [15:0]      pm1_pulse_per_second,
   input  wire             pm1_ready_to_read   ,
   output wire [31:0]      pm0_clk_freq        ,
   output wire [31:0]      pm0_clk_subsample   ,
   output wire             pm0_enable          ,
   output wire             pm0_use_one_pps_in  ,
   output wire [31:0]      pm1_clk_freq        ,
   output wire             pm1_clk_subsample   ,
   output wire             pm1_enable          ,
   output wire             pm1_use_one_pps_in  ,
   input  wire [(ADDR_W_IN_BITS)-1 : 0]              S_AXI_AWADDR,      
   input  wire [2 : 0]                               S_AXI_AWPROT,      
   input  wire                                       S_AXI_AWVALID,     
   output wire                                       S_AXI_AWREADY,     
   input  wire [(DATA_W_IN_BYTES*8) - 1:0]           S_AXI_WDATA,       
   input  wire [DATA_W_IN_BYTES-1 : 0]               S_AXI_WSTRB,       
   input  wire                                       S_AXI_WVALID,      
   output wire                                       S_AXI_WREADY,      
   output wire [1 : 0]                               S_AXI_BRESP,       
   output wire                                       S_AXI_BVALID,      
   input  wire                                       S_AXI_BREADY,      
   input  wire [(ADDR_W_IN_BITS)-1 : 0]              S_AXI_ARADDR,      
   input  wire [2 : 0]                               S_AXI_ARPROT,      
   input  wire                                       S_AXI_ARVALID,     
   output wire                                       S_AXI_ARREADY,     
   output wire [(DATA_W_IN_BYTES*8) - 1:0]           S_AXI_RDATA,       
   output wire [1 : 0]                               S_AXI_RRESP,       
   output wire                                       S_AXI_RVALID,      
   input  wire                                       S_AXI_RREADY,      
   input  wire                                       ACLK,              
   input  wire                                       ARESETn            
);
wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_rd_start; 
wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_rd_done;  
wire [DCADDR_LOW_BIT_W - 1:0]              bank_rd_addr;  
reg  [(DATA_W_IN_BYTES*8) - 1:0]           bank_rd_data;  
wire [(ADDR_W_IN_BITS)-1:DCADDR_LOW_BIT_W] decode_rd_addr;
wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_wr_start; 
wire [DCADDR_STROBE_MEM_SEG - 1:0]         bank_wr_done;  
wire [DCADDR_LOW_BIT_W - 1:0]              bank_wr_addr;  
wire [(DATA_W_IN_BYTES*8) - 1:0]           bank_wr_data;  
wire [(DATA_W_IN_BYTES*8) - 1:0]           bank_rd_data_bus[DCADDR_STROBE_MEM_SEG-1:0]; 
pc_ctrl_axi4_reg_if #(
  .DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
  .ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
  .DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      ),
  .DCADDR_STROBE_MEM_SEG (DCADDR_STROBE_MEM_SEG )
) pc_ctrl_axi4_reg_if_0_i (
   .S_AXI_AWADDR      (S_AXI_AWADDR  ), 
   .S_AXI_AWPROT      (S_AXI_AWPROT  ), 
   .S_AXI_AWVALID     (S_AXI_AWVALID ), 
   .S_AXI_AWREADY     (S_AXI_AWREADY ), 
   .S_AXI_WDATA       (S_AXI_WDATA   ), 
   .S_AXI_WSTRB       (S_AXI_WSTRB   ), 
   .S_AXI_WVALID      (S_AXI_WVALID  ), 
   .S_AXI_WREADY      (S_AXI_WREADY  ), 
   .S_AXI_BRESP       (S_AXI_BRESP   ), 
   .S_AXI_BVALID      (S_AXI_BVALID  ), 
   .S_AXI_BREADY      (S_AXI_BREADY  ), 
   .S_AXI_ARADDR      (S_AXI_ARADDR  ), 
   .S_AXI_ARPROT      (S_AXI_ARPROT  ), 
   .S_AXI_ARVALID     (S_AXI_ARVALID ), 
   .S_AXI_ARREADY     (S_AXI_ARREADY ), 
   .S_AXI_RDATA       (S_AXI_RDATA   ), 
   .S_AXI_RRESP       (S_AXI_RRESP   ), 
   .S_AXI_RVALID      (S_AXI_RVALID  ), 
   .S_AXI_RREADY      (S_AXI_RREADY  ), 
   .reg_bank_rd_start (bank_rd_start ), 
   .reg_bank_rd_done  (bank_rd_done  ), 
   .reg_bank_rd_addr  (bank_rd_addr  ), 
   .reg_bank_rd_data  (bank_rd_data  ), 
   .decode_rd_addr    (decode_rd_addr), 
   .reg_bank_wr_start (bank_wr_start ), 
   .reg_bank_wr_done  (bank_wr_done  ), 
   .reg_bank_wr_addr  (bank_wr_addr  ), 
   .reg_bank_wr_data  (bank_wr_data  ), 
   .ACLK              (ACLK          ), 
   .ARESETn           (ARESETn       )  
);
always @(*) begin
   case(decode_rd_addr)
   0:bank_rd_data = bank_rd_data_bus[0]; 
   1:bank_rd_data = bank_rd_data_bus[1]; 
   default:bank_rd_data = bank_rd_data_bus[0];
   endcase
end
pc_ctrl_pm0 #(
  .DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
  .ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
  .DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      )
) pc_ctrl_pm0_0_i (
   .accum_low_period(pm0_accum_low_period),
   .pulse_per_second(pm0_pulse_per_second),
   .ready_to_read   (pm0_ready_to_read   ),
   .clk_freq        (pm0_clk_freq        ),
   .clk_subsample   (pm0_clk_subsample   ),
   .enable          (pm0_enable          ),
   .use_one_pps_in  (pm0_use_one_pps_in  ),
   .reg_bank_rd_start (bank_rd_start[0]    ), 
   .reg_bank_rd_done  (bank_rd_done[0]     ), 
   .reg_bank_rd_addr  (bank_rd_addr        ), 
   .reg_bank_rd_data  (bank_rd_data_bus[0] ), 
   .reg_bank_wr_start (bank_wr_start[0]    ), 
   .reg_bank_wr_done  (bank_wr_done[0]     ), 
   .reg_bank_wr_addr  (bank_wr_addr        ), 
   .reg_bank_wr_data  (bank_wr_data        ), 
   .ACLK              (ACLK                ), 
   .ARESETn           (ARESETn             )  
);
pc_ctrl_pm1 #(
  .DATA_W_IN_BYTES       (DATA_W_IN_BYTES       ),
  .ADDR_W_IN_BITS        (ADDR_W_IN_BITS        ),
  .DCADDR_LOW_BIT_W      (DCADDR_LOW_BIT_W      )
) pc_ctrl_pm1_1_i (
   .accum_low_period(pm1_accum_low_period),
   .pulse_per_second(pm1_pulse_per_second),
   .ready_to_read   (pm1_ready_to_read   ),
   .clk_freq        (pm1_clk_freq        ),
   .clk_subsample   (pm1_clk_subsample   ),
   .enable          (pm1_enable          ),
   .use_one_pps_in  (pm1_use_one_pps_in  ),
   .reg_bank_rd_start (bank_rd_start[1]    ), 
   .reg_bank_rd_done  (bank_rd_done[1]     ), 
   .reg_bank_rd_addr  (bank_rd_addr        ), 
   .reg_bank_rd_data  (bank_rd_data_bus[1] ), 
   .reg_bank_wr_start (bank_wr_start[1]    ), 
   .reg_bank_wr_done  (bank_wr_done[1]     ), 
   .reg_bank_wr_addr  (bank_wr_addr        ), 
   .reg_bank_wr_data  (bank_wr_data        ), 
   .ACLK              (ACLK                ), 
   .ARESETn           (ARESETn             )  
);
endmodule
