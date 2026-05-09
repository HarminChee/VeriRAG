`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module decoder_axi_m_v1_0_M00_AXI #
(
  parameter integer C_M_AXI_BURST_LEN = 128,
  parameter integer C_M_AXI_ID_WIDTH  = 1,
  parameter integer C_M_AXI_ADDR_WIDTH  = 32,
  parameter integer C_M_AXI_DATA_WIDTH  = 32,
  parameter integer C_M_AXI_AWUSER_WIDTH  = 0,
  parameter integer C_M_AXI_ARUSER_WIDTH  = 0,
  parameter integer C_M_AXI_WUSER_WIDTH = 0,
  parameter integer C_M_AXI_RUSER_WIDTH = 0,
  parameter integer C_M_AXI_BUSER_WIDTH = 0
)
(
  output wire rburst_active,
  output wire wburst_active,
  output wire wnext,
  output reg error_reg,
  input wire dram_rreq,
  input wire dram_wreq,
  input wire [C_M_AXI_ADDR_WIDTH-1:0] dram_raddr,
  input wire [C_M_AXI_ADDR_WIDTH-1:0] dram_waddr,
  input wire [31:0] outgoing_data,
  input wire  M_AXI_ACLK,
  input wire  M_AXI_ARESETN,
  output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
  output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
  output wire [7 : 0] M_AXI_AWLEN,
  output wire [2 : 0] M_AXI_AWSIZE,
  output wire [1 : 0] M_AXI_AWBURST,
  output wire  M_AXI_AWLOCK,
  output wire [3 : 0] M_AXI_AWCACHE,
  output wire [2 : 0] M_AXI_AWPROT,
  output wire [3 : 0] M_AXI_AWQOS,
  output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
  output wire  M_AXI_AWVALID,
  input wire  M_AXI_AWREADY,
  output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
  output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
  output wire  M_AXI_WLAST,
  output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
  output wire  M_AXI_WVALID,
  input wire  M_AXI_WREADY,
  input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
  input wire [1 : 0] M_AXI_BRESP,
  input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
  input wire  M_AXI_BVALID,
  output wire  M_AXI_BREADY,
  output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
  output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
  output wire [7 : 0] M_AXI_ARLEN,
  output wire [2 : 0] M_AXI_ARSIZE,
  output wire [1 : 0] M_AXI_ARBURST,
  output wire  M_AXI_ARLOCK,
  output wire [3 : 0] M_AXI_ARCACHE,
  output wire [2 : 0] M_AXI_ARPROT,
  output wire [3 : 0] M_AXI_ARQOS,
  output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
  output wire  M_AXI_ARVALID,
  input wire  M_AXI_ARREADY,
  input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
  input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
  input wire [1 : 0] M_AXI_RRESP,
  input wire  M_AXI_RLAST,
  input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
  input wire  M_AXI_RVALID,
  output wire  M_AXI_RREADY
);
  function integer clogb2 (input integer bit_depth);              
  begin
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
      bit_depth = bit_depth >> 1;                                 
    end
  endfunction
 localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);
 localparam integer C_MASTER_LENGTH = 12;
 localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);
reg [C_M_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
reg   axi_awvalid;
reg   axi_wlast;
reg   axi_wvalid;
reg   axi_bready;
reg [C_M_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
reg   axi_arvalid;
reg   axi_rready;
reg [C_TRANSACTIONS_NUM : 0]  write_index;
reg [C_M_AXI_ADDR_WIDTH-1 : 0]  dram_waddr_registered;
reg [C_M_AXI_ADDR_WIDTH-1 : 0]  dram_raddr_registered;
always @ (posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 0) begin
    dram_waddr_registered = 0;
    dram_raddr_registered = 0;
  end else begin
    if (dram_wreq) begin
      dram_waddr_registered <= dram_waddr;
    end
    if (dram_rreq) begin
      dram_raddr_registered <= dram_raddr;
    end
  end
end
reg   burst_write_active;
reg   burst_read_active;
wire    write_resp_error;
wire    read_resp_error;
wire    start_burst_write;
wire    start_burst_read;
assign start_burst_write = dram_wreq && ~burst_write_active;
assign start_burst_read = dram_rreq && ~burst_read_active;
assign M_AXI_AWID = 'b0;
assign M_AXI_AWADDR = dram_waddr_registered;
assign M_AXI_AWLEN  = C_M_AXI_BURST_LEN - 1;
assign M_AXI_AWSIZE = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
assign M_AXI_AWBURST  = 2'b01;
assign M_AXI_AWLOCK = 1'b0;
assign M_AXI_AWCACHE  = 4'b0010;
assign M_AXI_AWPROT = 3'h0;
assign M_AXI_AWQOS  = 4'h0;
assign M_AXI_AWUSER = 'b1;
assign M_AXI_AWVALID  = axi_awvalid;
assign M_AXI_WDATA  = outgoing_data;
assign M_AXI_WSTRB  = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
assign M_AXI_WLAST  = axi_wlast;
assign M_AXI_WUSER  = 'b0;
assign M_AXI_WVALID = axi_wvalid;
assign M_AXI_BREADY = axi_bready;
assign M_AXI_ARID = 'b0;
assign M_AXI_ARADDR = dram_raddr_registered;
assign M_AXI_ARLEN  = C_M_AXI_BURST_LEN-1;
assign M_AXI_ARSIZE = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
assign M_AXI_ARBURST  = 2'b01;
assign M_AXI_ARLOCK = 1'b0;
assign M_AXI_ARCACHE  = 4'b0010;
assign M_AXI_ARPROT = 3'h0;
assign M_AXI_ARQOS  = 4'h0;
assign M_AXI_ARUSER = 'b1;
assign M_AXI_ARVALID  = axi_arvalid;
assign M_AXI_RREADY = axi_rready;
assign burst_size_bytes = C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
always @(posedge M_AXI_ACLK)
begin
  if (M_AXI_ARESETN == 0)
    begin
      axi_awvalid <= 1'b0;
    end
  else if (~axi_awvalid && start_burst_write)
    begin
      axi_awvalid <= 1'b1;
    end
  else if (M_AXI_AWREADY && axi_awvalid)
    begin
      axi_awvalid <= 1'b0;
    end
  else
    axi_awvalid <= axi_awvalid;
  end
assign wnext = M_AXI_WREADY & axi_wvalid;
always @(posedge M_AXI_ACLK)
begin        
  if (M_AXI_ARESETN == 0)
    begin    
      axi_wvalid <= 1'b0;
    end      
  else if (~axi_wvalid && start_burst_write)
    begin    
      axi_wvalid <= 1'b1;
    end      
  else if (wnext && axi_wlast)
    axi_wvalid <= 1'b0;
  else
    axi_wvalid <= axi_wvalid;
end
always @(posedge M_AXI_ACLK)
begin        
  if (M_AXI_ARESETN == 0)
    begin    
      axi_wlast <= 1'b0;
    end      
  else if (((write_index == C_M_AXI_BURST_LEN-2 && C_M_AXI_BURST_LEN >= 2) && wnext) || (C_M_AXI_BURST_LEN == 1 ))
    begin    
      axi_wlast <= 1'b1;
    end      
  else if (wnext)
    axi_wlast <= 1'b0;
  else if (axi_wlast && C_M_AXI_BURST_LEN == 1)                                   
    axi_wlast <= 1'b0;
  else       
    axi_wlast <= axi_wlast;
end          
always @(posedge M_AXI_ACLK)
begin        
  if (M_AXI_ARESETN == 0 || start_burst_write == 1'b1)    
    begin    
      write_index <= 0;
    end      
  else if (wnext && (write_index != C_M_AXI_BURST_LEN-1))                         
    begin    
      write_index <= write_index + 1;                                             
    end      
  else       
    write_index <= write_index;
end
always @(posedge M_AXI_ACLK)                                     
begin
  if (M_AXI_ARESETN == 0)                                            
    begin
      axi_bready <= 1'b0;                                             
    end
  else if (M_AXI_BVALID && ~axi_bready)                               
    begin
      axi_bready <= 1'b1;                                             
    end
  else if (axi_bready)                                                
    begin
      axi_bready <= 1'b0;                                             
    end
  else
    axi_bready <= axi_bready;                                         
end
assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]; 
always @(posedge M_AXI_ACLK)                                 
begin
  if (M_AXI_ARESETN == 0)                                         
    begin
      axi_arvalid <= 1'b0;                                         
    end
  else if (~axi_arvalid && start_burst_read)                
    begin
      axi_arvalid <= 1'b1;                                         
    end
  else if (M_AXI_ARREADY && axi_arvalid)                           
    begin
      axi_arvalid <= 1'b0;                                         
    end
  else
    axi_arvalid <= axi_arvalid;                                    
end
always @(posedge M_AXI_ACLK)                                          
begin
  if (M_AXI_ARESETN == 0)                  
    begin
      axi_rready <= 1'b0;                                             
    end
  else if (M_AXI_RVALID)                       
    begin                                      
       if (M_AXI_RLAST && axi_rready)          
        begin                                  
          axi_rready <= 1'b0;                  
        end                                    
       else                                    
         begin                                 
           axi_rready <= 1'b1;                 
         end                                   
    end                                        
end                                            
assign read_resp_error = axi_rready & M_AXI_RVALID & M_AXI_RRESP[1];  
always @(posedge M_AXI_ACLK)                                 
begin
  if (M_AXI_ARESETN == 0)                                          
    begin
      error_reg <= 1'b0;                                           
    end
  else if (write_resp_error || read_resp_error)   
    begin
      error_reg <= 1'b1;                                           
    end
  else
    error_reg <= error_reg;                                        
end
always @(posedge M_AXI_ACLK)         
begin                                
  if (M_AXI_ARESETN == 0)            
    burst_write_active <= 1'b0;      
  else if (start_burst_write) 
    burst_write_active <= 1'b1;      
  else if (M_AXI_BVALID && axi_bready)
    burst_write_active <= 0;         
end
always @(posedge M_AXI_ACLK)         
begin                                
  if (M_AXI_ARESETN == 0)            
    burst_read_active <= 1'b0;       
  else if (start_burst_read)  
    burst_read_active <= 1'b1;       
  else if (M_AXI_RVALID && axi_rready && M_AXI_RLAST)
    burst_read_active <= 0;          
end
assign rburst_active = burst_read_active;
assign wburst_active = burst_write_active;
endmodule
