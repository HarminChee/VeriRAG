`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module esaxi_v1_0_S00_AXI #
  (
   parameter [11:0]  C_READ_TAG_ADDR = 12'h810,
   parameter integer C_S_AXI_ID_WIDTH    = 1,
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
   parameter integer C_S_AXI_ADDR_WIDTH    = 30,
   parameter integer C_S_AXI_AWUSER_WIDTH    = 0,
   parameter integer C_S_AXI_ARUSER_WIDTH    = 0,
   parameter integer C_S_AXI_WUSER_WIDTH    = 0,
   parameter integer C_S_AXI_RUSER_WIDTH    = 0,
   parameter integer C_S_AXI_BUSER_WIDTH    = 0
   )
   (
    output reg  [102:0] emwr_wr_data,
    output reg          emwr_wr_en,
    input  wire         emwr_full,
    input  wire         emwr_prog_full,
    output reg  [102:0] emrq_wr_data,
    output reg          emrq_wr_en,
    input  wire         emrq_full,
    input  wire         emrq_prog_full,
    input wire [102:0]  emrr_rd_data,
    output wire         emrr_rd_en,
    input wire          emrr_empty,
    input wire [3:0]    ecfg_tx_ctrl_mode,
    input wire [11:0]   ecfg_coreid,
    input wire  S_AXI_ACLK,
    input wire  S_AXI_ARESETN,
    input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [7 : 0] S_AXI_AWLEN,
    input wire [2 : 0] S_AXI_AWSIZE,
    input wire [1 : 0] S_AXI_AWBURST,
    input wire  S_AXI_AWLOCK,
    input wire [3 : 0] S_AXI_AWCACHE,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire [3 : 0] S_AXI_AWQOS,
    input wire [3 : 0] S_AXI_AWREGION,
    input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
    input wire  S_AXI_AWVALID,
    output wire  S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire  S_AXI_WLAST,
    input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
    input wire  S_AXI_WVALID,
    output wire  S_AXI_WREADY,
    output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
    output wire [1 : 0] S_AXI_BRESP,
    output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
    output wire  S_AXI_BVALID,
    input wire  S_AXI_BREADY,
    input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [7 : 0] S_AXI_ARLEN,
    input wire [2 : 0] S_AXI_ARSIZE,
    input wire [1 : 0] S_AXI_ARBURST,
    input wire  S_AXI_ARLOCK,
    input wire [3 : 0] S_AXI_ARCACHE,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire [3 : 0] S_AXI_ARQOS,
    input wire [3 : 0] S_AXI_ARREGION,
    input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
    input wire  S_AXI_ARVALID,
    output wire  S_AXI_ARREADY,
    output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire  S_AXI_RLAST,
    output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
    output wire  S_AXI_RVALID,
    input wire  S_AXI_RREADY
    );
   reg [31:0]                    axi_awaddr;  
   reg [1:0]                     axi_awburst;
   reg [2:0]                     axi_awsize;
   reg                           axi_awready;
   reg                           axi_wready;
   reg [C_S_AXI_ID_WIDTH-1:0]    axi_bid;
   reg [1:0]                     axi_bresp;
   reg                           axi_bvalid;
   reg [31:0]                    axi_araddr;  
   reg [7:0]                     axi_arlen;
   reg [1:0]                     axi_arburst;
   reg [2:0]                     axi_arsize;
   reg                           axi_arready;
   reg [C_S_AXI_ID_WIDTH-1:0]    axi_rid;
   reg [C_S_AXI_DATA_WIDTH-1:0]  axi_rdata;
   reg [1:0]                     axi_rresp;
   reg                           axi_rlast;
   reg                           axi_rvalid;
   localparam integer            ADDR_LSB = (C_S_AXI_DATA_WIDTH/32)+ 1;
   assign S_AXI_AWREADY    = axi_awready;
   assign S_AXI_WREADY     = axi_wready;
   assign S_AXI_BRESP      = axi_bresp;
   assign S_AXI_BID        = axi_bid;
   assign S_AXI_BVALID     = axi_bvalid;
   assign S_AXI_ARREADY    = axi_arready;
   assign S_AXI_RDATA      = axi_rdata;
   assign S_AXI_RRESP      = axi_rresp;
   assign S_AXI_RLAST      = axi_rlast;
   assign S_AXI_RVALID     = axi_rvalid;
   assign S_AXI_RID        = axi_rid;
   assign S_AXI_BUSER      = 'd0;
   assign S_AXI_BUSER      = 'd0;
   assign S_AXI_RUSER      = 'd0;
   reg              write_active;
   reg              b_wait;      
   wire             last_wr_beat = axi_wready & S_AXI_WVALID & S_AXI_WLAST;
   always @( posedge S_AXI_ACLK ) begin
      if( S_AXI_ARESETN == 1'b0 )  begin
         axi_awready <= 1'b0;
         write_active <= 1'b0;
      end else begin
         if( ~axi_awready & ~write_active & ~b_wait )
           axi_awready <= 1'b1;
         else if( S_AXI_AWVALID )
           axi_awready <= 1'b0;
         if( axi_awready & S_AXI_AWVALID )
           write_active <= 1'b1;
         else if( last_wr_beat )
           write_active <= 1'b0;
      end 
   end 
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 )  begin
         axi_bid      <= 'd0;  
         axi_awaddr   <= 'd0;
         axi_awsize   <= 3'd0;
         axi_awburst  <= 2'd0;
      end else begin
         if( axi_awready & S_AXI_AWVALID ) begin
            axi_bid      <= S_AXI_AWID;
            axi_awaddr   <= { ecfg_coreid[11:C_S_AXI_ADDR_WIDTH-20],
                              S_AXI_AWADDR };
            axi_awsize   <= S_AXI_AWSIZE;  
            axi_awburst  <= S_AXI_AWBURST; 
         end else if( S_AXI_WVALID & axi_wready ) begin
            if( axi_awburst == 2'b01 ) begin 
               axi_awaddr[31:ADDR_LSB] <= axi_awaddr[31:ADDR_LSB] + 32'd1;
               axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
            end  
         end 
      end 
   end 
   always @( posedge S_AXI_ACLK ) begin
      if( S_AXI_ARESETN == 1'b0 ) begin
         axi_wready <= 1'b0;
      end else begin
         if( last_wr_beat )
           axi_wready <= 1'b0;
         else if( write_active )
           axi_wready <= ~emwr_prog_full;
      end 
   end 
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
         axi_bvalid <= 1'b0;
         axi_bresp  <= 2'b0;
         b_wait     <= 1'b0;
      end else begin
         if( last_wr_beat ) begin
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0;       
            b_wait     <= ~S_AXI_BREADY;  
         end else if (S_AXI_BREADY & axi_bvalid) begin
            axi_bvalid <= 1'b0;
            b_wait     <= 1'b0;
         end
      end 
   end 
   reg           read_active;
   reg [31:0]    read_addr;
   wire          last_rd_beat = axi_rvalid & axi_rlast & S_AXI_RREADY;
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
         axi_arready <= 1'b0;
         read_active <= 1'b0;
      end else begin    
         if( ~axi_arready & ~read_active )
            axi_arready <= 1'b1;
         else if( S_AXI_ARVALID )
            axi_arready <= 1'b0;
         if( axi_arready & S_AXI_ARVALID )
           read_active <= 1'b1;
         else if( last_rd_beat )
           read_active <= 1'b0;
      end 
   end 
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
         axi_araddr  <= 0;
         axi_arlen   <= 8'd0;
         axi_arburst <= 2'd0;
         axi_arsize  <= 2'b0;
         axi_rlast   <= 1'b0;
         axi_rid     <= 'd0;
      end else begin
         if( axi_arready & S_AXI_ARVALID ) begin
            axi_araddr  <= { ecfg_coreid[11:C_S_AXI_ADDR_WIDTH-20],
                            S_AXI_ARADDR };     
            axi_arlen   <= S_AXI_ARLEN;
            axi_arburst <= S_AXI_ARBURST;
            axi_arsize  <= S_AXI_ARSIZE;
            axi_rlast   <= ~(|S_AXI_ARLEN);
            axi_rid     <= S_AXI_ARID;
         end else if(axi_rvalid & S_AXI_RREADY) begin
            axi_arlen <= axi_arlen - 1;
            if(axi_arlen == 8'd1)
              axi_rlast <= 1'b1;
            if( S_AXI_ARBURST == 2'b01) begin 
               axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
               axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
            end
         end 
      end 
   end 
   reg [31:0]  aligned_data;
   reg [31:0]  aligned_addr;
   reg [1:0]   wsize;
   reg         pre_wr_en;   
   reg [3:0]   ctrl_mode;   
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
         aligned_data <= 'd0;
         aligned_addr <= 'd0;
         wsize        <= 2'd0;
         emwr_wr_data <= 'd0;
         pre_wr_en    <= 1'b0;
         emwr_wr_en   <= 1'b0;
         ctrl_mode    <= 'd0;
      end else begin
         ctrl_mode <= ecfg_tx_ctrl_mode;  
         aligned_addr[31:2] <= axi_awaddr[31:2];
         if( S_AXI_WSTRB[0] ) begin
            aligned_data      <= S_AXI_WDATA[31:0];
            aligned_addr[1:0] <= 2'd0;
         end else if(S_AXI_WSTRB[1] ) begin
            aligned_data <= {8'd0, S_AXI_WDATA[31:8]};
            aligned_addr[1:0] <= 2'd1;
         end else if(S_AXI_WSTRB[2] ) begin
            aligned_data <= {16'd0, S_AXI_WDATA[31:16]};
            aligned_addr[1:0] <= 2'd2;
         end else begin
            aligned_data <= {24'd0, S_AXI_WDATA[31:24]};
            aligned_addr[1:0] <= 2'd3;
         end
         wsize <= axi_awsize[1:0];
         pre_wr_en <= axi_wready & S_AXI_WVALID;
         emwr_wr_en <= pre_wr_en;
         emwr_wr_data <=                         
           { 1'b1,            
             wsize,           
             ctrl_mode,
             aligned_addr,    
             32'd0,           
             aligned_data};
      end 
   end 
   reg       ractive_reg;  
   reg       rnext;
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
         emrq_wr_en   <= 1'b0;
         emrq_wr_data <= 'd0;
         ractive_reg  <= 1'b0;
         rnext        <= 1'b0;
      end else begin
         ractive_reg <= read_active;
         rnext <= axi_rvalid & S_AXI_RREADY & ~axi_rlast;
         emrq_wr_en <= ( ~ractive_reg & read_active ) | rnext;
         emrq_wr_data <=
           { 1'b0,             
             axi_arsize[1:0],  
             ctrl_mode,
             axi_araddr,       
             {C_READ_TAG_ADDR, 20'd0},  
             32'd0             
             };
      end 
   end 
   assign emrr_rd_en = ~emrr_empty;
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
         axi_rvalid <= 1'b0;
         axi_rdata  <= 'd0;
         axi_rresp  <= 2'd0;
      end else begin
         if( ~emrr_empty ) begin
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'd0;
            case( axi_arsize[1:0] )
              2'b00: axi_rdata <= {4{emrr_rd_data[7:0]}};
              2'b01: axi_rdata <= {2{emrr_rd_data[15:0]}};
              default: axi_rdata <= emrr_rd_data;
            endcase 
         end else if( S_AXI_RREADY ) begin 
            axi_rvalid <= 1'b0;
         end
      end 
   end 
endmodule
