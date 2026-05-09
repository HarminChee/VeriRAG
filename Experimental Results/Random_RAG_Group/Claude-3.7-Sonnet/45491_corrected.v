module AXI_DDR2_MIG(
      input         test_i,
      input         CLK,                
      input			    CLK_333MHZ,
      input			    CLK_200MHZ,
      input         RST,              
      input           axi_awvalid,
      output          axi_awready,
      input  [32-1:0] axi_awaddr,
      input  [3-1:0]  axi_awprot,
      input           axi_wvalid,
      output          axi_wready,
      input  [32-1:0] axi_wdata,
      input  [4-1:0]  axi_wstrb,
      output          axi_bvalid,
      input           axi_bready,
      input           axi_arvalid,
      output          axi_arready,
      input  [32-1:0] axi_araddr,
      input  [3-1:0]  axi_arprot,
      output          axi_rvalid,
      input           axi_rready,
      output [32-1:0] axi_rdata,
      output [12:0] ddr2_addr,
      output [2:0]  ddr2_ba,
      output        ddr2_ras_n,
      output        ddr2_cas_n,
      output        ddr2_we_n,
      output [0:0]  ddr2_ck_p,
      output [0:0]  ddr2_ck_n,
      output [0:0]  ddr2_cke,
      output [0:0]  ddr2_cs_n,
      output [1:0]  ddr2_dm,
      output [0:0]  ddr2_odt,
      inout  [15:0] ddr2_dq,
      inout  [1:0]  ddr2_dqs_p,
      inout  [1:0]  ddr2_dqs_n
    );

    wire rst_i;
    assign rst_i = test_i ? CLK : ~RST;
    
    // ... existing code ...
    
    wire mem_ui_clk;
    wire mem_ui_clk_sync;
    assign mem_ui_clk_sync = test_i ? CLK : mem_ui_clk;
    
    // ... existing code ...
    
    always @ (posedge mem_ui_clk_sync or negedge rst_def)
    begin
        if (rst_def == 1'b0) begin
            // ... existing reset logic ...
        end else begin
            // ... existing state machine logic ...
        end
    end
    
    // ... rest of existing code ...

endmodule