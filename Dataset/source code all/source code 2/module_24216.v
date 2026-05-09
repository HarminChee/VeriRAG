`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module axis_ram_writer #
(
  parameter integer ADDR_WIDTH = 20,
  parameter integer AXI_ID_WIDTH = 6,
  parameter integer AXI_ADDR_WIDTH = 32,
  parameter integer AXI_DATA_WIDTH = 64,
  parameter integer AXIS_TDATA_WIDTH = 64
)
(
  input  wire                        aclk,
  input  wire                        aresetn,
  input  wire [AXI_ADDR_WIDTH-1:0]   cfg_data,
  output wire [ADDR_WIDTH-1:0]       sts_data,
  output wire [AXI_ID_WIDTH-1:0]     m_axi_awid,    
  output wire [AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,  
  output wire [3:0]                  m_axi_awlen,   
  output wire [2:0]                  m_axi_awsize,  
  output wire [1:0]                  m_axi_awburst, 
  output wire [3:0]                  m_axi_awcache, 
  output wire                        m_axi_awvalid, 
  input  wire                        m_axi_awready, 
  output wire [AXI_ID_WIDTH-1:0]     m_axi_wid,     
  output wire [AXI_DATA_WIDTH-1:0]   m_axi_wdata,   
  output wire [AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,   
  output wire                        m_axi_wlast,   
  output wire                        m_axi_wvalid,  
  input  wire                        m_axi_wready,  
  input  wire                        m_axi_bvalid,  
  output wire                        m_axi_bready,  
  output wire                        s_axis_tready,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid
);
  function integer clogb2 (input integer value);
    for(clogb2 = 0; value > 0; clogb2 = clogb2 + 1) value = value >> 1;
  endfunction
  localparam integer ADDR_SIZE = clogb2((AXI_DATA_WIDTH/8)-1);
  reg int_awvalid_reg, int_awvalid_next;
  reg int_wvalid_reg, int_wvalid_next;
  reg [ADDR_WIDTH-1:0] int_addr_reg, int_addr_next;
  reg [AXI_ID_WIDTH-1:0] int_wid_reg, int_wid_next;
  wire int_full_wire, int_empty_wire, int_rden_wire;
  wire int_wlast_wire, int_tready_wire;
  wire [71:0] int_wdata_wire;
  assign int_tready_wire = ~int_full_wire;
  assign int_wlast_wire = &int_addr_reg[3:0];
  assign int_rden_wire = m_axi_wready & int_wvalid_reg;
  FIFO36E1 #(
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .ALMOST_EMPTY_OFFSET(13'hf),
    .DATA_WIDTH(72),
    .FIFO_MODE("FIFO36_72")
  ) fifo_0 (
    .FULL(int_full_wire),
    .ALMOSTEMPTY(int_empty_wire),
    .RST(~aresetn),
    .WRCLK(aclk),
    .WREN(int_tready_wire & s_axis_tvalid),
    .DI({{(72-AXIS_TDATA_WIDTH){1'b0}}, s_axis_tdata}),
    .RDCLK(aclk),
    .RDEN(int_rden_wire),
    .DO(int_wdata_wire)
  );
  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_awvalid_reg <= 1'b0;
      int_wvalid_reg <= 1'b0;
      int_addr_reg <= {(ADDR_WIDTH){1'b0}};
      int_wid_reg <= {(AXI_ID_WIDTH){1'b0}};
    end
    else
    begin
      int_awvalid_reg <= int_awvalid_next;
      int_wvalid_reg <= int_wvalid_next;
      int_addr_reg <= int_addr_next;
      int_wid_reg <= int_wid_next;
    end
  end
  always @*
  begin
    int_awvalid_next = int_awvalid_reg;
    int_wvalid_next = int_wvalid_reg;
    int_addr_next = int_addr_reg;
    int_wid_next = int_wid_reg;
    if(~int_empty_wire & ~int_awvalid_reg & ~int_wvalid_reg)
    begin
      int_awvalid_next = 1'b1;
      int_wvalid_next = 1'b1;
    end
    if(m_axi_awready & int_awvalid_reg)
    begin
      int_awvalid_next = 1'b0;
    end
    if(int_rden_wire)
    begin
      int_addr_next = int_addr_reg + 1'b1;
    end
    if(m_axi_wready & int_wlast_wire)
    begin
      int_wid_next = int_wid_reg + 1'b1;
      if(int_empty_wire)
      begin
        int_wvalid_next = 1'b0;
      end
      else
      begin
        int_awvalid_next = 1'b1;
      end
    end
  end
  assign sts_data = int_addr_reg;
  assign m_axi_awid = int_wid_reg;
  assign m_axi_awaddr = cfg_data + {int_addr_reg, {(ADDR_SIZE){1'b0}}};
  assign m_axi_awlen = 4'd15;
  assign m_axi_awsize = ADDR_SIZE;
  assign m_axi_awburst = 2'b01;
  assign m_axi_awcache = 4'b1111;
  assign m_axi_awvalid = int_awvalid_reg;
  assign m_axi_wid = int_wid_reg;
  assign m_axi_wdata = int_wdata_wire[AXI_DATA_WIDTH-1:0];
  assign m_axi_wstrb = {(AXI_DATA_WIDTH/8){1'b1}};
  assign m_axi_wlast = int_wlast_wire;
  assign m_axi_wvalid = int_wvalid_reg;
  assign m_axi_bready = 1'b1;
  assign s_axis_tready = int_tready_wire;
endmodule
