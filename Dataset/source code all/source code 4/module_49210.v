`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_dwidth_converter_v2_1_7_axi4lite_downsizer #
  (
   parameter         C_FAMILY                         = "none", 
   parameter integer C_AXI_ADDR_WIDTH                 = 32, 
   parameter integer C_AXI_SUPPORTS_WRITE             = 1,
   parameter integer C_AXI_SUPPORTS_READ              = 1
   )
  (
   input  wire                              aresetn,
   input  wire                              aclk,
   input  wire [C_AXI_ADDR_WIDTH-1:0]       s_axi_awaddr,
   input  wire [3-1:0]                      s_axi_awprot,
   input  wire                              s_axi_awvalid,
   output wire                              s_axi_awready,
   input  wire [64-1:0]                     s_axi_wdata,
   input  wire [64/8-1:0]                   s_axi_wstrb,
   input  wire                              s_axi_wvalid,
   output wire                              s_axi_wready,
   output wire [2-1:0]                      s_axi_bresp,
   output wire                              s_axi_bvalid,
   input  wire                              s_axi_bready,
   input  wire [C_AXI_ADDR_WIDTH-1:0]       s_axi_araddr,
   input  wire [3-1:0]                      s_axi_arprot,
   input  wire                              s_axi_arvalid,
   output wire                              s_axi_arready,
   output wire [64-1:0]                     s_axi_rdata,
   output wire [2-1:0]                      s_axi_rresp,
   output wire                              s_axi_rvalid,
   input  wire                              s_axi_rready,
   output wire [C_AXI_ADDR_WIDTH-1:0]       m_axi_awaddr,
   output wire [3-1:0]                      m_axi_awprot,
   output wire                              m_axi_awvalid,
   input  wire                              m_axi_awready,
   output wire [32-1:0]                     m_axi_wdata,
   output wire [32/8-1:0]                   m_axi_wstrb,
   output wire                              m_axi_wvalid,
   input  wire                              m_axi_wready,
   input  wire [2-1:0]                      m_axi_bresp,
   input  wire                              m_axi_bvalid,
   output wire                              m_axi_bready,
   output wire [C_AXI_ADDR_WIDTH-1:0]       m_axi_araddr,
   output wire [3-1:0]                      m_axi_arprot,
   output wire                              m_axi_arvalid,
   input  wire                              m_axi_arready,
   input  wire [32-1:0]                     m_axi_rdata,
   input  wire [2-1:0]                      m_axi_rresp,
   input  wire                              m_axi_rvalid,
   output wire                              m_axi_rready
   );
  reg                                       s_axi_arready_i ;
  reg                                       s_axi_rvalid_i  ;
  reg                                       m_axi_arvalid_i ;
  reg                                       m_axi_rready_i  ;
  reg                                       split_ar        ;
  reg                                       split_r         ;
  reg                                       ar_start        ;
  reg                                       aw_start        ;
  reg                                       ar_done         ;
  reg  [31:0]                               rdata_low       ;
  reg  [1:0]                                rresp_low       ;
  reg                                       s_axi_awready_i ;
  reg                                       s_axi_bvalid_i  ;
  reg                                       m_axi_awvalid_i ;
  reg                                       m_axi_wvalid_i  ;
  reg                                       m_axi_bready_i  ;
  reg                                       split_aw        ;
  reg                                       split_w         ;
  reg                                       high_aw         ;
  reg                                       aw_done         ;
  reg                                       w_done          ;
  reg  [1:0]                                bresp_low       ;
  wire [C_AXI_ADDR_WIDTH-1:0]               s_axaddr        ;
  wire [C_AXI_ADDR_WIDTH-1:0]               m_axaddr        ;
  generate
  if (C_AXI_SUPPORTS_READ != 0) begin : gen_read
    always @(posedge aclk) begin
      if (~aresetn) begin
        s_axi_arready_i <= 1'b0 ;
        s_axi_rvalid_i  <= 1'b0 ;
        m_axi_arvalid_i <= 1'b0 ;
        m_axi_rready_i  <= 1'b0 ;
        split_ar        <= 1'b0 ;
        split_r         <= 1'b0 ;
        ar_start        <= 1'b0 ;
        ar_done         <= 1'b0 ;
        rdata_low       <= 32'b0 ;
        rresp_low       <= 2'b0 ;
      end else begin
        m_axi_rready_i <= 1'b0; 
        if (s_axi_rvalid_i) begin
          if (s_axi_rready) begin
            s_axi_rvalid_i <= 1'b0;
            m_axi_rready_i <= 1'b1; 
            split_ar <= 1'b0;
            split_r <= 1'b0;
            ar_start <= 1'b0;
          end
        end else if (s_axi_arready_i) begin
          s_axi_arready_i <= 1'b0; 
          s_axi_rvalid_i <= 1'b1;
        end else if (ar_done) begin
          if (m_axi_rvalid) begin
            ar_done <= 1'b0;
            if (split_ar & ~split_r) begin
              split_r <= 1'b1;
              rdata_low <= m_axi_rdata;
              rresp_low <= m_axi_rresp;
              m_axi_rready_i <= 1'b1; 
              m_axi_arvalid_i <= 1'b1;
            end else begin
              s_axi_arready_i <= 1'b1; 
            end
          end
        end else if (m_axi_arvalid_i) begin
          if (m_axi_arready) begin
            m_axi_arvalid_i <= 1'b0;
            ar_done <= 1'b1;
          end
        end else if (s_axi_arvalid & ((C_AXI_SUPPORTS_WRITE==0) | (~aw_start))) begin
          m_axi_arvalid_i <= 1'b1;
          split_ar <= ~s_axi_araddr[2];
          ar_start <= 1'b1;
        end
      end
    end
    assign s_axi_arready = s_axi_arready_i ;
    assign s_axi_rvalid  = s_axi_rvalid_i  ;
    assign m_axi_arvalid = m_axi_arvalid_i ;
    assign m_axi_rready  = m_axi_rready_i  ;
    assign m_axi_araddr = m_axaddr;
    assign s_axi_rresp    = split_r ? ({m_axi_rresp[1], &m_axi_rresp} | {rresp_low[1], &rresp_low}) : m_axi_rresp;
    assign s_axi_rdata    = split_r ? {m_axi_rdata,rdata_low} : {m_axi_rdata,m_axi_rdata};
    assign m_axi_arprot   = s_axi_arprot;
  end else begin : gen_noread
    assign s_axi_arready = 1'b0 ;
    assign s_axi_rvalid  = 1'b0 ;
    assign m_axi_arvalid = 1'b0 ;
    assign m_axi_rready  = 1'b0 ;
    assign m_axi_araddr  = {C_AXI_ADDR_WIDTH{1'b0}} ;
    assign s_axi_rresp   = 2'b0 ;
    assign s_axi_rdata   = 64'b0 ;
    assign m_axi_arprot  = 3'b0 ;
    always @ * begin
      ar_start = 1'b0;
      split_r = 1'b0;
    end
  end
  if (C_AXI_SUPPORTS_WRITE != 0) begin : gen_write
    always @(posedge aclk) begin
      if (~aresetn) begin
        s_axi_awready_i <= 1'b0 ;
        s_axi_bvalid_i  <= 1'b0 ;
        m_axi_awvalid_i <= 1'b0 ;
        m_axi_wvalid_i  <= 1'b0 ;
        m_axi_bready_i  <= 1'b0 ;
        split_aw        <= 1'b0 ;
        split_w         <= 1'b0 ;
        high_aw         <= 1'b0 ;
        aw_start        <= 1'b0 ;
        aw_done         <= 1'b0 ;
        w_done          <= 1'b0 ;
        bresp_low       <= 2'b0 ;
      end else begin
        m_axi_bready_i <= 1'b0; 
        if (s_axi_bvalid_i) begin
          if (s_axi_bready) begin
            s_axi_bvalid_i <= 1'b0;
            m_axi_bready_i <= 1'b1; 
            split_aw <= 1'b0;
            split_w <= 1'b0;
            high_aw <= 1'b0;
            aw_start <= 1'b0 ;
          end
        end else if (s_axi_awready_i) begin
          s_axi_awready_i <= 1'b0; 
          s_axi_bvalid_i <= 1'b1;
        end else if (aw_done & w_done) begin
          if (m_axi_bvalid) begin
            aw_done <= 1'b0;
            w_done <= 1'b0;
            if (split_aw & ~split_w) begin
              split_w <= 1'b1;
              bresp_low <= m_axi_bresp;
              m_axi_bready_i <= 1'b1; 
              m_axi_awvalid_i <= 1'b1;
              m_axi_wvalid_i <= 1'b1;
            end else begin
              s_axi_awready_i <= 1'b1; 
            end
          end
        end else begin
          if (m_axi_awvalid_i | m_axi_wvalid_i) begin
            if (m_axi_awvalid_i & m_axi_awready) begin
              m_axi_awvalid_i <= 1'b0;
              aw_done <= 1'b1;
            end
            if (m_axi_wvalid_i & m_axi_wready) begin
              m_axi_wvalid_i <= 1'b0;
              w_done <= 1'b1;
            end
          end else if (s_axi_awvalid & s_axi_wvalid & ~aw_done & ~w_done & ((C_AXI_SUPPORTS_READ==0) | (~ar_start & ~s_axi_arvalid))) begin
            m_axi_awvalid_i <= 1'b1;
            m_axi_wvalid_i <= 1'b1;
            aw_start        <= 1'b1 ;
            split_aw <= ~s_axi_awaddr[2] & (|s_axi_wstrb[7:4]) & (|s_axi_wstrb[3:0]);
            high_aw <= ~s_axi_awaddr[2] & (|s_axi_wstrb[7:4]) & ~(|s_axi_wstrb[3:0]);
          end
        end
      end
    end
    assign s_axi_awready = s_axi_awready_i ;
    assign s_axi_wready  = s_axi_awready_i ;
    assign s_axi_bvalid  = s_axi_bvalid_i  ;
    assign m_axi_awvalid = m_axi_awvalid_i ;
    assign m_axi_wvalid  = m_axi_wvalid_i  ;
    assign m_axi_bready  = m_axi_bready_i  ;
    assign m_axi_awaddr = m_axaddr;
    assign s_axi_bresp    = split_w ? ({m_axi_bresp[1], &m_axi_bresp} | {bresp_low[1], &bresp_low}) : m_axi_bresp;
    assign m_axi_wdata    = (split_w | s_axi_awaddr[2] | (|s_axi_wstrb[7:4]) & ~(|s_axi_wstrb[3:0])) ? s_axi_wdata[63:32] : s_axi_wdata[31:0];
    assign m_axi_wstrb    = (split_w | s_axi_awaddr[2] | (|s_axi_wstrb[7:4]) & ~(|s_axi_wstrb[3:0])) ? s_axi_wstrb[7:4] : s_axi_wstrb[3:0];
    assign m_axi_awprot   = s_axi_awprot;
  end else begin : gen_nowrite
    assign s_axi_awready = 1'b0 ;
    assign s_axi_wready  = 1'b0 ;
    assign s_axi_bvalid  = 1'b0 ;
    assign m_axi_awvalid = 1'b0 ;
    assign m_axi_wvalid  = 1'b0 ;
    assign m_axi_bready  = 1'b0 ;
    assign m_axi_awaddr  = {C_AXI_ADDR_WIDTH{1'b0}} ;
    assign s_axi_bresp   = 2'b0 ;
    assign m_axi_wdata   = 32'b0 ;
    assign m_axi_wstrb   = 4'b0 ;
    assign m_axi_awprot  = 3'b0 ;
    always @ * begin
      aw_start = 1'b0;
      split_w = 1'b0;
    end
  end
  if (C_AXI_SUPPORTS_WRITE == 0) begin : gen_ro_addr
    assign m_axaddr = split_r ? ({s_axi_araddr[C_AXI_ADDR_WIDTH-1:2], 2'b00}  | 3'b100) : s_axi_araddr;
  end else if (C_AXI_SUPPORTS_READ == 0) begin : gen_wo_addr
    assign m_axaddr = (split_w | high_aw) ? ({s_axi_awaddr[C_AXI_ADDR_WIDTH-1:2], 2'b00}  | 3'b100) : s_axi_awaddr;
  end else begin : gen_rw_addr
    assign s_axaddr = ar_start ? s_axi_araddr : s_axi_awaddr;
    assign m_axaddr = (split_w | split_r | high_aw) ? ({s_axaddr[C_AXI_ADDR_WIDTH-1:2], 2'b00}  | 3'b100) : s_axaddr;
  end
  endgenerate
endmodule
